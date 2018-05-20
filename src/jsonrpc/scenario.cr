require "./request"
require "./response"

module JSONRPC
  class Scenario(Params, Result)

    def request
      @request
    end

    def response
      @response
    end

    def response=(res : Response(Result))
      if @wants_response
        @response = res
        @fulfilled = true
      else
        raise %<response given for notification request "#{@id}">
      end
    end

    getter id : String|Int32?

    # Clientside implementation
    def initialize(@request : Request|Request(Params))
      @id = @request.id
      @wants_response = !!@id
      @response = nil
    end

    # Server implementation
    def initialize(req_str : String, &block : Params -> Result)
      begin
        @request = Request.new(req_str)
        @id = @request.id
        @wants_response = !!@id
      rescue JSON::ParseError
        @request, @id, @wants_response = nil, nil, false
        @response = Response.new(JSONRPC::ParseError.new)
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
