/*
LINKS1:
https://medium.com/snowflake/snowflake-dynamic-data-masking-e26a5a86ff09
https://thinketl.com/snowflake-dynamic-data-masking/
*/

use database demo_db;

use schema demo_schema;

create or replace table user_data(
mail_id varchar,
area varchar,
pincode int
);

insert into user_data values('avinash84546@gmail.com','126/4 vivekandha street',60012352);

select * from user_data;

-- MASKING POLICY
create or replace masking policy email_mask as (val string) returns string ->
case
	when current_role() in ('ACCOUNTADMIN') then val
    when current_role() in ('SYSADMIN') then sha2(val)
else '***'
end;

DESCRIBE MASKING POLICY email_mask;

-- GRANT PRIVILEGE "SYSADMIN"
use role securityadmin;

grant usage on database demo_db to role sysadmin;

grant usage,CREATE TABLE on schema demo_db.demo_schema to role sysadmin;

grant usage on warehouse compute_wh to role sysadmin;

GRANT SELECT ON ALL TABLES IN SCHEMA demo_db.demo_schema TO ROLE sysadmin;

-- GRANT PRIVILEGE "ANALYST"
use role securityadmin;

grant usage on database demo_db to role analyst;

grant usage,CREATE TABLE on schema demo_db.demo_schema to role analyst;

grant usage on warehouse compute_wh to role analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA demo_db.demo_schema TO ROLE analyst;

-- MASKING POLICY Applied
ALTER TABLE IF EXISTS user_data modify column mail_id set masking policy email_mask;

SELECT * from table(information_schema.policy_references(policy_name=>'email_mask'));

-- MASKING POLICY "UNSET"
alter table user_data modify mail_id unset masking policy; -- -> WORKING
ALTER TABLE user_data MODIFY COLUMN mail_id UNSET MASKING POLICY;

drop masking policy email_mask;
-- -----------------------------------------------------------------------------------------------------

-- select user_data table as "ACCOUNTADMIN"
use role accountadmin;
select * from user_data;

-- select user_data table as "SYSADMIN"
use role sysadmin;
select * from user_data;

-- select user_data table as "ANALYST"
use role analyst;
select * from user_data;