require "json"

require "./request"
require "./response"

class JSONRPC::Handler

  @methods = {} of String => Method

  def register_method(name : String, *params : String, &block : JSON::Any -> _)
    @methods[name] = Method.new *params, &block
  end

  def handle(json : String)
    request = Request(JSON::Any).new(JSON::PullParser.new(json)) rescue false
    return Response(Nil).new(ParseError.new) unless request
    return Response(Nil).new(InvalidRequest.new, request.id) unless (
      request.jsonrpc == RPCVERSION
    )

    handle(request)
  end

  def handle(request : Request(JSON::Any))
    mthd = @methods[request.name]?
    if mthd.nil?
      return Response(Nil).new(MethodNotFound.new, request.id).to_json
    end

    begin
      result = mthd.call(request)
    rescue err : KeyError
      return Response(Nil).new(InvalidRequest.new, request.id)
    rescue err : Exception
      return Response(Nil).new(InternalError.new, request.id)
    end

    return Response(JSON::Any).new(result.as(JSON::Any), request.id)
  end
end
