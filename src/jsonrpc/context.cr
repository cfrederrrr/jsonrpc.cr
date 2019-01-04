# A container class for JSON RPC method invocation includes the name, id, request and response
# of the scenario
#
# Comes with some convenience methods for assessing the status of the invocation and
# inspecting the data of the request and response
abstract class JSONRPC::Context(P, R)
  alias SID = String | Int32 | Nil

  getter name : String
  getter id : SID
  getter request : JSONRPC::Request(P)
  getter response : JSONRPC::Response(R)?

  def initialize(@request : JSONRPC::Request(P), @response : JSONRPC::Response(R))
    @name, @id = @request.name, @request.id
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
    return true unless @response
    !!@response.error
  end
end
