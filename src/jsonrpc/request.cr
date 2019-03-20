require "json"

# `Request` object to be sent to the JSONRPC server
#
# `P` can be of any type parsable by `JSON::PullParser` and buildable
# with `JSON::Builder`
#
# According to
# [https://www.jsonrpc.org/specification#request_object](JSONRPC 2.0),
# specification the params key should be any "structured value that holds
# the parameter values to be used during the invocation of the method"
#
# If the method you are invoking per `@method` is one which expects
# positional parameters, `P` should build to a JSON array
# Otherwise it should build to a JSON object
#
# The server implementation always uses Request(JSON::Any)
class JSONRPC::Request(P)
  include JSON::Serializable

  alias SID = String | Int32 | Nil

  # A `String` specifying the RPC method to be invoked.
  getter method : String

  # The parameter object of the method named in `method`.
  #
  # `P` could be an array, or array like type in the case that
  # the named method takes positional arguments.
  getter params : P?

  # An identifier established by the client. If `nil` or excluded, then
  # the client does not expect a response - this is known as a
  # "notification" according to JSON RPC 2.0 specification
  getter id : SID

  # A `String` indicating the JSONRPC version
  getter jsonrpc : String

  # Clientside can create a new `Request(P)` with direct arguments, rather than with a pullparser
  def initialize(@method : String, @params : P? = nil, @id : SID = nil, @jsonrpc = "2.0")
  end
end
