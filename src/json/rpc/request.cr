module JSON
  module RPC

    class Request

      # A `String` specifying the RPC method to be invoked.
      #
      getter :method

      # An `Array` or `Hash` that holds the parameter arguments.
      # - `Array` means positional arguments
      # - `Hash` means named arguments
      # - Omitting this key means no arguments.
      #
      getter :params

      # An identifier established by the client. If `nil` or excluded, then
      # the client does not expect a response - this is known as a
      # "notification" according to JSON RPC 2.0 specification
      #
      getter :req_id

      alias Params = Array(Any)|Hash(String,Any)?

      ::JSON.mapping(
        jsonrpc: String,
        method: String,
        params: {
          type: Params,
          nilable: true
        },
        id: {
          type: String|Int32?,
          nilable: true
        }
      )

      def initialize(
          @jsonrpc : String,
          @method : String,
          @params : Params = nil,
          @id : String|Int32? = nil
        )
        raise InvalidRequest.new unless (
          @jsonrpc == ::JSON::RPC::VERSION &&
          @method.is_a?(String)
        )
      end

      # Convenience overload for building {Request} without instantiating
      # a {JSON::PullParser} yourself - you can just use the incoming data
      def self.new(json : String)
        parser = JSON::PullParser.new(json)
        new(parser)
      end

    end

  end
end
