use database demo_db;
use schema demo_schema;
use warehouse compute_wh;

show tables;

select * from TRANSACTIONS_SBI;

-- views
create view transactions_view_sbi as (select * from TRANSACTIONS_SBI); -- 184 ms
create secure view transactions_secure_view_sbi as (select * from TRANSACTIONS_SBI); -- 205 ms

select * from transactions_view_sbi; -- 1.5s -> seconds
select get_ddl('view','transactions_view_sbi');

select * from transactions_secure_view_sbi; -- 291ms
select get_ddl('view','transactions_secure_view_sbi');


show views;

