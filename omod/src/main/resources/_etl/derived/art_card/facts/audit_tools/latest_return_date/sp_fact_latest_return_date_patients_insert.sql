-- $BEGIN
INSERT INTO mamba_fact_patients_latest_return_date (client_id,
                                                return_date)
SELECT b.client_id, b.return_visit_date
FROM mamba_fact_encounter_hiv_art_card b
         INNER JOIN (
    SELECT client_id, MAX(encounter_id) as encounter_id
    FROM mamba_fact_encounter_hiv_art_card
    WHERE return_visit_date IS NOT NULL
    GROUP BY client_id
) a ON b.encounter_id = a.encounter_id;
-- $END