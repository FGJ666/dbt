{# (2/3) Создайте свой собственный Generic тест, который будет проверять, что в колонке хранятся только строки длинной 3 символа, 
которые состоят только из заглавных букв. Добавьте эту проверку на поле airport_code. Тест назовите airport_code_pattern. 

В случае не удачи, данный тест должен возвращать предупреждение вместо ошибки; #}
{% test airport_code_pattern(model, column_name)%}
    select
    * from {{model}}
    where 
        {{column_name | length}} = 3
        and 
        {{column_name}} = {{column_name | upper}}
{%endtest%}