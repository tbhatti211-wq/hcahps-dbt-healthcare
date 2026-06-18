SELECT
    c.county_name,
    c.city,
    h.hospital_name,
    AVG(COALESCE(f.patient_survey_star_rating, 0)) AS avg_star_rating
FROM {{ ref('fact_patient_survey') }} f
LEFT JOIN {{ ref('dim_hospital_details') }} h
    ON f.hospital_id = h.hospital_id
LEFT JOIN {{ ref('dim_country_details') }} c
    ON f.country_id = c.country_id
WHERE c.county_name IS NOT NULL
GROUP BY c.county_name, c.city, h.hospital_name
ORDER BY c.county_name, c.city, avg_star_rating DESC