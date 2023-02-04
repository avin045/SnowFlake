--Lesson_4_Working_with_External_Unstructured_Data


/* 3 VIEWS 
1. SWEET SUIT SIZES VIEW -> zenas_athleisure_db.products.sweatsuit_sizes
2. SWEET BAND PRODUCT VIEW -> zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE
3. SWEET BAND COORDINATION VIEW -> zenas_athleisure_db.products.SWEATBAND_COORDINATION

STAGES AVAILABLE -> UNI_KLAUS_CLOTHING,UNI_KLAUS_SNEAKERS,UNI_KLAUS_ZMD
*/

-- STAGES
SHOW STAGES;

-- DATABASE
use database zenas_athleisure_db;
use schema products;

-- LIST STAGE
LIST @UNI_KLAUS_ZMD;

/* SELECT RECORDS FROM CLOTHING */
select $1
from @uni_klaus_clothing/90s_tracksuit.png;

/* 🥋 Query with 2 Built-In Meta-Data Columns */

select metadata$filename, metadata$file_row_number
from @uni_klaus_clothing/90s_tracksuit.png;

select metadata$filename,COUNT(metadata$filename)
from @uni_klaus_clothing
group by metadata$filename;

/* 🥋 Enabling, Refreshing and Querying Directory Tables  */
list @uni_klaus_clothing;

--Directory Tables
select * from directory(@uni_klaus_clothing);

-- Oh Yeah! We have to turn them on, first
alter stage uni_klaus_clothing 
set directory = (enable = true);

--Now?
select * from directory(@uni_klaus_clothing);

--Oh Yeah! Then we have to refresh the directory table!
alter stage uni_klaus_clothing refresh;

--Now?
select * from directory(@uni_klaus_clothing);

/* 🥋 Start By Checking Whether Functions will Work on Directory Tables  */

--testing UPPER and REPLACE functions on directory table
select UPPER(RELATIVE_PATH) as uppercase_filename
, REPLACE(uppercase_filename,'/') as no_slash_filename
, REPLACE(no_slash_filename,'_',' ') as no_underscores_filename
, REPLACE(no_underscores_filename,'.PNG') as just_words_filename
from directory(@uni_klaus_clothing);

-- COVERT THE ABOVE 4 column into 1 column
select REPLACE(
    REPLACE(
        REPLACE(UPPER(RELATIVE_PATH),'/'),'_',' '),
    '.PNG',
    ''
) as PRODUCT_NAME from directory(@uni_klaus_clothing);



/* 🥋 Create an Internal Table in the Zena Database */
--create an internal table for some sweat suit info
create or replace TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (
	COLOR_OR_STYLE VARCHAR(25),
	DIRECT_URL VARCHAR(200),
	PRICE NUMBER(5,2)
);

--fill the new table with some data
insert into  ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
          (COLOR_OR_STYLE, DIRECT_URL, PRICE)
