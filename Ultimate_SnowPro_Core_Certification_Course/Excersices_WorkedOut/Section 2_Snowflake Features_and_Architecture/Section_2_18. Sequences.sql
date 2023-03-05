use database demo_db;
use schema demo_schema;

create sequence fun_sequence
START = 1 
INCREMENT = 109;

create sequence fun_sequence_1_to_10
START = 0
INCREMENT = 10;

select fun_sequence.nextval; -- 1
select fun_sequence.nextval; -- 110
select fun_sequence.nextval; -- 219
select fun_sequence.nextval; -- 328

select fun_sequence_1_to_10.nextval,fun_sequence_1_to_10.nextval,fun_sequence_1_to_10.nextval,fun_sequence_1_to_10.nextval;
/*
NEXTVAL	NEXTVAL_2	NEXTVAL_3	NEXTVAL_4
      0	       10	       20	   30
*/

-- WHILE INSERTING INTO A TABLE

create sequence transaction_seq
start = 1001
increment = 1;

create table transaction(
id int,
time datetime
);

desc table transaction;

select current_timestamp();

insert into transaction(id,time) values (transaction_seq.nextval,current_timestamp());
insert into transaction values (transaction_seq.nextval,current_timestamp());
insert into transaction values (transaction_seq.nextval,current_timestamp());
insert into transaction values (transaction_seq.nextval,current_timestamp());
insert into transaction values (transaction_seq.nextval,current_timestamp());

select * from transaction;

-- WHILE CREATING TABLES
create or replace table transaction_with_nextval(
ID integer default transaction_seq.nextval,
name varchar
);

insert into transaction_with_nextval(name) values('raj'),('kumar'),('mohan');

select * from transaction_with_nextval;