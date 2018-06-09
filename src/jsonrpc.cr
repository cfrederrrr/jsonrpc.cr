require "json"

require "./jsonrpc/version"
require "./jsonrpc/errors"
require "./jsonrpc/request"
require "./jsonrpc/response"
require "./jsonrpc/method"
require "./jsonrpc/handler"

module JSONRPC
  HANDLER = Handler.new
  forward_missing_to HANDLER
end
