{% set fly = ['CN1', 'CR2', '763'] %}
select
    {%- for aircraft in fly %}
        sum(
            case
                when aircraft_id = '{{ aircraft }}' then 1
                else 0
            end
        ) as "flight_{{ aircraft }}" {% if not loop.last %},
        {%- endif -%}
    {% endfor %}
from
    {{ ref('fct_flights') }}
