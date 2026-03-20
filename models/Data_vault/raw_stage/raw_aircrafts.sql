{{ config(
    materialized = 'table',
) }}

select
    aircraft_code,
    model,
    range,
    'aircrafts' as RECORD_SOURCE,
    now() as LOAD_DATETIME
from
    {{ source(
        'demo_src',
        'aircrafts'
    ) }}
