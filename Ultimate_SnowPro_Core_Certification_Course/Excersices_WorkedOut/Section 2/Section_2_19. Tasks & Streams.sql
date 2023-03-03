use database demo_db;
use schema demo_schema;

-- -------------------------------------------------------
create task t1
warehouse = COMPUTE_WH
SCHEDULE = '1 MINUTE'
as 
SELECT * FROM T_CHERRY_CREEK_TRAIL;

-- show tables in demo_schema;
-- DESCRIBE THE TASK
describe task t1;

-- RESEUME THE TASK
alter task t1 resume;

-- SUSPEND(pause) THE TASK
alter task t1 suspend;

-----------------------------------------------------------------------------------

-- USING SEQUENCE FOR PRIMARY KEY
create sequence primary_key_generator_for_stream_work
start = 1001
increment = 1;

-- TABLE FOR STREAM
create or replace table stream_work_tbl(
id int default primary_key_generator_for_stream_work.nextval,
movie_name varchar,
year integer,
best_character_name varchar
);

insert into stream_work_tbl(movie_name,year,best_character_name) 
values
('Iron man',2008,'Tony Stark'),
('The Incredible Hulk',2008,'Bruce banner'),
('Captain America: The First Avenger',2000,'Steve Rogers');

select * from stream_work_tbl;

-- CREATING(set) STREAM ON A TABLE
create or replace stream stream_for_stream_work_tbl on table stream_work_tbl;

UPDATE stream_work_tbl set year = 2011 where best_character_name = 'Steve Rogers';

insert into stream_work_tbl(movie_name,year,best_character_name) 
values
('Hawkeye',2021,'Clint Barton'),('Kavalan',2011,'vijay');

delete from stream_work_tbl where best_character_name = 'vijay';

-- Query the STREAM
select * from stream_for_stream_work_tbl;

-- Describe the Stream object
desc stream stream_for_stream_work_tbl;

-- COPY for stream output
create or replace table stream_for_stream_work_tbl_output as select * from stream_for_stream_work_tbl;

-- show the records backup of stream
select * from stream_for_stream_work_tbl_output; -- deleted 'vijay' not visible in "STREAM"

show tables;