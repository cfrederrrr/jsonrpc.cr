# Client is, and can only be a wrapper for your favorite TCP/HTTP/S client
# It provides some convenience methods for handling method invocations, i.e.
# `JSON::RPC::Request` and `JSON::RPC::Response` but it is otherwise perfectly dumb
#
# This enables you to use whatever transport client you like, without having to
# deal much with the JSON RPC logic. However, it does mean that you will have to handle
# the transport logic yourself.
#
abstract class JSON::RPC::Client
  alias SID = String | Int32 | Nil


  # `submit_request` method should take one argument (serialized JSON) and should return
  # `String` (which will be serialized JSON as well)
  #
  # This method should handle the actual conveyance of data to and from the server, but should
  # _not_ attempt to parse it. That will be handled by the methods defined in the `rpc`
  # macro instead.
  abstract private def submit_request(json : IO|String) : IO|String
  abstract private def submit_batch(json : IO|String) : IO|String
  abstract private def genid : SID

  def log(ctx : Context)
  end

  macro rpc(defines, *, takes=nil, returns=nil, calls=false, notifies=false)
    {% raise "cannot define 'calls' and 'notifies' in the same rpc" if notifies && calls %}
    {% raise "cannot define both 'notifies' and 'returns' in the same rpc" if notifies && returns %}

    {% begin %}
      {% defsig = "#{defines.id}(" %}
      {% req = "Request(#{takes.id}).new(#{calls.id.stringify}, " %}

      {% if takes.nil? %} # do nothing
        {% req = "Request(Nil).new(#{calls.id.stringify}, " %}
      {% elsif takes.is_a?(TupleLiteral) %}
        {% req += "{" %}
        {% for t, i in takes %}
          {% defsig += "arg#{i.id} : #{t.id}," %}
          {% req += "arg#{i.id}," %}
        {% end %}
        {% req += "}"%}
      {% elsif takes.is_a?(NamedTupleLiteral) %}
        {% req += "{" %}
        {% for a, t in takes %}
          {% defsig += "#{a.id} : #{t.id}," %}
          {% req += "#{a.id}," %}
        {% end %}
        {% req += "}" %}
      {% elsif takes.is_a?(TypeNode) %}
        {% defsig += "params : #{takes.id}" %}
        {% req += "params" %}
      {% else %}
        {% raise "invalid 'takes' value - must be singular TypeNode or Tuple of TypeNode(s)" %}
      {% end %}

      {% if calls %}
        {% req += "id: self.genid()" %}
      {% end %}
      {% req += ")" %}
      {% defsig += ")" %}

      {% if calls %}
        {% defsig += " : Context(" + takes.stringify + ", " + returns.stringify + ")" %}
      {% end %}

      {% for yielding in {true, false} %}
    def {{defsig.id}}
      request = {{req.id}}

      {% if calls %}
        %response = submit_request(request.to_json)
        response = Response({{returns}}).new(%response)
        context = Context({{takes}}, {{returns}}).new(request, response)
        {% if yielding %} yield context {% end %}
        self.log(context)
        return response.result ? response.result : response.error
      {% else %}
        submit_request(request.to_json)
        context = Context({{takes}}, Nil).new(request, nil)
        self.log(context)
        return
      {% end %}

    end
      {% end %}
    {% end %}
  end
end
