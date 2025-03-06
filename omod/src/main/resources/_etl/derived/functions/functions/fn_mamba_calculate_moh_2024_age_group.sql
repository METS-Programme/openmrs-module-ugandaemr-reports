DROP FUNCTION IF EXISTS fn_mamba_calculate_moh_2024_age_group;

DELIMITER //

CREATE FUNCTION fn_mamba_calculate_moh_2024_age_group(age INT) RETURNS VARCHAR(15)
    DETERMINISTIC
BEGIN
    DECLARE agegroup VARCHAR(15);
    IF age between 0 and 4 THEN
        SET agegroup = '0-4';
    ELSEIF age between 5 and 9 THEN
        SET agegroup = '5-9';
    ELSEIF age between 10 and 14 THEN
        SET agegroup = '10-14';
    ELSEIF age between 15 and 19 THEN
        SET agegroup = '15-19';
    ELSEIF age between 20 and 24 THEN
        SET agegroup = '20-24';
    ELSEIF age between 25 and 29 THEN
        SET agegroup = '25-29';
    ELSEIF age between 30 and 39 THEN
        SET agegroup = '30-39';
    ELSEIF age between 40 and 49 THEN
        SET agegroup = '40-49';
    ELSE
        SET agegroup = '50+';
    END IF;

    RETURN (agegroup);
END //

DELIMITER ;