use warehouse compute_wh;

-- DATA GENERATION
select uuid_string();

-- AGGREGATE
use database demo_db;
use schema demo_schema;

create or replace table account_det(
id varchar,
amount float
);

insert into account_det values('001',10.00),('001',23.78),('002',67.78);

select max(amount) from account_det;

-- WINDOW FUNTIONS
select id,amount,max(amount) over (partition by id) from account_det;

-- TABLE FUNCTIONS
select randstr(5,random()),random() from table(generator(rowcount=>3));

-- SYSTEM FUNCTIONs
-- 1. cancel query
select system$cancel_query('01aa971f-3200-aa64-0003-41ba0006d0ea'); -- Identified SQL statement is not currently executing.

-- 2. pipe status
select system$pipe_status('mention_pipe_name_here');

-- 3. explain plan
select system$explain_plan_json(
'select id,amount,max(amount) over (partition by id) from account_det'
);
/*
{"GlobalStats":{"partitionsTotal":1,"partitionsAssigned":1,"bytesAssigned":1024},"Operations":[[{"id":0,"operation":"Result","expressions":["ACCOUNT_DET.ID","ACCOUNT_DET.AMOUNT","MAX(ACCOUNT_DET.AMOUNT) OVER (PARTITION BY ACCOUNT_DET.ID)"]},{"id":1,"parent":0,"operation":"WindowFunction","expressions":["MAX(ACCOUNT_DET.AMOUNT) OVER (PARTITION BY ACCOUNT_DET.ID)"]},{"id":2,"parent":1,"operation":"TableScan","objects":["DEMO_DB.DEMO_SCHEMA.ACCOUNT_DET"],"expressions":["ID","AMOUNT"],"partitionsAssigned":1,"partitionsTotal":1,"bytesAssigned":1024}]]}
*/
