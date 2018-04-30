module JSON
  module RPC

    class Request

      alias Params = Array(Any)|Hash(String,Any)?

      # A `String` specifying the RPC method to be invoked.
      #
      getter method : String

      # An `Array` or `Hash` that holds the parameter arguments.
      # - `Array` means positional arguments
      # - `Hash` means named arguments
      # - Omitting this key means no arguments.
      #
      getter params : Params

      # An identifier established by the client. If `nil` or excluded, then
      # the client does not expect a response - this is known as a
      # "notification" according to JSON RPC 2.0 specification
      #
      getter id : String|Int32?

      ::JSON.mapping(
        jsonrpc: String,
        method: String,
        params: {type: Params, nilable: true},
        id: {type: String|Int32?, nilable: true}
      )

      # Convenience overload for building `Request` without instantiating
      # a `JSON::PullParser` yourself - you can just use the incoming data
      def self.new(json : String)
        parser = ::JSON::PullParser.new(json)
        new(parser)
      end

      def initialize(
          @method : String,
          @params : Params = nil,
          @id : String|Int32? = nil
        )
        @jsonrpc = ::JSON::RPC::RPCVERSION
      end

    end

  end
end
