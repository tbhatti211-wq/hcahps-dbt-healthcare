-- ============================================
-- HCAHPS Healthcare Data Warehouse
-- Snowflake Setup Script
-- Author: Talib Hussain
-- Data Engineering Academy Portfolio Project
-- ============================================


-- ============================================
-- STEP 1: DATABASE AND SCHEMA SETUP
-- ============================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE DATABASE HEALTHCARE_ANALYSIS;
USE DATABASE HEALTHCARE_ANALYSIS;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS STAGING_SILVER;
CREATE SCHEMA IF NOT EXISTS GOLD_MARTS;
CREATE SCHEMA IF NOT EXISTS REPORTS;

USE SCHEMA RAW;


-- ============================================
-- STEP 2: FILE FORMAT AND STAGE
-- Note: The commands below were run via SnowSQL CLI
-- to upload the local CSV file to the internal stage.
-- They are documented here for reference.
-- ============================================

-- CREATE OR REPLACE FILE FORMAT HCAHPS_CSV_FORMAT
--   TYPE = 'CSV'
--   FIELD_DELIMITER = ','
--   RECORD_DELIMITER = '\r\n'
--   SKIP_HEADER = 1
--   FIELD_OPTIONALLY_ENCLOSED_BY = '"'
--   TRIM_SPACE = TRUE
--   NULL_IF = ('', 'NULL', 'Not Available')
--   EMPTY_FIELD_AS_NULL = TRUE;

-- CREATE OR REPLACE STAGE HCAHPS_STAGE
--   FILE_FORMAT = HCAHPS_CSV_FORMAT;

-- PUT 'file:///path/to/Health Care_Patient_survey_source.csv' @HCAHPS_STAGE AUTO_COMPRESS=TRUE;

-- Verify file was uploaded to stage
LIST @HCAHPS_STAGE;


-- ============================================
-- STEP 3: RAW LANDING TABLE AND DATA LOAD
-- All columns loaded as VARCHAR for safe landing.
-- Type casting handled in dbt staging layer.
-- ============================================

CREATE OR REPLACE TABLE RAW_PATIENT_SURVEY (
  provider_id                          VARCHAR,
  hospital_name                        VARCHAR,
  address                              VARCHAR,
  city                                 VARCHAR,
  state                                VARCHAR,
  zip_code                             VARCHAR,
  county_name                          VARCHAR,
  phone_number                         VARCHAR,
  measure_id                           VARCHAR,
  question                             VARCHAR,
  answer_description                   VARCHAR,
  patient_survey_star_rating           VARCHAR,
  patient_survey_star_rating_footnote  VARCHAR,
  answer_percent                       VARCHAR,
  answer_percent_footnote              VARCHAR,
  linear_mean_value                    VARCHAR,
  number_of_completed_surveys          VARCHAR,
  number_of_completed_surveys_footnote VARCHAR,
  survey_response_rate_percent         VARCHAR,
  survey_response_rate_percent_footnote VARCHAR,
  measure_start_date                   VARCHAR,
  measure_end_date                     VARCHAR,
  location                             VARCHAR
);

-- Load data from stage into raw table
-- ON_ERROR = CONTINUE skips bad rows instead of failing the entire load
COPY INTO RAW_PATIENT_SURVEY
  FROM @HCAHPS_STAGE
  FILE_FORMAT = HCAHPS_CSV_FORMAT
  ON_ERROR = 'CONTINUE';

-- Quick sanity check on raw load
SELECT COUNT(*) FROM RAW_PATIENT_SURVEY;
SELECT * FROM RAW_PATIENT_SURVEY LIMIT 10;
SELECT DISTINCT state FROM RAW_PATIENT_SURVEY ORDER BY 1;


-- ============================================
-- STEP 4: GRANTS FOR DBT ROLE
-- Grants all required privileges to PC_DBT_ROLE
-- so dbt Cloud can create and manage schemas and tables.
-- FUTURE grants ensure new objects are automatically covered.
-- ============================================

GRANT USAGE ON DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;
GRANT CREATE SCHEMA ON DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE HEALTHCARE_ANALYSIS TO ROLE PC_DBT_ROLE;


-- ============================================
-- STEP 5: VALIDATION QUERIES
-- Run after dbt build to confirm all layers
-- are populated correctly.
-- ============================================

-- Row counts across all dimension tables
SELECT 'dim_country_details'  AS table_name, COUNT(*) AS row_count FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_country_details
UNION ALL
SELECT 'dim_hospital_details', COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_hospital_details
UNION ALL
SELECT 'dim_measure_details',  COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_measure_details
UNION ALL
SELECT 'dim_survey_details',   COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_survey_details;

-- Spot checks on dimension tables
SELECT * FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_country_details  LIMIT 5;
SELECT * FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_hospital_details LIMIT 5;
SELECT * FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_measure_details  LIMIT 5;
SELECT * FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_survey_details   LIMIT 5;

-- Duplicate PK checks (all should return zero rows)
SELECT country_id, COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_country_details GROUP BY 1 HAVING COUNT(*) > 1;
SELECT hospital_id, COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_hospital_details GROUP BY 1 HAVING COUNT(*) > 1;
SELECT measure_sk,  COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_measure_details  GROUP BY 1 HAVING COUNT(*) > 1;
SELECT survey_id,   COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_survey_details   GROUP BY 1 HAVING COUNT(*) > 1;

-- Fact table row count (should be 34,999)
SELECT COUNT(*) FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.fact_patient_survey;

-- FK validation (all counts should equal 34,999)
SELECT
    COUNT(*)           AS total_rows,
    COUNT(country_id)  AS country_id_filled,
    COUNT(hospital_id) AS hospital_id_filled,
    COUNT(measure_sk)  AS measure_sk_filled,
    COUNT(survey_id)   AS survey_id_filled
FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.fact_patient_survey;

-- NULL check on completed surveys (expected ~4,050 due to CMS data suppression)
SELECT COUNT(*)
FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.fact_patient_survey
WHERE number_of_completed_surveys IS NULL;

-- Cities with more than one hospital (used for rpt_hospitals_by_city)
SELECT
    city,
    state,
    COUNT(DISTINCT hospital_name) AS hospital_count
FROM HEALTHCARE_ANALYSIS.GOLD_MARTS.dim_hospital_details
GROUP BY city, state
HAVING COUNT(DISTINCT hospital_name) > 1
ORDER BY hospital_count DESC;


-- ============================================
-- STEP 6: WAREHOUSE COST MANAGEMENT
-- Set auto suspend to 60 seconds to minimize
-- idle credit consumption.
-- ============================================

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;