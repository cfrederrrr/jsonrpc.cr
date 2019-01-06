class JSONRPC::Context::Clientside(P, R) < JSONRPC::Context(P, R)
  def initialize(@name : String, params : P, @id : JSONRPC::Context::SID = rand(0x7fffffff))
    @request = JSONRPC::Request(P).new(name, params, @id)
    begin
      json = yield(@request)
      @response = JSONRPC::Response(R).new(json)
    rescue JSON::MappingError
      @response = JSONRPC::Response(JSON::Any).new(json)
    rescue ex
      @response = nil
    end
  end
end
