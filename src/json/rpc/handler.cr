module JSON
  module RPC

    module Handler

      # `method` tells the `Handler` how to access the method it refers to
      macro method(name, params = nil, form = nil)
        def {{name.id}}(request : ::JSON::RPC::Request)
          {{name.id}}(
          {% if form.stringify == "named" || form == nil %}
            {% for a, t in params %}

            {{a.id}}: request.params
              .as(Hash(String,::Union({{*params.values}}))).fetch("{{a.id}}")
              .as({{t.id}}),

            {% end %}
          {% elsif form.stringify == "positional" %}
            {% i = 0 %}
            {% for a, t in params %}

            {{a.id}}: request.params
              .as(Array(::Union({{*params.values}}))).at({{i}})
              .as({{t.id}}),

            {% i = i + 1 %}
            {% end %}
          {% end %}
          )
        end
      end

    end

  end
end
