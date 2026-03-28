{# 2 (2/3). Создайте singular тест для проверки, что нет бронирований, в которые входит 5 или более билетов.

Если количество бронирований с 5 или более билетами:

до 50, то не выводить предупреждение
от 50 до 100, то вывести предупреждение
более 100, то вывести ошибку #}

{{
  config(
    severity = 'error',
    error_if = '>100',
    warn_if = '>50',
    
    )
}}
select
    book_ref
from {{ ref('stg_flights__bookings') }}
inner join {{ ref('stg_flights__tickets') }} using (book_ref)
group by book_ref
having count(distinct ticket_no) >= 5
