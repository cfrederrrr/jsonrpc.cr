module JSON
  module RPC

    class Request

      # A `String` specifying the RPC method to be invoked.
      #
      getter method : String

      # An `Array` or `Hash` that holds the parameter arguments.
      # - `Array` means positional arguments
      # - `Hash` means named arguments
      # - Omitting this key means no arguments.
      #
      getter params : Array(Type)|Hash(String, Type)?

      # An identifier established by the client. If `nil` or excluded, then
      # the client does not expect a response - this is known as a
      # "notification" according to JSON RPC 2.0 specification
      #
      getter id : String|Int32?

      def initialize(jsonrpc, method, params = nil, id = nil)
        raise InvalidRequest.new unless (
          jsonrpc == JSON::RPC::VERSION &&
          method.is_a?(String)
        )
        @method = method
        @params = params
        @id = id
      end

      # Parses a request from an opaque string and returns a new `Request`
      #
      def self.parse(opaque : String)
        data = JSON.parse_raw opaque
        new data["jsonrpc"], data["method"], data["params"]?, data["id"]?
      end

      # Turn the request into JSON `String`
      #
      def to_json(*args) : String
        j = {} of String => Type
        j["jsonrpc"] = JSON::RPC::VERSION
        j["method"] = @method
        j["method"] = @id unless @id.nil?
        j["params"] = @params unless @params.nil?
        j.to_json(*args)
      end

    end

  end
end
