WITH measure_base AS (
    SELECT DISTINCT
        measure_id,
        measure_start_date,
        measure_end_date
    FROM {{ ref('stg_patient_survey') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY measure_id) AS measure_sk,
    measure_id,
    measure_start_date,
    measure_end_date
FROM measure_base