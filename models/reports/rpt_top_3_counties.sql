SELECT
    c.county_name,
    AVG(COALESCE(f.survey_response_rate_percent, 0)) AS avg_response_rate
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_country_details') }} c
    ON f.country_id = c.country_id
WHERE c.county_name IS NOT NULL
GROUP BY c.county_name
ORDER BY avg_response_rate DESC
LIMIT 3