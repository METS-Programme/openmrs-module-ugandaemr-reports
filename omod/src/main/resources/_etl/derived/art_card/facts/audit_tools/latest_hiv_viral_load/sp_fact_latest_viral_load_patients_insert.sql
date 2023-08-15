-- $BEGIN
INSERT INTO mamba_fact_patients_latest_viral_load (client_id,
                                                encounter_date,
                                                   hiv_viral_load_copies,
                                                   hiv_viral_collection_date,
                                                   specimen_type)
SELECT a.client_id,encounter_date, hiv_viral_load, hiv_viral_load_date, specimen_sources
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id,
             MAX(encounter_date) AS latest_encounter_date
      FROM mamba_fact_encounter_hiv_art_card
      WHERE hiv_viral_load IS NOT NULL
      GROUP BY client_id) a ON a.client_id = b.client_id AND
                               encounter_date = latest_encounter_date;
-- $END