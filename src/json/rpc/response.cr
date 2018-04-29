module JSON
  module RPC

    class Response

      # JSON RPC version indicator.
      # Must be exactly `"2.0"` according to spec.
      getter jsonrpc : String

      # This key is included if the method ran successfully. It is excluded if
      # there was an error of any kind.
      getter result : Any

      # This key is included if the method did not run successfully. It is
      # excluded if the method was enacted successfully.
      getter error : Error?

      # Response has to include the same `@id` as its corresponding `Request`
      getter id : String|Int32?

      ::JSON.mapping(
        jsonrpc: {type: String, default: ::JSON::RPC::VERSION},
        result: {type: Any, nilable: true},
        error: {type: Error, nilable: true},
        id: {type: String|Int32?, nilable: true, emit_null: true}
      )

      # Convenience overload for building `Request` without instantiating
      # a `JSON::PullParser` yourself - you can just use the incoming data
      #
      def self.new(json : String)
        parser = ::JSON::PullParser.new(json)
        new(parser)
      end

      def initialize(
          @result : Any,
          @id : String|Int32? = nil
        )
        @jsonrpc = JSON::RPC::VERSION
      end

      def initialize(
          @error : Error,
          @id : String|Int32? = nil
        )
        @jsonrpc = ::JSON::RPC::VERSION
      end

      def initialize(@id : String|Int32? = nil)
        @result = nil
        @error = nil
      end

      def result=(res : Any)
        if @result.nil? && @error.nil?
          @result = res
        else
          @error = InternalError.new
        end
      end

      def error=(err : Error)
        if @result.nil? && @error.nil?
          @error = err
        else
          @error = InternalError.new
        end
      end

    end

  end
end
