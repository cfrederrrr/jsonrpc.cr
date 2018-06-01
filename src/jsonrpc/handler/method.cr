class JSONRPC::Handler::Method
  getter form : Symbol = :none
  getter params : Array(String)|Int32?
  getter operation : Proc(String, String)

  def initialize(@params : Array(String)|Int32?, &block)
    @form = case @params
      when Array  then :named
      when Int    then :positional
      when Nil    then :none
      end

    @operation = ->(request : Request(JSON::Any?)) do
      begin
        validate_params(request.params)
        result = block.call(request.params)
        Response(typeof(result)).new(result, request.id)

      rescue err : JSONRPC::Error
        Response(Nil).new(err, request.id)

      rescue Exception
        Response(Nil).new(InternalError.new, request.id)

      end
        .to_json
    end
  end

  def call(req : Request(JSON::Any?))

  end

  private def validate_params(parameters)
    case @form
    when :positional
      @params.each{ |a| raise InvalidRequest.new unless parameters[a]? }
    when :named
      raise InvalidRequest.new unless @params.size == parameters.size
    when :none
      raise InvalidRequest.new if parameters
    end

    true
  end


end
