-- Lesson_1_Getting_Set_Up_🥋_Set_Up_Your_Trial_Account

show users;

alter user AVINSF1 set default_role = 'SYSADMIN';
alter user AVINSF1 set default_warehouse = 'COMPUTE_WH';
alter user AVINSF1 set default_namespace = 'DEMO_DB.PUBLIC';

/* 🤖 Is DORA Working? Run This to Find Out! */
use role accountadmin;

select demo_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from
(SELECT 
 'DORA_IS_WORKING' as step
 ,(select 123 ) as actual
 ,123 as expected
 ,'Dora is working!' as description
); 