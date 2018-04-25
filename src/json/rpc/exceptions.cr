module JSON
  module RPC

    class InternalError < Exception
      getter data : String?
      getter code : Int32

      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "internal-error"
        @code = -32603
      end

      def to_json(json : JSON::Builder)
        json.object do
          json.field("code", @code)
          json.field("message", @message)
          json.field("data", @data) unless @data.nil?
        end
      end
    end

    class ParseError < InternalError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "parse-error"
        @code = -32700
      end
    end

    class InvalidRequest < InternalError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "invalid-request"
        @code = -32600
      end
    end

    class MethodNotFound < InternalError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "method-not-found"
        @code = -32601
      end
    end

    class InvalidParams < InternalError
      def initialize(@data : String? = nil, @cause : Exception? = nil)
        @message = "invalid-params"
        @code = -32602
      end
    end

  end
end
