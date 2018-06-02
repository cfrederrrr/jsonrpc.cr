require "json"

require "./request"
require "./response"

class JSONRPC::Handler

  @methods = {} of String => Method

  def register_method(name : String, params : Array(String), &block : JSON::Any -> _)
    @methods[name] = Method.new *params, &block
  end

  def handle(json : String) : String
    parser = JSON::PullParser.new(json)

    begin
      JSON.build { |builder|
        case parser.kind
        when :begin_object then handle parser, builder
        when :begin_array  then batch  parser, builder
        else Response(Nil).new(InvalidRequest.new).to_json(builder)
        end
      }
    rescue JSON::ParseException
      Response(Nil).new(ParseError.new).to_json
    end
  end

  def handle(parser : JSON::PullParser, builder : JSON::Builder) : Nil
    request = Request(JSON::Any).new(parser)
    handle_request(request, builder)
  end

  def batch(parser : JSON::PullParser, builder : JSON::Builder) : Nil
    b = [] of Request(JSON::Any)
    parser.read_array do
      b << Request(JSON::Any).new(parser)
    end

    builder.array do
      b.each do |request|
        handle_request request, builder
      end
    end
  end

  private def handle_request(req : Request(JSON::Any), builder : JSON::Builder) : Nil
    if req.jsonrpc != RPCVERSION
      Response(Nil).new(InvalidRequest.new, request.id).to_json(builder)
      return
    end

    method = @methods[req.name]?
    if method.nil?
      Response(Nil).new(MethodNotFound.new, request.id).to_json(builder)
      return
    end

    method.call(request, builder)
  end

end
