DROP FUNCTION IF EXISTS fn_mamba_calculate_moh_anc_age_group;

DELIMITER //

CREATE FUNCTION fn_mamba_calculate_moh_anc_age_group(age INT) RETURNS VARCHAR(15)
    DETERMINISTIC
BEGIN
    DECLARE agegroup VARCHAR(15);
    IF age < 15 THEN
        SET agegroup = 'Below15';
    ELSEIF age between 15 and 19 THEN
        SET agegroup = '15-19';
    ELSEIF age between 20 and 24 THEN
        SET agegroup = '20-24';
    ELSEIF age between 25 and 49 THEN
        SET agegroup = '25-49';
    ELSE
        SET agegroup = '50+';
    END IF;

    RETURN (agegroup);
END //


DELIMITER ;