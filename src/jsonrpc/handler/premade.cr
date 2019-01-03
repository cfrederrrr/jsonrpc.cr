module JSONRPC::Handler::Premade
  macro list_all_methods
    @[JSONRPC::Method("list-all-methods")]
    def list_all_methods
      {% all_methods = [] of Nil %}
      {% for m in @type.methods %}
        {% if m.annotation(JSONRPC::Method) %}
          {% all_methods.push m.name.stringify %}
        {% end %}
      {% end %}
      {{all_methods}}
    end
  end
end
