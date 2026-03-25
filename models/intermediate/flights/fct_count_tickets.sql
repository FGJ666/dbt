{{
  config(
    materialized = 'ephemeral',
    )
}}
select
    flight_id,
    count(ticket_no) as count_tickets
from {{ ref('fct_ticket_flights') }}
group by
    flight_id
