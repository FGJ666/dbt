select
    book_ref,
    book_date,
    total_amount,
    current_date as loaded_at
from
    {{ ref('stg_flights__bookings') }}
