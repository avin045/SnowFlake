/* USE ACCOUNTADMIN or SECURITYADMIN --> federated authentication */
use role accountadmin;

-- Show Parameters
-- show parameters like 'SAML_IDENTITY_PROVIDER';
show parameters like 'SAML_IDENTITY_PROVIDER';
/* SAML -> https://docs.snowflake.com/en/user-guide/admin-security-fed-auth-configure-snowflake */

alter account set saml_identity_provider = '{
  "certificate": "MIIDqjCCApKgAwIBAgIGAYbbxpO3MA0GCSqGSIb3DQEBCwUAMIGVMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxFjAUBgNVBAMMDXRyaWFsLTI2MTYyOTIxHDAaBgkqhkiG9w0B CQEWDWluZm9Ab2t0YS5jb20wHhcNMjMwMzEzMTYyMDA5WhcNMzMwMzEzMTYyMTA5WjCBlTELMAkG A1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTAL BgNVBAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRYwFAYDVQQDDA10cmlhbC0yNjE2Mjky MRwwGgYJKoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB CgKCAQEA0T3MgAIEbZ72jwV8DXJrenbmGwIJv596m6ZR3Qqo57m8uH5rh+3W+XebWkUOwq0DP04w Iw/TBTEZEnNxzwxATMLyOcF5VSLjtrTukWr07tjL4nIKEg9/CX8FawU2OVQ5IIyoDOTvrENXgIyD oevbRcaFZn0rs/I9DPtH5M/o4q47ioEuN0sDgeT0YGXnjjTur2dnwUdSgnq0ygrmNjm/+SqNsYq6 oxQgZiP1xpjeSKb797wVzVGJaJstlrRNameoTt0UC2p2uNODMuAqt0soelrdKYNVvhYkk6l6fdtt GBNJ5nSYnHwp4L0v06YkITj/47lHSH/UT0nFNA9QRuRwBQIDAQABMA0GCSqGSIb3DQEBCwUAA4IB AQANDLSGo0743A0L3stkVxrhG+9PvrZXyIMOIflYugxD3Z6pgxRMxsPYr+UlSEmYNAPweQlgGnBK MnIkEVTLKZKV+m6a9t2cLSuzduHa2eDxfO7thcZHwlmheFNm8cZ77L1ItMg4ZFiWMyVUUhUP0kV/ AsiHfJrK+ab0LgN7kQDejSCPZA6+RaYKRlCO+L/AhPM9mIb/9MfHr8mJDyJwVI6hNjz0LJw6ezgX BE6IZhMNsoJ5zQ69WUiF3pLqGhDbKPm8qj36UpGlQ/JtS4iEdMhVu7CWrPz38eASyfJqplePF9Qs ilnNU8qWfG4hCHC+wrxWEDNb8r/S0STZqWLe///C",
  "issuer": "http://www.okta.com/exk4it5tqr2OoCijK697",
  "ssoUrl": "https://trial-2616292.okta.com/app/snowflake/exk4it5tqr2OoCijK697/sso/saml",
  "type"  : "OKTA",
  "label" : "OKTASingleSignOn"
}';

-- Enable SSO at Account Level
use role accountadmin;
alter account set sso_login_page = true;

-- Create Security Integration
drop security integration oktaintegration;

CREATE SECURITY INTEGRATION OKTAINTEGRATION
    TYPE = SAML2
    ENABLED = TRUE 
    SAML2_ISSUER ='http://www.okta.com/exk4it5tqr2OoCijK697'
    SAML2_SSO_URL ='https://trial-2616292.okta.com/app/snowflake/exk4it5tqr2OoCijK697/sso/saml'
    SAML2_PROVIDER = OKTA
    SAML2_X509_CERT = 'MIIDqjCCApKgAwIBAgIGAYbbxpO3MA0GCSqGSIb3DQEBCwUAMIGVMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxFjAUBgNVBAMMDXRyaWFsLTI2MTYyOTIxHDAaBgkqhkiG9w0B CQEWDWluZm9Ab2t0YS5jb20wHhcNMjMwMzEzMTYyMDA5WhcNMzMwMzEzMTYyMTA5WjCBlTELMAkG A1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTAL BgNVBAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRYwFAYDVQQDDA10cmlhbC0yNjE2Mjky MRwwGgYJKoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB CgKCAQEA0T3MgAIEbZ72jwV8DXJrenbmGwIJv596m6ZR3Qqo57m8uH5rh+3W+XebWkUOwq0DP04w Iw/TBTEZEnNxzwxATMLyOcF5VSLjtrTukWr07tjL4nIKEg9/CX8FawU2OVQ5IIyoDOTvrENXgIyD oevbRcaFZn0rs/I9DPtH5M/o4q47ioEuN0sDgeT0YGXnjjTur2dnwUdSgnq0ygrmNjm/+SqNsYq6 oxQgZiP1xpjeSKb797wVzVGJaJstlrRNameoTt0UC2p2uNODMuAqt0soelrdKYNVvhYkk6l6fdtt GBNJ5nSYnHwp4L0v06YkITj/47lHSH/UT0nFNA9QRuRwBQIDAQABMA0GCSqGSIb3DQEBCwUAA4IB AQANDLSGo0743A0L3stkVxrhG+9PvrZXyIMOIflYugxD3Z6pgxRMxsPYr+UlSEmYNAPweQlgGnBK MnIkEVTLKZKV+m6a9t2cLSuzduHa2eDxfO7thcZHwlmheFNm8cZ77L1ItMg4ZFiWMyVUUhUP0kV/ AsiHfJrK+ab0LgN7kQDejSCPZA6+RaYKRlCO+L/AhPM9mIb/9MfHr8mJDyJwVI6hNjz0LJw6ezgX BE6IZhMNsoJ5zQ69WUiF3pLqGhDbKPm8qj36UpGlQ/JtS4iEdMhVu7CWrPz38eASyfJqplePF9Qs ilnNU8qWfG4hCHC+wrxWEDNb8r/S0STZqWLe///C'
    SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = 'OKTA SSO'
    SAML2_ENABLE_SP_INITIATED = TRUE;

/* Setup SAML ACS and Issuer URL */

-- use role accountadmin;
alter security integration OKTAINTEGRATION set saml2_snowflake_acs_url = 'https://mw57430.ap-southeast-1.snowflakecomputing.com/fed/login';
alter security integration OKTAINTEGRATION set saml2_snowflake_issuer_url = 'https://mw57430.ap-southeast-1.snowflakecomputing.com';

/* MODIFY login_name same as "OKTA" -> username */
alter user avinsf4 set login_name = 'avinash.sekar@wavicledata.com';