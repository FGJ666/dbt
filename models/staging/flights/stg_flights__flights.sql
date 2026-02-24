{{ config(
  materialized = 'incremental',
  incremental_strategy = 'merge',
  uniq_key = ['flight_id'],
  tags = ['incremental', 'flights']
) }}

select
    flight_id,
    flight_no,
    scheduled_departure,
    scheduled_arrival,
    departure_airport,
    arrival_airport,
    status,
    aircraft_code,
    actual_departure,
    actual_arrival
from
  {{ source(
    'demo_src',
    'flights'
  ) }}
where
    scheduled_departure > (
        select max(scheduled_departure)
        from
            {{ this }}
    ) - interval '100 day'
