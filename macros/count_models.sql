{% macro count_models() %}
{# Считаем количество моделей, seed и snapshot в проекте  #}
{% if execute %} {# Выполняем только если dbt в режиме execute #}

{# Создаем пустой список для моделей, seed и snapshot #}
{% set model = [] %} 
{% set seed = [] %}
{% set snapshot = [] %}
    
    {% for node in graph.nodes.values() -%} {# Получем ноды из graph #}
        {%- if node.resource_type == 'model' and 'elementary' not in node.tags-%}
            {% do model.append(node.name) %}

        {%-elif node.resource_type == 'seed'-%}
            {% do seed.append(node.name) %}

        {%-elif node.resource_type == 'snapshot'-%}
            {% do  snapshot.append(node.name) %}

        {% endif %}

    {% endfor %}

    {# Выводим количество моделей, seed и snapshot в логи #}
    {% do log("\nВсего в проекте:" 
        ~ "\n- " ~ model | length ~ " моделей"
        ~ "\n- " ~ seed | length ~ " seed"
        ~ "\n- " ~ snapshot | length ~ " snapshot"
    )%}

{% endif %}
{% endmacro %}