/*----------------D4_2 Hands-on----------------
1) Metadata Cache
2) Results Cache
3) Virtual Warehouse Local Storage
----------------------------------------------*/

-- Set context
USE ROLE SYSADMIN;

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000;

ALTER WAREHOUSE COMPUTE_WH SUSPEND;
ALTER WAREHOUSE SET AUTO_RESUME=FALSE;

-- Count all records

SELECT COUNT(*) FROM CUSTOMER;

-- Context Functions

SELECT CURRENT_USER();

-- Object descriptions

DESCRIBE TABLE CUSTOMER;

-- List objects

SHOW TABLES;

-- System functions 

SELECT SYSTEM$CLUSTERING_INFORMATION('LINEITEM', ('L_ORDERKEY'));

-- select L_ORDERKEY from lineitem limit 10;

SELECT * FROM CUSTOMER; -- Need a Warehouse is must to retrive the results from the table.


-- Results Cache

ALTER WAREHOUSE COMPUTE_WH RESUME IF SUSPENDED;
ALTER WAREHOUSE SET AUTO_RESUME=TRUE;

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000; -- FIRST TIME /* TIME TAKEN -> 1.4 seconds */

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000; -- 2nd TIME /* TIME TAKEN -> 72 milli seconds */

-- Syntactically different
SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_ACCTBAL FROM CUSTOMER LIMIT 1000000;

-- Includes functions evaluated at execution time
SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE, CURRENT_TIMESTAMP() FROM CUSTOMER LIMIT 1000000; -- 1st TIME /* TIME TAKEN -> 2.3 seconds */

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE, CURRENT_TIMESTAMP() FROM CUSTOMER LIMIT 1000000; /* 2nd time /* TIME TAKEN -> 1.2 seconds */ 
But Here the "QUERY RESULT REUSE [O]" not used, it's evaluating the each query for each time without get it from "RESULT CACHE".
In the Line 45,47 it uses the QUERY RESULT REUSE [O] from 45th line QUERY to 47th line QUERY
*/

USE ROLE ACCOUNTADMIN;

ALTER ACCOUNT SET USE_CACHED_RESULT = FALSE; -- Disable Result Cache

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000; /* same as LINE NO:47 BUT due to "USE_CACHED_RESULT = FALSE" it execute the query as new query not fetched from "RESULT CACHE" */

-- Local storage

SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000; -- 3.6s

SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000; -- 699ms


-- Additional column
SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE, O_CLERK, O_ORDERPRIORITY
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000; -- 97 ms

ALTER WAREHOUSE COMPUTE_WH SUSPEND;
ALTER WAREHOUSE COMPUTE_WH RESUME;

SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000; -- 2.9 s

ALTER ACCOUNT SET USE_CACHED_RESULT = TRUE;