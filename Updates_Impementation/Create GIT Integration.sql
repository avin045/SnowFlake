use database employee_db_dev;
use schema REPORTS;

create or replace SECRET git_secret
    TYPE = password
    USERNAME = 'avin045'
    PASSWORD = 'ghp_token'; -- PAT (Personal Access Token - Generated from Github)

create or replace api integration git_api_integration
    api_provider = git_https_api
    api_allowed_prefixes = ('https://github.com/avin045/Snowflake-Synthetic-data.git')
    enabled = true
    allowed_authentication_secrets = (git_secret);
    -- comment='<comment>';

CREATE OR REPLACE GIT REPOSITORY REPORTS."Snowflake-Synthetic-GI"
  API_INTEGRATION = git_api_integration
  GIT_CREDENTIALS = git_secret
  ORIGIN = 'https://github.com/avin045/Snowflake-Synthetic-data.git';


/* GIT Commands */
ALTER GIT REPOSITORY "Snowflake-Synthetic-GI" FETCH;

DESCRIBE GIT REPOSITORY "Snowflake-Synthetic-GI";

SHOW GIT REPOSITORIES IN DATABASE EMPLOYEE_DB_DEV;

SHOW GIT BRANCHES IN "Snowflake-Synthetic-GI";


-- ----------------------------------------
-- in PUBLIC SCHEMA

use database employee_db_dev;
create or replace api integration github_sample_integration
    api_provider = git_https_api
    api_allowed_prefixes = ('https://github.com/avin045/SnowFlake/')
    enabled = true;
    -- allowed_authentication_secrets = all
    -- comment='<comment>';

CREATE OR REPLACE GIT REPOSITORY git_sample
  API_INTEGRATION = github_sample_integration
  -- GIT_CREDENTIALS = my_secret if needed
  ORIGIN = 'https://github.com/avin045/SnowFlake';


ls @git_sample/branches/main;


-- ----------------------------------------
