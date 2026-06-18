SELECT
    h.hospital_name,
    m.measure_id,
    AVG(COALESCE(f.survey_response_rate_percent, 0)) AS avg_response_rate
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_hospital_details') }} h
    ON f.hospital_id = h.hospital_id
LEFT JOIN {{ ref('dim_measure_details') }} m
    ON f.measure_sk = m.measure_sk
GROUP BY h.hospital_name, m.measure_id
ORDER BY m.measure_id, avg_response_rate DESC