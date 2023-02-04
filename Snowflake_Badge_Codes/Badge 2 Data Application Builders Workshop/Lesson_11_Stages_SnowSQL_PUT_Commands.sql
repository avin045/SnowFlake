-- Lesson_11_Stages_SnowSQL_PUT_Commands

show stages in account; -- CHECKING for 'MY_INTERNAL_NAMED_STAGE'

/*
AVINSF1#(no warehouse)@(no database).(no schema)>put file://my_file.txt @demo_db.PUBLIC.my_internal_named_stage;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| my_file.txt | my_file.txt.gz |           7 |          48 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.975s
AVINSF1#(no warehouse)@(no database).(no schema)>
*/
-- LIST INTERNAL STAGE

list @my_internal_named_stage;

select $1 from @my_internal_named_stage/my_file.txt.gz;


-- DORA CHECKUP FOR FILES
-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW06' as step
 ,(select count(distinct METADATA$FILENAME) 
   from @demo_db.public.my_internal_named_stage) as actual
 , 3 as expected
 ,'I PUT 3 files!' as description
);