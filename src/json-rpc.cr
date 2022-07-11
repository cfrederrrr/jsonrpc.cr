require "json"

module JSON::RPC
  VERSION = "0.1.0"

  annotation Method
  end
end

class JSON::RPC::Version
  MAJOR, MINOR, PATCH = 0, 1, 0

  def to_s(io : IO) : Nil
    io << MAJOR
    io << '.'
    io << MINOR
    io << '.'
    io << PATCH
  end

  def to_i : Int32
    MAJOR * 1_000_000 +
    MINOR * 1_000 +
    PATCH
  end
end

require "./json/rpc/error"

require "./json/rpc/request"
require "./json/rpc/response"
require "./json/rpc/context"

require "./json/rpc/client"
require "./json/rpc/handler"
