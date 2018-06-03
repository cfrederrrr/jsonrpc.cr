require "spec"
require "http/server"

require "../src/jsonrpc"

JSONRPC::TEST_SERVER = HTTP::Server.new(8080) do |context|
  context.response.content_type = "application/json"
  context.response.print JSONRPC.handle(context.request.body)
end

at_exit { JSONRPC::TEST_SERVER.listen }
