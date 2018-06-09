class JSONRPC::Method

  @params : Array(String)|Int32?
  @action : Proc(String, String)

  def initialize(@params : Array(String)|Int32? = nil, &block)
    @action = ->(request : Request(JSON::Any?), builder : JSON::Builder) do
      begin
        invalid_params? request.params
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
    @action.call(req, builder)
  end

  # :nodoc:
  private def invalid_params?(parameters) : Nil
    case @params
    when Array
      @params.each{ |a| raise InvalidParams.new unless parameters[a]? }
    when Int
      raise InvalidParams.new unless @params.size == parameters.size
    when Nil
      raise InvalidParams.new if parameters
    end
  end

end
