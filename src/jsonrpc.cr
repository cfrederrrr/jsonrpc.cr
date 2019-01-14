require "json"

module JSONRPC
  VERSION = "0.1.0"

  annotation Method
  end
end

require "./jsonrpc/error"
require "./jsonrpc/request"
require "./jsonrpc/response"
require "./jsonrpc/context"
