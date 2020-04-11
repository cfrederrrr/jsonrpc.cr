module JSON::RPC::Handler::Premade
  macro list_all_methods
    @[JSON::RPC::Method("list-all-methods")]
    def list_all_methods
      {% all_methods = [] of Nil %}
      {% for m in @type.methods %}
        {% if m.annotation(JSON::RPC::Method) %}
          {% all_methods.push m.name.stringify %}
        {% end %}
      {% end %}
      {{all_methods}}
    end
  end
end
