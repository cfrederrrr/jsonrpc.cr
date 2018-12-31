require "json"

require "./jsonrpc/version"
require "./jsonrpc/errors"
require "./jsonrpc/request"
require "./jsonrpc/response"
require "./jsonrpc/method"
require "./jsonrpc/handler"

module JSONRPC
  HANDLER = Handler.new

  def self.handle(json : String)
    HANDLER.handle json
  end

  def self.register(name : String, params : Array(String) | Int32? = nil, &block : JSON::Any -> _)
    HANDLER.register name, params, &block
  end
end
