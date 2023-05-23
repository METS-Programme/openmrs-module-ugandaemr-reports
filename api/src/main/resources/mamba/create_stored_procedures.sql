
        
    
        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_calculate_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS fn_calculate_agegroup;

CREATE FUNCTION fn_calculate_agegroup(age INT) RETURNS VARCHAR(15)
    DETERMINISTIC
BEGIN
    DECLARE agegroup VARCHAR(15);
    IF (age < 1) THEN
        SET agegroup = '<1';
    ELSEIF age between 1 and 4 THEN
        SET agegroup = '1-4';
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
    ELSEIF age between 30 and 34 THEN
        SET agegroup = '30-34';
    ELSEIF age between 35 and 39 THEN
        SET agegroup = '35-39';
    ELSEIF age between 40 and 44 THEN
        SET agegroup = '40-44';
    ELSEIF age between 45 and 49 THEN
        SET agegroup = '45-49';
    ELSEIF age between 50 and 54 THEN
        SET agegroup = '50-54';
    ELSEIF age between 55 and 59 THEN
        SET agegroup = '55-59';
    ELSEIF age between 60 and 64 THEN
        SET agegroup = '60-64';
    ELSE
        SET agegroup = '65+';
    END IF;

    RETURN (agegroup);
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_get_obs_value_column  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS fn_get_obs_value_column;

