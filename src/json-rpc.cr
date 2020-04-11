require "json"

module JSON::RPC
  VERSION = "0.1.0"

  annotation Method
  end
end

require "./json/rpc/error"

require "./json/rpc/request"
require "./json/rpc/response"
require "./json/rpc/context"

require "./json/rpc/client"
require "./json/rpc/handler"
