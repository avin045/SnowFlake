use database demo_db;
use schema demo_schema;

show tables;

create view test_view as (
select * from TRANSACTIONS_SBI
);

create or replace materialized view test_view_mat as (
select * from TRANSACTIONS_SBI
);

create or replace materialized view test_view_mat as (
select * from TRANSACTIONS_SBI join ext_table
); -- Invalid materialized view definition. More than one table referenced in the view definition

select * from test_view;
select * from test_view_mat;

select * from TRANSACTIONS_SBI;

insert into TRANSACTIONS_SBI values(11111,11111111,'Dummy',11111,'sbi');
insert into TRANSACTIONS_SBI values(222,22222222,'Dumm22y',222222,'sbi');

select * from test_view; -- 143 ms
select * from test_view_mat; -- 178 ms