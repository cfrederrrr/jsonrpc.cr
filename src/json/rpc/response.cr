module JSON
  module RPC

    class Response

      # This key is included if the method ran successfully. It is excluded if
      # there was an error of any kind.
      getter result : Any

      # This key is included if the method did not run successfully. It is
      # excluded if there was no error of any kind.
      getter error : Error?

      # Response has to include the same `@id` as its corresponding `Request`
      getter id : String|Int32?

      ::JSON.mapping(
        jsonrpc: String,
        result: {
          type: Any,
          nilable: true
        },
        error: {
          type: Error,
          nilable: true
        },
        id: {
          type: String|Int32?,
          nilable: true,
          emite_null: true
        }
      )

      def initialize(
          @jsonrpc : String,
          @error : Error,
          @id : String|Int32? = nil
        )
      end

      def initialize(
          @jsonrpc : String,
          @result : Any,
          @id : String|Int32? = nil
        )
      end

      # This is basically the ultimate method to use when sending the
      # response back to the client. It will never raise an error, ensuring
      # the contract between server and client. It does this while still
      # allowing the server to raise and capture errors for logging
      #
      def to_json(builder : JSON::Builder)
        builder.object do
          builder.field("jsonrpc", JSON::RPC::VERSION)
          builder.field("id", @id) unless @id.nil?

          unless @error.nil? || @result.nil?
            builder.field("error", InternalError.new.to_json builder)
            return builder.end_object
          end

          case
          when @result
            builder.field("result", @result.to_json(builder))
          when @error
            builder.field("error", @error.to_json(builder))
          else
            message = "response did not have a result or error"
            builder.field("error", InternalError.new(message).to_json(builder))
          end
        end
      end

    end

  end
end
