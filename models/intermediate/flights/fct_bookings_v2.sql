select
    {{dbt_utils.generate_surrogate_key(['book_ref'])}} as book_ref_key,
    {{ show_columns_relation('stg_flights__bookings') -}},
    current_date as loaded_at
from
    {{ ref('stg_flights__bookings') }}
