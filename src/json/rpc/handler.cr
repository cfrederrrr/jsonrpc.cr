abstract class JSON::RPC::Handler
  # Handles notifications. This method will not return a response to the client,
  # so returning a value is not likely to be useful, unless you intend to do logging
  # outside the notify method

  # Searches the request for the "method" key and passes it, and the request
  # to `invoke_rpc(String, JSON::PullParser) : String`
  def handle(json : String) : String|Nil
    parser = JSON::PullParser.new(json)
    case parser.kind
    when :begin_object
      name, notification = analyze_request(JSON::PullParser.new(json))
      if notification
        handle_notification(name, parser)
      else
        handle_request(name, parser)
      end
    when :begin_array
      responses = handle_batch(parser, preparser)
      return nil if responses.empty?
      JSON.build do |builder|
        builder.array{ builder.raw responses.join(',') }
      end
    else
      JSON::RPC::Response(Nil).new(JSON::RPC::Error.invalid_request).to_json
    end
  end

  def handle_notification(parser : JSON::PullParser) : Nil
    invoke_rpc(name, parser)
    return nil
  end

  def handle_request(name : String, parser : JSON::PullParser) : String|Nil
    context = invoke_rpc(name, parser)
    inspect_context(context)
    return context.response.to_json
  end

  def handle_batch(parser : JSON::PullParser, preparser : JSON::PullParser, &block) : Array(String)
    responses = [] of String

    parser.read_array do
      preparser.read_array do
        begin
          response = handle_request(parser, preparser, &block)
          responses.push(response) if response
        rescue
          return responses
        end
      end
    end

    return responses
  end

  private def analyze_request(parser : JSON::PullParser) : Tuple(String, Bool)
    name = ""
    notification = true
    parser.read_object do |key|
      case key
      when "method" then name = String.new(parser)
      when "id"     then notification = !(String|Int32|Nil).new(parser)
      else               parser.skip
      end
    end

    {name, notification}
  end

  # Gathers up all methods annotated with `@[JSON::RPC::Method("name")]` and defines
  # the primary action method `#invoke_rpc`
  #
  # In order for this to work as expected
  # - All methods annotated as a `JSON::RPC::Method` must take one argument
  # - The `JSON::RPC::Method` annotation itself must have one String argument (the name it will be
  #   accessed as remotely)
  # - All methods annotated as a `JSON::RPC::Method` must specify a return type
  macro expose_rpc
    private def invoke_rpc(name : String, parser : JSON::PullParser) : JSON::RPC::Context
      case name
      {% for m in @type.methods %}
        {% anno = m.annotation(::JSON::RPC::Method) %} {% if anno %}
          {% if !anno[0] %}
            {% raise "#{@type}\##{m.name}'s JSON::RPC::Method annotation needs a name" %}
          {% end %}
          {% if m.args.size > 1 %}
            {% raise "#{@type}\##{m.name}: JSON::RPC methods should take only 0-1 arguments" %}
          {% end %}
          {% mp = m.args.first.restriction %}
          {% mr = m.return_type %}
      when {{anno[0]}}
        request = JSON::RPC::Request({{mp}}).new(parser)
        response = begin
            result = {{m.name}}{% if m.args.first %}(request.params.as {{mp}}){% end %}
            JSON::RPC::Response({{mr}}).new(result, request.id)
          rescue result : JSON::RPC::Error
            JSON::RPC::Response(Nil).new(result, request.id)
          rescue
            JSON::RPC::Response(Nil).new(JSON::RPC::Error.internal_error, request.id)
          end
        JSON::RPC::Context({{mp}}, {{mr}}).new(request, response)
        {% end %}
      {% end %}
      when ""
        # We don't care what type the params are, because the request cannot be processed
        # without a name
        request = JSON::RPC::Request(JSON::Any).new(parser)
        result = JSON::RPC::Error.invalid_request("method cannot be empty")
        response = JSON::RPC::Response(Nil).new(result, request.id)
        JSON::RPC::Context(JSON::Any, Nil).new(request, response)
      else
        # We don't care what type the params are, because the request cannot be processed
        # if it is not registered
        request = JSON::RPC::Request(JSON::Any).new(parser)
        result = JSON::RPC::Error.method_not_found
        response = JSON::RPC::Response(Nil).new(result, request.id)
        JSON::RPC::Context(JSON::Any, Nil).new(request, response)
      end
    end
  end

  macro finished
    expose_rpc
  end
end
