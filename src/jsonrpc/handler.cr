require "json"

require "./request"
require "./response"

class JSONRPC::Handler

  @methods = {} of String => Method

  def register(name : String, params : Array(String), &block : JSON::Any -> _)
    @methods[name] = Method.new *params, &block
  end

  def method?(name : String) : Method | Bool
    @methods[name]? || false
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
    rescue err : JSONRPC::Error
      Response(Nil).new(err).to_json
    rescue JSON::ParseException
      Response(Nil).new(ParseError.new).to_json
    end
  end

  def handle(parser : JSON::PullParser, builder : JSON::Builder) : Nil
    request = Request(JSON::Any).new(parser)
    handle_request(request, builder)
  end

  # Handles a batch of requests
  # - Only returns serialized Array, even if some requests are invalid
  # - Only raises a JSON::ParseException
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
    if req.jsonrpc != "2.0"
      Response(Nil).new(InvalidRequest.new, req.id).to_json(builder)
      return
    end

    method = method? req.name
    if method.nil?
      Response(Nil).new(MethodNotFound.new, req.id).to_json(builder)
      return
    end

    method.call(req, builder)
  end

end
