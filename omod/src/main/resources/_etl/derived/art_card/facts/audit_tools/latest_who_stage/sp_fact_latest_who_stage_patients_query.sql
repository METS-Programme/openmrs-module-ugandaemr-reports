DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_who_stage_query;
CREATE PROCEDURE sp_fact_patient_latest_who_stage_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_who_stage;
END //

DELIMITER ;




