{#
2. Создайте копию модели stg_flights__aircrafts.sql с названием stg_flights__aircrafts_backup.sql.

В модели stg_flights__aircrafts_backup.sql создайте pre_hook,  который перед обновлением модели будет переименовывать таблицу, 
существующую до начала обновления модели и относящуюся к данной модели, устанавливая название по следующему шаблону:

intermediate.stg_flights__aircrafts_backup_[YYYY_MM_DD_HHSSmm]

, где [YYYY_MM_DD_HHSSmm] - год, месяц, число, часы, минуты и секунды текущего времени (времени начала обновления модели)

Опубликуйте модель в github и приложите на нее ссылку.
#}


{{ config(
    materialized = 'table',
    pre_hook="{{backup_table_before_build()}}"
) }}

select
    aircraft_code,
    model,
    range
from
    {{ source(
        'demo_src',
        'aircrafts'
    ) }}
    
