SELECT
    h.hospital_name,
    SUM(COALESCE(f.number_of_completed_surveys, 0)) AS total_surveys_completed
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_hospital_details') }} h
    ON f.hospital_id = h.hospital_id
GROUP BY h.hospital_name
ORDER BY total_surveys_completed DESC