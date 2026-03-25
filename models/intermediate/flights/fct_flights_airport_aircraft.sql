{{
  config(
    materialized = 'ephemeral',
    )
}}
select
    departure_airport as departure_airport_code,
    stg_flights__airports_departure.airport_name as departure_airport_name,
    stg_flights__airports_departure.city as departure_airport_city,
    stg_flights__airports_departure.coordinates as departure_airport_coordinates,
    arrival_airport as arrival_airport_code,
    stg_flights__airports_arrival.airport_name as arrival_airport_name,
    stg_flights__airports_arrival.city as arrival_airport_city,
    stg_flights__airports_arrival.coordinates as arrival_airport_coordinates,
    status as flight_status,
    stg_flights__flights.aircraft_code,
    model as aircraft_model,
    scheduled_departure as scheduled_departure_date,
    flight_no,
    flight_id
from {{ ref('stg_flights__flights') }}
inner join {{ ref('stg_flights__airports') }} as stg_flights__airports_departure
    on stg_flights__flights.departure_airport = stg_flights__airports_departure.airport_code
inner join {{ ref('stg_flights__airports') }} as stg_flights__airports_arrival
    on stg_flights__flights.arrival_airport = stg_flights__airports_arrival.airport_code
inner join {{ ref('stg_flights__aircrafts') }}
    on stg_flights__flights.aircraft_code = stg_flights__aircrafts.aircraft_code
