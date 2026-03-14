{# 
2 (уровень 2/3) Написать макрос безопасного запроса данных из таблицы. 

Под безопасностью подразумевается, что сначала происходит проверка существования таблицы, название которой передано в макрос. 
Если таблица существует, то макрос возвращает код SQL запроса, возвращающего  все строки и столбцы из нее:

SELECT * FROM [название таблицы]

Если таблица не существует, то макрос возвращает запрос:

SELECT NULL

Название макроса - safe_select.

На вход принимает один параметр под названием table_name с названием таблицы, из которой нужно запросить все колонки и все строки.

#}

{# {% macro safe_select(table_name) %}
    {{ log("Checking: DB=" ~ target.database ~ " Schema=" ~ target.schema ~ " Table=" ~ table_name, info=true) }}
    {% set model_relation = ref(table_name) %}
    
    {% set exists = adapter.get_relation(
        database=model_relation.database,
        schema=model_relation.schema,
        identifier=model_relation.identifier
    )%}
    {{ log("Source Relation: " ~ model_relation, info=true) }}

    {% if exists %}
        select * from {{model_relation}}
    {%else%}
        SELECT NULL
    {% endif %}

{% endmacro %} #}

{# -----------Для произвольной схемы---------------#TODO: Лучше убрать конкатенацию для избежания инъекций #} 

{% macro safe_select(table_name) %}
    {% set query = "
        select 
            table_schema,
            table_name
        from dwh_flight.INFORMATION_SCHEMA.TABLES
        where table_name = '" ~ table_name ~ "'
        limit 1
        " 
    %}

    {% set result = run_query(query) %}

    {% if result | length > 0 %}
        {% set tables = result.columns['table_name'].values()[0] %}
        {% set schemas = result.columns['table_schema'].values()[0] %}

        select * from {{schemas}}.{{tables}}
    {% else %}
        SELECT NULL
    {% endif %}
{% endmacro %}