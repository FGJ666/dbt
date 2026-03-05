{% set uniq_status_query %}
select
    distinct status
from
    {{ ref('stg_flights__flights') }}

{% endset %}
{% set uniq_status = run_query(uniq_status_query) %}
{% if execute %}
    {% set status = uniq_status.columns [0].values() %}
{% else %}
        {% set status = [] %}
    {% endif %}
select
    {% for s in status %}
        sum(
            case
                when status = '{{ s }}' then 1
                else 0
            end
        ) as "status_{{ s.replace(' ', '_') }}" {%- if not loop.last %},
        {%- endif %}
    {% endfor %}
from
    {{ ref('stg_flights__flights') }}
