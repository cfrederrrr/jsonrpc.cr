# stdlib dependencies
require "json"

# local dependencies
require "./json/exceptions"

module JSON
  module RPC

    # A String specifying the version of the JSON-RPC protocol.
    # MUST be exactly "2.0"
    #
    VERSION = "2.0"

    class Scenario
      getter request : Request
      getter response : Response
      def initialize(@request, @response); end

      def invoke()
    end



  end
end
