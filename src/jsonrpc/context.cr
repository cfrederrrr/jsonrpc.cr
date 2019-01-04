# A container class for JSON RPC method invocation includes the name, id, request and response
# of the scenario
#
# Comes with some convenience methods for assessing the status of the invocation and
# inspecting the data of the request and response
class JSONRPC::Context(P, R)
  alias SID = String | Int32 | Nil

  getter name : String
  getter id : SID
  getter request : JSONRPC::Request(P)?
  getter response : JSONRPC::Response(R)?

  def self.new(json : String, &block)
    begin
      new(JSONRPC::Request(P).new(json), &block)
    rescue error : JSONRPC::Error
      new(nil, JSONRPC::Response(Nil).new(error))
    end
  end

  def initialize(@request, @response)
    @name, @id = @request.name, @request.id
  end

  def initialize(@request)
    @name, @id = @request.name, @request.id
    result : R
    begin
      result = @request.params.nil? yield : yield @request.params
      @response = JSONRPC::Response(R).new(result, @id) if @id
    rescue error : JSONRPC::Error
      @response = JSONRPC::Response(Nil).new(error)
    rescue exception
      @response = JSONRPC::Response(Nil).new JSONRPC::InternalError.new(unknown_error.message)
    end
  end

  def notification?
    @id.nil?
  end

  def params
    @request.params
  end

  def result
    @response.result
  end

  def error
    @response.error
  end

  def error?
    !!@response.error
  end
end
