require "./json/exceptions"
require "./json/request"
require "./json/response"

module JSON
  module RPC

    class Scenario

      getter request : Request
      getter response : Response

      def initialize(@request : Request, @response : Response)
      end

      def invoke
        begin

        rescue err : JSON::RPC::Error
          @response = Response.new()
        end
      end

    end

  end
end
