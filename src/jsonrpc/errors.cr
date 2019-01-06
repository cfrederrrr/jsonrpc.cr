# Virtual error type so child classes can be handled the
# in the same way
#
class JSONRPC::Error
  JSON.mapping(
    message: {type: String, default: "method-not-found", setter: false},
    code: {type: Int32, default: -32601, setter: false},
    data: {type: String?, nilable: true, default: nil, emit_null: false}
  )

  def initialize(@message : String, @code : Int32, @data, : String? = nil)
  end
end


def JSONRPC::Error.invalid_request(data = nil)
  new("invalid-request", -32600, data)
end

def JSONRPC::Error.method_not_found(data = nil)
  new("method-not-found", -32601, data)
end

def JSONRPC::Error.invalid_params(data = nil)
  new("invalid-params", -32602, data)
end

def JSONRPC::Error.internal_error(data = nil)
  new("internal-error", -32603, data)
end

def JSONRPC::Error.parse_error(data = nil)
  new("parse-error", -32700, data)
end
