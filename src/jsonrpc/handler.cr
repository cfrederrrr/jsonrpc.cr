abstract class JSONRPC::Handler
  # Searches the request for the "method" key and passes it, and the request
  # to #invoke_rpc(name : String, request : String)
  def handle(json : String)
    method : String
    parser = JSON::PullParser.new(json)

    return handle_batch(parser) if parser.kind == :begin_array
    return JSONRPC::Response(Nil).new(InvalidRequest.new).to_json if parser.kind != :begin_object

    parser.read_object do |key|
      skip unless key == "method"
      method = String.new(parser)
      break
    end

    invoke_rpc(method_name, json)
  end

  def handle_batch(parser : JSON::PullParser)
    parser.read_array do
      # this will not work - handle does not accept JSON::PullParser as an argument
      # have to figure out how to pull out the whole object without parsing it
      # not sure if this is possible and if it's not then jsonrpc.cr can't support
      # batch requests until a workaround is found
      handle(parser)
    end
  end

  macro expose_rpc
    {% for m in @type.methods %}
      {% if m.annotation(::JSONRPC::Method) && !m.annotation(::JSONRPC::Method).first %}
        {% raise "#{@type}\##{m.name}'s JSONRPC::Method annotation needs a name" %}
      {% end %}
    {% end %}

    private def invoke_rpc(method : String, json : String)
      case name
      when ""
        raise JSONRPC::InvalidRequest.new("method cannot empty")
      {% for m in @type.methods %}
      when {{m.first}}
        {% if m.args.first %}
        request = JSONRPC::Request({{m.args.first.restriction}}).new(json)
        result = {{m.name}}(request.params)
        {% else %}
        request = JSONRPC::Request(Nil).new(json)
        result = {{m.name}}
        {% end %}
        return JSONRPC::Response({m.return_type}).new(result, request.id)
      {% end %}
      else
        raise JSONRPC::MethodNotFound.new
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
