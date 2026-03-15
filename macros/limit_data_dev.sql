{# 
1. (1/3) В макросе limit_data_dev, уменьшающем количество строк при работе в dev окружении, сделать проверку, 
что в переданном параметре days содержится не отрицательное значение.

Если в параметре days отрицательное значение, то необходимо сгенерировать exception с ошибкой. 
#}
{% macro limit_data_dev(column_name, days=3) %}
    {% if days < 0 %}
        {% do exceptions.warn("Invalid value for days parameter. It should be a non-negative integer.") %}
    {%elif target.name == 'dev'%}
        where 
            {{adapter.quote(column_name)}} >= 
            {{ dbt.dateadd(datepart="day", interval= -days, from_date_or_timestamp=column_name) }}
    {% endif %}
{% endmacro %}