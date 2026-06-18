SELECT
    h.city,
    h.state,
    COUNT(h.hospital_id) AS total_hospitals,
    LISTAGG(h.hospital_name, ', ') 
        WITHIN GROUP (ORDER BY h.hospital_name) AS hospitals
FROM {{ ref('dim_hospital_details') }} h
GROUP BY h.city, h.state
HAVING COUNT(h.hospital_id) > 1
ORDER BY total_hospitals DESC