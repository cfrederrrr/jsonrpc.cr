require "json"

require "./jsonrpc/*"

module JSONRPC

  # A String specifying the version of the JSON-RPC protocol.
  # MUST be exactly "2.0"
  #
  RPCVERSION = "2.0"

  HANDLER = Handler.new
  forward_missing_to HANDLER

end
