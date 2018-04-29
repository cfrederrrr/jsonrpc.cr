require "./json/exceptions"
require "./json/request"
require "./json/response"

module JSON
  module RPC

    class Scenario

      getter request : Request
      getter response : Response
      getter id : String|Int32?
      getter fulfilled : Bool

      def initialize(@request : Request, @response : Response)
        @fulfilled = false

        begin
          @id = @request.id
          @response.id = @id
        rescue
          m = %<"id" either couldn't be found or was malformed>
          @response.error = InvalidRequest.new m
          @fulfilled = true
        end
      end

      def initialize()
      end

    end

  end
end
