<a name="about">Работа с базами данных MySQL</a>

<a name="database-architecture"> 
Таблица accounting_book:
id (INT, Primary Key): уникальный идентификатор записи.
id_a (INT, Foreign Key): внешний ключ таблицы auditory.
id_w (INT, Foreign Key): внешний ключ таблицы worker.
note_numb (INT): номер записи.
note_date (DATETIME): дата записи.

Таблица worker:
id (INT, Primary Key): уникальный идентификатор работника.
FIO (VARCHAR(30)): фамилия, имя, отчество работника.
phone (VARCHAR(30)): телефонный номер работника.

Таблица auditory:
id (INT, Primary Key): уникальный идентификатор аудитории.
number_a (INT): номер аудитории.
total_price_equipment (DOUBLE): общая стоимость оборудования в аудитории.

Таблица complectation_auditory:
id (INT, Primary Key): уникальный идентификатор комплектации аудитории.
id_a (INT, Foreign Key): внешний ключ таблицы auditory.
id_e (INT, Foreign Key): внешний ключ таблицы equipment.
count_e (INT): количество оборудования.

Таблица equipment:
id (INT, Primary Key): уникальный идентификатор оборудования.
name_e (VARCHAR(30)): наименование оборудования.
price (DOUBLE): цена оборудования.
</a>
