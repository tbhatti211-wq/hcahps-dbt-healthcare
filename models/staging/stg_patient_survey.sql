WITH patient_survey AS(
    SELECT
    TRIM(provider_id)                                        AS provider_id,
    TRIM(hospital_name)                                      AS hospital_name,
    TRIM(address)                                            AS address,
    TRIM(city)                                               AS city,
    TRIM(state)                                              AS state,
    TRIM(zip_code)                                           AS zip_code,
    TRIM(county_name)                                        AS county_name,
    TRIM(phone_number)                                       AS phone_number,
    TRIM(measure_id)                                         AS measure_id,
    TRIM(question)                                           AS question,
    TRIM(answer_description)                                 AS answer_description,
    TRIM(location)                                           AS location,
    TRY_CAST(patient_survey_star_rating AS FLOAT)            AS patient_survey_star_rating,
    TRY_CAST(patient_survey_star_rating_footnote AS INT)     AS patient_survey_star_rating_footnote,
    TRY_CAST(answer_percent AS FLOAT)                        AS answer_percent,
    TRY_CAST(answer_percent_footnote AS INT)                 AS answer_percent_footnote,
    TRY_CAST(linear_mean_value AS FLOAT)                     AS linear_mean_value,
    TRY_CAST(number_of_completed_surveys AS INT)             AS number_of_completed_surveys,
    TRY_CAST(number_of_completed_surveys_footnote AS INT)    AS number_of_completed_surveys_footnote,
    TRY_CAST(survey_response_rate_percent AS FLOAT)          AS survey_response_rate_percent,
    TRY_CAST(survey_response_rate_percent_footnote AS INT)   AS survey_response_rate_percent_footnote,
    TRY_CAST(measure_start_date AS DATE)                     AS measure_start_date,
    TRY_CAST(measure_end_date AS DATE)                       AS measure_end_date

    FROM {{ source('HEALTHCARE_SURVEY', 'RAW_PATIENT_SURVEY') }}

)

SELECT * FROM patient_survey