# Client is, and can only be a wrapper for your favorite TCP/HTTP/S client
# It provides some convenience methods for handling method invocations, i.e.
# `JSON::RPC::Request` and `JSON::RPC::Response` but it is otherwise perfectly dumb
#
# This enables you to use whatever transport client you like, without having to
# deal much with the JSON RPC logic. However, it does mean that you will have to handle
# the transport logic yourself.
#
abstract class JSON::RPC::Client

  # `submit_request` method should take one argument (serialized JSON) and should return
  # `String` (which will be serialized JSON as well)
  #
  # This method should handle the actual conveyance of data to the server, but should
  # _never_ attempt to parse it. That will be handled by the `#invoke_method` methods
  abstract def submit_request(json : String) : String
  abstract def submit_batch(json : String) : String

  macro rpcdef(name, params, result)
    {% method_name = name.underscore.tr("- ", "_") %}
    def {{method_name.id}}(params : {{params}}) : JSON::RPC::Context({{params}}, {{result}})
      request = JSON::RPC::Request({{params}}).new("{{name.id}}", params)
      %response = submit_request(request.to_json)
      response = JSON::RPC::Response({{result}}).new(%response)
      JSON::RPC::Context({{params}}, {{result}}).new(request, response)
    end
  end

  macro notify(name, params)
    def {{name.id}}(%params : {{params}}) : Bool
      request = JSON::RPC::Request({{params}}).new("{{name.id}}", %params)
      context = JSON::RPC::Context({{params}}, Nil).new(request, nil)
      submit_request(request.to_json)
      return true
    end
  end
end
