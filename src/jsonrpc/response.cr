require "json"

class JSONRPC::Response(R)
  include JSON::Serializable

  alias SID = String | Int32 | Nil

  # JSON RPC version indicator.
  # Must be exactly `"2.0"` according to spec.
  getter jsonrpc : String

  # This key is included if the method ran successfully. It is excluded if
  # there was an error of any kind.
  #
  # `result` is nilable even if `R` is not; JSONRPC 2.0 specification
  # dictates that this key be absent if the `error` key is present.
  getter result : R?

  # This key is included if the method did not run successfully. It is
  # excluded if the method was enacted successfully.
  getter error : JSONRPC::Error?

  # Response has to include the same `@id` as its corresponding `Request`
  getter id : SID

  # Serverside can create a new `Response(R)` with direct arguments, rather than with a pullparser
  def initialize(@result : R, @id : SID = nil, @jsonrpc = "2.0")
    @error = nil
  end

  # Serverside can create a new `Response(R)` with direct arguments, rather than with a pullparser
  def initialize(@error : JSONRPC::Error, @id : SID = nil, @jsonrpc = "2.0")
    @result = nil
  end
end
