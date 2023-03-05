use database demo_db;
use schema demo_schema;

create or replace stage direc_tables_stage
url = 's3://snowflake-training-udemy-1/'
CREDENTIALS = (AWS_KEY_ID='AKIAU26WV6SJPMDFH5UZ' AWS_SECRET_KEY='sYDMxgfRvsCmltq/CypLXmiWIYaigh9p2M2jUBXC')
directory = (ENABLE=TRUE);

-- alter stage direc_tables_stage set directory = (enable=true);

select * from directory(@direc_tables_stage);

/* REFRESH TO SEE THE NEW UPLOADED DATA In "AWS" => For both "INTERNAL" and "EXTERNAL" tables*/

alter stage direc_tables_stage refresh; -- data_transformation/SSH+in+Snowflake..pdf

/* USING "SQS service" method in the field directory_notification_channel */

/* SYNTAX
CREATE STAGE EXT STAGE
DIRECTORY = (ENABLE -
*/
alter stage direc_tables_stage set directory = (enable=true);

desc stage direc_tables_stage;