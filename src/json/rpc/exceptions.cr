module JSON
  module RPC

    class GenericError < Exception

      getter data : String?

      def to_json(json : JSON::Builder)
        json.object do
          json.field("code", @code)
          json.field("message", @message)
          json.field("data", @data) unless @data.nil?
        end
      end
    end

    class InvalidRequest < GenericError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "invalid-request"
        @code = -32600
      end
    end

    class MethodNotFound < GenericError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "method-not-found"
        @code = -32601
      end
    end

    class InvalidParams < GenericError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "invalid-params"
        @code = -32602
      end
    end

    class InternalError < GenericError
      getter data : String?
      getter code : Int32

      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "internal-error"
        @code = -32603
      end
    end

    class ParseError < GenericError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "parse-error"
        @code = -32700
      end
    end

  end
end
