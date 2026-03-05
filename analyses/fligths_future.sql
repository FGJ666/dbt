{# Задача 1:

Посчитайте сколько всего полетов (количество строк в модели fct_fligths) запланировано на дату, начиная с текущей даты (scheduled_departure >= [текущая дата]).

Создайте analyses под названием fligths_future с расчетом. Опубликуйте его в github и приложите ссылку.

Подсказки:

- Текущую дату и время в jinja можно получить так: {{ run_started_at }}
- Дату со временем можно преобразовать к строке с помощью фильтра string
- Получить первые 10 символов строки в jinja можно с помощью фильтра truncate(10, True, "") #}


select count(*) as count_flights
from {{ ref('fct_flights') }}
where scheduled_departure >= '{{ run_started_at | string | truncate(10, True, '') }}'::date
