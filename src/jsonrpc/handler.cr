require "json"

require "./request"
require "./response"

abstract class JSONRPC::MethodHandler
  abstract def handle_request(req : Request(JSON::Any?))

  def handle(json : String)
    begin
      request = Request(JSON::Any?).new(JSON::PullParser.new(json))
      result = handle_request(request)
      return Response(JSON::Any?).new(result, request.id)
    rescue err : JSON::ParseError
      return Response(JSON::Any?).new(JSONRPC::ParseError.new, request.id)
    rescue err : Exception
      return Response(JSON::Any?).new(JSONRPC::InternalError.new, request.id)
    end
  end
end
