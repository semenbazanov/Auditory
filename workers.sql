create table workers
(
    id    integer primary key auto_increment,
    fio   varchar(30) not null,
    phone varchar(30) not null UNIQUE
);

create table auditory
(
    id                    integer primary key auto_increment,
    number_a              integer              not null UNIQUE,
    total_price_equipment double default (0.0) not null
);

create table equipment
(
    id     integer primary key auto_increment,
    name_e varchar(30) not null UNIQUE,
    price  double      not null
);

create table accounting_book
(
    id        integer primary key auto_increment,
    id_a      integer  not null,
    foreign key (id_a) references auditory (id)
        on delete cascade on update cascade,
    id_w      integer  not null,
    foreign key (id_w) references workers (id)
        on delete cascade on update cascade,
    note_numb integer  not null UNIQUE,
    note_date DATETIME not null,
    UNIQUE (id_a, id_w, note_date)
);

create table complectation_auditory
(
    id      integer primary key auto_increment,
    id_a    integer not null,
    foreign key (id_a) references auditory (id)
        on delete cascade on update cascade,
    id_e    integer not null,
    foreign key (id_e) references equipment (id)
        on delete cascade on update cascade,
    count_e integer not null,
    UNIQUE (id_a, id_e)
);

INSERT INTO workers (fio, phone)
values ('Ivanov', +79118469372),
       ('Petrov', +79115347890),
       ('Smirnov', +79118462977);

INSERT INTO auditory (number_a)
values (3),
       (5),
       (7);

INSERT INTO accounting_book (id_a, id_w, note_numb, note_date)
values (1, 2, 1, '2022-12-05 10:37:22'),
       (1, 1, 2, '2023-10-10 12:43:22'),
       (2, 3, 3, '2023-08-01 15:20:41'),
       (3, 1, 4, '2023-10-07 09:05:04'),
       (2, 2, 5, '2023-10-10 12:43:22');

INSERT INTO equipment (name_e, price)
values ('table', 500),
       ('chair', 1000),
       ('book', 2000),
       ('keyboard', 2500),
       ('desk', 3000);

INSERT INTO complectation_auditory (id_a, id_e, count_e)
values (1, 1, 5),
       (1, 2, 3),
       (1, 3, 10),
       (2, 1, 2),
       (2, 2, 4),
       (2, 3, 7),
       (3, 1, 8),
       (3, 2, 5),
       (3, 3, 4);

/**
  •	Показать какие сотрудники заказывали какие аудитории
 */
SELECT fio, number_a
from workers
         join accounting_book ab on workers.id = ab.id_w
         join auditory a on a.id = ab.id_a;

/**
  Показать какие аудитории заказывал сотрудник с ФИО = ?
 */
SELECT number_a
from workers
         join accounting_book ab on workers.id = ab.id_w
         join auditory a on a.id = ab.id_a
where fio = ?;

/**
  Поменять ФИО в таблице сотрудник
 */
update workers
set fio = 'Kuznetsov'
where id = 1;

/**
  Определить количество аудиторий, сколько взял
сотрудник с заданным ФИО
 */
SELECT fio, COUNT(number_a) AS quantity
FROM accounting_book
         join workers w on accounting_book.id_w = w.id
         join auditory a on accounting_book.id_a = a.id
where fio = ?;

/**
  Вывести имя одного любого сотрудника,
  у которого количество записей максимально
 */
SELECT fio, COUNT(id_a) as qty
FROM accounting_book
         join workers w on accounting_book.id_w = w.id
         join auditory a on accounting_book.id_a = a.id
group by fio
HAVING qty = (SELECT MAX(sub.cnt)
              from (SELECT COUNT(id_a) as cnt
                    FROM accounting_book
                             join workers w on accounting_book.id_w = w.id
                             join auditory a on accounting_book.id_a = a.id
                    group by fio) AS sub)
LIMIT 1;

/**
 Вывести всех сотрудников, у которых количество записей максимально
 */
SELECT fio, COUNT(id_a) as qty
from accounting_book
         join workers on accounting_book.id_w = workers.id
         join auditory on accounting_book.id_a = auditory.id
group by fio
having qty = (SELECT max(alias.qnt)
              from (SELECT COUNT(id_a) as qnt
                    from accounting_book
                             join workers on accounting_book.id_w = workers.id
                             join auditory on accounting_book.id_a = auditory.id
                    group by fio) alias);

/**
  Вывести номер одной любой самой используемой аудитории
 */
SELECT number_a, COUNT(id_a) AS most_popular_auditory
from workers
         join accounting_book ab on workers.id = ab.id_w
         join auditory a on ab.id_a = a.id
group by number_a
limit 1;

/**
  •	Поменять параметры аудитории
 */
UPDATE auditory
set total_price_equipment = 40000
where number_a = 3;

/**
  Вывести топ 2 самых используемых аудиторий
 */
