class JSONRPC::Context::Serverside(P, R) < JSONRPC::Context(P, R)
  def self.new(json : String, &block)
    begin
      new(JSONRPC::Request(P).from_json(json), &block)
    rescue JSON::MappingError
      new(nil, JSONRPC::Response(Nil).new(JSONRPC::Error.invalid_request))
    rescue Exception
      new(nil, JSONRPC::Response(Nil).new(JSONRPC::Error.internal_error)
    end
  end

  def initialize(@request : JSONRPC::Request(P))
    @name, @id = @request.name, @request.id
    result : R
    begin
      result = @request.params.nil? yield : yield(@request.params)
      @response = JSONRPC::Response(R).new(result, @id) if @id
    rescue Exception
      @response = JSONRPC::Response(Nil).new(JSONRPC::Error.internal_error)
    end
  end
end
