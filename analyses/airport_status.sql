select
departure_airport,
{{dbt_utils.pivot(
    dbt_utils.slugify('status'),
    dbt_utils.get_column_values( ref('fct_flights'), dbt_utils.slugify( 'status' ) ),
    agg='sum'
)
}}
from {{ ref('fct_flights') }}
group by departure_airport