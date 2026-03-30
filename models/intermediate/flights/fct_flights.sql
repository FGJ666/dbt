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
    actual_arrival,
    case
        when actual_departure is not NULL and actual_arrival is not NULL
            then actual_arrival - actual_departure
        else INTERVAL '0 seconds'
    end as actual_duration_flight,
    current_date as load_date
from
    {{ ref('stg_flights__flights') }}
