# A container class for JSON RPC method invocation includes the name, id, request and response
# of the scenario
#
# Comes with some convenience methods for assessing the status of the invocation and
# inspecting the data of the request and response
class JSONRPC::Context(P, R)
  alias SID = String | Int32 | Nil

  getter name : String
  getter id : SID
  getter request : JSONRPC::Request(P)
  getter response : JSONRPC::Response(R)?

  def initialize(@request, @response)
    @name, @id = @request.name, @request.id
  end

  def initialize(@request)
    @name, @id = @request.name, @request.id
    result = yield
    @response = JSONRPC::Response(R).new(reuslt, @id) if @id
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
