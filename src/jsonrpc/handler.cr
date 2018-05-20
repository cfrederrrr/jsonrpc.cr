require "json"

require "./request"
require "./response"

module JSONRPC

  class Handler

    def methods
      @methods ||= {} of String => Scenario -> _
    end

    def method(name : String, &block : Scenario ->)
      methods[name] = ->(scenario : Scenario) do

      end
    end

    macro method(name, param_type, result_type, &block)
      %mthd = {} of String => Scenario({{param_type}}, {{result_type}})
      @@methods ||= %mthd
      @@methods = @@methods.merge %mthd
    end

  end

end
