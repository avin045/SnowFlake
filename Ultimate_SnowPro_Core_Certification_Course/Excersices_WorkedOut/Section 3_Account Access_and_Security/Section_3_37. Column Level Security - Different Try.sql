create database cls;

create schema cls_schema;

create or replace table employee(
mail_id varchar,
emp_no int
);

insert into employee values ('employee123@gmail.com',789456);

create or replace masking policy STRING_MASK as (val string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then val
    else '*********'
  end;

alter table if exists EMPLOYEE modify column mail_id set masking policy STRING_MASK;

select * from table(information_schema.policy_references(policy_name=>'STRING_MASK'));

alter table if exists EMPLOYEE modify column MAIL_ID unset masking policy;
-- ALTER TABLE EMPLOYEE MODIFY MAIL_ID UNSET MASKING POLICY; -> NOT WORKING

show masking policies;

drop masking policy STRING_MASK;

SELECT GET_DDL('POLICY','STRING_MASK');