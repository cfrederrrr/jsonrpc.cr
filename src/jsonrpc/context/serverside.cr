class JSONRPC::Context::Serverside(P, R) < JSONRPC::Context(P, R)
  def self.new(json : String, &block)
    begin
      new(JSONRPC::Request(P).new(json), &block)
    rescue error : JSONRPC::Error
      new(nil, JSONRPC::Response(Nil).new(error))
    rescue JSON::MappingError
      new(nil, JSONRPC::Response(Nil).new(JSONRPC::InvalidRequest.new))
    end
  end

  def initialize(@request : JSONRPC::Request(P))
    @name, @id = @request.name, @request.id
    result : R
    begin
      result = @request.params.nil? yield : yield(@request.params)
      @response = JSONRPC::Response(R).new(result, @id) if @id
    rescue error : JSONRPC::Error
      @response = JSONRPC::Response(Nil).new(error)
    rescue exception
      @response = JSONRPC::Response(Nil).new JSONRPC::InternalError.new(unknown_error.message)
    end
  end
end
