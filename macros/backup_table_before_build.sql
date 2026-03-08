{% macro backup_table_before_build() %}
    {# Получаем ссылку на текущую таблицу #}
    {% 
        set old_relation = adapter.get_relation(
        database=this.database,
        schema=this.schema,
        identifier=this.identifier
    )%}

    {# Формируем timestamp в нужном формате YYYY_MM_DD_HHMMSS #}
    {% set backup_suffix = run_started_at.strftime('%Y_%m_%d_%H%M%S') %}
    {% set backup_identifier = this.identifier ~ '_backup_' ~ backup_suffix %}

    {# Переименовываем только если таблица существует #}
    {% if old_relation is not none %}
        {% 
            set backup_relation = api.Relation.create(
            database=this.database,
            schema=this.schema,
            identifier=backup_identifier
        )%}    

        {% do log("Renaming " ~ old_relation ~ " to " ~ backup_relation, info=True) %}
        {% do adapter.rename_relation(old_relation, backup_relation)%}

    {% else %}
        {{ log("Table does not exist yet, skipping backup", info=true) }}
    {% endif %}
{% endmacro %}

        
