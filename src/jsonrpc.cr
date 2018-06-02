require "json"

require "./jsonrpc/version"
require "./jsonrpc/errors"
require "./jsonrpc/request"
require "./jsonrpc/response"
require "./jsonrpc/method"
require "./jsonrpc/handler"

module JSONRPC

  # A String specifying the version of the JSON-RPC protocol.
  # MUST be exactly "2.0"
  #
  RPCVERSION = "2.0"

  HANDLER = Handler.new
  forward_missing_to HANDLER

end
