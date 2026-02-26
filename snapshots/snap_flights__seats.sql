select
    aircraft_code,
    seat_no,
    fare_conditions
from
    {{ ref('stg_flights__seats') }}
