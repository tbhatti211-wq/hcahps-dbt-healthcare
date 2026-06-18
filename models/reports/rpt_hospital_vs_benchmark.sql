WITH national_avg AS (
    SELECT
        m.measure_id,
        AVG(COALESCE(f.survey_response_rate_percent, 0)) AS national_avg_response_rate
    FROM {{ ref('fact_patient_survey') }} f
    LEFT JOIN {{ ref('dim_measure_details') }} m
        ON f.measure_sk = m.measure_sk
    GROUP BY m.measure_id
),

hospital_measure AS (
    SELECT
        h.hospital_name,
        m.measure_id,
        AVG(COALESCE(f.survey_response_rate_percent, 0)) AS hospital_avg_response_rate
    FROM {{ ref('fact_patient_survey') }} f
    LEFT JOIN {{ ref('dim_hospital_details') }} h
        ON f.hospital_id = h.hospital_id
    LEFT JOIN {{ ref('dim_measure_details') }} m
        ON f.measure_sk = m.measure_sk
    GROUP BY h.hospital_name, m.measure_id
)

SELECT
    hm.hospital_name,
    hm.measure_id,
    hm.hospital_avg_response_rate,
    na.national_avg_response_rate,
    ROUND(hm.hospital_avg_response_rate - na.national_avg_response_rate, 2) AS variance_from_national,
    CASE 
        WHEN hm.hospital_avg_response_rate >= na.national_avg_response_rate 
        THEN 'Above Benchmark'
        ELSE 'Below Benchmark'
    END AS benchmark_status
FROM hospital_measure hm
LEFT JOIN national_avg na
    ON hm.measure_id = na.measure_id
ORDER BY hm.hospital_name, variance_from_national DESC