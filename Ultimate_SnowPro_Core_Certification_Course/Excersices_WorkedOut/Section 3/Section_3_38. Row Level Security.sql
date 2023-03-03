/*
LINKS :
https://thinketl.com/row-level-security-using-row-access-policies-in-snowflake/
*/

insert into user_data values('vignesh@gmail.com','88 vivekandha street',600122),
('jithan@gmail.com','88th vivekandha street',600122),
('suresh@gmail.com','81st street',600121),
('ramesh123@gmail.com','001 kunjan street',600101),
('tyon899@gmail.com','905 ninety ml street',612122)
;

-- ROW ACCESS POLICY
create or replace row access policy rap_id as (mail_id varchar) returns BOOLEAN -> 
CASE
	WHEN 'ACCOUNTADMIN' = CURRENT_ROLE() THEN TRUE
    ELSE FALSE
END;

ALTER TABLE user_data ADD ROW ACCESS POLICY rap_id on (mail_id);

-- DROP ROW ACCESS POLICY
alter table user_data drop row access policy rap_id;

-- The below SQL statement removes all row access policy associations from a table.
-- alter table <table name> drop all row access policies;

-- USE ROLE AS "ACCOUNTADMIN"
use role accountadmin;
select * from user_data;

-- USE ROLE AS others like "ANALYST"
use role analyst;
select * from user_data;