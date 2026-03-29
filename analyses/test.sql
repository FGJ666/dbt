select 
    min(coordinates[0]),
    min(coordinates[1]),
    max(coordinates[0]),
    max(coordinates[1])
from {{ ref('stg_flights__airports') }}
{# where coordinates[0] > 177 #}
