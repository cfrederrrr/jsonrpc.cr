require "../spec_helper"

describe "JSONRPC::Handler" do
  describe "#register" do
    it "registers a method" do
      JSONRPC.register "no-op" { nil }
      JSONRPC.method?("no-op").should be_a(JSONRPC::Method)
    end

    it "handles a request" do
      response = JSONRPC.handle %<{"jsonrpc":"2.0","method":"no-op","id":9001}>
    end
  end
end
