/*----------------D2_3 Hands-on----------------
1) Multi-cluster warehouse behaviour
2) Meaning of the MIN[/MAX]_CLUSTER_COUNT option
3) Meaning of the SCALING_POLICY option 
----------------------------------------------*/

-- Set context
USE ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE MULTI_CLUSTER_WAREHOUSE_STANDARD_XS 
WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE 
MIN_CLUSTER_COUNT = 1 
MAX_CLUSTER_COUNT = 4
SCALING_POLICY = 'STANDARD'; -- MAX_CLUSTER_COUNT = 11 -> Maximum number of clusters for warehouse 'MULTI_CLUSTER_WAREHOUSE_STANDARD_XS' exceeded, requested 11 and limit is 10.

SHOW WAREHOUSES LIKE 'MULTI%';

-- Set context
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE USER USER1 password='temp' default_role = SYSADMIN DEFAULT_WAREHOUSE=MULTI_CLUSTER_WAREHOUSE_STANDARD_XS;
GRANT ROLE SYSADMIN TO USER USER1;
CREATE OR REPLACE USER USER2 password='temp' default_role = SYSADMIN DEFAULT_WAREHOUSE=MULTI_CLUSTER_WAREHOUSE_STANDARD_XS;
GRANT ROLE SYSADMIN TO USER USER2;
CREATE OR REPLACE USER USER3 password='temp' default_role = SYSADMIN DEFAULT_WAREHOUSE=MULTI_CLUSTER_WAREHOUSE_STANDARD_XS;
GRANT ROLE SYSADMIN TO USER USER3;

DROP USER USER1;
DROP USER USER2;
DROP USER USER3;

DROP WAREHOUSE MULTI_CLUSTER_WAREHOUSE_STANDARD_XS;


------------------------------------------------------ OWN TRY ------------------------------------------------------

use database snowflake_sample_data;
use schema tpch_sf1000;

show tables;
CREATE RESOURCE MONITOR MULTI_CLUSTER_WAREHOUSE_STANDARD_XS WITH CREDIT_QUOTA = 1 
 TRIGGERS 
 ON 50 PERCENT DO NOTIFY
 ON 90 PERCENT DO SUSPEND 
 ON 100 PERCENT DO SUSPEND_IMMEDIATE;

select * from LINEITEM;



------------------------------------------------------ OWN TRY END ------------------------------------------------------