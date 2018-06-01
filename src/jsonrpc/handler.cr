require "json"

require "./request"
require "./response"

class JSONRPC::Handler

  @methods = {} of String => Method

  def register_method(name : String, *params : String, &block : JSON::Any -> _)
    @methods[name] = Method.new *params, &block
  end

  def handle(json : String) : String
    parser = JSON::PullParser.new(json)

    begin
      case parser.kind
      when :begin_array
        batch = [] of Request(JSON::Any)
        parser.read_array{ batch << Request(JSON::Any).new(parser) }
        return handle batch
      when :begin_object
        request = Request(JSON::Any).new(parser)
        return handle request
      else
        return Response(Nil).new(InvalidRequest.new).to_json
      end
    rescue JSON::ParseException
      return Response(Nil).new(ParseError.new) unless request
    end

    handle(request)
  end

  def handle(batch : Array(Request(JSON::Any))) : String
    response = [] of String
    batch.each{ |request| response.push(handle request) }
    "[#{response.join(',')}]"
  end

  def handle(request : Request(JSON::Any)) : String
    unless request.jsonrpc == RPCVERSION
      return Response(Nil).new(InvalidRequest.new, request.id).to_json
    end
    m = @methods[request.name]?
    return Response(Nil).new(MethodNotFound.new, request.id).to_json if m.nil?
    result = m.call(request)
    return Response(JSON::Any).new(result.as(JSON::Any), request.id)
  end
end
