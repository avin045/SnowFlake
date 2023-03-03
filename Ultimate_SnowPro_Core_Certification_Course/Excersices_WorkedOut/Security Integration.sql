use database demo_db;
use schema demo_schema;

create or replace security integration oauth_KB_1
    type=oauth
    enabled=true
    oauth_client=CUSTOM
    oauth_client_type='CONFIDENTIAL'
    oauth_redirect_uri= 'https://oauth.pstman.io/v1/browser-callback'
    oauth_issue_refresh_tokens=true
    oauth_refresh_token_validity=86400;

create or replace security integration oauth_KB
    type=oauth
    enabled=true
    oauth_client=CUSTOM
    oauth_client_type='PUBLIC'
    oauth_redirect_uri='https://localhost.com';
    
    
select SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('OAUTH_KB');

describe security integration oauth_KB;
/*
{"OAUTH_CLIENT_SECRET_2":"YrnykJwMhvLQ0Dak/5Q+cj639gzOB+a8Im0xhWLXt04=",
"OAUTH_CLIENT_SECRET":"WJY2sQqOfHomFQrZBGvpgJA3mcaca3kxiWKUoQ1CBEI=",
"OAUTH_CLIENT_ID":"PVzruGYePXXWsQ3ErtgFvzcAy4U="}
*/

-- https://<your-account>.snowflakecomputing.com/oauth/authorize?response_type=code&client_id=<your-client-id>&redirect_uri=<your-redirect-uri>
https://tj40347.snowflakecomputing.com/oauth/authorize?response_type=code&client_id=zMnUA57Jj+Zn3oIIE/VA6qw1Mjs=&redirect_uri=https://localhost.com
