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

    @operation = ->(req : String) do
      begin
        request = Request(JSON::Any).new(JSON::PullParser.new(req))
        validate_params(request.params)
        result = block.call(request.params)
        Response(typeof(result)).new(result, request.id)
      rescue error : JSONRPC::Error
        Response(Nil).new(error, request.id)
      rescue perr : JSON::ParseError
        Response(Nil).new(JSONRPC::ParseError.new)
      rescue exc : Exception
        Response(Nil).new(InternalError.new, request.id)
      end
        .to_json
    end
  end

  def call(req : String)

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
  end


end
