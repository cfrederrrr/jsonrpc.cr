# Client is, and can only be a wrapper for your favorite TCP/HTTP/S client
# It provides some convenience methods for handling method invocations, i.e.
# `JSONRPC::Request` and `JSONRPC::Response` but it is otherwise perfectly dumb
#
# This enables you to use whatever transport client you like, without having to
# deal much with the JSON RPC logic. However, it does mean that you will have to handle
# the transport logic yourself.
#
abstract class JSONRPC::Client

  # `submit_request` method should take one argument (serialized JSON) and should return
  # `String` (which will be serialized JSON as well)
  #
  # This method should handle the actual conveyance of data to the server, but should
  # _never_ attempt to parse it. That will be handled by the `#invoke_method` methods
  abstract def submit_request(json : String) : String
  abstract def submit_batch(json : String) : String

  macro rpc_method(name, mname, params, result)
    def {{name.id}}(%params : {{params}}) : JSONRPC::Context({{params}}, {{result}})
      %request = JSONRPC::Request({{params}}).new({{mname}}, %params)
      JSONRPC::Context({{params}}, {{result}}).new(%request) do |request|
        JSONRPC::Response({{result}}).from_json(submit_rpc(request.to_json))
      end
    end
  end

  macro rpc_notification(name, params)
    def {{name.id}}(%params : {{params}}) : Bool
      JSONRPC::Context({{params}}, {{result}}).new(%params) do |request|
        JSONRPC::Response({{result}}).from_json(submit_rpc(request.to_json))
      end

      return true
    end
  end
end
