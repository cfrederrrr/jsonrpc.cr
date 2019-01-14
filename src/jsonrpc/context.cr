# A container class for JSON RPC method invocation includes the name, id, request and response
# of the scenario
#
# Comes with some convenience methods for assessing the status of the invocation and
# inspecting the data of the request and response
#
# Neither clientside nor serverside should realistically bother with initializing this type
# This shard intends to abstract that away from users.
class JSONRPC::Context(P, R)
  alias SID = String | Int32 | Nil

  getter name : String
  getter id : SID
  getter request : JSONRPC::Request(P)
  getter response : JSONRPC::Response(R)?

  # Serverside initializer - incoming data will always be provided as a parser. See
  # `JSONRPC::Handler#invoke_rpc`
  def initialize(parser : JSON::PullParser)
    @request = JSONRPC::Request(P).new(parser)
    @name, @id = @request.method, @request.id
    @response = yield(@request)
  end

  # Clientside initializer
  def initialize(@name : String, params : P, @id : SID = rand(0x7fffffff))
    @request = JSONRPC::Request(P).new(params)
    @response = yield(@request)
  end

  # Clientside initializer when request is initialized outside `JSONRPC::Context`
  def initialize(@request : JSONRPC::Request(P))
    @name, @id = @request.method, @request.id
    @response = yield(@request)
  end

  # Either side initializer if both `@request` and `@response` are already initialized
  def initialize(@request : JSONRPC::Request(P), @response : JSONRPC::Response(R))
    @name, @id = @request.method, @request.id
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
  def result : R
    @response.result
  end

  # Easy access to the error of the `@response`
  def error : JSONRPC::Error
    @response.error
  end

  # Returns true if `@response` does not exist, or if the error `@response`
  # object is not nil. Otherwise, false.
  #
  # This may change in the future, as there could be a situation where access to
  # an instance of `JSONRPC::Context` is necessary while it's still waiting on a
  # response from the server.
  def error? : Bool
    return true unless @response
    !!@response.error
  end
end
