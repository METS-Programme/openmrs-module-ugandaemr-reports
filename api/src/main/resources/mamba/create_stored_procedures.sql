
        
    
        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_calculate_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS fn_mamba_calculate_agegroup;

CREATE FUNCTION fn_mamba_calculate_agegroup(age INT) RETURNS VARCHAR(15)
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
-- ----------------------  fn_mamba_get_obs_value_column  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS fn_mamba_get_obs_value_column;

CREATE FUNCTION fn_mamba_get_obs_value_column(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
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
-- ----------------------  fn_mamba_age_calculator  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS fn_mamba_age_calculator;

CREATE FUNCTION fn_mamba_age_calculator (birthdate DATE,deathDate DATE) RETURNS  Integer
    DETERMINISTIC
BEGIN
    DECLARE onDate DATE;
    DECLARE today DATE;
    DECLARE bday DATE;
    DECLARE age INT;
    DECLARE todaysMonth INT;
    DECLARE bdayMonth INT;
    DECLARE todaysDay INT;
    DECLARE bdayDay INT;

    SET onDate = NULL ;

    IF birthdate IS NULL THEN
        RETURN NULL;
    ELSE
        SET today = CURDATE();

        IF onDate IS NOT NULL THEN
            SET today = onDate;
        END IF;

        IF deathDate IS NOT NULL AND today > deathDate THEN
            SET today = deathDate;
        END IF;

        SET bday = birthdate;
        SET age = YEAR(today) - YEAR(bday);
        SET todaysMonth = MONTH(today);
        SET bdayMonth = MONTH(bday);
        SET todaysDay = DAY(today);
        SET bdayDay = DAY(bday);

        IF todaysMonth < bdayMonth THEN
            SET age = age - 1;
        ELSEIF todaysMonth = bdayMonth AND todaysDay < bdayDay THEN
            SET age = age - 1;
        END IF;

        RETURN age;
    END IF;
END//

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_json_extract  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP FUNCTION IF EXISTS JSON_EXTRACT_1;
CREATE FUNCTION JSON_EXTRACT_1(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE key_length INT;
  DECLARE key_index INT;

  SET key_name = CONCAT('"', key_name, '":');
  SET key_length = CHAR_LENGTH(key_name);
  SET key_index = LOCATE(key_name, json);

  IF key_index = 0 THEN
    RETURN NULL;
  END IF;

  SET start_index = key_index + key_length;

CASE
    WHEN SUBSTRING(json, start_index, 1) = '"' THEN
      SET start_index = start_index + 1;
      SET end_index = LOCATE('"', json, start_index);
ELSE
      SET end_index = LOCATE(',', json, start_index);
      IF end_index = 0 THEN
        SET end_index = LOCATE('}', json, start_index);
END IF;
END CASE;

RETURN SUBSTRING(json, start_index, end_index - start_index);
END //

DELIMITER ;


DELIMITER //

DROP FUNCTION IF EXISTS JSON_EXTRACT_ARRAY;
CREATE FUNCTION JSON_EXTRACT_ARRAY(json TEXT, key_name VARCHAR(255)) RETURNS TEXT
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE array_text TEXT;

  SET key_name = CONCAT('"', key_name, '":');
  SET start_index = LOCATE(key_name, json);

  IF start_index = 0 THEN
    RETURN NULL;
END IF;

  SET start_index = start_index + CHAR_LENGTH(key_name);

  IF SUBSTRING(json, start_index, 1) != '[' THEN
    RETURN NULL;
END IF;

  SET start_index = start_index + 1; -- Start after the '['
  SET end_index = start_index;

  -- Loop to find the matching closing bracket for the array
  SET @bracket_counter = 1;
  WHILE @bracket_counter > 0 AND end_index <= CHAR_LENGTH(json) DO
    SET end_index = end_index + 1;
    IF SUBSTRING(json, end_index, 1) = '[' THEN
      SET @bracket_counter = @bracket_counter + 1;
    ELSEIF SUBSTRING(json, end_index, 1) = ']' THEN
      SET @bracket_counter = @bracket_counter - 1;
END IF;
END WHILE;

  IF @bracket_counter != 0 THEN
    RETURN NULL; -- The brackets are not balanced, return NULL
END IF;

  SET array_text = SUBSTRING(json, start_index, end_index - start_index);
RETURN array_text;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS JSON_EXTRACT_OBJECT;
CREATE FUNCTION JSON_EXTRACT_OBJECT(json_string TEXT, key_name VARCHAR(255)) RETURNS TEXT
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE nested_level INT DEFAULT 0;
  DECLARE substring_length INT;
  DECLARE key_str VARCHAR(255);
  DECLARE result TEXT DEFAULT '';

  SET key_str := CONCAT('"', key_name, '": {');

  -- Find the start position of the key
  SET start_index := LOCATE(key_str, json_string);
  IF start_index = 0 THEN
    RETURN NULL;
END IF;

  -- Adjust start_index to the start of the value
  SET start_index := start_index + CHAR_LENGTH(key_str);

  -- Initialize the end_index to start_index
  SET end_index := start_index;

  -- Find the end of the object
  WHILE nested_level >= 0 AND end_index <= CHAR_LENGTH(json_string) DO
    SET end_index := end_index + 1;
    SET substring_length := end_index - start_index;

    -- Check for nested objects
    IF SUBSTRING(json_string, end_index, 1) = '{' THEN
      SET nested_level := nested_level + 1;
    ELSEIF SUBSTRING(json_string, end_index, 1) = '}' THEN
      SET nested_level := nested_level - 1;
END IF;
END WHILE;

  -- Get the JSON object
  IF nested_level < 0 THEN
    -- We found a matching pair of curly braces
    SET result := SUBSTRING(json_string, start_index, substring_length);
END IF;

RETURN result;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS GET_ARRAY_ITEM_BY_INDEX;
CREATE FUNCTION GET_ARRAY_ITEM_BY_INDEX(array_string TEXT, item_index INT) RETURNS TEXT
BEGIN
  DECLARE elem_start INT DEFAULT 1;
  DECLARE elem_end INT DEFAULT 0;
  DECLARE current_index INT DEFAULT 0;
  DECLARE result TEXT DEFAULT '';

  -- If the item_index is less than 1 or the array_string is empty, return an empty string
  IF item_index < 1 OR array_string = '[]' OR TRIM(array_string) = '' THEN
    RETURN '';
END IF;

  -- Loop until we find the start quote of the desired index
  WHILE current_index < item_index DO
    -- Find the start quote of the next element
    SET elem_start = LOCATE('"', array_string, elem_end + 1);
    -- If we can't find a new element, return an empty string
    IF elem_start = 0 THEN
      RETURN '';
END IF;

    -- Find the end quote of this element
    SET elem_end = LOCATE('"', array_string, elem_start + 1);
    -- If we can't find the end quote, return an empty string
    IF elem_end = 0 THEN
      RETURN '';
END IF;

    -- Increment the current_index
    SET current_index = current_index + 1;
END WHILE;

  -- When the loop exits, current_index should equal item_index, and elem_start/end should be the positions of the quotes
  -- Extract the element
  SET result = SUBSTRING(array_string, elem_start + 1, elem_end - elem_start - 1);

RETURN result;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS JSON_VALUE_BY_KEY;

CREATE FUNCTION JSON_VALUE_BY_KEY(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE key_length INT;
    DECLARE key_index INT;
    DECLARE value_length INT;
    DECLARE extracted_value VARCHAR(255);

    -- Add the key structure to search for in the JSON string
    SET key_name = CONCAT('"', key_name, '":');
    SET key_length = CHAR_LENGTH(key_name);

    -- Locate the key within the JSON string
    SET key_index = LOCATE(key_name, json);

    -- If the key is not found, return NULL
    IF key_index = 0 THEN
        RETURN NULL;
    END IF;

    -- Set the starting index of the value
    SET start_index = key_index + key_length;

    -- Check if the value is a string (starts with a quote)
    IF SUBSTRING(json, start_index, 1) = '"' THEN
        -- Set the start index to the first character of the value (skipping the quote)
        SET start_index = start_index + 1;

        -- Find the end of the string value (the next quote)
        SET end_index = LOCATE('"', json, start_index);
        IF end_index = 0 THEN
            -- If there's no end quote, the JSON is malformed
            RETURN NULL;
        END IF;
    ELSE
        -- The value is not a string (e.g., a number, boolean, or null)
        -- Find the end of the value (either a comma or closing brace)
        SET end_index = LOCATE(',', json, start_index);
        IF end_index = 0 THEN
            SET end_index = LOCATE('}', json, start_index);
        END IF;
    END IF;

    -- Calculate the length of the extracted value
    SET value_length = end_index - start_index;

    -- Extract the value
    SET extracted_value = SUBSTRING(json, start_index, value_length);

    -- Return the extracted value without leading or trailing quotes
    RETURN TRIM(BOTH '"' FROM extracted_value);
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_json_keys  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //
DROP FUNCTION IF EXISTS JSON_KEYS_ARRAY;
CREATE FUNCTION JSON_KEYS_ARRAY(json_object TEXT) RETURNS TEXT
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE start_index INT DEFAULT 1;
    DECLARE end_index INT DEFAULT 1;
    DECLARE key_name TEXT DEFAULT '';
    DECLARE my_keys TEXT DEFAULT '';
    DECLARE json_length INT;
    DECLARE key_end_index INT;

    SET json_length = CHAR_LENGTH(json_object);

    -- Initialize the my_keys string as an empty 'array'
    SET my_keys = '';

    -- This loop goes through the JSON object and extracts the my_keys
    WHILE NOT finished DO
            -- Find the start of the key
            SET start_index = LOCATE('"', json_object, end_index);
            IF start_index = 0 OR start_index >= json_length THEN
                SET finished = 1;
            ELSE
                -- Find the end of the key
                SET end_index = LOCATE('"', json_object, start_index + 1);
                SET key_name = SUBSTRING(json_object, start_index + 1, end_index - start_index - 1);

                -- Append the key to the 'array' of my_keys
                IF my_keys = ''
                    THEN
                    SET my_keys = CONCAT('["', key_name, '"');
                ELSE
                    SET my_keys = CONCAT(my_keys, ',"', key_name, '"');
                END IF;

                -- Move past the current key-value pair
                SET key_end_index = LOCATE(',', json_object, end_index);
                IF key_end_index = 0 THEN
                    SET key_end_index = LOCATE('}', json_object, end_index);
                END IF;
                IF key_end_index = 0 THEN
                    -- Closing brace not found - malformed JSON
                    SET finished = 1;
                ELSE
                    -- Prepare for the next iteration
                    SET end_index = key_end_index + 1;
                END IF;
            END IF;
        END WHILE;

    -- Close the 'array' of my_keys
    IF my_keys != '' THEN
        SET my_keys = CONCAT(my_keys, ']');
    END IF;

    RETURN my_keys;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_json_length  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //
DROP FUNCTION IF EXISTS JSON_LENGTH_5_6;
CREATE FUNCTION JSON_LENGTH_5_6(json_array TEXT) RETURNS INT
BEGIN
    DECLARE element_count INT DEFAULT 0;
    DECLARE current_position INT DEFAULT 1;

    WHILE current_position <= LENGTH(json_array) DO
        SET element_count = element_count + 1;
        SET current_position = LOCATE(',', json_array, current_position) + 1;

        IF current_position = 0 THEN
            RETURN element_count;
        END IF;
    END WHILE;

RETURN element_count;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS JSON_ARRAY_LENGTH;

CREATE FUNCTION JSON_ARRAY_LENGTH(json_array TEXT) RETURNS INT
BEGIN
    DECLARE array_length INT DEFAULT 0;
    DECLARE current_pos INT DEFAULT 1;
    DECLARE char_val CHAR(1);

    IF json_array IS NULL THEN
        RETURN 0;
    END IF;

  -- Iterate over the string to count the number of objects based on commas and curly braces
    WHILE current_pos <= CHAR_LENGTH(json_array) DO
        SET char_val = SUBSTRING(json_array, current_pos, 1);

    -- Check for the start of an object
        IF char_val = '{' THEN
            SET array_length = array_length + 1;

      -- Move current_pos to the end of this object
            SET current_pos = LOCATE('}', json_array, current_pos) + 1;
        ELSE
            SET current_pos = current_pos + 1;
        END IF;
    END WHILE;

    RETURN array_length;
END //

DELIMITER ;

DELIMITER //

DROP FUNCTION IF EXISTS JSON_OBJECT_AT_INDEX;
CREATE FUNCTION JSON_OBJECT_AT_INDEX(json_array TEXT, index_pos INT) RETURNS TEXT
BEGIN
  DECLARE obj_start INT DEFAULT 1;
  DECLARE obj_end INT DEFAULT 1;
  DECLARE current_index INT DEFAULT 0;
  DECLARE obj_text TEXT;

  -- Handle negative index_pos or json_array being NULL
  IF index_pos < 1 OR json_array IS NULL THEN
    RETURN NULL;
END IF;

  -- Find the start of the requested object
  WHILE obj_start < CHAR_LENGTH(json_array) AND current_index < index_pos DO
    SET obj_start = LOCATE('{', json_array, obj_end);

    -- If we can't find a new object, return NULL
    IF obj_start = 0 THEN
      RETURN NULL;
END IF;

    SET current_index = current_index + 1;
    -- If this isn't the object we want, find the end and continue
    IF current_index < index_pos THEN
      SET obj_end = LOCATE('}', json_array, obj_start) + 1;
END IF;
END WHILE;

  -- Now obj_start points to the start of the desired object
  -- Find the end of it
  SET obj_end = LOCATE('}', json_array, obj_start);
  IF obj_end = 0 THEN
    -- The object is not well-formed
    RETURN NULL;
END IF;

  -- Extract the object
  SET obj_text = SUBSTRING(json_array, obj_start, obj_end - obj_start + 1);
RETURN obj_text;
END //

DELIMITER ;


DELIMITER //
DROP FUNCTION IF EXISTS ARRAY_LENGTH;
CREATE FUNCTION ARRAY_LENGTH(array_string TEXT) RETURNS INT
BEGIN
  DECLARE length INT DEFAULT 0;
  DECLARE i INT DEFAULT 1;

  -- If the array_string is not empty, initialize length to 1
  IF TRIM(array_string) != '' AND TRIM(array_string) != '[]' THEN
    SET length = 1;
END IF;

  -- Count the number of commas in the array string
  WHILE i <= CHAR_LENGTH(array_string) DO
    IF SUBSTRING(array_string, i, 1) = ',' THEN
      SET length = length + 1;
END IF;
    SET i = i + 1;
END WHILE;

RETURN length;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_json_quote  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //
DROP FUNCTION IF EXISTS REMOVE_ALL_WHITESPACE;
CREATE FUNCTION REMOVE_ALL_WHITESPACE(input_string TEXT) RETURNS TEXT
BEGIN
  DECLARE cleaned_string TEXT;
  SET cleaned_string = input_string;

  -- Replace common whitespace characters
  SET cleaned_string = REPLACE(cleaned_string, CHAR(9), '');   -- Horizontal tab
  SET cleaned_string = REPLACE(cleaned_string, CHAR(10), '');  -- Line feed
  SET cleaned_string = REPLACE(cleaned_string, CHAR(13), '');  -- Carriage return
  SET cleaned_string = REPLACE(cleaned_string, CHAR(32), '');  -- Space
  SET cleaned_string = REPLACE(cleaned_string, CHAR(160), ''); -- Non-breaking space

RETURN TRIM(cleaned_string);
END //

DELIMITER ;


DELIMITER //
DROP FUNCTION IF EXISTS REMOVE_QUOTES;
CREATE FUNCTION REMOVE_QUOTES(original TEXT) RETURNS TEXT
BEGIN
  DECLARE without_quotes TEXT;

  -- Replace both single and double quotes with nothing
  SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');

RETURN REMOVE_ALL_WHITESPACE(without_quotes);
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_functions_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_stored_functions_in_schema;

CREATE PROCEDURE sp_xf_system_drop_all_stored_functions_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8
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
    IN database_name CHAR(255) CHARACTER SET UTF8
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
    IN database_name CHAR(255) CHARACTER SET UTF8
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

-- CREATE PROCEDURE sp_xf_system_drop_all_tables_in_schema(IN database_name CHAR(255) CHARACTER SET UTF8)
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
-- ----------------------  sp_mamba_flat_encounter_table_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_create;

CREATE PROCEDURE sp_mamba_flat_encounter_table_create(
    IN flat_encounter_table_name VARCHAR(255) CHARSET UTF8
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
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT NOT NULL, client_id INT NOT NULL, encounter_datetime DATETIME NOT NULL);');
    ELSE
        SET @create_table = CONCAT(
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT NOT NULL, client_id INT NOT NULL, encounter_datetime DATETIME NOT NULL, ', @column_labels,
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
-- ----------------------  sp_mamba_flat_encounter_table_create_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_create_all;

CREATE PROCEDURE sp_mamba_flat_encounter_table_create_all()
BEGIN

    DECLARE tbl_name CHAR(50) CHARACTER SET UTF8;

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

        CALL sp_mamba_flat_encounter_table_create(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = flat_encounter_table_name;

    SET @old_sql = (SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ')
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = @tbl_name
                      AND TABLE_SCHEMA = Database());

    SELECT
        GROUP_CONCAT(DISTINCT
            CONCAT(' MAX(CASE WHEN column_label = ''', column_label, ''' THEN ',
                fn_mamba_get_obs_value_column(concept_datatype), ' END) ', column_label)
            ORDER BY id ASC)
    INTO @column_labels
    FROM mamba_dim_concept_metadata
    WHERE flat_table_name = @tbl_name;

    SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_name, '` SELECT eo.encounter_id, eo.person_id, eo.encounter_datetime, ',
            @column_labels, '
            FROM mamba_z_encounter_obs eo
                INNER JOIN mamba_dim_concept_metadata cm
                ON IF(cm.concept_answer_obs=1, cm.concept_uuid=eo.obs_value_coded_uuid, cm.concept_uuid=eo.obs_question_uuid)
            WHERE cm.flat_table_name = ''', @tbl_name, '''
            AND eo.encounter_type_uuid = cm.encounter_type_uuid
            GROUP BY eo.encounter_id, eo.person_id, eo.encounter_datetime;');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_insert_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert_all;

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert_all()
BEGIN

    DECLARE tbl_name CHAR(50) CHARACTER SET UTF8;

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

        CALL sp_mamba_flat_encounter_table_insert(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_multiselect_values_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_mamba_multiselect_values_update`;

CREATE PROCEDURE `sp_mamba_multiselect_values_update`(
    IN table_to_update CHAR(100) CHARACTER SET UTF8,
    IN column_names TEXT CHARACTER SET UTF8,
    IN value_yes CHAR(100) CHARACTER SET UTF8,
    IN value_no CHAR(100) CHARACTER SET UTF8
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
-- ----------------------  sp_mamba_extract_report_metadata  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_extract_report_metadata;

CREATE PROCEDURE sp_mamba_extract_report_metadata(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8,
    IN metadata_table VARCHAR(255) CHARSET UTF8
)
BEGIN

    SET session group_concat_max_len = 20000;

SELECT  JSON_EXTRACT_ARRAY(report_data, 'flat_report_metadata') INTO @report_array;
SELECT JSON_ARRAY_LENGTH(@report_array) INTO @report_array_len;

SET @report_count = 1;
    WHILE @report_count <= @report_array_len
        DO
            SELECT  JSON_OBJECT_AT_INDEX(@report_array, @report_count) INTO @report;
            SET @report =  CONCAT(@report,'}');
            SELECT  JSON_EXTRACT_1(@report, 'report_name') INTO @report_name;
            SELECT  JSON_EXTRACT_1(@report, 'flat_table_name') INTO @flat_table_name;
            SELECT  JSON_EXTRACT_1(@report, 'encounter_type_uuid') INTO @encounter_type;
            SELECT  JSON_EXTRACT_1(@report, 'concepts_locale') INTO @concepts_locale;
            SELECT  JSON_EXTRACT_OBJECT(@report, 'table_columns') INTO @column_array;
            SELECT JSON_KEYS_ARRAY(@column_array) INTO @column_keys_array;
            SELECT ARRAY_LENGTH(@column_keys_array) INTO @column_keys_array_len;

            SET @col_count = 1;
            SET @column_array = CONCAT('{',@column_array,'}');
            WHILE @col_count <= @column_keys_array_len
                DO
                    SELECT  GET_ARRAY_ITEM_BY_INDEX(@column_keys_array, @col_count) INTO @field_name;
                    SELECT JSON_VALUE_BY_KEY(@column_array,  @field_name) INTO @concept_uuid;

                    SET @tbl_name = '';
                    INSERT INTO mamba_dim_concept_metadata
                        (
                            report_name,
                            flat_table_name,
                            encounter_type_uuid,
                            column_label,
                            concept_uuid,
                            concepts_locale
                        )
                    VALUES (REMOVE_QUOTES(@report_name),
                            REMOVE_QUOTES(@flat_table_name),
                            REMOVE_QUOTES(@encounter_type),
                            REMOVE_QUOTES(@field_name),
                            REMOVE_QUOTES(@concept_uuid),
                            REMOVE_QUOTES(@concepts_locale));

                    SET @col_count = @col_count + 1;
            END WHILE;

            SET @report_count = @report_count + 1;
    END WHILE;

END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_load_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_load_agegroup;

CREATE PROCEDURE sp_mamba_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO mamba_dim_agegroup(age, datim_agegroup, normal_agegroup)
            VALUES (age, fn_mamba_calculate_agegroup(age), IF(age < 15, '<15', '15+'));
            SET age = age + 1;
        END WHILE;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_create;

CREATE PROCEDURE sp_mamba_dim_location_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_location
(
    id              INT          NOT NULL AUTO_INCREMENT,
    location_id     INT          NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     VARCHAR(255) NULL,
    city_village    VARCHAR(255) NULL,
    state_province  VARCHAR(255) NULL,
    postal_code     VARCHAR(50)  NULL,
    country         VARCHAR(50)  NULL,
    latitude        VARCHAR(50)  NULL,
    longitude       VARCHAR(50)  NULL,
    county_district VARCHAR(255) NULL,
    address1        VARCHAR(255) NULL,
    address2        VARCHAR(255) NULL,
    address3        VARCHAR(255) NULL,
    address4        VARCHAR(255) NULL,
    address5        VARCHAR(255) NULL,
    address6        VARCHAR(255) NULL,
    address7        VARCHAR(255) NULL,
    address8        VARCHAR(255) NULL,
    address9        VARCHAR(255) NULL,
    address10       VARCHAR(255) NULL,
    address11       VARCHAR(255) NULL,
    address12       VARCHAR(255) NULL,
    address13       VARCHAR(255) NULL,
    address14       VARCHAR(255) NULL,
    address15       VARCHAR(255) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_location_location_id_index
    ON mamba_dim_location (location_id);

CREATE INDEX mamba_dim_location_name_index
    ON mamba_dim_location (name);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_insert;

CREATE PROCEDURE sp_mamba_dim_location_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_location (location_id,
                                name,
                                description,
                                city_village,
                                state_province,
                                postal_code,
                                country,
                                latitude,
                                longitude,
                                county_district,
                                address1,
                                address2,
                                address3,
                                address4,
                                address5,
                                address6,
                                address7,
                                address8,
                                address9,
                                address10,
                                address11,
                                address12,
                                address13,
                                address14,
                                address15)
SELECT location_id,
       name,
       description,
       city_village,
       state_province,
       postal_code,
       country,
       latitude,
       longitude,
       county_district,
       address1,
       address2,
       address3,
       address4,
       address5,
       address6,
       address7,
       address8,
       address9,
       address10,
       address11,
       address12,
       address13,
       address14,
       address15
FROM location;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_update;

CREATE PROCEDURE sp_mamba_dim_location_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_location;

CREATE PROCEDURE sp_mamba_dim_location()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_location_create();
CALL sp_mamba_dim_location_insert();
CALL sp_mamba_dim_location_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_create;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier_type
(
    id                         INT         NOT NULL AUTO_INCREMENT,
    patient_identifier_type_id INT         NOT NULL,
    name                       VARCHAR(50) NOT NULL,
    description                TEXT        NULL,
    uuid                       CHAR(38)    NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_patient_identifier_type_id_index
    ON mamba_dim_patient_identifier_type (patient_identifier_type_id);

CREATE INDEX mamba_dim_patient_identifier_type_name_index
    ON mamba_dim_patient_identifier_type (name);

CREATE INDEX mamba_dim_patient_identifier_type_uuid_index
    ON mamba_dim_patient_identifier_type (uuid);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_insert;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name,
                                               description,
                                               uuid)
SELECT patient_identifier_type_id,
       name,
       description,
       uuid
FROM patient_identifier_type;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_update;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_type()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_patient_identifier_type_create();
CALL sp_mamba_dim_patient_identifier_type_insert();
CALL sp_mamba_dim_patient_identifier_type_update();

-- $END
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
    id                  INT          NOT NULL AUTO_INCREMENT,
    concept_datatype_id INT          NOT NULL,
    datatype_name       VARCHAR(255) NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_datatype_concept_datatype_id_index
    ON mamba_dim_concept_datatype (concept_datatype_id);

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

INSERT INTO mamba_dim_concept_datatype (concept_datatype_id,
                                        datatype_name)
SELECT dt.concept_datatype_id AS concept_datatype_id,
       dt.name                AS datatype_name
FROM concept_datatype dt;
-- WHERE dt.retired = 0;

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
    id          INT          NOT NULL AUTO_INCREMENT,
    concept_id  INT          NOT NULL,
    uuid        CHAR(38)     NOT NULL,
    datatype_id INT NOT NULL, -- make it a FK
    datatype    VARCHAR(100) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_concept_id_index
    ON mamba_dim_concept (concept_id);

CREATE INDEX mamba_dim_concept_uuid_index
    ON mamba_dim_concept (uuid);

CREATE INDEX mamba_dim_concept_datatype_id_index
    ON mamba_dim_concept (datatype_id);

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
                               concept_id,
                               datatype_id)
SELECT c.uuid        AS uuid,
       c.concept_id  AS concept_id,
       c.datatype_id AS datatype_id
FROM concept c;
-- WHERE c.retired = 0;

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
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.datatype_name
WHERE c.id > 0;

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
    id                INT NOT NULL AUTO_INCREMENT,
    concept_answer_id INT NOT NULL,
    concept_id        INT NOT NULL,
    answer_concept    INT,
    answer_drug       INT,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_answer_concept_answer_id_index
    ON mamba_dim_concept_answer (concept_answer_id);

CREATE INDEX mamba_dim_concept_answer_concept_id_index
    ON mamba_dim_concept_answer (concept_id);

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

INSERT INTO mamba_dim_concept_answer (concept_answer_id,
                                      concept_id,
                                      answer_concept,
                                      answer_drug)
SELECT ca.concept_answer_id AS concept_answer_id,
       ca.concept_id        AS concept_id,
       ca.answer_concept    AS answer_concept,
       ca.answer_drug       AS answer_drug
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
    id                INT          NOT NULL AUTO_INCREMENT,
    concept_name_id   INT          NOT NULL,
    concept_id        INT,
    name              VARCHAR(255) NOT NULL,
    locale            VARCHAR(50)  NOT NULL,
    locale_preferred  TINYINT,
    concept_name_type VARCHAR(255),

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_name_concept_name_id_index
    ON mamba_dim_concept_name (concept_name_id);

CREATE INDEX mamba_dim_concept_name_concept_id_index
    ON mamba_dim_concept_name (concept_id);

CREATE INDEX mamba_dim_concept_name_concept_name_type_index
    ON mamba_dim_concept_name (concept_name_type);

CREATE INDEX mamba_dim_concept_name_locale_index
    ON mamba_dim_concept_name (locale);

CREATE INDEX mamba_dim_concept_name_locale_preferred_index
    ON mamba_dim_concept_name (locale_preferred);

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

INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    concept_name_type)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.concept_name_type
FROM concept_name cn
 WHERE cn.locale = 'en'
  AND cn.locale_preferred = 1
    AND cn.voided = 0;

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
    id                INT      NOT NULL AUTO_INCREMENT,
    encounter_type_id INT      NOT NULL,
    uuid              CHAR(38) NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_encounter_type_encounter_type_id_index
    ON mamba_dim_encounter_type (encounter_type_id);

CREATE INDEX mamba_dim_encounter_type_uuid_index
    ON mamba_dim_encounter_type (uuid);

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

INSERT INTO mamba_dim_encounter_type (encounter_type_id,
                                      uuid)
SELECT et.encounter_type_id,
       et.uuid
FROM encounter_type et;
-- WHERE et.retired = 0;

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
    id                  INT        NOT NULL AUTO_INCREMENT,
    encounter_id        INT        NOT NULL,
    uuid                CHAR(38)   NOT NULL,
    encounter_type      INT        NOT NULL,
    encounter_type_uuid CHAR(38)   NULL,
    patient_id          INT        NOT NULL,
    encounter_datetime  DATETIME   NOT NULL,
    date_created        DATETIME   NOT NULL,
    voided              TINYINT NOT NULL,
    visit_id            INT        NULL,

    CONSTRAINT encounter_encounter_id_index
        UNIQUE (encounter_id),

    CONSTRAINT encounter_uuid_index
        UNIQUE (uuid),

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_encounter_encounter_id_index
    ON mamba_dim_encounter (encounter_id);

CREATE INDEX mamba_dim_encounter_encounter_type_index
    ON mamba_dim_encounter (encounter_type);

CREATE INDEX mamba_dim_encounter_uuid_index
    ON mamba_dim_encounter (uuid);

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

INSERT INTO mamba_dim_encounter (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 encounter_datetime,
                                 date_created,
                                 voided,
                                 visit_id)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.encounter_datetime,
       e.date_created,
       e.voided,
       e.visit_id
FROM encounter e
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id
WHERE et.uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_dim_concept_metadata md);

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
    id                  INT          NOT NULL AUTO_INCREMENT,
    concept_id          INT          NULL,
    concept_uuid        CHAR(38)     NOT NULL,
    concept_name        VARCHAR(255) NULL,
    concepts_locale     VARCHAR(20)  NOT NULL,
    column_number       INT,
    column_label        VARCHAR(50)  NOT NULL,
    concept_datatype    VARCHAR(255) NULL,
    concept_answer_obs  TINYINT      NOT NULL DEFAULT 0,
    report_name         VARCHAR(255) NOT NULL,
    flat_table_name     VARCHAR(255) NULL,
    encounter_type_uuid CHAR(38)     NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_metadata_concept_id_index
    ON mamba_dim_concept_metadata (concept_id);

CREATE INDEX mamba_dim_concept_metadata_concept_uuid_index
    ON mamba_dim_concept_metadata (concept_uuid);

CREATE INDEX mamba_dim_concept_metadata_encounter_type_uuid_index
    ON mamba_dim_concept_metadata (encounter_type_uuid);

CREATE INDEX mamba_dim_concept_metadata_concepts_locale_index
    ON mamba_dim_concept_metadata (concepts_locale);

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
  "report_name": "ART_Card_Encounter",
  "flat_table_name": "mamba_flat_encounter_art_card",
  "encounter_type_uuid": "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f",
  "concepts_locale": "en",
  "table_columns": {
    "method_of_family_planning": "dc7620b3-30ab-102d-86b0-7a5022ba4115",
    "cd4": "dc86e9fb-30ab-102d-86b0-7a5022ba4115",
    "hiv_viral_load": "dc8d83e3-30ab-102d-86b0-7a5022ba4115",
    "historical_drug_start_date": "1190AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "historical_drug_stop_date": "1191AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "medication_orders": "1282AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "viral_load_qualitative": "dca12261-30ab-102d-86b0-7a5022ba4115",
    "hepatitis_b_test___qualitative": "dca16e53-30ab-102d-86b0-7a5022ba4115",
    "duration_units": "1732AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "return_visit_date": "dcac04cf-30ab-102d-86b0-7a5022ba4115",
    "cd4_count": "dcbcba2c-30ab-102d-86b0-7a5022ba4115",
    "estimated_date_of_confinement": "dcc033e5-30ab-102d-86b0-7a5022ba4115",
    "pmtct": "dcd7e8e5-30ab-102d-86b0-7a5022ba4115",
    "pregnant": "dcda5179-30ab-102d-86b0-7a5022ba4115",
    "scheduled_patient_visist": "dcda9857-30ab-102d-86b0-7a5022ba4115",
    "who_hiv_clinical_stage": "dcdff274-30ab-102d-86b0-7a5022ba4115",
    "name_of_location_transferred_to": "dce015bb-30ab-102d-86b0-7a5022ba4115",
    "tuberculosis_status": "dce02aa1-30ab-102d-86b0-7a5022ba4115",
    "tuberculosis_treatment_start_date": "dce02eca-30ab-102d-86b0-7a5022ba4115",
    "adherence_assessment_code": "dce03b2f-30ab-102d-86b0-7a5022ba4115",
    "reason_for_missing_arv_administration": "dce045a4-30ab-102d-86b0-7a5022ba4115",
    "medication_or_other_side_effects": "dce05b7f-30ab-102d-86b0-7a5022ba4115",
    "family_planning_status": "dce0a659-30ab-102d-86b0-7a5022ba4115",
    "symptom_diagnosis": "dce0e02a-30ab-102d-86b0-7a5022ba4115",
    "transfered_out_to_another_facility": "dd27a783-30ab-102d-86b0-7a5022ba4115",
    "tuberculosis_treatment_stop_date": "dd2adde2-30ab-102d-86b0-7a5022ba4115",
    "current_arv_regimen": "dd2b0b4d-30ab-102d-86b0-7a5022ba4115",
    "art_duration": "9ce522a8-cd6a-4254-babb-ebeb48b8ce2f",
    "current_art_duration": "171de3f4-a500-46f6-8098-8097561dfffb",
    "mid_upper_arm_circumference_code": "5f86d19d-9546-4466-89c0-6f80c101191b",
    "district_tuberculosis_number": "67e9ec2f-4c72-408b-8122-3706909d77ec",
    "other_medications_dispensed": "b04eaf95-77c9-456a-99fb-f668f58a9386",
    "arv_regimen_days_dispensed": "7593ede6-6574-4326-a8a6-3d742e843659",
    "ar_regimen_dose": "b0e53f0a-eaca-49e6-b663-d0df61601b70",
    "nutrition_support_and_infant_feeding": "8531d1a7-9793-4c62-adab-f6716cf9fabb",
    "other_side_effects": "d4f4c0e7-06f5-4aa6-a218-17b1f97c5a44",
    "other_reason_for_missing_arv": "d14ea061-e36f-40df-ab8c-bd8f933a9e0a",
    "current_regimen_other": "97c48198-3cf7-4892-a3e6-d61fb1125882",
    "transfer_out_date": "fc1b1e96-4afb-423b-87e5-bb80d451c967",
    "cotrim_given": "c3d744f6-00ef-4774-b9a7-d33c58f5b014",
    "syphilis_test_result_for_partner": "d8bc9915-ed4b-4df9-9458-72ca1bc2cd06",
    "eid_visit_1_z_score": "01b61dfb-7be9-4de5-8880-b37fefc253ba",
    "medication_duration": "159368AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "medication_prescribed_per_dose": "160856AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "tuberculosis_polymerase": "162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "specimen_sources": "162476AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "estimated_gestational_age": "0b995cb8-7d0d-46c0-bd1a-bd322387c870",
    "hiv_viral_load_date": "0b434cfa-b11c-4d14-aaa2-9aed6ca2da88",
    "other_reason_for_appointment": "e17524f4-4445-417e-9098-ecdd134a6b81",
    "nutrition_assesment": "165050AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "differentiated_service_delivery": "73312fee-c321-11e8-a355-529269fb1459",
    "stable_in_dsdm": "cc183c11-0f94-4992-807c-84f33095ce37",
    "tpt_start_date": "483939c7-79ba-4ca4-8c3e-346488c97fc7",
    "tpt_completion_date": "813e21e7-4ccb-4fe9-aaab-3c0e40b6e356",
    "advanced_disease_status": "17def5f6-d6b4-444b-99ed-40eb05d2c4f8",
    "tpt_status": "37d4ac43-b3b4-4445-b63b-e3acf47c8910",
    "rpr_test_results": "d462b4f6-fb37-4e19-8617-e5499626c234",
    "crag_test_results": "43c33e93-90ff-406b-b7b2-9c655b2a561a",
    "tb_lam_results": "066b84a0-e18f-4cdd-a0d7-189454f4c7a4",
    "cervical_cancer_screening": "5029d903-51ba-4c44-8745-e97f320739b6",
    "intention_to_conceive": "ede98e0d-0e04-49c6-b6bd-902ad759a084",
    "tb_microscopy_results": "215d1c92-43f4-4aee-9875-31047f30132c",
    "quantity_unit": "dfc50562-da6a-4ce2-ab80-43c8f2d64d6f",
    "tpt_side_effects": "23a6dc6e-ac16-4fa6-8029-155522548d04",
    "lab_number": "0f998893-ab24-4ee4-922a-f197ac5fd6e6",
    "test": "472b6d0f-3f63-4647-8a5c-8223dd1207f5",
    "test_result": "2cab2216-1aec-49d2-919b-d910bae973fb",
    "refill_point_code": "7a22cfcb-a272-4eff-968c-5e9467125a7b",
    "next_return_date_at_facility": "f6c456f7-1ab4-4b4d-a3b4-e7417c81002a",
    "indication_for_viral_load_testing": "59f36196-3ebe-4fea-be92-6fc9551c3a11"
  }
},
  {
  "report_name": "ART_Health_Education_card",
  "flat_table_name": "mamba_flat_encounter_art_health_education",
  "encounter_type_uuid": "6d88e370-f2ba-476b-bf1b-d8eaf3b1b67e",
  "concepts_locale": "en",
  "table_columns": {
    "scheduled_patient_visit": "dcda9857-30ab-102d-86b0-7a5022ba4115",
    "health_education_disclosure": "8bdff534-6b4b-44ca-bc88-d088b3b53431",
    "clinic_contact_comments": "1648e8a1-ed34-4318-87d8-735da453fb38",
    "clinical_impression_comment": "159395AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "health_education_setting": "2d5a0641-ef12-4101-be76-533d4ba651df",
    "intervation_approaches": "eb7c1c34-59e5-46d5-beba-626694badd54",
    "linkages_and_refferals": "a806304b-bef4-483f-b4d0-9514bfc80621",
    "depression_status": "fe9a6bfc-b0db-4bf3-bab6-a8800dd93ded",
    "ovc_screening": "c2f9c9f3-3e46-456c-9f17-7bb23c473f1b",
    "art_preparation": "47502ce3-fc55-41e6-a61c-54a4404dd0e1",
    "ovc_assessment": "cb07b087-effb-4679-9e1c-5bcc506b5599",
    "prevention_components": "d788b8df-f25d-49e7-b946-bf5fe2d9407c",
    "pss_issues_identified": "1760ea50-8f05-4675-aedd-d55f99541aa8",
    "other_linkages": "609193dc-ea2a-4746-9074-675661c025d0",
    "other_phdp_components": "ccaba007-ea6c-4dae-a3b0-07118ddf5008",
    "gender_based_violance": "23a37400-f855-405b-9268-cb2d25b97f54"
  }
},
  {
  "report_name": "non_suppressed_card",
  "flat_table_name": "mamba_flat_encounter_non_suppressed",
  "encounter_type_uuid": "38cb2232-30fc-4b1f-8df1-47c795771ee9",
  "concepts_locale": "en",
  "table_columns": {
    "vl_qualitative": "dca12261-30ab-102d-86b0-7a5022ba4115",
    "register_serial_number": "1646AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "cd4_count": "dcbcba2c-30ab-102d-86b0-7a5022ba4115",
    "tuberculosis_status": "dce02aa1-30ab-102d-86b0-7a5022ba4115",
    "current_arv_regimen": "dd2b0b4d-30ab-102d-86b0-7a5022ba4115",
    "breast_feeding": "9e5ac0a8-6041-4feb-8c07-fe522ef5f9ab",
    "eligible_for_art_pregnant": "63d67ada-bb8a-4ba0-a2a0-c60c9b7a00ce",
    "clinical_impression_comment": "159395AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "hiv_vl_date": "0b434cfa-b11c-4d14-aaa2-9aed6ca2da88",
    "date_vl_results_received_at_facility": "163150AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "session_date": "163154AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "adherence_assessment_score": "1134AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "date_vl_results_given_to_client": "163156AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "serum_crag_screening_result": "164986AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "serum_crag_screening": "164987AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "restarted_iac": "164988AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "hivdr_sample_collected": "164989AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "tb_lam_results": "066b84a0-e18f-4cdd-a0d7-189454f4c7a4",
    "date_cd4_sample_collected": "1ae6f663-d3b0-4527-bb8f-4ed18a9ca96c",
    "date_of_vl_sample_collection": "c4389c60-32f5-4390-b7c6-9095ff880df5",
    "on_fluconazole_treatment": "25a839f2-ab34-4a22-aa4d-558cdbcedc43",
    "tb_lam_test_done": "8f1ac242-b497-41eb-b140-36ba6ab2d4d4",
    "date_hivr_results_recieved_at_facility": "b913c0d9-f279-4e43-bb8e-3d1a4cf1ad4d",
    "hivdr_results": "1c654215-fcc4-439f-a975-ced21995ed15"
  }
},
  {
  "report_name": "ART_Summary_card",
  "flat_table_name": "mamba_flat_encounter_art_summary_card",
  "encounter_type_uuid": "8d5b27bc-c2cc-11de-8d13-0010c6dffd0f",
  "concepts_locale": "en",
  "table_columns": {
    "allergy": "dc674105-30ab-102d-86b0-7a5022ba4115",
    "hepatitis_b_test_qualitative": "dca16e53-30ab-102d-86b0-7a5022ba4115",
    "hepatitis_c_test_qualitative": "dca17ac9-30ab-102d-86b0-7a5022ba4115",
    "lost_to_followup": "dcb23465-30ab-102d-86b0-7a5022ba4115",
    "currently_in_school": "dcc3a7e9-30ab-102d-86b0-7a5022ba4115",
    "pmtct": "dcd7e8e5-30ab-102d-86b0-7a5022ba4115",
    "entry_point_into_hiv_care": "dcdfe3ce-30ab-102d-86b0-7a5022ba4115",
    "name_of_location_transferred_from": "dcdffef2-30ab-102d-86b0-7a5022ba4115",
    "date_lost_to_followup": "dce00b87-30ab-102d-86b0-7a5022ba4115",
    "name_of_location_transferred_to": "dce015bb-30ab-102d-86b0-7a5022ba4115",
    "patient_unique_identifier": "dce11a89-30ab-102d-86b0-7a5022ba4115",
    "address": "dce122f3-30ab-102d-86b0-7a5022ba4115",
    "date_positive_hiv_test_confirmed": "dce12b4f-30ab-102d-86b0-7a5022ba4115",
    "hiv_care_status": "dce13f66-30ab-102d-86b0-7a5022ba4115",
    "treatment_supporter_telephone_number": "dce17480-30ab-102d-86b0-7a5022ba4115",
    "transfered_out_to_another_facility": "dd27a783-30ab-102d-86b0-7a5022ba4115",
    "prior_art": "902e30a1-2d10-4e92-8f77-784b6677109a",
    "post_exposure_prophylaxis": "966db6f2-a9f2-4e47-bba2-051467c77c17",
    "prior_art_not_transfer": "240edc6a-5c70-46ce-86cf-1732bc21e95c",
    "baseline_regimen": "c3332e8d-2548-4ad6-931d-6855692694a3",
    "transfer_in_regimen": "9a9314ed-0756-45d0-b37c-ace720ca439c",
    "baseline_weight": "900b8fd9-2039-4efc-897b-9b8ce37396f5",
    "baseline_stage": "39243cef-b375-44b1-9e79-cbf21bd10878",
    "baseline_cd4": "c17bd9df-23e6-4e65-ba42-eb6d9250ca3f",
    "baseline_pregnancy": "b253be65-0155-4b43-ad15-88bc797322c9",
    "name_of_family_member": "e96d0880-e80e-4088-9787-bb2623fd46af",
    "age_of_family_member": "4049d989-b99e-440d-8f70-c222aa9fe45c",
    "hiv_test": "ddcd8aad-9085-4a88-a411-f19521be4785",
    "hiv_test_facility": "89d3ee61-7c74-4537-b199-4026bd6a3f67",
    "other_care_entry_point": "adf31c43-c9a0-4ab8-b53a-42097eb3d2b6",
    "treatment_supporter_tel_no_owner": "201d5b56-2420-4be0-92bc-69cd40ef291b",
    "treatment_supporter_name": "23e28311-3c17-4137-8eee-69860621b80b",
    "pep_regimen_start_date": "999dea3b-ad8b-45b4-b858-d7ab98de486c",
    "pmtct_regimen_start_date": "3f125b4f-7c60-4a08-9f8d-c9936e0bb422",
    "earlier_arv_not_transfer_regimen_start_date": "5e0d5edc-486c-41f1-8429-fbbad5416629",
    "transfer_in_regimen_start_date": "f363f153-f659-438b-802f-9cc1828b5fa9",
    "baseline_regimen_start_date": "ab505422-26d9-41f1-a079-c3d222000440",
    "transfer_out_date": "fc1b1e96-4afb-423b-87e5-bb80d451c967",
    "baseline_regimen_other": "cc3d64df-61a5-4c5a-a755-6e95d6ef3295",
    "transfer_in_regimen_other": "a5bfc18e-c6db-4d5d-81f5-18d61b1355a8",
    "hep_b_prior_art": "4937ae55-afed-48b0-abb5-aad1152d9d4c",
    "hep_b_prior_art_regimen_start_date": "ce1d514c-142b-4b93-aea2-6d24b7cc9614",
    "baseline_lactating": "ab7bb4db-1a54-4225-b71c-d8e138b471e9",
    "age_unit": "33b18e88-0eb9-48f0-8023-2e90caad4469",
    "eid_enrolled": "e77b5448-129f-4b1a-8464-c684fb7dbde8",
    "drug_restart_date": "160738AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "relationship_to_patient": "164352AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "pre_exposure_prophylaxis": "a75ab6b0-dbe7-4037-93aa-f1dfd3976f10",
    "hts_special_category": "927563c5-cb91-4536-b23c-563a72d3f829",
    "special_category": "927563c5-cb91-4536-b23c-563a72d3f829",
    "other_special_category": "eac4e9c2-a086-43fc-8d43-b5a4e02febb4",
    "tpt_start_date": "483939c7-79ba-4ca4-8c3e-346488c97fc7",
    "tpt_completion_date": "813e21e7-4ccb-4fe9-aaab-3c0e40b6e356",
    "treatment_interruption_type": "3aaf3680-6240-4819-a704-e20a93841942",
    "treatment_interruption": "65d1bdf6-e518-4400-9f61-b7f2b1e80169",
    "treatment_interruption_stop_date": "ac98d431-8ebc-4397-8c78-78b0eee0ffe7",
    "treatment_interruption_reason": "af0b99f2-4ef5-49a8-b208-e5585ba5538a",
    "hepatitis_b_test_date": "53df33eb-4060-4300-8b7e-0f0784947767",
    "hepatitis_c_test_date": "d8fcb0c7-6e6e-4efc-ac2b-3fae764fd198",
    "blood_sugar_test_date": "612ab515-94f7-4c56-bb1b-be613bf10543",
    "pre_exposure_prophylaxis_start_date": "9a7b4b98-4cbb-4f94-80aa-d80a56084181",
    "prep_duration_in_months": "d11d4ad1-4aa2-4f90-8f2c-83f52155f0fc",
    "pep_duration_in_months": "0b5fa454-0757-4f6d-b376-fefd60ae42ba",
    "hep_b_duration_in_months": "33a2a6fb-c02c-4015-810d-71d0761c8dd5",
    "blood_sugar_test_result": "10a3fc87-f37e-4715-8cd9-7c8ad9e58914",
    "pmtct_duration_in_months": "0f7e7d9d-d8d1-4ef8-9d61-ae5d17da4d1e",
    "earlier_arv_not_transfer_duration_in_months": "666afa00-2cbf-4ca0-9576-2c89a19fe466",
    "family_member_hiv_status": "1f98a7e6-4d0a-4008-a6f7-4ec118f08983",
    "family_member_hiv_test_date": "b7f597e7-39b5-419e-9ec5-de5901fffb52",
    "hiv_enrollment_date": "31c5c7aa-4948-473e-890b-67fe2fbbd71a"
  }
},
  {
  "report_name": "HTS_Encounter",
  "flat_table_name": "mamba_flat_encounter_hts_card",
  "encounter_type_uuid": "264daIZd-f80e-48fe-nba9-P37f2W1905Pv",
  "concepts_locale": "en",
  "table_columns": {
    "family_member_accompanying_patient": "dc911cc1-30ab-102d-86b0-7a5022ba4115",
    "other_specified_family_member": "6cb349b1-9f45-4c96-84c7-9d7037c6a056",
    "delivery_model": "46648b1d-b099-433b-8f9c-3815ff1e0a0f",
    "counselling_approach": "ff820a28-1adf-4530-bf27-537bfa9ce0b2",
    "hct_entry_point": "720a1e85-ea1c-4f7b-a31e-cb896978df79",
    "community_testing_point": "4f4e6d1d-4343-42cc-ba47-2319b8a84369",
    "other_community_testing": "16820069-b4bf-4c47-9efc-408746e1636b",
    "anc_visit_number": "c0b1b5f1-a692-49d1-9a69-ff901e07fa27",
    "other_care_entry_point": "adf31c43-c9a0-4ab8-b53a-42097eb3d2b6",
    "reason_for_testing": "2afe1128-c3f6-4b35-b119-d17b9b9958ed",
    "reason_for_testing_other_specify": "8c628b5b-0045-40dc-a480-7e1518ffb256",
    "special_category": "927563c5-cb91-4536-b23c-563a72d3f829",
    "other_special_category": "eac4e9c2-a086-43fc-8d43-b5a4e02febb4",
    "hiv_first_time_tester": "2766c090-c057-44f2-98f0-691b6d0336dc",
    "previous_hiv_tests_date": "34c917f0-356b-40d0-b3d1-cf609517b5fc",
    "months_since_first_hiv_aids_symptoms": "bf038497-df07-417d-9767-983e59983760",
    "previous_hiv_test_results": "49ba801d-b6ff-47cd-8d29-e0ac8649cb7d",
    "referring_health_facility": "a2397735-328f-432f-8c0d-d5c358516375",
    "no_of_times_tested_in_last_12_months": "8037192e-8f0c-4af3-ad8d-ccd1dd6880ba",
    "no_of_partners_in_the_last_12_months": "f1a6ede9-052e-4707-9cd8-a77fdeb2a02b",
    "partner_tested_for_hiv": "adc0b1a1-39cf-412b-9ab0-28ec0f731220",
    "partner_hiv_test_result": "ee802cf2-295b-4297-b53c-205f794294a5",
    "pre_test_counseling_done": "193039f1-c378-4d81-bb72-653b66c69914",
    "counselling_session_type": "b92b1777-4356-49b2-9c83-a799680dc7d4",
    "current_hiv_test_result": "3d292447-d7df-417f-8a71-e53e869ec89d",
    "hiv_syphilis_duo": "16091701-69b8-4bc7-82b3-b1726cf5a5df",
    "consented_for_blood_drawn_for_testing": "0698a45b-771c-4d11-84ff-095598c8883c",
    "hiv_recency_result": "141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
    "hiv_recency_viral_load_results": "5fd38584-21a7-4145-be4b-c126c5fb3d73",
    "hiv_recency_viral_load_qualitative": "0787cd66-0816-46f1-ade4-eb75b166144e",
    "hiv_recency_sample_id": "a0a6545b-8383-4235-a74f-417db2b580f3",
    "hts_fingerprint_captured": "d7974eae-a0a0-4a0c-b5ed-f060af91665d",
    "results_received_as_individual": "3437ae80-bcc5-41e2-887e-d56999a1b467",
    "results_received_as_a_couple": "2aa9f0c1-3f7e-49cd-86ee-baac0d2d5f2d",
    "couple_results": "94a5bd0a-b79d-421e-ab71-8e382eed100f",
    "tb_suspect": "b80f04a4-1559-42fd-8923-f8a6d2456a04",
    "presumptive_tb_case_referred": "c5da115d-f6a3-4d13-b182-c2e982a3a796",
    "prevention_services_received": "73686a14-b55c-4b10-916d-fda2046b803f",
    "other_prevention_services": "f3419b12-f6da-4aed-a001-e9f0bd078140",
    "has_client_been_linked_to_care": "3d620422-0641-412e-ab31-5e45b98bc459",
    "name_of_location_transferred_to": "dce015bb-30ab-102d-86b0-7a5022ba4115"
  }
},
  {
  "report_name": "TB_Enrollment",
  "flat_table_name": "mamba_flat_encounter_tb_enrollment",
  "encounter_type_uuid": "334bf97e-28e2-4a27-8727-a5ce31c7cd66",
  "concepts_locale": "en",
  "table_columns": {
    "district_tb_number": "67e9ec2f-4c72-408b-8122-3706909d77ec",
    "unit_tb_no": "2e2ec250-f5d3-4de7-8c70-a458f42441e6",
    "next_of_kin_name": "162729AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "next_of_kin_contact": "165052AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "treatment_supporter_name": "23e28311-3c17-4137-8eee-69860621b80b",
    "treatment_supporter_type": "805a9d40-8922-4fb0-8208-7c0fdf57936a",
    "tb_disease_classification": "d45871ee-62d6-4d4d-b905-f7b75a3fd3bb",
    "indicate_site": "9c78a74a-6c28-4c83-89e5-2ced9fec78d4",
    "type_of_tb_patient": "e077f196-c19a-417f-adc6-b175a3343bfd",
    "referral_date": "3dd08b9a-dfe6-4095-a553-21c7284561aa",
    "referral_type": "67ea4375-0f4f-4e67-b8b0-403942753a4d",
    "referring_health_facility": "a2397735-328f-432f-8c0d-d5c358516375",
    "referring_community_name": "a2de58bf-afa0-49df-ab76-72c0aa71148f",
    "referring_district": "c5281171-63d7-4c2d-ba08-202d7270267f",
    "referring_contact_phone_number": "0a28d426-244e-45b9-befb-70b15de9c9b9",
    "started_on_tb_first_line": "56a01780-5fcb-46ce-88d2-18f2f320c252",
    "date_started_on_tb_first_line": "7326297e-0ccd-4355-9b86-dde1c056e2c2",
    "susceptible_to_anti_tb_drugs": "159958AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "diagnosed_with_dr_tb": "c069ca01-e8e2-4ae2-ac36-ab0ee4540347",
    "date_diagnosed_with_dr_tb": "67ac3702-5ec1-4c52-8e80-405ec99b723b",
    "hiv_positive_category": "5737ab4e-53f9-418e-94f4-35da78ab884f",
    "examination_date": "d2f31713-aada-4d0d-9340-014b2371bdd8",
    "anti_retroviral_therapy_status": "dca25616-30ab-102d-86b0-7a5022ba4115",
    "baseline_regimen_start_date": "ab505422-26d9-41f1-a079-c3d222000440",
    "started_on_cpt": "bb77f9f0-9743-4c60-8e70-b20b5e800a50",
    "dapson_start_date": "481c5fdb-4719-4be3-84c0-a64172a426c7",
    "special_category": "927563c5-cb91-4536-b23c-563a72d3f829",
    "other_special_category": "eac4e9c2-a086-43fc-8d43-b5a4e02febb4",
    "baseline_tb_test": "1eb51d98-a49f-4a9a-87a1-6c3541b5713a",
    "other_tests_ordered": "79447e7c-9778-4b5d-b665-cd63e9035aa5",
    "lab_result_txt": "bfd0ac71-cd88-47a3-a320-4fc2e6f5993f",
    "tb_smear_result": "dce0532c-30ab-102d-86b0-7a5022ba4115",
    "tb_rifampin_resistance_checking": "162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "tb_lam_results": "066b84a0-e18f-4cdd-a0d7-189454f4c7a4",
    "x_ray_chest": "dc5458a6-30ab-102d-86b0-7a5022ba4115",
    "lab_number": "0f998893-ab24-4ee4-922a-f197ac5fd6e6",
    "diabetes_test_done": "c92173bf-98bc-4770-a267-065b6e9730ac",
    "diabetes_test_results": "93d5f1ea-df3a-470d-b60f-dbe84d717574"
  }
},
  {
  "report_name": "TB_Encounter",
  "flat_table_name": "mamba_flat_encounter_tb_followup",
  "encounter_type_uuid": "455bad1f-5e97-4ee9-9558-ff1df8808732",
  "concepts_locale": "en",
  "table_columns": {
    "return_visit_date": "dcac04cf-30ab-102d-86b0-7a5022ba4115",
    "month_of_follow_up": "4d1cc565-ae34-4bb2-92e7-681614218b7b",
    "muac": "5f86d19d-9546-4466-89c0-6f80c101191b",
    "eid_visit_1_z_score": "01b61dfb-7be9-4de5-8880-b37fefc253ba",
    "tb_treatment_model": "9e4e93fc-dcc0-4d36-9738-c0a5a489baa1",
    "rhze_150_75_400_275_mg_given": "c6df995b-b716-4b63-8e1c-8081c9593835",
    "rhze_150_75_400_275_mg_blisters_given": "1744602d-e003-44b1-bd40-9060ae584188",
    "rh_150_75mg_given": "ea4a34d3-4f21-4627-a1c9-446dd99c26d7",
    "rh_150_75mg_blisters_given": "c2d89f0d-65bb-458b-8a1a-e09517c2ba5a",
    "rhz_75_50_150mg_given": "6e972b63-55ac-4f8f-83dd-303d0a472212",
    "rhz_75_50_150mg_blisters_given": "44ece6a5-9b62-4567-981e-ab0b7cf4788a",
    "rh_75_50_mg_given": "59d4da25-6b05-4783-82de-6bf4217fc957",
    "rh_75_50_mg_blisters_given": "fe85b853-0548-40f8-a5a8-c2595d2b6664",
    "ethambutol_100mg_given": "4a67c909-9a4a-4de6-a32a-bbb75d40bf85",
    "ethambutol_100mg_blisters_given": "ed016d14-6f01-437e-8592-9e9061f28fe8",
    "hiv_positive_category": "5737ab4e-53f9-418e-94f4-35da78ab884f",
    "cotrim_given": "c3d744f6-00ef-4774-b9a7-d33c58f5b014",
    "arv_drugs_given": "b16f3f1d-aba3-4f8b-bf2d-116162c0b4fb",
    "adverse_event_reported_during_the_visit": "a5c0352a-a191-4a74-9389-db0e8d913790",
    "medication_or_other_side_effects": "dce05b7f-30ab-102d-86b0-7a5022ba4115",
    "severity_of_side_effect": "dce0d9c2-30ab-102d-86b0-7a5022ba4115",
    "drug_causing_adverse_events_side_effects": "b868f24f-c4e7-4cb9-906f-718c78ecda9a",
    "sample_referred_from_community": "80df8b91-b758-4361-ac31-64865f375c3d",
    "name_of_facility_unit_sample_referred_from": "524e6ef2-16a2-49f3-bcf0-b0cd58538933",
    "examination_type": "75fdbadd-183b-4abc-aafc-d370ba5c35bf",
    "examination_date": "d2f31713-aada-4d0d-9340-014b2371bdd8",
    "baseline_tb_test": "1eb51d98-a49f-4a9a-87a1-6c3541b5713a",
    "other_tests_ordered": "79447e7c-9778-4b5d-b665-cd63e9035aa5",
    "lab_result_txt": "bfd0ac71-cd88-47a3-a320-4fc2e6f5993f",
    "tb_smear_result": "dce0532c-30ab-102d-86b0-7a5022ba4115",
    "tb_polymerase_chain_reaction_with_RR": "162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "tb_lam_results": "066b84a0-e18f-4cdd-a0d7-189454f4c7a4",
    "x_ray_chest": "dc5458a6-30ab-102d-86b0-7a5022ba4115",
    "lab_number": "0f998893-ab24-4ee4-922a-f197ac5fd6e6",
    "contact_screening_date": "80645672-6690-4234-8d57-59dbd853b8ef",
    "no_of_contants_gtr_or_eq_to_5_yrs_old": "5d041b7f-ae96-49a8-b3c0-9c251b80039b",
    "total_under_5_yr_old_household_contacts": "164419AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "no_of_contacts_5yrs_or_gtr_yrs_old_screened_for_tb": "793762c6-5223-4d0f-ae92-2936530ae12c",
    "no_of_contacts_less_5_yrs_old_screened_for_tb": "9ecd5ff1-a87e-48ab-8b52-b0052f970a8e",
    "no_of_contacts_gtr_or_eq_to_5_yrs_old_with_tb": "463f1761-b4d2-47da-9d0b-9bc1f5f8f6ac",
    "no_of_contacts_less_than_5_yrs_old_with_tb": "4230e839-77ec-4c69-875d-e7fb37523ea1",
    "no_of_contacts_gtr_or_eq_to_5_yrs_old_on_tpt": "af09d200-55b9-47b9-b46c-c32d494ce838",
    "total_under_5_yrs_old_started_on_ipt": "164421AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "transfer_date": "34c5cbad-681a-4aca-bcc3-c7ddd2a88db8",
    "transfer_type": "c2ecad6a-ee54-411b-b6ff-0a2a096b06ae",
    "transfer_health_facility": "bc58b30e-2edf-4e60-98ba-dc54249f8ed0",
    "transfer_district": "b9d15a43-c3e0-4564-b0b1-af4510da2b4b",
    "phone_contact_of_receiving_facility": "e6efa947-eec2-41ef-a969-baa1aba3d761",
    "follow_up_date": "bdd1b59b-328d-42fa-a5ce-5e81d1c4042a",
    "patient_missed_appointment": "444403bb-14dc-4c33-a6db-2c75574f7abe",
    "side_effects": "677cea54-d613-4d98-b65f-bfc76202505d",
    "dot_monitoring": "0eebaac1-8528-4c5a-a0cd-6f2a5b9d0316",
    "counselling_done": "928a4617-436e-44b3-91b3-725cb1b910d1",
    "pill_refill": "4f6bd17b-1e71-41fd-b5b3-29aef8baaf96",
    "appointment_reminder": "6908508b-70c0-4b21-92d4-4fffd9458dac",
    "sputum_sample_collection": "3601a46e-4392-4612-a390-123558318947",
    "other_support": "ac8a9e07-e0d9-4ff4-8db9-02b2e4343e58",
    "patient_evaluated": "2ff1ff13-6998-4310-97ed-f010b77f881a",
    "found_with_a_treatment_supporter": "243dad0d-5c72-4ea6-9ef3-08da9bb7a7d4",
    "transferred_out_to_another_facility": "dd27a783-30ab-102d-86b0-7a5022ba4115",
    "followup_outcome": "8f889d84-8e5c-4a66-970d-458d6d01e8a4",
    "date_of_dot_report": "a6903fa4-3085-4070-baa2-0f811235c535",
    "next_date_of_dot_appointment": "2377dfda-b713-48da-9ce2-b9cc214a5ece",
    "days_when_patient_was_directly_observed": "814bb92c-ee21-4d0c-94f3-7084b68c9212",
    "days_of_incomplete_doses": "9e65437f-0bba-48a9-b70f-35ab479bc561",
    "days_electronic_messages_of_drug_refills": "98acf275-a466-4386-a6bd-01615db35d40",
    "days_of_video_observed_therapy": "30ecb9a1-11e5-4be5-b2b5-a6d0e071c2eb",
    "days_when_dot_was_not_supervised": "9329109d-b4a0-4050-a1d1-acff1bdf50a7",
    "days_when_doses_were_taken_under_tx_supporter": "8e2718c8-f69b-4d93-bd1b-b6157e68f6b2",
    "days_when_drugs_were_not_taken": "b5c36ea3-3f9f-4153-a2ab-2520f6060e32",
    "tb_treatment_outcome_date": "dfbf41ad-44de-48db-b653-54273789c0c6",
    "tb_treatment_outcome": "e44c8c4c-db50-4d1e-9d6e-092d3b31cfd6",
    "transferred_to_2nd_line": "d96ee5b5-7723-4f9e-8442-3b6aa1276f6d",
    "miss_classification": "75a0e016-5f0c-4613-a7b2-cc0bf5dd7574",
    "reason_for_miss_classification": "881b4254-21be-4372-aa96-42453c941230",
    "action_taken_for_miss_classification": "6e936468-7c40-43fa-a515-137b53ed58d6",
    "tb_treatment_comments": "6965a8c4-7be5-47ee-a872-e158bd9545b1"
  }
}]}';

  CALL sp_mamba_extract_report_metadata(@report_data, 'mamba_dim_concept_metadata');

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

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_dim_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
    INNER JOIN mamba_dim_concept_name cn
    ON c.concept_id = cn.concept_id
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = cn.name
WHERE md.id > 0
  AND cn.locale = md.concepts_locale
  AND IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED');

-- Use locale preferred or Fully specified name

-- Update to True if this field is an obs answer to an obs Question
-- UPDATE mamba_dim_concept_metadata md
--     INNER JOIN mamba_dim_concept_answer ca
--     ON md.concept_id = ca.answer_concept
-- SET md.concept_answer_obs = 1
-- WHERE md.id > 0;

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
    id                  INT          NOT NULL AUTO_INCREMENT,
    person_id           INT          NOT NULL,
    birthdate           DATE         NULL,
    birthdate_estimated TINYINT      NOT NULL,
    age                 INT          NULL,
    dead                TINYINT      NOT NULL,
    death_date          DATETIME     NULL,
    deathdate_estimated TINYINT      NOT NULL,
    gender              VARCHAR(255) NULL,
    date_created        DATETIME     NOT NULL,
    person_name_short   VARCHAR(255) NULL,
    person_name_long    TEXT         NULL,
    uuid                CHAR(38)     NOT NULL,
    voided              TINYINT      NOT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX mamba_dim_person_person_id_index
    ON mamba_dim_person (person_id);

CREATE INDEX mamba_dim_person_uuid_index
    ON mamba_dim_person (uuid);

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

INSERT INTO mamba_dim_person
(person_id,
 birthdate,
 birthdate_estimated,
 age,
 dead,
 death_date,
 deathdate_estimated,
 gender,
 date_created,
 person_name_short,
 person_name_long,
 uuid,
 voided)

SELECT psn.person_id,
       psn.birthdate,
       psn.birthdate_estimated,
       fn_mamba_age_calculator(birthdate, death_date)               AS age,
       psn.dead,
       psn.death_date,
       psn.deathdate_estimated,
       psn.gender,
       psn.date_created,
       CONCAT_WS(' ', prefix, given_name, middle_name, family_name) AS person_name_short,
       CONCAT_WS(' ', prefix, given_name, middle_name, family_name_prefix, family_name, family_name2,
                 family_name_suffix, degree)
                                                                    AS person_name_long,
       psn.uuid,
       psn.voided
FROM person psn
         INNER JOIN person_name pn
                    on psn.person_id = pn.person_id
where pn.preferred=1;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_update;

CREATE PROCEDURE sp_mamba_dim_person_update()
BEGIN
-- $BEGIN
UPDATE mamba_dim_person dp
    INNER JOIN person psn  on psn.person_id = dp.person_id
    INNER JOIN  person_name pn on psn.person_id = pn.person_id
    SET   person_name_short = CONCAT_WS(' ',prefix,given_name,middle_name,family_name),
        person_name_long = CONCAT_WS(' ',prefix,given_name, middle_name,family_name_prefix, family_name,family_name2,family_name_suffix, degree)
WHERE  pn.preferred=1
;
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
CALL sp_mamba_dim_person_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_create;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier
(
    id                    INT         NOT NULL AUTO_INCREMENT,
    patient_identifier_id INT,
    patient_id            INT         NOT NULL,
    identifier            VARCHAR(50) NOT NULL,
    identifier_type       INT         NOT NULL,
    preferred             TINYINT     NOT NULL,
    location_id           INT         NULL,
    date_created          DATETIME    NOT NULL,
    uuid                  CHAR(38)    NOT NULL,
    voided                TINYINT     NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_patient_identifier_patient_identifier_id_index
    ON mamba_dim_patient_identifier (patient_identifier_id);

CREATE INDEX mamba_dim_patient_identifier_patient_id_index
    ON mamba_dim_patient_identifier (patient_id);

CREATE INDEX mamba_dim_patient_identifier_identifier_index
    ON mamba_dim_patient_identifier (identifier);

CREATE INDEX mamba_dim_patient_identifier_identifier_type_index
    ON mamba_dim_patient_identifier (identifier_type);

CREATE INDEX mamba_dim_patient_identifier_uuid_index
    ON mamba_dim_patient_identifier (uuid);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_insert;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_patient_identifier (patient_id,
                                          identifier,
                                          identifier_type,
                                          preferred,
                                          location_id,
                                          date_created,
                                          uuid,
                                          voided)
SELECT patient_id,
       identifier,
       identifier_type,
       preferred,
       location_id,
       date_created,
       uuid,
       voided
FROM patient_identifier;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_update;

CREATE PROCEDURE sp_mamba_dim_patient_identifier_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier;

CREATE PROCEDURE sp_mamba_dim_patient_identifier()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_patient_identifier_create();
CALL sp_mamba_dim_patient_identifier_insert();
CALL sp_mamba_dim_patient_identifier_update();

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
    id                 INT         NOT NULL AUTO_INCREMENT,
    person_name_id     INT         NOT NULL,
    person_id          INT         NOT NULL,
    preferred          TINYINT  NOT NULL,
    prefix             VARCHAR(50) NULL,
    given_name         VARCHAR(50) NULL,
    middle_name        VARCHAR(50) NULL,
    family_name_prefix VARCHAR(50) NULL,
    family_name        VARCHAR(50) NULL,
    family_name2       VARCHAR(50) NULL,
    family_name_suffix VARCHAR(50) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_person_name_person_name_id_index
    ON mamba_dim_person_name (person_name_id);

CREATE INDEX mamba_dim_person_name_person_id_index
    ON mamba_dim_person_name (person_id);

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

INSERT INTO mamba_dim_person_name
    (
        person_name_id,
        person_id,
        preferred,
        prefix,
        given_name,
        middle_name,
        family_name_prefix,
        family_name,
        family_name2,
        family_name_suffix
    )
    SELECT
        pn.person_name_id,
        pn.person_id,
        pn.preferred,
        pn.prefix,
        pn.given_name,
        pn.middle_name,
        pn.family_name_prefix,
        pn.family_name,
        pn.family_name2,
        pn.family_name_suffix
    FROM
        person_name pn;

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
    id                INT          NOT NULL AUTO_INCREMENT,
    person_address_id INT          NOT NULL,
    person_id         INT          NULL,
    preferred         TINYINT      NOT NULL,
    address1          VARCHAR(255) NULL,
    address2          VARCHAR(255) NULL,
    address3          VARCHAR(255) NULL,
    address4          VARCHAR(255) NULL,
    address5          VARCHAR(255) NULL,
    address6          VARCHAR(255) NULL,
    city_village      VARCHAR(255) NULL,
    county_district   VARCHAR(255) NULL,
    state_province    VARCHAR(255) NULL,
    postal_code       VARCHAR(50)  NULL,
    country           VARCHAR(50)  NULL,
    latitude          VARCHAR(50)  NULL,
    longitude         VARCHAR(50)  NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_person_address_person_address_id_index
    ON mamba_dim_person_address (person_address_id);

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

INSERT INTO mamba_dim_person_address (person_address_id,
                                      person_id,
                                      preferred,
                                      address1,
                                      address2,
                                      address3,
                                      address4,
                                      address5,
                                      address6,
                                      city_village,
                                      county_district,
                                      state_province,
                                      postal_code,
                                      country,
                                      latitude,
                                      longitude)
SELECT person_address_id,
       person_id,
       preferred,
       address1,
       address2,
       address3,
       address4,
       address5,
       address6,
       city_village,
       county_district,
       state_province,
       postal_code,
       country,
       latitude,
       longitude
FROM person_address;

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
-- ----------------------  sp_mamba_dim_user_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_create;

CREATE PROCEDURE sp_mamba_dim_user_create()
BEGIN
-- $BEGIN
    CREATE TABLE mamba_dim_users
    (
        id            INT          NOT NULL AUTO_INCREMENT,
        user_id       INT          NOT NULL,
        system_id     VARCHAR(50)  NOT NULL,
        username      VARCHAR(50)  NULL,
        creator       INT          NOT NULL,
        date_created  DATETIME     NOT NULL,
        changed_by    INT          NULL,
        date_changed  DATETIME     NULL,
        person_id     INT          NOT NULL,
        retired       TINYINT(1)   NOT NULL,
        retired_by    INT          NULL,
        date_retired  DATETIME     NULL,
        retire_reason VARCHAR(255) NULL,
        uuid          CHAR(38)     NOT NULL,
        email         VARCHAR(255) NULL,

        PRIMARY KEY (id)
    )
        CHARSET = UTF8;

    CREATE INDEX mamba_dim_users_user_id_index
        ON mamba_dim_users (user_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_insert;

CREATE PROCEDURE sp_mamba_dim_user_insert()
BEGIN
-- $BEGIN
    INSERT INTO mamba_dim_users
        (
            user_id,
            system_id,
            username,
            creator,
            date_created,
            changed_by,
            date_changed,
            person_id,
            retired,
            retired_by,
            date_retired,
            retire_reason,
            uuid,
            email
        )
        SELECT
            user_id,
            system_id,
            username,
            creator,
            date_created,
            changed_by,
            date_changed,
            person_id,
            retired,
            retired_by,
            date_retired,
            retire_reason,
            uuid,
            email
        FROM users c;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_update;

CREATE PROCEDURE sp_mamba_dim_user_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_user;

CREATE PROCEDURE sp_mamba_dim_user()
BEGIN
-- $BEGIN
    CALL sp_mamba_dim_user_create();
    CALL sp_mamba_dim_user_insert();
    CALL sp_mamba_dim_user_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_create;

CREATE PROCEDURE sp_mamba_dim_relationship_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_dim_relationship
(
    relationship_id INT                  NOT NULL AUTO_INCREMENT,
    person_a        INT                  NOT NULL,
    relationship    INT                  NOT NULL,
    person_b        INT                  NOT NULL,
    start_date      DATETIME             NULL,
    end_date        DATETIME             NULL,
    creator         INT                  NOT NULL,
    date_created    DATETIME             NOT NULL,
    date_changed    DATETIME             NULL,
    changed_by      INT                  NULL,
    voided          TINYINT(1)           NOT NULL ,
    voided_by       INT                  NULL,
    date_voided     DATETIME             NULL,
    void_reason     VARCHAR(255)         NULL,
    uuid            CHAR(38)             NOT NULL,

    PRIMARY KEY (relationship_id)
)

    CHARSET = UTF8MB3;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_insert;

CREATE PROCEDURE sp_mamba_dim_relationship_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_dim_relationship
    (
        relationship_id,
        person_a,
        relationship,
        person_b,
        start_date,
        end_date,
        creator,
        date_created,
        date_changed,
        changed_by,
        voided,
        voided_by,
        date_voided,
        void_reason,
        uuid
    )
SELECT
    relationship_id,
    person_a,
    relationship,
    person_b,
    start_date,
    end_date,
    creator,
    date_created,
    date_changed,
    changed_by,
    voided,
    voided_by,
    date_voided,
    void_reason,
    uuid
FROM relationship;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_update;

CREATE PROCEDURE sp_mamba_dim_relationship_update()
BEGIN
-- $BEGIN

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship;

CREATE PROCEDURE sp_mamba_dim_relationship()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_relationship_create();
CALL sp_mamba_dim_relationship_insert();
CALL sp_mamba_dim_relationship_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_create;

CREATE PROCEDURE sp_mamba_dim_agegroup_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_agegroup
(
    id              INT         NOT NULL AUTO_INCREMENT,
    age             INT         NULL,
    datim_agegroup  VARCHAR(50) NULL,
    datim_age_val   INT         NULL,
    normal_agegroup VARCHAR(50) NULL,
    normal_age_val   INT        NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_insert;

CREATE PROCEDURE sp_mamba_dim_agegroup_insert()
BEGIN
-- $BEGIN

-- Enter unknown dimension value (in case a person's date of birth is unknown)
CALL sp_mamba_load_agegroup();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_update;

CREATE PROCEDURE sp_mamba_dim_agegroup_update()
BEGIN
-- $BEGIN

-- update age_value b
UPDATE mamba_dim_agegroup a
SET datim_age_val =
    CASE
        WHEN a.datim_agegroup = '<1' THEN 1
        WHEN a.datim_agegroup = '1-4' THEN 2
        WHEN a.datim_agegroup = '5-9' THEN 3
        WHEN a.datim_agegroup = '10-14' THEN 4
        WHEN a.datim_agegroup = '15-19' THEN 5
        WHEN a.datim_agegroup = '20-24' THEN 6
        WHEN a.datim_agegroup = '25-29' THEN 7
        WHEN a.datim_agegroup = '30-34' THEN 8
        WHEN a.datim_agegroup = '35-39' THEN 9
        WHEN a.datim_agegroup = '40-44' THEN 10
        WHEN a.datim_agegroup = '45-49' THEN 11
        WHEN a.datim_agegroup = '50-54' THEN 12
        WHEN a.datim_agegroup = '55-59' THEN 13
        WHEN a.datim_agegroup = '60-64' THEN 14
        WHEN a.datim_agegroup = '65+' THEN 15
    END
WHERE a.datim_agegroup IS NOT NULL;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup;

CREATE PROCEDURE sp_mamba_dim_agegroup()
BEGIN
-- $BEGIN

CALL sp_mamba_dim_agegroup_create();
CALL sp_mamba_dim_agegroup_insert();
CALL sp_mamba_dim_agegroup_update();
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_create;

CREATE PROCEDURE sp_mamba_z_encounter_obs_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    id                      INT           NOT NULL AUTO_INCREMENT,
    encounter_id            INT           NULL,
    person_id               INT           NOT NULL,
    encounter_datetime      DATETIME      NOT NULL,
    obs_datetime            DATETIME      NOT NULL,
    obs_question_concept_id INT DEFAULT 0 NOT NULL,
    obs_value_text          TEXT          NULL,
    obs_value_numeric       DOUBLE        NULL,
    obs_value_coded         INT           NULL,
    obs_value_datetime      DATETIME      NULL,
    obs_value_complex       VARCHAR(1000) NULL,
    obs_value_drug          INT           NULL,
    obs_question_uuid       CHAR(38),
    obs_answer_uuid         CHAR(38),
    obs_value_coded_uuid    CHAR(38),
    encounter_type_uuid     CHAR(38),
    status                  VARCHAR(16)   NOT NULL,
    voided                  TINYINT       NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

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

CREATE INDEX mamba_z_encounter_obs_status_index
    ON mamba_z_encounter_obs (status);

CREATE INDEX mamba_z_encounter_obs_voided_index
    ON mamba_z_encounter_obs (voided);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
-- $BEGIN

INSERT INTO mamba_z_encounter_obs
    (
        encounter_id,
        person_id,
        obs_datetime,
        encounter_datetime,
        encounter_type_uuid,
        obs_question_concept_id,
        obs_value_text,
        obs_value_numeric,
        obs_value_coded,
        obs_value_datetime,
        obs_value_complex,
        obs_value_drug,
        obs_question_uuid,
        obs_answer_uuid,
        obs_value_coded_uuid,
        status,
        voided
    )
    SELECT o.encounter_id,
           o.person_id,
           o.obs_datetime,
           e.encounter_datetime,
           e.encounter_type_uuid,
           o.concept_id     AS obs_question_concept_id,
           o.value_text     AS obs_value_text,
           o.value_numeric  AS obs_value_numeric,
           o.value_coded    AS obs_value_coded,
           o.value_datetime AS obs_value_datetime,
           o.value_complex  AS obs_value_complex,
           o.value_drug     AS obs_value_drug,
           NULL             AS obs_question_uuid,
           NULL             AS obs_answer_uuid,
           NULL             AS obs_value_coded_uuid,
           o.status,
           o.voided
    FROM obs o
             INNER JOIN mamba_dim_encounter e
                        ON o.encounter_id = e.encounter_id
    WHERE o.encounter_id IS NOT NULL;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
-- $BEGIN

-- update obs question UUIDs
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_metadata md
    ON z.obs_question_concept_id = md.concept_id
SET z.obs_question_uuid = md.concept_uuid
WHERE TRUE;

-- update obs_value_coded (UUIDs & Concept value names)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_name cn
    ON z.obs_value_coded = cn.concept_id
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.concept_id
SET z.obs_value_text       = cn.name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.obs_value_coded IS NOT NULL
;

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

CALL sp_mamba_z_encounter_obs_create();
CALL sp_mamba_z_encounter_obs_insert();
CALL sp_mamba_z_encounter_obs_update();

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_data_processing_flatten  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_flatten;

CREATE PROCEDURE sp_mamba_data_processing_flatten()
BEGIN
-- $BEGIN
-- CALL sp_xf_system_drop_all_tables_in_schema($target_database);
CALL sp_xf_system_drop_all_tables_in_schema();

CALL sp_mamba_dim_location;

CALL sp_mamba_dim_patient_identifier_type;

CALL sp_mamba_dim_concept_datatype;

CALL sp_mamba_dim_concept_answer;

CALL sp_mamba_dim_concept_name;

CALL sp_mamba_dim_concept;

CALL sp_mamba_dim_concept_metadata;

CALL sp_mamba_dim_encounter_type;

CALL sp_mamba_dim_encounter;

CALL sp_mamba_dim_person;

CALL sp_mamba_dim_person_name;

CALL sp_mamba_dim_person_address;

CALL sp_mamba_dim_user;

CALL sp_mamba_dim_relationship;

CALL sp_mamba_dim_patient_identifier;

CALL sp_mamba_dim_agegroup;

CALL sp_mamba_z_encounter_obs;

CALL sp_mamba_flat_encounter_table_create_all;

CALL sp_mamba_flat_encounter_table_insert_all;
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
-- ----------------------  sp_data_processing_derived_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art_card;

CREATE PROCEDURE sp_data_processing_derived_hiv_art_card()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art_card;
CALL sp_fact_encounter_hiv_art_summary;
CALL sp_fact_encounter_hiv_art_health_education;
CALL sp_fact_active_in_care;
CALL sp_fact_latest_adherence_patients;
CALL sp_fact_latest_advanced_disease_patients;
CALL sp_fact_latest_arv_days_dispensed_patients;
CALL sp_fact_latest_current_regimen_patients;
CALL sp_fact_latest_family_planning_patients;
CALL sp_fact_latest_hepatitis_b_test_patients;
CALL sp_fact_latest_viral_load_patients;
CALL sp_fact_latest_iac_decision_outcome_patients;
CALL sp_fact_latest_iac_sessions_patients;
CALL sp_fact_latest_index_tested_children_patients;
CALL sp_fact_latest_index_tested_children_status_patients;
CALL sp_fact_latest_index_tested_partners_patients;
CALL sp_fact_latest_index_tested_partners_status_patients;
CALL sp_fact_latest_nutrition_assesment_patients;
CALL sp_fact_latest_nutrition_support_patients;
CALL sp_fact_latest_regimen_line_patients;
CALL sp_fact_latest_return_date_patients;
CALL sp_fact_latest_tb_status_patients;
CALL sp_fact_latest_tpt_status_patients;
CALL sp_fact_latest_viral_load_ordered_patients;
CALL sp_fact_latest_vl_after_iac_patients;
CALL sp_fact_latest_who_stage_patients;
CALL sp_fact_marital_status_patients;
CALL sp_fact_nationality_patients;
CALL sp_fact_latest_patient_demographics_patients;
CALL sp_fact_art_patients;
CALL sp_fact_current_arv_regimen_start_date;
CALL sp_fact_latest_pregnancy_status_patients;
CALL sp_fact_calhiv_patients;
CALL sp_fact_eid_patients;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_non_suppressed  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_non_suppressed;

CREATE PROCEDURE sp_data_processing_derived_non_suppressed()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_IIT  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_IIT;

CREATE PROCEDURE sp_data_processing_derived_IIT()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;

CALL sp_fact_no_of_interruptions_in_treatment;
CALL sp_fact_patient_interruption_details;


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hts  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts;

CREATE PROCEDURE sp_data_processing_derived_hts()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hts_card;

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
-- ----------------------  sp_mamba_dim_concept_name_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_create;

CREATE PROCEDURE sp_mamba_dim_concept_name_create()
BEGIN
-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    id                INT          NOT NULL AUTO_INCREMENT,
    concept_name_id   INT          NOT NULL,
    concept_id        INT,
    name              VARCHAR(255) NOT NULL,
    locale            VARCHAR(50)  NOT NULL,
    locale_preferred  TINYINT,
    concept_name_type VARCHAR(255),

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX mamba_dim_concept_name_concept_name_id_index
    ON mamba_dim_concept_name (concept_name_id);

CREATE INDEX mamba_dim_concept_name_concept_id_index
    ON mamba_dim_concept_name (concept_id);

CREATE INDEX mamba_dim_concept_name_concept_name_type_index
    ON mamba_dim_concept_name (concept_name_type);

CREATE INDEX mamba_dim_concept_name_locale_index
    ON mamba_dim_concept_name (locale);

CREATE INDEX mamba_dim_concept_name_locale_preferred_index
    ON mamba_dim_concept_name (locale_preferred);

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

INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    concept_name_type)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.concept_name_type
FROM concept_name cn
 WHERE cn.locale = 'en'
    AND cn.voided = 0
    AND IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED');

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
-- $BEGIN
    SET @report_encounter_uuid = '["8d5b2be0-c2cc-11de-8d13-0010c6dffd0f","6d88e370-f2ba-476b-bf1b-d8eaf3b1b67e","38cb2232-30fc-4b1f-8df1-47c795771ee9","8d5b27bc-c2cc-11de-8d13-0010c6dffd0f","264daIZd-f80e-48fe-nba9-P37f2W1905Pv","334bf97e-28e2-4a27-8727-a5ce31c7cd66","455bad1f-5e97-4ee9-9558-ff1df8808732"]';

    SELECT JSON_ARRAY_LENGTH(@report_encounter_uuid) INTO @report_encounter_uuid_len;

    SET @my_count = 1;
    WHILE @my_count <= 7
        DO
            SELECT  GET_ARRAY_ITEM_BY_INDEX(@report_encounter_uuid, @my_count) INTO @encounter_type_uuid;
            IF @encounter_type_uuid ='8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' THEN
                INSERT INTO mamba_z_encounter_obs
                    (
                            encounter_id,
                            person_id,
                            obs_datetime,
                            encounter_datetime,
                            encounter_type_uuid,
                            obs_question_concept_id,
                            obs_value_text,
                            obs_value_numeric,
                            obs_value_coded,
                            obs_value_datetime,
                            obs_value_complex,
                            obs_value_drug,
                            obs_question_uuid,
                            obs_answer_uuid,
                            obs_value_coded_uuid,
                            status,
                            voided
                    )
                    SELECT o.encounter_id,
                               o.person_id,
                               o.obs_datetime,
                               e.encounter_datetime,
                               e.encounter_type_uuid,
                               o.concept_id     AS obs_question_concept_id,
                               o.value_text     AS obs_value_text,
                               o.value_numeric  AS obs_value_numeric,
                               o.value_coded    AS obs_value_coded,
                               o.value_datetime AS obs_value_datetime,
                               o.value_complex  AS obs_value_complex,
                               o.value_drug     AS obs_value_drug,
                               NULL             AS obs_question_uuid,
                               NULL             AS obs_answer_uuid,
                               NULL             AS obs_value_coded_uuid,
                               o.status,
                               o.voided
                        FROM obs o
                                 INNER JOIN mamba_dim_encounter e
                                            ON o.encounter_id = e.encounter_id
                        WHERE o.encounter_id IS NOT NULL and o.voided =0 and e.encounter_datetime >=DATE_SUB(CURRENT_DATE(), INTERVAL 8 YEAR) and e.encounter_type_uuid= @encounter_type_uuid;
            ELSE
                INSERT INTO mamba_z_encounter_obs
                        (
                            encounter_id,
                            person_id,
                            obs_datetime,
                            encounter_datetime,
                            encounter_type_uuid,
                            obs_question_concept_id,
                            obs_value_text,
                            obs_value_numeric,
                            obs_value_coded,
                            obs_value_datetime,
                            obs_value_complex,
                            obs_value_drug,
                            obs_question_uuid,
                            obs_answer_uuid,
                            obs_value_coded_uuid,
                            status,
                            voided
                        )
                SELECT o.encounter_id,
                           o.person_id,
                           o.obs_datetime,
                           e.encounter_datetime,
                           e.encounter_type_uuid,
                           o.concept_id     AS obs_question_concept_id,
                           o.value_text     AS obs_value_text,
                           o.value_numeric  AS obs_value_numeric,
                           o.value_coded    AS obs_value_coded,
                           o.value_datetime AS obs_value_datetime,
                           o.value_complex  AS obs_value_complex,
                           o.value_drug     AS obs_value_drug,
                           NULL             AS obs_question_uuid,
                           NULL             AS obs_answer_uuid,
                           NULL             AS obs_value_coded_uuid,
                           o.status,
                           o.voided
                FROM obs o
                             INNER JOIN mamba_dim_encounter e
                                        ON o.encounter_id = e.encounter_id
                WHERE o.encounter_id IS NOT NULL and o.voided =0 and e.encounter_type_uuid= @encounter_type_uuid;
            END IF;
        SET @my_count = @my_count + 1;
        END WHILE;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_data_processing_etl  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl;

CREATE PROCEDURE sp_mamba_data_processing_etl()
BEGIN
-- $BEGIN
-- add base folder SP here --
-- CALL sp_data_processing_derived_hts();

CALL sp_mamba_data_processing_flatten();
CALL sp_data_processing_derived_transfers();
CALL sp_data_processing_derived_non_suppressed();
CALL sp_data_processing_derived_hiv_art_card();
CALL sp_data_processing_derived_IIT();
CALL sp_data_processing_derived_hts();
    -- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_create;

CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_no_of_interruptions
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    encounter_date                          DATE NULL,
    return_date                             DATE NULL,
    days_interrupted                        INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_no_of_interruptions_client_id_index ON mamba_fact_patients_no_of_interruptions (client_id);
CREATE INDEX
    mamba_fact_patients_no_of_interruptions_encounter_date_index ON mamba_fact_patients_no_of_interruptions (encounter_date);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_insert;

CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_no_of_interruptions(client_id,
                                                        encounter_date,
                                                        return_date,
                                                    days_interrupted)
SELECT
    client_id,
    encounter_date,
    return_visit_date,
    DATEDIFF(
            encounter_date,
            (SELECT return_visit_date
             FROM mamba_fact_encounter_hiv_art_card AS sub
             WHERE sub.client_id = main.client_id
               AND sub.encounter_date < main.encounter_date
             ORDER BY sub.encounter_date DESC
                LIMIT 1)
    ) AS Days
FROM
    mamba_fact_encounter_hiv_art_card AS main
ORDER BY
    client_id, encounter_date;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment;

CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment()
BEGIN
-- $BEGIN
CALL sp_fact_no_of_interruptions_in_treatment_create();
CALL sp_fact_no_of_interruptions_in_treatment_insert();
CALL sp_fact_no_of_interruptions_in_treatment_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_query;
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_no_of_interruptions;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_update;

CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details;

CREATE PROCEDURE sp_fact_patient_interruption_details()
BEGIN
-- $BEGIN
CALL sp_fact_patient_interruption_details_create();
CALL sp_fact_patient_interruption_details_insert();
CALL sp_fact_patient_interruption_details_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_create;

CREATE PROCEDURE sp_fact_patient_interruption_details_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_interruptions_details
(
    id                               INT AUTO_INCREMENT,
    client_id                        INT          NOT NULL,
    case_id                          VARCHAR(250) NOT NULL,
    art_enrollment_date              DATE NULL,
    days_since_initiation            INT NULL,
    last_dispense_date               DATE NULL,
    last_dispense_amount             INT NULL,
    current_regimen_start_date       DATE NULL,
    last_VL_result                   INT NULL,
    VL_last_date                     DATE NULL,
    last_dispense_description        VARCHAR(250) NULL,
    all_interruptions                INT NULL,
    iit_in_last_12Months             INT NULL,
    longest_IIT_ever                 INT NULL,
    last_IIT_duration                INT NULL,
    last_encounter_interruption_date DATE NULL,


    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_interruptions_details_client_id_index ON mamba_fact_patients_interruptions_details (client_id);
CREATE INDEX
    mamba_fact_patients_interruptions_details_case_id_index ON mamba_fact_patients_interruptions_details (case_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_insert;

CREATE PROCEDURE sp_fact_patient_interruption_details_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_interruptions_details(client_id, case_id, art_enrollment_date, days_since_initiation,
                                                      last_dispense_date, last_dispense_amount,
                                                      current_regimen_start_date, last_VL_result, VL_last_date,
                                                      last_dispense_description, all_interruptions,
                                                      iit_in_last_12Months, longest_IIT_ever, last_IIT_duration,
                                                      last_encounter_interruption_date)

SELECT person_id,
       uuid                                                            AS case_id,
       baseline_regimen_start_date                                     as art_enrollment_date,
       TIMESTAMPDIFF(DAY,baseline_regimen_start_date, last_visit_date) as days_since_initiation,
       last_visit_date                                                 as last_dispense_date,
       arv_days_dispensed                                              as last_dispense_amount,
       arv_regimen_start_date                                          as current_regimen_start_date,
       hiv_viral_load_copies                                           as last_VL_result,
       hiv_viral_collection_date                                       as VL_last_date,
       current_regimen                                                 as last_dispense_description,
       all_interruptions,
       iit_in_last_12Months,
       longest_IIT_ever,
       max_encounter_days_interrupted                                  AS last_IIT_duration,
       max_encounter_date                                              AS last_IIT_return_date

FROM mamba_dim_person
         INNER JOIN mamba_fact_audit_tool_art_patients a ON a.client_id = person_id
         LEFT JOIN (SELECT client_id, COUNT(days_interrupted) all_interruptions
                    FROM mamba_fact_patients_no_of_interruptions
                    WHERE days_interrupted >= 28
                    GROUP BY client_id) all_iits ON a.client_id = all_iits.client_id
         LEFT JOIN (SELECT client_id, COUNT(days_interrupted) iit_in_last_12months
                    FROM mamba_fact_patients_no_of_interruptions
                    WHERE days_interrupted >= 28
                      AND encounter_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH) AND CURRENT_DATE()
                    GROUP BY client_id) mfpnoi1 ON a.client_id = mfpnoi1.client_id
         LEFT JOIN (SELECT client_id, MAX(days_interrupted) longest_IIT_ever
                    FROM mamba_fact_patients_no_of_interruptions
                    WHERE days_interrupted >= 28
                    GROUP BY client_id) mfpnoi ON a.client_id = mfpnoi.client_id
         LEFT JOIN (SELECT m.client_id,
                           max_encounter_date,
                           m.days_interrupted AS max_encounter_days_interrupted
                    FROM mamba_fact_patients_no_of_interruptions m
                             JOIN (SELECT client_id,
                                          MAX(encounter_date) AS max_encounter_date
                                   FROM mamba_fact_patients_no_of_interruptions
                                   WHERE days_interrupted >= 28
                                   GROUP BY client_id) subquery
                                  ON m.client_id = subquery.client_id AND
                                     m.encounter_date = subquery.max_encounter_date) long_interruptions
                   ON a.client_id = long_interruptions.client_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patients_interruptions_details_query;
CREATE PROCEDURE sp_fact_patients_interruptions_details_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_interruptions_details;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_update;

CREATE PROCEDURE sp_fact_patient_interruption_details_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_IIT  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_IIT;

CREATE PROCEDURE sp_data_processing_derived_IIT()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;

CALL sp_fact_no_of_interruptions_in_treatment;
CALL sp_fact_patient_interruption_details;


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_create;

CREATE PROCEDURE sp_mamba_dim_agegroup_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_dim_agegroup
(
    id              INT         NOT NULL AUTO_INCREMENT,
    age             INT         NULL,
    datim_agegroup  VARCHAR(50) NULL,
    datim_age_val   INT         NULL,
    normal_agegroup VARCHAR(50) NULL,
    normal_age_val   INT        NULL,
    moh_age_group VARCHAR(50) NULL,
    moh_age_val   INT        NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;
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
CREATE TABLE mamba_fact_encounter_hiv_art_card
(
    id                                   INT AUTO_INCREMENT,
    encounter_id                         INT NULL,
    client_id                            INT NULL,
    encounter_date                       DATE NULL,

    hemoglobin                           CHAR(255) CHARACTER SET UTF8 NULL,
    malnutrition                         CHAR(255) CHARACTER SET UTF8 NULL,
    method_of_family_planning            CHAR(255) CHARACTER SET UTF8 NULL,
    oedema                               CHAR(255) CHARACTER SET UTF8 NULL,
    cd4_panel                            CHAR(255) CHARACTER SET UTF8 NULL,
    cd4_percent                          CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_viral_load                       CHAR(255) CHARACTER SET UTF8 NULL,
    historical_drug_start_date           CHAR(255) CHARACTER SET UTF8 NULL,
    historical_drug_stop_date            CHAR(255) CHARACTER SET UTF8 NULL,
    current_drugs_used                   CHAR(255) CHARACTER SET UTF8 NULL,
    tests_ordered                        CHAR(255) CHARACTER SET UTF8 NULL,
    number_of_weeks_pregnant             CHAR(255) CHARACTER SET UTF8 NULL,
    medication_orders                    CHAR(255) CHARACTER SET UTF8 NULL,
    viral_load_qualitative               CHAR(255) CHARACTER SET UTF8 NULL,
    hepatitis_b_test_qualitative         CHAR(255) CHARACTER SET UTF8 NULL,
    mid_upper_arm_circumference          CHAR(255) CHARACTER SET UTF8 NULL,
    medication_strength                  CHAR(255) CHARACTER SET UTF8 NULL,
    register_serial_number               CHAR(255) CHARACTER SET UTF8 NULL,
    duration_units                       CHAR(255) CHARACTER SET UTF8 NULL,
    systolic_blood_pressure              CHAR(255) CHARACTER SET UTF8 NULL,
    diastolic_blood_pressure             CHAR(255) CHARACTER SET UTF8 NULL,
    pulse                                CHAR(255) CHARACTER SET UTF8 NULL,
    temperature                          CHAR(255) CHARACTER SET UTF8 NULL,
    weight                               CHAR(255) CHARACTER SET UTF8 NULL,
    height                               CHAR(255) CHARACTER SET UTF8 NULL,
    return_visit_date                    CHAR(255) CHARACTER SET UTF8 NULL,
    respiratory_rate                     CHAR(255) CHARACTER SET UTF8 NULL,
    head_circumference                   CHAR(255) CHARACTER SET UTF8 NULL,
    cd4_count                            CHAR(255) CHARACTER SET UTF8 NULL,
    estimated_date_of_confinement        CHAR(255) CHARACTER SET UTF8 NULL,
    pmtct                                CHAR(255) CHARACTER SET UTF8 NULL,
    pregnant                             CHAR(255) CHARACTER SET UTF8 NULL,
    scheduled_patient_visit              CHAR(255) CHARACTER SET UTF8 NULL,
    entry_point_into_hiv_care            CHAR(255) CHARACTER SET UTF8 NULL,
    who_hiv_clinical_stage               CHAR(255) CHARACTER SET UTF8 NULL,
    name_of_location_transferred_to      CHAR(255) CHARACTER SET UTF8 NULL,
    tuberculosis_status                  CHAR(255) CHARACTER SET UTF8 NULL,
    tuberculosis_treatment_start_date    CHAR(255) CHARACTER SET UTF8 NULL,
    adherence_to_cotrim                  CHAR(255) CHARACTER SET UTF8 NULL,
    arv_adherence_assessment_code        CHAR(255) CHARACTER SET UTF8 NULL,
    reason_for_missing_arv               CHAR(255) CHARACTER SET UTF8 NULL,
    medication_or_other_side_effects     CHAR(255) CHARACTER SET UTF8 NULL,
    history_of_functional_status         CHAR(255) CHARACTER SET UTF8 NULL,
    body_weight                          CHAR(255) CHARACTER SET UTF8 NULL,
    family_planning_status               CHAR(255) CHARACTER SET UTF8 NULL,
    symptom_diagnosis                    CHAR(255) CHARACTER SET UTF8 NULL,
    address                              CHAR(255) CHARACTER SET UTF8 NULL,
    date_positive_hiv_test_confirmed     CHAR(255) CHARACTER SET UTF8 NULL,
    treatment_supporter_telephone_number CHAR(255) CHARACTER SET UTF8 NULL,
    transferred_out                      CHAR(255) CHARACTER SET UTF8 NULL,
    tuberculosis_treatment_stop_date     CHAR(255) CHARACTER SET UTF8 NULL,
    current_arv_regimen                  CHAR(255) CHARACTER SET UTF8 NULL,
    art_duration                         CHAR(255) CHARACTER SET UTF8 NULL,
    current_art_duration                 CHAR(255) CHARACTER SET UTF8 NULL,
    antenatal_number                     CHAR(255) CHARACTER SET UTF8 NULL,
    mid_upper_arm_circumference_code     CHAR(255) CHARACTER SET UTF8 NULL,
    district_tuberculosis_number         CHAR(255) CHARACTER SET UTF8 NULL,
    opportunistic_infection              CHAR(255) CHARACTER SET UTF8 NULL,
    trimethoprim_days_dispensed          CHAR(255) CHARACTER SET UTF8 NULL,
    other_medications_dispensed          CHAR(255) CHARACTER SET UTF8 NULL,
    arv_regimen_days_dispensed           CHAR(255) CHARACTER SET UTF8 NULL,
    trimethoprim_dosage                  CHAR(255) CHARACTER SET UTF8 NULL,
    ar_regimen_dose                      CHAR(255) CHARACTER SET UTF8 NULL,
    nutrition_support_and_infant_feeding CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_regimen                     CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_weight                      CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_stage                       CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_cd4                         CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_pregnancy                   CHAR(255) CHARACTER SET UTF8 NULL,
    name_of_family_member                CHAR(255) CHARACTER SET UTF8 NULL,
    age_of_family_member                 CHAR(255) CHARACTER SET UTF8 NULL,
    family_member_set                    CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_test                             CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_test_facility                    CHAR(255) CHARACTER SET UTF8 NULL,
    other_side_effects                   CHAR(255) CHARACTER SET UTF8 NULL,
    other_tests_ordered                  CHAR(255) CHARACTER SET UTF8 NULL,
    care_entry_point_set                 CHAR(255) CHARACTER SET UTF8 NULL,
    treatment_supporter_tel_no           CHAR(255) CHARACTER SET UTF8 NULL,
    other_reason_for_missing_arv         CHAR(255) CHARACTER SET UTF8 NULL,
    current_regimen_other                CHAR(255) CHARACTER SET UTF8 NULL,
    treatment_supporter_name             CHAR(255) CHARACTER SET UTF8 NULL,
    cd4_classification_for_infants       CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_regimen_start_date          CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_regimen_set                 CHAR(255) CHARACTER SET UTF8 NULL,
    transfer_out_date                    CHAR(255) CHARACTER SET UTF8 NULL,
    transfer_out_set                     CHAR(255) CHARACTER SET UTF8 NULL,
    health_education_disclosure          CHAR(255) CHARACTER SET UTF8 NULL,
    other_referral_ordered               CHAR(255) CHARACTER SET UTF8 NULL,
    age_in_months                        CHAR(255) CHARACTER SET UTF8 NULL,
    test_result_type                     CHAR(255) CHARACTER SET UTF8 NULL,
    lab_result_txt                       CHAR(255) CHARACTER SET UTF8 NULL,
    lab_result_set                       CHAR(255) CHARACTER SET UTF8 NULL,
    counselling_session_type             CHAR(255) CHARACTER SET UTF8 NULL,
    cotrim_given                         CHAR(255) CHARACTER SET UTF8 NULL,
    eid_visit_1_appointment_date         CHAR(255) CHARACTER SET UTF8 NULL,
    feeding_status_at_eid_visit_1        CHAR(255) CHARACTER SET UTF8 NULL,
    counselling_approach                 CHAR(255) CHARACTER SET UTF8 NULL,
    current_hiv_test_result              CHAR(255) CHARACTER SET UTF8 NULL,
    results_received_as_a_couple         CHAR(255) CHARACTER SET UTF8 NULL,
    tb_suspect                           CHAR(255) CHARACTER SET UTF8 NULL,
    baseline_lactating                   CHAR(255) CHARACTER SET UTF8 NULL,
    inh_dosage                           CHAR(255) CHARACTER SET UTF8 NULL,
    inh_days_dispensed                   CHAR(255) CHARACTER SET UTF8 NULL,
    age_unit                             CHAR(255) CHARACTER SET UTF8 NULL,
    syphilis_test_result                 CHAR(255) CHARACTER SET UTF8 NULL,
    syphilis_test_result_for_partner     CHAR(255) CHARACTER SET UTF8 NULL,
    ctx_given_at_eid_visit_1             CHAR(255) CHARACTER SET UTF8 NULL,
    nvp_given_at_eid_visit_1             CHAR(255) CHARACTER SET UTF8 NULL,
    eid_visit_1_muac                     CHAR(255) CHARACTER SET UTF8 NULL,
    medication_duration                  CHAR(255) CHARACTER SET UTF8 NULL,
    clinical_impression_comment          CHAR(255) CHARACTER SET UTF8 NULL,
    reason_for_appointment               CHAR(255) CHARACTER SET UTF8 NULL,
    medication_history                   CHAR(255) CHARACTER SET UTF8 NULL,
    quantity_of_medication               CHAR(255) CHARACTER SET UTF8 NULL,
    tb_with_rifampin_resistance_checking CHAR(255) CHARACTER SET UTF8 NULL,
    specimen_sources                     CHAR(255) CHARACTER SET UTF8 NULL,
    eid_immunisation_codes               CHAR(255) CHARACTER SET UTF8 NULL,
    clinical_assessment_codes            CHAR(255) CHARACTER SET UTF8 NULL,
    refiil_of_art_for_the_mother         CHAR(255) CHARACTER SET UTF8 NULL,
    development_milestone                CHAR(255) CHARACTER SET UTF8 NULL,
    pre_test_counseling_done             CHAR(255) CHARACTER SET UTF8 NULL,
    hct_entry_point                      CHAR(255) CHARACTER SET UTF8 NULL,
    linked_to_care                       CHAR(255) CHARACTER SET UTF8 NULL,
    estimated_gestational_age            CHAR(255) CHARACTER SET UTF8 NULL,
    eid_concept_type                     CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_viral_load_date                  CHAR(255) CHARACTER SET UTF8 NULL,
    relationship_to_patient              CHAR(255) CHARACTER SET UTF8 NULL,
    other_reason_for_appointment         CHAR(255) CHARACTER SET UTF8 NULL,
    nutrition_assessment                 CHAR(255) CHARACTER SET UTF8 NULL,
    art_pill_balance                     CHAR(255) CHARACTER SET UTF8 NULL,
    differentiated_service_delivery      CHAR(255) CHARACTER SET UTF8 NULL,
    stable_in_dsdm                       CHAR(255) CHARACTER SET UTF8 NULL,
    reason_for_testing                   CHAR(255) CHARACTER SET UTF8 NULL,
    previous_hiv_tests_date              CHAR(255) CHARACTER SET UTF8 NULL,
    milligram_per_meter_squared          CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_testing_service_delivery_model   CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_syphillis_duo                    CHAR(255) CHARACTER SET UTF8 NULL,
    prevention_services_received         CHAR(255) CHARACTER SET UTF8 NULL,
    hiv_first_time_tester                CHAR(255) CHARACTER SET UTF8 NULL,
    previous_hiv_test_results            CHAR(255) CHARACTER SET UTF8 NULL,
    results_received_as_individual       CHAR(255) CHARACTER SET UTF8 NULL,
    health_education_setting             CHAR(255) CHARACTER SET UTF8 NULL,
    health_edu_intervation_approaches    CHAR(255) CHARACTER SET UTF8 NULL,
    health_education_depression_status   CHAR(255) CHARACTER SET UTF8 NULL,
    ovc_screening                        CHAR(255) CHARACTER SET UTF8 NULL,
    art_preparation_readiness            CHAR(255) CHARACTER SET UTF8 NULL,
    ovc_assessment                       CHAR(255) CHARACTER SET UTF8 NULL,
    phdp_components                      CHAR(255) CHARACTER SET UTF8 NULL,
    tpt_start_date                       CHAR(255) CHARACTER SET UTF8 NULL,
    tpt_completion_date                  CHAR(255) CHARACTER SET UTF8 NULL,
    advanced_disease_status              CHAR(255) CHARACTER SET UTF8 NULL,
    family_member_hiv_status             CHAR(255) CHARACTER SET UTF8 NULL,
    tpt_status                           CHAR(255) CHARACTER SET UTF8 NULL,
    rpr_test_results                     CHAR(255) CHARACTER SET UTF8 NULL,
    crag_test_results                    CHAR(255) CHARACTER SET UTF8 NULL,
    tb_lam_results                       CHAR(255) CHARACTER SET UTF8 NULL,
    gender_based_violance                CHAR(255) CHARACTER SET UTF8 NULL,
    dapsone_ctx_medset                   CHAR(255) CHARACTER SET UTF8 NULL,
    tuberculosis_medication_set          CHAR(255) CHARACTER SET UTF8 NULL,
    fluconazole_medication_set           CHAR(255) CHARACTER SET UTF8 NULL,
    cervical_cancer_screening            CHAR(255) CHARACTER SET UTF8 NULL,
    intention_to_conceive                CHAR(255) CHARACTER SET UTF8 NULL,
    viral_load_test                      CHAR(255) CHARACTER SET UTF8 NULL,
    genexpert_test                       CHAR(255) CHARACTER SET UTF8 NULL,
    tb_microscopy_results                CHAR(255) CHARACTER SET UTF8 NULL,
    tb_microscopy_test                   CHAR(255) CHARACTER SET UTF8 NULL,
    tb_lam                               CHAR(255) CHARACTER SET UTF8 NULL,
    rpr_test                             CHAR(255) CHARACTER SET UTF8 NULL,
    crag_test                            CHAR(255) CHARACTER SET UTF8 NULL,
    arv_med_set                          CHAR(255) CHARACTER SET UTF8 NULL,
    quantity_unit                        CHAR(255) CHARACTER SET UTF8 NULL,
    tpt_side_effects                     CHAR(255) CHARACTER SET UTF8 NULL,
    split_into_drugs                     CHAR(255) CHARACTER SET UTF8 NULL,
    lab_number                           CHAR(255) CHARACTER SET UTF8 NULL,
    other_drug_dispensed_set             CHAR(255) CHARACTER SET UTF8 NULL,
    test                                 CHAR(255) CHARACTER SET UTF8 NULL,
    test_result                          CHAR(255) CHARACTER SET UTF8 NULL,
    other_tests                          CHAR(255) CHARACTER SET UTF8 NULL,
    refill_point_code                    CHAR(255) CHARACTER SET UTF8 NULL,
    next_return_date_at_facility         CHAR(255) CHARACTER SET UTF8 NULL,
    PRIMARY KEY (id)
);

CREATE INDEX
    mamba_fact_encounter_hiv_art_encounter_id_index ON mamba_fact_encounter_hiv_art_card (encounter_id);
CREATE INDEX
    mamba_fact_encounter_hiv_art_client_id_index ON mamba_fact_encounter_hiv_art_card (client_id);
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
                                          encounter_date,
                                          hemoglobin, malnutrition, method_of_family_planning, oedema, cd4_panel,
                                          cd4_percent, hiv_viral_load, historical_drug_start_date,
                                          historical_drug_stop_date, current_drugs_used, tests_ordered,
                                          number_of_weeks_pregnant, medication_orders, viral_load_qualitative,
                                          hepatitis_b_test_qualitative, mid_upper_arm_circumference,
                                          medication_strength, register_serial_number, duration_units,
                                          systolic_blood_pressure, diastolic_blood_pressure, pulse, temperature, weight,
                                          height, return_visit_date, respiratory_rate, head_circumference, cd4_count,
                                          estimated_date_of_confinement, pmtct, pregnant, scheduled_patient_visit,
                                          entry_point_into_hiv_care, who_hiv_clinical_stage,
                                          name_of_location_transferred_to, tuberculosis_status,
                                          tuberculosis_treatment_start_date, adherence_to_cotrim,
                                          arv_adherence_assessment_code, reason_for_missing_arv,
                                          medication_or_other_side_effects, history_of_functional_status, body_weight,
                                          family_planning_status, symptom_diagnosis, address,
                                          date_positive_hiv_test_confirmed, treatment_supporter_telephone_number,
                                          transferred_out, tuberculosis_treatment_stop_date, current_arv_regimen,
                                          art_duration, current_art_duration, antenatal_number,
                                          mid_upper_arm_circumference_code, district_tuberculosis_number,
                                          opportunistic_infection, trimethoprim_days_dispensed,
                                          other_medications_dispensed, arv_regimen_days_dispensed, trimethoprim_dosage,
                                          ar_regimen_dose, nutrition_support_and_infant_feeding, baseline_regimen,
                                          baseline_weight, baseline_stage, baseline_cd4, baseline_pregnancy,
                                          name_of_family_member, age_of_family_member, family_member_set, hiv_test,
                                          hiv_test_facility, other_side_effects, other_tests_ordered,
                                          care_entry_point_set, treatment_supporter_tel_no,
                                          other_reason_for_missing_arv, current_regimen_other, treatment_supporter_name,
                                          cd4_classification_for_infants, baseline_regimen_start_date,
                                          baseline_regimen_set, transfer_out_date, transfer_out_set,
                                          health_education_disclosure, other_referral_ordered, age_in_months,
                                          test_result_type, lab_result_txt, lab_result_set, counselling_session_type,
                                          cotrim_given, eid_visit_1_appointment_date, feeding_status_at_eid_visit_1,
                                          counselling_approach, current_hiv_test_result, results_received_as_a_couple,
                                          tb_suspect, baseline_lactating, inh_dosage, inh_days_dispensed, age_unit,
                                          syphilis_test_result, syphilis_test_result_for_partner,
                                          ctx_given_at_eid_visit_1, nvp_given_at_eid_visit_1, eid_visit_1_muac,
                                          medication_duration, clinical_impression_comment, reason_for_appointment,
                                          medication_history, quantity_of_medication,
                                          tb_with_rifampin_resistance_checking, specimen_sources,
                                          eid_immunisation_codes, clinical_assessment_codes,
                                          refiil_of_art_for_the_mother, development_milestone, pre_test_counseling_done,
                                          hct_entry_point, linked_to_care, estimated_gestational_age, eid_concept_type,
                                          hiv_viral_load_date, relationship_to_patient, other_reason_for_appointment,
                                          nutrition_assessment, art_pill_balance, differentiated_service_delivery,
                                          stable_in_dsdm, reason_for_testing, previous_hiv_tests_date,
                                          milligram_per_meter_squared, hiv_testing_service_delivery_model,
                                          hiv_syphillis_duo, prevention_services_received, hiv_first_time_tester,
                                          previous_hiv_test_results, results_received_as_individual,
                                          health_education_setting, health_edu_intervation_approaches,
                                          health_education_depression_status, ovc_screening, art_preparation_readiness,
                                          ovc_assessment, phdp_components, tpt_start_date, tpt_completion_date,
                                          advanced_disease_status, family_member_hiv_status, tpt_status,
                                          rpr_test_results, crag_test_results, tb_lam_results, gender_based_violance,
                                          dapsone_ctx_medset, tuberculosis_medication_set, fluconazole_medication_set,
                                          cervical_cancer_screening, intention_to_conceive, viral_load_test,
                                          genexpert_test, tb_microscopy_results, tb_microscopy_test, tb_lam, rpr_test,
                                          crag_test, arv_med_set, quantity_unit, tpt_side_effects, split_into_drugs,
                                          lab_number, other_drug_dispensed_set, test, test_result, other_tests,
                                          refill_point_code, next_return_date_at_facility)
SELECT encounter_id,
       client_id,
       encounter_date,
       hemoglobin,
       malnutrition,
       method_of_family_planning,
       oedema,
       cd4_panel,
       cd4_percent,
       hiv_viral_load,
       historical_drug_start_date,
       historical_drug_stop_date,
       current_drugs_used,
       tests_ordered,
       number_of_weeks_pregnant,
       medication_orders,
       viral_load_qualitative,
       hepatitis_b_test_qualitative,
       mid_upper_arm_circumference,
       medication_strength,
       register_serial_number,
       duration_units,
       systolic_blood_pressure,
       diastolic_blood_pressure,
       pulse,
       temperature,
       weight,
       height,
       return_visit_date,
       respiratory_rate,
       head_circumference,
       cd4_count,
       estimated_date_of_confinement,
       pmtct,
       pregnant,
       scheduled_patient_visit,
       entry_point_into_hiv_care,
       who_hiv_clinical_stage,
       name_of_location_transferred_to,
       tuberculosis_status,
       tuberculosis_treatment_start_date,
       adherence_to_cotrim,
       arv_adherence_assessment_code,
       reason_for_missing_arv,
       medication_or_other_side_effects,
       history_of_functional_status,
       body_weight,
       family_planning_status,
       symptom_diagnosis,
       address,
       date_positive_hiv_test_confirmed,
       treatment_supporter_telephone_number,
       transferred_out,
       tuberculosis_treatment_stop_date,
       current_arv_regimen,
       art_duration,
       current_art_duration,
       antenatal_number,
       mid_upper_arm_circumference_code,
       district_tuberculosis_number,
       opportunistic_infection,
       trimethoprim_days_dispensed,
       other_medications_dispensed,
       arv_regimen_days_dispensed,
       trimethoprim_dosage,
       ar_regimen_dose,
       nutrition_support_and_infant_feeding,
       baseline_regimen,
       baseline_weight,
       baseline_stage,
       baseline_cd4,
       baseline_pregnancy,
       name_of_family_member,
       age_of_family_member,
       family_member_set,
       hiv_test,
       hiv_test_facility,
       other_side_effects,
       other_tests_ordered,
       care_entry_point_set,
       treatment_supporter_tel_no,
       other_reason_for_missing_arv,
       current_regimen_other,
       treatment_supporter_name,
       cd4_classification_for_infants,
       baseline_regimen_start_date,
       baseline_regimen_set,
       transfer_out_date,
       transfer_out_set,
       health_education_disclosure,
       other_referral_ordered,
       age_in_months,
       test_result_type,
       lab_result_txt,
       lab_result_set,
       counselling_session_type,
       cotrim_given,
       eid_visit_1_appointment_date,
       feeding_status_at_eid_visit_1,
       counselling_approach,
       current_hiv_test_result,
       results_received_as_a_couple,
       tb_suspect,
       baseline_lactating,
       inh_dosage,
       inh_days_dispensed,
       age_unit,
       syphilis_test_result,
       syphilis_test_result_for_partner,
       ctx_given_at_eid_visit_1,
       nvp_given_at_eid_visit_1,
       eid_visit_1_muac,
       medication_duration,
       clinical_impression_comment,
       reason_for_appointment,
       medication_history,
       quantity_of_medication,
       tb_with_rifampin_resistance_checking,
       specimen_sources,
       eid_immunisation_codes,
       clinical_assessment_codes,
       refiil_of_art_for_the_mother,
       development_milestone,
       pre_test_counseling_done,
       hct_entry_point,
       linked_to_care,
       estimated_gestational_age,
       eid_concept_type,
       hiv_viral_load_date,
       relationship_to_patient,
       other_reason_for_appointment,
       nutrition_assessment,
       art_pill_balance,
       differentiated_service_delivery,
       stable_in_dsdm,
       reason_for_testing,
       previous_hiv_tests_date,
       milligram_per_meter_squared,
       hiv_testing_service_delivery_model,
       hiv_syphillis_duo,
       prevention_services_received,
       hiv_first_time_tester,
       previous_hiv_test_results,
       results_received_as_individual,
       health_education_setting,
       health_edu_intervation_approaches,
       health_education_depression_status,
       ovc_screening,
       art_preparation_readiness,
       ovc_assessment,
       phdp_components,
       tpt_start_date,
       tpt_completion_date,
       advanced_disease_status,
       family_member_hiv_status,
       tpt_status,
       rpr_test_results,
       crag_test_results,
       tb_lam_results,
       gender_based_violance,
       dapsone_ctx_medset,
       tuberculosis_medication_set,
       fluconazole_medication_set,
       cervical_cancer_screening,
       intention_to_conceive,
       viral_load_test,
       genexpert_test,
       tb_microscopy_results,
       tb_microscopy_test,
       tb_lam,
       rpr_test,
       crag_test,
       arv_med_set,
       quantity_unit,
       tpt_side_effects,
       split_into_drugs,
       lab_number,
       other_drug_dispensed_set,
       test,
       test_result,
       other_tests,
       refill_point_code,
       next_return_date_at_facility
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
    SELECT pn.given_name,
           TIMESTAMPDIFF(YEAR,p.birthdate,CURRENT_DATE),
           p.gender,
            pi.identifier,
           hivart.return_date,
           hivart.current_regimen,
           hivart.who_stage,
           hivart.no_of_days,
           hivart.tb_status,
           hivart.dsdm,
           hivart.pregnant,
           hivart.emtct
    FROM mamba_fact_encounter_hiv_art hivart INNER JOIN mamba_dim_person_name pn on client_id=pn.external_person_id
     INNER JOIN mamba_dim_person p on client_id= p.external_person_id inner join patient_identifier pi on client_id =pi.patient_id
    WHERE hivart.return_date >= START_DATE
      AND hivart.return_date <= END_DATE AND pi.identifier_type=4;
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
-- ----------------------  sp_fact_encounter_hiv_art_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_create;

CREATE PROCEDURE sp_fact_encounter_hiv_art_card_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_hiv_art_card
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT          NULL,
    client_id                             INT          NULL,
    encounter_date                        DATE         NULL,

    method_of_family_planning             VARCHAR(255) NULL,
    cd4                                   INT NULL,
    hiv_viral_load                        VARCHAR(255) NULL,
    historical_drug_start_date            DATE NULL,
    historical_drug_stop_date             DATE NULL,
    medication_orders                     VARCHAR(255) NULL,
    viral_load_qualitative                VARCHAR(255) NULL,
    hepatitis_b_test___qualitative        VARCHAR(255) NULL,
    duration_units                        VARCHAR(255) NULL,
    return_visit_date                     DATE NULL,
    cd4_count                             INT NULL,
    estimated_date_of_confinement         DATE NULL,
    pmtct                                 VARCHAR(255) NULL,
    pregnant                              VARCHAR(255) NULL,
    scheduled_patient_visist              VARCHAR(255) NULL,
    who_hiv_clinical_stage                VARCHAR(255) NULL,
    name_of_location_transferred_to       TEXT NULL,
    tuberculosis_status                   VARCHAR(255) NULL,
    tuberculosis_treatment_start_date     VARCHAR(255) NULL,
    adherence_assessment_code             VARCHAR(255) NULL,
    reason_for_missing_arv_administration VARCHAR(255) NULL,
    medication_or_other_side_effects      TEXT NULL,
    family_planning_status                VARCHAR(255) NULL,
    symptom_diagnosis                     VARCHAR(255) NULL,
    transfered_out_to_another_facility    VARCHAR(255) NULL,
    tuberculosis_treatment_stop_date      DATE NULL,
    current_arv_regimen                   VARCHAR(255) NULL,
    art_duration                          INT NULL,
    current_art_duration                  INT NULL,
    mid_upper_arm_circumference_code      VARCHAR(255) NULL,
    district_tuberculosis_number          TEXT NULL,
    other_medications_dispensed           TEXT NULL,
    arv_regimen_days_dispensed            DOUBLE NULL,
    ar_regimen_dose                       DOUBLE NULL,
    nutrition_support_and_infant_feeding  VARCHAR(255) NULL,
    other_side_effects                    TEXT NULL,
    other_reason_for_missing_arv          TEXT NULL,
    current_regimen_other                 TEXT NULL,
    transfer_out_date                     DATE NULL,
    cotrim_given                          VARCHAR(80) NULL,
    syphilis_test_result_for_partner      VARCHAR(255) NULL,
    eid_visit_1_z_score                   VARCHAR(255) NULL,
    medication_duration                   VARCHAR(255) NULL,
    medication_prescribed_per_dose        VARCHAR(255) NULL,
    tuberculosis_polymerase               VARCHAR(255) NULL,
    specimen_sources                      VARCHAR(255) NULL,
    estimated_gestational_age             INT NULL,
    hiv_viral_load_date                   DATE NULL,
    other_reason_for_appointment          TEXT NULL,
    nutrition_assesment                   VARCHAR(255) NULL,
    differentiated_service_delivery       VARCHAR(255) NULL,
    stable_in_dsdm                        VARCHAR(255) NULL,
    tpt_start_date                        DATE NULL,
    tpt_completion_date                   DATE NULL,
    advanced_disease_status               VARCHAR(255) NULL,
    tpt_status                            VARCHAR(255) NULL,
    rpr_test_results                      VARCHAR(255) NULL,
    crag_test_results                     VARCHAR(255) NULL,
    tb_lam_results                        VARCHAR(255) NULL,
    cervical_cancer_screening             VARCHAR(255) NULL,
    intention_to_conceive                 VARCHAR(255) NULL,
    tb_microscopy_results                 VARCHAR(255) NULL,
    quantity_unit                         VARCHAR(255) NULL,
    tpt_side_effects                      TEXT NULL,
    lab_number                            TEXT NULL,
    test                                  TEXT NULL,
    test_result                           TEXT NULL,
    refill_point_code                     TEXT NULL,
    next_return_date_at_facility          DATE NULL,
    indication_for_viral_load_testing     VARCHAR(255) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hiv_art_card_client_id_index ON mamba_fact_encounter_hiv_art_card (client_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_card_encounter_id_index ON mamba_fact_encounter_hiv_art_card (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_card_encounter_date_index ON mamba_fact_encounter_hiv_art_card (encounter_date);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_insert;

CREATE PROCEDURE sp_fact_encounter_hiv_art_card_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_hiv_art_card (encounter_id,
                                               client_id,
                                               encounter_date,
                                               method_of_family_planning,
                                               cd4,
                                               hiv_viral_load,
                                               historical_drug_start_date,
                                               historical_drug_stop_date,
                                               medication_orders,
                                               viral_load_qualitative,
                                               hepatitis_b_test___qualitative,
                                               duration_units,
                                               return_visit_date,
                                               cd4_count,
                                               estimated_date_of_confinement,
                                               pmtct,
                                               pregnant,
                                               scheduled_patient_visist,
                                               who_hiv_clinical_stage,
                                               name_of_location_transferred_to,
                                               tuberculosis_status,
                                               tuberculosis_treatment_start_date,
                                               adherence_assessment_code,
                                               reason_for_missing_arv_administration,
                                               medication_or_other_side_effects,
                                               family_planning_status,
                                               symptom_diagnosis,
                                               transfered_out_to_another_facility,
                                               tuberculosis_treatment_stop_date,
                                               current_arv_regimen,
                                               art_duration,
                                               current_art_duration,
                                               mid_upper_arm_circumference_code,
                                               district_tuberculosis_number,
                                               other_medications_dispensed,
                                               arv_regimen_days_dispensed,
                                               ar_regimen_dose,
                                               nutrition_support_and_infant_feeding,
                                               other_side_effects,
                                               other_reason_for_missing_arv,
                                               current_regimen_other,
                                               transfer_out_date,
                                               cotrim_given,
                                               syphilis_test_result_for_partner,
                                               eid_visit_1_z_score,
                                               medication_duration,
                                               medication_prescribed_per_dose,
                                               tuberculosis_polymerase,
                                               specimen_sources,
                                               estimated_gestational_age,
                                               hiv_viral_load_date,
                                               other_reason_for_appointment,
                                               nutrition_assesment,
                                               differentiated_service_delivery,
                                               stable_in_dsdm,
                                               tpt_start_date,
                                               tpt_completion_date,
                                               advanced_disease_status,
                                               tpt_status,
                                               rpr_test_results,
                                               crag_test_results,
                                               tb_lam_results,
                                               cervical_cancer_screening,
                                               intention_to_conceive,
                                               tb_microscopy_results,
                                               quantity_unit,
                                               tpt_side_effects,
                                               lab_number,
                                               test,
                                               test_result,
                                               refill_point_code,
                                               next_return_date_at_facility,
                                               indication_for_viral_load_testing)
SELECT encounter_id,
       client_id,
       encounter_datetime,
       method_of_family_planning,
       cd4,
       hiv_viral_load,
       historical_drug_start_date,
       historical_drug_stop_date,
       medication_orders,
       viral_load_qualitative,
       hepatitis_b_test___qualitative,
       duration_units,
       return_visit_date,
       cd4_count,
       estimated_date_of_confinement,
       pmtct,
       pregnant,
       scheduled_patient_visist,
       who_hiv_clinical_stage,
       name_of_location_transferred_to,
       tuberculosis_status,
       tuberculosis_treatment_start_date,
       adherence_assessment_code,
       reason_for_missing_arv_administration,
       medication_or_other_side_effects,
       family_planning_status,
       symptom_diagnosis,
       transfered_out_to_another_facility,
       tuberculosis_treatment_stop_date,
       current_arv_regimen,
       art_duration,
       current_art_duration,
       mid_upper_arm_circumference_code,
       district_tuberculosis_number,
       other_medications_dispensed,
       FLOOR(arv_regimen_days_dispensed),
       ar_regimen_dose,
       nutrition_support_and_infant_feeding,
       other_side_effects,
       other_reason_for_missing_arv,
       current_regimen_other,
       transfer_out_date,
       cotrim_given,
       syphilis_test_result_for_partner,
       eid_visit_1_z_score,
       medication_duration,
       medication_prescribed_per_dose,
       tuberculosis_polymerase,
       specimen_sources,
       estimated_gestational_age,
       hiv_viral_load_date,
       other_reason_for_appointment,
       nutrition_assesment,
       differentiated_service_delivery,
       stable_in_dsdm,
       tpt_start_date,
       tpt_completion_date,
       advanced_disease_status,
       tpt_status,
       rpr_test_results,
       crag_test_results,
       tb_lam_results,
       cervical_cancer_screening,
       intention_to_conceive,
       tb_microscopy_results,
       quantity_unit,
       tpt_side_effects,
       lab_number,
       test,
       test_result,
       refill_point_code,
       next_return_date_at_facility,
       indication_for_viral_load_testing
FROM mamba_flat_encounter_art_card where encounter_datetime >= DATE_SUB(CURRENT_DATE(),INTERVAL 10 YEAR) ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_update;

CREATE PROCEDURE sp_fact_encounter_hiv_art_card_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card;

CREATE PROCEDURE sp_fact_encounter_hiv_art_card()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hiv_art_card_create();
CALL sp_fact_encounter_hiv_art_card_insert();
CALL sp_fact_encounter_hiv_art_card_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_query;
CREATE PROCEDURE sp_fact_encounter_hiv_art_card_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_card hiv_card WHERE hiv_card.encounter_date >= START_DATE
      AND hiv_card.encounter_date <= END_DATE ;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_create;

CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_hiv_art_summary
(
    id                                          INT AUTO_INCREMENT,
    encounter_id                                INT NULL,
    client_id                                   INT NULL,
    encounter_datetime                          DATE NULL,
    allergy                                     TEXT NULL,
    hepatitis_b_test_qualitative                VARCHAR(255) NULL,
    hepatitis_c_test_qualitative                VARCHAR(255) NULL,
    lost_to_followup                            VARCHAR(255) NULL,
    currently_in_school                         VARCHAR(255) NULL,
    pmtct                                       VARCHAR(255) NULL,
    entry_point_into_hiv_care                   VARCHAR(255) NULL,
    name_of_location_transferred_from           TEXT NULL,
    date_lost_to_followup                       VARCHAR(255) NULL,
    name_of_location_transferred_to             TEXT NULL,
    patient_unique_identifier                   VARCHAR(255) NULL,
    address                                     TEXT NULL,
    date_positive_hiv_test_confirmed            VARCHAR(255) NULL,
    hiv_care_status                             VARCHAR(255) NULL,
    treatment_supporter_telephone_number        TEXT NULL,
    transfered_out_to_another_facility          VARCHAR(255) NULL,
    prior_art                                   VARCHAR(255) NULL,
    post_exposure_prophylaxis                   VARCHAR(255) NULL,
    prior_art_not_transfer                      VARCHAR(255) NULL,
    baseline_regimen                            VARCHAR(255) NULL,
    transfer_in_regimen                         VARCHAR(255) NULL,
    baseline_weight                             VARCHAR(255) NULL,
    baseline_stage                              VARCHAR(255) NULL,
    baseline_cd4                                VARCHAR(255) NULL,
    baseline_pregnancy                          VARCHAR(255) NULL,
    name_of_family_member                       TEXT NULL,
    age_of_family_member                        VARCHAR(255) NULL,
    hiv_test                                    VARCHAR(255) NULL,
    hiv_test_facility                           TEXT NULL,
    other_care_entry_point                      TEXT NULL,
    treatment_supporter_tel_no_owner            TEXT NULL,
    treatment_supporter_name                    TEXT NULL,
    pep_regimen_start_date                      DATE NULL,
    pmtct_regimen_start_date                    DATE NULL,
    earlier_arv_not_transfer_regimen_start_date DATE NULL,
    transfer_in_regimen_start_date              DATE NULL,
    baseline_regimen_start_date                 DATE NULL,
    transfer_out_date                           DATE NULL,
    baseline_regimen_other                      TEXT NULL,
    transfer_in_regimen_other                   TEXT NULL,
    hep_b_prior_art                             VARCHAR(255) NULL,
    hep_b_prior_art_regimen_start_date          VARCHAR(255) NULL,
    baseline_lactating                          VARCHAR(255) NULL,
    age_unit                                    VARCHAR(255) NULL,
    eid_enrolled                                VARCHAR(255) NULL,
    drug_restart_date                           DATE NULL,
    relationship_to_patient                     VARCHAR(255) NULL,
    pre_exposure_prophylaxis                    VARCHAR(255) NULL,
    hts_special_category                        VARCHAR(255) NULL,
    special_category                            VARCHAR(255) NULL,
    other_special_category                      TEXT NULL,
    tpt_start_date                              VARCHAR(255) NULL,
    tpt_completion_date                         DATE NULL,
    treatment_interruption_type                 VARCHAR(255) NULL,
    treatment_interruption                      VARCHAR(255) NULL,
    treatment_interruption_stop_date            DATE NULL,
    treatment_interruption_reason               TEXT NULL,
    hepatitis_b_test_date                       DATE NULL,
    hepatitis_c_test_date                       DATE NULL,
    blood_sugar_test_date                       DATE NULL,
    pre_exposure_prophylaxis_start_date         DATE NULL,
    prep_duration_in_months                     VARCHAR(255) NULL,
    pep_duration_in_months                      VARCHAR(255) NULL,
    hep_b_duration_in_months                    VARCHAR(255) NULL,
    blood_sugar_test_result                     VARCHAR(255) NULL,
    pmtct_duration_in_months                    VARCHAR(255) NULL,
    earlier_arv_not_transfer_duration_in_months VARCHAR(255) NULL,
    family_member_hiv_status                    VARCHAR(255) NULL,
    family_member_hiv_test_date                 DATE NULL,
    hiv_enrollment_date                         DATE NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_client_id_index ON mamba_fact_encounter_hiv_art_summary (client_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_encounter_id_index ON mamba_fact_encounter_hiv_art_summary (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_encounter_date_index ON mamba_fact_encounter_hiv_art_summary (encounter_datetime);


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_insert;

CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_hiv_art_summary (encounter_id,
                                                  client_id,
                                                  encounter_datetime,
                                                  allergy,
                                                  hepatitis_b_test_qualitative,
                                                  hepatitis_c_test_qualitative,
                                                  lost_to_followup,
                                                  currently_in_school,
                                                  pmtct,
                                                  entry_point_into_hiv_care,
                                                  name_of_location_transferred_from,
                                                  date_lost_to_followup,
                                                  name_of_location_transferred_to,
                                                  patient_unique_identifier,
                                                  address,
                                                  date_positive_hiv_test_confirmed,
                                                  hiv_care_status,
                                                  treatment_supporter_telephone_number ,
                                                  transfered_out_to_another_facility,
                                                  prior_art,
                                                  post_exposure_prophylaxis,
                                                  prior_art_not_transfer,
                                                  baseline_regimen,
                                                  transfer_in_regimen,
                                                  baseline_weight,
                                                  baseline_stage,
                                                  baseline_cd4,
                                                  baseline_pregnancy,
                                                  name_of_family_member,
                                                  age_of_family_member,
                                                  hiv_test,
                                                  hiv_test_facility,
                                                  other_care_entry_point,
                                                  treatment_supporter_tel_no_owner,
                                                  treatment_supporter_name,
                                                  pep_regimen_start_date,
                                                  pmtct_regimen_start_date,
                                                  earlier_arv_not_transfer_regimen_start_date,
                                                  transfer_in_regimen_start_date,
                                                  baseline_regimen_start_date,
                                                  transfer_out_date,
                                                  baseline_regimen_other,
                                                  transfer_in_regimen_other,
                                                  hep_b_prior_art,
                                                  hep_b_prior_art_regimen_start_date,
                                                  baseline_lactating,
                                                  age_unit,
                                                  eid_enrolled,
                                                  drug_restart_date,
                                                  relationship_to_patient,
                                                  pre_exposure_prophylaxis,
                                                  hts_special_category,
                                                  special_category,
                                                  other_special_category,
                                                  tpt_start_date,
                                                  tpt_completion_date,
                                                  treatment_interruption_type,
                                                  treatment_interruption,
                                                  treatment_interruption_stop_date,
                                                  treatment_interruption_reason,
                                                  hepatitis_b_test_date,
                                                  hepatitis_c_test_date,
                                                  blood_sugar_test_date,
                                                  pre_exposure_prophylaxis_start_date,
                                                  prep_duration_in_months,
                                                  pep_duration_in_months,
                                                  hep_b_duration_in_months,
                                                  blood_sugar_test_result,
                                                  pmtct_duration_in_months,
                                                  earlier_arv_not_transfer_duration_in_months,
                                                  family_member_hiv_status,
                                                  family_member_hiv_test_date,
                                                  hiv_enrollment_date)
SELECT encounter_id,
       client_id,
       encounter_datetime,
       allergy,
       hepatitis_b_test_qualitative,
       hepatitis_c_test_qualitative,
       lost_to_followup,
       currently_in_school,
       pmtct,
       entry_point_into_hiv_care,
       name_of_location_transferred_from,
       date_lost_to_followup,
       name_of_location_transferred_to,
       patient_unique_identifier,
       address,
       date_positive_hiv_test_confirmed,
       hiv_care_status,
       treatment_supporter_telephone_number,
       transfered_out_to_another_facility,
       prior_art,
       post_exposure_prophylaxis,
       prior_art_not_transfer,
       baseline_regimen,
       transfer_in_regimen,
       baseline_weight,
       baseline_stage,
       baseline_cd4,
       baseline_pregnancy,
       name_of_family_member,
       age_of_family_member,
       hiv_test,
       hiv_test_facility,
       other_care_entry_point,
       treatment_supporter_tel_no_owner,
       treatment_supporter_name,
       pep_regimen_start_date,
       pmtct_regimen_start_date,
       earlier_arv_not_transfer_regimen_start_date,
       transfer_in_regimen_start_date,
       baseline_regimen_start_date,
       transfer_out_date,
       baseline_regimen_other,
       transfer_in_regimen_other,
       hep_b_prior_art,
       hep_b_prior_art_regimen_start_date,
       baseline_lactating,
       age_unit,
       eid_enrolled,
       drug_restart_date,
       relationship_to_patient,
       pre_exposure_prophylaxis,
       hts_special_category,
       special_category,
       other_special_category,
       tpt_start_date,
       tpt_completion_date,
       treatment_interruption_type,
       treatment_interruption,
       treatment_interruption_stop_date,
       treatment_interruption_reason,
       hepatitis_b_test_date,
       hepatitis_c_test_date,
       blood_sugar_test_date,
       pre_exposure_prophylaxis_start_date,
       prep_duration_in_months,
       pep_duration_in_months,
       hep_b_duration_in_months,
       blood_sugar_test_result,
       pmtct_duration_in_months,
       earlier_arv_not_transfer_duration_in_months,
       family_member_hiv_status,
       family_member_hiv_test_date,
       hiv_enrollment_date
FROM mamba_flat_encounter_art_summary_card;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_update;

CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary;

CREATE PROCEDURE sp_fact_encounter_hiv_art_summary()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hiv_art_summary_create();
CALL sp_fact_encounter_hiv_art_summary_insert();
CALL sp_fact_encounter_hiv_art_summary_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_query;
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_summary hiv_sum WHERE hiv_sum.encounter_date >= START_DATE
      AND hiv_sum.encounter_date <= END_DATE ;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_create;

CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_hiv_art_health_education
(
    id                          INT AUTO_INCREMENT,
    encounter_id                INT NULL,
    client_id                   INT NULL,
    encounter_datetime          DATE NULL,
    ovc_screening               VARCHAR(255)  DEFAULT NULL,
    other_linkages              VARCHAR(255)  DEFAULT NULL,
    ovc_assessment              VARCHAR(255)  DEFAULT NULL,
    art_preparation             VARCHAR(255)  DEFAULT NULL,
    depression_status           VARCHAR(255)  DEFAULT NULL,
    gender_based_violance       VARCHAR(255)  DEFAULT NULL,
    other_phdp_components       TEXT  DEFAULT NULL,
    prevention_components       VARCHAR(255)  DEFAULT NULL,
    pss_issues_identified       VARCHAR(255)  DEFAULT NULL,
    intervation_approaches      VARCHAR(255)  DEFAULT NULL,
    linkages_and_refferals      TEXT  DEFAULT NULL,
    clinic_contact_comments     TEXT  DEFAULT NULL,
    scheduled_patient_visit     VARCHAR(255)  DEFAULT NULL,
    health_education_setting    VARCHAR(255)  DEFAULT NULL,
    clinical_impression_comment TEXT  DEFAULT NULL,
    health_education_disclosure VARCHAR(255)  DEFAULT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;


CREATE INDEX
    mamba_fact_encounter_hiv_art_health_education_client_id_index ON mamba_fact_encounter_hiv_art_health_education (client_id);

CREATE INDEX
    mamba_fact_health_education_encounter_id_index ON mamba_fact_encounter_hiv_art_health_education (encounter_id);


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_insert;

CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_hiv_art_health_education (encounter_id,
                                                       client_id,
                                                       encounter_datetime,
                                                       ovc_screening,
                                                       other_linkages,
                                                       ovc_assessment,
                                                       art_preparation,
                                                       depression_status,
                                                       gender_based_violance,
                                                       other_phdp_components,
                                                       prevention_components,
                                                       pss_issues_identified,
                                                       intervation_approaches,
                                                       linkages_and_refferals,
                                                       clinic_contact_comments,
                                                       scheduled_patient_visit,
                                                       health_education_setting,
                                                       clinical_impression_comment,
                                                       health_education_disclosure)
SELECT encounter_id,
       client_id,
       encounter_datetime,
       ovc_screening,
       other_linkages,
       ovc_assessment,
       art_preparation,
       depression_status,
       gender_based_violance,
       other_phdp_components,
       prevention_components,
       pss_issues_identified,
       intervation_approaches,
       linkages_and_refferals,
       clinic_contact_comments,
       scheduled_patient_visit,
       health_education_setting,
       clinical_impression_comment,
       health_education_disclosure


FROM mamba_flat_encounter_art_health_education;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_update;

CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education;

CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hiv_art_health_education_create();
CALL sp_fact_encounter_hiv_art_health_education_insert();
CALL sp_fact_encounter_hiv_art_health_education_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_query;
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_health_education hiv_health WHERE hiv_health.encounter_date >= START_DATE
      AND hiv_health.encounter_date<= END_DATE ;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date;

CREATE PROCEDURE sp_fact_current_arv_regimen_start_date()
BEGIN
-- $BEGIN
CALL sp_fact_current_arv_regimen_start_date_create();
CALL sp_fact_current_arv_regimen_start_date_insert();
CALL sp_fact_current_arv_regimen_start_date_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_create;

CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_current_arv_regimen_start_date
(
    id                                    INT AUTO_INCREMENT,
    client_id                             INT NULL,
    arv_regimen_start_date                 DATE  NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_current_arv_regimen_start_date_client_id_index ON mamba_fact_current_arv_regimen_start_date (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_insert;

CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_current_arv_regimen_start_date (client_id,
                                                       arv_regimen_start_date)
SELECT B.client_id, MIN(encounter_date)
from mamba_fact_encounter_hiv_art_card mfehac
         join mamba_fact_patients_latest_current_regimen
      B
     on B.client_id = mfehac.client_id
where mfehac.current_arv_regimen = B.current_regimen
GROUP BY B.client_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_current_arv_start_date_query;
CREATE PROCEDURE sp_fact_current_arv_start_date_query()
BEGIN
    SELECT *
    FROM mamba_fact_current_arv_regimen_start_date;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_update;

CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients;

CREATE PROCEDURE sp_fact_latest_adherence_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_adherence_patients_create();
CALL sp_fact_latest_adherence_patients_insert();
CALL sp_fact_latest_adherence_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_create;

CREATE PROCEDURE sp_fact_latest_adherence_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_adherence
(
    id        INT AUTO_INCREMENT,
    client_id INT NOT NULL,
    adherence VARCHAR(250) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_adherence_client_id_index ON mamba_fact_patients_latest_adherence (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_insert;

CREATE PROCEDURE sp_fact_latest_adherence_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_adherence (client_id,
                                                adherence)
SELECT b.client_id, adherence_assessment_code
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE adherence_assessment_code IS NOT NULL
      GROUP BY client_id) a ON b.encounter_id = a.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_adherence_query;
CREATE PROCEDURE sp_fact_patient_latest_adherence_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_adherence;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_update;

CREATE PROCEDURE sp_fact_latest_adherence_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients;

CREATE PROCEDURE sp_fact_latest_advanced_disease_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_advanced_disease_patients_create();
CALL sp_fact_latest_advanced_disease_patients_insert();
CALL sp_fact_latest_advanced_disease_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_create;

CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_advanced_disease
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    encounter_date                          DATE NULL,
    advanced_disease                        VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_advanced_disease_client_id_index ON mamba_fact_patients_latest_advanced_disease (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_insert;

CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_advanced_disease(client_id,
                                                        encounter_date,
                                                        advanced_disease)
SELECT b.client_id,encounter_date, advanced_disease_status
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE advanced_disease_status IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_advanced_disease_query;
CREATE PROCEDURE sp_fact_patient_latest_advanced_disease_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_advanced_disease;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_update;

CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients;

CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_arv_days_dispensed_patients_create();
CALL sp_fact_latest_arv_days_dispensed_patients_insert();
CALL sp_fact_latest_arv_days_dispensed_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_create;

CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_arv_days_dispensed
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    days         INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_arv_days_dispensed_client_id_index ON mamba_fact_patients_latest_arv_days_dispensed (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_insert;

CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_arv_days_dispensed(client_id,
                                                          encounter_date,
                                                          days)
SELECT b.client_id,encounter_date, arv_regimen_days_dispensed
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE arv_regimen_days_dispensed IS NOT NULL
      GROUP BY client_id) a ON a.encounter_id = b.encounter_id ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_arv_days_dispensed_query;
CREATE PROCEDURE sp_fact_patient_latest_arv_days_dispensed_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_arv_days_dispensed;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_update;

CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients;

CREATE PROCEDURE sp_fact_latest_current_regimen_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_current_regimen_patients_create();
CALL sp_fact_latest_current_regimen_patients_insert();
CALL sp_fact_latest_current_regimen_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_create;

CREATE PROCEDURE sp_fact_latest_current_regimen_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_current_regimen
(
    id              INT AUTO_INCREMENT,
    client_id       INT NOT NULL,
    current_regimen VARCHAR(250) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_current_regimen_client_id_index ON mamba_fact_patients_latest_current_regimen (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_insert;

CREATE PROCEDURE sp_fact_latest_current_regimen_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_current_regimen (client_id,
                                                current_regimen)
SELECT b.client_id, current_arv_regimen
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE current_arv_regimen IS NOT NULL
      GROUP BY client_id) a ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_current_regimen_query;
CREATE PROCEDURE sp_fact_patient_latest_current_regimen_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_current_regimen;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_update;

CREATE PROCEDURE sp_fact_latest_current_regimen_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients;

CREATE PROCEDURE sp_fact_latest_family_planning_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_family_planning_patients_create();
CALL sp_fact_latest_family_planning_patients_insert();
CALL sp_fact_latest_family_planning_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_create;

CREATE PROCEDURE sp_fact_latest_family_planning_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_family_planning
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_family_planning_client_id_index ON mamba_fact_patients_latest_family_planning (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_insert;

CREATE PROCEDURE sp_fact_latest_family_planning_patients_insert()
BEGIN
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
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_family_planning_query;
CREATE PROCEDURE sp_fact_patient_latest_family_planning_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_family_planning;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_update;

CREATE PROCEDURE sp_fact_latest_family_planning_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients;

CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_hepatitis_b_test_patients_create();
CALL sp_fact_latest_hepatitis_b_test_patients_insert();
CALL sp_fact_latest_hepatitis_b_test_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_create;

CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_hepatitis_b_test
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    result         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_hepatitis_b_test_client_id_index ON mamba_fact_patients_latest_hepatitis_b_test (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_insert;

CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_hepatitis_b_test(client_id,
                                                        encounter_date,
                                                        result)
SELECT b.client_id,encounter_date, hepatitis_b_test___qualitative
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE hepatitis_b_test___qualitative IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_hepatitis_b_test_query;
CREATE PROCEDURE sp_fact_patient_latest_hepatitis_b_test_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_hepatitis_b_test;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_update;

CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients;

CREATE PROCEDURE sp_fact_latest_viral_load_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_viral_load_patients_create();
CALL sp_fact_latest_viral_load_patients_insert();
CALL sp_fact_latest_viral_load_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_create;

CREATE PROCEDURE sp_fact_latest_viral_load_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_viral_load
(
    id        INT AUTO_INCREMENT,
    client_id INT NOT NULL,
    encounter_date DATE NULL,
    hiv_viral_load_copies INT NULL,
    hiv_viral_collection_date DATE NULL,
    specimen_type VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_viral_load_client_id_index ON mamba_fact_patients_latest_viral_load (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_insert;

CREATE PROCEDURE sp_fact_latest_viral_load_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_viral_load (client_id,
                                                encounter_date,
                                                   hiv_viral_load_copies,
                                                   hiv_viral_collection_date,
                                                   specimen_type)
SELECT b.client_id,encounter_date, hiv_viral_load, hiv_viral_load_date, specimen_sources
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id,MAX(encounter_id) AS encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE hiv_viral_load IS NOT NULL
      GROUP BY client_id) a ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_viral_load_query;
CREATE PROCEDURE sp_fact_patient_latest_viral_load_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_viral_load;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_update;

CREATE PROCEDURE sp_fact_latest_viral_load_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients;

CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_iac_decision_outcome_patients_create();
CALL sp_fact_latest_iac_decision_outcome_patients_insert();
CALL sp_fact_latest_iac_decision_outcome_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_create;

CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_iac_decision_outcome
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    decision         TEXT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_iac_decision_outcome_client_id_index ON mamba_fact_patients_latest_iac_decision_outcome (client_id);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_insert;

CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_iac_decision_outcome(client_id,
                                                            encounter_date,
                                                            decision)
SELECT o.person_id, obs_datetime,cn.name
FROM obs o
         INNER JOIN encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN encounter_type et ON e.encounter_type = et.encounter_type_id AND
                                         et.uuid = '38cb2232-30fc-4b1f-8df1-47c795771ee9'
         INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
                     FROM obs
                     WHERE concept_id = 163166
                       AND voided = 0
                     GROUP BY person_id) a ON o.person_id = a.person_id
         LEFT JOIN concept_name cn
                   ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
                      cn.locale = 'en'
WHERE o.concept_id = 163166
  AND obs_datetime = a.latest_date
  AND o.voided = 0
  AND obs_datetime <= CURRENT_DATE()
GROUP BY o.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_iac_decision_outcome_query;
CREATE PROCEDURE sp_fact_patient_latest_iac_decision_outcome_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_iac_decision_outcome;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_update;

CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients;

CREATE PROCEDURE sp_fact_latest_iac_sessions_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_iac_sessions_patients_create();
CALL sp_fact_latest_iac_sessions_patients_insert();
CALL sp_fact_latest_iac_sessions_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_create;

CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_iac_sessions
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    sessions         INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_iac_sessions_client_id_index ON mamba_fact_patients_latest_iac_sessions (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_insert;

CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_iac_sessions(client_id,
                                                    encounter_date,
                                                    sessions)
SELECT obs.person_id,obs_datetime, COUNT(value_datetime) sessions
FROM obs
         INNER JOIN (SELECT person_id, MAX(DATE (value_datetime)) AS vldate
                     FROM obs
                     WHERE concept_id = 163023
                       AND voided = 0
                       AND value_datetime <= CURRENT_DATE()
                       AND obs_datetime <= CURRENT_DATE()
                     GROUP BY person_id) vl_date ON vl_date.person_id = obs.person_id
WHERE concept_id = 163154
  AND value_datetime >= vldate
  AND obs_datetime BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR) AND CURRENT_DATE()
GROUP BY obs.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_arv_days_dispensed_query;
CREATE PROCEDURE sp_fact_patient_latest_arv_days_dispensed_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_arv_days_dispensed;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_update;

CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients;

CREATE PROCEDURE sp_fact_latest_index_tested_children_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_index_tested_children_patients_create();
CALL sp_fact_latest_index_tested_children_patients_insert();
CALL sp_fact_latest_index_tested_children_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_create;

CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_index_tested_children
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    no                            INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_tested_children_client_id_index ON mamba_fact_patients_latest_index_tested_children (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_insert;

CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_index_tested_children(client_id,
                                                             no)
SELECT age.person_id, COUNT(*) AS no
FROM (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 164352
    AND value_coded = 90280) relationship_child
    JOIN (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 99074
    AND (TIMESTAMPDIFF(YEAR, obs_datetime, CURRENT_DATE ()) + value_numeric) <= 19) age
ON relationship_child.obs_group_id = age.obs_group_id
GROUP BY age.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_children_query;
CREATE PROCEDURE sp_fact_patient_latest_index_tested_children_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_children;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_update;

CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients;

CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_index_tested_children_status_patients_create();
CALL sp_fact_latest_index_tested_children_status_patients_insert();
CALL sp_fact_latest_index_tested_children_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_create;

CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_index_tested_children_status
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    no                            INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_patients_latest_children_status_client_id_index ON mamba_fact_patients_latest_index_tested_children_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_insert;

CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_index_tested_children_status(client_id,
                                                                    no)
SELECT age.person_id, COUNT(*) AS no
FROM (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 164352
    AND value_coded = 90280) relationship_child
    JOIN (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 99074
    AND (TIMESTAMPDIFF(YEAR, obs_datetime, CURRENT_DATE ()) + value_numeric) <= 19) age
ON relationship_child.obs_group_id = age.obs_group_id
    INNER JOIN (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 165275) status ON status.obs_group_id = age.obs_group_id
GROUP BY age.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_children_status_query;
CREATE PROCEDURE sp_fact_patient_latest_index_tested_children_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_children_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_update;

CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_index_tested_partners_patients_create();
CALL sp_fact_latest_index_tested_partners_patients_insert();
CALL sp_fact_latest_index_tested_partners_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_create;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_index_tested_partners
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    no                            INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_partners_client_id_index ON mamba_fact_patients_latest_index_tested_partners (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_insert;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_index_tested_partners(client_id,
                                                             no)
Select person_id, count(*) as no from obs  WHERE concept_id = 164352
                                             AND value_coded IN (90288, 165274) AND voided=0 GROUP BY person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_partners_query;
CREATE PROCEDURE sp_fact_patient_latest_index_tested_partners_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_partners;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_update;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_index_tested_partners_status_patients_create();
CALL sp_fact_latest_index_tested_partners_status_patients_insert();
CALL sp_fact_latest_index_tested_partners_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_create;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_index_tested_partners_status
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    no                            INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_patients_latest_partners_status_client_id_index ON mamba_fact_patients_latest_index_tested_partners_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_insert;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_index_tested_partners_status(client_id,
                                                                    no)
SELECT status.person_id, COUNT(*) AS no
FROM (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 164352
    AND value_coded IN (90288, 165274)) relationship_spouse
    INNER JOIN (SELECT family.person_id, obs_group_id
    FROM obs family
    INNER JOIN (SELECT o.person_id, obs_id
    FROM obs o
    WHERE concept_id = 99075
    AND o.voided = 0) b
    ON family.obs_group_id = b.obs_id
    WHERE concept_id = 165275 and voided =0) status
ON status.obs_group_id = relationship_spouse.obs_group_id
GROUP BY status.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_partners_status_query;
CREATE PROCEDURE sp_fact_patient_latest_index_tested_partners_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_partners_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_update;

CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients;

CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_nutrition_assesment_patients_create();
CALL sp_fact_latest_nutrition_assesment_patients_insert();
CALL sp_fact_latest_nutrition_assesment_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_create;

CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_nutrition_assesment
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_nutrition_assesment_client_id_index ON mamba_fact_patients_latest_nutrition_assesment (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_insert;

CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_nutrition_assesment(client_id,
                                                           encounter_date,
                                                           status)
SELECT b.client_id,encounter_date, nutrition_assesment
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE nutrition_assesment IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_nutrition_assesment_query;
CREATE PROCEDURE sp_fact_patient_latest_nutrition_assesment_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_nutrition_assesment;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_update;

CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients;

CREATE PROCEDURE sp_fact_latest_nutrition_support_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_nutrition_support_patients_create();
CALL sp_fact_latest_nutrition_support_patients_insert();
CALL sp_fact_latest_nutrition_support_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_create;

CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_nutrition_support
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    support         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_nutrition_support_client_id_index ON mamba_fact_patients_latest_nutrition_support (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_insert;

CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_nutrition_support(client_id,
                                                         encounter_date,
                                                         support)
SELECT b.client_id,encounter_date, nutrition_support_and_infant_feeding
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE nutrition_support_and_infant_feeding IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_nutrition_support_query;
CREATE PROCEDURE sp_fact_patient_latest_nutrition_support_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_nutrition_support;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_update;

CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients;

CREATE PROCEDURE sp_fact_latest_regimen_line_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_regimen_line_patients_create();
CALL sp_fact_latest_regimen_line_patients_insert();
CALL sp_fact_latest_regimen_line_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_create;

CREATE PROCEDURE sp_fact_latest_regimen_line_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_regimen_line
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    regimen                             VARCHAR(80) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_regimen_line_client_id_index ON mamba_fact_patients_latest_regimen_line (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_insert;

CREATE PROCEDURE sp_fact_latest_regimen_line_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_regimen_line(client_id,
                                                    regimen)
SELECT DISTINCT pp.patient_id, program_workflow_state.concept_id AS line
FROM patient_state
         INNER JOIN program_workflow_state
                    ON patient_state.state = program_workflow_state.program_workflow_state_id
         INNER JOIN program_workflow ON program_workflow_state.program_workflow_id =
                                        program_workflow.program_workflow_id
         INNER JOIN program ON program_workflow.program_id = program.program_id
         INNER JOIN patient_program pp
                    ON patient_state.patient_program_id = pp.patient_program_id AND
                       program_workflow.concept_id = 166214 AND
                       patient_state.end_date IS NULL;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_regimen_line_query;
CREATE PROCEDURE sp_fact_patient_latest_regimen_line_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_regimen_line;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_update;

CREATE PROCEDURE sp_fact_latest_regimen_line_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients;

CREATE PROCEDURE sp_fact_latest_return_date_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_return_date_patients_create();
CALL sp_fact_latest_return_date_patients_insert();
CALL sp_fact_latest_return_date_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_create;

CREATE PROCEDURE sp_fact_latest_return_date_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_return_date
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    return_date                             DATE NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_return_date_client_id_index ON mamba_fact_patients_latest_return_date (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_insert;

CREATE PROCEDURE sp_fact_latest_return_date_patients_insert()
BEGIN
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
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_return_date_query;
CREATE PROCEDURE sp_fact_patient_latest_return_date_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_return_date;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_update;

CREATE PROCEDURE sp_fact_latest_return_date_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients;

CREATE PROCEDURE sp_fact_latest_tb_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_tb_status_patients_create();
CALL sp_fact_latest_tb_status_patients_insert();
CALL sp_fact_latest_tb_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_create;

CREATE PROCEDURE sp_fact_latest_tb_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_tb_status
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_tb_status_client_id_index ON mamba_fact_patients_latest_tb_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_insert;

CREATE PROCEDURE sp_fact_latest_tb_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_tb_status(client_id,
                                                 encounter_date,
                                                 status)
SELECT b.client_id,encounter_date, tuberculosis_status
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE tuberculosis_status IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_tb_status_query;
CREATE PROCEDURE sp_fact_patient_latest_tb_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_tb_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_update;

CREATE PROCEDURE sp_fact_latest_tb_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients;

CREATE PROCEDURE sp_fact_latest_tpt_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_tpt_status_patients_create();
CALL sp_fact_latest_tpt_status_patients_insert();
CALL sp_fact_latest_tpt_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_create;

CREATE PROCEDURE sp_fact_latest_tpt_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_tpt_status
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_tpt_status_client_id_index ON mamba_fact_patients_latest_tpt_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_insert;

CREATE PROCEDURE sp_fact_latest_tpt_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_tpt_status(client_id,
                                                  encounter_date,
                                                  status)
SELECT b.client_id,encounter_date, tpt_status
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE tpt_status IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_tpt_status_query;
CREATE PROCEDURE sp_fact_patient_latest_tpt_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_tpt_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_update;

CREATE PROCEDURE sp_fact_latest_tpt_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients;

CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_viral_load_ordered_patients_create();
CALL sp_fact_latest_viral_load_ordered_patients_insert();
CALL sp_fact_latest_viral_load_ordered_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_create;

CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_viral_load_ordered
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    encounter_date                          DATE NULL,
    order_date                             DATE NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_viral_load_ordered_client_id_index ON mamba_fact_patients_latest_viral_load_ordered (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_insert;

CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_viral_load_ordered (client_id,
                                                encounter_date, order_date)
SELECT b.client_id,encounter_date, hiv_viral_load_date
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE hiv_viral_load IS NULL
        AND hiv_viral_load_date IS NOT NULL
      GROUP BY client_id) a
     ON  a.encounter_id = b.encounter_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_viral_load_ordered_query;
CREATE PROCEDURE sp_fact_patient_latest_viral_load_ordered_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_viral_load_ordered;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_update;

CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients;

CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_vl_after_iac_patients_create();
CALL sp_fact_latest_vl_after_iac_patients_insert();
CALL sp_fact_latest_vl_after_iac_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_create;

CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_vl_after_iac
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    results        VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_vl_after_iac_client_id_index ON mamba_fact_patients_latest_vl_after_iac (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_insert;

CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_vl_after_iac(client_id,
                                                    encounter_date,
                                                    results)
SELECT o.person_id,obs_datetime, value_numeric
FROM obs o
         INNER JOIN encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN encounter_type et ON e.encounter_type = et.encounter_type_id AND
                                         et.uuid = '38cb2232-30fc-4b1f-8df1-47c795771ee9'
         INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
                     FROM obs
                     WHERE concept_id = 1305
                       AND obs_group_id in (SELECT obs_id from obs where concept_id=163157 and voided=0 GROUP BY person_id)
                       AND voided = 0
                     GROUP BY person_id) a ON o.person_id = a.person_id
WHERE o.concept_id = 856
  AND obs_datetime = a.latest_date
  AND o.voided = 0
  AND obs_datetime <= CURRENT_DATE()
GROUP BY o.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_vl_after_iac_query;
CREATE PROCEDURE sp_fact_patient_latest_vl_after_iac_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_vl_after_iac;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_update;

CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients;

CREATE PROCEDURE sp_fact_latest_who_stage_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_who_stage_patients_create();
CALL sp_fact_latest_who_stage_patients_insert();
CALL sp_fact_latest_who_stage_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_create;

CREATE PROCEDURE sp_fact_latest_who_stage_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_who_stage
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    stage         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_who_stage_client_id_index ON mamba_fact_patients_latest_who_stage (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_insert;

CREATE PROCEDURE sp_fact_latest_who_stage_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_who_stage(client_id,
                                                 encounter_date,
                                                 stage)
SELECT b.client_id,encounter_date, who_hiv_clinical_stage
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE who_hiv_clinical_stage IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_who_stage_query;
CREATE PROCEDURE sp_fact_patient_latest_who_stage_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_who_stage;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_update;

CREATE PROCEDURE sp_fact_latest_who_stage_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients;

CREATE PROCEDURE sp_fact_marital_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_marital_status_patients_create();
CALL sp_fact_marital_status_patients_insert();
CALL sp_fact_marital_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_create;

CREATE PROCEDURE sp_fact_marital_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_marital_status
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    marital_status VARCHAR(80) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_marital_status_client_id_index ON mamba_fact_patients_marital_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_insert;

CREATE PROCEDURE sp_fact_marital_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_marital_status (client_id,
                                                marital_status)
SELECT person_id, mdcn.name
FROM person_attribute pa
         INNER JOIN person_attribute_type pat
                    ON pa.person_attribute_type_id = pat.person_attribute_type_id
         INNER JOIN mamba_dim_concept_name mdcn ON pa.value = mdcn.concept_id
WHERE pat.uuid = '8d871f2a-c2cc-11de-8d13-0010c6dffd0f'
  AND pa.voided = 0
  AND mdcn.locale = 'en'
  AND mdcn.concept_name_type = 'FULLY_SPECIFIED';
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_marital_status_query;
CREATE PROCEDURE sp_fact_patient_marital_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_marital_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_update;

CREATE PROCEDURE sp_fact_marital_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients;

CREATE PROCEDURE sp_fact_nationality_patients()
BEGIN
-- $BEGIN
CALL sp_fact_nationality_patients_create();
CALL sp_fact_nationality_patients_insert();
CALL sp_fact_nationality_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_create;

CREATE PROCEDURE sp_fact_nationality_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_nationality
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    nationality                             VARCHAR(80) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_nationality_client_id_index ON mamba_fact_patients_nationality (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_insert;

CREATE PROCEDURE sp_fact_nationality_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_nationality (client_id,
                                                nationality)
SELECT person_id, mdcn.name
FROM person_attribute pa
         INNER JOIN person_attribute_type pat
                    ON pa.person_attribute_type_id = pat.person_attribute_type_id
         INNER JOIN mamba_dim_concept_name mdcn ON pa.value = mdcn.concept_id
WHERE pat.uuid = 'dec484be-1c43-416a-9ad0-18bd9ef28929'
  AND pa.voided = 0
  AND mdcn.locale = 'en'
  AND mdcn.concept_name_type = 'FULLY_SPECIFIED';
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_nationality_query;
CREATE PROCEDURE sp_fact_patient_nationality_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_nationality;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_update;

CREATE PROCEDURE sp_fact_nationality_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients;

CREATE PROCEDURE sp_fact_latest_patient_demographics_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_patient_demographics_patients_create();
CALL sp_fact_latest_patient_demographics_patients_insert();
CALL sp_fact_latest_patient_demographics_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_create;

CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_patient_demographics
(
    id         INT AUTO_INCREMENT,
    patient_id INT NOT NULL,
    birthdate  DATE NULL,
    age        INT NULL,
    gender     VARCHAR(10) NULL,
    dead       BIT NOT NULL DEFAULT 0,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_patient_demos_patient_id_index ON mamba_fact_patients_latest_patient_demographics (patient_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_insert;

CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_patient_demographics(patient_id,
                                                       birthdate,
                                                       age,
                                                       gender,
                                                       dead)
SELECT person_id,
       birthdate,
       TIMESTAMPDIFF(YEAR, birthdate, NOW()) AS age,
       gender,
       dead
from mamba_dim_person where voided=0;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_patient_demographics_query;
CREATE PROCEDURE sp_fact_patient_latest_patient_demographics_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_patient_demographics;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_update;

CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_art_patients;

CREATE PROCEDURE sp_fact_art_patients()
BEGIN
-- $BEGIN
CALL sp_fact_art_patients_create();
CALL sp_fact_art_patients_insert();
CALL sp_fact_art_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_art_patients_create;

CREATE PROCEDURE sp_fact_art_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_art_patients
(
    id        INT AUTO_INCREMENT,
    client_id INT NULL,
    birthdate DATE NULL,
    age       INT NULL,
    gender    VARCHAR(10) NULL,
    dead      BIT NULL,
    age_group VARCHAR(20) NULL,


    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_art_patients_client_id_index ON mamba_fact_art_patients (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_art_patients_insert;

CREATE PROCEDURE sp_fact_art_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_art_patients(client_id,
                                      birthdate,
                                      age,
                                      gender,
                                      dead,
                                      age_group)
SELECT DISTINCT e.client_id, birthdate, mdp.age, gender, dead, mda.datim_agegroup as age_group
FROM (SELECT DISTINCT client_id from mamba_fact_encounter_hiv_art_card) e
         INNER JOIN mamba_fact_patients_latest_patient_demographics mdp ON e.client_id = mdp.patient_id
LEFT JOIN mamba_dim_agegroup mda on mda.age = mdp.age;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_art_patients_query;
CREATE PROCEDURE sp_fact_art_patients_query()
BEGIN
    SELECT *
    FROM mamba_fact_art_patients ;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_art_patients_update;

CREATE PROCEDURE sp_fact_art_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients;

CREATE PROCEDURE sp_fact_calhiv_patients()
BEGIN
-- $BEGIN
CALL sp_fact_calhiv_patients_create();
CALL sp_fact_calhiv_patients_insert();
CALL sp_fact_calhiv_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_create;

CREATE PROCEDURE sp_fact_calhiv_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_audit_tool_art_patients
(
    id                                     INT AUTO_INCREMENT,
    client_id                              INT NOT NULL,
    identifier                             VARCHAR(80) NULL,
    nationality                            VARCHAR(80) NULL,
    marital_status                         VARCHAR(80) NULL,
    birthdate                              DATE NULL,
    age                                    INT NULL,
    dead                                   BIT NOT NULL,
    gender                                 VARCHAR(10) NULL,
    last_visit_date                        DATE NULL,
    return_date                            DATE NULL,
    client_status                          VARCHAR(50) NULL,
    transfer_out_date                      DATE NULL,
    current_regimen                        VARCHAR(255) NULL,
    arv_regimen_start_date                 DATE NULL,
    adherence                              VARCHAR(100) NULL,
    arv_days_dispensed                     INT NULL,
    hiv_viral_load_copies                  INT NULL,
    hiv_viral_collection_date              DATE NULL,
    new_sample_collection_date             DATE NULL,
    advanced_disease                       VARCHAR(255) NULL,
    family_planning_status                 VARCHAR(255) NULL,
    nutrition_assesment                    VARCHAR(100) NULL,
    nutrition_support                      VARCHAR(250) NULL,
    hepatitis_b_test_qualitative           VARCHAR(80) NULL,
    syphilis_test_result_for_partner       VARCHAR(80) NULL,
    cervical_cancer_screening              VARCHAR(250) NULL,
    tuberculosis_status                    VARCHAR(250) NULL,
    tpt_status                             VARCHAR(250) NULL,
    crag_test_results                      VARCHAR(250) NULL,
    WHO_stage                              VARCHAR(250) NULL,
    baseline_cd4                           INT NULL,
    baseline_regimen_start_date            DATE NULL,
    special_category                       VARCHAR(250) NULL,
    regimen_line                           INT NULL,
    health_education_setting               VARCHAR(250),
    pss_issues_identified                  VARCHAR(250),
    art_preparation                        VARCHAR(250) NULL,
    depression_status                      VARCHAR(250) NULL,
    gender_based_violance                  VARCHAR(250) NULL,
    health_education_disclosure            VARCHAR(250) NULL,
    ovc_screening                          VARCHAR(250) NULL,
    ovc_assessment                         VARCHAR(250) NULL,
    prevention_components                  VARCHAR(250) NULL,
    iac_sessions                           INT NULL,
    hivdr_results                          VARCHAR(250) NULL,
    date_hivr_results_recieved_at_facility DATE NULL,
    vl_after_iac                           VARCHAR(100) NULL,
    decision_outcome                       VARCHAR(250) NULL,
    duration_on_art                        INT NULL,
    side_effects                           VARCHAR(250) NULL,
    specimen_source                        VARCHAR(80),
    hiv_vl_date                            DATE NULL,
    children                               INT NULL,
    known_status_children                  INT NULL,
    partners                               INT NULL,
    known_status_partners                  INT NULL,
    age_group                              VARCHAR(50) NULL,
    cacx_date                              DATE NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_audit_tool_art_patients_client_id_index ON mamba_fact_audit_tool_art_patients (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_insert;

CREATE PROCEDURE sp_fact_calhiv_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_audit_tool_art_patients (client_id,
                                                identifier,
                                                nationality,
                                                marital_status,
                                                birthdate,
                                                age,
                                                dead,
                                                gender,
                                                last_visit_date,
                                                return_date,
                                                client_status,
                                                transfer_out_date,
                                                current_regimen,
                                                arv_regimen_start_date,
                                                adherence,
                                                arv_days_dispensed,
                                                hiv_viral_load_copies,
                                                hiv_viral_collection_date,
                                                new_sample_collection_date,
                                                advanced_disease,
                                                family_planning_status,
                                                nutrition_assesment,
                                                nutrition_support,
                                                hepatitis_b_test_qualitative,
                                                syphilis_test_result_for_partner,
                                                cervical_cancer_screening,
                                                tuberculosis_status,
                                                tpt_status,
                                                crag_test_results,
                                                WHO_stage,
                                                baseline_cd4,
                                                baseline_regimen_start_date,
                                                special_category,
                                                regimen_line,
                                                health_education_setting,
                                                pss_issues_identified,
                                                art_preparation,
                                                depression_status,
                                                gender_based_violance,
                                                health_education_disclosure,
                                                ovc_screening,
                                                ovc_assessment,
                                                prevention_components,
                                                iac_sessions,
                                                hivdr_results,
                                                date_hivr_results_recieved_at_facility,
                                                vl_after_iac,
                                                decision_outcome,
                                                duration_on_art,
                                                side_effects,
                                                specimen_source,
                                                hiv_vl_date,
                                                children,
                                                known_status_children,
                                                partners,
                                                known_status_partners,age_group,
                                                cacx_date)
SELECT cohort.client_id,
       identifiers.identifier                                                                  AS identifier,
       nationality,
       marital_status,
       cohort.birthdate,
       cohort.age,
       cohort.dead,
       cohort.gender,
       last_visit_date,
       return_date,
       IF(dead = 0 AND (transfer_out_date IS NULL OR last_visit_date > transfer_out_date),
          IF(days_left_to_be_lost <= 0, 'Active(TX_CURR)', IF(
                          days_left_to_be_lost >= 1 AND days_left_to_be_lost <= 28, 'Lost(TX_CURR)',
                          IF(days_left_to_be_lost > 28, 'LTFU (TX_ML)', ''))), '') AS client_status,
       transfer_out_date,
       current_regimen,
       arv_regimen_start_date,
       adherence,
       days                                                                                    AS arv_days_dispensed,
       hiv_viral_load_copies,
       hiv_viral_collection_date,
       IF(order_date > hiv_viral_collection_date, order_date, NULL)                            AS new_sample_collection_date,
       advanced_disease,
       mfplfp.status                                                                           AS family_planning_status,
       mfplna.status                                                                           AS nutrition_assesment,
       mfplfp.status                                                                           AS nutrition_support,
       IF(mfplhbt.result='UNKNOWN','Not Tested',IF(mfplhbt.result='waiting for test results','Tested',mfplhbt.result))                                                                          AS hepatitis_b_test_qualitative,
       syphilis_test_result_for_partner,
       cervical_cancer_screening,
       mfplts.status                                                                           AS tuberculosis_status,
       mfplts2.status                                                                          AS tpt_status,
       crag_test_results,
       stage                                                                                   AS WHO_stage,
       baseline_cd4,
       baseline_regimen_start_date,
       IF(IFNULL(special_category, '') = '', '', 'Priority population(PP)')                    AS special_category,
       IF(regimen = 90271, 1,
          IF(regimen = 90305, 2,
             IF(regimen = 162987, 3, 1)))                                                      AS regimen_line,
       health_education_setting,
       pss_issues_identified,
       art_preparation,
       depression_status,
       gender_based_violance,
       health_education_disclosure,
       ovc_screening,
       ovc_assessment,
       prevention_components,
       IF(hiv_viral_load_copies >=1000,IFNULL(sessions,0),NULL)                                                                                AS iac_sessions,
       IF(hiv_viral_load_copies >=1000,hivdr_results,NULL) AS hivdr_results,
       date_hivr_results_recieved_at_facility,
       IF(hiv_viral_load_copies >=1000,mfplvai.results,NULL)                                                                         as vl_after_iac,
       IF(hiv_viral_load_copies >=1000,mfplido.decision,NULL)                                                                        AS decision_outcome,
       TIMESTAMPDIFF(MONTH, baseline_regimen_start_date, last_visit_date)                      AS duration_on_art,
       sub_side_effects.medication_or_other_side_effects                                       AS side_effects,
       specimen_type                                                                           AS specimen_source,
       hiv_vl_date,
       mfplitc.no                                                                              AS children,
       mfplitcs.no                                                                             AS known_status_children,
       mfplitp.no                                                                              AS partners,
       mfplitps.no                                                                             AS known_status_partners,
       cohort.age_group                                                                        AS age_group,
       sub_cervical_cancer_screening.encounter_date                                     AS cacx_date

FROM    mamba_fact_art_patients cohort
            LEFT JOIN mamba_fact_patients_nationality mfpn ON mfpn.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_marital_status mfpms ON mfpms.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_return_date mfplrd ON mfplrd.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_current_regimen mfplcr ON mfplcr.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_adherence mfpla ON mfpla.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_arv_days_dispensed mfpladd ON mfpladd.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_viral_load mfplvl ON mfplvl.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_viral_load_ordered mfplvlo ON mfplvlo.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_advanced_disease mfplad ON mfplad.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_family_planning mfplfp ON mfplfp.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_nutrition_assesment mfplna ON mfplna.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_nutrition_support mfplnsmfplns
                      ON mfplnsmfplns.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_hepatitis_b_test mfplhbt ON mfplhbt.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_tb_status mfplts ON mfplts.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_tpt_status mfplts2 ON mfplts2.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_who_stage who_stage ON who_stage.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_regimen_line mfplrl ON mfplrl.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_iac_sessions mfplis ON mfplis.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_vl_after_iac mfplvai ON mfplvai.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_iac_decision_outcome mfplido ON mfplido.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_index_tested_children mfplitc ON mfplitc.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_index_tested_children_status mfplitcs
                      ON mfplitcs.client_id = cohort.client_id

            LEFT JOIN mamba_fact_patients_latest_index_tested_partners mfplitp ON mfplitp.client_id = cohort.client_id
            LEFT JOIN mamba_fact_patients_latest_index_tested_partners_status mfplitps
                      ON mfplitps.client_id = cohort.client_id
            LEFT JOIN (SELECT client_id, MAX(encounter_datetime) AS last_visit_date
                       FROM mamba_flat_encounter_art_card
                       GROUP BY client_id) last_encounter ON last_encounter.client_id = cohort.client_id

            LEFT JOIN (SELECT b.client_id, syphilis_test_result_for_partner
                       FROM mamba_fact_encounter_hiv_art_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_id) as encounter_id
                             FROM mamba_fact_encounter_hiv_art_card
                             WHERE syphilis_test_result_for_partner IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_syphilis_test_result_for_partner
                      ON sub_syphilis_test_result_for_partner.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id,b.encounter_date, cervical_cancer_screening
                       FROM mamba_fact_encounter_hiv_art_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_id) as encounter_id
                             FROM mamba_fact_encounter_hiv_art_card
                             WHERE cervical_cancer_screening IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id ) sub_cervical_cancer_screening
                      ON sub_cervical_cancer_screening.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, crag_test_results
                       FROM mamba_fact_encounter_hiv_art_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_id) as encounter_id
                             FROM mamba_fact_encounter_hiv_art_card
                             WHERE crag_test_results IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id ) sub_crag_test_results
                      ON sub_crag_test_results.client_id = cohort.client_id
            LEFT JOIN (SELECT client_id,
                              baseline_cd4,
                              baseline_regimen_start_date,
                              special_category
                       FROM mamba_fact_encounter_hiv_art_summary
                       GROUP BY client_id) sub_art_summary ON sub_art_summary.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, health_education_setting
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE health_education_setting IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id ) sub_health_education_setting
                      ON sub_health_education_setting.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, pss_issues_identified
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE pss_issues_identified IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id ) sub_pss_issues_identified
                      ON sub_pss_issues_identified.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, art_preparation
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE art_preparation IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_art_preparation
                      ON sub_art_preparation.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, depression_status
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE depression_status IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_depression_status
                      ON sub_depression_status.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, gender_based_violance
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE gender_based_violance IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id ) sub_gender_based_violance
                      ON sub_gender_based_violance.client_id = cohort.client_id
            LEFT JOIN (SELECT client_id, MAX(encounter_datetime) AS latest_encounter_date, health_education_disclosure
                       FROM mamba_fact_encounter_hiv_art_health_education
                       WHERE health_education_disclosure IS NOT NULL
                       GROUP BY client_id) sub_health_education_disclosure
                      ON sub_health_education_disclosure.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, ovc_screening
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE ovc_screening IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_ovc_screening
                      ON sub_ovc_screening.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, ovc_assessment
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE ovc_assessment IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_ovc_assessment
                      ON sub_ovc_assessment.client_id = cohort.client_id
            LEFT JOIN (SELECT b.client_id, prevention_components
                       FROM mamba_fact_encounter_hiv_art_health_education b
                                JOIN
                            (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                             FROM mamba_fact_encounter_hiv_art_health_education
                             WHERE prevention_components IS NOT NULL
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id) sub_prevention_components
                      ON sub_prevention_components.client_id = cohort.client_id

            LEFT JOIN (SELECT client_id, days_left_to_be_lost, transfer_out_date FROM mamba_fact_active_in_care) actives
                      ON actives.client_id = cohort.client_id
            LEFT JOIN mamba_fact_current_arv_regimen_start_date mfcarsd ON mfcarsd.client_id = cohort.client_id
            LEFT JOIN (SELECT a.client_id, hivdr_sample_collected
                       FROM mamba_fact_encounter_non_suppressed_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_date) AS hivdr_sample_collected_date
                             FROM mamba_fact_encounter_non_suppressed_card
                             WHERE hivdr_sample_collected IS NOT NULL
                             GROUP BY client_id) a ON a.client_id = b.client_id AND encounter_date =
                                                                                    hivdr_sample_collected_date) sub_hivdr_sample_collected
                      ON sub_hivdr_sample_collected.client_id = cohort.client_id
            LEFT JOIN (SELECT a.client_id, hivdr_results
                       FROM mamba_fact_encounter_non_suppressed_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_date) AS latest_encounter_date
                             FROM mamba_fact_encounter_non_suppressed_card
                             WHERE hivdr_results IS NOT NULL
                             GROUP BY client_id) a
                            ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_hivdr_results
                      ON sub_hivdr_results.client_id = cohort.client_id
            LEFT JOIN (SELECT pi.patient_id AS patientid, identifier
                       FROM patient_identifier pi
                                INNER JOIN patient_identifier_type pit
                                           ON pi.identifier_type = pit.patient_identifier_type_id AND
                                              pit.uuid = 'e1731641-30ab-102d-86b0-7a5022ba4115'
                       WHERE pi.voided = 0
                       GROUP BY pi.patient_id) identifiers ON cohort.client_id = identifiers.patientid
            LEFT JOIN (SELECT a.client_id, date_hivr_results_recieved_at_facility
                       FROM mamba_fact_encounter_non_suppressed_card b
                                JOIN
                            (SELECT client_id,
                                    MAX(encounter_date) AS latest_encounter_date
                             FROM mamba_fact_encounter_non_suppressed_card
                             WHERE date_hivr_results_recieved_at_facility IS NOT NULL
                             GROUP BY client_id) a
                            ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_date_hivr_results_recieved_at_facility
                      ON sub_date_hivr_results_recieved_at_facility.client_id = cohort.client_id

            LEFT JOIN (SELECT b.client_id, medication_or_other_side_effects
                       FROM mamba_fact_encounter_hiv_art_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_id) as encounter_id
                             FROM mamba_fact_encounter_hiv_art_card
                             GROUP BY client_id) a
                            ON a.encounter_id = b.encounter_id
                       WHERE medication_or_other_side_effects IS NOT NULL) sub_side_effects
                      ON sub_side_effects.client_id = cohort.client_id
            LEFT JOIN (SELECT a.client_id, hiv_vl_date
                       FROM mamba_fact_encounter_non_suppressed_card b
                                JOIN
                            (SELECT client_id, MAX(encounter_date) AS latest_encounter_date
                             FROM mamba_fact_encounter_non_suppressed_card
                             WHERE hiv_vl_date IS NOT NULL
                             GROUP BY client_id) a
                            ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_hiv_vl_date
                      ON sub_hiv_vl_date.client_id = cohort.client_id;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_audit_tool_art_query;
CREATE PROCEDURE sp_fact_audit_tool_art_query(IN id_list VARCHAR(255))
BEGIN
    SELECT *
    FROM mamba_fact_audit_tool_art_patients audit_tool where client_id in (id_list);
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_update;

CREATE PROCEDURE sp_fact_calhiv_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_active_in_care;

CREATE PROCEDURE sp_fact_active_in_care()
BEGIN
-- $BEGIN
CALL sp_fact_active_in_care_create();
CALL sp_fact_active_in_care_insert();
CALL sp_fact_active_in_care_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_create;

CREATE PROCEDURE sp_fact_active_in_care_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_active_in_care
(
    id                   INT AUTO_INCREMENT,
    client_id            INT  NULL,
    latest_return_date   DATE NULL,

    days_left_to_be_lost INT  NULL,
    last_encounter_date  DATE NULL,
    dead                 INT NULL,
    transfer_out_date    DATE NULL,


    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_active_in_care_client_id_index ON mamba_fact_active_in_care (client_id);


-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_insert;

CREATE PROCEDURE sp_fact_active_in_care_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_active_in_care(client_id,
                                      latest_return_date,
                                      days_left_to_be_lost,
                                      last_encounter_date,
                                      dead)
SELECT b.client_id,
       return_visit_date,
       TIMESTAMPDIFF(DAY, DATE(return_visit_date), DATE(CURRENT_DATE())) AS days_lost,
       encounter_date                                                    AS last_encounter_date,
       dead
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) as encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE return_visit_date IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id
         JOIN person p ON b.client_id = p.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_query;
CREATE PROCEDURE sp_fact_active_in_care_query(IN DAYS_LOST INT)
BEGIN
    SELECT *
    FROM mamba_fact_active_in_care WHERE days_left_to_be_lost >= DAYS_LOST;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_update;

CREATE PROCEDURE sp_fact_active_in_care_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients;

CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients()
BEGIN
-- $BEGIN
CALL sp_fact_latest_pregnancy_status_patients_create();
CALL sp_fact_latest_pregnancy_status_patients_insert();
CALL sp_fact_latest_pregnancy_status_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_create;

CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_pregnancy_status
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_pregnancy_status_client_id_index ON mamba_fact_patients_latest_pregnancy_status (client_id);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_insert;

CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_patients_latest_pregnancy_status(client_id,
                                                       encounter_date,
                                                       status)
SELECT a.client_id,encounter_date,
       IF(pregnant='YES','Pregnant',
           IF(pregnant='NO','Not Pregnant Not BreastFeeding',pregnant)) AS family_planning_status
FROM mamba_fact_encounter_hiv_art_card b
         JOIN
     (SELECT client_id, MAX(encounter_id) AS encounter_id
      FROM mamba_fact_encounter_hiv_art_card
      WHERE pregnant IS NOT NULL
      GROUP BY client_id) a
     ON a.encounter_id = b.encounter_id ;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patient_latest_pregnancy_status_query;
CREATE PROCEDURE sp_fact_patient_latest_pregnancy_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_pregnancy_status;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_update;

CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_eid_patients;

CREATE PROCEDURE sp_fact_eid_patients()
BEGIN
-- $BEGIN
CALL sp_fact_eid_patients_create();
CALL sp_fact_eid_patients_insert();
CALL sp_fact_eid_patients_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_create;

CREATE PROCEDURE sp_fact_eid_patients_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_eid_patients
(
    id        INT AUTO_INCREMENT,
    client_id INT  NULL,
    EDD DATE DEFAULT NULL ,
    EID_NO VARCHAR(80) DEFAULT NULL ,
    EID_DOB DATE DEFAULT NULL ,
    EID_AGE INT DEFAULT NULL ,
    EID_WEIGHT INT DEFAULT NULL ,
    EID_NEXT_APPT DATE DEFAULT NULL,
    EID_FEEDING varchar(80) DEFAULT NULL,
    CTX_START varchar(80) DEFAULT NULL,
    CTX_AGE INT DEFAULT NULL,
    1ST_PCR_DATE DATE DEFAULT NULL,
    1ST_PCR_AGE INT DEFAULT NULL,
    1ST_PCR_RESULT varchar(80) DEFAULT NULL,
    1ST_PCR_RECEIVED DATE DEFAULT NULL,
    2ND_PCR_DATE DATE DEFAULT NULL,
    2ND_PCR_AGE INT DEFAULT NULL,
    2ND_PCR_RESULT varchar(80) DEFAULT NULL,
    2ND_PCR_RECEIVED DATE DEFAULT NULL,
    REPEAT_PCR_DATE DATE DEFAULT NULL,
    REPEAT_PCR_AGE INT DEFAULT NULL,
    REPEAT_PCR_RESULT varchar(80) DEFAULT NULL,
    REPEAT_PCR_RECEIVED DATE DEFAULT NULL,
    RAPID_PCR_DATE DATE DEFAULT NULL,
    RAPID_PCR_AGE INT DEFAULT NULL,
    RAPID_PCR_RESULT varchar(80) DEFAULT NULL,
    FINAL_OUTCOME varchar(80) DEFAULT NULL,
    LINKAGE_NO varchar(80) DEFAULT NULL,
    NVP_AT_BIRTH varchar(80) DEFAULT NULL,
    BREAST_FEEDING_STOPPED DATE DEFAULT  NULL,
    PMTCT_STATUS VARCHAR(250) DEFAULT NULL,
    PMTCT_ENROLLMENT_DATE DATE DEFAULT NULL,
    BABY INT DEFAULT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_eid_patients_client_id_index ON mamba_fact_eid_patients (client_id);

CREATE INDEX
    mamba_fact_eid_patients_baby_id_index ON mamba_fact_eid_patients (BABY);

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_insert;

CREATE PROCEDURE sp_fact_eid_patients_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_eid_patients (client_id,
                                     edd,
                                     eid_no,
                                     eid_dob,
                                     eid_age,
                                     eid_weight,
                                     eid_next_appt,
                                     eid_feeding,
                                     ctx_start,
                                     ctx_age,
                                     1st_pcr_date,
                                     1st_pcr_age,
                                     1st_pcr_result,
                                     1st_pcr_received,
                                     2nd_pcr_date,
                                     2nd_pcr_age,
                                     2nd_pcr_result,
                                     2nd_pcr_received,
                                     repeat_pcr_date,
                                     repeat_pcr_age,
                                     repeat_pcr_result,
                                     repeat_pcr_received,
                                     rapid_pcr_date,
                                     rapid_pcr_age,
                                     rapid_pcr_result,
                                     final_outcome,
                                     linkage_no,
                                     nvp_at_birth,
                                     breast_feeding_stopped,
                                     pmtct_status,
                                     pmtct_enrollment_date,
                                     baby)
SELECT patient,
       edd.edd_date,
       eidno.id                                                                                    AS eidno,
       eiddob.dob                                                                                  AS eid_dob,
       TIMESTAMPDIFF(MONTH, eiddob.dob, CURRENT_DATE())                                            AS eid_age,
       eid_w.value_numeric                                                                         AS eid_weight,
       eid_next_appt.value_datetime                                                                AS next_appointment_date,
       eid_feeding.name                                                                            AS feeding,
       ctx.mydate                                                                                  AS ctx_start,
       TIMESTAMPDIFF(MONTH, eiddob.dob, ctx.mydate)                                                AS agectx,
       1stpcr.mydate                                                                               AS 1stpcrdate,
       TIMESTAMPDIFF(MONTH, eiddob.dob, 1stpcr.mydate)                                             AS age1stpcr,
       1stpcrresult.name,
       1stpcrreceived.mydate                                                                       AS 1stpcrrecieved,
       2ndpcr.mydate                                                                               AS 2ndpcrdate,
       TIMESTAMPDIFF(MONTH, eiddob.dob, 2ndpcr.mydate)                                             AS age2ndpcr,
       2ndpcrresult.name,
       2ndpcrreceived.mydate                                                                       AS 2ndpcrrecieved,
       repeatpcr.mydate                                                                            AS repeatpcrdate,
       TIMESTAMPDIFF(MONTH, eiddob.dob, repeatpcr.mydate)                                          AS age3rdpcr,
       repeatpcrresult.name,
       repeatpcrreceived.mydate                                                                    AS repeatpcrrecieved,
       rapidtest.mydate                                                                            AS rapidtestdate,
       TIMESTAMPDIFF(MONTH, eiddob.dob, rapidtest.mydate)                                          AS ageatrapidtest,
       rapidtestresult.name,
       finaloutcome.name,
       linkageno.value_text,
       IF(nvp.mydate IS NULL, '', IF(TIMESTAMPDIFF(DAY, eiddob.dob, nvp.mydate) <= 2, 'Y', 'N'))   AS nvp,
       stopped_bf.latest_date                                                                      AS breast_feeding_stopped,
       IF(cohort.pmtct = 'Not Pregnant Not BreastFeeding', 'Stopped Breast Feeding', cohort.pmtct) AS pmtct,
       enrollment_date,
       babies                                                                                      AS baby

FROM (
         # mothers with babies
         SELECT person_a AS patient, person_b AS babies, pmtct_enrollment.enrollment_date, preg_status.status AS pmtct
         FROM relationship r
                  INNER JOIN person p ON r.person_a = p.person_id
                  INNER JOIN person p1 ON r.person_b = p1.person_id
                  INNER JOIN relationship_type rt
                             ON r.relationship = rt.relationship_type_id AND
                                rt.uuid = '8d91a210-c2cc-11de-8d13-0010c6dffd0f'
                  LEFT JOIN (SELECT client_id, MIN(encounter_date) enrollment_date
                             FROM mamba_fact_encounter_hiv_art_card
                             WHERE pregnant = 'Breast feeding'
                                OR pregnant = 'YES' AND encounter_date <= CURRENT_DATE()
                                 AND encounter_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
                             GROUP BY client_id) pmtct_enrollment ON pmtct_enrollment.client_id = person_a
                  LEFT JOIN (SELECT client_id, status FROM mamba_fact_patients_latest_pregnancy_status) preg_status
                            ON preg_status.client_id = person_a
         WHERE p.gender = 'F'
           AND TIMESTAMPDIFF(MONTH, p1.birthdate, CURRENT_DATE()) <= 24
           AND r.person_b IN (SELECT DISTINCT e.patient_id
                              FROM encounter e
                                       INNER JOIN encounter_type et
                                                  ON e.encounter_type = et.encounter_type_id
                              WHERE e.voided = 0
                                AND et.uuid = '9fcfcc91-ad60-4d84-9710-11cc25258719'
                                AND encounter_datetime <= CURRENT_DATE()
                                AND encounter_datetime >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH))
           AND r.person_a NOT IN (SELECT DISTINCT person_id FROM obs WHERE concept_id = 99165 AND voided = 0)
           AND r.person_b NOT IN (SELECT DISTINCT person_id FROM obs WHERE concept_id = 99165 AND voided = 0)

         UNION
# mothers without babies
         SELECT DISTINCT mfehac.client_id AS patient,
                         NULL             AS babies,
                         pmtct_enrollment_date,
                         'Pregnant'       AS pmtct
         FROM (SELECT client_id
               FROM mamba_fact_encounter_hiv_art_card
               WHERE pregnant = 'YES'
                 AND encounter_date <= CURRENT_DATE()
                 AND encounter_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
               GROUP BY client_id) mfehac
                  LEFT JOIN (SELECT person_a AS patient
                             FROM relationship r
                                      INNER JOIN person p ON r.person_a = p.person_id
                                      INNER JOIN person p1 ON r.person_b = p1.person_id
                                      INNER JOIN relationship_type rt
                                                 ON r.relationship = rt.relationship_type_id AND
                                                    rt.uuid = '8d91a210-c2cc-11de-8d13-0010c6dffd0f'
                                      LEFT JOIN (SELECT client_id, MIN(encounter_date) pmtct_enrollment_date
                                                 FROM mamba_fact_encounter_hiv_art_card
                                                 WHERE pregnant = 'Breast feeding'
                                                    OR pregnant = 'YES' AND encounter_date <= CURRENT_DATE()
                                                     AND encounter_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
                                                 GROUP BY client_id) pmtct_enrollment
                                                ON pmtct_enrollment.client_id = person_a
                                      LEFT JOIN (SELECT client_id, status
                                                 FROM mamba_fact_patients_latest_pregnancy_status) preg_status
                                                ON preg_status.client_id = person_a
                             WHERE p.gender = 'F'
                               AND TIMESTAMPDIFF(MONTH, p1.birthdate, CURRENT_DATE()) <= 24
                               AND r.person_b IN (SELECT DISTINCT e.patient_id
                                                  FROM encounter e
                                                           INNER JOIN encounter_type et
                                                                      ON e.encounter_type = et.encounter_type_id
                                                  WHERE e.voided = 0
                                                    AND et.uuid = '9fcfcc91-ad60-4d84-9710-11cc25258719'
                                                    AND encounter_datetime <= CURRENT_DATE()
                                                    AND encounter_datetime >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH))) alreadymothers
                            ON mfehac.client_id = alreadymothers.patient
                  LEFT JOIN (SELECT client_id, MIN(encounter_date) pmtct_enrollment_date
                             FROM mamba_fact_encounter_hiv_art_card
                             WHERE pregnant = 'YES'
                               AND encounter_date <= CURRENT_DATE()
                               AND encounter_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
                             GROUP BY client_id) pmtct_enrollment ON mfehac.client_id = pmtct_enrollment.client_id
         WHERE alreadymothers.patient IS NULL

         UNION
# babies without parents in emr
         SELECT NULL AS patient, e.patient_id AS babies, NULL AS pmtct_enrollment_date, 'HEI with caregiver' AS pmtct
         FROM encounter e
                  INNER JOIN encounter_type et ON e.encounter_type = et.encounter_type_id
                  INNER JOIN person p ON e.patient_id = p.person_id
         WHERE e.voided = 0
           AND et.uuid = '9fcfcc91-ad60-4d84-9710-11cc25258719'
           AND encounter_datetime <= CURRENT_DATE()
           AND encounter_datetime >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
           AND patient_id NOT IN (SELECT person_b AS parent
                                  FROM relationship r
                                           INNER JOIN relationship_type rt
                                                      ON r.relationship = rt.relationship_type_id AND
                                                         rt.uuid = '8d91a210-c2cc-11de-8d13-0010c6dffd0f')
           AND TIMESTAMPDIFF(MONTH, p.birthdate, CURRENT_DATE()) <= 24) cohort
         LEFT JOIN (SELECT person_id, MAX(DATE(value_datetime)) AS edd_date
                    FROM obs
                    WHERE concept_id = 5596
                      AND voided = 0
                      AND obs_datetime >= DATE_SUB(CURRENT_DATE(), INTERVAL 16 MONTH)
                      AND obs_datetime <= CURRENT_DATE()
                    GROUP BY person_id) edd ON patient = edd.person_id
         LEFT JOIN (SELECT o.person_id, DATE(value_datetime) mydate
    FROM obs o
                             INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
                                         FROM obs
                                         WHERE concept_id = 99771
                                           AND obs.voided = 0
                                         GROUP BY person_id) a
ON o.person_id = a.person_id
WHERE o.concept_id = 99771
  AND obs_datetime = a.latest_date
  AND o.voided = 0
GROUP BY o.person_id) nvp
ON babies = nvp.person_id
    LEFT JOIN (SELECT patient_id, pi.identifier AS id
    FROM patient_identifier pi
    INNER JOIN patient_identifier_type pit
    ON pi.identifier_type = pit.patient_identifier_type_id AND
    pit.uuid = '2c5b695d-4bf3-452f-8a7c-fe3ee3432ffe') eidno
    ON babies = eidno.patient_id
    LEFT JOIN (SELECT person_id, p.birthdate AS dob FROM person p) eiddob ON babies = eiddob.person_id
    LEFT JOIN (SELECT o.person_id, value_numeric
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 5089
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 5089
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) eid_w ON babies = eid_w.person_id
    LEFT JOIN (SELECT o.person_id, value_datetime
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 5096
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 5096
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) eid_next_appt ON babies = eid_next_appt.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99451
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 99451
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) eid_feeding ON babies = eid_feeding.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99773
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 99773
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) ctx ON babies = ctx.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99606
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    WHERE o.concept_id = 99606
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) 1stpcr ON babies = 1stpcr.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99435
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 99435
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) 1stpcrresult ON babies = 1stpcrresult.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99438
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 99438
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) 1stpcrreceived ON babies = 1stpcrreceived.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99436
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 99436
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) 2ndpcr ON babies = 2ndpcr.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99440
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 99440
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) 2ndpcrresult ON babies = 2ndpcrresult.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99442
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 99442
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) 2ndpcrreceived ON babies = 2ndpcrreceived.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 165405
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 165405
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) repeatpcr ON babies = repeatpcr.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 165406
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 165406
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY person_id) repeatpcrresult ON babies = repeatpcrresult.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 165408
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 165408
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY a.person_id) repeatpcrreceived ON babies = repeatpcrreceived.person_id
    LEFT JOIN (SELECT o.person_id, DATE (value_datetime) mydate
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 162879
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 162879
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY a.person_id) rapidtest ON babies = rapidtest.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 162880
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 162880
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) rapidtestresult ON babies = rapidtestresult.person_id
    LEFT JOIN (SELECT o.person_id, cn.name
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99797
    AND obs.voided = 0
    GROUP BY person_id) a ON o.person_id = a.person_id
    LEFT JOIN concept_name cn
    ON value_coded = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
    cn.locale = 'en'
    WHERE o.concept_id = 99797
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) finaloutcome ON babies = finaloutcome.person_id
    LEFT JOIN (SELECT o.person_id, value_text
    FROM obs o
    INNER JOIN (SELECT person_id, MAX(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99751
    AND obs.voided = 0
    GROUP BY person_id) a
    ON o.person_id = a.person_id
    WHERE o.concept_id = 99751
    AND obs_datetime = a.latest_date
    AND o.voided = 0
    GROUP BY o.person_id) linkageno ON babies = linkageno.person_id
    LEFT JOIN (SELECT person_id, MIN(obs_datetime) latest_date
    FROM obs
    WHERE concept_id = 99451
    AND value_coded = 99793
    AND obs.voided = 0
    GROUP BY person_id) stopped_bf ON babies = stopped_bf.person_id;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_query;
CREATE PROCEDURE sp_fact_eid_patients_query()
BEGIN
    SELECT *
    FROM mamba_fact_eid_patients;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_update;

CREATE PROCEDURE sp_fact_eid_patients_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art_card;

CREATE PROCEDURE sp_data_processing_derived_hiv_art_card()
BEGIN
-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art_card;
CALL sp_fact_encounter_hiv_art_summary;
CALL sp_fact_encounter_hiv_art_health_education;
CALL sp_fact_active_in_care;
CALL sp_fact_latest_adherence_patients;
CALL sp_fact_latest_advanced_disease_patients;
CALL sp_fact_latest_arv_days_dispensed_patients;
CALL sp_fact_latest_current_regimen_patients;
CALL sp_fact_latest_family_planning_patients;
CALL sp_fact_latest_hepatitis_b_test_patients;
CALL sp_fact_latest_viral_load_patients;
CALL sp_fact_latest_iac_decision_outcome_patients;
CALL sp_fact_latest_iac_sessions_patients;
CALL sp_fact_latest_index_tested_children_patients;
CALL sp_fact_latest_index_tested_children_status_patients;
CALL sp_fact_latest_index_tested_partners_patients;
CALL sp_fact_latest_index_tested_partners_status_patients;
CALL sp_fact_latest_nutrition_assesment_patients;
CALL sp_fact_latest_nutrition_support_patients;
CALL sp_fact_latest_regimen_line_patients;
CALL sp_fact_latest_return_date_patients;
CALL sp_fact_latest_tb_status_patients;
CALL sp_fact_latest_tpt_status_patients;
CALL sp_fact_latest_viral_load_ordered_patients;
CALL sp_fact_latest_vl_after_iac_patients;
CALL sp_fact_latest_who_stage_patients;
CALL sp_fact_marital_status_patients;
CALL sp_fact_nationality_patients;
CALL sp_fact_latest_patient_demographics_patients;
CALL sp_fact_art_patients;
CALL sp_fact_current_arv_regimen_start_date;
CALL sp_fact_latest_pregnancy_status_patients;
CALL sp_fact_calhiv_patients;
CALL sp_fact_eid_patients;

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

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_calculate_moh_age_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_calculate_moh_age_group;

DELIMITER //

CREATE FUNCTION fn_mamba_calculate_moh_age_group(age INT) RETURNS VARCHAR(15)
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
    ELSE
        SET agegroup = '50+';
    END IF;

    RETURN (agegroup);
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_insert_age_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_load_agegroup;

DELIMITER //

CREATE PROCEDURE sp_mamba_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO mamba_dim_agegroup(age, datim_agegroup, normal_agegroup,moh_age_group)
            VALUES (age, fn_mamba_calculate_agegroup(age), IF(age < 15, '<15', '15+'),fn_mamba_calculate_moh_age_group(age));
            SET age = age + 1;
END WHILE;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card;

CREATE PROCEDURE sp_fact_encounter_hts_card()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hts_card_create();
CALL sp_fact_encounter_hts_card_insert();
CALL sp_fact_encounter_hts_card_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_create;

CREATE PROCEDURE sp_fact_encounter_hts_card_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_hts_card
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    encounter_date                        DATE         NULL,
    family_member_accompanying_patient    VARCHAR(255) NULL,
    other_specified_family_member         VARCHAR(255) NULL,
    delivery_model                        VARCHAR(255) NULL,
    counselling_approach                  VARCHAR(255) NULL,
    hct_entry_point                       VARCHAR(255) NULL,
    community_testing_point               VARCHAR(255) NULL,
    other_community_testing               VARCHAR(255) NULL,
    anc_visit_number                      VARCHAR(255) NULL,
    other_care_entry_point                VARCHAR(255) NULL,
    reason_for_testing                    VARCHAR(255) NULL,
    reason_for_testing_other_specify      TEXT NULL,
    special_category                      VARCHAR(255) NULL,
    other_special_category                TEXT NULL,
    hiv_first_time_tester                 VARCHAR(255) NULL,
    previous_hiv_tests_date               DATE NULL,
    months_since_first_hiv_aids_symptoms  VARCHAR(255),
    previous_hiv_test_results             VARCHAR(255),
    referring_health_facility             VARCHAR(255),
    no_of_times_tested_in_last_12_months  INT NULL,
    no_of_partners_in_the_last_12_months  INT NULL,
    partner_tested_for_hiv                VARCHAR(255) NULL,
    partner_hiv_test_result               VARCHAR(255) NULL,
    pre_test_counseling_done              VARCHAR(255) NULL,
    counselling_session_type              VARCHAR(255) NULL,
    current_hiv_test_result               VARCHAR(255) NULL,
    hiv_syphilis_duo                      VARCHAR(255) NULL,
    consented_for_blood_drawn_for_testing VARCHAR(255) NULL,
    hiv_recency_result                    VARCHAR(255) NULL,
    hiv_recency_viral_load_results        VARCHAR(255) NULL,
    hiv_recency_viral_load_qualitative DOUBLE NULL,
    hiv_recency_sample_id                 VARCHAR(255) NULL,
    hts_fingerprint_captured              VARCHAR(255) NULL,
    results_received_as_individual        VARCHAR(255) NULL,
    results_received_as_a_couple          VARCHAR(255) NULL,
    couple_results                        VARCHAR(255) NULL,
    tb_suspect                            VARCHAR(255) NULL,
    presumptive_tb_case_referred          VARCHAR(255) NULL,
    prevention_services_received          VARCHAR(255) NULL,
    other_prevention_services             VARCHAR(255) NULL,
    has_client_been_linked_to_care        VARCHAR(255) NULL,
    name_of_location_transferred_to       VARCHAR(255) NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hts_card_client_id_index ON mamba_fact_encounter_hts_card (client_id);

CREATE INDEX
    mamba_fact_encounter_hts_encounter_id_index ON mamba_fact_encounter_hts_card (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_encounter_date_index ON mamba_fact_encounter_hts_card (encounter_date);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_insert;

CREATE PROCEDURE sp_fact_encounter_hts_card_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_hts_card (encounter_id,
                                           client_id,
                                           family_member_accompanying_patient, other_specified_family_member,
                                           delivery_model, counselling_approach, hct_entry_point,
                                           community_testing_point, other_community_testing, anc_visit_number,
                                           other_care_entry_point, reason_for_testing, reason_for_testing_other_specify,
                                           special_category, other_special_category, hiv_first_time_tester,
                                           previous_hiv_tests_date, months_since_first_hiv_aids_symptoms,
                                           previous_hiv_test_results, referring_health_facility,
                                           no_of_times_tested_in_last_12_months, no_of_partners_in_the_last_12_months,
                                           partner_tested_for_hiv, partner_hiv_test_result,
                                           pre_test_counseling_done, counselling_session_type,
                                           current_hiv_test_result, hiv_syphilis_duo,
                                           consented_for_blood_drawn_for_testing, hiv_recency_result,
                                           hiv_recency_viral_load_results, hiv_recency_viral_load_qualitative,
                                           hiv_recency_sample_id, hts_fingerprint_captured,
                                           results_received_as_individual, results_received_as_a_couple,
                                           couple_results, tb_suspect, presumptive_tb_case_referred,
                                           prevention_services_received, other_prevention_services,
                                           has_client_been_linked_to_care, name_of_location_transferred_to)
SELECT encounter_id,
       client_id,
       family_member_accompanying_patient,
       other_specified_family_member,
       delivery_model,
       counselling_approach,
       hct_entry_point,
       community_testing_point,
       other_community_testing,
       anc_visit_number,
       other_care_entry_point,
       reason_for_testing,
       reason_for_testing_other_specify,
       special_category,
       other_special_category,
       hiv_first_time_tester,
       previous_hiv_tests_date,
       months_since_first_hiv_aids_symptoms,
       previous_hiv_test_results,
       referring_health_facility,
       no_of_times_tested_in_last_12_months,
       no_of_partners_in_the_last_12_months,
       partner_tested_for_hiv,
       partner_hiv_test_result,
       pre_test_counseling_done,
       counselling_session_type,
       current_hiv_test_result,
       hiv_syphilis_duo,
       consented_for_blood_drawn_for_testing,
       hiv_recency_result,
       hiv_recency_viral_load_results,
       hiv_recency_viral_load_qualitative,
       hiv_recency_sample_id,
       hts_fingerprint_captured,
       results_received_as_individual,
       results_received_as_a_couple,
       couple_results,tb_suspect,
       presumptive_tb_case_referred,
       prevention_services_received,
       other_prevention_services,
       has_client_been_linked_to_care,
       name_of_location_transferred_to

FROM mamba_flat_encounter_hts_card
where encounter_datetime >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_update;

CREATE PROCEDURE sp_fact_encounter_hts_card_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hts  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts;

CREATE PROCEDURE sp_data_processing_derived_hts()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_hts_card;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_create;

CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_create()
BEGIN
-- $BEGIN
CREATE TABLE mamba_fact_encounter_non_suppressed_card
(
    id                                     INT AUTO_INCREMENT,
    encounter_id                           INT NULL,
    client_id                              INT NULL,
    encounter_date                         DATE NULL,

    vl_qualitative                         VARCHAR(80) NULL,
    register_serial_number                 TEXT NULL,
    cd4_count                              INT NULL,
    tuberculosis_status                    VARCHAR(80) NULL,
    current_arv_regimen                    VARCHAR(80) NULL,
    breast_feeding                         VARCHAR(80) NULL,
    eligible_for_art_pregnant              VARCHAR(80) NULL,
    clinical_impression_comment            TEXT NULL,
    hiv_vl_date                            VARCHAR(80) NULL,
    date_vl_results_received_at_facility   DATE NULL,
    session_date                           DATE NULL,
    adherence_assessment_score             VARCHAR(80) NULL,
    date_vl_results_given_to_client        DATE NULL,
    serum_crag_screening_result            TEXT NULL,
    serum_crag_screening                   VARCHAR(80) NULL,
    restarted_iac                          VARCHAR(80) NULL,
    hivdr_sample_collected                 VARCHAR(80) NULL,
    tb_lam_results                         VARCHAR(80) NULL,
    date_cd4_sample_collected              DATE NULL,
    date_of_vl_sample_collection           DATE NULL,
    on_fluconazole_treatment               VARCHAR(80) NULL,
    tb_lam_test_done                       VARCHAR(80) NULL,
    date_hivr_results_recieved_at_facility DATE NULL,
    hivdr_results                          TEXT NULL,
        PRIMARY KEY (id)
) CHARSET = UTF8;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_insert;

CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_encounter_non_suppressed_card (encounter_id,
                                                      client_id,
                                                      encounter_date,
                                                      vl_qualitative, register_serial_number, cd4_count,
                                                      tuberculosis_status, current_arv_regimen, breast_feeding,
                                                      eligible_for_art_pregnant, clinical_impression_comment,
                                                      hiv_vl_date, date_vl_results_received_at_facility, session_date,
                                                      adherence_assessment_score, date_vl_results_given_to_client,
                                                      serum_crag_screening_result, serum_crag_screening, restarted_iac,
                                                      hivdr_sample_collected, tb_lam_results, date_cd4_sample_collected,
                                                      date_of_vl_sample_collection, on_fluconazole_treatment,
                                                      tb_lam_test_done, date_hivr_results_recieved_at_facility,
                                                      hivdr_results)
SELECT encounter_id,
       client_id,
       encounter_datetime,
       vl_qualitative,
       register_serial_number,
       cd4_count,
       tuberculosis_status,
       current_arv_regimen,
       breast_feeding,
       eligible_for_art_pregnant,
       clinical_impression_comment,
       hiv_vl_date,
       date_vl_results_received_at_facility,
       session_date,
       adherence_assessment_score,
       date_vl_results_given_to_client,
       serum_crag_screening_result,
       serum_crag_screening,
       restarted_iac,
       hivdr_sample_collected,
       tb_lam_results,
       date_cd4_sample_collected,
       date_of_vl_sample_collection,
       on_fluconazole_treatment,
       tb_lam_test_done,
       date_hivr_results_recieved_at_facility,
       hivdr_results

FROM mamba_flat_encounter_non_suppressed;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_update;

CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_query;
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_non_suppressed_card non_suppressed WHERE non_suppressed.encounter_date >= START_DATE
      AND non_suppressed.encounter_date <= END_DATE ;
END //

DELIMITER ;


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card;

CREATE PROCEDURE sp_fact_encounter_non_suppressed_card()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card_create();
CALL sp_fact_encounter_non_suppressed_card_insert();
CALL sp_fact_encounter_non_suppressed_card_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_non_suppressed  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_non_suppressed;

CREATE PROCEDURE sp_data_processing_derived_non_suppressed()
BEGIN
-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card;
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_in;

CREATE PROCEDURE sp_fact_transfer_in()
BEGIN
-- $BEGIN
CALL sp_fact_transfer_in_create();
CALL sp_fact_transfer_in_insert();
CALL sp_fact_transfer_in_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_create;

CREATE PROCEDURE sp_fact_transfer_in_create()
BEGIN
-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_fact_transfer_in
(
    id                       INT AUTO_INCREMENT,
    client_id                         INT           NULL,
    encounter_date                    DATE          NOT NULL,
    transfer_in_date                  DATE    NOT NULL,

    PRIMARY KEY (id)

);

CREATE INDEX
    mamba_fact_transfer_in_client_id_index ON mamba_fact_transfer_in (client_id);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_insert;

CREATE PROCEDURE sp_fact_transfer_in_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_transfer_in (
                                  client_id,
                                  encounter_date,
                                  transfer_in_date
                                 )
SELECT person_id, obs_datetime, value_datetime from obs where concept_id=99160 and voided =0 ;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_update;

CREATE PROCEDURE sp_fact_transfer_in_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_out;

CREATE PROCEDURE sp_fact_transfer_out()
BEGIN
-- $BEGIN
CALL sp_fact_transfer_out_create();
CALL sp_fact_transfer_out_insert();
CALL sp_fact_transfer_out_update();
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_create;

CREATE PROCEDURE sp_fact_transfer_out_create()
BEGIN
-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_fact_transfer_out
(
    id                       INT AUTO_INCREMENT,
    client_id                         INT           NULL,
    encounter_date                    DATE          NOT NULL,
    transfer_out_date                  DATE    NOT NULL,

    PRIMARY KEY (id)

);

CREATE INDEX
    mamba_fact_transfer_out_client_id_index ON mamba_fact_transfer_out (client_id);
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_insert;

CREATE PROCEDURE sp_fact_transfer_out_insert()
BEGIN
-- $BEGIN
INSERT INTO mamba_fact_transfer_out (
                                  client_id,
                                  encounter_date,
                                  transfer_out_date
                                 )
SELECT person_id, obs_datetime, value_datetime from obs where concept_id=99165 and voided =0 ;

-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_update;

CREATE PROCEDURE sp_fact_transfer_out_update()
BEGIN
-- $BEGIN
-- $END
END //

DELIMITER ;

        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_transfers  ----------------------------
-- ---------------------------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS sp_data_processing_derived_transfers;

CREATE PROCEDURE sp_data_processing_derived_transfers()
BEGIN
-- $BEGIN

CALL sp_fact_transfer_in;
CALL sp_fact_transfer_out;
-- $END
END //

DELIMITER ;

