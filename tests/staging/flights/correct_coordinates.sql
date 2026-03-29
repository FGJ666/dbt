select
    *
from {{ ref('stg_flights__airports') }}
where 
    not coordinates[0] between 20 and 180
    and not coordinates[1] between 42 and 81