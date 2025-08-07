DROP PROCEDURE IF EXISTS sp_mamba_load_agegroup;

DELIMITER //

CREATE PROCEDURE sp_mamba_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO mamba_dim_agegroup(age, datim_agegroup, normal_agegroup,moh_age_group,moh_2024_age_group,moh_anc_age_group)
            VALUES (age, fn_mamba_calculate_agegroup(age), IF(age < 15, '<15', '15+'),fn_mamba_calculate_moh_age_group(age),fn_mamba_calculate_moh_2024_age_group(age),fn_mamba_calculate_moh_anc_age_group(age));
            SET age = age + 1;
        END WHILE;
END //

DELIMITER ;