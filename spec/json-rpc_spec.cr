require "./spec_helper"

#
# examples taken from http://www.jsonrpc.org/specification#examples
#
describe JSON::RPC do
  it "handles an rpc call with positional parameters" do
    # --> {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}
    # <-- {"jsonrpc": "2.0", "result": 19, "id": 1}
    result = SpecClient.subtract [42, 23]
    result.should eq(19)
    SpecClient.logs.last.request.id.should eq(SpecHandler.logs.last.response.id)

    # --> {"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}
    # <-- {"jsonrpc": "2.0", "result": -19, "id": 2}
    result = SpecClient.subtract [23, 42]
    result.should eq(-19)
    SpecClient.logs.last.request.id.should eq(SpecHandler.logs.last.response.id)
  end

  it "handles an rpc call with named parameters" do
    # --> {"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}
    # <-- {"jsonrpc": "2.0", "result": 19, "id": 3}
    result = SpecClient.subtract SubtractionHelper.new(subtrahend: 42, minuend: 23)
    result.should eq(19)
    SpecClient.logs.last.request.id.should eq(SpecHandler.logs.last.response.id)

    # --> {"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 4}
    # <-- {"jsonrpc": "2.0", "result": 19, "id": 4}
    result = SpecClient.subtract SubtractionHelper.new(minuend: 23, subtrahend: 42)
    result.should eq(-19)
    SpecClient.logs.last.request.id.should eq(SpecHandler.logs.last.response.id)
  end

  it "handles a Notification" do
    # --> {"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}
    SpecClient.update([1,2,3,4,5])
    SpecHandler.state.should eq([0,1,2,3,4,5])

    # --> {"jsonrpc": "2.0", "method": "foobar"}
    SpecClient.foobar
  end

  it "handles an rpc call of non-existent method" do
    # --> {"jsonrpc": "2.0", "method": "foobar", "id": "1"}
    # <-- {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"}
    error = SpecClient.foobar
    error.should.be_a JSON::RPC::Error
    error.message.should eq("Method not found")
    error.code.should eq(-32601)
    SpecClient.logs.last.request.id.should eq(SpecHandler.logs.last.response.id)
  end

  it "handles an rpc call with invalid JSON" do
    # --> {"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]
    # <-- {"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}
    error = SpecClient.invalid_json
    error.should.be_a JSON::RPC::Error
    error.message.should eq("Parse error")
    error.code.should eq(-32700)
  end

  it "handles an rpc call with invalid Request object" do
    # --> {"jsonrpc": "2.0", "method": 1, "params": "bar"}
    # <-- {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    error = SpecClient.invalid_request
    error.should.be_a JSON::RPC::Error
    error.message.should eq("Invalid Request")
    error.code.should eq(-32600)
  end

  it "handles an rpc call Batch, invalid JSON" do
    # --> [
    #   {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
    #   {"jsonrpc": "2.0", "method"
    # ]
    # <-- {"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}
  end

  it "handles an rpc call with an empty Array" do
    # --> []
    # <-- {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
  end

  it "handles an rpc call with an invalid Batch (but not empty)" do
    # --> [1]
    # <-- [
    #   {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    # ]
  end

  it "handles an rpc call with invalid Batch" do
    # --> [1,2,3]
    # <-- [
    #   {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
    #   {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
    #   {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    # ]
  end

  it "handles an rpc call Batch" do
    # --> [
    #         {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
    #         {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
    #         {"jsonrpc": "2.0", "method": "subtract", "params": [42,23], "id": "2"},
    #         {"foo": "boo"},
    #         {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
    #         {"jsonrpc": "2.0", "method": "get_data", "id": "9"}
    #     ]
    # <-- [
    #         {"jsonrpc": "2.0", "result": 7, "id": "1"},
    #         {"jsonrpc": "2.0", "result": 19, "id": "2"},
    #         {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
    #         {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "5"},
    #         {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
    #     ]
  end

  it "handles an rpc call Batch (all notifications)" do
    # --> [
    #         {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
    #         {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
    #     ]
    # <-- //Nothing is returned for all notification batches
  end
end
