{{
  config(
    materialized = 'ephemeral',
    )
}}
select
    flight_id,
    sum(amount) as sum_amount_tickets
from {{ ref('fct_ticket_flights') }}
group by
    flight_id
