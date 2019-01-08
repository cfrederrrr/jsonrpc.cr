require "../json/pull_parser"

abstract class JSONRPC::Handler
  # Handles notifications. This method will not return a response to the client,
  # so returning a value is not likely to be useful, unless you intend to do logging
  # outside the notify method
  abstract def notify

  # Searches the request for the "method" key and passes it, and the request
  # to #invoke_rpc(name : String, request : String)
  def handle(json : String, &block) : String
    parser = JSON::PullParser.new(json)

    case parser.kind
    when :begin_object then handle(parser, &block)
    when :begin_array  then handle_batch(parser, &block)
    else                    JSONRPC::Response(Nil).new(JSONRPC::Error.invalid_request).to_json
    end
  end

  def handle(parser : JSON::PullParser) : String
    name : String
    _parser = parser.dup

    _parser.read_object do |key|
      _parser.skip unless key == "method"
      name = String.new(_parser)
      # we don't care about the rest and don't want to waste time reading it
      break
    end

    context = invoke_rpc(name, parser)
    yield context if block_given?
    return context.response.to_json
  end

  def handle_batch(parser : JSON::PullParser, &block) : String
    JSON.build do |builder|
      builder.array do
        parser.read_array do
          # handle(parser, &block) always returns a JSON encoded string
          json.raw handle(parser, &block)
        end
      end
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
    {% for m in @type.methods %}
      {% if m.annotation(::JSONRPC::Method) %}
        {% title = "#{@type}\##{m.name}" %}
        {% if !m.annotation(::JSONRPC::Method).first %}
          {% raise "#{title}'s JSONRPC::Method annotation needs a name" %}
        {% end %}
        {% if m.args.size > 1 %}
          {% raise "#{title}: too many arguments - JSONRPC methods should take only one" %}
        {% end %}
      {% end %}
    {% end %}

    private def invoke_rpc(name : String, parser : JSON::PullParser) : JSONRPC::Context
      case name
      when ""
        # We don't care what type the params are, because the request cannot be processed
        # without a name
        JSONRPC::Context(JSON::Any, Nil).new(parser) do |request|
          JSONRPC::InvalidRequest(Nil).new("method cannot empty", request.id)
        end
      {% for m in @type.methods %} {% mp = m.args.first.restriction %} {% mr = m.return_type %}
      when {{m.first}}
        {% if m.args.first %}
        JSONRPC::Context({{mp}}, {{mr}}).new(parser) do |params|
          {{m.name}}(params)
        end
        {% else %}
        JSONRPC::Context({{mp}}, {{mr}}).new(parser) do
          {{m.name}}
        end
        {% end %}
      {% end %}
      else
        # We don't care what type the params are, because the request cannot be processed
        # if it is not registered
        JSONRPC::Context(JSON::Any, Nil).new(parser) do
          JSONRPC::MethodNotFound.new
        end
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
