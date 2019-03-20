require "../json/pull_parser"

abstract class JSONRPC::Handler
  # Handles notifications. This method will not return a response to the client,
  # so returning a value is not likely to be useful, unless you intend to do logging
  # outside the notify method
  # abstract def notify

  # Searches the request for the "method" key and passes it, and the request
  # to #invoke_rpc(name : String, request : String)
  def handle(json : String, &block) : String
    parser = JSON::PullParser.new(json)
    classifier = JSON::PullParser.new(json)
    case parser.kind
    when :begin_object then handle_request(parser, classifier, &block)
    when :begin_array  then handle_batch(parser, classifier, &block)
    else                    JSONRPC::Response(Nil).new(JSONRPC::Error.invalid_request).to_json
    end
  end

  def handle_request(parser : JSON::PullParser, classifier : JSON::PullParser) : String | Nil
    id = nil
    name = ""

    classifier.read_object do |key|
      case key
      when "method" then name = String.new(classifier)
      when "id"     then id   = Union(String, Int32, Nil).new(parser)
      else               classifier.skip
      end
    end

    context = invoke_rpc(name, parser)
    yield context
    return context.response.to_json
  end

  def handle_batch(parser : JSON::PullParser, classifier : JSON::PullParser, &block) : String
    responses = [] of String

    parser.read_array do
      classifier.read_array do
        response = handle_request(parser, classifier, &block)
        responses.push(response) if response
      end
    end

    JSON.build do |builder|
      builder.array{ builder.raw responses.join(',') }
    end
  end

  # Gathers up all methods annotated with `@[JSONRPC::Method("name")]` and adds them to
  # the `#invoke_rpc` method
  #
  # In order for this to work as expected...
  # - All methods annotated as a `JSONRPC::Method` must take one argument
  # - The `JSONRPC::Method` annotation itself must have one String argument (the name it will be
  #   accessed as remotely)
  # - All methods annotated as a `JSONRPC::Method` must specify a return type
  # - The last line of your class definition must be `expose_rpc`
  macro expose_rpc
    private def invoke_rpc(name : String, parser : JSON::PullParser) : JSONRPC::Context
      case name
      {% for m in @type.methods %}
        {% anno = m.annotation(::JSONRPC::Method) %} {% if anno %}
          {% if !anno[0] %}
            {% raise "#{@type}\##{m.name}'s JSONRPC::Method annotation needs a name" %}
          {% end %}
          {% if m.args.size > 1 %}
            {% raise "#{@type}\##{m.name}: JSONRPC methods should take only 0-1 arguments" %}
          {% end %}
          {% mp = m.args.first.restriction %}
          {% mr = m.return_type %}
      when {{anno[0]}}
        request = JSONRPC::Request({{mp}}).new(parser)
        response = begin
            result = {{m.name}}{% if m.args.first %}(request.params.as {{mp}}){% end %}
            JSONRPC::Response({{mr}}).new(result, request.id)
          rescue result : JSONRPC::Error
            JSONRPC::Response(Nil).new(result, request.id)
          rescue
            JSONRPC::Response(Nil).new(JSONRPC::Error.internal_error, request.id)
          end
        JSONRPC::Context({{mp}}, {{mr}}).new(request, response)
        {% end %}
      {% end %}
      when ""
        # We don't care what type the params are, because the request cannot be processed
        # without a name
        request = JSONRPC::Request(JSON::Any).new(parser)
        result = JSONRPC::Error.invalid_request("method cannot be empty")
        response = JSONRPC::Response(Nil).new(result, request.id)
        JSONRPC::Context(JSON::Any, Nil).new(request, response)
      else
        # We don't care what type the params are, because the request cannot be processed
        # if it is not registered
        request = JSONRPC::Request(JSON::Any).new(parser)
        result = JSONRPC::Error.method_not_found
        response = JSONRPC::Response(Nil).new(result, request.id)
        JSONRPC::Context(JSON::Any, Nil).new(request, response) do
      end
    end
  end

  # Block inheritance from any child classes of `JSONRPC::Handler`
  # because it is not feasible to capture all methods exposed by a handler
  # class which inherits from another.
  macro inherited
    macro inherited
      raise "{{ @type }} cannot be inherited from due to limitations of crystal. " + \
            "When those limitations are dealt with, this inheritance restriction " + \
            "will be removed."
    end
  end
end
