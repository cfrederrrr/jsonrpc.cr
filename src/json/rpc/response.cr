module JSON
  module RPC

    class Response

      # This key is included if the method ran successfully. It is excluded if
      # there was an error of any kind.
      getter result : Type

      # This key is included if the method did not run successfully. It is
      # excluded if there was no error of any kind.
      getter error : GenericError?

      # Response has to include the same `@id` as its corresponding `Request`
      getter id : String|Int32?


      ::JSON.mapping(
        jsonrpc: String,
        result: Type,
        error: {
          type: GenericError?,
          nilable: true
        },
        res_id: {
          type: String|Int32?,
          nilable: true,
          key: "id"
        }
      )

      # ```
      # Response.new 12345 do |response|
      #   begin
      #     response.result =  enact_rpc
      #   rescue
      #     response.error =  "something went wrong"
      #   end
      # end
      # ```
      #
      # def initialize()
      #   begin
      #     @result = yield
      #   rescue ParseException
      #     @error = JSON::RPC::ParseError.new
      #   rescue Exception
      #     @error = JSON::RPC::InternalError.new
      #   rescue err : JSON::RPC::RPCError
      #     @error = err
      #   end
      # end

      def initialize(
        @result : Type,
        @error :
      )

      # Parse a response from an opaque string
      #
      def self.parse(opaque : String)
        data = JSON.parse_raw opaque

        raise "response #{data} has neither `result' nor `error' key" unless
          data.has_key?("result") || data.has_key?("error")

        raise "response #{data} has both `result' and `error' keys" if
          data.has_key?("result") && data.has_key?("error")

        new data["jsonrpc"], data["id"]?, data["result"]?, data["error"]?
      end

      def initialize(@id, res = nil, err = nil)
        raise "cannot contain both result and error" unless (res && err) == nil
        @result = res
        @error = err
      end

      # Set the `result` key if the result was not present at the time of
      # instantiation. This method will error if `@result` or `@error` are
      # already set.
      #
      def result=(res)
        raise "result already set" if @result
        raise "#{self} already has `error' key" if @error
        @result = res
      end

      #
      # Set the `error` key, if the error was not present at the time of
      # instantiation. This method will error if `@error` or `@result` are
      # already set.
      #
      def error=(err)
        raise "error already set" if @error
        raise "#{self} already has `result' key" if @result
        @error = err
      end

      # This is basically the ultimate method to use when sending the
      # response back to the client. It will never raise an error, ensuring
      # the contract between server and client. It does this while still
      # allowing the server to raise and capture errors for logging
      #
      def to_json(json : JSON::Builder)
        json.object do
          json.field("jsonrpc", JSON::RPC::VERSION)
          json.field("id", @id) unless @id.nil?

          if @error && @result
            json.field("error", InternalError.new.to_json json)
            return json.end_object
          end

          case
          when @result
            json.field("result", @result.to_json(json))
          when @error
            json.field("error", @error.to_json(json))
          else
            message = "response did not have a result or error"
            json.field("error", InternalError.new(message).to_json(json))
          end
        end
      end

    end

  end
end
