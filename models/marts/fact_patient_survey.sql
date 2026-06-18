WITH base_tables AS(
    SELECT
        h.country_id,
        h.hospital_id,
        m.measure_sk,
        sd.survey_id,
        s.number_of_completed_surveys,
        s.number_of_completed_surveys_footnote,
        s.survey_response_rate_percent,
        s.survey_response_rate_percent_footnote,
        s.linear_mean_value,
        s.answer_percent,
        s.patient_survey_star_rating
    FROM {{ ref('stg_patient_survey') }} s
    -- Joining Hospital which will give hospital and country
    LEFT JOIN {{ ref('dim_hospital_details') }} h
    on h.provider_id = s.provider_id
    -- Joining Dim Survey
    LEFT JOIN {{ ref('dim_survey_details') }} sd
    on s.question = sd.survey_question 
    AND s.answer_description = sd.survey_answer
    -- Joing Measure
    LEFT JOIN {{ ref('dim_measure_details') }} m
    ON s.measure_id = m.measure_id
)

SELECT * FROM base_tables