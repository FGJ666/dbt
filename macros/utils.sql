{# 
3 (уровень 2/3). Перечисление всех колонок из другой модели.

Часто при создании кода модели нам требуется взять все поля из предыдущей модели. 
Чтобы не перечислять список всех полей предыдущей модели, сделайте макрос, который перечислит через запятую названия всех колонок из модели, 
название, которой будет передано в аргументе.

Назовите макрос show_columns_relation и поместите в macros/utils.sql.

В модели models/intermediate/flights/fct_bookings.sql используйте вызов макроса show_columns_relation вместо перечисления всех колонок stg_flights__bookings.

#}

{%- macro show_columns_relation(model_name) %}

    {%- set relation = ref(model_name) %}

    {%- set columns = adapter.get_columns_in_relation(relation) %}

    {%- for column in columns -%}
        {{column.name}} {%- if not loop.last -%},{% endif %}
    {% endfor %}

{%- endmacro -%}
