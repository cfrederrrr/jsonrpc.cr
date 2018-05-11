module JSON
  module RPC

    # `Request` object to be sent to the JSONRPC server
    #
    # `Params` can be of any type parsable by `JSON::PullParser` and buildable
    # with `JSON::Builder`
    #
    # According to
    # [https://www.jsonrpc.org/specification#request_object](JSONRPC 2.0),
    # specification the params key should be any "structured value that holds
    # the parameter values to be used during the invocation of the method"
    #
    # If the method you are invoking per `@method` is one which expects
    # positional parameters, `Params` should build to a JSON array
    # Otherwise it should build to a JSON object
    class Request(Params)

      # A `String` specifying the RPC method to be invoked.
      getter method : String

      # An `Array` or `Hash` that holds the parameter arguments.
      # - `Array` means positional arguments
      # - `Hash` means named arguments
      # - Omitting this key means no arguments.
      getter params : Params

      # An identifier established by the client. If `nil` or excluded, then
      # the client does not expect a response - this is known as a
      # "notification" according to JSON RPC 2.0 specification
      getter id : String|Int32?

      # A `String` indicating the JSONRPC version
      getter jsonrpc : String

      ::JSON.mapping(
        jsonrpc: String,
        method: String,
        params: {type: Params, nilable: true},
        id: {type: String|Int32?, nilable: true}
      )

      # Convenience overload for building `Request` without instantiating
      # a `JSON::PullParser` yourself - you can just use the incoming data
      def self.new(json : String)
        new ::JSON::PullParser.new(json)
      end

      # Create a new `Request(Params)` with direct arguments,
      # rather than with a JSON string
      def initialize(
          @method : String,
          @params : Params = nil,
          @id : String|Int32? = nil
        )
        @jsonrpc = ::JSON::RPC::RPCVERSION
      end
    end

    # `Request` object to be sent to the JSONRPC server
    #
    # The non-generic version of `Request` sends a request with no
    # parameters
    #
    # If your request should have parameters, see `Request(Params)`. 
    # This is mainly here just because writing `Request(Nil).new` is
    # awkward and ugly.
    #
    #  With `Request`, you provide the method name as a
    # `String` and an optional `id` and the rest is handled for you
    class Request

      # A `String` specifying the RPC method to be invoked.
      getter method : String

      # An identifier established by the client. If `nil` or excluded, then
      # the client does not expect a response - this is known as a
      # "notification" according to JSON RPC 2.0 specification
      getter id : String|Int32?

      # A `String` indicating the JSONRPC version
      getter jsonrpc : String

      ::JSON.mapping(
        jsonrpc: String,
        method: String,
        id: {type: String|Int32?, nilable: true}
      )

      def initialize(
          @method : String,
          @id : String|Int32? = nil
        )
        @jsonrpc = ::JSON::RPC::RPCVERSION
      end
    end

  end
end
