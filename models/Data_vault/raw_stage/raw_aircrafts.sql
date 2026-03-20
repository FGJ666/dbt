{{ config(
    materialized = 'table',
) }}

select
    aircraft_code,
    model,
    range,
    'aircrafts' as record_source,
    now() as load_datetime
from
    {{ source(
        'demo_src',
        'aircrafts'
    ) }}
