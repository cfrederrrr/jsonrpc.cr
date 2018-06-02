class JSONRPC::Handler::Method

  @params : Array(String)|Int32?
  @operation : Proc(String, String)

  def initialize(@params : Array(String)|Int32?, &block)
    @operation = ->(request : Request(JSON::Any?), builder : JSON::Builder) do
      begin
        validate_params(request.params)
        result = block.call(request.params)
        Response(typeof(result)).new(result, request.id)

      rescue err : JSONRPC::Error
        Response(Nil).new(err, request.id)

      rescue Exception
        Response(Nil).new(InternalError.new, request.id)

      end
        .to_json(builder)
    end
  end

  def call(req : Request(JSON::Any?), builder : JSON::Builder)
    @operation.call(req, builder)
  end

  private def validate_params(parameters) : Nil
    case @params
    when Int
      @params.each{ |a| raise InvalidRequest.new unless parameters[a]? }
    when Array
      raise InvalidRequest.new unless @params.size == parameters.size
    when Nil
      raise InvalidRequest.new if parameters
    end
  end


end
