WITH ranked_measures AS (
    SELECT
        h.hospital_name,
        m.measure_id,
        sd.survey_question,
        COALESCE(f.answer_percent, 0)              AS answer_percent,
        COALESCE(f.patient_survey_star_rating, 0)  AS star_rating,
        ROW_NUMBER() OVER (
            PARTITION BY h.hospital_name
            ORDER BY f.answer_percent DESC, f.patient_survey_star_rating DESC
        ) AS rnk
    FROM {{ ref('fact_patient_survey') }} f
    LEFT JOIN {{ ref('dim_hospital_details') }} h
        ON f.hospital_id = h.hospital_id
    LEFT JOIN {{ ref('dim_measure_details') }} m
        ON f.measure_sk = m.measure_sk
    LEFT JOIN {{ ref('dim_survey_details') }} sd
        ON f.survey_id = sd.survey_id
)

SELECT
    hospital_name,
    measure_id,
    survey_question,
    answer_percent,
    star_rating,
    rnk AS measure_rank
FROM ranked_measures
WHERE rnk <= 3
ORDER BY hospital_name, measure_rank