require "json"

module JSON
  module RPC

    # Virtual error type so child classes can be handled the
    # in the same way
    #
    class Error; end

    class InvalidRequest < Error
      ::JSON.mapping(
        message: {type: String?, default: "invalid-request", setter: false},
        code: {type: Int32, default: -32600, setter: false},
        data: {type: String?, nilable: true, default: nil}
      )

      # Used serverside to generate `InvalidRequest`.
      # Should not be used clientside.
      #
      def initialize(@data : String? = nil)
        @message = "invalid-request"
        @code = -32600
      end
    end

    class MethodNotFound < Error
      ::JSON.mapping(
        message: {type: String?, default: "method-not-found", setter: false},
        code: {type: Int32, default: -32601, setter: false},
        data: {type: String?, nilable: true, default: nil}
      )

      # Used serverside to generate `MethodNotFound`.
      # Should not be used clientside.
      #
      def initialize(@data : String? = nil)
        @message = "method-not-found"
        @code = -32601
      end
    end

    class InvalidParams < Error
      ::JSON.mapping(
        message: {type: String?, default: "invalid-params", setter: false},
        code: {type: Int32, default: -32602, setter: false},
        data: {type: String?, nilable: true, default: nil}
      )

      # Used serverside to generate `InvalidParams`.
      # Should not be used clientside.
      #
      def initialize(@data : String? = nil)
        @message = "invalid-params"
        @code = -32602
      end
    end

    class InternalError < Error
      ::JSON.mapping(
        message: {type: String?, default: "internal-error", setter: false},
        code: {type: Int32, default: -32603, setter: false},
        data: {type: String?, nilable: true,default: nil}
      )

      # Used serverside to generate `InternalError`.
      # Should not be used clientside.
      #
      def initialize(@data : String? = nil)
        @message = "internal-error"
        @code = -32603
      end
    end

    class ParseError < Error
      ::JSON.mapping(
        message: {type: String?, default: "parse-error", setter: false},
        code: {type: Int32, default: -32700, setter: false},
        data: {type: String?, nilable: true, default: nil}
      )

      # Used serverside to generate `ParseError`.
      # Should not be used clientside.
      #
      def initialize(@data : String? = nil)
        @message = "parse-error"
        @code = -32700
      end
    end

  end
end
