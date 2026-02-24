{{ config(
    materialized = 'table',
) }}

select
    tickets.ticket_no,
    tickets.book_ref,
    tickets.passenger_id,
    tickets.passenger_name,
    tickets.contact_data
from
    {{ ref('stg_flights__tickets') }} as tickets
where
    tickets.passenger_id not in (
        select passenger_id
        from
            {{ ref('staff') }}
    )
