abstract class JSON::RPC::Handler
  # Handles notifications. This method will not return a response to the client,
  # so returning a value is not likely to be useful, unless you intend to do logging
  # outside the notify method

  # Searches the request for the "method" key and passes it, and the request
  # to `invoke_rpc(String, JSON::PullParser) : String`
  def handle(parser : JSON::PullParser) : String|IO|Nil
    case parser.kind
    when .begin_object?
      context = handle_request(parser)
      return context
    when .begin_array?
      contexts = handle_batch(parser)
      return contexts
    else
      JSON::RPC::Response(Nil).new(JSON::RPC::Error.invalid_request).to_json
    end
  end

  def handle_request(parser : JSON::PullParser) : Context|Nil
    context = spawn invoke_rpc(parser)
    return context
  end

  def handle_batch(parser : JSON::PullParser) : Array(Context)
    contexts = [] of Context

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

  # Gathers up all methods annotated with `@[JSON::RPC::Method("name")]` and defines
  # the primary action method `#invoke_rpc`
  #
  # In order for this to work as expected
  # - Methods annotated as a `JSON::RPC::Method` must specify explicit argument types
  # - Methods annotated as a `JSON::RPC::Method` must specify a return type
  macro expose_rpc
  {% begin %}
    {% rpc_methods = [] of Nil %}
    {% for m in @type.methods %}
      {% anno = m.annotation(::JSON::RPC::Method) %}
      {% if anno %}
        {% if anno[0] %}
          {% title = anno[0].stringify %}
        {% else %}
          {% title = m.name.stringify %}
        {% end %}

        {% param_type = title.gsub(/[^\w]+|_+/, "_").split('_').map(&.capitalize).join("").id %}
        {% rpc_methods.push({title, param_type, m}) %}

        # define a parameters class that can be easily parsed from json
        record {{param_type}}, {{m.args}} { include JSON::Serializable }
      {% end %}
    {% end %}

    private def invoke_rpc(parser : JSON::PullParser) : Context
      begin
        request = Request({{param_type}}).new(parser)
      rescue JSON::ParseException
        request = Request(Nil).new("unknown")
        response = Response(Nil).new(Error.parse_error(error.message))
        return Context(Nil, Nil).new(request, response)
      rescue
        request = Request(Nil).new("unknown")
        response = Response(Nil).new(JSON::RPC::Error.internal_error)
        return Context(Nil, Nil).new(request, response)
      end

      case request.method
      {% for rpc_method in rpc_methods %}
      {% title, param_type, m = rpc_method %}
      when {{title}}
        begin
          request = Request({{param_type}}).new(parser)
          result = {{m.name.id}}({% for arg in m.args %} {{arg.name.id}}: request.params.{{arg.name.id}}, {% end %})
          response = Response({{m.return_type}}).new(result, request.id)
        rescue error : JSON::RPC::Error
          response = Response(Nil).new(error, request.id)
        rescue error : JSON::ParseException
          response = Response(Nil).new(JSON::RPC::Error.parse_error(error.message), request.id)
        rescue
          response = Response(Nil).new(JSON::RPC::Error.internal_error, request.id)
        end

        return Context({{param_type}}, {{m.return_type}}).new(request, response)
        {% end %}
      {% end %}
      when ""
        # We don't care what type the params are, because the request cannot be processed
        # without a method name
        request = Request(JSON::Any).new(parser)
        error = JSON::RPC::Error.invalid_request("method cannot be empty")
        response = Response(Nil).new(error, request.id)
        return Context(JSON::Any, Nil).new(request, response)
      else
        # We don't care what type the params are, because the request cannot be processed
        # if it is not defined
        request = Request(JSON::Any).new(parser)
        error = JSON::RPC::Error.method_not_found()
        response = Response(Nil).new(error, request.id)
        return Context(JSON::Any, Nil).new(request, response)
      end
    end
  {% end %}
  end

  # WARNING:
  # This classes uses the `inherited` macro to apply a uniform
  # `finished` macro to all its children. If you override the
  # `inherited` macro, be sure to include
  #
  # ```crystal
  # macro finished
  #   expose_rpc
  # end
  # ```
  #
  # at the end of your `inerited` definition.
  #
  # If you override the `finished` macro, be sure to include
  # ```crystal
  # expose_rpc
  # ```
  #
  # at the bottom of your `finished` definition.
  #
  # Otherwise, the handler will not work properly
  macro inherited
    macro finished
      expose_rpc
    end
  end
end
