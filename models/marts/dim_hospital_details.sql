WITH hospital_base AS (
    SELECT DISTINCT
        s.provider_id,
        s.hospital_name,
        s.address,
        s.city,
        s.state,
        s.phone_number,
        c.country_id
    FROM {{ ref('stg_patient_survey') }} s
    LEFT JOIN {{ ref('dim_country_details') }} c
        ON s.state = c.state
        AND s.city = c.city
        AND s.zip_code = c.zip_code
        AND COALESCE(s.county_name, '') = COALESCE(c.county_name, '')
)

SELECT
    ROW_NUMBER() OVER (ORDER BY provider_id) AS hospital_id,
    country_id,
    provider_id,
    hospital_name,
    address,
    city,
    state,
    phone_number
FROM hospital_base