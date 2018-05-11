require "./json/exceptions"
require "./json/request"
require "./json/response"

module JSON
  module RPC

    class Scenario(Params, Result)

      # The request object of the scenario. Cannot be altered after
      # initialization
      getter request : Request?

      # The response object of the scenario. Can be nil, and can be altered
      # after initialization.
      getter response : Response?

      def response=(res : Response)
        if @wants_response
          @response = res
          @fulfilled = true
        else
          raise %<response given for notification request "#{@id}">
        end
      end

      getter id : String|Int32?

      # Clientside implementation
      def initialize(@request : Request)
        @id = @request.id
        @wants_response = !!@id
        @response = nil
      end

      # Server implementation
      def initialize(req_str : String, &block)
        begin
          @request = Request.new(req_str)
          @id = @request.id
          @wants_response = !!@id
        rescue ::JSON::ParseError
          @request, @id, @wants_response = nil, nil, false
          @response = Response.new(::JSON::RPC::ParseError.new)
          return
        end

        @response = Response.new(@id)

        begin
          @response.result = yield @request.params
        rescue
          @response.error = InternalError.new
        end
      end
    end

  end
end
