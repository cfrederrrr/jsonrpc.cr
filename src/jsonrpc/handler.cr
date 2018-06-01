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

    case parser.kind
    when :begin_array
      batch = [] of Request(JSON::Any)
      parser.read_array{ batch << Request(JSON::Any).new(parser) }
      return handle batch
    when :begin_object
      request = Request(JSON::Any).new(parser)
      return handle request
    end

    return Response(Nil).new(ParseError.new) unless request
    return Response(Nil).new(InvalidRequest.new, request.id) unless (
      request.jsonrpc == RPCVERSION
    )

    handle(request)
  end

  def handle(batch : Array(Request(JSON::Any))) : String
    response = [] of String
    batch.each do |request|
      response.push handle request
    end
    "[#{response.join(',')}]"
  end

  def handle(request : Request(JSON::Any)) : String
    m = @methods[request.name]?
    return Response(Nil).new(MethodNotFound.new, request.id).to_json if m.nil?
    result = m.call(request)
    return Response(JSON::Any).new(result.as(JSON::Any), request.id)
  end
end
