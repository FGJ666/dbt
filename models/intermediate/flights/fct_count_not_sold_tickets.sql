{{
  config(
    materialized = 'ephemeral',
    )
}}
with cnt_seats_by_aircraft_code as (
    select
        aircraft_code,
        count(distinct seat_no) as count_seats
    from {{ ref('stg_flights__seats') }}
    inner join {{ ref('stg_flights__aircrafts') }} using (aircraft_code)
    group by aircraft_code
),

all_seats_per_flight as (
    select
        flight_id,
        avg(count_seats) as all_seats
    from {{ ref('stg_flights__flights') }}
    inner join cnt_seats_by_aircraft_code using (aircraft_code)
    group by flight_id
)
select
    flight_id,
    all_seats - count_tickets as not_sold_tickets
from {{ ref('fct_count_tickets') }}
inner join all_seats_per_flight using (flight_id)
