select
    departure_airport_code,
    departure_airport_name,
    departure_airport_city,
    departure_airport_coordinates,
    arrival_airport_code,
    arrival_airport_name,
    arrival_airport_city,
    arrival_airport_coordinates,
    flight_status,
    aircraft_code,
    aircraft_model,
    scheduled_departure_date,
    flight_no,
    flight_id,
    fct_count_tickets.count_tickets as ticket_flights_purchased,
    boarding_passes_count as boarding_passes_issued,
    sum_amount_tickets as ticket_flights_amount,
    not_sold_tickets as ticket_flights_no_sold
from {{ ref('fct_flights_airport_aircraft') }}
inner join {{ ref('fct_count_tickets') }} using (flight_id)
inner join {{ ref('fct_count_boarding_passes') }} using (flight_id)
inner join {{ ref('fct_sum_amount_tickets') }} using (flight_id)
inner join {{ ref('fct_count_not_sold_tickets') }} using (flight_id)
