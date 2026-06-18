SELECT
    h.hospital_name,
    SUM(COALESCE(f.survey_response_rate_percent, 0)) AS total_response_rate
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_hospital_details') }} h
    ON f.hospital_id = h.hospital_id
GROUP BY h.hospital_name
ORDER BY total_response_rate DESC