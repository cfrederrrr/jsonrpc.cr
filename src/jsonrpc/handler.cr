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

    JSON.build do |builder|
      begin
        case parser.kind
        when :begin_object
          handle Request(JSON::Any).new(parser), builder
        when :begin_array
          builder.array do
            parser.read_array do
              handle Request(JSON::Any).new(parser), builder
            end
          end
        else
          Response(Nil).new(InvalidRequest.new).to_json(builder)
        end
      rescue JSON::ParseException
        Response(Nil).new(ParseError.new).to_json(builder)
      end
    end
  end

  def handle(request : Request(JSON::Any), builder : JSON::Builder) : Nil
    if request.jsonrpc != RPCVERSION
      Response(Nil).new(InvalidRequest.new, request.id).to_json(builder)
      return nil
    end

    method = @methods[request.name]?

    if method.nil?
      Response(Nil).new(MethodNotFound.new, request.id).to_json(builder)
      return nil
    end

    method.call(request, builder)
    return nil
  end
end
