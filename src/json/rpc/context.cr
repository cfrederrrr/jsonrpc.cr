# A container class for JSON RPC method invocation includes the name, id, request and response
# of the scenario
#
# Comes with some convenience methods for assessing the status of the invocation and
# inspecting the data of the request and response
#
# Neither clientside nor serverside should realistically bother with initializing this type
# This shard intends to abstract that away from users.
class JSON::RPC::Context(P, R)
  alias SID = String | Int32 | Nil

  getter name : String
  getter id : SID
  getter request : Request(P)
  getter response : Response(R)?

  # Either side initializer if both `@request` and `@response` are already initialized
  def initialize(@request : Request(P), @response : Response(R))
    @name, @id = @request.method, @request.id
  end

  def initialize(@request : Request(P))
    @id = nil
    @response = nil
    @name = @request.method
  end

  # According to JSON RPC 2.0 specification, a request without an `@id` is
  # considered a notification and does not require a response
  def notification? : Bool
    @id.nil?
  end

  # Easy access to the params of the `@request`
  def params : P
    @request.params
  end

  # Easy access to the result of the `@response`
  def result : R?
    @response.result unless self.notification?
  end

  # Easy access to the error of the `@response`
  def error : JSON::RPC::Error?
    @response.error if error?
  end

  # Returns true if `@response` does not exist, or if the error `@response`
  # object is not nil. Otherwise, false.
  #
  # This may change in the future, as there could be a situation where access to
  # an instance of `JSON::RPC::Context` is necessary while it's still waiting on a
  # response from the server.
  def error? : Bool
    return true unless @response
    !!@response.error
  end
end
