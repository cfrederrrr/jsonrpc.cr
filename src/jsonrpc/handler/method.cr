class JSONRPC::Handler::Method
  getter process : Proc(String, String)
  getter params : Array(String)

  def initialize(*params, &blk)
    @params = params.to_a
    @process = ->(req : String) do
      begin
        request = Request(JSON::Any).new(JSON::PullParser.new(req))
        validate_params(request.params)
        result = block.call(request.params.as(JSON::Any))
        Response(typeof(result)).new(result, request.id).to_json
      rescue error : JSONRPC::Error
        Response(Nil).new(error, request.id)
      rescue perr : JSON::ParseError
        Response(Nil).new(JSONRPC::ParseError.new)
      rescue exc : Exception
        Response(Nil).new(InternalError.new, request.id)
      end
    end
  end

  private def validate_params(request)
    @params == request.params
  end

end
