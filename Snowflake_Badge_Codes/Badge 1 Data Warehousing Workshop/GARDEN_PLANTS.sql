show tables;
-- DESC table ROOT_DEPTH;

create table vegetable_details(
    plant_names varchar(25),
    root_depth_code varchar(1)
);

-- DESCRIBE TABLE
DESC TABLE vegetable_details;

-- ALTER COLUMN NAME from `plant_names` TO `plant_name`
ALTER TABLE vegetable_details RENAME COLUMN plant_names to plant_name;

-- AFTER CSV LOAD (View Data)
select * from GARDEN_PLANTS.VEGGIES.vegetable_details;
-- select COUNT(*) from GARDEN_PLANTS.VEGGIES.vegetable_details;

-- TRUNCATE
-- TRUNCATE TABLE GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;

--  CREATE TWO FILE FORMATS
create file format GARDEN_PLANTS.VEGGIES.PIPECOLSEP_ONEHEADROW
    TYPE = 'CSV'
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1;

create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'; --this means that some values will be wrapped in double-quotes bc they have commas in them
    
-- TO DROP FILE FORMAT
-- DROP FILE FORMAT IF EXISTS GARDEN_PLANTS.VEGGIES.PIPECOLSEP_ONHEADROW;
    
select * from vegetable_details;
select * from vegetable_details where "Plant Name" = 'Spinach';
select * from vegetable_details where "Plant Name" = 'Spinach' and "Rooting Depth" = 'D'; -- 'D' -> Case Sensitive

-- remove only the Spinach row with "D" in the ROOT_DEPTH_CODE column.
-- DELETE from vegetable_details where "Plant Name" = 'Spinach' and "Rooting Depth" = 'D';

-- SHOWING FILE FORMATS
SHOW FILE FORMATS;

select * from root_depth;