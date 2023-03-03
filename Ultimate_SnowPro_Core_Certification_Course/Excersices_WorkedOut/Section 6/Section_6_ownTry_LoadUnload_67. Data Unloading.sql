use role accountadmin;

create or replace database loadUnload;
create or replace schema load_unload;

-- Grant read-write permissions on database FIN to db_fin_rw role.
GRANT USAGE ON DATABASE loadUnload TO ROLE sysadmin;
GRANT CREATE SEQUENCE,CREATE STAGE,create file format,create table,USAGE ON ALL SCHEMAS IN DATABASE loadUnload TO ROLE sysadmin; -- sequence is a schema level object
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN DATABASE loadUnload TO ROLE sysadmin;


use role sysadmin;

create or replace sequence index_seq
start = 1
increment = 1;

-------------------------------------------------------------------------------------------------------------------
/* DATA LOADING */

create or replace stage snowflake_learning
url = 's3://snowflake-training-udemy-1/'
 CREDENTIALS=(
    AWS_KEY_ID='AKIAU26WV6SJPMDFH5UZ'
    AWS_SECRET_KEY='sYDMxgfRvsCmltq/CypLXmiWIYaigh9p2M2jUBXC'
  );

list @snowflake_learning;

create or replace file format csv_format
type = 'csv'
skip_header = 1
field_delimiter = ','
RECORD_DELIMITER = '\r\n' /* \r => carriage return */
FIELD_OPTIONALLY_ENCLOSED_BY='"'
-- error_on_column_count_mismatch = false
;

-- QUERY THE STAGE
select $1,$2,$3,$4,$5,$6,$7 from @snowflake_learning/loading_unloading/snowflake_movie_data_unload.csv
(file_format => csv_format);


create or replace table film_details_aws(
id int default index_seq.nextval, /* nextval('index_seq') */
movie_name varchar,
imdb_rating float,
protoganist varchar,
director varchar,
year int,
genre varchar,
imdb_redirect_link varchar null,
time_record timestamp default current_timestamp()
);

create or replace table film_details_aws1(
movie_name varchar,
imdb_rating float,
protoganist varchar,
director varchar,
year int,
genre varchar,
imdb_redirect_link varchar
);

desc table film_details_aws;


-- COPY DATA from STAGED CSV FILE into a TABLE "film_details_aws"
copy into film_details_aws(movie_name,imdb_rating,protoganist,director,year,genre,imdb_redirect_link)
from @snowflake_learning/loading_unloading/
FILES = ('snowflake_movie_data_unload.csv')
FILE_FORMAT = csv_format
ON_ERROR = 'abort_statement'
;

copy into film_details_aws1 
from @snowflake_learning/loading_unloading/
FILES = ('snowflake_movie_data_unload.csv')
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE'
;

SELECT * FROM film_details_aws;
SELECT * FROM film_details_aws1;

select * from table(validate(film_details_aws,job_id=>'01aa8f93-3200-aa51-0003-41ba000690ee'));
select * from table(validate(film_details_aws1,job_id=>'01aa8f86-3200-aa50-0003-41ba0006810e'));

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
/* UNLOADING */

-- COPY TO "snowflake table" to "CSV IN AWS S3"
copy into @snowflake_learning/loading_unloading/snowflake_movie_data_unloading_with_timestamp.csv
from loadunload.load_unload.film_details_aws; -- STORED AS "GZ" Format.

copy into 
@snowflake_learning/loading_unloading/snowflake_movie_data_unloading_with_timestamp.csv
from 
loadunload.load_unload.film_details_aws
file_format = csv_format; -- STORED AS "GZ" Format.

/* 
snowflake always compress the csv files as "GZ" Format
*/

-- JUST TRY with 3 COLUMNS
select $1,$2,$3 from 
@snowflake_learning/loading_unloading/snowflake_movie_data_unloading_with_timestamp.csv
(file_format => csv_format);

/* WITH ALL COLUMNS */
select $1,$2,$3,
$4,$5,$6,
$7,$8,$9
from 
@snowflake_learning/loading_unloading/snowflake_movie_data_unloading_with_timestamp.csv
(file_format => csv_format);



list @snowflake_learning;


-------------------------------------------------------------------------------------------------------------------