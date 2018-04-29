require "../../spec_helper"

describe "JSON::RPC::Error" do
end

describe "JSON::RPC::InvalidRequest" do
  data = "internal error occurred!"
  example = JSON::RPC::InvalidRequest.new data

  describe "#code" do
    it "should always be -32600" do
      example.code.should eq(-32600)
    end
  end

  describe "#message" do
    it "should always be 'invalid-request'" do
      example.message.should eq("invalid-request")
    end
  end

  describe "#data" do
    it "should match param provided in .new(data : String?)" do
      describe "#{data}" do
        example.data.should eq(data)
      end

      describe "nil" do
        JSON::RPC::InvalidRequest.new.data.should be_nil
      end
    end
  end

  describe ".from_json" do
    it "pulls from json" do
      _example = JSON::RPC::InvalidRequest.from_json(example.to_json)
      example.code.should eq(_example.code)
      example.message.should eq(_example.message)
      example.data.should eq(_example.data)
    end
  end
end

describe "JSON::RPC::InvalidRequest" do
  example = JSON::RPC::MethodNotFound.new "method is not found!"

  describe "any instance" do
    it "code should always be -32601" do
      example.code.should eq(-32601)
    end

    it "message should always be 'method-not-found'" do
      example.message.should eq("method-not-found")
    end

    it "data should be 'method is not found!'" do
      example.data.should eq("method is not found!")
    end
  end

  describe ".from_json" do
    it "pulls from json" do
      _example = JSON::RPC::InvalidRequest.from_json(example.to_json)
      example.code.should eq(_example.code)
      example.message.should eq(_example.message)
      example.data.should eq(_example.data)
    end
  end
end
