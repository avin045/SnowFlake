/* --------------------------------------- INTERNAL STAGE --------------------------------------- */

-- 1. Create an internal stage in Snowflake:
CREATE TEMPORARY STAGE my_stage;

-- 2. Load data into the internal stage:
PUT file:///path/to/my/data.csv @my_stage;

-- 3. Copy the data from the internal stage into the table: 
COPY INTO my_table
FROM @my_stage/data.csv
FILE_FORMAT = (TYPE = CSV);

-- This command copies the data from the CSV file in the internal stage into the "my_table" table.

/* --------------------------------------- External Stage Example --------------------------------------- */
-- 1. Create an external stage in Snowflake:
CREATE STAGE my_s3_stage
  URL = 's3://my-bucket'
  CREDENTIALS = (AWS_KEY_ID = 'my_key_id' AWS_SECRET_KEY = 'my_secret_key');

-- 2. Load data into the external stage:
PUT file:///path/to/my/data.csv @my_s3_stage;

-- This command loads data from a CSV file located on a local file system into the external stage we created called "my_s3_stage", which is mapped to an AWS S3 bucket.

-- 3. Copy the data from the external stage into the table:
COPY INTO my_table
FROM @my_s3_stage/data.csv
FILE_FORMAT = (TYPE = CSV);
/* 
This command copies the data from the CSV file in the external stage into the "my_table" table.

In summary, both internal and external stages in Snowflake are temporary storage locations used to hold data that needs to be loaded into a table
within a Snowflake database. The difference is that internal stages are located within the database,
while external stages are located outside the database, often in cloud storage systems like AWS S3.
*/
