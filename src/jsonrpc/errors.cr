require "json"

# Virtual error type so child classes can be handled the
# in the same way
#
abstract class JSONRPC::Error < ::Exception
  abstract def to_json
  abstract def to_json(io : IO)
end

# Exception indicating that the JSON sent is not a valid `Request(P)` object.
class JSONRPC::InvalidRequest < JSONRPC::Error
  JSON.mapping(
    message: {type: String?, default: "invalid-request", setter: false},
    code: {type: Int32, default: -32600, setter: false},
    data: {type: String?, nilable: true, default: nil, emit_null: false}
  )

  # Used serverside to generate `InvalidRequest`. Some notes:
  # - Should not be used clientside.
  # - `data` will be visible to the client - do not include information
  #   not relevant from the client's perspective here
  #
  def initialize(@data : String? = nil, @cause : Exception? = nil)
    @message = "invalid-request"
    @code = -32600
  end
end

# Exception indicating to the client that the method either does not exist or
# is not available.
class JSONRPC::MethodNotFound < JSONRPC::Error
  JSON.mapping(
    message: {type: String?, default: "method-not-found", setter: false},
    code: {type: Int32, default: -32601, setter: false},
    data: {type: String?, nilable: true, default: nil, emit_null: false}
  )

  # Used serverside to generate `MethodNotFound`. Some notes:
  # - Should not be used clientside.
  # - `data` will be visible to the client - do not include information
  #   not relevant from the client's perspective here
  #
  def initialize(@data : String? = nil, @cause : Exception? = nil)
    @message = "method-not-found"
    @code = -32601
  end
end

# Exception indicating that the `Request(P)#params` provided for the named
# `Request(P)#method` are somehow invalid
class JSONRPC::InvalidParams < JSONRPC::Error
  JSON.mapping(
    message: {type: String?, default: "invalid-params", setter: false},
    code: {type: Int32, default: -32602, setter: false},
    data: {type: String?, nilable: true, default: nil, emit_null: false}
  )

  # Used serverside to generate `InvalidParams`. Some notes:
  # - Should not be used clientside.
  # - `data` will be visible to the client - do not include information
  #   not relevant from the client's perspective here
  #
  def initialize(@data : String? = nil, @cause : Exception? = nil)
    @message = "invalid-params"
    @code = -32602
  end
end

# Exception indicating that the RPC server has suffered an error internally.
# That is, irrespective of the `Request(P)` object received by the server.
class JSONRPC::InternalError < JSONRPC::Error
  JSON.mapping(
    message: {type: String?, default: "internal-error", setter: false},
    code: {type: Int32, default: -32603, setter: false},
    data: {type: String?, nilable: true,default: nil}
  )

  # Used serverside to generate `InternalError`. Some notes:
  # - Should not be used clientside.
  # - `data` will be visible to the client - do not include information
  #   not relevant from the client's perspective here. `InternalError`
  #   should almost never include data, but it is not prohibited.
  #
  def initialize(@data : String? = nil, @cause : Exception? = nil)
    @message = "internal-error"
    @code = -32603
  end
end

# From [JSONRPC 2.0 specification](http://www.jsonrpc.org/specification):
# > Invalid JSON was received by the server. An error occurred on the server
# > while parsing the JSON text.
class JSONRPC::ParseError < JSONRPC::Error
  JSON.mapping(
    message: {type: String?, default: "parse-error", setter: false},
    code: {type: Int32, default: -32700, setter: false},
    data: {type: String?, nilable: true, default: nil, emit_null: false}
  )

  # Used serverside to generate `ParseError`. Some notes:
  # - Should not be used clientside.
  # - `data` will be visible to the client - do not include information
  #   not relevant from the client's perspective here
  #
  def initialize(@data : String? = nil, @cause : Exception? = nil)
    @message = "parse-error"
    @code = -32700
  end
end

# Copyright (C) 2007-2010 by the JSON-RPC Working Group
#
# This document and translations of it may be used to implement JSON-RPC,
# it may be copied and furnished to others, and derivative works that comment
# on or otherwise explain it or assist in its implementation may be prepared,
# copied, published and distributed, in whole or in part, without restriction
# of any kind, provided that the above copyright notice and this paragraph are
# included on all such copies and derivative works. However, this document
# itself may not bemodified in any way.