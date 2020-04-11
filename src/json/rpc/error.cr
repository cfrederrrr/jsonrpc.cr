# Virtual error type so child classes can be handled the
# in the same way
#
class JSON::RPC::Error
  include JSON::Serializable

  getter message : String
  getter code : Int32

  # Data will (unfortunately) be restricted to `String` for now, since there
  # isn't a clean way to predictably parse `JSON::RPC::Response(R)` with the potential
  # for an error object of unknowable type without turning `JSON::RPC::Response(R)`
  # into an abstract class.
  #
  # Doing so would require users to define their own responses for every RPC method,
  # both clientside and serverside, containing every possible error that an RPC call
  # could ever result in, including the standard errors.
  #
  # Since I predict that most people would simply use `String` for the `@data` attribute
  # anyway, I deem this slight departure from the JSON::RPC 2.0 spec to be acceptable
  getter data : String?

  def initialize(@message : String, @code : Int32, @data : String?)
  end
end

def JSON::RPC::Error.invalid_request(data : String? = nil)
  new("Invalid Request", -32600, data)
end

def JSON::RPC::Error.method_not_found(data : String? = nil)
  new("Method not found", -32601, data)
end

def JSON::RPC::Error.invalid_params(data : String? = nil)
  new("Invalid params", -32602, data)
end

def JSON::RPC::Error.internal_error(data : String? = nil)
  new("Internal error", -32603, data)
end

def JSON::RPC::Error.parse_error(data : String? = nil)
  new("Parse error", -32700, data)
end
