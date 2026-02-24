select
    ticket_flights.ticket_no,
    ticket_flights.flight_id,
    ticket_flights.fare_conditions,
    ticket_flights.amount,
    boarding_passes.ticket_no as boarding_no,
    boarding_passes.seat_no,
    case
        when boarding_passes.ticket_no is null then 'no'
        else 'yes'
    end as boarding_pass_exists,
    current_date as load_date
from
    {{ ref('stg_flights__ticket_flights') }} as ticket_flights
left join {{ ref('stg_flights__boarding_passes') }} as boarding_passes
    on
        ticket_flights.ticket_no = boarding_passes.ticket_no
        and ticket_flights.flight_id = boarding_passes.flight_id