values
('90s', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/90s_tracksuit.png',500)
,('Burgundy', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/forest_green_sweatsuit.png',65)
,('Navy Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/navy_blue_sweatsuit.png',65)
,('Orange', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/orange_sweatsuit.png',65)
,('Pink', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/pink_sweatsuit.png',65)
,('Purple', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/purple_sweatsuit.png',65)
,('Red', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/red_sweatsuit.png',65)
,('Royal Blue',	'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/royal_blue_sweatsuit.png',65)
,('Yellow', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/yellow_sweatsuit.png',65);


/* 🎯 Can You Join These? 
    ==> This challenge lab does not include step-by-step details. 
    Can you join the directory table and the new sweatsuits table ?
*/

/* EXTRACT COLOR_OR_STYLE[ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS] on directory(@uni_klaus_clothing)
select split(REPLACE(
    REPLACE(
        REPLACE(UPPER(RELATIVE_PATH),'/'),'_',' '),
    '.PNG',
    ''
),' ')[0] as PRODUCT_NAME from directory(@uni_klaus_clothing); 
*/

select 
color_or_style,
direct_url,
price,
size as image_size,
last_modified as image_last_modified
from directory(@uni_klaus_clothing) as dir_ukc
JOIN
ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS as zad_ps 
ON 
split(replace(lower(dir_ukc.RELATIVE_PATH),'/',''),'_')[0] = split(lower(zad_ps.COLOR_OR_STYLE),' ')[0];

-- ANOTHER QUERY FOR THE SAME PROBLEM
select color_or_style , direct_url , price , size as image_size , last_modified as image_last_modified 
from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
join 
directory(@uni_klaus_clothing) 
on split_part(DIRECT_URL,'/',-1)=split_part(relative_path,'/',-1);

-- SNOWFLAKE SOLUTION
select color_or_style , direct_url , price , size as image_size , last_modified as image_last_modified 
from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS s
join directory(@uni_klaus_clothing) d
on d.relative_path = SUBSTR(s.direct_url,54,50);

/* 📓  Adding a Cross Join */
-- 3 way join - internal table, directory table, and view based on external data

select color_or_style
, direct_url
, price
, size as image_size
, last_modified as image_last_modified
, sizes_available
from sweatsuits 
join directory(@uni_klaus_clothing) 
on relative_path = SUBSTR(direct_url,54,50)
cross join sweatsuit_sizes;

/* 🎯 Convert Your Select Statement to a View
===> Lay a view on top of the select above and call it catalog. 
Make sure the view is in Zena's database, in her Product schema, and is owned by the SYSADMIN role. 
*/
-- USE ROLE SYSADMIN;
CREATE or REPLACE view catalog as (
    select color_or_style
, direct_url
, price
, size as image_size
, last_modified as image_last_modified
, sizes_available
from sweatsuits 
join directory(@uni_klaus_clothing) 
on relative_path = SUBSTR(direct_url,54,50)
cross join sweatsuit_sizes
);

-- GRANT ACCESS for SYSADMIN'
grant select on view catalog to role sysadmin;

-- DROP VIEW catalog;

select COUNT(*) from zenas_athleisure_db.products.catalog;


-----------------------------------------------------------------------
-- DORA CHECK-UPs
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW03' as step
 ,(select count(*) from ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG) as actual
 ,198 as expected
 ,'Cross-joined view exists' as description
); 



--------------------------------------------------
/* 📓  Zena's Work So Far */
-- 🥋 Add the Upsell Table and Populate It

-- Add a table to map the sweat suits to the sweat band sets
create table ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE varchar(25)
,UPSELL_PRODUCT_CODE varchar(10)
);

--populate the upsell table
insert into ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE
,UPSELL_PRODUCT_CODE 
)
VALUES
('Charcoal Grey','SWT_GRY')
,('Forest Green','SWT_FGN')
,('Orange','SWT_ORG')
,('Pink', 'SWT_PNK')
,('Red','SWT_RED')
,('Yellow', 'SWT_YLW');

/* 🥋 Zena's View for the Athleisure Web Catalog Prototype */
-- Zena needs a single view she can query for her website prototype
create view catalog_for_website as 
select color_or_style
,price
,direct_url
,size_list
,coalesce('BONUS: ' ||  headband_description || ' & ' || wristband_description, 'Consider White, Black or Grey Sweat Accessories')  as upsell_product_desc
from
(   select color_or_style, price, direct_url, image_last_modified,image_size
    ,listagg(sizes_available, ' | ') within group (order by sizes_available) as size_list
    from catalog
    group by color_or_style, price, direct_url, image_last_modified, image_size
) c
left join upsell_mapping u
on u.sweatsuit_color_or_style = c.color_or_style
left join sweatband_coordination sc
on sc.product_code = u.upsell_product_code
left join sweatband_product_line spl
on spl.product_code = sc.product_code
where price < 200 -- high priced items like vintage sweatsuits aren't a good fit for this website
and image_size < 1000000 -- large images need to be processed to a smaller size
;

-- DORA CHECKUP
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW04' as step
 ,(select count(*) 
  from zenas_athleisure_db.products.catalog_for_website 
  where upsell_product_desc like '%NUS:%') as actual
 ,6 as expected
 ,'Relentlessly resourceful' as description
); 


