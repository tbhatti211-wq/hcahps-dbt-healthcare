WITH survey_base AS (
    SELECT DISTINCT
        question AS survey_question,
        answer_description AS survey_answer,
        patient_survey_star_rating_footnote
    FROM {{ ref('stg_patient_survey') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY survey_question, survey_answer) AS survey_id,
    survey_question,
    survey_answer,
    patient_survey_star_rating_footnote
FROM survey_base