SELECT number_a, COUNT(id_a) as cnt
from accounting_book
         join auditory a on a.id = accounting_book.id_a
         join workers w on accounting_book.id_w = w.id
group by number_a
order by cnt desc
limit 2;

/**
  Вывести номера аудитории с наименьшей ценой оборудования
 */
SELECT number_a, SUM(count_e * price) as total_price
from complectation_auditory
         join auditory a on a.id = complectation_auditory.id_a
         join equipment e on e.id = complectation_auditory.id_e
group by number_a
having total_price = (SELECT min(total_price)
                      from (SELECT SUM(count_e * price) as total_price
                            from complectation_auditory
                                     join auditory a on a.id = complectation_auditory.id_a
                                     join equipment e on e.id = complectation_auditory.id_e
                            group by number_a) alias);

/**
  Вывести сотрудников, которые заказывали аудитории
  с наименьшей ценой оборудования в них
 */
SELECT fio, number_a
from accounting_book
         join auditory a on a.id = accounting_book.id_a
         join workers w on w.id = accounting_book.id_w
where number_a = (SELECT number_a
                  from (SELECT number_a, SUM(price * count_e) AS total_equipment
                        from complectation_auditory
                                 join equipment e on e.id = complectation_auditory.id_e
                                 join auditory a on a.id = complectation_auditory.id_a
                        group by number_a
                        having total_equipment = (SELECT MIN(total_equipment)
                                                  from (select SUM(price * count_e) AS total_equipment
                                                        from complectation_auditory
                                                                 join equipment e on e.id = complectation_auditory.id_e
                                                                 join auditory a on a.id = complectation_auditory.id_a
                                                        group by number_a) t)) t1);

/**
  Определить среднюю цену оборудования в
  заказанных каждым сотрудником аудиториях
 */
SELECT fio, (SUM(price * count_e) / SUM(count_e)) as total_price
from accounting_book
         join auditory a on a.id = accounting_book.id_a
         join workers w on w.id = accounting_book.id_w
         join complectation_auditory ca on a.id = ca.id_a
         join equipment e on e.id = ca.id_e
group by fio;

/**
  Найти аудитории, в которых
  максимальное количество оборудования
 */
SELECT number_a, SUM(count_e) AS max_equipment
from complectation_auditory
         join auditory a on a.id = complectation_auditory.id_a
group by number_a
having max_equipment = (SELECT MAX(max_a)
                        from (SELECT SUM(count_e) AS max_a
                              from complectation_auditory
                                       join auditory a on a.id = complectation_auditory.id_a
                              group by number_a) t);

/**
  Для каждой аудитории
  вывести среднюю цену находящегося в ней оборудования
 */
select number_a, (SUM(price * count_e) / SUM(count_e)) AS total_equipment
from complectation_auditory
         join equipment e on e.id = complectation_auditory.id_e
         join auditory a on a.id = complectation_auditory.id_a
group by number_a;

/**
  Вывести рейтинг аудиторий
  по суммарному числу оборудования в них
 */
select number_a, SUM(count_e) AS total_equipment
from complectation_auditory
         join equipment e on e.id = complectation_auditory.id_e
         join auditory a on a.id = complectation_auditory.id_a
group by number_a
order by total_equipment DESC;

/**
  Определение всего оборудования,
  которое по стоимости такое же, как заданное
 */
SELECT name_e AS equipment
from equipment
where price = ?;

/**
  Написать триггер на колонку total_price_equipment,
  срабатывающий при добавлении нового оборудования
  в аудиторию оборудования
 */
drop trigger total_price_tr;

delimiter |
CREATE TRIGGER total_price_tr
    AFTER INSERT
    on complectation_auditory
    FOR EACH ROW
begin
    UPDATE auditory
    set total_price_equipment = total_price_equipment + (select *
                                                         from (SELECT SUM(count_e * price)
                                                               from complectation_auditory
                                                                        join equipment e on e.id = complectation_auditory.id_e
                                                                        join auditory a on a.id = complectation_auditory.id_a
                                                               where id_a = new.id_a
                                                                 and id_e = new.id_e) as alias)
    where id = new.id_a;
end;
|

/**
  Написать триггер на колонку total_price_equipment,
  срабатывающий при удалении оборудования из нее
 */
drop trigger total_price_deduction_tr;

delimiter |
CREATE TRIGGER total_price_deduction_tr
    BEFORE DELETE
    on complectation_auditory
    FOR EACH ROW
begin
    UPDATE auditory
    set total_price_equipment = total_price_equipment - (select *
                                                         from (SELECT SUM(count_e * price)
                                                               from complectation_auditory
                                                                        join equipment e on e.id = complectation_auditory.id_e
                                                                        join auditory a on a.id = complectation_auditory.id_a
                                                               where id_a = old.id_a
                                                                 and id_e = old.id_e) as alias)
    where id = old.id_a;
end;
|






