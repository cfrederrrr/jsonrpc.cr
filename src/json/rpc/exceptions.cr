module JSON
  module RPC

    class InternalError < Exception
      CODE = -32603
      MESSAGE = "internal-error"

      getter data : String?
      getter code : Int32

      def initialize(message : String, @code : Int32, @data : String? = nil)
        super(message)
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
      CODE = -32700
      MESSAGE = "parse-error"

      def initialize(data : String? = nil)
        super(MESSAGE, CODE, data)
      end
    end

    class InvalidRequest < InternalError
      CODE = -32600
      MESSAGE = "invalid-request"

      def initialize(data : String? = nil)
        super(MESSAGE, CODE, data)
      end
    end

    class MethodNotFound < InternalError
      CODE = -32601
      MESSAGE = "method-not-found"

      def initialize(data : String? = nil)
        super(MESSAGE, CODE, data)
      end
    end

    class InvalidParams < InternalError
      CODE = -32602
      MESSAGE = "invalid-params"

      def initialize(data : String? = nil)
        super(MESSAGE, CODE, data)
      end
    end

  end
end
