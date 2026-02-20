{{ config(
    materialized = 'table',
) }}

select
    "stg_flights__ticket_flights"."ticket_no",
    stg_flights__ticket_flights.flight_id,
    stg_flights__ticket_flights.fare_conditions,
    stg_flights__ticket_flights.amount,
    case
        when "stg_flights__boarding_passes"."ticket_no" is null then 'no'
        else 'yes'
    end as boarding_pass_exists,
    "stg_flights__boarding_passes"."ticket_no" as boarding_no,
    "stg_flights__boarding_passes"."seat_no" as seat_no,
    current_date as load_date
from
    {{ ref('stg_flights__ticket_flights') }}
    left join {{ ref('stg_flights__boarding_passes') }}
    on "stg_flights__ticket_flights"."ticket_no" = "stg_flights__boarding_passes"."ticket_no"
    and "stg_flights__ticket_flights"."flight_id" = "stg_flights__boarding_passes"."flight_id"
