require "spec"
require "http/server"

require "../src/jsonrpc"

class JSONRPC::SpecHandler < JSONRPC::Handler

  class SubtractionHelper
    JSON.mapping(subtrahend: {type: Int32, getter: true}, minuend: {type: Int32, getter: true})
  end

  def subtract(numbers : Array(Int32)) : Int32
    start = numbers.shift
    numbers.reduce(start) do |memo, number|
      memo - number
    end
  end

  def subtract(pair : SubtractionHelper) : Int32
    pair.minuend - pair.subtrahend
  end

  expose_rpc
end
