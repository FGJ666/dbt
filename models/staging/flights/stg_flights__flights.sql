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

{% if is_incremental() %}
    -- Логика инкрементального обновления:
    -- 1. Добавляем новые рейсы с scheduled_departure >= максимальной даты в таблице
    -- 2. Обновляем существующие рейсы по unique_key (flight_id)
    where scheduled_departure >= (
        select max(scheduled_departure) from {{ this }}
    )
    or flight_id in (
        select flight_id from {{ this }}
    )
{% endif %}