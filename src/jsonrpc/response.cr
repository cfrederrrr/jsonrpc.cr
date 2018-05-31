require "json"

module JSONRPC::Response(R)

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
  getter error : Error?

  # Response has to include the same `@id` as its corresponding `Request`
  getter id : String|Int32?

  JSON.mapping(
    jsonrpc: {type: String, default: JSONRPC::RPCVERSION},
    result: {type: R?, nilable: true, emit_null: false},
    error: {type: Error?, nilable: true, emit_null: false},
    id: {type: String|Int32?, nilable: true, emit_null: true}
  )

  def initialize(
      @result : R,
      @id : String|Int32? = nil
    )
    @error = nil
    @jsonrpc = JSONRPC::RPCVERSION
  end

  def initialize(
      @error : Error,
      @id : String|Int32? = nil
    )
    @result = nil
    @jsonrpc = JSONRPC::RPCVERSION
  end

  def initialize(@id : String|Int32? = nil)
    @result = nil
    @error = nil
    @jsonrpc = JSONRPC::RPCVERSION
  end

end
