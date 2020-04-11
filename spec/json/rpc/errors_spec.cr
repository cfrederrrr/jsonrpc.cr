require "../../../spec_helper"

describe "JSON::RPC::Error" do
  it "constructs an 'invalid request' error" do
    invalid_request = JSON::RPC::Error.invalid_request "request is invalid"
    invalid_request.message.should eq "Invalid Request"
    invalid_request.code.should eq -32600
    invalid_request.data.should eq "request is invalid"
  end

  it "constructs a 'method not found' error" do
    method_not_found = JSON::RPC::Error.method_not_found "method is not found"
    method_not_found.message.should eq "Method not found"
    method_not_found.code.should eq -32601
    method_not_found.data.should eq "method is not found"
  end

  it "constructs an 'invalid params' error" do
    invalid_params = JSON::RPC::Error.invalid_params "parameters are invalid"
    invalid_params.message.should eq "Invalid params"
    invalid_params.code.should eq -32602
    invalid_params.data.should eq "parameters are invalid"
  end

  it "constructs an 'internal error' error" do
    internal_error = JSON::RPC::Error.internal_error "an internal error occurred"
    internal_error.message.should eq "Internal error"
    internal_error.code.should eq -32603
    internal_error.data.should eq "an internal error occurred"
  end

  it "constructs a 'parse error' error" do
    parse_error = JSON::RPC::Error.parse_error "error parsing the request"
    parse_error.message.should eq "Parse error"
    parse_error.code.should eq -32700
    parse_error.data.should eq "error parsing the request"
  end
end
