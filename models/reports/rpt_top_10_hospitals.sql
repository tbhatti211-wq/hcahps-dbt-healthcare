SELECT
    h.hospital_name,
    AVG(COALESCE(f.survey_response_rate_percent, 0)) AS avg_response_rate
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_hospital_details') }} h
    ON f.hospital_id = h.hospital_id
GROUP BY h.hospital_name
ORDER BY avg_response_rate DESC
LIMIT 10