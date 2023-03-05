/*----------------D2_1 Hands-on----------------
1) Virtual warehouse creation
2) Virtual warehouse sizes
3) Virtual warehouse state properties
4) Virtual warehouse behaviour
----------------------------------------------*/

-- Set context
USE ROLE SYSADMIN;

-- Create data loading analysis warehouse
create warehouse DATA_ANALYSIS_WAREHOUSE
WAREHOUSE_SIZE = 'SMALL'
auto_suspend = 600 -- 10 mins /* if warehouse IDLE for 10 mins it'll suspend */
auto_resume = TRUE -- when user runs the query after 10 mins automatically warehouse will be started
INITIALLY_SUSPENDED=TRUE;

-- Set context
USE WAREHOUSE  DATA_ANALYSIS_WAREHOUSE;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000;

-- Manually resume virtual warehouse
alter warehouse data_analysis_warehouse resume;

-- Show state of virtual warehouse
SHOW WAREHOUSES LIKE 'DATA_ANALYSIS_WAREHOUSE';

-- Manually suspend virtual warehouse
ALTER WAREHOUSE DATA_ANALYSIS_WAREHOUSE SUSPEND;

SHOW WAREHOUSES LIKE 'DATA_ANALYSIS_WAREHOUSE';

SELECT 
C_CUSTKEY, 
C_NAME, 
C_ADDRESS, 
C_NATIONKEY, 
C_PHONE FROM CUSTOMER LIMIT 300;

SHOW WAREHOUSES LIKE 'DATA_ANALYSIS_WAREHOUSE';

-- Set configurations on-the-fly
alter warehouse data_analysis_warehouse set warehouse_size = LARGE;

ALTER WAREHOUSE DATA_ANALYSIS_WAREHOUSE SET AUTO_SUSPEND=300;

ALTER WAREHOUSE DATA_ANALYSIS_WAREHOUSE SET AUTO_RESUME=FALSE;

SHOW WAREHOUSES LIKE 'DATA_ANALYSIS_WAREHOUSE';
SELECT "name", "state", "size", "auto_suspend", "auto_resume" FROM TABLE(result_scan(last_query_id()));
