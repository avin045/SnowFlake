/* FILE FUNCTIONS */

use role accountadmin;
use database demo_db;
use schema demo_schema;
use warehouse compute_wh;
/*
1. BUILD_SCOPED_FILE_URL
2. BUILD_STAGE_FILE_URL
3. GET_PRESIGNED_URL
*/

/* 1. BUILD_SCOPED_FILE_URL */

-- user stage => @~ 
-- Table stage => @%
-- Named Stage => @my_stage

-- CREATING STAGE
create or replace stage images_stage;

alter stage images_stage set directory = (enable=true);

select * from directory(@images_stage);

list @images_stage; 

-- drop stage image_stage;

-- put file://image.jpg @images_stage

--  GET PRESIGNED URL
select get_presigned_url(@images_stage,'the-imitation-game');
/*OUTPUT:
https://sfc-sg-ds1-35-customer-stage.s3.ap-southeast-1.amazonaws.com/ilf40000-s/stages/c166e87a-67e7-44b7-a092-316eb18c3145/the-imitation-game?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230301T090122Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=AKIARKR2GT63W5JZMRWV%2F20230301%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=2f27c34a248e80aee974a7d73af4f40d9b01b30bd67aff60047dbf644fbf65de

*/
----------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. BUILD_SCOPED_FILE_URL ==> Valid for 24hrs

-- build_scoped_file_url(@<stage_name>,<'relative_file_path'>)

select build_scoped_file_url(@images_stage,'the-imitation-game.jpg'); 
/* OUTPUT
https://tj40347.ap-southeast-1.snowflakecomputing.com/api/files/01aaa6c4-3200-aac5-0003-41ba0008816a/916692050010118/pe%2fWVpLlaFGxyM0XbmUPeiuJlNAiRBkaKVBpFK9OvgJIV%2fLzCFNp7cnNG1jMl6YJJvci9Hry6%2fbTPI7%2bqz29TAZ96%2b%2fDbTXln%2fPGU8pQ7%2bWqEbyo9YZ%2b9vK6ZhCmpOahxM43K4JiImLTrBuznDvO6scqb6opKHKFMysD82spMdtBdDR9cJiFjGOtrgV17ephGTByIdUWoYoJgybsIvIaBBqawN84kKfYSMFSpYA%3d
*/

-- CREATE A VIEW WITH THIS
create view imitation_game as select build_scoped_file_url(@images_stage,'the-imitation-game.jpg') as file_url;

select * from imitation_game;

/* 2. BUILD_STAGE_FILE_URL => The URL does not Expire */

-- SYNTAX => build_stage_file_url(@<stage_name>,'<relative_path>')

select build_stage_file_url(@images_stage,'the-imitation-game.jpg');

/* OUTPUT
https://tj40347.ap-southeast-1.snowflakecomputing.com/api/files/DEMO_DB/DEMO_SCHEMA/IMAGES_STAGE/the-imitation-game%2ejpg
*/

alter stage images_stage set encryption = (type='SNOWFLAKE_SSE'); -- SERVER SIDE ENCRYPTION only for External Stages

/* 3. GET PRESIGNED URL */
select get_presigned_url(@images_stage,'the-imitation-game',60); -- 60 seconds
/*
https://sfc-sg-ds1-35-customer-stage.s3.ap-southeast-1.amazonaws.com/ilf40000-s/stages/c166e87a-67e7-44b7-a092-316eb18c3145/the-imitation-game?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230301T094714Z&X-Amz-SignedHeaders=host&X-Amz-Expires=59&X-Amz-Credential=AKIARKR2GT63W5JZMRWV%2F20230301%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=e628c5a2979d35159736428edd7006131bc182a7c71f4975104ea245c7071b67
*/

----------------------------------------------------------------------------------------------------------------------------------------------------

/* WITH EXTERNAL STAGE */
create or replace stage images_external_stage
url = 's3://snowflake-training-udemy-1/data_transformation/'
CREDENTIALS = (AWS_KEY_ID='AKIAU26WV6SJPMDFH5UZ' AWS_SECRET_KEY='sYDMxgfRvsCmltq/CypLXmiWIYaigh9p2M2jUBXC');

select build_scoped_file_url(@images_external_stage,'the-imitation-game.jpg'); -- with in 24 hrs

select build_stage_file_url(@images_external_stage,'the-imitation-game.jpg'); -- not a time limit
/*
https://tj40347.ap-southeast-1.snowflakecomputing.com/api/files/DEMO_DB/DEMO_SCHEMA/IMAGES_EXTERNAL_STAGE/the-imitation-game%2ejpg
*/

-- alter stage images_external_stage set encryption = (type='SNOWFLAKE_SSE');

select get_presigned_url(@images_external_stage,'the-imitation-game.jpg',60); -- 60 seconds -- WORKING
/*
https://snowflake-training-udemy-1.s3.amazonaws.com/data_transformation/the-imitation-game.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230301T101538Z&X-Amz-SignedHeaders=host&X-Amz-Expires=58&X-Amz-Credential=AKIAU26WV6SJPMDFH5UZ%2F20230301%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=6e298f35acf6f8f4f0e93579537f015cd1a7489c3709afdb8509c11b3c885f46
*/