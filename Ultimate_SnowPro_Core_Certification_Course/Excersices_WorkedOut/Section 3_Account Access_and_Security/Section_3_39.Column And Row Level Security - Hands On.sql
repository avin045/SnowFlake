/*----------------D1_2 Hands-on----------------
1) Managing masking policies
2) Managing row access policies
3) Centralized policy management
----------------------------------------------*/

-- Create database, schema and table for test data
USE ROLE SYSADMIN;
use warehouse compute_wh;

CREATE DATABASE SALES_DB;
CREATE SCHEMA SALES_SCHEMA;

CREATE TABLE CUSTOMERS (
ID NUMBER, 
NAME STRING,
EMAIL STRING,
COUNTRY_CODE STRING
);

INSERT INTO CUSTOMERS VALUES 
(138763, 'Kajal Yash','k-yash@gmail.com' ,'IN'), 
(896731, 'Iza Jacenty','jacentyi@stanford.edu','PL'),
(799521, 'Finn Conley','conley76@outlook.co.uk','IE');

-- create reader role
use role accountadmin;-- use role securityadmin;

grant usage on database SALES_DB to role analyst;
grant usage on schema sales_schema to role analyst;

grant select on table SALES_DB.SALES_SCHEMA.CUSTOMERS to role analyst;

-- Create reader role
create OR replace role MASKING_ADMIN;

grant usage on database SALES_DB to role masking_admin;
grant usage on schema SALES_SCHEMA to role masking_admin;
grant CREATE MASKING POLICY,CREATE ROW ACCESS POLICY on schema SALES_SCHEMA to role masking_admin;
grant APPLY MASKING POLICY,APPLY ROW ACCESS POLICY on account to role masking_admin;
grant role MASKING_ADMIN to user AVINSF2;

show grants to role masking_admin;

-- Create Masking Policy (Column Level Security)
create or replace masking policy EMAIL_MASK as (val string)returns STRING ->
CASE 
when current_role() in ('ANALYST') then val
when current_role() in ('SYSADMIN') then '*****sysadmin*****'
else regexp_replace(val,'.+\@','******@') /* make ***** before @ */
END;

-- SET Column-Level-Security on column email
alter table customers modify column email set masking policy email_mask;

-- UNSET Column-Level-Security on column email
-- alter table customers modify column email unset masking policy;
-- drop masking policy email_mask;

-- Verify Policy
use role analyst;
select * from customers;

use role sysadmin;
select * from customers;

----------------------------------------- ROW ACCESS POLICY -----------------------------------------
-- Create 'simple' row access policy
use role masking_admin;
use schema sales_schema;

-- Input column irrelevant in simple row access policy, just a binding point
create or replace row access policy row_access_policy as (val varchar) returns boolean ->
CASE
when 'ANALYST' = current_role() then TRUE
else FALSE
END;

-- ADD ROW ACCESS POLICY INTO A TABLE 
-- # Aleady we use column level access policy on column (email) so we use "NAME" column Here.
alter table customers add row access policy row_access_policy on (email);

-- ALTER TABLE CUSTOMERS MODIFY COLUMN EMAIL UNSET MASKING POLICY;

alter table customers add row access policy row_access_policy on (name);

-- Verify policy 
use role analyst;
select * from customers;

use role sysadmin;
select * from customers;

---------------------------------- Another Ex for ROW ACCESS POLICY ----------------------------------

-- Create mapping table 
CREATE TABLE TITLE_COUNTRY_MAPPING  (
  TITLE STRING,
  COUNTRY_ISO_CODE string
);

insert into TITLE_COUNTRY_MAPPING values('ANALYST','PL'); -- -> To Display the country_code = 'PL' in customers table.

GRANT select on TITLE_COUNTRY_MAPPING to role masking_admin;


USE ROLE MASKING_ADMIN;

CREATE OR REPLACE ROW ACCESS POLICY CUSTOMER_POLICY AS (COUNTRY_CODE VARCHAR) RETURNS BOOLEAN ->
  'SYSADMIN' = CURRENT_ROLE()
      OR EXISTS (
            SELECT 1 FROM TITLE_COUNTRY_MAPPING
              WHERE TITLE = CURRENT_ROLE()
                AND COUNTRY_ISO_CODE = COUNTRY_CODE
          );

alter table customers add row access policy customer_policy on (COUNTRY_CODE); -- Object CUSTOMERS already has a ROW_ACCESS_POLICY. Only one ROW_ACCESS_POLICY is allowed at a time.

alter table customers drop all row access policies;

alter table customers add row access policy customer_policy on (COUNTRY_CODE);

-- Verify policy
USE ROLE SYSADMIN;

SELECT * FROM CUSTOMERS; 

USE ROLE ANALYST;

SELECT * FROM CUSTOMERS; 