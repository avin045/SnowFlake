/* OWN dEMOSTRATION*/
use database demo_db;
use schema demo_schema;

create table checkdata(id int);

insert into checkdata values (1),(2);

create table checkdata_cloned clone checkdata;

insert into checkdata_cloned values (10),(20);

select * from checkdata_cloned;

drop table checkdata;

select * from checkdata_cloned;
/* OWN dEMOSTRATION eND */


-----------------------------------------------------------------------------------------------

/*----------------D6_2 Hands-on----------------
1) Clone objects
2) Cloning and Time Travel
----------------------------------------------*/

use role accountadmin;
GRANT USAGE,CREATE TABLE,MODIFY ON schema demo_schema TO ROLE sysadmin;

-- GRANT INSERT,DELETE ON FUTURE TABLES IN SCHEMA DEMO_DB.DEMO_SCHEMA TO ROLE sysadmin;
-- GRANT SELECT,INSERT,DELETE ON ALL TABLES IN SCHEMA DEMO_DB.DEMO_SCHEMA to ROLE sysadmin;
GRANT ALL PRIVILEGES ON TABLE demo_table TO ROLE SYSADMIN;


-- Set context
USE ROLE SYSADMIN;

CREATE DATABASE DEMO_DB;
CREATE SCHEMA DEMO_SCHEMA;

use database demo_db;
use schema demo_Schema;

select * from demo_table;

show tables like 'DEMO_TABLE';

-- drop database DEMO_TABLE;
CREATE or replace TABLE DEMO_TABLE
(
ID STRING, 
FIRST_NAME STRING, 
AGE NUMBER
);

/* change the retention_period => 0 to 30 Days */
ALTER TABLE DEMO_TABLE SET DATA_RETENTION_TIME_IN_DAYS=30;

INSERT INTO DEMO_TABLE VALUES ('55D899','Edric',56),('MMD829','Jayanthi',23);

select * from demo_table;

-- Cloning is metadata operation only, no data is transferred: "zero-copy" cloning
CREATE or replace TABLE DEMO_TABLE_CLONE CLONE DEMO_TABLE;

SELECT * FROM DEMO_TABLE_CLONE;

-- We can create clones of clones
CREATE or replace TABLE DEMO_TABLE_CLONE_TWO CLONE DEMO_TABLE_CLONE;

SELECT * FROM DEMO_TABLE_CLONE_TWO;

-- Easily and quickly create entire database from existing database
CREATE or replace DATABASE DEMO_DB_CLONE CLONE DEMO_DB;
-- ALTER DATABASE DEMO_DB_CLONE SET DATA_RETENTION_TIME_IN_DAYS=45;

USE DATABASE DEMO_DB_CLONE;
USE SCHEMA DEMO_SCHEMA;

-- Cloning is recursive for databases and schemas
SHOW TABLES;

SELECT * FROM DEMO_TABLE;

-- Data added to cloned database table will start to store micro-partitions, incurring additional cost
INSERT INTO DEMO_TABLE VALUES ('7DM899','Chloe',51);

-- cloned table
SELECT * FROM DEMO_TABLE;

-- source table unchanged
SELECT * FROM "DEMO_DB"."DEMO_SCHEMA"."DEMO_TABLE";

-- Create clone from point in past with Time Travel 
SHOW TABLES HISTORY;


CREATE OR REPLACE TABLE DEMO_TABLE_CLONE_TIME_TRAVEL CLONE DEMO_DB_CLONE.DEMO_SCHEMA.DEMO_TABLE
AT(OFFSET => -30*1);


SELECT * FROM DEMO_TABLE_CLONE_TIME_TRAVEL;

-- Clear-down resources
DROP DATABASE DEMO_DB;
-- DROP DATABASE DEMO_DB_CLONE;

-----------------------------------------------------------------------------------------------