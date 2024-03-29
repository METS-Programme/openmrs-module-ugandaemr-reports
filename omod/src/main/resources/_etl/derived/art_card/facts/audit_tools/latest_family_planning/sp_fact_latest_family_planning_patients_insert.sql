-- $BEGIN
INSERT INTO mamba_fact_patients_latest_family_planning(client_id,
                                                       encounter_date,
                                                       status)
SELECT b.client_id,encounter_date,
       IF(family_planning_status='NOT PREGNANT AND NOT ON FAMILY PLANNING','NOT ON FAMILY PLANNING',
           IF(family_planning_status='NOT PREGNANT AND ON FAMILY PLANNING','ON FAMILY PLANNING',family_planning_status)) AS family_planning_status
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE family_planning_status IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id;
-- $END