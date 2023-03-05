/*----------------D1_1 Hands-on----------------
1) Role-based access control (RBAC)
2) Discretionary access control (DAC)
3) Roles & Privileges
4) Privilege Inheritance
----------------------------------------------*/

-- WAREHOUSE
USE WAREHOUSE COMPUTE_WH;
ALTER WAREHOUSE COMPUTE_WH RESUME;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;

-- Set Context
USE ROLE ACCOUNTADMIN;

-- ROLES
show roles;

-- via LAST QUERY ID
select "name","comment" from TABLE(result_scan(last_query_id()));

show grants to role securityadmin;

-- Create Database and Schema (UNDER -> "sysadmin")
use role sysadmin;

create or replace database films_db;
create or replace schema films_schema;

create or replace TABLE films_sysadmin(
ID STRING,
TITLE STRING,
RELEASE_DATE DATE,
RATING INT
);

-- Create custom role inherited by SYSADMIN system-defined role.

USE ROLE SECURITYADMIN; -- Used to create ROLE's

create role analyst;

grant usage on database films_db to role analyst;

grant usage,CREATE TABLE on schema films_db.films_schema to role analyst;

grant usage on warehouse compute_wh to role analyst;

-- Assign "custom role" to SYSADMIN (privilege Inheritance)
grant role analyst to role sysadmin;

-- GRANT "ANALYST role" to USER
grant role analyst to USER AVINSF2;

show users;
show roles;

-- Verify Privileges
show grants to role sysadmin;
-- show grants of role sysadmin; -- own ( sysadmin inherits the properties(privileges) from ACCOUNTADMIN )

show grants to role analyst; -- granted on (which object's [database,schema.table,warehouse])
show grants of role analyst; -- granted to (which ROLE or USER)

-- Set Context for "ROLE ANALYST" -> CREATE TABLE , USAGE
use role analyst;
use schema films_db.films_schema;

create table films_analyst(
id string,
title string,
release_date date,
rating int
);

show tables;

show databases;

select "name","owner" from table(result_scan(last_query_id()));

use role sysadmin;

show tables;

-- FUTURE GRANTS
USE ROLE SECURITYADMIN;

grant usage on future schemas in database films_db to role analyst;

use role sysadmin;

create schema music_schema;
create schema books_schema;

use role analyst;

show schemas;

show grants to role analyst;

-- Create User
use role useradmin;

create user sundari password='iloveyou' default_role=analyst default_warehouse = 'compute_wh' must_change_password=TRUE;

use role securityadmin;

grant role analyst to user sundari; -- the ROLE analyst is providing for user "SUNDARI". -- New Passcode in UI -> SnowFlakeTrial123

-- Clear-down resources
-- USE ROLE SYSADMIN;
-- DROP DATABASE FILMS_DB;
