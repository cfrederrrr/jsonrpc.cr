abstract class JSONRPC::Handler

  # Handles notifications. This method will not return a response to the client,
  # so returning a value is not likely to be useful, unless you intend to do logging
  # outside the notify method
  abstract def notify

  # Searches the request for the "method" key and passes it, and the request
  # to #invoke_rpc(name : String, request : String)
  def handle(json : String) : String
    name : String
    parser = JSON::PullParser.new(json)

    return handle_batch(parser) if parser.kind == :begin_array
    return JSONRPC::Response(Nil).new(InvalidRequest.new).to_json if parser.kind != :begin_object

    parser.read_object do |key|
      parser.skip unless key == "method"
      name = String.new(parser)
      # we no longer care about the rest right now and don't want to waste time reading it
      break
    end

    method = invoke_rpc(name, json)
    yield method if block_given?
    return method.response.to_json
  end

  def handle_batch(parser : JSON::PullParser) : Array(JSONRPC::Context)
    parser.read_array do
      # this will not work - handle does not accept JSON::PullParser as an argument
      # have to figure out how to pull out the whole object without parsing it
      # not sure if this is possible and if it's not then jsonrpc.cr can't support
      # batch requests until a workaround is found
      handle(parser)
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

    private def invoke_rpc(name : String, json : String) : JSONRPC::Context
      case name
      when ""
        # We don't care what type the params are, because the request cannot be processed
        # without a name
        request = JSONRPC::Request(JSON::Any).new(json)
        JSONRPC::Context(JSON::Any, JSONRPC::InvalidRequest).new do
          JSONRPC::InvalidRequest.new("method cannot empty")
        end
      {% for m in @type.methods %} {% params = m.args.first.restriction %} {% result = m.return_type %}
      when {{m.first}}
        request = JSONRPC::Request({{params}}).new(json)
        JSONRPC::Context({{params}}, {{result}}).new(request) do
          {{m.name}}({% if m.args.first %}request.params{% end %})
        end
      {% end %}
      else
        # We don't care what type the params are, because the request cannot be processed
        # if it is not registered
        request = JSONRPC::Request(JSON::Any).new(json)
        JSONRPC::Context(JSON::Any, JSONRPC::MethodNotFound).new(request) do
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
