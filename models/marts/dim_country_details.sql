WITH country_base AS (
    SELECT DISTINCT
        state,
        city,
        zip_code,
        county_name,
        'USA' AS country_name
    FROM {{ ref('stg_patient_survey') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY state, city, zip_code, county_name) AS country_id,
    country_name,
    state,
    city,
    zip_code,
    county_name
FROM country_base