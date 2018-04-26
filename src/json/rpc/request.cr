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

      alias Param = Array(Type)|Hash(String, Type)?

      ::JSON.mapping(
        jsonrpc: String,
        method: String,
        params: {
          type: Param,
          nilable: true
        },
        req_id: {
          type: String|Int32?,
          nilable: true,
          key: "id"
        }
      )

      def initialize(
          @jsonrpc : String,
          @method : String,
          @params : Param = nil,
          @req_id : String|Int32? = nil
        )
        raise InvalidRequest.new unless (
          @jsonrpc == ::JSON::RPC::VERSION &&
          @method.is_a?(String)
        )
      end

      def self.new(json : String)
        parser = JSON::PullParser.new(json)
        new(parser)
      end

    end

  end
end
