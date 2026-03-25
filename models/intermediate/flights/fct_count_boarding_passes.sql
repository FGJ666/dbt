
select
    flight_id,
    count(ticket_no) as boarding_passes_count
from {{ ref('stg_flights__boarding_passes') }}
group by
    flight_id
