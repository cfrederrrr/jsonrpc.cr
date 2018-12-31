require "spec"
require "http/server"

require "../src/jsonrpc"

TEST_SERVER = HTTP::Server.new(8080) do |context|
  context.response.content_type = "application/json"
  context.response.print JSONRPC.handle(context.request.body.to_s)
end

TEST_SERVER.listen
