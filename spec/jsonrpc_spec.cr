require "./spec_helper"

JSONRPC.register_method "subtract", -1 do |params|
  total = params.shift
  while params.any?
    total = total - params.shift
  end
  total
end

#
# examples taken from http://www.jsonrpc.org/specification#examples
#
describe "JSONRPC" do
  it "handles an rpc call with positional parameters" do
    # --> req = %({"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1})
    # <-- {"jsonrpc": "2.0", "result": 19, "id": 1}
    #
    # --> req = %({"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2})
    # <-- {"jsonrpc":"2.0","result":-19,"id":2}
  end

  it "handles an rpc call with named parameters" do
    # --> req = %({"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3})
    # <-- {"jsonrpc": "2.0", "result": 19, "id": 3}
    #
    # --> req = %({"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 4})
    # <-- {"jsonrpc":"2.0","result":19,"id":4}
  end

  it "handles a Notification" do
    # --> req = %({"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]})
    # --> req = %({"jsonrpc":"2.0","method":"foobar"})
  end

  it "handles an rpc call of non-existent method" do
    # --> req = %({"jsonrpc": "2.0", "method": "foobar", "id": "1"})
    # <-- {"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"},"id":"1"}
  end

  it "handles an rpc call with invalid JSON" do
    # --> req = %({"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz])
    # <-- {"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}
  end

  it "handles an rpc call with invalid Request object" do
    # --> req = %({"jsonrpc": "2.0", "method": 1, "params": "bar"})
    # <-- {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
  end

  it "handles an rpc call Batch, invalid JSON" do
    # --> req = %([
    #       {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
    #       {"jsonrpc": "2.0", "method"
    #     ])
    # <-- {"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}
  end

  it "handles an rpc call with an empty Array" do
    # --> req = %([])
    # <-- {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
  end

  it "handles an rpc call with an invalid Batch (but not empty)" do
    # --> req = %([1])
    # <-- [{"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}]
  end

  it "handles an rpc call with invalid Batch"
    #
    # --> req = %([1,2,3])
    # <-- [
    #       {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null},
    #       {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null},
    #       {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
    #     ]
    # resp = [
    #   {
    #     "jsonrpc" => "2.0",
    #     "error" => {
    #       "code" => -32600,
    #       "message" => "Invalid Request"
    #     },
    #     "id": nil
    #   },
    #   {
    #     "jsonrpc" => "2.0",
    #     "error" => {
    #       "code" => -32600,
    #       "message" => "Invalid Request"
    #     },
    #     "id" => null
    #   },
    #   {
    #     "jsonrpc" => "2.0",
    #     "error" => {
    #       "code" => -32600,
    #       "message" => "Invalid Request"
    #     },
    #     "id" => null
    #   }
    # ].to_json
  end

  it "handles an rpc call Batch" do
    #
    # --> req = %([
    #         {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
    #         {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
    #         {"jsonrpc": "2.0", "method": "subtract", "params": [42,23], "id": "2"},
    #         {"foo": "boo"},
    #         {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
    #         {"jsonrpc": "2.0", "method": "get_data", "id": "9"}
    #     ])
    # <-- [
    #         {"jsonrpc": "2.0", "result": 7, "id": "1"},
    #         {"jsonrpc": "2.0", "result": 19, "id": "2"},
    #         {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
    #         {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "5"},
    #         {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
    #     ]
  end

  it "handles an rpc call Batch (all notifications)" do
    #
    # --> req = %([
    #         {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
    #         {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
    #     ])
    # <-- //Nothing is returned for all notification batches
  end
end
