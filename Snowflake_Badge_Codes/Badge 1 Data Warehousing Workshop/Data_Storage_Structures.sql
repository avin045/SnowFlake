use role sysadmin; -- The worksheet's role can only be set from the folder

// Create a new database and set the context to use the new database
CREATE DATABASE LIBRARY_CARD_CATALOG COMMENT = 'DWW Lesson 9 ';
USE DATABASE LIBRARY_CARD_CATALOG;

// Create and Author table
CREATE OR REPLACE TABLE AUTHOR (
   AUTHOR_UID NUMBER 
  ,FIRST_NAME VARCHAR(50)
  ,MIDDLE_NAME VARCHAR(50)
  ,LAST_NAME VARCHAR(50)
);

// Insert the first two authors into the Author table
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
Values
(1, 'Fiona', '','Macdonald')
,(2, 'Gian','Paulo','Faleschini');

// Look at your table with it's new rows
SELECT * 
FROM AUTHOR;

-- --------------------------------------------------------------------------

-- Create a Sequence 
CREATE sequence SEQ_AUTHOR_UID
    START = 1
    INCREMENT = 1
    COMMENT = "Use this to fill in AUTHOR_UID";
    
DROP SEQUENCE SEQ_AUTHOR_ID;

select * from AUTHOR;-- LIBRARY_CARD_CATALOG.PUBLIC;


-- Query the Sequence
use role sysadmin;

//See how the nextval function works
SELECT SEQ_AUTHOR_UID.nextval;

-- Use the Sequence By Querying It
select SEQ_AUTHOR_UID.nextval,SEQ_AUTHOR_UID.nextval;

-- SHOW SEQUENCE
show sequences;

-- INSERTING with UID with nextval
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
values (SEQ_AUTHOR_UID.nextval,'David',NULL,'Billa');
-- delete from AUTHOR where LAST_NAME = 'Billa';
--  Recreate the Sequence with a Different Starting Value

use role sysadmin;

//Drop and recreate the counter (sequence) so that it starts at 3 
// then we'll add the other author records to our author table
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_AUTHOR_UID" 
START 3 
INCREMENT 1 
COMMENT = 'Use this to fill in the AUTHOR_UID every time you add a row';


//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
Values
(SEQ_AUTHOR_UID.nextval, 'Laura', 'K','Egendorf')
,(SEQ_AUTHOR_UID.nextval, 'Jan', '','Grover')
,(SEQ_AUTHOR_UID.nextval, 'Jennifer', '','Clapp')
,(SEQ_AUTHOR_UID.nextval, 'Kathleen', '','Petelinsek');

SELECT * FROM AUTHOR;

-- ----------------------------------------------------------------------------------------
--  Create a 2nd Counter, a Book Table, and a Mapping Table

USE DATABASE LIBRARY_CARD_CATALOG;

-- CREATE A NEW SEQUENCE , THIS WILL BE THE COUNTER FOR THE BOOK TABLE:
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_BOOK_ID"
START 1
INCREMENT 1
COMMENT = 'Use this to fill in the BOOK_UID everytime you add a row';

// Create the book table and use the NEXTVAL as the 
// default value each time a row is added to the table
CREATE OR REPLACE TABLE book (
    BOOK_UID number DEFAULT SEQ_BOOK_ID.nextval,
    TITLE VARCHAR(50),
    YEAR_PUBLISHED number(4,0)
);

-- INSERTING VALUES INTO TABLE book
// You don't have to list anything for the
// BOOK_UID field because the default setting
// will take care of it for you
INSERT INTO BOOK(TITLE,YEAR_PUBLISHED)
VALUES
 ('Food',2001)
,('Food',2006)
,('Food',2008)
,('Food',2016)
,('Food',2015);

select * from "BOOK"; -- BOTH WORKS
select * from book;

-- -------------------------------------------------------------------------------------

// Create the relationships table
// this is sometimes called a "Many-to-Many table"
CREATE TABLE BOOK_TO_AUTHOR
(  BOOK_UID NUMBER
  ,AUTHOR_UID NUMBER
);

//Insert rows of the known relationships
INSERT INTO BOOK_TO_AUTHOR(BOOK_UID,AUTHOR_UID)
VALUES
 (1,1) // This row links the 2001 book to Fiona Macdonald
,(1,2) // This row links the 2001 book to Gian Paulo Faleschini
,(2,3) // Links 2006 book to Laura K Egendorf
,(3,4) // Links 2008 book to Jan Grover
,(4,5) // Links 2016 book to Jennifer Clapp
,(5,6);// Links 2015 book to Kathleen Petelinsek

select * from "BOOK_TO_AUTHOR";
-- SELECT * from book_to_author;

-- TABLES TO JOIN
DESC TABLE AUTHOR;
select * from AUTHOR;
DESC TABLE BOOK;
select * from BOOK;
DESC TABLE BOOK_TO_AUTHOR;
select * from BOOK_TO_AUTHOR;

-- JOINING 3 TABLES
select * from
AUTHOR JOIN BOOK_TO_AUTHOR 
ON author.author_uid = book_to_author.author_uid
JOIN BOOK ON book_to_author.book_uid = book.book_uid;

-- DORA CHECKS
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
show external functions;

-- Set your worksheet drop lists
-- DO NOT EDIT THE CODE 
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
     SELECT 'DWW15' as step 
     ,(select count(*) 
      from LIBRARY_CARD_CATALOG.PUBLIC.Book_to_Author ba 
      join LIBRARY_CARD_CATALOG.PUBLIC.author a 
      on ba.author_uid = a.author_uid 
      join LIBRARY_CARD_CATALOG.PUBLIC.book b 
      on b.book_uid=ba.book_uid) as actual 
     , 6 as expected 
     , '3NF DB was Created.' as description  
); 