CREATE FUNCTION fn_get_obs_value_column(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE obsValueColumn VARCHAR(20);
    IF (conceptDatatype = 'Text' OR conceptDatatype = 'Coded' OR conceptDatatype = 'N/A' OR
        conceptDatatype = 'Boolean') THEN
        SET obsValueColumn = 'obs_value_text';
    ELSEIF conceptDatatype = 'Date' OR conceptDatatype = 'Datetime' THEN
        SET obsValueColumn = 'obs_value_datetime';
    ELSEIF conceptDatatype = 'Numeric' THEN
        SET obsValueColumn = 'obs_value_numeric';
    END IF;

    RETURN (obsValueColumn);
END//

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_functions_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_stored_functions_in_schema;

CREATE PROCEDURE sp_xf_system_drop_all_stored_functions_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN
    DELETE FROM `mysql`.`proc` WHERE `type` = 'FUNCTION' AND `db` = database_name; -- works in mysql before v.8

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_stored_procedures_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_stored_procedures_in_schema;

CREATE PROCEDURE sp_xf_system_drop_all_stored_procedures_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    DELETE FROM `mysql`.`proc` WHERE `type` = 'PROCEDURE' AND `db` = database_name; -- works in mysql before v.8

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_objects_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_objects_in_schema;

CREATE PROCEDURE sp_xf_system_drop_all_objects_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    CALL sp_xf_system_drop_all_stored_functions_in_schema(database_name);
    CALL sp_xf_system_drop_all_stored_procedures_in_schema(database_name);
    CALL sp_xf_system_drop_all_tables_in_schema(database_name);
    # CALL sp_xf_system_drop_all_views_in_schema (database_name);

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_tables_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_tables_in_schema;

-- CREATE PROCEDURE sp_xf_system_drop_all_tables_in_schema(IN database_name CHAR(255) CHARACTER SET UTF8MB4)
CREATE PROCEDURE sp_xf_system_drop_all_tables_in_schema()
BEGIN

    DECLARE tables_count INT;

    SET @database_name = (SELECT DATABASE());

    SELECT COUNT(1)
    INTO tables_count
    FROM information_schema.tables
    WHERE TABLE_TYPE = 'BASE TABLE'
      AND TABLE_SCHEMA = @database_name;

    IF tables_count > 0 THEN

        SET session group_concat_max_len = 20000;

        SET @tbls = (SELECT GROUP_CONCAT(@database_name, '.', TABLE_NAME SEPARATOR ', ')
                     FROM information_schema.tables
                     WHERE TABLE_TYPE = 'BASE TABLE'
                       AND TABLE_SCHEMA = @database_name
                       AND TABLE_NAME REGEXP '^(mamba_|dim_|fact_|flat_)');

        IF (@tbls IS NOT NULL) THEN

            SET @drop_tables = CONCAT('DROP TABLE IF EXISTS ', @tbls);

            SET foreign_key_checks = 0; -- Remove check, so we don't have to drop tables in the correct order, or care if they exist or not.
            PREPARE drop_tbls FROM @drop_tables;
            EXECUTE drop_tbls;
            DEALLOCATE PREPARE drop_tbls;
            SET foreign_key_checks = 1;

        END IF;

    END IF;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_execute_etl  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_execute_etl;

CREATE PROCEDURE sp_xf_system_execute_etl()
BEGIN
    DECLARE error_message VARCHAR(255) DEFAULT 'OK';
    DECLARE error_code CHAR(5) DEFAULT '00000';

    DECLARE start_time bigint;
    DECLARE end_time bigint;
    DECLARE start_date_time DATETIME;
    DECLARE end_date_time DATETIME;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                error_code = RETURNED_SQLSTATE,
                error_message = MESSAGE_TEXT;

            -- SET @sql = CONCAT('SIGNAL SQLSTATE ''', error_code, ''' SET MESSAGE_TEXT = ''', error_message, '''');
            -- SET @sql = CONCAT('SET @signal = ''', @sql, '''');

            -- SET @sql = CONCAT('SIGNAL SQLSTATE ''', error_code, ''' SET MESSAGE_TEXT = ''', error_message, '''');
            -- PREPARE stmt FROM @sql;
            -- EXECUTE stmt;
            -- DEALLOCATE PREPARE stmt;

            INSERT INTO zzmamba_etl_tracker (initial_run_date,
                                             start_date,
                                             end_date,
                                             time_taken_microsec,
                                             completion_status,
                                             success_or_error_message,
                                             next_run_date)
            SELECT NOW(),
                   start_date_time,
                   NOW(),
                   (((UNIX_TIMESTAMP(NOW()) * 1000000 + MICROSECOND(NOW(6))) - @start_time) / 1000),
                   'ERROR',
                   (CONCAT(error_code, ' : ', error_message)),
                   NOW() + 5;
        END;

    -- Fix start time in microseconds
    SET start_date_time = NOW();
    SET @start_time = (UNIX_TIMESTAMP(NOW()) * 1000000 + MICROSECOND(NOW(6)));

    CALL sp_data_processing_etl();

    -- Fix end time in microseconds
    SET end_date_time = NOW();
    SET @end_time = (UNIX_TIMESTAMP(NOW()) * 1000000 + MICROSECOND(NOW(6)));

    -- Result
    SET @time_taken = (@end_time - @start_time) / 1000;
    SELECT @time_taken;


    INSERT INTO zzmamba_etl_tracker (initial_run_date,
                                     start_date,
                                     end_date,
                                     time_taken_microsec,
                                     completion_status,
                                     success_or_error_message,
                                     next_run_date)
    SELECT NOW(), start_date_time, end_date_time, @time_taken, 'SUCCESS', 'OK', NOW() + 5;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_flat_encounter_table_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_create;

CREATE PROCEDURE sp_flat_encounter_table_create(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', flat_encounter_table_name, '`');

    SELECT GROUP_CONCAT(column_label SEPARATOR ' TEXT, ')
    INTO @column_labels
    FROM mamba_dim_concept_metadata
    WHERE flat_table_name = flat_encounter_table_name
      AND concept_datatype IS NOT NULL;

    IF @column_labels IS NULL THEN
        SET @create_table = CONCAT(
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT, client_id INT);');
    ELSE
        SET @create_table = CONCAT(
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT, client_id INT, ', @column_labels,
                ' TEXT);');
    END IF;


    PREPARE deletetb FROM @drop_table;
    PREPARE createtb FROM @create_table;

    EXECUTE deletetb;
    EXECUTE createtb;

    DEALLOCATE PREPARE deletetb;
    DEALLOCATE PREPARE createtb;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_flat_encounter_table_create_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_create_all;

CREATE PROCEDURE sp_flat_encounter_table_create_all()
BEGIN

    DECLARE tbl_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name) FROM mamba_dim_concept_metadata;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_flat_encounter_table_create(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_flat_encounter_table_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_insert;

CREATE PROCEDURE sp_flat_encounter_table_insert(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = flat_encounter_table_name;

    SET @old_sql = (SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ')
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = @tbl_name
                      AND TABLE_SCHEMA = Database());

    SELECT GROUP_CONCAT(DISTINCT
                        CONCAT(' MAX(CASE WHEN column_label = ''', column_label, ''' THEN ',
                               fn_get_obs_value_column(concept_datatype), ' END) ', column_label)
                        ORDER BY concept_metadata_id ASC)
    INTO @column_labels
    FROM mamba_dim_concept_metadata
    WHERE flat_table_name = @tbl_name;

    SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_name, '` SELECT eo.encounter_id, eo.person_id, ', @column_labels, '
            FROM mamba_z_encounter_obs eo
                INNER JOIN mamba_dim_concept_metadata cm
                ON IF(cm.concept_answer_obs=1, cm.concept_uuid=eo.obs_value_coded_uuid, cm.concept_uuid=eo.obs_question_uuid)
            WHERE cm.flat_table_name = ''', @tbl_name, '''
            AND eo.encounter_type_uuid = cm.encounter_type_uuid
            GROUP BY eo.encounter_id, eo.person_id;');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_flat_encounter_table_insert_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_insert_all;

CREATE PROCEDURE sp_flat_encounter_table_insert_all()
BEGIN

    DECLARE tbl_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name) FROM mamba_dim_concept_metadata;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_flat_encounter_table_insert(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_multiselect_values_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_multiselect_values_update`;

CREATE PROCEDURE `sp_multiselect_values_update`(
    IN table_to_update CHAR(100) CHARACTER SET UTF8MB4,
    IN column_names TEXT CHARACTER SET UTF8MB4,
    IN value_yes CHAR(100) CHARACTER SET UTF8MB4,
    IN value_no CHAR(100) CHARACTER SET UTF8MB4
)
BEGIN

    SET @table_columns = column_names;
    SET @start_pos = 1;
    SET @comma_pos = locate(',', @table_columns);
    SET @end_loop = 0;

    SET @column_label = '';

    REPEAT
        IF @comma_pos > 0 THEN
            SET @column_label = substring(@table_columns, @start_pos, @comma_pos - @start_pos);
            SET @end_loop = 0;
        ELSE
            SET @column_label = substring(@table_columns, @start_pos);
            SET @end_loop = 1;
        END IF;

        -- UPDATE fact_hts SET @column_label=IF(@column_label IS NULL OR '', new_value_if_false, new_value_if_true);

        SET @update_sql = CONCAT(
                'UPDATE ', table_to_update, ' SET ', @column_label, '= IF(', @column_label, ' IS NOT NULL, ''',
                value_yes, ''', ''', value_no, ''');');
        PREPARE stmt FROM @update_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        IF @end_loop = 0 THEN
            SET @table_columns = substring(@table_columns, @comma_pos + 1);
            SET @comma_pos = locate(',', @table_columns);
        END IF;
    UNTIL @end_loop = 1
        END REPEAT;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_extract_report_metadata  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_extract_report_metadata;

CREATE PROCEDURE sp_extract_report_metadata(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8MB4,
    IN metadata_table CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;

    SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
    SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

    SET @report_count = 0;
    WHILE @report_count < @report_array_len
        DO

            SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
            SELECT JSON_EXTRACT(@report, '$.report_name') INTO @report_name;
            SELECT JSON_EXTRACT(@report, '$.flat_table_name') INTO @flat_table_name;
            SELECT JSON_EXTRACT(@report, '$.encounter_type_uuid') INTO @encounter_type;
            SELECT JSON_EXTRACT(@report, '$.table_columns') INTO @column_array;

            SELECT JSON_KEYS(@column_array) INTO @column_keys_array;
            SELECT JSON_LENGTH(@column_keys_array) INTO @column_keys_array_len;
            SET @col_count = 0;
            WHILE @col_count < @column_keys_array_len
                DO
                    SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                    SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                    SET @tbl_name = '';
                    INSERT INTO mamba_dim_concept_metadata(report_name,
                                                           flat_table_name,
                                                           encounter_type_uuid,
                                                           column_label,
                                                           concept_uuid)
                    VALUES (JSON_UNQUOTE(@report_name),
                            JSON_UNQUOTE(@flat_table_name),
                            JSON_UNQUOTE(@encounter_type),
                            JSON_UNQUOTE(@field_name),
                            JSON_UNQUOTE(@concept_uuid));

                    SET @col_count = @col_count + 1;
                END WHILE;

            SET @report_count = @report_count + 1;
        END WHILE;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_load_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_load_agegroup;

CREATE PROCEDURE sp_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO dim_agegroup(age, datim_agegroup, normal_agegroup)
            VALUES (age, fn_calculate_agegroup(age), IF(age < 15, '<15', '15+'));
            SET age = age + 1;
        END WHILE;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_create;

CREATE PROCEDURE sp_mamba_dim_concept_datatype_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept_datatype
(
    concept_datatype_id  int                             NOT NULL AUTO_INCREMENT,
    external_datatype_id int,
    datatype_name        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (concept_datatype_id)
);

create index mamba_dim_concept_datatype_external_datatype_id_index
    on mamba_dim_concept_datatype (external_datatype_id);


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_insert;

CREATE PROCEDURE sp_mamba_dim_concept_datatype_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_concept_datatype (external_datatype_id,
                                        datatype_name)
SELECT dt.concept_datatype_id AS external_datatype_id,
       dt.name                AS datatype_name
FROM concept_datatype dt
WHERE dt.retired = 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype;

CREATE PROCEDURE sp_mamba_dim_concept_datatype()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_concept_datatype_create();
CALL sp_mamba_dim_concept_datatype_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_create;

CREATE PROCEDURE sp_mamba_dim_concept_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    concept_id           INT                             NOT NULL AUTO_INCREMENT,
    uuid                 CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,
    external_concept_id  INT,
    external_datatype_id INT, -- make it a FK
    datatype             CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (concept_id)
);

CREATE INDEX mamba_dim_concept_external_concept_id_index
    ON mamba_dim_concept (external_concept_id);

CREATE INDEX mamba_dim_concept_external_datatype_id_index
    ON mamba_dim_concept (external_datatype_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_insert;

CREATE PROCEDURE sp_mamba_dim_concept_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_concept (uuid,
                               external_concept_id,
                               external_datatype_id)
SELECT c.uuid        AS uuid,
       c.concept_id  AS external_concept_id,
       c.datatype_id AS external_datatype_id
FROM concept c
WHERE c.retired = 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_update;

CREATE PROCEDURE sp_mamba_dim_concept_update()
BEGIN
-- $BEGIN

UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.external_datatype_id = dt.external_datatype_id
SET c.datatype = dt.datatype_name
WHERE c.concept_id > 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept;

CREATE PROCEDURE sp_mamba_dim_concept()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_concept_create();
CALL sp_mamba_dim_concept_insert();
CALL sp_mamba_dim_concept_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_create;

CREATE PROCEDURE sp_mamba_dim_concept_answer_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept_answer
(
    concept_answer_id INT NOT NULL AUTO_INCREMENT,
    concept_id        INT,
    answer_concept    INT,
    answer_drug       INT,
    PRIMARY KEY (concept_answer_id)
);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_insert;

CREATE PROCEDURE sp_mamba_dim_concept_answer_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_concept_answer (concept_id,
                                      answer_concept,
                                      answer_drug)
SELECT ca.concept_id     AS concept_id,
       ca.answer_concept AS answer_concept,
       ca.answer_drug    AS answer_drug
FROM concept_answer ca;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer;

CREATE PROCEDURE sp_mamba_dim_concept_answer()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_concept_answer_create();
CALL sp_mamba_dim_concept_answer_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_create;

CREATE PROCEDURE sp_mamba_dim_concept_name_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    concept_name_id     INT                             NOT NULL AUTO_INCREMENT,
    external_concept_id INT,
    concept_name        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (concept_name_id)
);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_insert;

CREATE PROCEDURE sp_mamba_dim_concept_name_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_concept_name (external_concept_id,
                                    concept_name)
SELECT cn.concept_id AS external_concept_id,
       cn.name       AS concept_name
FROM concept_name cn
WHERE cn.locale = 'en'
  AND cn.locale_preferred = 1;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name;

CREATE PROCEDURE sp_mamba_dim_concept_name()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_concept_name_create();
CALL sp_mamba_dim_concept_name_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_create;

CREATE PROCEDURE sp_mamba_dim_encounter_type_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    encounter_type_id          INT                            NOT NULL AUTO_INCREMENT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38) CHARACTER SET UTF8MB4 NOT NULL,
    PRIMARY KEY (encounter_type_id)
);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_insert;

CREATE PROCEDURE sp_mamba_dim_encounter_type_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_encounter_type (external_encounter_type_id,
                                      encounter_type_uuid)
SELECT et.encounter_type_id AS external_encounter_type_id,
       et.uuid              AS encounter_type_uuid
FROM encounter_type et
WHERE et.retired = 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type;

CREATE PROCEDURE sp_mamba_dim_encounter_type()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_encounter_type_create();
CALL sp_mamba_dim_encounter_type_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_create;

CREATE PROCEDURE sp_mamba_dim_encounter_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id               INT                            NOT NULL AUTO_INCREMENT,
    external_encounter_id      INT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (encounter_id)
);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_insert;

CREATE PROCEDURE sp_mamba_dim_encounter_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_encounter (external_encounter_id,
                                 external_encounter_type_id)
SELECT e.encounter_id   AS external_encounter_id,
       e.encounter_type AS external_encounter_type_id
FROM encounter e;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_update;

CREATE PROCEDURE sp_mamba_dim_encounter_update()
BEGIN
-- $BEGIN

UPDATE mamba_dim_encounter e
    INNER JOIN mamba_dim_encounter_type et
    ON e.external_encounter_type_id = et.external_encounter_type_id
SET e.encounter_type_uuid = et.encounter_type_uuid
WHERE e.encounter_id > 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter;

CREATE PROCEDURE sp_mamba_dim_encounter()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_encounter_create();
CALL sp_mamba_dim_encounter_insert();
CALL sp_mamba_dim_encounter_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_metadata_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_metadata_create;

CREATE PROCEDURE sp_mamba_dim_concept_metadata_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept_metadata
(
    concept_metadata_id INT                             NOT NULL AUTO_INCREMENT,
    column_number       INT,
    column_label        CHAR(50) CHARACTER SET UTF8MB4  NOT NULL,
    concept_uuid        CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,
    concept_datatype    CHAR(255) CHARACTER SET UTF8MB4 NULL,
    concept_answer_obs  TINYINT(1)                      NOT NULL DEFAULT 0,
    report_name         CHAR(255) CHARACTER SET UTF8MB4 NOT NULL,
    flat_table_name     CHAR(255) CHARACTER SET UTF8MB4 NULL,
    encounter_type_uuid CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,

    PRIMARY KEY (concept_metadata_id)
);

create index mamba_dim_concept_metadata_concept_uuid_index
    on mamba_dim_concept_metadata (concept_uuid);

-- ALTER TABLE `mamba_dim_concept_metadata`
--     ADD COLUMN `encounter_type_id` INT NULL AFTER `output_table_name`,
--     ADD CONSTRAINT `fk_encounter_type_id`
--         FOREIGN KEY (`encounter_type_id`) REFERENCES `mamba_dim_encounter_type` (`encounter_type_id`);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_metadata_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_metadata_insert;

CREATE PROCEDURE sp_mamba_dim_concept_metadata_insert()
BEGIN
  -- $BEGIN

  SET @report_data = '{"flat_report_metadata":[
  {
  "report_name": "ART_Register",
  "flat_table_name": "mamba_flat_encounter_art_card",
  "encounter_type_uuid": "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f",
  "table_columns": {
    "return_date": "dcac04cf-30ab-102d-86b0-7a5022ba4115",
    "current_regimen": "dd2b0b4d-30ab-102d-86b0-7a5022ba4115",
    "who_stage": "dcdff274-30ab-102d-86b0-7a5022ba4115",
    "no_of_days": "7593ede6-6574-4326-a8a6-3d742e843659",
    "no_of_pills": "b0e53f0a-eaca-49e6-b663-d0df61601b70",
    "tb_status": "dce02aa1-30ab-102d-86b0-7a5022ba4115",
    "dsdm": "73312fee-c321-11e8-a355-529269fb1459",
    "pregnant": "dcda5179-30ab-102d-86b0-7a5022ba4115",
    "emtct": "dcd7e8e5-30ab-102d-86b0-7a5022ba4115"
  }
}]}';

  CALL sp_extract_report_metadata(@report_data, 'mamba_dim_concept_metadata');

  -- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_metadata_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_metadata_update;

CREATE PROCEDURE sp_mamba_dim_concept_metadata_update()
BEGIN
-- $BEGIN

-- Update the Concept datatypes
UPDATE mamba_dim_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
SET md.concept_datatype = c.datatype
WHERE md.concept_metadata_id > 0;

-- Update to True if this field is an obs answer to an obs Question
UPDATE mamba_dim_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
    INNER JOIN mamba_dim_concept_answer ca
    ON ca.answer_concept = c.external_concept_id
SET md.concept_answer_obs = 1
WHERE md.concept_metadata_id > 0;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_metadata  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_metadata;

CREATE PROCEDURE sp_mamba_dim_concept_metadata()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_concept_metadata_create();
CALL sp_mamba_dim_concept_metadata_insert();
CALL sp_mamba_dim_concept_metadata_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_create;

CREATE PROCEDURE sp_mamba_dim_person_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_person
(
    person_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_id INT,
    birthdate          CHAR(255) CHARACTER SET UTF8MB4 NULL,
    gender             CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_id)
);
create index mamba_dim_person_external_person_id_index
    on mamba_dim_person (external_person_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_insert;

CREATE PROCEDURE sp_mamba_dim_person_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_person (external_person_id,
                              birthdate,
                              gender)
SELECT psn.person_id AS external_person_id,
       psn.birthdate AS birthdate,
       psn.gender    AS gender
FROM person psn;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person;

CREATE PROCEDURE sp_mamba_dim_person()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_person_create();
CALL sp_mamba_dim_person_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_create;

CREATE PROCEDURE sp_mamba_dim_person_name_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_person_name
(
    person_name_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_name_id INT,
    external_person_id      INT,
    given_name              CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_name_id)
);
CREATE INDEX mamba_dim_person_name_external_person_id_index
    ON mamba_dim_person_name (external_person_id);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_insert;

CREATE PROCEDURE sp_mamba_dim_person_name_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_person_name (external_person_name_id,
                                   external_person_id,
                                   given_name)
SELECT pn.person_name_id AS external_person_name_id,
       pn.person_id      AS external_person_id,
       pn.given_name     AS given_name
FROM person_name pn;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name;

CREATE PROCEDURE sp_mamba_dim_person_name()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_person_name_create();
CALL sp_mamba_dim_person_name_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_create;

CREATE PROCEDURE sp_mamba_dim_person_address_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_person_address
(
    person_address_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_address_id INT,
    external_person_id         INT,
    city_village               CHAR(255) CHARACTER SET UTF8MB4 NULL,
    county_district            CHAR(255) CHARACTER SET UTF8MB4 NULL,
    address1                   CHAR(255) CHARACTER SET UTF8MB4 NULL,
    address2                   CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_address_id)
);
create index mamba_dim_person_address_external_person_id_index
    on mamba_dim_person_address (external_person_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_insert;

CREATE PROCEDURE sp_mamba_dim_person_address_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_person_address (external_person_address_id,
                                      external_person_id,
                                      city_village,
                                      county_district,
                                      address1,
                                      address2)
SELECT pa.person_address_id AS external_person_address_id,
       pa.person_id         AS external_person_id,
       pa.city_village      AS city_village,
       pa.county_district   AS county_district,
       pa.address1          AS address1,
       pa.address2          AS address2
FROM person_address pa;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address;

CREATE PROCEDURE sp_mamba_dim_person_address()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_person_address_create();
CALL sp_mamba_dim_person_address_insert();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_create;

CREATE PROCEDURE sp_dim_client_create()
BEGIN
-- $BEGIN
CREATE TABLE dim_client
(
    id            INT                             NOT NULL AUTO_INCREMENT,
    client_id     INT,
    date_of_birth DATE                            NULL,
    age           INT,
    sex           CHAR(255) CHARACTER SET UTF8MB4 NULL,
    county        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    sub_county    CHAR(255) CHARACTER SET UTF8MB4 NULL,
    ward          CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (id)
);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_insert;

CREATE PROCEDURE sp_dim_client_insert()
BEGIN
-- $BEGIN

INSERT INTO dim_client (client_id,
                        date_of_birth,
                        age,
                        sex,
                        county,
                        sub_county,
                        ward)
SELECT `psn`.`person_id`                             AS `client_id`,
       `psn`.`birthdate`                             AS `date_of_birth`,
       timestampdiff(YEAR, `psn`.`birthdate`, now()) AS `age`,
       (CASE `psn`.`gender`
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE '_'
           END)                                      AS `sex`,
       `pa`.`county_district`                        AS `county`,
       `pa`.`city_village`                           AS `sub_county`,
       `pa`.`address1`                               AS `ward`
FROM ((`mamba_dim_person` `psn`
    LEFT JOIN `mamba_dim_person_name` `pn` on ((`psn`.`external_person_id` = `pn`.`external_person_id`)))
    LEFT JOIN `mamba_dim_person_address` `pa` on ((`psn`.`external_person_id` = `pa`.`external_person_id`)));


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_update;

CREATE PROCEDURE sp_dim_client_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client;

CREATE PROCEDURE sp_dim_client()
BEGIN
-- $BEGIN

CALL sp_dim_client_create();
CALL sp_dim_client_insert();
CALL sp_dim_client_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs;

CREATE PROCEDURE sp_mamba_z_encounter_obs()
BEGIN
-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    obs_question_uuid    CHAR(38) CHARACTER SET UTF8MB4,
--    obs_answer_uuid      CHAR(38) CHARACTER SET UTF8MB4,
    obs_value_coded_uuid CHAR(38) CHARACTER SET UTF8MB4,
    encounter_type_uuid  CHAR(38) CHARACTER SET UTF8MB4
)
SELECT o.encounter_id         AS encounter_id,
       o.person_id            AS person_id,
       o.obs_datetime         AS obs_datetime,
       o.concept_id           AS obs_question_concept_id,
       o.value_text           AS obs_value_text,
       o.value_numeric        AS obs_value_numeric,
       o.value_coded          AS obs_value_coded,
       o.value_datetime       AS obs_value_datetime,
       o.value_complex        AS obs_value_complex,
       o.value_drug           AS obs_value_drug,
       et.encounter_type_uuid AS encounter_type_uuid,
       NULL                   AS obs_question_uuid,
--       NULL                   AS obs_answer_uuid,
       NULL                   AS obs_value_coded_uuid
FROM obs o
         INNER JOIN mamba_dim_encounter e
                    ON o.encounter_id = e.external_encounter_id
         INNER JOIN mamba_dim_encounter_type et
                    ON e.external_encounter_type_id = et.external_encounter_type_id
WHERE et.encounter_type_uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_dim_concept_metadata md);

CREATE INDEX mamba_z_encounter_obs_encounter_id_type_uuid_person_id_index
    ON mamba_z_encounter_obs (encounter_id, encounter_type_uuid, person_id);

CREATE INDEX mamba_z_encounter_obs_encounter_type_uuid_index
    ON mamba_z_encounter_obs (encounter_type_uuid);

CREATE INDEX mamba_z_encounter_obs_question_concept_id_index
    ON mamba_z_encounter_obs (obs_question_concept_id);

CREATE INDEX mamba_z_encounter_obs_value_coded_index
    ON mamba_z_encounter_obs (obs_value_coded);

CREATE INDEX mamba_z_encounter_obs_value_coded_uuid_index
    ON mamba_z_encounter_obs (obs_value_coded_uuid);

CREATE INDEX mamba_z_encounter_obs_question_uuid_index
    ON mamba_z_encounter_obs (obs_question_uuid);

-- update obs question UUIDs
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_question_concept_id = c.external_concept_id
SET z.obs_question_uuid = c.uuid
WHERE TRUE;

-- update obs_value_coded (UUIDs & values)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_name cn
    ON z.obs_value_coded = cn.external_concept_id
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.external_concept_id
SET z.obs_value_text       = cn.concept_name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.obs_value_coded IS NOT NULL;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_tables  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_tables;

CREATE PROCEDURE sp_mamba_z_tables()
BEGIN
-- $BEGIN

CALL sp_mamba_z_encounter_obs;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_flatten  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_flatten;

CREATE PROCEDURE sp_data_processing_flatten()
BEGIN
-- $BEGIN
-- CALL sp_xf_system_drop_all_tables_in_schema($target_database);
CALL sp_xf_system_drop_all_tables_in_schema();

CALL sp_mamba_dim_concept_datatype;

CALL sp_mamba_dim_concept_answer;

CALL sp_mamba_dim_concept_name;

CALL sp_mamba_dim_concept;

CALL sp_mamba_dim_encounter_type;

CALL sp_mamba_dim_encounter;

CALL sp_mamba_dim_concept_metadata;

CALL sp_mamba_dim_person;

CALL sp_mamba_dim_person_name;

CALL sp_mamba_dim_person_address;

CALL sp_dim_client;

CALL sp_mamba_z_tables;

CALL sp_flat_encounter_table_create_all;

CALL sp_flat_encounter_table_insert_all;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_covid;

CREATE PROCEDURE sp_data_processing_derived_covid()
BEGIN
-- $BEGIN
CALL sp_dim_client_covid;
CALL sp_fact_encounter_covid;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art;

CREATE PROCEDURE sp_data_processing_derived_hiv_art()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_etl  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_etl;

CREATE PROCEDURE sp_data_processing_etl()
BEGIN
-- $BEGIN
-- add base folder SP here --
-- CALL sp_data_processing_derived_hts();

CALL sp_data_processing_flatten();

CALL sp_data_processing_derived_hiv_art();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_create;

CREATE PROCEDURE sp_fact_encounter_hiv_art_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_hiv_art
(
    id              INT AUTO_INCREMENT,
    encounter_id    INT NULL,
    client_id       INT NULL,
    return_date     DATE NULL,
    current_regimen CHAR(255) CHARACTER SET UTF8MB4 NULL,
    who_stage       CHAR(255) CHARACTER SET UTF8MB4 NULL,
    no_of_days      CHAR(255) CHARACTER SET UTF8MB4 NULL,
    no_of_pills     INT NULL,
    tb_status       CHAR(255) CHARACTER SET UTF8MB4 NULL,
    dsdm            CHAR(255) CHARACTER SET UTF8MB4 NULL,
    pregnant        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    emtct           CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (id)
);

CREATE INDEX
    mamba_fact_encounter_hiv_art_return_date_index ON mamba_fact_encounter_hiv_art (return_date);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_insert;

CREATE PROCEDURE sp_fact_encounter_hiv_art_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_hiv_art (encounter_id,
                                          client_id,
                                          return_date,
                                          current_regimen,
                                          who_stage,
                                          no_of_days,
                                          no_of_pills,
                                          tb_status,
                                          dsdm,
                                          pregnant,
                                          emtct)
SELECT fu.encounter_id,
       fu.client_id,
       fu.return_date,
       fu.current_regimen,
       fu.who_stage,
       fu.no_of_days,
       fu.no_of_pills,
       fu.tb_status,
       fu.dsdm,
       fu.pregnant,
       fu.emtct
FROM mamba_flat_encounter_art_card as fu;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_update;

CREATE PROCEDURE sp_fact_encounter_hiv_art_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art;

CREATE PROCEDURE sp_fact_encounter_hiv_art()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hiv_art_create();
CALL sp_fact_encounter_hiv_art_insert();
CALL sp_fact_encounter_hiv_art_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_query;
CREATE PROCEDURE sp_fact_encounter_hiv_art_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT hivart.return_date,
           hivart.current_regimen,
           hivart.who_stage,
           hivart.no_of_days,
           hivart.tb_status,
           hivart.dsdm,
           hivart.pregnant,
           hivart.emtct
    FROM mamba_fact_encounter_hiv_art hivart

    WHERE hivart.return_date >= START_DATE
      AND hivart.return_date <= END_DATE;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art;

CREATE PROCEDURE sp_data_processing_derived_hiv_art()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_covid_create;

CREATE PROCEDURE sp_dim_client_covid_create()
BEGIN
-- $BEGIN
CREATE TABLE dim_client_covid
(
    id            INT auto_increment,
    client_id     INT           NULL,
    date_of_birth DATE          NULL,
    ageattest     INT           NULL,
    sex           NVARCHAR(50)  NULL,
    county        NVARCHAR(255) NULL,
    sub_county    NVARCHAR(255) NULL,
    ward          NVARCHAR(255) NULL,
    PRIMARY KEY (id)
);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_covid_insert;

CREATE PROCEDURE sp_dim_client_covid_insert()
BEGIN
-- $BEGIN
INSERT INTO dim_client_covid (client_id,
                              date_of_birth,
                              ageattest,
                              sex,
                              county,
                              sub_county,
                              ward)
SELECT c.client_id,
       date_of_birth,
       DATEDIFF(CAST(cd.order_date AS DATE), CAST(date_of_birth as DATE)) / 365 as ageattest,
       sex,
       county,
       sub_county,
       ward
FROM dim_client c
         INNER JOIN flat_encounter_covid cd
                    ON c.client_id = cd.client_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_covid_update;

CREATE PROCEDURE sp_dim_client_covid_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_dim_client_covid;

CREATE PROCEDURE sp_dim_client_covid()
BEGIN
-- $BEGIN
CALL sp_dim_client_covid_create();
CALL sp_dim_client_covid_insert();
CALL sp_dim_client_covid_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_create;

CREATE PROCEDURE sp_fact_encounter_covid_create()
BEGIN
-- $BEGIN
CREATE TABLE IF NOT EXISTS fact_encounter_covid
(
    encounter_id                      INT           NULL,
    client_id                         INT           NULL,
    covid_test                        NVARCHAR(255) NULL,
    order_date                        DATE          NULL,
    result_date                       DATE          NULL,
    date_assessment                   DATE          NULL,
    assessment_presentation           NVARCHAR(255) NULL,
    assessment_contact_case           INT           NULL,
    assessment_entry_country          INT           NULL,
    assessment_travel_out_country     INT           NULL,
    assessment_follow_up              INT           NULL,
    assessment_voluntary              INT           NULL,
    assessment_quarantine             INT           NULL,
    assessment_symptomatic            INT           NULL,
    assessment_surveillance           INT           NULL,
    assessment_health_worker          INT           NULL,
    assessment_frontline_worker       INT           NULL,
    assessment_rdt_confirmatory       INT           NULL,
    assessment_post_mortem            INT           NULL,
    assessment_other                  INT           NULL,
    date_onset_symptoms               DATE          NULL,
    symptom_cough                     INT           NULL,
    symptom_headache                  INT           NULL,
    symptom_red_eyes                  INT           NULL,
    symptom_sneezing                  INT           NULL,
    symptom_diarrhoea                 INT           NULL,
    symptom_sore_throat               INT           NULL,
    symptom_tiredness                 INT           NULL,
    symptom_chest_pain                INT           NULL,
    symptom_joint_pain                INT           NULL,
    symptom_loss_smell                INT           NULL,
    symptom_loss_taste                INT           NULL,
    symptom_runny_nose                INT           NULL,
    symptom_fever_chills              INT           NULL,
    symptom_muscular_pain             INT           NULL,
    symptom_general_weakness          INT           NULL,
    symptom_shortness_breath          INT           NULL,
    symptom_nausea_vomiting           INT           NULL,
    symptom_abdominal_pain            INT           NULL,
    symptom_irritability_confusion    INT           NULL,
    symptom_disturbance_consciousness INT           NULL,
    symptom_other                     INT           NULL,
    comorbidity_present               INT           NULL,
    comorbidity_tb                    INT           NULL,
    comorbidity_liver                 INT           NULL,
    comorbidity_renal                 INT           NULL,
    comorbidity_diabetes              INT           NULL,
    comorbidity_hiv_aids              INT           NULL,
    comorbidity_malignancy            INT           NULL,
    comorbidity_chronic_lung          INT           NULL,
    comorbidity_hypertension          INT           NULL,
    comorbidity_former_smoker         INT           NULL,
    comorbidity_cardiovascular        INT           NULL,
    comorbidity_current_smoker        INT           NULL,
    comorbidity_immunodeficiency      INT           NULL,
    comorbidity_chronic_neurological  INT           NULL,
    comorbidity_other                 INT           NULL,
    diagnostic_pcr_test               NVARCHAR(255) NULL,
    diagnostic_pcr_result             NVARCHAR(255) NULL,
    rapid_antigen_test                NVARCHAR(255) NULL,
    rapid_antigen_result              NVARCHAR(255) NULL,
    long_covid_description            NVARCHAR(255) NULL,
    patient_outcome                   NVARCHAR(255) NULL,
    date_recovered                    DATE          NULL,
    date_died                         DATE          NULL
);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_insert;

CREATE PROCEDURE sp_fact_encounter_covid_insert()
BEGIN
-- $BEGIN
INSERT INTO fact_encounter_covid (encounter_id,
                                  client_id,
                                  covid_test,
                                  order_date,
                                  result_date,
                                  date_assessment,
                                  assessment_presentation,
                                  assessment_contact_case,
                                  assessment_entry_country,
                                  assessment_travel_out_country,
                                  assessment_follow_up,
                                  assessment_voluntary,
                                  assessment_quarantine,
                                  assessment_symptomatic,
                                  assessment_surveillance,
                                  assessment_health_worker,
                                  assessment_frontline_worker,
                                  assessment_rdt_confirmatory,
                                  assessment_post_mortem,
                                  assessment_other,
                                  date_onset_symptoms,
                                  symptom_cough,
                                  symptom_headache,
                                  symptom_red_eyes,
                                  symptom_sneezing,
                                  symptom_diarrhoea,
                                  symptom_sore_throat,
                                  symptom_tiredness,
                                  symptom_chest_pain,
                                  symptom_joint_pain,
                                  symptom_loss_smell,
                                  symptom_loss_taste,
                                  symptom_runny_nose,
                                  symptom_fever_chills,
                                  symptom_muscular_pain,
                                  symptom_general_weakness,
                                  symptom_shortness_breath,
                                  symptom_nausea_vomiting,
                                  symptom_abdominal_pain,
                                  symptom_irritability_confusion,
                                  symptom_disturbance_consciousness,
                                  symptom_other,
                                  comorbidity_present,
                                  comorbidity_tb,
                                  comorbidity_liver,
                                  comorbidity_renal,
                                  comorbidity_diabetes,
                                  comorbidity_hiv_aids,
                                  comorbidity_malignancy,
                                  comorbidity_chronic_lung,
                                  comorbidity_hypertension,
                                  comorbidity_former_smoker,
                                  comorbidity_cardiovascular,
                                  comorbidity_current_smoker,
                                  comorbidity_immunodeficiency,
                                  comorbidity_chronic_neurological,
                                  comorbidity_other,
                                  diagnostic_pcr_test,
                                  diagnostic_pcr_result,
                                  rapid_antigen_test,
                                  rapid_antigen_result,
                                  long_covid_description,
                                  patient_outcome,
                                  date_recovered,
                                  date_died)
SELECT encounter_id,
       client_id,
       covid_test,
       cast(order_date AS DATE)          order_date,
       cast(result_date AS DATE)         result_date,
       cast(date_assessment AS DATE)     date_assessment,
       assessment_presentation,
       assessment_contact_case,
       assessment_entry_country,
       assessment_travel_out_country,
       assessment_follow_up,
       assessment_voluntary,
       assessment_quarantine,
       assessment_symptomatic,
       assessment_surveillance,
       assessment_health_worker,
       assessment_frontline_worker,
       assessment_rdt_confirmatory,
       assessment_post_mortem,
       assessment_other,
       cast(date_onset_symptoms AS DATE) date_onset_symptoms,
       symptom_cough,
       symptom_headache,
       symptom_red_eyes,
       symptom_sneezing,
       symptom_diarrhoea,
       symptom_sore_throat,
       symptom_tiredness,
       symptom_chest_pain,
       symptom_joint_pain,
       symptom_loss_smell,
       symptom_loss_taste,
       symptom_runny_nose,
       symptom_fever_chills,
       symptom_muscular_pain,
       symptom_general_weakness,
       symptom_shortness_breath,
       symptom_nausea_vomiting,
       symptom_abdominal_pain,
       symptom_irritability_confusion,
       symptom_disturbance_consciousness,
       symptom_other,
       CASE
           WHEN comorbidity_present IN ('Yes', 'True') THEN 1
           WHEN comorbidity_present IN ('False', 'No') THEN 0
           END AS                        comorbidity_present,
       comorbidity_tb,
       comorbidity_liver,
       comorbidity_renal,
       comorbidity_diabetes,
       comorbidity_hiv_aids,
       comorbidity_malignancy,
       comorbidity_chronic_lung,
       comorbidity_hypertension,
       comorbidity_former_smoker,
       comorbidity_cardiovascular,
       comorbidity_current_smoker,
       comorbidity_immunodeficiency,
       comorbidity_chronic_neurological,
       comorbidity_other,
       diagnostic_pcr_test,
       diagnostic_pcr_result,
       rapid_antigen_test,
       rapid_antigen_result,
       long_covid_description,
       patient_outcome,
       cast(date_recovered AS DATE)      date_recovered,
       cast(date_died AS DATE)           date_died
FROM flat_encounter_covid;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_update;

CREATE PROCEDURE sp_fact_encounter_covid_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid;

CREATE PROCEDURE sp_fact_encounter_covid()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_covid_create();
CALL sp_fact_encounter_covid_insert();
CALL sp_fact_encounter_covid_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_covid;

CREATE PROCEDURE sp_data_processing_derived_covid()
BEGIN
-- $BEGIN
CALL sp_dim_client_covid;
CALL sp_fact_encounter_covid;
-- $END
END //

DELIMITER ;

