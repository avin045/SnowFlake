-- Lesson_3_Leaving_the_Data_Where_it_Lands

/* 🥋 Query Data in the ZMD */
select $1
from @uni_klaus_zmd; 

/* 🥋 Query Data in Just One File at a Time  */
/* FILE 1 -> product co-ordination*/
select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt;

/* FILE 2 -> SWEAT SUIT SIZE */
select $1
from @uni_klaus_zmd/sweatsuit_sizes.txt;
-- s3://uni-klaus/zenas_metadata/sweatsuit_sizes.txt

/* FILE 3 -> SWEET PRODUCT LINE */
select $1
from @uni_klaus_zmd/swt_product_line.txt;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

/* 🥋 Create an Exploratory File Format USING RECORD(ROW)_DELIMITER -- for FILE 1 */
create file format zmd_file_format_1
RECORD_DELIMITER = '^'; -- ROW DELIMITER

select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_1);

/* 🥋 Testing Our Second Theory USING FIELD(COLUMN)_DELIMITER*/
create file format zmd_file_format_2
FIELD_DELIMITER = '^';  

select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_2); -- results 1 ROW -> 10 COLUMNS;


/* 🥋 A Third Possibility? */
create file format zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^';

select $1, $2
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

/* FILE FORMAT FOR FILE 2 -> SWEAT SUIT SIZE */

create or replace file format zmd_file_format_1
RECORD_DELIMITER = ';'; -- ROW DELIMITER

select $1
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1);

/* FILE FORMAT FOR FILE 3 -> SWEET PRODUCT LINE */
create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = True /* TRIM_SPACE -> REMOVE THE spaces in columns */
;

select $1, $2, $3
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2); -- 9 COLUMNS

/* 🥋 Make the Sweatsuit Sizes Data Look Great! */

select REPLACE($1,chr(13)||char(10)) as "$1",$2,$3 
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);



select regexp_replace($1,'[[:space:]]','') as sizes_available /* REPLACE($1,chr(13)||char(10)) (Not Working) => regexp_replace($1,'[[:space:]]','') */
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available <> '';

/* 🥋 Convert Your Select to a View */

/* 1. SWEET SUIT SIZES VIEW */
create OR replace view zenas_athleisure_db.products.sweatsuit_sizes as (
    select regexp_replace($1,'[[:space:]]','') as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available <> ''
);

select * from zenas_athleisure_db.products.sweatsuit_sizes;

/* 🎯 Make the Sweatband Product Line File Look Great! */
create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = True /* TRIM_SPACE -> REMOVE THE spaces in columns */
;

select regexp_replace($1,'[[:space:]]','') as PRODUCT_CODE, $2 as HEADBAND_DESCRIPTION, $3 AS WRISTBAND_DESCRIPTION
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2); -- 9 COLUMNS

-- CREATE VIEW
/* 2. SWEET BAND PRODUCT VIEW */

CREATE or REPLACE view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as (
   select regexp_replace($1,'[[:space:]]','') as PRODUCT_CODE, $2 as HEADBAND_DESCRIPTION, $3 AS WRISTBAND_DESCRIPTION
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2)
);

select * from zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE;


/* 🎯 Make the Product Coordination Data Look Great! */
create or replace file format zmd_file_format_4
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'
TRIM_SPACE = True /* TRIM_SPACE -> REMOVE THE spaces in columns */
;

select regexp_replace($1,'[[:space:]]','') as $1,$2
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_4); -- 9 COLUMNS

/* ------ 3. SWEET BAND COORDINATION VIEW ------ */

create or replace view zenas_athleisure_db.products.SWEATBAND_COORDINATION as (
    select regexp_replace($1,'[[:space:]]','') as PRODUCT_CODE,$2 as HAS_MATCHING_SWEATSUIT
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_4)
);

select * from zenas_athleisure_db.products.SWEATBAND_COORDINATION;

/*
1. SWEET SUIT SIZES VIEW
2. SWEET BAND PRODUCT VIEW
3. SWEET BAND COORDINATION VIEW
*/

--------------------------------------------------------------------------------------
-- DORA CHECK-UP
USE ROLE ACCOUNTADMIN;

USE DATABASE DEMO_DB;

select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
   'DLKW02' as step
   ,(select sum(tally) from
        (select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
        where length(product_code) > 7 
        union
        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
        where LEFT(sizes_available,2) = char(13)||char(10))     
     ) as actual
   ,0 as expected
   ,'Leave data where it lands.' as description
); 