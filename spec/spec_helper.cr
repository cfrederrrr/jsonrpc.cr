require "spec"
require "../src/json-rpc"

class SubtractionHelper
  include JSON::Serializable

  getter subtrahend : Int32
  getter minuend : Int32
  def initialize(@subtrahend, @minuend)
  end
end

class AdditionHelper
  include JSON::Serializable

  getter x : Int32
  getter y : Int32
end

class JSON::RPC::SpecHandler < JSON::RPC::Handler

  def notify
  end

  @[JSON::RPC::Method("subtract")]
  def subtract(numbers : Array(Int32)) : Int32
    start = numbers.shift
    numbers.reduce(start) do |memo, number|
      memo - number
    end
  end

  @[JSON::RPC::Method("subtract")]
  def subtract(pair : SubtractionHelper) : Int32
    pair.minuend - pair.subtrahend
  end

  @[JSON::RPC::Method("add")]
  def add(pair : AdditionHelper) : Int32
    pair.x + pair.y
  end
end

class JSON::RPC::SpecClient < JSON::RPC::Client
  # Gives control of handler to SpecClient. For the purpose of tests,
  # this is fine, but it would never happen like this in a real program
  def initialize(@handler : JSON::RPC::Handler)
  end

  def submit_request(json)
    @handler.handle(json) do |context|
      printf %<Message from %s: "Handling %s">, Handler.inspect
      printf %<  Handling "%s">, context.request.method
      if context.error?
        printf %<  Error: "%s">, context.response.error
      elsif context.response.result
        printf %<  Result: "%s">, context.response.result
      end
    end
  end

  def submit_batch(json)
    json
  end

  rpcdef "subtract", params: Array(Int32), result: Int32
  rpcdef "add", params: Array(Int32), result: Int32
end

HANDLER = JSON::RPC::SpecHandler.new
CLIENT = JSON::RPC::SpecClient.new HANDLER
