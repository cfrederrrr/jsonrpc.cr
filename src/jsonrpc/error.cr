# Virtual error type so child classes can be handled the
# in the same way
#
class JSONRPC::Error(D)
  JSON.mapping(
    message: {type: String, setter: false},
    code: {type: Int32, setter: false},
    data: {type: Data, emit_null: false}
  )

  def initialize(@message : String, @code : Int32, @data : D)
  end
end

def JSONRPC::Error.invalid_request(data : D = nil)
  new("Invalid Request", -32600, data)
end

def JSONRPC::Error.method_not_found(data : D = nil)
  new("Method not found", -32601, data)
end

def JSONRPC::Error.invalid_params(data : D = nil)
  new("Invalid params", -32602, data)
end

def JSONRPC::Error.internal_error(data : D = nil)
  new("Internal error", -32603, data)
end

def JSONRPC::Error.parse_error(data : D = nil)
  new("Parse error", -32700, data)
end
