select
    aircrafts.aircraft_code,
    aircrafts.model,
    count(
        distinct seats.seat_no
    ) as seat_count
from
    {{ ref('stg_flights__seats') }} as seats
inner join {{ ref('stg_flights__aircrafts') }} as aircrafts
    on seats.aircraft_code = aircrafts.aircraft_code
group by
    aircrafts.aircraft_code,
    aircrafts.model
order by
    seat_count desc;
