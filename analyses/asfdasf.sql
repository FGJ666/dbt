{# 
1. Напишите Jinja код, который выведет список всех колонок таблицы dwh_fligths.intermediate.stg_flights__flights (или любой другой таблицы, 
в которой хранятся полеты, если у вас отличаются названия таблиц от учебного проекта).

Ответ приложите в виде кода Jinja 
#}

{% set flights_relation = load_relation(ref('stg_flights__flights')) %}
{% set columns = adapter.get_columns_in_relation(flights_relation) %}

{% for column in columns %}
    {{ "Column: " ~ column }}
{% endfor %}

select * from {{ ref('stg_flights__flights') }}