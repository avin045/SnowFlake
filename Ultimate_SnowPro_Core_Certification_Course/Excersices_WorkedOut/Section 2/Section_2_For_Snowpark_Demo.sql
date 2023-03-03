create or replace sequence sbi_key
start = 10001
increment = 1;

create or replace sequence sbi_key_account_generator
start = 30124678
increment = 1;

create or replace sequence sbi_amount
start = 100000
increment = 1110;

create or replace table transactions_sbi(
id int default sbi_key.nextval,
account_id int default sbi_key_account_generator.nextval,
name varchar,
amount int default sbi_amount.nextval,
bank_name varchar default 'sbi'
);

-- INSERTING
insert into transactions_sbi(name) values('jeeva'),('hari'),('Revi'),('Krish'),('Raja'),('Karunya'),('siva'),('Kokki Kumar'),('Tony Stark');

insert into transactions_sbi(name) values ('chandru'),('vijay'),('Ajith');

-- create duplicate value for ajith
insert into transactions_sbi(account_id,name) values (30124689,'Ajith');

select * from transactions_sbi;

-- drop table transactions_sbi;
show tables like '%flag%';
select * from flagged_transaction_sbi;

select current_account();