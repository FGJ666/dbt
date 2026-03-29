select * from {{ ref('stg_flights__airports') }}
where length(airport_code) != 3
