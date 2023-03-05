/*----------------D6_1 Hands-on----------------
1) Time Travel 
2) DATA_RETENTION_TIME_IN_DAYS parameter
3) Time Travel SQL extensions
----------------------------------------------*/

-----------------------
-- doubt
-- create database tt if not exists;
create schema tt_schema;
create table tt_check(id int);

show tables;

create or replace database tt;
create or replace schema tt_schema;
-------------------------

-- Set context
USE ROLE ACCOUNTADMIN;

use warehouse compute_wh;

CREATE DATABASE DEMO_DB;
CREATE SCHEMA DEMO_SCHEMA;

use database demo_db;
use schema demo_schema;

-- show tables like 'demo_table_tt';

CREATE TABLE DEMO_TABLE_TT
(
ID STRING, 
FIRST_NAME STRING, 
AGE NUMBER
);

INSERT INTO DEMO_TABLE_TT VALUES ('55D899','Edric',56),('MMD829','Jayanthi',23),('7DM899','Chloe',51);


-- Verify retention_time is set to default of 1
SHOW DATABASES LIKE 'DEMO_DB'; -- retention_time (column name) => 1

ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS=90; 

-- Verify updated retention_time 
SHOW DATABASES LIKE 'DEMO_DB'; -- retention_time (column name) => 90

ALTER DATABASE DEMO_DB SET DATA_RETENTION_TIME_IN_DAYS=45;

-- Verify updated retention_time 
SHOW DATABASES LIKE 'DEMO_DB';-- retention_time (column name) => 45

-- Verify updated retention_time 
SHOW SCHEMAS LIKE 'DEMO_SCHEMA';-- retention_time (column name) => 45

-- Verify updated retention_time 
SHOW TABLES LIKE 'DEMO_TABLE_TT';-- retention_time (column name) => 45

-- own
select "retention_time" from table(result_scan(last_query_id())); -- retention_time (column name) => 45

ALTER SCHEMA DEMO_SCHEMA SET DATA_RETENTION_TIME_IN_DAYS=10;
ALTER TABLE DEMO_TABLE_TT SET DATA_RETENTION_TIME_IN_DAYS=5;

SHOW SCHEMAS LIKE 'DEMO_SCHEMA'; -- retention_time (column name) => 10 Days.
SHOW TABLES LIKE 'DEMO_TABLE_TT'; -- retention_time (column name) => 5 Days.

-- Setting DATA_RETENTION_TIME_IN_DAYS to 0 effectively disables Time Travel
ALTER SCHEMA DEMO_SCHEMA SET DATA_RETENTION_TIME_IN_DAYS=0; -- Here we cancelled the Time Travel so those deleted Micro partitions moved to FAIL SAFE

------------------------------------------------------
create schema demoooo;
alter schema demoooo set DATA_RETENTION_TIME_IN_DAYS=0;
drop schema demoooo;
undrop schema demoooo; -- Schema DEMOOOO did not exist or was purged.
------------------------------------------------------

-- UNDROP 
SHOW TABLES HISTORY;
SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID()));

DROP TABLE DEMO_TABLE_TT;

SHOW TABLES HISTORY;
SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID())); -- dropped_on => 2023-02-28 00:35:15.838 -0800

UNDROP TABLE DEMO_TABLE_TT;

SHOW TABLES HISTORY;
SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID()));

SELECT * FROM DEMO_TABLE_TT;


-- The "AT" keyword allows you to capture historical data inclusive of all changes made by a statement or transaction up until that point.

TRUNCATE TABLE DEMO_TABLE_TT;

SELECT * FROM DEMO_TABLE_TT;

--  Select table as it was 5 minutes ago, expressed in difference in seconds between current time
SELECT * FROM DEMO_TABLE_TT
AT(OFFSET => -60*5); -- -60 seconds * 5 => -300 seconds

-- Select rows from point in time of inserting records into table
SELECT * FROM DEMO_TABLE_TT
AT(STATEMENT => '01aaa0b3-3200-aabc-0003-41ba0008401e'); -- => '<insert_statement_id>'

-- Select tables as it was 15 minutes ago using Timestamp
SELECT * FROM DEMO_TABLE_TT
AT(TIMESTAMP => DATEADD(minute,-15, current_timestamp()));

SELECT * FROM DEMO_TABLE_TT
AT(TIMESTAMP => DATEADD(minute,-15, current_timestamp()));


-- The BEFORE keyword allows you to select historical data from a table up to, but not including any changes made by a specified statement or transaction.

-- Select rows from BEFORE truncate command
SELECT * FROM DEMO_TABLE_TT
BEFORE(STATEMENT => '01aaa0b3-3200-aabc-0003-41ba0008401e'); -- /* */ it's give before insert /* so the table is empty */

SELECT * FROM DEMO_TABLE_TT
BEFORE(STATEMENT => '01aaa10e-3200-aabe-0003-41ba000800be');-- /* <truncate_statement_id> */ it's give before truncate /* so the table have records */

CREATE TABLE DEMO_TABLE_TT_RESTORED
AS 
SELECT * FROM DEMO_TABLE_TT
BEFORE(STATEMENT => '01aaa10e-3200-aabe-0003-41ba000800be');-- /* <truncate_statement_id> */ it's give before truncate /* so the table have records 

SELECT * FROM DEMO_TABLE_TT_RESTORED;

-- Clear-down resources
DROP DATABASE DEMO_DB;
ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS=1;

show tables;