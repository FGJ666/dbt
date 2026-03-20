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
    current_date as load_date
from
    {{ ref('stg_flights__flights') }}

{% set uniq_status = dbt_utils.get_column_values(table=ref('stg_flights__flights'), column='status') %}
{% do log("Uniq status values: " ~ uniq_status) %}
