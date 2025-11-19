CREATE database IF NOT EXISTS mamba_etl_db;
~-~-

USE mamba_etl_db;
~-~-


        
    
        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_calculate_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_calculate_agegroup;


~-~-
CREATE FUNCTION fn_mamba_calculate_agegroup(age INT) RETURNS VARCHAR(15)
    DETERMINISTIC
BEGIN
    DECLARE agegroup VARCHAR(15);
    CASE
        WHEN age < 1 THEN SET agegroup = '<1';
        WHEN age between 1 and 4 THEN SET agegroup = '1-4';
        WHEN age between 5 and 9 THEN SET agegroup = '5-9';
        WHEN age between 10 and 14 THEN SET agegroup = '10-14';
        WHEN age between 15 and 19 THEN SET agegroup = '15-19';
        WHEN age between 20 and 24 THEN SET agegroup = '20-24';
        WHEN age between 25 and 29 THEN SET agegroup = '25-29';
        WHEN age between 30 and 34 THEN SET agegroup = '30-34';
        WHEN age between 35 and 39 THEN SET agegroup = '35-39';
        WHEN age between 40 and 44 THEN SET agegroup = '40-44';
        WHEN age between 45 and 49 THEN SET agegroup = '45-49';
        WHEN age between 50 and 54 THEN SET agegroup = '50-54';
        WHEN age between 55 and 59 THEN SET agegroup = '55-59';
        WHEN age between 60 and 64 THEN SET agegroup = '60-64';
        ELSE SET agegroup = '65+';
        END CASE;

    RETURN agegroup;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_get_obs_value_column  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_get_obs_value_column;


~-~-
CREATE FUNCTION fn_mamba_get_obs_value_column(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE obsValueColumn VARCHAR(20);

        IF conceptDatatype = 'Text' THEN
            SET obsValueColumn = 'obs_value_text';

        ELSEIF conceptDatatype = 'Coded'
           OR conceptDatatype = 'N/A' THEN
            SET obsValueColumn = 'obs_value_text';

        ELSEIF conceptDatatype = 'Boolean' THEN
            SET obsValueColumn = 'obs_value_boolean';

        ELSEIF  conceptDatatype = 'Date'
                OR conceptDatatype = 'Datetime' THEN
            SET obsValueColumn = 'obs_value_datetime';

        ELSEIF conceptDatatype = 'Numeric' THEN
            SET obsValueColumn = 'obs_value_numeric';

        ELSE
            SET obsValueColumn = 'obs_value_text';

        END IF;

    RETURN (obsValueColumn);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_age_calculator  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_age_calculator;


~-~-
CREATE FUNCTION fn_mamba_age_calculator(birthdate DATE, deathDate DATE) RETURNS INTEGER
    DETERMINISTIC
BEGIN
    DECLARE today DATE;
    DECLARE age INT;

    -- Check if birthdate is not null and not an empty string
    IF birthdate IS NULL OR TRIM(birthdate) = '' THEN
        RETURN NULL;
    ELSE
        SET today = IFNULL(CURDATE(), '0000-00-00');
        -- Check if birthdate is a valid date using STR_TO_DATE and if it's not in the future
        IF STR_TO_DATE(birthdate, '%Y-%m-%d') IS NULL OR STR_TO_DATE(birthdate, '%Y-%m-%d') > today THEN
            RETURN NULL;
        END IF;

        -- If deathDate is provided and in the past, set today to deathDate
        IF deathDate IS NOT NULL AND today > deathDate THEN
            SET today = deathDate;
        END IF;

        SET age = YEAR(today) - YEAR(birthdate);

        -- Adjust age based on month and day
        IF MONTH(today) < MONTH(birthdate) OR (MONTH(today) = MONTH(birthdate) AND DAY(today) < DAY(birthdate)) THEN
            SET age = age - 1;
        END IF;

        RETURN age;
    END IF;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_get_datatype_for_concept  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_get_datatype_for_concept;


~-~-
CREATE FUNCTION fn_mamba_get_datatype_for_concept(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE mysqlDatatype VARCHAR(20);


    IF conceptDatatype = 'Text' THEN
        SET mysqlDatatype = 'TEXT';

    ELSEIF conceptDatatype = 'Coded'
        OR conceptDatatype = 'N/A' THEN
        SET mysqlDatatype = 'VARCHAR(250)';

    ELSEIF conceptDatatype = 'Boolean' THEN
        SET mysqlDatatype = 'BOOLEAN';

    ELSEIF conceptDatatype = 'Date' THEN
        SET mysqlDatatype = 'DATE';

    ELSEIF conceptDatatype = 'Datetime' THEN
        SET mysqlDatatype = 'DATETIME';

    ELSEIF conceptDatatype = 'Numeric' THEN
        SET mysqlDatatype = 'DOUBLE';

    ELSE
        SET mysqlDatatype = 'TEXT';

    END IF;

    RETURN mysqlDatatype;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_generate_json_from_mamba_flat_table_config  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_generate_json_from_mamba_flat_table_config;


~-~-
CREATE FUNCTION fn_mamba_generate_json_from_mamba_flat_table_config(
    is_incremental TINYINT(1)
) RETURNS JSON
    DETERMINISTIC
BEGIN
    DECLARE report_array JSON;
    SET session group_concat_max_len = 200000;

    SELECT CONCAT('{"flat_report_metadata":[', GROUP_CONCAT(
            CONCAT(
                    '{',
                    '"report_name":', JSON_EXTRACT(table_json_data, '$.report_name'),
                    ',"flat_table_name":', JSON_EXTRACT(table_json_data, '$.flat_table_name'),
                    ',"encounter_type_uuid":', JSON_EXTRACT(table_json_data, '$.encounter_type_uuid'),
                    ',"table_columns": ', JSON_EXTRACT(table_json_data, '$.table_columns'),
                    '}'
            ) SEPARATOR ','), ']}')
    INTO report_array
    FROM mamba_flat_table_config
    WHERE (IF(is_incremental = 1, incremental_record = 1, 1));

    RETURN report_array;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_array_length  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_array_length;

~-~-
CREATE FUNCTION fn_mamba_array_length(array_string TEXT) RETURNS INT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_get_array_item_by_index  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_get_array_item_by_index;

~-~-
CREATE FUNCTION fn_mamba_get_array_item_by_index(array_string TEXT, item_index INT) RETURNS TEXT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_array_length  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_array_length;

~-~-
CREATE FUNCTION fn_mamba_json_array_length(json_array TEXT) RETURNS INT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_extract  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_extract;

~-~-
CREATE FUNCTION fn_mamba_json_extract(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
    DETERMINISTIC
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE key_length INT;
  DECLARE key_index INT;

  SET key_name = CONCAT( key_name, '":');
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_extract_array  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_extract_array;

~-~-
CREATE FUNCTION fn_mamba_json_extract_array(json TEXT, key_name VARCHAR(255)) RETURNS TEXT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_extract_object  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_extract_object;

~-~-
CREATE FUNCTION fn_mamba_json_extract_object(json_string TEXT, key_name VARCHAR(255)) RETURNS TEXT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_keys_array  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP FUNCTION IF EXISTS fn_mamba_json_keys_array;

~-~-
CREATE FUNCTION fn_mamba_json_keys_array(json_object TEXT) RETURNS TEXT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_length  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_length;

~-~-
CREATE FUNCTION fn_mamba_json_length(json_array TEXT) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE element_count INT DEFAULT 0;
    DECLARE current_position INT DEFAULT 1;

    WHILE current_position <= CHAR_LENGTH(json_array) DO
        SET element_count = element_count + 1;
        SET current_position = LOCATE(',', json_array, current_position) + 1;

        IF current_position = 0 THEN
            RETURN element_count;
        END IF;
    END WHILE;

RETURN element_count;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_object_at_index  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_object_at_index;

~-~-
CREATE FUNCTION fn_mamba_json_object_at_index(json_array TEXT, index_pos INT) RETURNS TEXT
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_json_value_by_key  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_json_value_by_key;

~-~-
CREATE FUNCTION fn_mamba_json_value_by_key(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
    DETERMINISTIC
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_remove_all_whitespace  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_remove_all_whitespace;

~-~-
CREATE FUNCTION fn_mamba_remove_all_whitespace(input_string TEXT) RETURNS TEXT
    DETERMINISTIC

BEGIN
  DECLARE cleaned_string TEXT;
  SET cleaned_string = input_string;

  -- Replace common whitespace characters
  SET cleaned_string = REPLACE(cleaned_string, CHAR(9), '');   -- Horizontal tab
  SET cleaned_string = REPLACE(cleaned_string, CHAR(10), '');  -- Line feed
  SET cleaned_string = REPLACE(cleaned_string, CHAR(13), '');  -- Carriage return
  SET cleaned_string = REPLACE(cleaned_string, CHAR(32), '');  -- Space
  -- SET cleaned_string = REPLACE(cleaned_string, CHAR(160), ''); -- Non-breaking space

RETURN TRIM(cleaned_string);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_remove_quotes  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_remove_quotes;

~-~-
CREATE FUNCTION fn_mamba_remove_quotes(original TEXT) RETURNS TEXT
    DETERMINISTIC
BEGIN
  DECLARE without_quotes TEXT;

  -- Replace both single and double quotes with nothing
  SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');

RETURN fn_mamba_remove_all_whitespace(without_quotes);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_remove_special_characters  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;


~-~-
CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
    RETURNS VARCHAR(255)
    DETERMINISTIC
    NO SQL
    COMMENT 'Removes special characters from input text'
BEGIN
    DECLARE modified_string VARCHAR(255);
    DECLARE special_chars VARCHAR(255);
    DECLARE char_index INT DEFAULT 1;
    DECLARE current_char CHAR(1);

    IF input_text IS NULL THEN
        RETURN NULL;
    END IF;

    SET modified_string = input_text;

    -- Define special characters to remove
    SET special_chars = '!@#$%^&*?/,()"-=+£:;><ã\\|[]{}\'~`.'; -- TODO: Added '.' xter as well but Remove after adding backtick support

    -- Remove each special character
    WHILE char_index <= CHAR_LENGTH(special_chars) DO
            SET current_char = SUBSTRING(special_chars, char_index, 1);
            SET modified_string = REPLACE(modified_string, current_char, '');
            SET char_index = char_index + 1;
        END WHILE;

    -- Trim any leading or trailing spaces
    RETURN TRIM(modified_string);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_collapse_spaces  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_collapse_spaces;


~-~-
CREATE FUNCTION fn_mamba_collapse_spaces(input_text TEXT)
    RETURNS TEXT
    DETERMINISTIC
BEGIN
    DECLARE result TEXT;
    SET result = input_text;

    -- First replace tabs and other whitespace characters with spaces
    SET result = REPLACE(result, '\t', ' '); -- Replace tabs with a single space

    -- Loop to collapse multiple spaces into one
    WHILE INSTR(result, '  ') > 0
        DO
            SET result = REPLACE(result, '  ', ' '); -- Replace two spaces with one space
        END WHILE;

    RETURN result;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_functions_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_stored_functions_in_schema;


~-~-
CREATE PROCEDURE sp_xf_system_drop_all_stored_functions_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN
    DELETE FROM `mysql`.`proc` WHERE `type` = 'FUNCTION' AND `db` = database_name; -- works in mysql before v.8

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_stored_procedures_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_stored_procedures_in_schema;


~-~-
CREATE PROCEDURE sp_xf_system_drop_all_stored_procedures_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    DELETE FROM `mysql`.`proc` WHERE `type` = 'PROCEDURE' AND `db` = database_name; -- works in mysql before v.8

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_xf_system_drop_all_objects_in_schema  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_objects_in_schema;


~-~-
CREATE PROCEDURE sp_xf_system_drop_all_objects_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    CALL sp_xf_system_drop_all_stored_functions_in_schema(database_name);
    CALL sp_xf_system_drop_all_stored_procedures_in_schema(database_name);
    CALL sp_mamba_system_drop_all_tables(database_name);
    # CALL sp_xf_system_drop_all_views_in_schema (database_name);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_system_drop_all_tables  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_system_drop_all_tables;


-- CREATE PROCEDURE sp_mamba_system_drop_all_tables(IN database_name CHAR(255) CHARACTER SET UTF8MB4)
~-~-
CREATE PROCEDURE sp_mamba_system_drop_all_tables()
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

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_scheduler_wrapper  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_scheduler_wrapper;


~-~-
CREATE PROCEDURE sp_mamba_etl_scheduler_wrapper()

BEGIN

    DECLARE etl_ever_scheduled TINYINT(1);
    DECLARE incremental_mode TINYINT(1);
    DECLARE incremental_mode_cascaded TINYINT(1);

    SELECT COUNT(1)
    INTO etl_ever_scheduled
    FROM _mamba_etl_schedule;

    SELECT incremental_mode_switch
    INTO incremental_mode
    FROM _mamba_etl_user_settings;

    IF etl_ever_scheduled <= 1 OR incremental_mode = 0 THEN
        SET incremental_mode_cascaded = 0;
        CALL sp_mamba_data_processing_drop_and_flatten();
    ELSE
        SET incremental_mode_cascaded = 1;
        CALL sp_mamba_data_processing_increment_and_flatten();
    END IF;

    CALL sp_mamba_data_processing_etl(incremental_mode_cascaded);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_schedule_table_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_table_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_schedule_table_create()
BEGIN

    CREATE TABLE IF NOT EXISTS _mamba_etl_schedule
    (
        id                         INT      NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
        start_time                 DATETIME NOT NULL DEFAULT NOW(),
        end_time                   DATETIME,
        next_schedule              DATETIME,
        execution_duration_seconds BIGINT,
        missed_schedule_by_seconds BIGINT,
        completion_status          ENUM ('SUCCESS', 'ERROR'),
        transaction_status         ENUM ('RUNNING', 'COMPLETED'),
        success_or_error_message   MEDIUMTEXT,

        INDEX mamba_idx_start_time (start_time),
        INDEX mamba_idx_end_time (end_time),
        INDEX mamba_idx_transaction_status (transaction_status),
        INDEX mamba_idx_completion_status (completion_status)
    )
        CHARSET = UTF8MB4;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_schedule  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule;


~-~-
CREATE PROCEDURE sp_mamba_etl_schedule()

BEGIN

    DECLARE etl_execution_delay_seconds TINYINT(2) DEFAULT 0; -- 0 Seconds
    DECLARE interval_seconds INT;
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE time_now DATETIME;
    DECLARE txn_end_time DATETIME;
    DECLARE next_schedule_time DATETIME;
    DECLARE next_schedule_seconds BIGINT;
    DECLARE missed_schedule_seconds INT DEFAULT 0;
    DECLARE time_taken BIGINT;
    DECLARE etl_is_ready_to_run BOOLEAN DEFAULT FALSE;

    -- cleanup stuck schedule
    CALL sp_mamba_etl_un_stuck_scheduler();
    -- check if _mamba_etl_schedule is empty(new) or last transaction_status
    -- is 'COMPLETED' AND it was a 'SUCCESS' AND its 'end_time' was set.
    SET etl_is_ready_to_run = (SELECT COALESCE(
                                              (SELECT IF(end_time IS NOT NULL
                                                             AND transaction_status = 'COMPLETED'
                                                             AND completion_status = 'SUCCESS',
                                                         TRUE, FALSE)
                                               FROM _mamba_etl_schedule
                                               ORDER BY id DESC
                                               LIMIT 1), TRUE));

    IF etl_is_ready_to_run THEN

        SET time_now = NOW();
        SET start_time_seconds = UNIX_TIMESTAMP(time_now);

        INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
        VALUES (time_now, 'RUNNING');

        SET @last_inserted_id = LAST_INSERT_ID();

        UPDATE _mamba_etl_user_settings
        SET last_etl_schedule_insert_id = @last_inserted_id
        WHERE TRUE
        ORDER BY id DESC
        LIMIT 1;

        -- Call ETL
        CALL sp_mamba_etl_scheduler_wrapper();

        SET txn_end_time = NOW();
        SET end_time_seconds = UNIX_TIMESTAMP(txn_end_time);

        SET time_taken = (end_time_seconds - start_time_seconds);


        SET interval_seconds = (SELECT etl_interval_seconds
                                FROM _mamba_etl_user_settings
                                ORDER BY id DESC
                                LIMIT 1);

        SET next_schedule_seconds = start_time_seconds + interval_seconds + etl_execution_delay_seconds;
        SET next_schedule_time = FROM_UNIXTIME(next_schedule_seconds);

        -- Run ETL immediately if schedule was missed (give allowance of 1 second)
        IF end_time_seconds > next_schedule_seconds THEN
            SET missed_schedule_seconds = end_time_seconds - next_schedule_seconds;
            SET next_schedule_time = FROM_UNIXTIME(end_time_seconds + 1);
        END IF;

        UPDATE _mamba_etl_schedule
        SET end_time                   = txn_end_time,
            next_schedule              = next_schedule_time,
            execution_duration_seconds = time_taken,
            missed_schedule_by_seconds = missed_schedule_seconds,
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED'
        WHERE id = @last_inserted_id;

    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_schedule_trim_log_event  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_trim_log_event;


~-~-
CREATE PROCEDURE sp_mamba_etl_schedule_trim_log_event()

BEGIN

    DELETE FROM _mamba_etl_schedule
    WHERE id NOT IN (
        SELECT id FROM (
                           SELECT id
                           FROM _mamba_etl_schedule
                           ORDER BY id DESC
                           LIMIT 20
                       ) AS recent_records
    );

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_un_stuck_scheduler  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_un_stuck_scheduler;


~-~-
CREATE PROCEDURE sp_mamba_etl_un_stuck_scheduler()
BEGIN

    DECLARE running_schedule_record BOOLEAN DEFAULT FALSE;
    DECLARE no_running_mamba_sp BOOLEAN DEFAULT FALSE;
    DECLARE last_schedule_record_id INT;

    SET running_schedule_record = (SELECT COALESCE(
                                                  (SELECT IF(transaction_status = 'RUNNING'
                                                                 AND completion_status is null,
                                                             TRUE, FALSE)
                                                   FROM _mamba_etl_schedule
                                                   ORDER BY id DESC
                                                   LIMIT 1), TRUE));
    SET no_running_mamba_sp = NOT EXISTS (SELECT 1
                                          FROM performance_schema.events_statements_current
                                          WHERE SQL_TEXT LIKE 'CALL sp_mamba_etl_scheduler_wrapper(%'
                                             OR SQL_TEXT = 'CALL sp_mamba_etl_scheduler_wrapper()');
    IF running_schedule_record AND no_running_mamba_sp THEN
        SET last_schedule_record_id = (SELECT MAX(id) FROM _mamba_etl_schedule limit 1);
        UPDATE _mamba_etl_schedule
        SET end_time                   = NOW(),
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED',
            success_or_error_message   = 'Stuck schedule updated'
            WHERE id = last_schedule_record_id;
    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_setup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_setup;


~-~-
CREATE PROCEDURE sp_mamba_etl_setup(
    IN openmrs_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN etl_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT
)
BEGIN

    -- Setup ETL Error log Table
    CALL sp_mamba_etl_error_log();

    -- Setup ETL configurations
    CALL sp_mamba_etl_user_settings(openmrs_database,
                                    etl_database,
                                    concepts_locale,
                                    table_partition_number,
                                    incremental_mode_switch,
                                    automatic_flattening_mode_switch,
                                    etl_interval_seconds);

    -- create ETL schedule log table
    CALL sp_mamba_etl_schedule_table_create();

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_create;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_create(
    IN flat_encounter_table_name VARCHAR(60) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', flat_encounter_table_name, '`');

    SELECT GROUP_CONCAT(CONCAT('`', column_label, '` ', fn_mamba_get_datatype_for_concept(concept_datatype)) SEPARATOR ', ')
    INTO @column_labels
    FROM mamba_concept_metadata
    WHERE flat_table_name = flat_encounter_table_name
      AND concept_datatype IS NOT NULL;

    IF @column_labels IS NOT NULL THEN
        SET @create_table = CONCAT(
            'CREATE TABLE `', flat_encounter_table_name, '` (`encounter_id` INT PRIMARY KEY, `visit_id` INT NULL, `client_id` INT NOT NULL, `encounter_datetime` DATETIME NOT NULL, `location_id` INT NULL, ', @column_labels, ', INDEX `mamba_idx_encounter_id` (`encounter_id`), INDEX `mamba_idx_visit_id` (`visit_id`), INDEX `mamba_idx_client_id` (`client_id`), INDEX `mamba_idx_encounter_datetime` (`encounter_datetime`), INDEX `mamba_idx_location_id` (`location_id`));');
    END IF;

    IF @column_labels IS NOT NULL THEN
        PREPARE deletetb FROM @drop_table;
        PREPARE createtb FROM @create_table;

        EXECUTE deletetb;
        EXECUTE createtb;

        DEALLOCATE PREPARE deletetb;
        DEALLOCATE PREPARE createtb;
    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_create_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_create_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_create_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name) FROM mamba_concept_metadata;

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

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN p_flat_table_name VARCHAR(60) CHARACTER SET UTF8MB4,
    IN p_encounter_id INT -- Optional parameter for incremental insert
)
BEGIN

    DROP TEMPORARY TABLE IF EXISTS temp_concept_metadata;

    SET session group_concat_max_len = 20000;

    -- Handle incremental updates
    IF p_encounter_id IS NOT NULL THEN

        SET @delete_stmt = CONCAT('DELETE FROM `', p_flat_table_name, '` WHERE `encounter_id` = ?');
        PREPARE stmt FROM @delete_stmt;
        SET @encounter_id = p_encounter_id; -- Bind the variable
        EXECUTE stmt USING @encounter_id; -- Use the bound variable
        DEALLOCATE PREPARE stmt;
    END IF;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_concept_metadata
    (
        `id`                  INT          NOT NULL,
        `flat_table_name`     VARCHAR(60)  NOT NULL,
        `encounter_type_uuid` CHAR(38)     NOT NULL,
        `column_label`        VARCHAR(255) NOT NULL,
        `concept_uuid`        CHAR(38)     NOT NULL,
        `obs_value_column`    VARCHAR(50),
        `concept_datatype`    VARCHAR(50),
        `concept_answer_obs`  INT,

        INDEX idx_id (`id`),
        INDEX idx_column_label (`column_label`),
        INDEX idx_concept_uuid (`concept_uuid`),
        INDEX idx_concept_answer_obs (`concept_answer_obs`),
        INDEX idx_flat_table_name (`flat_table_name`),
        INDEX idx_encounter_type_uuid (`encounter_type_uuid`)
    ) CHARSET = UTF8MB4;

    -- Populate metadata
    INSERT INTO temp_concept_metadata
    SELECT DISTINCT `id`,
                    `flat_table_name`,
                    `encounter_type_uuid`,
                    `column_label`,
                    `concept_uuid`,
                    fn_mamba_get_obs_value_column(`concept_datatype`),
                    `concept_datatype`,
                    `concept_answer_obs`
    FROM `mamba_concept_metadata`
    WHERE `flat_table_name` = p_flat_table_name
      AND `concept_id` IS NOT NULL
      AND `concept_datatype` IS NOT NULL;

    -- Generate dynamic columns
    SELECT GROUP_CONCAT(
                   DISTINCT CONCAT(
                    'MAX(CASE WHEN `column_label` = ''',
                    `column_label`,
                    ''' THEN ',
                    `obs_value_column`,
                    ' END) `',
                    `column_label`,
                    '`'
                            ) ORDER BY `id` ASC
           )
    INTO @column_labels
    FROM temp_concept_metadata;

    SELECT DISTINCT `encounter_type_uuid`
    INTO @encounter_type_uuid
    FROM temp_concept_metadata
    LIMIT 1;

    IF @column_labels IS NOT NULL THEN

        CALL sp_mamba_flat_encounter_table_question_concepts_insert(
                p_flat_table_name,
                p_encounter_id,
                @encounter_type_uuid,
                @column_labels
             );

        CALL sp_mamba_flat_encounter_table_answer_concepts_insert(
                p_flat_table_name,
                p_encounter_id,
                @encounter_type_uuid,
                @column_labels
             );
    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_insert_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_insert_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name) FROM mamba_concept_metadata;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_table_insert(tbl_name, NULL); -- Insert all OBS/Encounters for this flat table

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_question_concepts_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_question_concepts_insert;


-- SP inserts all concepts that are questions or have a concept_id value in the Obs table
-- whether their values/answers are coded or non-coded
~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_question_concepts_insert(
    IN p_table_name VARCHAR(60),
    IN p_encounter_id INT,
    IN p_encounter_type_uuid CHAR(38),
    IN p_column_labels TEXT
)
BEGIN
    DECLARE sql_stmt TEXT;

    -- Construct base INSERT statement
    SET sql_stmt = CONCAT(
            'INSERT INTO `', p_table_name, '` ',
            'SELECT
                o.encounter_id,
                MAX(o.visit_id) AS visit_id,
                o.person_id,
                o.encounter_datetime,
                MAX(o.location_id) AS location_id,
                ', p_column_labels, '
        FROM mamba_z_encounter_obs o
        INNER JOIN temp_concept_metadata tcm
            ON tcm.concept_uuid = o.obs_question_uuid
        WHERE 1=1 ');

    -- Add encounter_id filter if provided
    IF p_encounter_id IS NOT NULL THEN
        SET sql_stmt = CONCAT(sql_stmt,
                              ' AND o.encounter_id = ', p_encounter_id);
    END IF;

    -- Add remaining conditions
    SET sql_stmt = CONCAT(sql_stmt,
                          ' AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
          AND tcm.obs_value_column IS NOT NULL
          AND o.obs_group_id IS NULL
          AND o.voided = 0
        GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
        ORDER BY o.encounter_id ASC');

    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_table_answer_concepts_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_answer_concepts_insert;


-- Create a stored procedure to insert answer concepts into a flat table
-- These are concepts that are answers to other question concepts. e.g. multichoice answers in a select or dropdown or radio answers
-- e.g. Key population. They are usually represented as Yes/No or 1/0 or just their concept name under their column name.
-- they dont have a concept_id value or entry in the Obs table, that's why we join on o.obs_value_coded_uuid
~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_table_answer_concepts_insert(
    IN p_table_name VARCHAR(60),
    IN p_encounter_id INT,
    IN p_encounter_type_uuid CHAR(38),
    IN p_column_labels TEXT
)
BEGIN
    DECLARE sql_stmt TEXT;
    DECLARE update_columns TEXT;

    -- Generate UPDATE part for ON DUPLICATE KEY UPDATE
    SELECT GROUP_CONCAT(
                   CONCAT('`', column_label, '` = COALESCE(VALUES(`',
                          column_label, '`), `', column_label, '`)')
           )
    INTO update_columns
    FROM temp_concept_metadata;

    -- Construct base INSERT statement
    SET sql_stmt = CONCAT(
            'INSERT INTO `', p_table_name, '` ',
            'SELECT
                o.encounter_id,
                MAX(o.visit_id) AS visit_id,
                o.person_id,
                o.encounter_datetime,
                MAX(o.location_id) AS location_id,
                ', p_column_labels, '
        FROM mamba_z_encounter_obs o
        INNER JOIN temp_concept_metadata tcm
            ON tcm.concept_uuid = o.obs_value_coded_uuid
        WHERE 1=1 '
                   );

    -- Add encounter_id filter if provided
    IF p_encounter_id IS NOT NULL THEN
        SET sql_stmt = CONCAT(sql_stmt,
                              ' AND o.encounter_id = ', p_encounter_id);
    END IF;

    -- Add remaining conditions and ON DUPLICATE KEY UPDATE clause
    SET sql_stmt = CONCAT(sql_stmt,
                          ' AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
          AND tcm.obs_value_column IS NOT NULL
          AND o.obs_group_id IS NULL
          AND o.voided = 0
        GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
        ORDER BY o.encounter_id ASC
        ON DUPLICATE KEY UPDATE ', update_columns);

    -- Execute the statement
    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_incremental_create_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_incremental_create_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_incremental_create_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name)
        FROM mamba_concept_metadata md
        WHERE incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_drop_table(tbl_name);
        CALL sp_mamba_flat_encounter_table_create(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_incremental_insert_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_incremental_insert_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_incremental_insert_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT(flat_table_name)
        FROM mamba_concept_metadata md
        WHERE incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_table_insert(tbl_name, NULL); -- Insert all OBS/Encounters for this flat table

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_incremental_update_encounter  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_incremental_update_encounter;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_incremental_update_encounter()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE encounter_id INT;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT eo.encounter_id, cm.flat_table_name
        FROM mamba_z_encounter_obs eo
                 INNER JOIN mamba_concept_metadata cm ON eo.encounter_type_uuid = cm.encounter_type_uuid
        WHERE eo.incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO encounter_id, tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_table_insert(tbl_name, encounter_id); -- Update only OBS/Encounters that have been modified for this flat table

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_incremental_update_encounter  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_incremental_update_encounter;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_incremental_update_encounter()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE encounter_id INT;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT eo.encounter_id, cm.flat_table_name
        FROM mamba_z_encounter_obs eo
                 INNER JOIN mamba_concept_metadata cm ON eo.encounter_type_uuid = cm.encounter_type_uuid
        WHERE eo.incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO encounter_id, tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_table_insert(tbl_name, encounter_id); -- Update only OBS/Encounters that have been modified for this flat table

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_obs_group_table_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `sp_mamba_flat_encounter_obs_group_table_create`;


~-~-
CREATE PROCEDURE `sp_mamba_flat_encounter_obs_group_table_create`(
    IN `flat_encounter_table_name` VARCHAR(60) CHARSET UTF8MB4,
    IN `obs_group_concept_name` VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

SET session group_concat_max_len = 20000;
SET @column_labels := NULL;
    SET @tbl_obs_group_name = CONCAT(LEFT(`flat_encounter_table_name`, 50), '_', `obs_group_concept_name`); -- TODO: 50 + 12 to make 62

        SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', @tbl_obs_group_name, '`');

SELECT GROUP_CONCAT(CONCAT(`column_label`, ' ', fn_mamba_get_datatype_for_concept(`concept_datatype`)) SEPARATOR ', ')
INTO @column_labels
FROM `mamba_concept_metadata` cm
         INNER JOIN
     (SELECT DISTINCT `obs_question_concept_id`
      FROM `mamba_z_encounter_obs` eo
               INNER JOIN `mamba_obs_group` og
                          ON eo.`obs_id` = og.`obs_id`
      WHERE eo.`obs_group_id` IS NOT NULL
        AND og.`obs_group_concept_name` = `obs_group_concept_name`) eo
     ON cm.`concept_id` = eo.`obs_question_concept_id`
WHERE `flat_table_name` = `flat_encounter_table_name`
  AND `concept_datatype` IS NOT NULL;

IF @column_labels IS NOT NULL THEN
        SET @create_table = CONCAT(
                'CREATE TABLE `', @tbl_obs_group_name, '` (',
                '`encounter_id` INT NOT NULL,',
                '`visit_id` INT NULL,',
                '`client_id` INT NOT NULL,',
                '`encounter_datetime` DATETIME NOT NULL,',
                '`location_id` INT NULL, '
                '`obs_group_id` INT NOT NULL,', @column_labels,

                ',INDEX `mamba_idx_encounter_id` (`encounter_id`),',
                'INDEX `mamba_idx_visit_id` (`visit_id`),',
                'INDEX `mamba_idx_client_id` (`client_id`),',
                'INDEX `mamba_idx_encounter_datetime` (`encounter_datetime`),',
                'INDEX `mamba_idx_location_id` (`location_id`));'
        );
END IF;

    IF @column_labels IS NOT NULL THEN
        PREPARE deletetb FROM @drop_table;
PREPARE createtb FROM @create_table;

EXECUTE deletetb;
EXECUTE createtb;

DEALLOCATE PREPARE deletetb;
DEALLOCATE PREPARE createtb;
END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_obs_group_table_create_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_create_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_create_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE obs_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT 0;

    DECLARE cursor_flat_tables CURSOR FOR
    SELECT DISTINCT(flat_table_name) FROM mamba_concept_metadata;

    DECLARE cursor_obs_group_tables CURSOR FOR
    SELECT DISTINCT(obs_group_concept_name) FROM mamba_obs_group;

    -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_flat_tables;

        REPEAT
            FETCH cursor_flat_tables INTO tbl_name;
                IF NOT done THEN
                    OPEN cursor_obs_group_tables;
                        block2: BEGIN
                            DECLARE doneobs_name INT DEFAULT 0;
                            DECLARE firstobs_name varchar(255) DEFAULT '';
                            DECLARE i int DEFAULT 1;
                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneobs_name = 1;

                            REPEAT
                                FETCH cursor_obs_group_tables INTO obs_name;

                                    IF i = 1 THEN
                                        SET firstobs_name = obs_name;
                                    END IF;

                                    CALL sp_mamba_flat_encounter_obs_group_table_create(tbl_name,obs_name);
                                    SET i = i + 1;

                                UNTIL doneobs_name
                            END REPEAT;

                            CALL sp_mamba_flat_encounter_obs_group_table_create(tbl_name,firstobs_name);
                        END block2;
                    CLOSE cursor_obs_group_tables;
                END IF;
            UNTIL done
        END REPEAT;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_obs_group_table_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert(
    IN flat_encounter_table_name VARCHAR(60) CHARACTER SET UTF8MB4,
    IN obs_group_concept_name VARCHAR(255) CHARACTER SET UTF8MB4,
    IN encounter_id INT -- Optional parameter for incremental insert
)
BEGIN
    -- Set maximum length for GROUP_CONCAT
SET session group_concat_max_len = 20000;

-- Set up table name and encounter_id variables
SET @tbl_name = flat_encounter_table_name;
    SET @obs_group_name = obs_group_concept_name;
    SET @enc_id = encounter_id;

    -- Generate observation group table name dynamically
    SET @tbl_obs_group_name = CONCAT(LEFT(@tbl_name, 50), '_', obs_group_concept_name);

    -- Handle the optional encounter_id parameter
    IF @enc_id IS NOT NULL THEN
        -- If encounter_id is provided, delete existing records for that encounter_id
        SET @delete_stmt = CONCAT('DELETE FROM `', @tbl_obs_group_name, '` WHERE `encounter_id` = ', @enc_id);
PREPARE deletetbl FROM @delete_stmt;
EXECUTE deletetbl;
DEALLOCATE PREPARE deletetbl;
ELSE
        SET @enc_id = 0;
END IF;

    -- Create and populate a temporary table for concept metadata
    CREATE TEMPORARY TABLE IF NOT EXISTS `mamba_temp_concept_metadata_group` (
        `id` INT NOT NULL,
        `flat_table_name` VARCHAR(60) NOT NULL,
        `encounter_type_uuid` CHAR(38) NOT NULL,
        `column_label` VARCHAR(255) NOT NULL,
        `concept_uuid` CHAR(38) NOT NULL,
        `obs_value_column` VARCHAR(50),
        `concept_answer_obs` INT,
        INDEX (`id`),
        INDEX (`column_label`),
        INDEX (`concept_uuid`),
        INDEX (`concept_answer_obs`),
        INDEX (`flat_table_name`),
        INDEX (`encounter_type_uuid`)
    ) CHARSET = UTF8MB4;

TRUNCATE TABLE `mamba_temp_concept_metadata_group`;

INSERT INTO `mamba_temp_concept_metadata_group`
SELECT DISTINCT
    cm.`id`,
    cm.`flat_table_name`,
    cm.`encounter_type_uuid`,
    cm.`column_label`,
    cm.`concept_uuid`,
    fn_mamba_get_obs_value_column(cm.`concept_datatype`) AS `obs_value_column`,
    cm.`concept_answer_obs`
FROM `mamba_concept_metadata` cm
         INNER JOIN (
    SELECT DISTINCT eo.`obs_question_concept_id`
    FROM `mamba_z_encounter_obs` eo
             INNER JOIN `mamba_obs_group` og ON eo.`obs_id` = og.`obs_id`
    WHERE og.`obs_group_concept_name` = @obs_group_name
) eo ON cm.`concept_id` = eo.`obs_question_concept_id`
WHERE cm.`flat_table_name` = @tbl_name;

-- Generate dynamic column labels for the insert statement
SELECT GROUP_CONCAT(DISTINCT
                            CONCAT('MAX(CASE WHEN `column_label` = ''', `column_label`, ''' THEN ',
                                   `obs_value_column`, ' END) `', `column_label`, '`')
                            ORDER BY `id` ASC)
INTO @column_labels
FROM `mamba_temp_concept_metadata_group`;

SELECT DISTINCT `encounter_type_uuid` INTO @tbl_encounter_type_uuid FROM `mamba_temp_concept_metadata_group`;

-- Check if column labels are generated
IF @column_labels IS NOT NULL THEN

    SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_obs_group_name, '` ',
            'SELECT eo.`encounter_id`, MAX(eo.`visit_id`) AS `visit_id`, eo.`person_id`, eo.`encounter_datetime`, MAX(eo.`location_id`) AS `location_id`, eo.`obs_group_id`, ',
            @column_labels, ' ',
            'FROM `mamba_z_encounter_obs` eo ',
            'INNER JOIN `mamba_temp_concept_metadata_group` tcm ON tcm.`concept_uuid` = eo.`obs_question_uuid` ',
            'WHERE eo.`obs_group_id` IS NOT NULL ',
            'AND eo.`voided` = 0 ',
            IF(@enc_id <> 0, CONCAT('AND eo.`encounter_id` = ', @enc_id, ' '), ''),
            'GROUP BY eo.`encounter_id`, eo.`person_id`, eo.`encounter_datetime`, eo.`obs_group_id` '
        );

PREPARE inserttbl FROM @insert_stmt;
EXECUTE inserttbl;
DEALLOCATE PREPARE inserttbl;

SET @update_stmt = (
            SELECT GROUP_CONCAT(
                CONCAT('`', `column_label`, '` = COALESCE(VALUES(`', `column_label`, '`), `', `column_label`, '`)')
            )
            FROM `mamba_temp_concept_metadata_group`
        );

        SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_obs_group_name, '` ',
            'SELECT eo.`encounter_id`, MAX(eo.`visit_id`) AS `visit_id`, eo.`person_id`, eo.`encounter_datetime`, MAX(eo.`location_id`) AS `location_id`,eo.`obs_group_id` , ',
            @column_labels, ' ',
            'FROM `mamba_z_encounter_obs` eo ',
            'INNER JOIN `mamba_temp_concept_metadata_group` tcm ON tcm.`concept_uuid` = eo.`obs_value_coded_uuid` ',
            'WHERE eo.`obs_group_id` IS NOT NULL ',
            'AND eo.`voided` = 0 ',
            IF(@enc_id <> 0, CONCAT('AND eo.`encounter_id` = ', @enc_id, ' '), ''),
            'GROUP BY eo.`encounter_id`, eo.`person_id`, eo.`encounter_datetime`, eo.`obs_group_id` ',
            'ON DUPLICATE KEY UPDATE ', @update_stmt
        );

PREPARE inserttbl FROM @insert_stmt;
EXECUTE inserttbl;
DEALLOCATE PREPARE inserttbl;
END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_encounter_obs_group_table_insert_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert_all;


~-~-
CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE obs_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT 0;

    DECLARE cursor_flat_tables CURSOR FOR
    SELECT DISTINCT(flat_table_name) FROM mamba_concept_metadata;

    DECLARE cursor_obs_group_tables CURSOR FOR
    SELECT DISTINCT(obs_group_concept_name) FROM mamba_obs_group;

    -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_flat_tables;

        REPEAT
            FETCH cursor_flat_tables INTO tbl_name;
                IF NOT done THEN
                    OPEN cursor_obs_group_tables;
                        block2: BEGIN
                            DECLARE doneobs_name INT DEFAULT 0;
                            DECLARE firstobs_name varchar(255) DEFAULT '';
                            DECLARE i int DEFAULT 1;
                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneobs_name = 1;

                            REPEAT
                                FETCH cursor_obs_group_tables INTO obs_name;

                                    IF i = 1 THEN
                                        SET firstobs_name = obs_name;
                                    END IF;

                                    CALL sp_mamba_flat_encounter_obs_group_table_insert(tbl_name,obs_name,NULL);
                                    SET i = i + 1;

                                UNTIL doneobs_name
                            END REPEAT;

                            CALL sp_mamba_flat_encounter_obs_group_table_insert(tbl_name,firstobs_name,NULL);
                        END block2;
                    CLOSE cursor_obs_group_tables;
            END IF;
                        UNTIL done
        END REPEAT;
    CLOSE cursor_flat_tables;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_multiselect_values_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `sp_mamba_multiselect_values_update`;


~-~-
CREATE PROCEDURE `sp_mamba_multiselect_values_update`(
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

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_load_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_load_agegroup;


~-~-
CREATE PROCEDURE sp_mamba_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO mamba_dim_agegroup(age, datim_agegroup, normal_agegroup)
            VALUES (age, fn_mamba_calculate_agegroup(age), IF(age < 15, '<15', '15+'));
            SET age = age + 1;
        END WHILE;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_write_automated_json_config  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_write_automated_json_config;


~-~-
CREATE PROCEDURE sp_mamba_write_automated_json_config()
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE jsonData JSON;
    DECLARE cur CURSOR FOR
        SELECT table_json_data FROM mamba_flat_table_config;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        SET @report_data = '{"flat_report_metadata":[';

        OPEN cur;
        FETCH cur INTO jsonData;

        IF NOT done THEN
                    SET @report_data = CONCAT(@report_data, jsonData);
        FETCH cur INTO jsonData; -- Fetch next record after the first one
        END IF;

                read_loop: LOOP
                    IF done THEN
                        LEAVE read_loop;
        END IF;

                    SET @report_data = CONCAT(@report_data, ',', jsonData);
        FETCH cur INTO jsonData;
        END LOOP;
        CLOSE cur;

        SET @report_data = CONCAT(@report_data, ']}');

        CALL sp_mamba_extract_report_metadata(@report_data, 'mamba_concept_metadata');

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_locale_insert_helper  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_locale_insert_helper;


~-~-
CREATE PROCEDURE sp_mamba_locale_insert_helper(
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4
)
BEGIN

    SET @conc_locale = concepts_locale;
    SET @insert_stmt = CONCAT('INSERT INTO mamba_dim_locale (locale) VALUES (''', @conc_locale, ''');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_extract_report_column_names  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_extract_report_column_names;


~-~-
CREATE PROCEDURE sp_mamba_extract_report_column_names()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE proc_name VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT DISTINCT report_columns_procedure_name FROM mamba_dim_report_definition;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO proc_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Fetch the parameters for the procedure and provide empty string values for each
        SET @params := NULL;

        SELECT GROUP_CONCAT('\'\'' SEPARATOR ', ')
        INTO @params
        FROM mamba_dim_report_definition_parameters rdp
                 INNER JOIN mamba_dim_report_definition rd on rdp.report_id = rd.report_id
        WHERE rd.report_columns_procedure_name = proc_name;

        IF @params IS NULL THEN
            SET @procedure_call = CONCAT('CALL ', proc_name, '();');
        ELSE
            SET @procedure_call = CONCAT('CALL ', proc_name, '(', @params, ');');
        END IF;

        PREPARE stmt FROM @procedure_call;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_extract_report_definition_metadata  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_extract_report_definition_metadata;


~-~-
CREATE PROCEDURE sp_mamba_extract_report_definition_metadata(
    IN report_definition_json JSON,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    IF report_definition_json IS NULL OR JSON_LENGTH(report_definition_json) = 0 THEN
        SIGNAL SQLSTATE '02000'
            SET MESSAGE_TEXT = 'Warn: report_definition_json is empty or null.';
    ELSE

        SET session group_concat_max_len = 20000;

        SELECT JSON_EXTRACT(report_definition_json, '$.report_definitions') INTO @report_array;
        SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

        SET @report_count = 0;
        WHILE @report_count < @report_array_len
            DO

                SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, '$.report_name')) INTO @report_name;
                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, '$.report_id')) INTO @report_id;

                SELECT CONCAT('sp_mamba_report_', @report_id, '_query') INTO @report_procedure_name;
                SELECT CONCAT('sp_mamba_report_', @report_id, '_columns_query') INTO @report_columns_procedure_name;
                SELECT CONCAT('sp_mamba_report_', @report_id, '_size_query') INTO @report_size_procedure_name;
                SELECT CONCAT('mamba_report_', @report_id) INTO @table_name;

                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, CONCAT('$.report_sql.sql_query'))) INTO @sql_query;
                SELECT JSON_EXTRACT(@report, CONCAT('$.report_sql.query_params')) INTO @query_params_array;
                SELECT JSON_EXTRACT(@report, CONCAT('$.report_sql.paginate')) INTO @paginate_flag;

                INSERT INTO mamba_dim_report_definition(report_id,
                                                        report_procedure_name,
                                                        report_columns_procedure_name,
                                                        report_size_procedure_name,
                                                        sql_query,
                                                        table_name,
                                                        report_name)
                VALUES (@report_id,
                        @report_procedure_name,
                        @report_columns_procedure_name,
                        @report_size_procedure_name,
                        @sql_query,
                        @table_name,
                        @report_name);

                -- Iterate over the "params" array for each report
                SELECT JSON_LENGTH(@query_params_array) INTO @total_params;

                SET @parameters := NULL;
                SET @param_count = 0;
                WHILE @param_count < @total_params
                    DO
                        SELECT JSON_EXTRACT(@query_params_array, CONCAT('$[', @param_count, ']')) INTO @param;
                        SELECT JSON_UNQUOTE(JSON_EXTRACT(@param, '$.name')) INTO @param_name;
                        SELECT JSON_UNQUOTE(JSON_EXTRACT(@param, '$.type')) INTO @param_type;
                        SET @param_position = @param_count + 1;

                        INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                           parameter_name,
                                                                           parameter_type,
                                                                           parameter_position)
                        VALUES (@report_id,
                                @param_name,
                                @param_type,
                                @param_position);

                        SET @param_count = @param_position;
                    END WHILE;

                -- Handle pagination parameters if paginate flag is true
                IF @paginate_flag = TRUE OR @paginate_flag = 'true' THEN
                    -- Add page_number parameter
                    SET @page_number_position = @total_params + 1;
                    INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                      parameter_name,
                                                                      parameter_type,
                                                                      parameter_position)
                    VALUES (@report_id,
                            'page_number',
                            'INT',
                            @page_number_position);
                            
                    -- Add page_size parameter
                    SET @page_size_position = @total_params + 2;
                    INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                      parameter_name,
                                                                      parameter_type,
                                                                      parameter_position)
                    VALUES (@report_id,
                            'page_size',
                            'INT',
                            @page_size_position);
                END IF;

                SET @report_count = @report_count + 1;
            END WHILE;

    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_generate_report_wrapper  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_generate_report_wrapper;


~-~-
CREATE PROCEDURE sp_mamba_generate_report_wrapper(IN generate_columns_flag TINYINT(1),
                                                  IN report_identifier VARCHAR(255),
                                                  IN parameter_list JSON)
BEGIN

    DECLARE proc_name VARCHAR(255);
    DECLARE sql_args VARCHAR(1000);
    DECLARE arg_name VARCHAR(50);
    DECLARE arg_value VARCHAR(255);
    DECLARE tester VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_parameter_names CURSOR FOR
        SELECT DISTINCT (p.parameter_name)
        FROM mamba_dim_report_definition_parameters p
        WHERE p.report_id = report_identifier;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    IF generate_columns_flag = 1 THEN
        SET proc_name = (SELECT DISTINCT (rd.report_columns_procedure_name)
                         FROM mamba_dim_report_definition rd
                         WHERE rd.report_id = report_identifier);
    ELSE
        SET proc_name = (SELECT DISTINCT (rd.report_procedure_name)
                         FROM mamba_dim_report_definition rd
                         WHERE rd.report_id = report_identifier);
    END IF;

    OPEN cursor_parameter_names;
    read_loop:
    LOOP
        FETCH cursor_parameter_names INTO arg_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SET arg_value = IFNULL((JSON_EXTRACT(parameter_list, CONCAT('$[', ((SELECT p.parameter_position
                                                                            FROM mamba_dim_report_definition_parameters p
                                                                            WHERE p.parameter_name = arg_name
                                                                              AND p.report_id = report_identifier) - 1),
                                                                    '].value'))), 'NULL');
        SET tester = CONCAT_WS(', ', tester, arg_value);
        SET sql_args = IFNULL(CONCAT_WS(', ', sql_args, arg_value), NULL);

    END LOOP;

    CLOSE cursor_parameter_names;

    SET @sql = CONCAT('CALL ', proc_name, '(', IFNULL(sql_args, ''), ')');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_generate_report_size_sp_wrapper  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_generate_report_size_sp_wrapper;


~-~-
CREATE PROCEDURE sp_mamba_generate_report_size_sp_wrapper(
    IN report_identifier VARCHAR(255),
    IN parameter_list JSON)
BEGIN

    DECLARE proc_name VARCHAR(255);
    DECLARE sql_args VARCHAR(1000);
    DECLARE arg_name VARCHAR(50);
    DECLARE arg_value VARCHAR(255);
    DECLARE tester VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_parameter_names CURSOR FOR
        SELECT DISTINCT (p.parameter_name)
        FROM mamba_dim_report_definition_parameters p
        WHERE p.report_id = report_identifier
        AND p.parameter_name NOT IN ('page_number', 'page_size');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET proc_name = (SELECT DISTINCT (rd.report_size_procedure_name)
                         FROM mamba_dim_report_definition rd
                         WHERE rd.report_id = report_identifier);

    OPEN cursor_parameter_names;
    read_loop:
    LOOP
        FETCH cursor_parameter_names INTO arg_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SET arg_value = IFNULL((JSON_EXTRACT(parameter_list, CONCAT('$[', ((SELECT p.parameter_position
                                                                            FROM mamba_dim_report_definition_parameters p
                                                                            WHERE p.parameter_name = arg_name
                                                                              AND p.report_id = report_identifier) - 1),
                                                                    '].value'))), 'NULL');
        SET tester = CONCAT_WS(', ', tester, arg_value);
        SET sql_args = IFNULL(CONCAT_WS(', ', sql_args, arg_value), NULL);

    END LOOP;

    CLOSE cursor_parameter_names;

    SET @sql = CONCAT('CALL ', proc_name, '(', IFNULL(sql_args, ''), ')');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_get_report_column_names  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_get_report_column_names;


~-~-
CREATE PROCEDURE sp_mamba_get_report_column_names(IN report_identifier VARCHAR(255))
BEGIN

    -- We could also pick the column names from the report definition table but it is in a comma-separated list (weigh both options)
    SELECT table_name
    INTO @table_name
    FROM mamba_dim_report_definition
    WHERE report_id = report_identifier;

    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @table_name;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_reset_incremental_update_flag  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Given a table name, this procedure will reset the incremental_record column to 0 for all rows where the incremental_record is 1.
-- This is useful when we want to re-run the incremental updates for a table.

DROP PROCEDURE IF EXISTS sp_mamba_reset_incremental_update_flag;


~-~-
CREATE PROCEDURE sp_mamba_reset_incremental_update_flag(
    IN table_name VARCHAR(60) CHARACTER SET UTF8MB4
)
BEGIN

    SET @tbl_name = table_name;

    SET @update_stmt =
            CONCAT('UPDATE ', @tbl_name, ' SET incremental_record = 0 WHERE incremental_record = 1');
    PREPARE updatetb FROM @update_stmt;
    EXECUTE updatetb;
    DEALLOCATE PREPARE updatetb;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_reset_incremental_update_flag_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_reset_incremental_update_flag_all;


~-~-
CREATE PROCEDURE sp_mamba_reset_incremental_update_flag_all()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_reset_incremental_update_flag_all', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_reset_incremental_update_flag_all', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Given a table name, this procedure will reset the incremental_record column to 0 for all rows where the incremental_record is 1.
-- This is useful when we want to re-run the incremental updates for a table.

CALL sp_mamba_reset_incremental_update_flag('mamba_dim_location');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_patient_identifier_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_datatype');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_name');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_answer');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_encounter_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_flat_table_config');
CALL sp_mamba_reset_incremental_update_flag('mamba_concept_metadata');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_encounter');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_name');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_attribute_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_attribute');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_address');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_users');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_relationship');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_patient_identifier');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_orders');
CALL sp_mamba_reset_incremental_update_flag('mamba_z_encounter_obs');

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_concept_metadata_create();
CALL sp_mamba_concept_metadata_insert();
CALL sp_mamba_concept_metadata_missing_columns_insert(); -- Update/insert table column metadata configs without table_columns json
CALL sp_mamba_concept_metadata_update();
CALL sp_mamba_concept_metadata_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_create;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_concept_metadata
(
    id                  INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    concept_id          INT          NULL,
    concept_uuid        CHAR(38)     NOT NULL,
    concept_name        VARCHAR(255) NULL,
    column_number       INT,
    column_label        VARCHAR(60)  NOT NULL,
    concept_datatype    VARCHAR(255) NULL,
    concept_answer_obs  TINYINT(1)   NOT NULL DEFAULT 0,
    report_name         VARCHAR(255) NOT NULL,
    flat_table_name     VARCHAR(60)  NULL,
    encounter_type_uuid CHAR(38)     NOT NULL,
    row_num             INT          NULL     DEFAULT 1,
    incremental_record  INT          NOT NULL DEFAULT 0,

    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_concept_uuid (concept_uuid),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_row_num (row_num),
    INDEX mamba_idx_concept_datatype (concept_datatype),
    INDEX mamba_idx_flat_table_name (flat_table_name),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_insert;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN


SET @is_incremental = 0;
-- SET @report_data = fn_mamba_generate_json_from_mamba_flat_table_config(@is_incremental);
CALL sp_mamba_concept_metadata_insert_helper(@is_incremental, 'mamba_concept_metadata');


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_insert_helper  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_insert_helper;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_insert_helper(
    IN is_incremental TINYINT(1),
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    DECLARE is_incremental_record TINYINT(1) DEFAULT 0;
    DECLARE report_json JSON;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        -- selects rows where incremental_record is 1. If is_incremental is not 1, it selects all rows.
        SELECT table_json_data
        FROM mamba_flat_table_config
        WHERE (IF(is_incremental = 1, incremental_record = 1, 1));

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET session group_concat_max_len = 20000;

    SELECT DISTINCT(table_partition_number)
    INTO @table_partition_number
    FROM _mamba_etl_user_settings;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO report_json;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT JSON_EXTRACT(report_json, '$.report_name') INTO @report_name;
        SELECT JSON_EXTRACT(report_json, '$.flat_table_name') INTO @flat_table_name;
        SELECT JSON_EXTRACT(report_json, '$.encounter_type_uuid') INTO @encounter_type;
        SELECT JSON_EXTRACT(report_json, '$.table_columns') INTO @column_array;

        SELECT JSON_KEYS(@column_array) INTO @column_keys_array;
        SELECT JSON_LENGTH(@column_keys_array) INTO @column_keys_array_len;

        -- if is_incremental = 1, delete records (if they exist) from mamba_concept_metadata table with encounter_type_uuid = @encounter_type
        IF is_incremental = 1 THEN

            SET is_incremental_record = 1;
            SET @delete_query = CONCAT('DELETE FROM mamba_concept_metadata WHERE encounter_type_uuid = ''',
                                       JSON_UNQUOTE(@encounter_type), '''');

            PREPARE stmt FROM @delete_query;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

        IF @column_keys_array_len = 0 THEN

            INSERT INTO mamba_concept_metadata
            (report_name,
             flat_table_name,
             encounter_type_uuid,
             column_label,
             concept_uuid,
             incremental_record)
            VALUES (JSON_UNQUOTE(@report_name),
                    JSON_UNQUOTE(@flat_table_name),
                    JSON_UNQUOTE(@encounter_type),
                    'AUTO-GENERATE',
                    'AUTO-GENERATE',
                    is_incremental_record);
        ELSE

            SET @col_count = 0;
            SET @table_name = JSON_UNQUOTE(@flat_table_name);


            WHILE @col_count < @column_keys_array_len
                DO
                    SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                    SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                    IF @col_count < @table_partition_number THEN
                        SET @table_name = @table_name;
                    ELSE
                        SET @table_name = CONCAT(LEFT(JSON_UNQUOTE(@flat_table_name), 57), '_', FLOOR((@col_count - @table_partition_number) / @table_partition_number)+1);
                    END IF;

                    INSERT INTO mamba_concept_metadata
                    (report_name,
                     flat_table_name,
                     encounter_type_uuid,
                     column_label,
                     concept_uuid,
                     incremental_record)
                    VALUES (JSON_UNQUOTE(@report_name),
                            JSON_UNQUOTE(@table_name),
                            JSON_UNQUOTE(@encounter_type),
                            JSON_UNQUOTE(@field_name),
                            JSON_UNQUOTE(@concept_uuid),
                            is_incremental_record);
                    SET @col_count = @col_count + 1;
                END WHILE;
        END IF;
    END LOOP;

    CLOSE cur;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_update;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = c.name
WHERE md.id > 0;

-- All Records' concept_answer_obs field is set to 0 by default
-- what will remain with (concept_answer_obs = 0) after the 2 updates
-- are Question concepts that have other values other than concepts as answers

-- First update: Get All records that are answer concepts (Answers to other question concepts)
-- concept_answer_obs = 1
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer answer
    ON md.concept_id = answer.answer_concept
SET md.concept_answer_obs = 1
WHERE NOT EXISTS (SELECT 1
                  FROM mamba_dim_concept_answer question
                  WHERE question.concept_id = answer.answer_concept);

-- Second update: Get All records that are Both a Question concept and an Answer concept
-- concept_answer_obs = 2
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer answer
    ON md.concept_id = answer.concept_id
SET md.concept_answer_obs = 2
WHERE EXISTS (SELECT 1
              FROM mamba_dim_concept_answer answer2
              WHERE answer2.answer_concept = answer.concept_id);

-- Update row number
SET @row_number = 0;
SET @prev_flat_table_name = NULL;
SET @prev_concept_id = NULL;

UPDATE mamba_concept_metadata md
    INNER JOIN (SELECT flat_table_name,
                       concept_id,
                       id,
                       @row_number := CASE
                                          WHEN @prev_flat_table_name = flat_table_name
                                              AND @prev_concept_id = concept_id
                                              THEN @row_number + 1
                                          ELSE 1
                           END AS num,
                       @prev_flat_table_name := flat_table_name,
                       @prev_concept_id := concept_id
                FROM mamba_concept_metadata
                ORDER BY flat_table_name, concept_id, id) m ON md.id = m.id
SET md.row_num = num
WHERE md.id > 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_cleanup()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_cleanup', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_cleanup', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- delete un wanted rows after inserting columns that were not given in the .json config file into the meta data table,
-- all rows with 'AUTO-GENERATE' are not used anymore. Delete them/1
DELETE
FROM mamba_concept_metadata
WHERE concept_uuid = 'AUTO-GENERATE'
  AND column_label = 'AUTO-GENERATE';

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_missing_columns_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_missing_columns_insert;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_missing_columns_insert()
BEGIN

    DECLARE encounter_type_uuid_value CHAR(38);
    DECLARE report_name_val VARCHAR(100);
    DECLARE encounter_type_id_val INT;
    DECLARE flat_table_name_val VARCHAR(255);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounters CURSOR FOR
        SELECT DISTINCT(encounter_type_uuid), m.report_name, m.flat_table_name, et.encounter_type_id
        FROM mamba_concept_metadata m
                 INNER JOIN mamba_dim_encounter_type et ON m.encounter_type_uuid = et.uuid
        WHERE et.retired = 0
          AND m.concept_uuid = 'AUTO-GENERATE'
          AND m.column_label = 'AUTO-GENERATE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_encounters;
    computations_loop:
    LOOP
        FETCH cursor_encounters
            INTO encounter_type_uuid_value, report_name_val, flat_table_name_val, encounter_type_id_val;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        SET @insert_stmt = CONCAT(
                'INSERT INTO mamba_concept_metadata
                (
                    report_name,
                    flat_table_name,
                    encounter_type_uuid,
                    column_label,
                    concept_uuid
                )
                SELECT
                    ''', report_name_val, ''',
                ''', flat_table_name_val, ''',
                ''', encounter_type_uuid_value, ''',
                field_name,
                concept_uuid,
                FROM (
                     SELECT
                          DISTINCT et.encounter_type_id,
                          c.auto_table_column_name AS field_name,
                          c.uuid AS concept_uuid
                     FROM mamba_source_db.obs o
                          INNER JOIN mamba_source_db.encounter e
                            ON e.encounter_id = o.encounter_id
                          INNER JOIN mamba_dim_encounter_type et
                            ON e.encounter_type = et.encounter_type_id
                          INNER JOIN mamba_dim_concept c
                            ON o.concept_id = c.concept_id
                     WHERE et.encounter_type_id = ''', encounter_type_id_val, '''
                       AND et.retired = 0
                ) mamba_missing_concept;
            ');

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;

    END LOOP computations_loop;
    CLOSE cursor_encounters;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_incremental;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_concept_metadata_incremental_insert();
CALL sp_mamba_concept_metadata_missing_columns_incremental_insert(); -- Update/insert table column metadata configs without table_columns json
CALL sp_mamba_concept_metadata_incremental_update();
CALL sp_mamba_concept_metadata_incremental_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN


SET @is_incremental = 1;
-- SET @report_data = fn_mamba_generate_json_from_mamba_flat_table_config(@is_incremental);
CALL sp_mamba_concept_metadata_insert_helper(@is_incremental, 'mamba_concept_metadata');


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = c.name
WHERE md.incremental_record = 1;

-- Update to True if this field is an obs answer to an obs Question
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer ca
    ON md.concept_id = ca.answer_concept
SET md.concept_answer_obs = 1
WHERE md.incremental_record = 1
  AND md.concept_id IN (SELECT DISTINCT ca.concept_id
                        FROM mamba_dim_concept_answer ca);

-- Update to for multiple selects/dropdowns/options this field is an obs answer to an obs Question
-- TODO: check this implementation here
UPDATE mamba_concept_metadata md
SET md.concept_answer_obs = 1
WHERE md.incremental_record = 1
  and concept_datatype = 'N/A';

-- Update row number
SET @row_number = 0;
SET @prev_flat_table_name = NULL;
SET @prev_concept_id = NULL;

UPDATE mamba_concept_metadata md
    INNER JOIN (SELECT flat_table_name,
                       concept_id,
                       id,
                       @row_number := CASE
                                          WHEN @prev_flat_table_name = flat_table_name
                                              AND @prev_concept_id = concept_id
                                              THEN @row_number + 1
                                          ELSE 1
                           END AS num,
                       @prev_flat_table_name := flat_table_name,
                       @prev_concept_id := concept_id
                FROM mamba_concept_metadata
                -- WHERE incremental_record = 1
                ORDER BY flat_table_name, concept_id, id) m ON md.id = m.id
SET md.row_num = num
WHERE md.incremental_record = 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_incremental_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_incremental_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_incremental_cleanup()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_concept_metadata_incremental_cleanup', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_concept_metadata_incremental_cleanup', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- delete un wanted rows after inserting columns that were not given in the .json config file into the meta data table,
-- all rows with 'AUTO-GENERATE' are not used anymore. Delete them/1
DELETE
FROM mamba_concept_metadata
WHERE incremental_record = 1
  AND concept_uuid = 'AUTO-GENERATE'
  AND column_label = 'AUTO-GENERATE';

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_concept_metadata_missing_columns_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_missing_columns_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_concept_metadata_missing_columns_incremental_insert()
BEGIN

    DECLARE encounter_type_uuid_value CHAR(38);
    DECLARE report_name_val VARCHAR(100);
    DECLARE encounter_type_id_val INT;
    DECLARE flat_table_name_val VARCHAR(255);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounters CURSOR FOR
        SELECT DISTINCT(encounter_type_uuid), m.report_name, m.flat_table_name, et.encounter_type_id
        FROM mamba_concept_metadata m
                 INNER JOIN mamba_dim_encounter_type et ON m.encounter_type_uuid = et.uuid
        WHERE et.retired = 0
          AND m.concept_uuid = 'AUTO-GENERATE'
          AND m.column_label = 'AUTO-GENERATE'
          AND m.incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_encounters;
    computations_loop:
    LOOP
        FETCH cursor_encounters
            INTO encounter_type_uuid_value, report_name_val, flat_table_name_val, encounter_type_id_val;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        SET @insert_stmt = CONCAT(
                'INSERT INTO mamba_concept_metadata
                (
                    report_name,
                    flat_table_name,
                    encounter_type_uuid,
                    column_label,
                    concept_uuid,
                    incremental_record
                )
                SELECT
                    ''', report_name_val, ''',
                ''', flat_table_name_val, ''',
                ''', encounter_type_uuid_value, ''',
                field_name,
                concept_uuid,
                1
                FROM (
                     SELECT
                          DISTINCT et.encounter_type_id,
                          c.auto_table_column_name AS field_name,
                          c.uuid AS concept_uuid
                     FROM mamba_source_db.obs o
                          INNER JOIN mamba_source_db.encounter e
                            ON e.encounter_id = o.encounter_id
                          INNER JOIN mamba_dim_encounter_type et
                            ON e.encounter_type = et.encounter_type_id
                          INNER JOIN mamba_dim_concept c
                            ON o.concept_id = c.concept_id
                     WHERE et.encounter_type_id = ''', encounter_type_id_val, '''
                       AND et.retired = 0
                ) mamba_missing_concept;
            ');

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;

    END LOOP computations_loop;
    CLOSE cursor_encounters;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_create;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_flat_table_config
(
    id                   INT           NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    encounter_type_id    INT           NOT NULL UNIQUE,
    report_name          VARCHAR(100)  NOT NULL,
    table_json_data      JSON          NOT NULL,
    table_json_data_hash CHAR(32)      NULL,
    encounter_type_uuid  CHAR(38)      NOT NULL,
    incremental_record   INT DEFAULT 0 NOT NULL COMMENT 'Whether `table_json_data` has been modified or not',

    INDEX mamba_idx_encounter_type_id (encounter_type_id),
    INDEX mamba_idx_report_name (report_name),
    INDEX mamba_idx_table_json_data_hash (table_json_data_hash),
    INDEX mamba_idx_uuid (encounter_type_uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_insert_helper_manual  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- manually extracts user given flat table config file json into the mamba_flat_table_config table
-- this data together with automatically extracted flat table data is inserted into the mamba_flat_table_config table
-- later it is processed by the 'fn_mamba_generate_report_array_from_automated_json_table' function
-- into the @report_data variable inside the compile-mysql.sh script

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_insert_helper_manual;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_insert_helper_manual(
    IN report_data JSON
)
BEGIN

    DECLARE report_count INT DEFAULT 0;
    DECLARE report_array_len INT;
    DECLARE report_enc_type_id INT DEFAULT NULL;
    DECLARE report_enc_type_uuid VARCHAR(50);
    DECLARE report_enc_name VARCHAR(500);

    SET session group_concat_max_len = 200000;

    SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
    SELECT JSON_LENGTH(@report_array) INTO report_array_len;

    WHILE report_count < report_array_len
        DO

            SELECT JSON_EXTRACT(@report_array, CONCAT('$[', report_count, ']')) INTO @report_data_item;
            SELECT JSON_EXTRACT(@report_data_item, '$.report_name') INTO report_enc_name;
            SELECT JSON_EXTRACT(@report_data_item, '$.encounter_type_uuid') INTO report_enc_type_uuid;

            SET report_enc_type_uuid = JSON_UNQUOTE(report_enc_type_uuid);

            SET report_enc_type_id = (SELECT DISTINCT et.encounter_type_id
                                      FROM mamba_dim_encounter_type et
                                      WHERE et.uuid = report_enc_type_uuid
                                      LIMIT 1);

            IF report_enc_type_id IS NOT NULL THEN
                INSERT INTO mamba_flat_table_config
                (report_name,
                 encounter_type_id,
                 table_json_data,
                 encounter_type_uuid)
                VALUES (JSON_UNQUOTE(report_enc_name),
                        report_enc_type_id,
                        @report_data_item,
                        report_enc_type_uuid);
            END IF;

            SET report_count = report_count + 1;

        END WHILE;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_insert_helper_auto  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_insert_helper_auto;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_insert_helper_auto()
main_block:
BEGIN

    DECLARE encounter_type_name CHAR(50) CHARACTER SET UTF8MB4;
    DECLARE is_automatic_flattening TINYINT(1);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounter_type_name CURSOR FOR
        SELECT DISTINCT et.name
        FROM mamba_source_db.obs o
                 INNER JOIN mamba_source_db.encounter e ON e.encounter_id = o.encounter_id
                 INNER JOIN mamba_dim_encounter_type et ON e.encounter_type = et.encounter_type_id
        WHERE et.encounter_type_id NOT IN (SELECT DISTINCT tc.encounter_type_id from mamba_flat_table_config tc)
          AND et.retired = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT DISTINCT(automatic_flattening_mode_switch)
    INTO is_automatic_flattening
    FROM _mamba_etl_user_settings;

    -- If auto-flattening is not switched on, do nothing
    IF is_automatic_flattening = 0 THEN
        LEAVE main_block;
    END IF;

    OPEN cursor_encounter_type_name;
    computations_loop:
    LOOP
        FETCH cursor_encounter_type_name INTO encounter_type_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        SET @insert_stmt = CONCAT(
                'INSERT INTO mamba_flat_table_config(report_name, encounter_type_id, table_json_data, encounter_type_uuid)
                    SELECT
                        name,
                        encounter_type_id,
                         CONCAT(''{'',
                            ''"report_name": "'', name, ''", '',
                            ''"flat_table_name": "'', table_name, ''", '',
                            ''"encounter_type_uuid": "'', uuid, ''", '',
                            ''"table_columns": '', json_obj, '' '',
                            ''}'') AS table_json_data,
                        encounter_type_uuid
                    FROM (
                        SELECT DISTINCT
                            et.name,
                            encounter_type_id,
                            et.auto_flat_table_name AS table_name,
                            et.uuid, ',
                '(
                SELECT DISTINCT CONCAT(''{'', GROUP_CONCAT(CONCAT(''"'', name, ''":"'', uuid, ''"'') SEPARATOR '','' ),''}'') x
                FROM (
                        SELECT
                            DISTINCT et.encounter_type_id,
                            c.auto_table_column_name AS name,
                            c.uuid
                        FROM mamba_source_db.obs o
                        INNER JOIN mamba_source_db.encounter e
                                  ON e.encounter_id = o.encounter_id
                        INNER JOIN mamba_dim_encounter_type et
                                  ON e.encounter_type = et.encounter_type_id
                        INNER JOIN mamba_dim_concept c
                                  ON o.concept_id = c.concept_id
                        WHERE et.name = ''', encounter_type_name, '''
                                    AND et.retired = 0
                                ) json_obj
                        ) json_obj,
                       et.uuid as encounter_type_uuid
                    FROM mamba_dim_encounter_type et
                    INNER JOIN mamba_source_db.encounter e
                        ON e.encounter_type = et.encounter_type_id
                    WHERE et.name = ''', encounter_type_name, '''
                ) X  ;   ');
        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END LOOP computations_loop;
    CLOSE cursor_encounter_type_name;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_insert;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN


SET @report_data = '{"flat_report_metadata":[{
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
    "indication_for_viral_load_testing": "59f36196-3ebe-4fea-be92-6fc9551c3a11",
    "htn_status": "c8f00db3-abb6-46a2-89a4-25acf95be863",
    "diabetes_mellitus_status": "126aecd6-c4de-4b1f-bfa2-8f68380f9329",
    "anxiety_and_or_depression": "6649a671-32ea-45b7-adc5-bda1cff7febd",
    "alcohol_and_substance_use_disorder": "10eb8116-0602-41e4-8e62-6325440dffb2",
    "oedema": "460AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "inr_no": "b644c29c-9bb0-447e-9f73-2ae89496a709",
    "pregnancy_status": "cd48b900-dd21-45ce-ae6b-b38ad2a3a695",
    "lnmp": "8ed491d6-6790-4035-b729-c33ed5cb3473",
    "anc_no.": "c7231d96-34d8-4bf7-a509-c810f75e3329",
    "digital_health_messaging_registration": "6908508b-70c0-4b21-92d4-4fffd9458dac",
    "cacx_screening_visit_type": "68096054-7cc0-4884-b5c8-c7ec5920fbc2",
    "cacx_screening_method": "bd0c20f2-39a5-4d82-ad69-742e7b67e447",
    "cacx_screening_status": "d3ac6593-b782-4ba9-9ff9-f320e59c6417",
    "cacx_treatment": "6f1baf4c-1cdd-44a5-a48e-909391ed05f2",
    "syphilis_status": "275a6f72-b8a4-4038-977a-727552f69cb8",
    "tb_regimen": "16fd7307-0b26-4c8b-afa3-8362baff4042",
    "other_tpt_status": "7913502b-68ff-4e2b-ad64-82cb3f12ee2b",
    "hpvVacStatus": "525c11be-f4d6-4373-b09a-3fc03390ec8c",
    "interruption_reason": "af0b99f2-4ef5-49a8-b208-e5585ba5538a",
    "other_reason_stopped_treatment": "a7465d9a-3a01-4bae-9f33-846b119fafd5",
    "hpv_vaccination_date": "164992AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "covidVaccStatus": "50032cf9-d5e6-4b8d-8d7d-32906d6a1115",
    "covid_vaccination_date": "1410AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "reasons_for_next_appointment": "160288AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "clinical_notes": "159395AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
    "gender_based_violance": "23a37400-f855-405b-9268-cb2d25b97f54",
    "ovc_no": "caffcc16-5a4d-4adc-a113-9a819c9b2c52",
    "patient_categorization": "cc183c11-0f94-4992-807c-84f33095ce37",
    "dsdm_models": "1e755463-df07-4f18-bc67-9e5527bc252f",
    "dsdm_approach": "73312fee-c321-11e8-a355-529269fb1459",
    "other_gmh_approach": "d42d2bab-f8a3-4bc4-8205-093d014b4215",
    "other_imc_approach": "99d7cd10-13bd-4ad1-9947-db2c720ba99a",
    "other_gmc_approach": "d0c7752d-edea-42df-a556-7bf5af44ffcf",
    "other_imf_approach": "503fdc10-293e-48cd-9380-408111d2dc5b",
    "linkages_and_referrals1": "325e4270-8b1f-447e-a591-b3daf13acea3",
    "arrange": "5105a11e-5300-4295-9a46-3a6832d2b3dc"
  }
},{
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
    "hivdr_results": "1c654215-fcc4-439f-a975-ced21995ed15",
    "emtct": "dcd7e8e5-30ab-102d-86b0-7a5022ba4115",
    "pregnant_status": "cd48b900-dd21-45ce-ae6b-b38ad2a3a695",
    "diagnosed_with_cryptococcal_meningitis": "1f7dfe47-26a8-480d-a3db-5571cd6af3b9",
    "treated_for_ccm": "bbf8b6ec-d0dc-4f8d-a597-b4547ee06d15",
    "histoplasmosis_screening": "29924e7f-39c0-493b-8f0a-cb8c08e7a924",
    "histoplasmosis_results": "aae2c3c1-5697-4ad0-9abb-99864a167d26",
    "aspergillosis_screening": "93e9b081-96df-4248-a13a-f138d29821b1",
    "other_clinical_decision": "163168AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "date_of_decision": "163167AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "outcome": "163170AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "other_outcome": "163171AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "comments": "163173AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
    "hiv_enrollment_date": "31c5c7aa-4948-473e-890b-67fe2fbbd71a",
    "relationship_to_index_clients": "bc61e60a-53ce-4767-8eed-29f3ec088829",
    "other_relationship_to_index_client": "632b3be3-626d-4cc0-b6a5-27aeb8155314"
  }
},{
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
    "name_of_location_transferred_to": "dce015bb-30ab-102d-86b0-7a5022ba4115",
    "serial_number": "1646AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "client_at_risk_of_acquiring_hiv": "fdd25ec0-5229-4f07-9afa-2a4c14107a53",
    "risk_profile": "69885d35-8861-4d16-a2c8-04ca380948ce",
    "do_you_consent_for_an_hiv_test": "a69e8d5b-4b44-4392-8a49-3eaf2abffe26",
    "consent_date": "dec56d39-01bd-474e-9021-be00f92161b8",
    "hiv_test_1_kit": "cbbc1d9a-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_1_kit_results": "cbbc1fb6-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_2_kit": "cbbc26fa-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_2_kit_results": "cbbc2394-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_3_kit": "5140ca0a-b2c0-11ed-afa1-0242ac120002",
    "hiv_test_3_kit_results": "cbbc2556-a7e2-11ed-afa1-0242ac120002",
    "sample_sent_to_reference_laboratory": "11316f54-0437-449c-b698-9e2dc48daa11",
    "client_screened_for_tb": "81fa73db-eb74-4e1b-b259-be76658cbb10",
    "art_no": "105ef9de-ad90-4c08-bcd5-ab48f74f6287",
    "received_prevention_services": "737dc257-643c-485a-974d-caf8b698e084",
    "test_name": "0cf86109-82ad-4fc0-9c23-40e04ba41594",
    "test_date": "164400AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
},{
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

CALL sp_mamba_flat_table_config_insert_helper_manual(@report_data); -- insert manually added config JSON data from config dir
CALL sp_mamba_flat_table_config_insert_helper_auto(); -- insert automatically generated config JSON data from db

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_update;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update the hash of the JSON data
UPDATE mamba_flat_table_config
SET table_json_data_hash = MD5(TRIM(table_json_data))
WHERE id > 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_flat_table_config_create();
CALL sp_mamba_flat_table_config_insert();
CALL sp_mamba_flat_table_config_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_create;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_incremental_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_incremental_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE IF NOT EXISTS mamba_flat_table_config_incremental
(
    id                   INT           NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    encounter_type_id    INT           NOT NULL UNIQUE,
    report_name          VARCHAR(100)  NOT NULL,
    table_json_data      JSON          NOT NULL,
    table_json_data_hash CHAR(32)      NULL,
    encounter_type_uuid  CHAR(38)      NOT NULL,
    incremental_record   INT DEFAULT 0 NOT NULL COMMENT 'Whether `table_json_data` has been modified or not',

    INDEX mamba_idx_encounter_type_id (encounter_type_id),
    INDEX mamba_idx_report_name (report_name),
    INDEX mamba_idx_table_json_data_hash (table_json_data_hash),
    INDEX mamba_idx_uuid (encounter_type_uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_insert_helper_manual  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- manually extracts user given flat table config file json into the mamba_flat_table_config_incremental table
-- this data together with automatically extracted flat table data is inserted into the mamba_flat_table_config_incremental table
-- later it is processed by the 'fn_mamba_generate_report_array_from_automated_json_table' function
-- into the @report_data variable inside the compile-mysql.sh script

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_insert_helper_manual;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_insert_helper_manual(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8MB4
)
BEGIN

    DECLARE report_count INT DEFAULT 0;
    DECLARE report_array_len INT;
    DECLARE report_enc_type_id INT DEFAULT NULL;
    DECLARE report_enc_type_uuid VARCHAR(50);
    DECLARE report_enc_name VARCHAR(500);

    SET session group_concat_max_len = 20000;

    SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
    SELECT JSON_LENGTH(@report_array) INTO report_array_len;

    WHILE report_count < report_array_len
        DO

            SELECT JSON_EXTRACT(@report_array, CONCAT('$[', report_count, ']')) INTO @report_data_item;
            SELECT JSON_EXTRACT(@report_data_item, '$.report_name') INTO report_enc_name;
            SELECT JSON_EXTRACT(@report_data_item, '$.encounter_type_uuid') INTO report_enc_type_uuid;

            SET report_enc_type_uuid = JSON_UNQUOTE(report_enc_type_uuid);

            SET report_enc_type_id = (SELECT DISTINCT et.encounter_type_id
                                      FROM mamba_dim_encounter_type et
                                      WHERE et.uuid = report_enc_type_uuid
                                      LIMIT 1);

            IF report_enc_type_id IS NOT NULL THEN
                INSERT INTO mamba_flat_table_config_incremental
                (report_name,
                 encounter_type_id,
                 table_json_data,
                 encounter_type_uuid)
                VALUES (JSON_UNQUOTE(report_enc_name),
                        report_enc_type_id,
                        @report_data_item,
                        report_enc_type_uuid);
            END IF;

            SET report_count = report_count + 1;

        END WHILE;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_insert_helper_auto  ----------------------------
-- ---------------------------------------------------------------------------------------------

-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_insert_helper_auto;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_insert_helper_auto()
main_block:
BEGIN

    DECLARE encounter_type_name CHAR(50) CHARACTER SET UTF8MB4;
    DECLARE is_automatic_flattening TINYINT(1);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounter_type_name CURSOR FOR
        SELECT DISTINCT et.name
        FROM mamba_source_db.obs o
                 INNER JOIN mamba_source_db.encounter e ON e.encounter_id = o.encounter_id
                 INNER JOIN mamba_dim_encounter_type et ON e.encounter_type = et.encounter_type_id
        WHERE et.encounter_type_id NOT IN (SELECT DISTINCT tc.encounter_type_id from mamba_flat_table_config_incremental tc)
          AND et.retired = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT DISTINCT(automatic_flattening_mode_switch)
    INTO is_automatic_flattening
    FROM _mamba_etl_user_settings;

    -- If auto-flattening is not switched on, do nothing
    IF is_automatic_flattening = 0 THEN
        LEAVE main_block;
    END IF;

    OPEN cursor_encounter_type_name;
    computations_loop:
    LOOP
        FETCH cursor_encounter_type_name INTO encounter_type_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        SET @insert_stmt = CONCAT(
                'INSERT INTO mamba_flat_table_config_incremental (report_name, encounter_type_id, table_json_data, encounter_type_uuid)
                    SELECT
                        name,
                        encounter_type_id,
                         CONCAT(''{'',
                            ''"report_name": "'', name, ''", '',
                            ''"flat_table_name": "'', table_name, ''", '',
                            ''"encounter_type_uuid": "'', uuid, ''", '',
                            ''"table_columns": '', json_obj, '' '',
                            ''}'') AS table_json_data,
                        encounter_type_uuid
                    FROM (
                        SELECT DISTINCT
                            et.name,
                            encounter_type_id,
                            et.auto_flat_table_name AS table_name,
                            et.uuid, ',
                '(
                SELECT DISTINCT CONCAT(''{'', GROUP_CONCAT(CONCAT(''"'', name, ''":"'', uuid, ''"'') SEPARATOR '','' ),''}'') x
                FROM (
                        SELECT
                            DISTINCT et.encounter_type_id,
                            c.auto_table_column_name AS name,
                            c.uuid
                        FROM mamba_source_db.obs o
                        INNER JOIN mamba_source_db.encounter e
                                  ON e.encounter_id = o.encounter_id
                        INNER JOIN mamba_dim_encounter_type et
                                  ON e.encounter_type = et.encounter_type_id
                        INNER JOIN mamba_dim_concept c
                                  ON o.concept_id = c.concept_id
                        WHERE et.name = ''', encounter_type_name, '''
                                    AND et.retired = 0
                                ) json_obj
                        ) json_obj,
                       et.uuid as encounter_type_uuid
                    FROM mamba_dim_encounter_type et
                    INNER JOIN mamba_source_db.encounter e
                        ON e.encounter_type = et.encounter_type_id
                    WHERE et.name = ''', encounter_type_name, '''
                ) X  ;   ');
        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END LOOP computations_loop;
    CLOSE cursor_encounter_type_name;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN


SET @report_data = '{"flat_report_metadata":[{
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
    "indication_for_viral_load_testing": "59f36196-3ebe-4fea-be92-6fc9551c3a11",
    "htn_status": "c8f00db3-abb6-46a2-89a4-25acf95be863",
    "diabetes_mellitus_status": "126aecd6-c4de-4b1f-bfa2-8f68380f9329",
    "anxiety_and_or_depression": "6649a671-32ea-45b7-adc5-bda1cff7febd",
    "alcohol_and_substance_use_disorder": "10eb8116-0602-41e4-8e62-6325440dffb2",
    "oedema": "460AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "inr_no": "b644c29c-9bb0-447e-9f73-2ae89496a709",
    "pregnancy_status": "cd48b900-dd21-45ce-ae6b-b38ad2a3a695",
    "lnmp": "8ed491d6-6790-4035-b729-c33ed5cb3473",
    "anc_no.": "c7231d96-34d8-4bf7-a509-c810f75e3329",
    "digital_health_messaging_registration": "6908508b-70c0-4b21-92d4-4fffd9458dac",
    "cacx_screening_visit_type": "68096054-7cc0-4884-b5c8-c7ec5920fbc2",
    "cacx_screening_method": "bd0c20f2-39a5-4d82-ad69-742e7b67e447",
    "cacx_screening_status": "d3ac6593-b782-4ba9-9ff9-f320e59c6417",
    "cacx_treatment": "6f1baf4c-1cdd-44a5-a48e-909391ed05f2",
    "syphilis_status": "275a6f72-b8a4-4038-977a-727552f69cb8",
    "tb_regimen": "16fd7307-0b26-4c8b-afa3-8362baff4042",
    "other_tpt_status": "7913502b-68ff-4e2b-ad64-82cb3f12ee2b",
    "hpvVacStatus": "525c11be-f4d6-4373-b09a-3fc03390ec8c",
    "interruption_reason": "af0b99f2-4ef5-49a8-b208-e5585ba5538a",
    "other_reason_stopped_treatment": "a7465d9a-3a01-4bae-9f33-846b119fafd5",
    "hpv_vaccination_date": "164992AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "covidVaccStatus": "50032cf9-d5e6-4b8d-8d7d-32906d6a1115",
    "covid_vaccination_date": "1410AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "reasons_for_next_appointment": "160288AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "clinical_notes": "159395AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
    "gender_based_violance": "23a37400-f855-405b-9268-cb2d25b97f54",
    "ovc_no": "caffcc16-5a4d-4adc-a113-9a819c9b2c52",
    "patient_categorization": "cc183c11-0f94-4992-807c-84f33095ce37",
    "dsdm_models": "1e755463-df07-4f18-bc67-9e5527bc252f",
    "dsdm_approach": "73312fee-c321-11e8-a355-529269fb1459",
    "other_gmh_approach": "d42d2bab-f8a3-4bc4-8205-093d014b4215",
    "other_imc_approach": "99d7cd10-13bd-4ad1-9947-db2c720ba99a",
    "other_gmc_approach": "d0c7752d-edea-42df-a556-7bf5af44ffcf",
    "other_imf_approach": "503fdc10-293e-48cd-9380-408111d2dc5b",
    "linkages_and_referrals1": "325e4270-8b1f-447e-a591-b3daf13acea3",
    "arrange": "5105a11e-5300-4295-9a46-3a6832d2b3dc"
  }
},{
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
    "hivdr_results": "1c654215-fcc4-439f-a975-ced21995ed15",
    "emtct": "dcd7e8e5-30ab-102d-86b0-7a5022ba4115",
    "pregnant_status": "cd48b900-dd21-45ce-ae6b-b38ad2a3a695",
    "diagnosed_with_cryptococcal_meningitis": "1f7dfe47-26a8-480d-a3db-5571cd6af3b9",
    "treated_for_ccm": "bbf8b6ec-d0dc-4f8d-a597-b4547ee06d15",
    "histoplasmosis_screening": "29924e7f-39c0-493b-8f0a-cb8c08e7a924",
    "histoplasmosis_results": "aae2c3c1-5697-4ad0-9abb-99864a167d26",
    "aspergillosis_screening": "93e9b081-96df-4248-a13a-f138d29821b1",
    "other_clinical_decision": "163168AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "date_of_decision": "163167AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "outcome": "163170AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "other_outcome": "163171AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "comments": "163173AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
    "hiv_enrollment_date": "31c5c7aa-4948-473e-890b-67fe2fbbd71a",
    "relationship_to_index_clients": "bc61e60a-53ce-4767-8eed-29f3ec088829",
    "other_relationship_to_index_client": "632b3be3-626d-4cc0-b6a5-27aeb8155314"
  }
},{
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
    "name_of_location_transferred_to": "dce015bb-30ab-102d-86b0-7a5022ba4115",
    "serial_number": "1646AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "client_at_risk_of_acquiring_hiv": "fdd25ec0-5229-4f07-9afa-2a4c14107a53",
    "risk_profile": "69885d35-8861-4d16-a2c8-04ca380948ce",
    "do_you_consent_for_an_hiv_test": "a69e8d5b-4b44-4392-8a49-3eaf2abffe26",
    "consent_date": "dec56d39-01bd-474e-9021-be00f92161b8",
    "hiv_test_1_kit": "cbbc1d9a-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_1_kit_results": "cbbc1fb6-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_2_kit": "cbbc26fa-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_2_kit_results": "cbbc2394-a7e2-11ed-afa1-0242ac120002",
    "hiv_test_3_kit": "5140ca0a-b2c0-11ed-afa1-0242ac120002",
    "hiv_test_3_kit_results": "cbbc2556-a7e2-11ed-afa1-0242ac120002",
    "sample_sent_to_reference_laboratory": "11316f54-0437-449c-b698-9e2dc48daa11",
    "client_screened_for_tb": "81fa73db-eb74-4e1b-b259-be76658cbb10",
    "art_no": "105ef9de-ad90-4c08-bcd5-ab48f74f6287",
    "received_prevention_services": "737dc257-643c-485a-974d-caf8b698e084",
    "test_name": "0cf86109-82ad-4fc0-9c23-40e04ba41594",
    "test_date": "164400AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  }
},{
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
},{
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

CALL sp_mamba_flat_table_config_incremental_insert_helper_manual(@report_data); -- insert manually added config JSON data from config dir
CALL sp_mamba_flat_table_config_incremental_insert_helper_auto(); -- insert automatically generated config JSON data from db

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update the hash of the JSON data
UPDATE mamba_flat_table_config_incremental
SET table_json_data_hash = MD5(TRIM(table_json_data))
WHERE id > 0;

-- If a new encounter type has been added
INSERT INTO mamba_flat_table_config (report_name,
                                     encounter_type_id,
                                     table_json_data,
                                     encounter_type_uuid,
                                     table_json_data_hash,
                                     incremental_record)
SELECT tci.report_name,
       tci.encounter_type_id,
       tci.table_json_data,
       tci.encounter_type_uuid,
       tci.table_json_data_hash,
       1
FROM mamba_flat_table_config_incremental tci
WHERE tci.encounter_type_id NOT IN (SELECT encounter_type_id FROM mamba_flat_table_config);

-- If there is any change in either concepts or encounter types in terms of names or additional questions
UPDATE mamba_flat_table_config tc
    INNER JOIN mamba_flat_table_config_incremental tci ON tc.encounter_type_id = tci.encounter_type_id
SET tc.table_json_data      = tci.table_json_data,
    tc.table_json_data_hash = tci.table_json_data_hash,
    tc.report_name          = tci.report_name,
    tc.encounter_type_uuid  = tci.encounter_type_uuid,
    tc.incremental_record   = 1
WHERE tc.table_json_data_hash <> tci.table_json_data_hash
  AND tc.table_json_data_hash IS NOT NULL;

-- If an encounter type has been voided then delete it from dim_json
DELETE
FROM mamba_flat_table_config
WHERE encounter_type_id NOT IN (SELECT tci.encounter_type_id FROM mamba_flat_table_config_incremental tci);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental_truncate  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental_truncate;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental_truncate()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_incremental_truncate', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_incremental_truncate', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_mamba_truncate_table('mamba_flat_table_config_incremental');
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_flat_table_config_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_incremental;


~-~-
CREATE PROCEDURE sp_mamba_flat_table_config_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_flat_table_config_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_flat_table_config_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_flat_table_config_incremental_create();
CALL sp_mamba_flat_table_config_incremental_truncate();
CALL sp_mamba_flat_table_config_incremental_insert();
CALL sp_mamba_flat_table_config_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group;


~-~-
CREATE PROCEDURE sp_mamba_obs_group()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_obs_group_create();
CALL sp_mamba_obs_group_insert();
CALL sp_mamba_obs_group_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_create;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_obs_group
(
    id                     INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    obs_id                 INT          NOT NULL,
    obs_group_concept_id   INT          NOT NULL,
    obs_group_concept_name VARCHAR(255) NOT NULL, -- should be the concept name of the obs
    obs_group_id           INT          NOT NULL,

    INDEX mamba_idx_obs_id (obs_id),
    INDEX mamba_idx_obs_group_concept_id (obs_group_concept_id),
    INDEX mamba_idx_obs_group_concept_name (obs_group_concept_name)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_insert;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_insert()
BEGIN
    DECLARE total_records INT;
    DECLARE batch_size INT DEFAULT 1000000; -- 1 million records per batch
    DECLARE mamba_offset INT DEFAULT 0;

    -- Calculate total records to process
SELECT COUNT(*)
INTO total_records
FROM mamba_source_db.obs o
         INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                     FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
WHERE o.encounter_id IS NOT NULL;

-- Loop through the batches of records
WHILE mamba_offset < total_records
    DO
        -- Create a temporary table to store obs group information
        CREATE TEMPORARY TABLE mamba_temp_obs_group_ids
        (
            obs_group_id INT NOT NULL,
            row_num      INT NOT NULL,
            INDEX mamba_idx_obs_group_id (obs_group_id),
            INDEX mamba_idx_row_num (row_num)
        )
        CHARSET = UTF8MB4;

        -- Insert into the temporary table based on obs group aggregation
        SET @sql_temp_insert = CONCAT('
            INSERT INTO mamba_temp_obs_group_ids
            SELECT obs_group_id, COUNT(*) AS row_num
            FROM mamba_z_encounter_obs o
            WHERE obs_group_id IS NOT NULL
            GROUP BY obs_group_id, person_id, encounter_id
            LIMIT ', batch_size, ' OFFSET ', mamba_offset);

PREPARE stmt_temp_insert FROM @sql_temp_insert;
EXECUTE stmt_temp_insert;
DEALLOCATE PREPARE stmt_temp_insert;

-- Insert into the final table from the temp table, including concept data
SET @sql_obs_group_insert = CONCAT('
            INSERT INTO mamba_obs_group (obs_group_concept_id, obs_group_concept_name, obs_id,obs_group_id)
            SELECT DISTINCT o.obs_question_concept_id,
                            LEFT(c.auto_table_column_name, 12) AS name,
                            o.obs_id,
                            o.obs_group_id
            FROM mamba_temp_obs_group_ids t
                     INNER JOIN mamba_z_encounter_obs o ON t.obs_group_id = o.obs_group_id
                     INNER JOIN mamba_dim_concept c ON o.obs_question_concept_id = c.concept_id
            WHERE t.row_num > 1
            LIMIT ', batch_size, ' OFFSET ', mamba_offset);

PREPARE stmt_obs_group_insert FROM @sql_obs_group_insert;
EXECUTE stmt_obs_group_insert;
DEALLOCATE PREPARE stmt_obs_group_insert;

-- Drop the temporary table after processing each batch
DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_group_ids;

        -- Increment the offset for the next batch
        SET mamba_offset = mamba_offset + batch_size;

END WHILE;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_update;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_error_log_drop  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_error_log_drop;


~-~-
CREATE PROCEDURE sp_mamba_etl_error_log_drop()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_error_log_drop', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_error_log_drop', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

DROP TABLE IF EXISTS _mamba_etl_error_log;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_error_log_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_error_log_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_error_log_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_error_log_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_error_log_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE _mamba_etl_error_log
(
    id             INT          NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary Key',
    procedure_name VARCHAR(255) NOT NULL,
    error_message  VARCHAR(1000),
    error_code     INT,
    sql_state      VARCHAR(5),
    error_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_error_log_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_error_log_insert;


~-~-
CREATE PROCEDURE sp_mamba_etl_error_log_insert(
    IN procedure_name VARCHAR(255),
    IN error_message VARCHAR(1000),
    IN error_code INT,
    IN sql_state VARCHAR(5)
)
BEGIN
    INSERT INTO _mamba_etl_error_log (procedure_name, error_message, error_code, sql_state)
    VALUES (procedure_name, error_message, error_code, sql_state);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_error_log  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_error_log;


~-~-
CREATE PROCEDURE sp_mamba_etl_error_log()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_error_log', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_error_log', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_error_log_drop();
CALL sp_mamba_etl_error_log_create();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_user_settings_drop  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings_drop;


~-~-
CREATE PROCEDURE sp_mamba_etl_user_settings_drop()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_user_settings_drop', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_user_settings_drop', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

DROP TABLE IF EXISTS _mamba_etl_user_settings;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_user_settings_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_user_settings_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_user_settings_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_user_settings_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE _mamba_etl_user_settings
(
    id                               INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Primary Key',
    openmrs_database                 VARCHAR(255) NOT NULL COMMENT 'Name of the OpenMRS (source) database',
    etl_database                     VARCHAR(255) NOT NULL COMMENT 'Name of the ETL (target) database',
    concepts_locale                  CHAR(4)      NOT NULL COMMENT 'Preferred Locale of the Concept names',
    table_partition_number           INT          NOT NULL COMMENT 'Number of columns at which to partition \'many columned\' Tables',
    incremental_mode_switch          TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not run in Incremental Mode',
    automatic_flattening_mode_switch TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not automatically flatten ALL encounter types',
    etl_interval_seconds             INT          NOT NULL COMMENT 'ETL Runs every 60 seconds',
    incremental_mode_switch_cascaded TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'This is a computed Incremental Mode (1 or 0) for the ETL that is cascaded down to the implementer scripts',
    last_etl_schedule_insert_id      INT          NOT NULL DEFAULT 1 COMMENT 'Insert ID of the last ETL that ran'

) CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_user_settings_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings_insert;


~-~-
CREATE PROCEDURE sp_mamba_etl_user_settings_insert(
    IN openmrs_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN etl_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT
)
BEGIN

    SET @insert_stmt = CONCAT(
            'INSERT INTO _mamba_etl_user_settings (`openmrs_database`, `etl_database`, `concepts_locale`, `table_partition_number`, `incremental_mode_switch`, `automatic_flattening_mode_switch`, `etl_interval_seconds`) VALUES (''',
            openmrs_database, ''', ''', etl_database, ''', ''', concepts_locale, ''', ', table_partition_number, ', ', incremental_mode_switch, ', ', automatic_flattening_mode_switch, ', ', etl_interval_seconds, ');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_user_settings  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings;


~-~-
CREATE PROCEDURE sp_mamba_etl_user_settings(
    IN openmrs_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN etl_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT
)
BEGIN

    -- DECLARE openmrs_db VARCHAR(256)  DEFAULT IFNULL(openmrs_database, 'openmrs');

    CALL sp_mamba_etl_user_settings_drop();
    CALL sp_mamba_etl_user_settings_create();
    CALL sp_mamba_etl_user_settings_insert(openmrs_database,
                                           etl_database,
                                           concepts_locale,
                                           table_partition_number,
                                           incremental_mode_switch,
                                           automatic_flattening_mode_switch,
                                           etl_interval_seconds);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_all_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_all_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_all_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- This table will be used to index the columns that are used to determine if a record is new, changed, retired or voided
-- It will be used to speed up the incremental updates for each incremental Table indentified in the ETL process

CREATE TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_all
(
    incremental_table_pkey INT        NOT NULL UNIQUE PRIMARY KEY,

    date_created           DATETIME   NOT NULL,
    date_changed           DATETIME   NULL,
    date_retired           DATETIME   NULL,
    date_voided            DATETIME   NULL,

    retired                TINYINT(1) NULL,
    voided                 TINYINT(1) NULL,

    INDEX mamba_idx_date_created (date_created),
    INDEX mamba_idx_date_changed (date_changed),
    INDEX mamba_idx_date_retired (date_retired),
    INDEX mamba_idx_date_voided (date_voided),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_voided (voided)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_all_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_insert;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_insert(
    IN openmrs_table VARCHAR(255)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE incremental_column_name VARCHAR(255);
    DECLARE column_list VARCHAR(500) DEFAULT 'incremental_table_pkey, ';
    DECLARE select_list VARCHAR(500) DEFAULT '';
    DECLARE pkey_column VARCHAR(255);

    DECLARE column_cursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'mamba_etl_incremental_columns_index_all';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Identify the primary key of the target table
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'mamba_source_db'
      AND TABLE_NAME = openmrs_table
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    -- Add the primary key to the select list
    SET select_list = CONCAT(select_list, pkey_column, ', ');

    OPEN column_cursor;

    column_loop:
    LOOP
        FETCH column_cursor INTO incremental_column_name;
        IF done THEN
            LEAVE column_loop;
        END IF;

        -- Check if the column exists in openmrs_table
        IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'mamba_source_db'
                     AND TABLE_NAME = openmrs_table
                     AND COLUMN_NAME = incremental_column_name) THEN
            SET column_list = CONCAT(column_list, incremental_column_name, ', ');
            SET select_list = CONCAT(select_list, incremental_column_name, ', ');
        END IF;
    END LOOP column_loop;

    CLOSE column_cursor;

    -- Remove the trailing comma and space
    SET column_list = LEFT(column_list, CHAR_LENGTH(column_list) - 2);
    SET select_list = LEFT(select_list, CHAR_LENGTH(select_list) - 2);

    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_all (', column_list, ') ',
            'SELECT ', select_list, ' FROM mamba_source_db.', openmrs_table
                      );

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_all_truncate  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_truncate;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_truncate()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_all_truncate', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_all_truncate', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

TRUNCATE TABLE mamba_etl_incremental_columns_index_all;
-- CALL sp_mamba_truncate_table('mamba_etl_incremental_columns_index_all');

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_all  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all(
    IN target_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_all_create();
    CALL sp_mamba_etl_incremental_columns_index_all_truncate();
    CALL sp_mamba_etl_incremental_columns_index_all_insert(target_table_name);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_new_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_new_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_new_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_new_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_new_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- This Table will only contain Primary keys for only those records that are NEW (i.e. Newly Inserted)

CREATE TEMPORARY TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_new
(
    incremental_table_pkey INT NOT NULL UNIQUE PRIMARY KEY
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_new_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_new_insert;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_new_insert(
    IN mamba_table_name VARCHAR(255)
)
BEGIN
    DECLARE incremental_start_time DATETIME;
    DECLARE pkey_column VARCHAR(255);

    -- Identify the primary key of the 'mamba_table_name'
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = mamba_table_name
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET incremental_start_time = (SELECT start_time
                                  FROM _mamba_etl_schedule sch
                                  WHERE end_time IS NOT NULL
                                    AND transaction_status = 'COMPLETED'
                                  ORDER BY id DESC
                                  LIMIT 1);

    -- Insert only records that are NOT in the mamba ETL table
    -- and were created after the last ETL run time (start_time)
    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_new (incremental_table_pkey) ',
            'SELECT DISTINCT incremental_table_pkey ',
            'FROM mamba_etl_incremental_columns_index_all ',
            'WHERE date_created >= ?',
            ' AND incremental_table_pkey NOT IN (SELECT DISTINCT (', pkey_column, ') FROM ', mamba_table_name, ')');

    PREPARE stmt FROM @insert_sql;
    SET @inc_start_time = incremental_start_time;
    EXECUTE stmt USING @inc_start_time;
    DEALLOCATE PREPARE stmt;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_new_truncate  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_new_truncate;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_new_truncate()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_new_truncate', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_new_truncate', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

TRUNCATE TABLE mamba_etl_incremental_columns_index_new;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_new  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_new;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_new(
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_new_create();
    CALL sp_mamba_etl_incremental_columns_index_new_truncate();
    CALL sp_mamba_etl_incremental_columns_index_new_insert(mamba_table_name);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_modified_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified_create;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_modified_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_modified_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- This Table will only contain Primary keys for only those records that have been modified/updated (i.e. Retired, Voided, Changed)

CREATE TEMPORARY TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_modified
(
    incremental_table_pkey INT NOT NULL UNIQUE PRIMARY KEY
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_modified_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified_insert;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified_insert(
    IN mamba_table_name VARCHAR(255)
)
BEGIN
    DECLARE incremental_start_time DATETIME;
    DECLARE pkey_column VARCHAR(255);

    -- Identify the primary key of the 'mamba_table_name'
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = mamba_table_name
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET incremental_start_time = (SELECT start_time
                                  FROM _mamba_etl_schedule sch
                                  WHERE end_time IS NOT NULL
                                    AND transaction_status = 'COMPLETED'
                                  ORDER BY id DESC
                                  LIMIT 1);

    -- Insert only records that are NOT in the mamba ETL table
    -- and were created after the last ETL run time (start_time)
    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_modified (incremental_table_pkey) ',
            'SELECT DISTINCT incremental_table_pkey ',
            'FROM mamba_etl_incremental_columns_index_all ',
            'WHERE date_changed >= ?',
            ' OR (voided = 1 AND date_voided >= ?)',
            ' OR (retired = 1 AND date_retired >= ?)');

    PREPARE stmt FROM @insert_sql;
    SET @incremental_start_time = incremental_start_time;
    EXECUTE stmt USING @incremental_start_time, @incremental_start_time, @incremental_start_time;
    DEALLOCATE PREPARE stmt;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_modified_truncate  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified_truncate;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified_truncate()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_etl_incremental_columns_index_modified_truncate', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_etl_incremental_columns_index_modified_truncate', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

TRUNCATE TABLE mamba_etl_incremental_columns_index_modified;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index_modified  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified(
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_modified_create();
    CALL sp_mamba_etl_incremental_columns_index_modified_truncate();
    CALL sp_mamba_etl_incremental_columns_index_modified_insert(mamba_table_name);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_etl_incremental_columns_index  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index;


~-~-
CREATE PROCEDURE sp_mamba_etl_incremental_columns_index(
    IN openmrs_table_name VARCHAR(255),
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_all(openmrs_table_name);
    CALL sp_mamba_etl_incremental_columns_index_new(mamba_table_name);
    CALL sp_mamba_etl_incremental_columns_index_modified(mamba_table_name);

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_table_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_table_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_table_insert(
    IN openmrs_table VARCHAR(255),
    IN mamba_table VARCHAR(255),
    IN is_incremental BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tbl_column_name VARCHAR(255);
    DECLARE column_list VARCHAR(500) DEFAULT '';
    DECLARE select_list VARCHAR(500) DEFAULT '';
    DECLARE pkey_column VARCHAR(255);
    DECLARE join_clause VARCHAR(500) DEFAULT '';

    DECLARE column_cursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = mamba_table;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Identify the primary key of the mamba_source_db table
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'mamba_source_db'
      AND TABLE_NAME = openmrs_table
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET column_list = CONCAT(column_list, 'incremental_record', ', ');
    IF is_incremental THEN
        SET select_list = CONCAT(select_list, 1, ', ');
    ELSE
        SET select_list = CONCAT(select_list, 0, ', ');
    END IF;

    OPEN column_cursor;

    column_loop:
    LOOP
        FETCH column_cursor INTO tbl_column_name;
        IF done THEN
            LEAVE column_loop;
        END IF;

        -- Check if the column exists in openmrs_table
        IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'mamba_source_db'
                     AND TABLE_NAME = openmrs_table
                     AND COLUMN_NAME = tbl_column_name) THEN
            SET column_list = CONCAT(column_list, tbl_column_name, ', ');
            SET select_list = CONCAT(select_list, tbl_column_name, ', ');
        END IF;
    END LOOP column_loop;

    CLOSE column_cursor;

    -- Remove the trailing comma and space
    SET column_list = LEFT(column_list, CHAR_LENGTH(column_list) - 2);
    SET select_list = LEFT(select_list, CHAR_LENGTH(select_list) - 2);

    -- Set the join clause if it is an incremental insert
    IF is_incremental THEN
        SET join_clause = CONCAT(
                ' INNER JOIN mamba_etl_incremental_columns_index_new ic',
                ' ON tb.', pkey_column, ' = ic.incremental_table_pkey');
    END IF;

    SET @insert_sql = CONCAT(
            'INSERT INTO ', mamba_table, ' (', column_list, ') ',
            'SELECT ', select_list,
            ' FROM mamba_source_db.', openmrs_table, ' tb',
            join_clause, ';');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_truncate_table  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_truncate_table;


~-~-
CREATE PROCEDURE sp_mamba_truncate_table(
    IN table_to_truncate VARCHAR(64) CHARACTER SET UTF8MB4
)
BEGIN
    IF EXISTS (SELECT 1
               FROM information_schema.tables
               WHERE table_schema = DATABASE()
                 AND table_name = table_to_truncate) THEN

        SET @sql = CONCAT('TRUNCATE TABLE ', table_to_truncate);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_drop_table  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_drop_table;


~-~-
CREATE PROCEDURE sp_mamba_drop_table(
    IN table_to_drop VARCHAR(64) CHARACTER SET UTF8MB4
)
BEGIN

    SET @sql = CONCAT('DROP TABLE IF EXISTS ', table_to_drop);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_location
(
    location_id        INT           NOT NULL UNIQUE PRIMARY KEY,
    name               VARCHAR(255)  NOT NULL,
    description        VARCHAR(255)  NULL,
    city_village       VARCHAR(255)  NULL,
    state_province     VARCHAR(255)  NULL,
    postal_code        VARCHAR(50)   NULL,
    country            VARCHAR(50)   NULL,
    latitude           VARCHAR(50)   NULL,
    longitude          VARCHAR(50)   NULL,
    county_district    VARCHAR(255)  NULL,
    address1           VARCHAR(255)  NULL,
    address2           VARCHAR(255)  NULL,
    address3           VARCHAR(255)  NULL,
    address4           VARCHAR(255)  NULL,
    address5           VARCHAR(255)  NULL,
    address6           VARCHAR(255)  NULL,
    address7           VARCHAR(255)  NULL,
    address8           VARCHAR(255)  NULL,
    address9           VARCHAR(255)  NULL,
    address10          VARCHAR(255)  NULL,
    address11          VARCHAR(255)  NULL,
    address12          VARCHAR(255)  NULL,
    address13          VARCHAR(255)  NULL,
    address14          VARCHAR(255)  NULL,
    address15          VARCHAR(255)  NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_retired       DATETIME      NULL,
    retired            TINYINT(1)    NULL,
    retire_reason      VARCHAR(255)  NULL,
    retired_by         INT           NULL,
    changed_by         INT           NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_name (name),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('location', 'mamba_dim_location', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location;


~-~-
CREATE PROCEDURE sp_mamba_dim_location()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_location_create();
CALL sp_mamba_dim_location_insert();
CALL sp_mamba_dim_location_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('location', 'mamba_dim_location');
CALL sp_mamba_dim_location_incremental_insert();
CALL sp_mamba_dim_location_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('location', 'mamba_dim_location', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_location_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_location_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_location_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_location_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_location_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_location mdl
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mdl.location_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.location l
    ON mdl.location_id = l.location_id
SET mdl.name               = l.name,
    mdl.description        = l.description,
    mdl.city_village       = l.city_village,
    mdl.state_province     = l.state_province,
    mdl.postal_code        = l.postal_code,
    mdl.country            = l.country,
    mdl.latitude           = l.latitude,
    mdl.longitude          = l.longitude,
    mdl.county_district    = l.county_district,
    mdl.address1           = l.address1,
    mdl.address2           = l.address2,
    mdl.address3           = l.address3,
    mdl.address4           = l.address4,
    mdl.address5           = l.address5,
    mdl.address6           = l.address6,
    mdl.address7           = l.address7,
    mdl.address8           = l.address8,
    mdl.address9           = l.address9,
    mdl.address10          = l.address10,
    mdl.address11          = l.address11,
    mdl.address12          = l.address12,
    mdl.address13          = l.address13,
    mdl.address14          = l.address14,
    mdl.address15          = l.address15,
    mdl.date_created       = l.date_created,
    mdl.changed_by         = l.changed_by,
    mdl.date_changed       = l.date_changed,
    mdl.retired            = l.retired,
    mdl.retired_by         = l.retired_by,
    mdl.date_retired       = l.date_retired,
    mdl.retire_reason      = l.retire_reason,
    mdl.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier_type
(
    patient_identifier_type_id INT           NOT NULL UNIQUE PRIMARY KEY,
    name                       VARCHAR(50)   NOT NULL,
    description                TEXT          NULL,
    uuid                       CHAR(38)      NOT NULL,
    date_created               DATETIME      NOT NULL,
    date_changed               DATETIME      NULL,
    date_retired               DATETIME      NULL,
    retired                    TINYINT(1)    NULL,
    retire_reason              VARCHAR(255)  NULL,
    retired_by                 INT           NULL,
    changed_by                 INT           NULL,
    incremental_record         INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_name (name),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('patient_identifier_type', 'mamba_dim_patient_identifier_type', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_patient_identifier_type_create();
CALL sp_mamba_dim_patient_identifier_type_insert();
CALL sp_mamba_dim_patient_identifier_type_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('patient_identifier_type', 'mamba_dim_patient_identifier_type');
CALL sp_mamba_dim_patient_identifier_type_incremental_insert();
CALL sp_mamba_dim_patient_identifier_type_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('patient_identifier_type', 'mamba_dim_patient_identifier_type', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_type_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_type_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_type_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_type_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_type_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_patient_identifier_type mdpit
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mdpit.patient_identifier_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.patient_identifier_type pit
    ON mdpit.patient_identifier_type_id = pit.patient_identifier_type_id
SET mdpit.name               = pit.name,
    mdpit.description        = pit.description,
    mdpit.uuid               = pit.uuid,
    mdpit.date_created       = pit.date_created,
    mdpit.date_changed       = pit.date_changed,
    mdpit.date_retired       = pit.date_retired,
    mdpit.retired            = pit.retired,
    mdpit.retire_reason      = pit.retire_reason,
    mdpit.retired_by         = pit.retired_by,
    mdpit.changed_by         = pit.changed_by,
    mdpit.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_concept_datatype
(
    concept_datatype_id INT           NOT NULL UNIQUE PRIMARY KEY,
    name                VARCHAR(255)  NOT NULL,
    hl7_abbreviation    VARCHAR(3)    NULL,
    description         VARCHAR(255)  NULL,
    date_created        DATETIME      NOT NULL,
    date_retired        DATETIME      NULL,
    retired             TINYINT(1)    NULL,
    retire_reason       VARCHAR(255)  NULL,
    retired_by          INT           NULL,
    incremental_record  INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_name (name),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('concept_datatype', 'mamba_dim_concept_datatype', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_concept_datatype_create();
CALL sp_mamba_dim_concept_datatype_insert();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('concept_datatype', 'mamba_dim_concept_datatype', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_concept_datatype mcd
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mcd.concept_datatype_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept_datatype cd
    ON mcd.concept_datatype_id = cd.concept_datatype_id
SET mcd.name               = cd.name,
    mcd.hl7_abbreviation   = cd.hl7_abbreviation,
    mcd.description        = cd.description,
    mcd.date_created       = cd.date_created,
    mcd.date_retired       = cd.date_retired,
    mcd.retired            = cd.retired,
    mcd.retired_by         = cd.retired_by,
    mcd.retire_reason      = cd.retire_reason,
    mcd.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_datatype_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_datatype_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_datatype_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_datatype_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_datatype_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_datatype', 'mamba_dim_concept_datatype');
CALL sp_mamba_dim_concept_datatype_incremental_insert();
CALL sp_mamba_dim_concept_datatype_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    concept_id             INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                   CHAR(38)      NOT NULL,
    datatype_id            INT           NOT NULL, -- make it a FK
    datatype               VARCHAR(100)  NULL,
    name                   VARCHAR(256)  NULL,
    auto_table_column_name VARCHAR(60)   NULL,
    date_created           DATETIME      NOT NULL,
    date_changed           DATETIME      NULL,
    date_retired           DATETIME      NULL,
    retired                TINYINT(1)    NULL,
    retire_reason          VARCHAR(255)  NULL,
    retired_by             INT           NULL,
    changed_by             INT           NULL,
    incremental_record     INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_datatype_id (datatype_id),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_date_created (date_created),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('concept', 'mamba_dim_concept', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.concept_id > 0;

CREATE TEMPORARY TABLE mamba_temp_computed_concept_name
(
    concept_id      INT          NOT NULL,
    computed_name   VARCHAR(255) NOT NULL,
    tbl_column_name VARCHAR(60)  NOT NULL,
    INDEX mamba_idx_concept_id (concept_id)
)
    CHARSET = UTF8MB4
SELECT c.concept_id,
       CASE
           WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = '' THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
           WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
           ELSE TRIM(cn.name)
           END     AS computed_name,
       TRIM(LOWER(
               LEFT(
                       REPLACE(
                               REPLACE(
                                       fn_mamba_remove_special_characters(
                                           -- First collapse multiple spaces into one
                                               fn_mamba_collapse_spaces(
                                                       TRIM(
                                                               CASE
                                                                   WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = ''
                                                                       THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
                                                                   WHEN c.retired = 1
                                                                       THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
                                                                   ELSE TRIM(cn.name)
                                                                   END
                                                       )
                                               )
                                       ),
                                       ' ', '_'), -- Replace single spaces with underscores
                               '__', '_'), -- Replace double underscores with a single underscore
                       60 -- Limit to 60 characters
               ))) AS tbl_column_name
FROM mamba_dim_concept c
         LEFT JOIN mamba_dim_concept_name cn ON c.concept_id = cn.concept_id;

UPDATE mamba_dim_concept c
    INNER JOIN mamba_temp_computed_concept_name tc
    ON c.concept_id = tc.concept_id
SET c.name                   = tc.computed_name,
    c.auto_table_column_name = IF(tc.tbl_column_name = '',
                                  CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id),
                                  tc.tbl_column_name)
WHERE c.concept_id > 0;

DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_table_column_name VARCHAR(60);
    DECLARE previous_auto_table_column_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT concept_id, auto_table_column_name
        FROM mamba_dim_concept
        ORDER BY auto_table_column_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_concept_temp
    (
        concept_id             INT,
        auto_table_column_name VARCHAR(60)
    )
        CHARSET = UTF8MB4;

    TRUNCATE TABLE mamba_dim_concept_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_table_column_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_table_column_name IS NULL THEN
            SET current_auto_table_column_name = '';
        END IF;

        IF current_auto_table_column_name = previous_auto_table_column_name THEN

            SET counter = counter + 1;
            SET current_auto_table_column_name = CONCAT(
                    IF(CHAR_LENGTH(previous_auto_table_column_name) <= 57,
                       previous_auto_table_column_name,
                       LEFT(previous_auto_table_column_name, CHAR_LENGTH(previous_auto_table_column_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_table_column_name = current_auto_table_column_name;
        END IF;

        INSERT INTO mamba_dim_concept_temp (concept_id, auto_table_column_name)
        VALUES (current_id, current_auto_table_column_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_concept c
        JOIN mamba_dim_concept_temp t
        ON c.concept_id = t.concept_id
    SET c.auto_table_column_name = t.auto_table_column_name
    WHERE c.concept_id > 0;

    DROP TEMPORARY TABLE IF EXISTS mamba_dim_concept_temp;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_concept_create();
CALL sp_mamba_dim_concept_insert();
CALL sp_mamba_dim_concept_update();
CALL sp_mamba_dim_concept_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('concept', 'mamba_dim_concept', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_concept tc
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON tc.concept_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept sc
    ON tc.concept_id = sc.concept_id
SET tc.uuid               = sc.uuid,
    tc.datatype_id        = sc.datatype_id,
    tc.date_created       = sc.date_created,
    tc.date_changed       = sc.date_changed,
    tc.date_retired       = sc.date_retired,
    tc.changed_by         = sc.changed_by,
    tc.retired            = sc.retired,
    tc.retired_by         = sc.retired_by,
    tc.retire_reason      = sc.retire_reason,
    tc.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.incremental_record = 1;

-- Update the concept name and table column name
CREATE TEMPORARY TABLE mamba_temp_computed_concept_name
(
    concept_id      INT          NOT NULL,
    computed_name   VARCHAR(255) NOT NULL,
    tbl_column_name VARCHAR(60)  NOT NULL,
    INDEX mamba_idx_concept_id (concept_id)
)CHARSET = UTF8MB4 AS
SELECT c.concept_id,
       CASE
           WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = '' THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
           WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
           ELSE TRIM(cn.name)
           END                                                         AS computed_name,
       TRIM(LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(
                                               CASE
                                                   WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = ''
                                                       THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
                                                   WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
                                                   ELSE TRIM(cn.name)
                                                   END
                                       ), ' ', '_'), '__', '_'), 60))) AS tbl_column_name
FROM mamba_dim_concept c
         LEFT JOIN mamba_dim_concept_name cn ON c.concept_id = cn.concept_id;

UPDATE mamba_dim_concept c
    INNER JOIN mamba_temp_computed_concept_name tc
    ON c.concept_id = tc.concept_id
SET c.name                   = tc.computed_name,
    c.auto_table_column_name = IF(tc.tbl_column_name = '',
                                  CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id),
                                  tc.tbl_column_name)
WHERE c.incremental_record = 1;

DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_incremental_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_incremental_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_incremental_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_table_column_name VARCHAR(60);
    DECLARE previous_auto_table_column_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT concept_id, auto_table_column_name
        FROM mamba_dim_concept
        WHERE incremental_record = 1
        ORDER BY auto_table_column_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_concept_temp
    (
        concept_id             INT,
        auto_table_column_name VARCHAR(60)

    ) CHARSET = UTF8MB4;

    TRUNCATE TABLE mamba_dim_concept_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_table_column_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_table_column_name IS NULL THEN
            SET current_auto_table_column_name = '';
        END IF;

        IF current_auto_table_column_name = previous_auto_table_column_name THEN

            SET counter = counter + 1;
            SET current_auto_table_column_name = CONCAT(
                    IF(CHAR_LENGTH(previous_auto_table_column_name) <= 57,
                       previous_auto_table_column_name,
                       LEFT(previous_auto_table_column_name, CHAR_LENGTH(previous_auto_table_column_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_table_column_name = current_auto_table_column_name;
        END IF;

        INSERT INTO mamba_dim_concept_temp (concept_id, auto_table_column_name)
        VALUES (current_id, current_auto_table_column_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_concept c
        JOIN mamba_dim_concept_temp t
        ON c.concept_id = t.concept_id
    SET c.auto_table_column_name = t.auto_table_column_name
    WHERE incremental_record = 1;

    DROP TEMPORARY TABLE mamba_dim_concept_temp;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept', 'mamba_dim_concept');
CALL sp_mamba_dim_concept_incremental_insert();
CALL sp_mamba_dim_concept_incremental_update();
CALL sp_mamba_dim_concept_incremental_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_concept_answer
(
    concept_answer_id  INT           NOT NULL UNIQUE PRIMARY KEY,
    concept_id         INT           NOT NULL,
    answer_concept     INT,
    answer_drug        INT,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_concept_answer (concept_answer_id),
    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('concept_answer', 'mamba_dim_concept_answer', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_concept_answer_create();
CALL sp_mamba_dim_concept_answer_insert();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new records
CALL sp_mamba_dim_table_insert('concept_answer', 'mamba_dim_concept_answer', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_answer_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_answer_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_answer_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_answer_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_answer_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_answer', 'mamba_dim_concept_answer');
CALL sp_mamba_dim_concept_answer_incremental_insert();
CALL sp_mamba_dim_concept_answer_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    concept_name_id    INT           NOT NULL UNIQUE PRIMARY KEY,
    concept_id         INT,
    name               VARCHAR(255)  NOT NULL,
    locale             VARCHAR(50)   NOT NULL,
    locale_preferred   TINYINT,
    concept_name_type  VARCHAR(255),
    voided             TINYINT,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_concept_name_type (concept_name_type),
    INDEX mamba_idx_locale (locale),
    INDEX mamba_idx_locale_preferred (locale_preferred),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    voided,
                                    concept_name_type,
                                    date_created,
                                    date_changed,
                                    changed_by,
                                    voided_by,
                                    date_voided,
                                    void_reason)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.voided,
       cn.concept_name_type,
       cn.date_created,
       cn.date_changed,
       cn.changed_by,
       cn.voided_by,
       cn.date_voided,
       cn.void_reason
FROM mamba_source_db.concept_name cn
WHERE cn.locale IN (SELECT DISTINCT(concepts_locale) FROM _mamba_etl_user_settings)
  AND IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED')
  AND cn.voided = 0;
-- Use locale preferred or Fully specified name

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_concept_name_create();
CALL sp_mamba_dim_concept_name_insert();
CALL sp_mamba_dim_concept_name_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    voided,
                                    concept_name_type,
                                    date_created,
                                    date_changed,
                                    changed_by,
                                    voided_by,
                                    date_voided,
                                    void_reason,
                                    incremental_record)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.voided,
       cn.concept_name_type,
       cn.date_created,
       cn.date_changed,
       cn.changed_by,
       cn.voided_by,
       cn.date_voided,
       cn.void_reason,
       1
FROM mamba_source_db.concept_name cn
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON cn.concept_name_id = ic.incremental_table_pkey
WHERE cn.locale IN (SELECT DISTINCT (concepts_locale) FROM _mamba_etl_user_settings)
  AND cn.locale_preferred = 1
  AND cn.voided = 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- Update only Modified Records
UPDATE mamba_dim_concept_name cn
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON cn.concept_name_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept_name cnm
    ON cn.concept_name_id = cnm.concept_name_id
SET cn.concept_id         = cnm.concept_id,
    cn.name               = cnm.name,
    cn.locale             = cnm.locale,
    cn.locale_preferred   = cnm.locale_preferred,
    cn.concept_name_type  = cnm.concept_name_type,
    cn.voided             = cnm.voided,
    cn.date_created       = cnm.date_created,
    cn.date_changed       = cnm.date_changed,
    cn.changed_by         = cnm.changed_by,
    cn.voided_by          = cnm.voided_by,
    cn.date_voided        = cnm.date_voided,
    cn.void_reason        = cnm.void_reason,
    cn.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_incremental_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_incremental_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_incremental_cleanup()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_incremental_cleanup', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_incremental_cleanup', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- Delete any concept names that have become voided or not locale_preferred or not our locale we set (so we are consistent with the original INSERT statement)
-- We only need to keep the non-voided, locale we set & locale_preferred concept names
-- This is because when concept names are modified, the old name is voided and a new name is created but both have a date_changed value of the same date (donno why)

DELETE
FROM mamba_dim_concept_name
WHERE voided <> 0
   OR locale_preferred <> 1
   OR locale NOT IN (SELECT DISTINCT(concepts_locale) FROM _mamba_etl_user_settings);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_concept_name_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_name_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_concept_name_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_concept_name_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_concept_name_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_name', 'mamba_dim_concept_name');
CALL sp_mamba_dim_concept_name_incremental_insert();
CALL sp_mamba_dim_concept_name_incremental_update();
CALL sp_mamba_dim_concept_name_incremental_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    encounter_type_id    INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                 CHAR(38)      NOT NULL,
    name                 VARCHAR(50)   NOT NULL,
    auto_flat_table_name VARCHAR(60)   NULL,
    description          TEXT          NULL,
    retired              TINYINT(1)    NULL,
    date_created         DATETIME      NULL,
    date_changed         DATETIME      NULL,
    changed_by           INT           NULL,
    date_retired         DATETIME      NULL,
    retired_by           INT           NULL,
    retire_reason        VARCHAR(255)  NULL,
    incremental_record   INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_name (name),
    INDEX mamba_idx_auto_flat_table_name (auto_flat_table_name),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('encounter_type', 'mamba_dim_encounter_type', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

UPDATE mamba_dim_encounter_type et
SET et.auto_flat_table_name = LOWER(LEFT(
        REPLACE(REPLACE(fn_mamba_remove_special_characters(CONCAT('mamba_flat_encounter_', et.name)), ' ', '_'), '__',
                '_'), 60))
WHERE et.encounter_type_id > 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_flat_table_name VARCHAR(60);
    DECLARE previous_auto_flat_table_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT encounter_type_id, auto_flat_table_name
        FROM mamba_dim_encounter_type
        ORDER BY auto_flat_table_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_encounter_type_temp
    (
        encounter_type_id    INT,
        auto_flat_table_name VARCHAR(60)
    )
        CHARSET = UTF8MB4;

    TRUNCATE TABLE mamba_dim_encounter_type_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_flat_table_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_flat_table_name IS NULL THEN
            SET current_auto_flat_table_name = '';
        END IF;

        IF current_auto_flat_table_name = previous_auto_flat_table_name THEN

            SET counter = counter + 1;
            SET current_auto_flat_table_name = CONCAT(
                    IF(CHAR_LENGTH(previous_auto_flat_table_name) <= 57,
                       previous_auto_flat_table_name,
                       LEFT(previous_auto_flat_table_name, CHAR_LENGTH(previous_auto_flat_table_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_flat_table_name = current_auto_flat_table_name;
        END IF;

        INSERT INTO mamba_dim_encounter_type_temp (encounter_type_id, auto_flat_table_name)
        VALUES (current_id, current_auto_flat_table_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_encounter_type c
        JOIN mamba_dim_encounter_type_temp t
        ON c.encounter_type_id = t.encounter_type_id
    SET c.auto_flat_table_name = t.auto_flat_table_name
    WHERE c.encounter_type_id > 0;

    DROP TEMPORARY TABLE mamba_dim_encounter_type_temp;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_encounter_type_create();
CALL sp_mamba_dim_encounter_type_insert();
CALL sp_mamba_dim_encounter_type_update();
CALL sp_mamba_dim_encounter_type_cleanup();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('encounter_type', 'mamba_dim_encounter_type', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Encounter types
UPDATE mamba_dim_encounter_type et
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON et.encounter_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.encounter_type ent
    ON et.encounter_type_id = ent.encounter_type_id
SET et.uuid               = ent.uuid,
    et.name               = ent.name,
    et.description        = ent.description,
    et.retired            = ent.retired,
    et.date_created       = ent.date_created,
    et.date_changed       = ent.date_changed,
    et.changed_by         = ent.changed_by,
    et.date_retired       = ent.date_retired,
    et.retired_by         = ent.retired_by,
    et.retire_reason      = ent.retire_reason,
    et.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

UPDATE mamba_dim_encounter_type et
SET et.auto_flat_table_name = LOWER(LEFT(
        REPLACE(REPLACE(fn_mamba_remove_special_characters(CONCAT('mamba_flat_encounter_', et.name)), ' ', '_'), '__',
                '_'), 60))
WHERE et.incremental_record = 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_incremental_cleanup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_incremental_cleanup;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_incremental_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_flat_table_name VARCHAR(60);
    DECLARE previous_auto_flat_table_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT encounter_type_id, auto_flat_table_name
        FROM mamba_dim_encounter_type
        WHERE incremental_record = 1
        ORDER BY auto_flat_table_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_encounter_type_temp
    (
        encounter_type_id    INT,
        auto_flat_table_name VARCHAR(60)
    )
        CHARSET = UTF8MB4;

    TRUNCATE TABLE mamba_dim_encounter_type_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_flat_table_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_flat_table_name IS NULL THEN
            SET current_auto_flat_table_name = '';
        END IF;

        IF current_auto_flat_table_name = previous_auto_flat_table_name THEN

            SET counter = counter + 1;
            SET current_auto_flat_table_name = CONCAT(
                    IF(CHAR_LENGTH(previous_auto_flat_table_name) <= 57,
                       previous_auto_flat_table_name,
                       LEFT(previous_auto_flat_table_name, CHAR_LENGTH(previous_auto_flat_table_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_flat_table_name = current_auto_flat_table_name;
        END IF;

        INSERT INTO mamba_dim_encounter_type_temp (encounter_type_id, auto_flat_table_name)
        VALUES (current_id, current_auto_flat_table_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_encounter_type et
        JOIN mamba_dim_encounter_type_temp t
        ON et.encounter_type_id = t.encounter_type_id
    SET et.auto_flat_table_name = t.auto_flat_table_name
    WHERE et.incremental_record = 1;

    DROP TEMPORARY TABLE mamba_dim_encounter_type_temp;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_type_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_type_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_type_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_type_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('encounter_type', 'mamba_dim_encounter_type');
CALL sp_mamba_dim_encounter_type_incremental_insert();
CALL sp_mamba_dim_encounter_type_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id        INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                CHAR(38)      NOT NULL,
    encounter_type      INT           NOT NULL,
    encounter_type_uuid CHAR(38)      NULL,
    patient_id          INT           NOT NULL,
    visit_id            INT           NULL,
    encounter_datetime  DATETIME      NOT NULL,
    date_created        DATETIME      NOT NULL,
    date_changed        DATETIME      NULL,
    changed_by          INT           NULL,
    date_voided         DATETIME      NULL,
    voided              TINYINT(1)    NOT NULL,
    voided_by           INT           NULL,
    void_reason         VARCHAR(255)  NULL,
    incremental_record  INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_encounter_type (encounter_type),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_visit_id (visit_id),
    INDEX mamba_idx_encounter_datetime (encounter_datetime),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

INSERT INTO mamba_dim_encounter (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 visit_id,
                                 encounter_datetime,
                                 date_created,
                                 date_changed,
                                 changed_by,
                                 date_voided,
                                 voided,
                                 voided_by,
                                 void_reason)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.visit_id,
       e.encounter_datetime,
       e.date_created,
       e.date_changed,
       e.changed_by,
       e.date_voided,
       e.voided,
       e.voided_by,
       e.void_reason
FROM mamba_source_db.encounter e
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id
WHERE et.uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_concept_metadata md);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_encounter_create();
CALL sp_mamba_dim_encounter_insert();
CALL sp_mamba_dim_encounter_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new records
INSERT INTO mamba_dim_encounter (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 visit_id,
                                 encounter_datetime,
                                 date_created,
                                 date_changed,
                                 changed_by,
                                 date_voided,
                                 voided,
                                 voided_by,
                                 void_reason,
                                 incremental_record)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.visit_id,
       e.encounter_datetime,
       e.date_created,
       e.date_changed,
       e.changed_by,
       e.date_voided,
       e.voided,
       e.voided_by,
       e.void_reason,
       1
FROM mamba_source_db.encounter e
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON e.encounter_id = ic.incremental_table_pkey
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Encounters
UPDATE mamba_dim_encounter e
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON e.encounter_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.encounter enc
    ON e.encounter_id = enc.encounter_id
    INNER JOIN mamba_dim_encounter_type et
    ON e.encounter_type = et.encounter_type_id
SET e.encounter_id        = enc.encounter_id,
    e.uuid                = enc.uuid,
    e.encounter_type      = enc.encounter_type,
    e.encounter_type_uuid = et.uuid,
    e.patient_id          = enc.patient_id,
    e.visit_id            = enc.visit_id,
    e.encounter_datetime  = enc.encounter_datetime,
    e.date_created        = enc.date_created,
    e.date_changed        = enc.date_changed,
    e.changed_by          = enc.changed_by,
    e.date_voided         = enc.date_voided,
    e.voided              = enc.voided,
    e.voided_by           = enc.voided_by,
    e.void_reason         = enc.void_reason,
    e.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_encounter_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_encounter_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_encounter_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_encounter_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('encounter', 'mamba_dim_encounter');
CALL sp_mamba_dim_encounter_incremental_insert();
CALL sp_mamba_dim_encounter_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_report_definition_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_report_definition_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_report_definition_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_report_definition_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_report_definition_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_report_definition
(
    id                            INT          NOT NULL AUTO_INCREMENT,
    report_id                     VARCHAR(255) NOT NULL UNIQUE,
    report_procedure_name         VARCHAR(255) NOT NULL UNIQUE, -- should be derived from report_id??
    report_columns_procedure_name VARCHAR(255) NOT NULL UNIQUE,
    report_size_procedure_name    VARCHAR(255) NULL UNIQUE,
    sql_query                     TEXT         NOT NULL,
    table_name                    VARCHAR(255) NOT NULL,        -- name of the table (will contain columns) of this query
    report_name                   VARCHAR(255) NULL,
    result_column_names           TEXT         NULL,            -- comma-separated column names

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_report_definition_report_id_index
    ON mamba_dim_report_definition (report_id);


CREATE TABLE mamba_dim_report_definition_parameters
(
    id                 INT          NOT NULL AUTO_INCREMENT,
    report_id          VARCHAR(255) NOT NULL,
    parameter_name     VARCHAR(255) NOT NULL,
    parameter_type     VARCHAR(30)  NOT NULL,
    parameter_position INT          NOT NULL, -- takes order or declaration in JSON file

    PRIMARY KEY (id),
    FOREIGN KEY (`report_id`) REFERENCES `mamba_dim_report_definition` (`report_id`)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_report_definition_parameter_position_index
    ON mamba_dim_report_definition_parameters (parameter_position);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_report_definition_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_report_definition_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_report_definition_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_report_definition_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_report_definition_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
SET @report_definition_json = '{
  "report_definitions": []
}';
CALL sp_mamba_extract_report_definition_metadata(@report_definition_json, 'mamba_dim_report_definition');
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_report_definition_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_report_definition_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_report_definition_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_report_definition_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_report_definition_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_report_definition  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_report_definition;


~-~-
CREATE PROCEDURE sp_mamba_dim_report_definition()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_report_definition', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_report_definition', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_report_definition_create();
CALL sp_mamba_dim_report_definition_insert();
CALL sp_mamba_dim_report_definition_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_person
(
    person_id           INT           NOT NULL UNIQUE PRIMARY KEY,
    birthdate           DATE          NULL,
    birthdate_estimated TINYINT(1)    NOT NULL,
    age                 INT           NULL,
    dead                TINYINT(1)    NOT NULL,
    death_date          DATETIME      NULL,
    deathdate_estimated TINYINT       NOT NULL,
    gender              VARCHAR(50)   NULL,
    person_name_short   VARCHAR(255)  NULL,
    person_name_long    TEXT          NULL,
    uuid                CHAR(38)      NOT NULL,
    date_created        DATETIME      NOT NULL,
    date_changed        DATETIME      NULL,
    changed_by          INT           NULL,
    date_voided         DATETIME      NULL,
    voided              TINYINT(1)    NOT NULL,
    voided_by           INT           NULL,
    void_reason         VARCHAR(255)  NULL,
    incremental_record  INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)

) CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person', 'mamba_dim_person', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

UPDATE mamba_dim_person psn
    INNER JOIN mamba_dim_person_name pn
    on psn.person_id = pn.person_id
SET age               = fn_mamba_age_calculator(psn.birthdate, psn.death_date),
    person_name_short = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name),
    person_name_long  = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix, pn.family_name,
                                  pn.family_name2,
                                  pn.family_name_suffix, pn.degree)
WHERE pn.preferred = 1
  AND pn.voided = 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person;


~-~-
CREATE PROCEDURE sp_mamba_dim_person()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_person_create();
CALL sp_mamba_dim_person_insert();
CALL sp_mamba_dim_person_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person', 'mamba_dim_person', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Persons
UPDATE mamba_dim_person p
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON p.person_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person psn
    ON p.person_id = psn.person_id
SET p.birthdate           = psn.birthdate,
    p.birthdate_estimated = psn.birthdate_estimated,
    p.dead                = psn.dead,
    p.death_date          = psn.death_date,
    p.deathdate_estimated = psn.deathdate_estimated,
    p.gender              = psn.gender,
    p.uuid                = psn.uuid,
    p.date_created        = psn.date_created,
    p.date_changed        = psn.date_changed,
    p.changed_by          = psn.changed_by,
    p.date_voided         = psn.date_voided,
    p.voided              = psn.voided,
    p.voided_by           = psn.voided_by,
    p.void_reason         = psn.void_reason,
    p.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

UPDATE mamba_dim_person psn
    INNER JOIN mamba_dim_person_name pn
    on psn.person_id = pn.person_id
SET age               = fn_mamba_age_calculator(psn.birthdate, psn.death_date),
    person_name_short = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name),
    person_name_long  = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix, pn.family_name,
                                  pn.family_name2,
                                  pn.family_name_suffix, pn.degree)
WHERE psn.incremental_record = 1
  AND pn.preferred = 1
  AND pn.voided = 0;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person', 'mamba_dim_person');
CALL sp_mamba_dim_person_incremental_insert();
CALL sp_mamba_dim_person_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_person_attribute
(
    person_attribute_id      INT           NOT NULL UNIQUE PRIMARY KEY,
    person_attribute_type_id INT           NOT NULL,
    person_id                INT           NOT NULL,
    uuid                     CHAR(38)      NOT NULL,
    value                    NVARCHAR(50)  NOT NULL,
    voided                   TINYINT,
    date_created             DATETIME      NOT NULL,
    date_changed             DATETIME      NULL,
    date_voided              DATETIME      NULL,
    changed_by               INT           NULL,
    voided_by                INT           NULL,
    void_reason              VARCHAR(255)  NULL,
    incremental_record       INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_person_attribute_type_id (person_attribute_type_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_attribute', 'mamba_dim_person_attribute', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_person_attribute_create();
CALL sp_mamba_dim_person_attribute_insert();
CALL sp_mamba_dim_person_attribute_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_attribute', 'mamba_dim_person_attribute', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Persons
UPDATE mamba_dim_person_attribute mpa
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpa.person_attribute_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_attribute pa
    ON mpa.person_attribute_id = pa.person_attribute_id
SET mpa.person_attribute_id = pa.person_attribute_id,
    mpa.person_id           = pa.person_id,
    mpa.uuid                = pa.uuid,
    mpa.value               = pa.value,
    mpa.date_created        = pa.date_created,
    mpa.date_changed        = pa.date_changed,
    mpa.date_voided         = pa.date_voided,
    mpa.changed_by          = pa.changed_by,
    mpa.voided              = pa.voided,
    mpa.voided_by           = pa.voided_by,
    mpa.void_reason         = pa.void_reason,
    mpa.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_attribute', 'mamba_dim_person_attribute');
CALL sp_mamba_dim_person_attribute_incremental_insert();
CALL sp_mamba_dim_person_attribute_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_person_attribute_type
(
    person_attribute_type_id INT           NOT NULL UNIQUE PRIMARY KEY,
    name                     NVARCHAR(50)  NOT NULL,
    description              TEXT          NULL,
    searchable               TINYINT(1)    NOT NULL,
    uuid                     NVARCHAR(50)  NOT NULL,
    date_created             DATETIME      NOT NULL,
    date_changed             DATETIME      NULL,
    date_retired             DATETIME      NULL,
    retired                  TINYINT(1)    NULL,
    retire_reason            VARCHAR(255)  NULL,
    retired_by               INT           NULL,
    changed_by               INT           NULL,
    incremental_record       INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_name (name),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_attribute_type', 'mamba_dim_person_attribute_type', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_person_attribute_type_create();
CALL sp_mamba_dim_person_attribute_type_insert();
CALL sp_mamba_dim_person_attribute_type_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('person_attribute_type', 'mamba_dim_person_attribute_type', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_person_attribute_type mpat
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpat.person_attribute_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_attribute_type pat
    ON mpat.person_attribute_type_id = pat.person_attribute_type_id
SET mpat.name               = pat.name,
    mpat.description        = pat.description,
    mpat.searchable         = pat.searchable,
    mpat.uuid               = pat.uuid,
    mpat.date_created       = pat.date_created,
    mpat.date_changed       = pat.date_changed,
    mpat.date_retired       = pat.date_retired,
    mpat.changed_by         = pat.changed_by,
    mpat.retired            = pat.retired,
    mpat.retired_by         = pat.retired_by,
    mpat.retire_reason      = pat.retire_reason,
    mpat.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_attribute_type_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_attribute_type_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_attribute_type_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_attribute_type_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_attribute_type_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_attribute_type', 'mamba_dim_person_attribute_type');
CALL sp_mamba_dim_person_attribute_type_incremental_insert();
CALL sp_mamba_dim_person_attribute_type_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier
(
    patient_identifier_id INT           NOT NULL UNIQUE PRIMARY KEY,
    patient_id            INT           NOT NULL,
    identifier            VARCHAR(50)   NOT NULL,
    identifier_type       INT           NOT NULL,
    preferred             TINYINT       NOT NULL,
    location_id           INT           NULL,
    patient_program_id    INT           NULL,
    uuid                  CHAR(38)      NOT NULL,
    date_created          DATETIME      NOT NULL,
    date_changed          DATETIME      NULL,
    date_voided           DATETIME      NULL,
    changed_by            INT           NULL,
    voided                TINYINT,
    voided_by             INT           NULL,
    void_reason           VARCHAR(255)  NULL,
    incremental_record    INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_identifier (identifier),
    INDEX mamba_idx_identifier_type (identifier_type),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('patient_identifier', 'mamba_dim_patient_identifier', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_patient_identifier_create();
CALL sp_mamba_dim_patient_identifier_insert();
CALL sp_mamba_dim_patient_identifier_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('patient_identifier', 'mamba_dim_patient_identifier', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_patient_identifier mpi
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpi.patient_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.patient_identifier pi
    ON mpi.patient_id = pi.patient_id
SET mpi.patient_id         = pi.patient_id,
    mpi.identifier         = pi.identifier,
    mpi.identifier_type    = pi.identifier_type,
    mpi.preferred          = pi.preferred,
    mpi.location_id        = pi.location_id,
    mpi.patient_program_id = pi.patient_program_id,
    mpi.uuid               = pi.uuid,
    mpi.voided             = pi.voided,
    mpi.date_created       = pi.date_created,
    mpi.date_changed       = pi.date_changed,
    mpi.date_voided        = pi.date_voided,
    mpi.changed_by         = pi.changed_by,
    mpi.voided_by          = pi.voided_by,
    mpi.void_reason        = pi.void_reason,
    mpi.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_patient_identifier_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_patient_identifier_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_patient_identifier_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_patient_identifier_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_patient_identifier_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('patient_identifier', 'mamba_dim_patient_identifier');
CALL sp_mamba_dim_patient_identifier_incremental_insert();
CALL sp_mamba_dim_patient_identifier_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_person_name
(
    person_name_id     INT           NOT NULL UNIQUE PRIMARY KEY,
    person_id          INT           NOT NULL,
    preferred          TINYINT       NOT NULL,
    prefix             VARCHAR(50)   NULL,
    given_name         VARCHAR(50)   NULL,
    middle_name        VARCHAR(50)   NULL,
    family_name_prefix VARCHAR(50)   NULL,
    family_name        VARCHAR(50)   NULL,
    family_name2       VARCHAR(50)   NULL,
    family_name_suffix VARCHAR(50)   NULL,
    degree             VARCHAR(50)   NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided             TINYINT(1)    NOT NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_name', 'mamba_dim_person_name', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_person_name_create();
CALL sp_mamba_dim_person_name_insert();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_name', 'mamba_dim_person_name', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Encounters
UPDATE mamba_dim_person_name dpn
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON dpn.person_name_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_name pn
    ON dpn.person_name_id = pn.person_name_id
SET dpn.person_name_id     = pn.person_name_id,
    dpn.person_id          = pn.person_id,
    dpn.preferred          = pn.preferred,
    dpn.prefix             = pn.prefix,
    dpn.given_name         = pn.given_name,
    dpn.middle_name        = pn.middle_name,
    dpn.family_name_prefix = pn.family_name_prefix,
    dpn.family_name        = pn.family_name,
    dpn.family_name2       = pn.family_name2,
    dpn.family_name_suffix = pn.family_name_suffix,
    dpn.degree             = pn.degree,
    dpn.date_created       = pn.date_created,
    dpn.date_changed       = pn.date_changed,
    dpn.changed_by         = pn.changed_by,
    dpn.date_voided        = pn.date_voided,
    dpn.voided             = pn.voided,
    dpn.voided_by          = pn.voided_by,
    dpn.void_reason        = pn.void_reason,
    dpn.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_name_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_name_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_name_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_name_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_name_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_name', 'mamba_dim_person_name');
CALL sp_mamba_dim_person_name_incremental_insert();
CALL sp_mamba_dim_person_name_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_person_address
(
    person_address_id  INT           NOT NULL UNIQUE PRIMARY KEY,
    person_id          INT           NULL,
    preferred          TINYINT       NOT NULL,
    address1           VARCHAR(255)  NULL,
    address2           VARCHAR(255)  NULL,
    address3           VARCHAR(255)  NULL,
    address4           VARCHAR(255)  NULL,
    address5           VARCHAR(255)  NULL,
    address6           VARCHAR(255)  NULL,
    address7           VARCHAR(255)  NULL,
    address8           VARCHAR(255)  NULL,
    address9           VARCHAR(255)  NULL,
    address10          VARCHAR(255)  NULL,
    address11          VARCHAR(255)  NULL,
    address12          VARCHAR(255)  NULL,
    address13          VARCHAR(255)  NULL,
    address14          VARCHAR(255)  NULL,
    address15          VARCHAR(255)  NULL,
    city_village       VARCHAR(255)  NULL,
    county_district    VARCHAR(255)  NULL,
    state_province     VARCHAR(255)  NULL,
    postal_code        VARCHAR(50)   NULL,
    country            VARCHAR(50)   NULL,
    latitude           VARCHAR(50)   NULL,
    longitude          VARCHAR(50)   NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided             TINYINT,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('person_address', 'mamba_dim_person_address', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_person_address_create();
CALL sp_mamba_dim_person_address_insert();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('person_address', 'mamba_dim_person_address', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_person_address mpa
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpa.person_address_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_address pa
    ON mpa.person_address_id = pa.person_address_id
SET mpa.person_id          = pa.person_id,
    mpa.preferred          = pa.preferred,
    mpa.address1           = pa.address1,
    mpa.address2           = pa.address2,
    mpa.address3           = pa.address3,
    mpa.address4           = pa.address4,
    mpa.address5           = pa.address5,
    mpa.address6           = pa.address6,
    mpa.address7           = pa.address7,
    mpa.address8           = pa.address8,
    mpa.address9           = pa.address9,
    mpa.address10          = pa.address10,
    mpa.address11          = pa.address11,
    mpa.address12          = pa.address12,
    mpa.address13          = pa.address13,
    mpa.address14          = pa.address14,
    mpa.address15          = pa.address15,
    mpa.city_village       = pa.city_village,
    mpa.county_district    = pa.county_district,
    mpa.state_province     = pa.state_province,
    mpa.postal_code        = pa.postal_code,
    mpa.country            = pa.country,
    mpa.latitude           = pa.latitude,
    mpa.longitude          = pa.longitude,
    mpa.date_created       = pa.date_created,
    mpa.date_changed       = pa.date_changed,
    mpa.date_voided        = pa.date_voided,
    mpa.changed_by         = pa.changed_by,
    mpa.voided             = pa.voided,
    mpa.voided_by          = pa.voided_by,
    mpa.void_reason        = pa.void_reason,
    mpa.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_person_address_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_person_address_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_person_address_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_person_address_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_person_address_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_address', 'mamba_dim_person_address');
CALL sp_mamba_dim_person_address_incremental_insert();
CALL sp_mamba_dim_person_address_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_dim_users
(
    user_id            INT           NOT NULL UNIQUE PRIMARY KEY,
    system_id          VARCHAR(50)   NOT NULL,
    username           VARCHAR(50)   NULL,
    creator            INT           NOT NULL,
    person_id          INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    email              VARCHAR(255)  NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_system_id (system_id),
    INDEX mamba_idx_username (username),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('users', 'mamba_dim_users', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user;


~-~-
CREATE PROCEDURE sp_mamba_dim_user()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
    CALL sp_mamba_dim_user_create();
    CALL sp_mamba_dim_user_insert();
    CALL sp_mamba_dim_user_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('users', 'mamba_dim_users', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Users
UPDATE mamba_dim_users u
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON u.user_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.users us
    ON u.user_id = us.user_id
SET u.system_id          = us.system_id,
    u.username           = us.username,
    u.creator            = us.creator,
    u.person_id          = us.person_id,
    u.uuid               = us.uuid,
    u.email              = us.email,
    u.retired            = us.retired,
    u.date_created       = us.date_created,
    u.date_changed       = us.date_changed,
    u.changed_by         = us.changed_by,
    u.date_retired       = us.date_retired,
    u.retired_by         = us.retired_by,
    u.retire_reason      = us.retire_reason,
    u.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_user_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_user_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_user_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_user_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_user_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_mamba_etl_incremental_columns_index('users', 'mamba_dim_users');
CALL sp_mamba_dim_user_incremental_insert();
CALL sp_mamba_dim_user_incremental_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_relationship
(
    relationship_id    INT           NOT NULL UNIQUE PRIMARY KEY,
    person_a           INT           NOT NULL,
    relationship       INT           NOT NULL,
    person_b           INT           NOT NULL,
    start_date         DATETIME      NULL,
    end_date           DATETIME      NULL,
    creator            INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_voided        DATETIME      NULL,
    voided             TINYINT(1)    NOT NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_a (person_a),
    INDEX mamba_idx_person_b (person_b),
    INDEX mamba_idx_relationship (relationship),
    INDEX mamba_idx_incremental_record (incremental_record)

) CHARSET = UTF8MB3;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('relationship', 'mamba_dim_relationship', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_relationship_create();
CALL sp_mamba_dim_relationship_insert();
CALL sp_mamba_dim_relationship_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('relationship', 'mamba_dim_relationship', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only modified records
UPDATE mamba_dim_relationship r
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON r.relationship_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.relationship rel
    ON r.relationship_id = rel.relationship_id
SET r.relationship       = rel.relationship,
    r.person_a           = rel.person_a,
    r.relationship       = rel.relationship,
    r.person_b           = rel.person_b,
    r.start_date         = rel.start_date,
    r.end_date           = rel.end_date,
    r.creator            = rel.creator,
    r.uuid               = rel.uuid,
    r.date_created       = rel.date_created,
    r.date_changed       = rel.date_changed,
    r.changed_by         = rel.changed_by,
    r.voided             = rel.voided,
    r.voided_by          = rel.voided_by,
    r.date_voided        = rel.date_voided,
    r.incremental_record = 1
WHERE im.incremental_table_pkey > 1;


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_relationship_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_relationship_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_relationship_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_relationship_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_relationship_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('relationship', 'mamba_dim_relationship');
CALL sp_mamba_dim_relationship_incremental_insert();
CALL sp_mamba_dim_relationship_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_dim_orders
(
    order_id               INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                   CHAR(38)      NOT NULL,
    order_type_id          INT           NOT NULL,
    concept_id             INT           NOT NULL,
    patient_id             INT           NOT NULL,
    encounter_id           INT           NOT NULL, -- links with encounter table
    accession_number       VARCHAR(255)  NULL,
    order_number           VARCHAR(50)   NOT NULL,
    orderer                INT           NOT NULL,
    instructions           TEXT          NULL,
    date_activated         DATETIME      NULL,
    auto_expire_date       DATETIME      NULL,
    date_stopped           DATETIME      NULL,
    order_reason           INT           NULL,
    order_reason_non_coded VARCHAR(255)  NULL,
    urgency                VARCHAR(50)   NOT NULL,
    previous_order_id      INT           NULL,
    order_action           VARCHAR(50)   NOT NULL,
    comment_to_fulfiller   VARCHAR(1024) NULL,
    care_setting           INT           NOT NULL,
    scheduled_date         DATETIME      NULL,
    order_group_id         INT           NULL,
    sort_weight            DOUBLE        NULL,
    fulfiller_comment      VARCHAR(1024) NULL,
    fulfiller_status       VARCHAR(50)   NULL,
    date_created           DATETIME      NOT NULL,
    creator                INT           NULL,
    voided                 TINYINT(1)    NOT NULL,
    voided_by              INT           NULL,
    date_voided            DATETIME      NULL,
    void_reason            VARCHAR(255)  NULL,
    incremental_record     INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_order_type_id (order_type_id),
    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('orders', 'mamba_dim_orders', FALSE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_orders_create();
CALL sp_mamba_dim_orders_insert();
CALL sp_mamba_dim_orders_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_table_insert('orders', 'mamba_dim_orders', TRUE);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Modified Encounters
UPDATE mamba_dim_orders do
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON do.order_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.orders o
    ON do.order_id = o.order_id
SET do.order_id               = o.order_id,
    do.uuid                   = o.uuid,
    do.order_type_id          = o.order_type_id,
    do.concept_id             = o.concept_id,
    do.patient_id             = o.patient_id,
    do.encounter_id           = o.encounter_id,
    do.accession_number       = o.accession_number,
    do.order_number           = o.order_number,
    do.orderer                = o.orderer,
    do.instructions           = o.instructions,
    do.date_activated         = o.date_activated,
    do.auto_expire_date       = o.auto_expire_date,
    do.date_stopped           = o.date_stopped,
    do.order_reason           = o.order_reason,
    do.order_reason_non_coded = o.order_reason_non_coded,
    do.urgency                = o.urgency,
    do.previous_order_id      = o.previous_order_id,
    do.order_action           = o.order_action,
    do.comment_to_fulfiller   = o.comment_to_fulfiller,
    do.care_setting           = o.care_setting,
    do.scheduled_date         = o.scheduled_date,
    do.order_group_id         = o.order_group_id,
    do.sort_weight            = o.sort_weight,
    do.fulfiller_comment      = o.fulfiller_comment,
    do.fulfiller_status       = o.fulfiller_status,
    do.date_created           = o.date_created,
    do.creator                = o.creator,
    do.voided                 = o.voided,
    do.voided_by              = o.voided_by,
    do.date_voided            = o.date_voided,
    do.void_reason            = o.void_reason,
    do.incremental_record     = 1
WHERE im.incremental_table_pkey > 1;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_orders_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_orders_incremental;


~-~-
CREATE PROCEDURE sp_mamba_dim_orders_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_orders_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_orders_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('orders', 'mamba_dim_orders');
CALL sp_mamba_dim_orders_incremental_insert();
CALL sp_mamba_dim_orders_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_agegroup_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_agegroup_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_agegroup_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_insert;


~-~-
CREATE PROCEDURE sp_mamba_dim_agegroup_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_agegroup_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_agegroup_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_mamba_load_agegroup();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_update;


~-~-
CREATE PROCEDURE sp_mamba_dim_agegroup_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_agegroup_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_agegroup_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup;


~-~-
CREATE PROCEDURE sp_mamba_dim_agegroup()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_agegroup', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_agegroup', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_dim_agegroup_create();
CALL sp_mamba_dim_agegroup_insert();
CALL sp_mamba_dim_agegroup_update();
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_create;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_z_encounter_obs_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_z_encounter_obs_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    obs_id                  INT           NOT NULL UNIQUE PRIMARY KEY,
    encounter_id            INT           NULL,
    visit_id                INT           NULL,
    person_id               INT           NOT NULL,
    order_id                INT           NULL,
    encounter_datetime      DATETIME      NOT NULL,
    obs_datetime            DATETIME      NOT NULL,
    location_id             INT           NULL,
    obs_group_id            INT           NULL,
    obs_question_concept_id INT DEFAULT 0 NOT NULL,
    obs_value_text          TEXT          NULL,
    obs_value_numeric       DOUBLE        NULL,
    obs_value_boolean       BOOLEAN       NULL,
    obs_value_coded         INT           NULL,
    obs_value_datetime      DATETIME      NULL,
    obs_value_complex       VARCHAR(1000) NULL,
    obs_value_drug          INT           NULL,
    obs_question_uuid       CHAR(38),
    obs_answer_uuid         CHAR(38),
    obs_value_coded_uuid    CHAR(38),
    encounter_type_uuid     CHAR(38),
    status                  VARCHAR(16)   NOT NULL,
    previous_version        INT           NULL,
    date_created            DATETIME      NOT NULL,
    date_voided             DATETIME      NULL,
    voided                  TINYINT(1)    NOT NULL,
    voided_by               INT           NULL,
    void_reason             VARCHAR(255)  NULL,
    incremental_record      INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_visit_id (visit_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_encounter_datetime (encounter_datetime),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_obs_question_concept_id (obs_question_concept_id),
    INDEX mamba_idx_obs_value_coded (obs_value_coded),
    INDEX mamba_idx_obs_value_coded_uuid (obs_value_coded_uuid),
    INDEX mamba_idx_obs_question_uuid (obs_question_uuid),
    INDEX mamba_idx_status (status),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_date_voided (date_voided),
    INDEX mamba_idx_order_id (order_id),
    INDEX mamba_idx_previous_version (previous_version),
    INDEX mamba_idx_obs_group_id (obs_group_id),
    INDEX mamba_idx_incremental_record (incremental_record),
    INDEX idx_encounter_person_datetime (encounter_id, person_id, encounter_datetime)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1m batch size
    DECLARE batch_last_obs_id INT DEFAULT 0;
    DECLARE last_obs_id INT;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_obs_data AS
    SELECT o.obs_id,
           o.encounter_id,
           e.visit_id,
           o.person_id,
           o.order_id,
           e.encounter_datetime,
           o.obs_datetime,
           o.location_id,
           o.obs_group_id,
           o.concept_id     AS obs_question_concept_id,
           o.value_text     AS obs_value_text,
           o.value_numeric  AS obs_value_numeric,
           o.value_coded    AS obs_value_coded,
           o.value_datetime AS obs_value_datetime,
           o.value_complex  AS obs_value_complex,
           o.value_drug     AS obs_value_drug,
           md.concept_uuid  AS obs_question_uuid,
           NULL             AS obs_answer_uuid,
           NULL             AS obs_value_coded_uuid,
           e.encounter_type_uuid,
           o.status,
           o.previous_version,
           o.date_created,
           o.date_voided,
           o.voided,
           o.voided_by,
           o.void_reason
    FROM mamba_source_db.obs o
             INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
             INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                         FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
    WHERE o.encounter_id IS NOT NULL;

    CREATE INDEX idx_obs_id ON mamba_temp_obs_data (obs_id);

    SELECT MAX(obs_id) INTO last_obs_id FROM mamba_temp_obs_data;

    WHILE batch_last_obs_id < last_obs_id
        DO
            INSERT INTO mamba_z_encounter_obs (obs_id,
                                               encounter_id,
                                               visit_id,
                                               person_id,
                                               order_id,
                                               encounter_datetime,
                                               obs_datetime,
                                               location_id,
                                               obs_group_id,
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
                                               encounter_type_uuid,
                                               status,
                                               previous_version,
                                               date_created,
                                               date_voided,
                                               voided,
                                               voided_by,
                                               void_reason)
            SELECT obs_id,
                   encounter_id,
                   visit_id,
                   person_id,
                   order_id,
                   encounter_datetime,
                   obs_datetime,
                   location_id,
                   obs_group_id,
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
                   encounter_type_uuid,
                   status,
                   previous_version,
                   date_created,
                   date_voided,
                   voided,
                   voided_by,
                   void_reason
            FROM mamba_temp_obs_data
            WHERE obs_id > batch_last_obs_id
            ORDER BY obs_id ASC
            LIMIT batch_size;

            SELECT MAX(obs_id)
            INTO batch_last_obs_id
            FROM mamba_z_encounter_obs
            LIMIT 1;

        END WHILE;

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_data;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE total_records INT;
    DECLARE batch_size INT DEFAULT 1000000; -- 1 million batches
    DECLARE mamba_offset INT DEFAULT 0;

    SELECT COUNT(*)
    INTO total_records
    FROM mamba_z_encounter_obs;
    CREATE
        TEMPORARY TABLE mamba_temp_value_coded_values
        CHARSET = UTF8MB4 AS
    SELECT m.concept_id AS concept_id,
           m.uuid       AS concept_uuid,
           m.name       AS concept_name
    FROM mamba_dim_concept m
    WHERE concept_id in (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);

    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    -- update obs_value_coded (UUIDs & Concept value names)
    WHILE mamba_offset < total_records
        DO
            UPDATE mamba_z_encounter_obs z
                JOIN (SELECT encounter_id
                      FROM mamba_z_encounter_obs
                      ORDER BY encounter_id
                      LIMIT batch_size OFFSET mamba_offset) AS filter
                ON filter.encounter_id = z.encounter_id
                INNER JOIN mamba_temp_value_coded_values mtv
                ON z.obs_value_coded = mtv.concept_id
            SET z.obs_value_text       = mtv.concept_name,
                z.obs_value_coded_uuid = mtv.concept_uuid
            WHERE z.obs_value_coded IS NOT NULL;

            SET mamba_offset = mamba_offset + batch_size;
        END WHILE;

    -- update column obs_value_boolean (Concept values)
    UPDATE mamba_z_encounter_obs z
    SET obs_value_boolean =
            CASE
                WHEN obs_value_text IN ('FALSE', 'No') THEN 0
                WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
                ELSE NULL
                END
    WHERE z.obs_value_coded IS NOT NULL
      AND obs_question_concept_id in
          (SELECT DISTINCT concept_id
           FROM mamba_dim_concept c
           WHERE c.datatype = 'Boolean');

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_z_encounter_obs', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_z_encounter_obs', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_z_encounter_obs_create();
CALL sp_mamba_z_encounter_obs_insert();
CALL sp_mamba_z_encounter_obs_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_incremental_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_incremental_insert;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_incremental_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_z_encounter_obs_incremental_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_z_encounter_obs_incremental_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Insert into mamba_z_encounter_obs
INSERT INTO mamba_z_encounter_obs (obs_id,
                                   encounter_id,
                                   visit_id,
                                   person_id,
                                   order_id,
                                   encounter_datetime,
                                   obs_datetime,
                                   location_id,
                                   obs_group_id,
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
                                   encounter_type_uuid,
                                   status,
                                   previous_version,
                                   date_created,
                                   date_voided,
                                   voided,
                                   voided_by,
                                   void_reason,
                                   incremental_record)
SELECT o.obs_id,
       o.encounter_id,
       e.visit_id,
       o.person_id,
       o.order_id,
       e.encounter_datetime,
       o.obs_datetime,
       o.location_id,
       o.obs_group_id,
       o.concept_id     AS obs_question_concept_id,
       o.value_text     AS obs_value_text,
       o.value_numeric  AS obs_value_numeric,
       o.value_coded    AS obs_value_coded,
       o.value_datetime AS obs_value_datetime,
       o.value_complex  AS obs_value_complex,
       o.value_drug     AS obs_value_drug,
       md.concept_uuid  AS obs_question_uuid,
       NULL             AS obs_answer_uuid,
       NULL             AS obs_value_coded_uuid,
       e.encounter_type_uuid,
       o.status,
       o.previous_version,
       o.date_created,
       o.date_voided,
       o.voided,
       o.voided_by,
       o.void_reason,
       1
FROM mamba_source_db.obs o
         INNER JOIN mamba_etl_incremental_columns_index_new ic ON o.obs_id = ic.incremental_table_pkey
         INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                     FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
WHERE o.encounter_id IS NOT NULL;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_incremental_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_incremental_update;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_incremental_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_z_encounter_obs_incremental_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_z_encounter_obs_incremental_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- Update only Modified Records

-- Update voided Obs (FINAL & AMENDED pair obs are incremental 1 though we shall not consider them in incremental flattening)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON z.obs_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.obs o
    ON z.obs_id = o.obs_id
SET z.encounter_id            = o.encounter_id,
    z.person_id               = o.person_id,
    z.order_id                = o.order_id,
    z.obs_datetime            = o.obs_datetime,
    z.location_id             = o.location_id,
    z.obs_group_id            = o.obs_group_id,
    z.obs_question_concept_id = o.concept_id,
    z.obs_value_text          = o.value_text,
    z.obs_value_numeric       = o.value_numeric,
    z.obs_value_coded         = o.value_coded,
    z.obs_value_datetime      = o.value_datetime,
    z.obs_value_complex       = o.value_complex,
    z.obs_value_drug          = o.value_drug,
    -- z.encounter_type_uuid     = o.encounter_type_uuid,
    z.status                  = o.status,
    z.previous_version        = o.previous_version,
    -- z.row_num            = o.row_num,
    z.date_created            = o.date_created,
    z.voided                  = o.voided,
    z.voided_by               = o.voided_by,
    z.date_voided             = o.date_voided,
    z.void_reason             = o.void_reason,
    z.incremental_record      = 1
WHERE im.incremental_table_pkey > 1;

-- update obs_value_coded (UUIDs & Concept value names) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.concept_id
SET z.obs_value_text       = c.name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.incremental_record = 1
  AND z.obs_value_coded IS NOT NULL;

-- update column obs_value_boolean (Concept values) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE', 'No') THEN 0
            WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
            ELSE NULL
            END
WHERE z.incremental_record = 1
  AND z.obs_value_coded IS NOT NULL
  AND obs_question_concept_id in
      (SELECT DISTINCT concept_id
       FROM mamba_dim_concept c
       WHERE c.datatype = 'Boolean');

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_incremental  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_incremental;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_incremental()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_z_encounter_obs_incremental', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_z_encounter_obs_incremental', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('obs', 'mamba_z_encounter_obs');
CALL sp_mamba_z_encounter_obs_incremental_insert();
CALL sp_mamba_z_encounter_obs_incremental_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_data_processing_drop_and_flatten  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_drop_and_flatten;


~-~-
CREATE PROCEDURE sp_mamba_data_processing_drop_and_flatten()

BEGIN

    CALL sp_mamba_system_drop_all_tables();

    CALL sp_mamba_dim_agegroup;

    CALL sp_mamba_dim_location;

    CALL sp_mamba_dim_patient_identifier_type;

    CALL sp_mamba_dim_concept_datatype;

    CALL sp_mamba_dim_concept_name;

    CALL sp_mamba_dim_concept;

    CALL sp_mamba_dim_concept_answer;

    CALL sp_mamba_dim_encounter_type;

    CALL sp_mamba_flat_table_config;

    CALL sp_mamba_concept_metadata;

    CALL sp_mamba_dim_report_definition;

    CALL sp_mamba_dim_encounter;

    CALL sp_mamba_dim_person_name;

    CALL sp_mamba_dim_person;

    CALL sp_mamba_dim_person_attribute_type;

    CALL sp_mamba_dim_person_attribute;

    CALL sp_mamba_dim_person_address;

    CALL sp_mamba_dim_user;

    CALL sp_mamba_dim_relationship;

    CALL sp_mamba_dim_patient_identifier;

    CALL sp_mamba_dim_orders;

    CALL sp_mamba_z_encounter_obs;

    CALL sp_mamba_obs_group;

    CALL sp_mamba_flat_encounter_table_create_all;

    CALL sp_mamba_flat_encounter_table_insert_all;

    CALL sp_mamba_flat_encounter_obs_group_table_create_all;

    CALL sp_mamba_flat_encounter_obs_group_table_insert_all;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_data_processing_increment_and_flatten  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_increment_and_flatten;


~-~-
CREATE PROCEDURE sp_mamba_data_processing_increment_and_flatten()

BEGIN

    CALL sp_mamba_dim_location_incremental;

    CALL sp_mamba_dim_patient_identifier_type_incremental;

    CALL sp_mamba_dim_concept_datatype_incremental;

    CALL sp_mamba_dim_concept_name_incremental;

    CALL sp_mamba_dim_concept_incremental;

    CALL sp_mamba_dim_concept_answer_incremental;

    CALL sp_mamba_dim_encounter_type_incremental;

    CALL sp_mamba_flat_table_config_incremental;

    CALL sp_mamba_concept_metadata_incremental;

    CALL sp_mamba_dim_encounter_incremental;

    CALL sp_mamba_dim_person_name_incremental;

    CALL sp_mamba_dim_person_incremental;

    CALL sp_mamba_dim_person_attribute_type_incremental;

    CALL sp_mamba_dim_person_attribute_incremental;

    CALL sp_mamba_dim_person_address_incremental;

    CALL sp_mamba_dim_user_incremental;

    CALL sp_mamba_dim_relationship_incremental;

    CALL sp_mamba_dim_patient_identifier_incremental;

    CALL sp_mamba_dim_orders_incremental;

    -- incremental inserts into the mamba_z_encounter_obs table only
    CALL sp_mamba_z_encounter_obs_incremental;

    CALL sp_mamba_flat_table_incremental_create_all;

    -- create and insert into flat tables whose columns or table names have been modified/added (determined by json_data hash)
    CALL sp_mamba_flat_table_incremental_insert_all;

    -- insert from mamba_z_encounter_obs into the flat table OBS that are either MODIFIED or CREATED/NEW
    -- (Deletes and inserts an entire Encounter (by id) if one of the obs is modified)
    CALL sp_mamba_flat_table_incremental_update_encounter;

    CALL sp_mamba_reset_incremental_update_flag_all;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_covid;


~-~-
CREATE PROCEDURE sp_data_processing_derived_covid()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_covid', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_covid', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_dim_client_covid;
CALL sp_fact_encounter_covid;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hiv_art()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hiv_art', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hiv_art', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art_card;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hiv_art_card()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hiv_art_card', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hiv_art_card', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art_card;
CALL sp_fact_encounter_hiv_art_summary;
CALL sp_fact_encounter_hiv_art_health_education;
CALL sp_fact_active_in_care;
CALL sp_fact_medication_orders;
CALL sp_fact_test_orders;
CALL sp_fact_test_orders_results;
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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_non_suppressed  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_non_suppressed;


~-~-
CREATE PROCEDURE sp_data_processing_derived_non_suppressed()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_non_suppressed', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_non_suppressed', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card;
CALL sp_fact_encounter_non_suppressed_obs_group;
CALL sp_fact_encounter_non_suppressed_repeat_vl;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_IIT  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_IIT;


~-~-
CREATE PROCEDURE sp_data_processing_derived_IIT()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_IIT', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_IIT', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;

CALL sp_fact_no_of_interruptions_in_treatment;
CALL sp_fact_patient_interruption_details;


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hts  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hts()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hts', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hts', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hts_card;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_z_encounter_obs_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;


~-~-
CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1m batch size
    DECLARE batch_last_obs_id INT DEFAULT 0;
    DECLARE last_obs_id INT;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_obs_data AS
    SELECT o.obs_id,
           o.encounter_id,
           e.visit_id,
           o.person_id,
           o.order_id,
           e.encounter_datetime,
           o.obs_datetime,
           o.location_id,
           o.obs_group_id,
           o.concept_id     AS obs_question_concept_id,
           o.value_text     AS obs_value_text,
           o.value_numeric  AS obs_value_numeric,
           o.value_coded    AS obs_value_coded,
           o.value_datetime AS obs_value_datetime,
           o.value_complex  AS obs_value_complex,
           o.value_drug     AS obs_value_drug,
           md.concept_uuid  AS obs_question_uuid,
           NULL             AS obs_answer_uuid,
           NULL             AS obs_value_coded_uuid,
           e.encounter_type_uuid,
           o.status,
           o.previous_version,
           o.date_created,
           o.date_voided,
           o.voided,
           o.voided_by,
           o.void_reason
    FROM mamba_source_db.obs o
             INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
             INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                         FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
    WHERE o.encounter_id IS NOT NULL and e.encounter_datetime >=DATE_SUB(CURRENT_DATE(), INTERVAL 8 YEAR);

    CREATE INDEX idx_obs_id ON mamba_temp_obs_data (obs_id);

    SELECT MAX(obs_id) INTO last_obs_id FROM mamba_temp_obs_data;

    WHILE batch_last_obs_id < last_obs_id
        DO
            INSERT INTO mamba_z_encounter_obs (obs_id,
                                               encounter_id,
                                               visit_id,
                                               person_id,
                                               order_id,
                                               encounter_datetime,
                                               obs_datetime,
                                               location_id,
                                               obs_group_id,
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
                                               encounter_type_uuid,
                                               status,
                                               previous_version,
                                               date_created,
                                               date_voided,
                                               voided,
                                               voided_by,
                                               void_reason)
            SELECT obs_id,
                   encounter_id,
                   visit_id,
                   person_id,
                   order_id,
                   encounter_datetime,
                   obs_datetime,
                   location_id,
                   obs_group_id,
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
                   encounter_type_uuid,
                   status,
                   previous_version,
                   date_created,
                   date_voided,
                   voided,
                   voided_by,
                   void_reason
            FROM mamba_temp_obs_data
            WHERE obs_id > batch_last_obs_id
            ORDER BY obs_id ASC
            LIMIT batch_size;

            SELECT MAX(obs_id)
            INTO batch_last_obs_id
            FROM mamba_z_encounter_obs
            LIMIT 1;

        END WHILE;

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_data;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group;


~-~-
CREATE PROCEDURE sp_mamba_obs_group()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_mamba_obs_group_create();
CALL sp_mamba_obs_group_insert();
CALL sp_mamba_obs_group_update();

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_create;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CREATE TABLE mamba_obs_group
(
    id                     INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    obs_id                 INT          NOT NULL,
    obs_group_concept_id   INT          NOT NULL,
    obs_group_concept_name VARCHAR(255) NOT NULL, -- should be the concept name of the obs

    INDEX mamba_idx_obs_id (obs_id),
    INDEX mamba_idx_obs_group_concept_id (obs_group_concept_id),
    INDEX mamba_idx_obs_group_concept_name (obs_group_concept_name)
)
    CHARSET = UTF8MB4;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_insert;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_obs_group_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_obs_group_update;


~-~-
CREATE PROCEDURE sp_mamba_obs_group_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_obs_group_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_obs_group_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_system_drop_fact_tables  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_system_drop_fact_tables;


-- CREATE PROCEDURE sp_mamba_system_drop_all_tables(IN database_name CHAR(255) CHARACTER SET UTF8MB4)
~-~-
CREATE PROCEDURE sp_mamba_system_drop_fact_tables()
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
                       AND TABLE_NAME REGEXP '^(mamba_fact_)');

        IF (@tbls IS NOT NULL) THEN

            SET @drop_tables = CONCAT('DROP TABLE IF EXISTS ', @tbls);

            SET foreign_key_checks = 0; -- Remove check, so we don't have to drop tables in the correct order, or care if they exist or not.
            PREPARE drop_tbls FROM @drop_tables;
            EXECUTE drop_tbls;
            DEALLOCATE PREPARE drop_tbls;
            SET foreign_key_checks = 1;

        END IF;

    END IF;

END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_data_processing_etl  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl;

~-~-
CREATE PROCEDURE sp_mamba_data_processing_etl(IN etl_incremental_mode INT)

BEGIN
    -- add base folder SP here if any --

    CALL sp_data_processing_derived_transfers();
    CALL sp_data_processing_derived_non_suppressed();
    CALL sp_data_processing_derived_hiv_art_card();
    CALL sp_data_processing_derived_IIT();
    CALL sp_data_processing_derived_hts();

END;
~-~-



    -- $END


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_create;


~-~-
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_no_of_interruptions_in_treatment_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_no_of_interruptions_in_treatment_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_insert;


~-~-
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_no_of_interruptions_in_treatment_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_no_of_interruptions_in_treatment_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment;


~-~-
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_no_of_interruptions_in_treatment', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_no_of_interruptions_in_treatment', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_no_of_interruptions_in_treatment_create();
CALL sp_fact_no_of_interruptions_in_treatment_insert();
CALL sp_fact_no_of_interruptions_in_treatment_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_query;
~-~-
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_no_of_interruptions;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_no_of_interruptions_in_treatment_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_no_of_interruptions_in_treatment_update;


~-~-
CREATE PROCEDURE sp_fact_no_of_interruptions_in_treatment_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_no_of_interruptions_in_treatment_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_no_of_interruptions_in_treatment_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details;


~-~-
CREATE PROCEDURE sp_fact_patient_interruption_details()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_patient_interruption_details', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_patient_interruption_details', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_patient_interruption_details_create();
CALL sp_fact_patient_interruption_details_insert();
CALL sp_fact_patient_interruption_details_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_create;


~-~-
CREATE PROCEDURE sp_fact_patient_interruption_details_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_patient_interruption_details_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_patient_interruption_details_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_insert;


~-~-
CREATE PROCEDURE sp_fact_patient_interruption_details_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_patient_interruption_details_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_patient_interruption_details_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patients_interruptions_details_query;
~-~-
CREATE PROCEDURE sp_fact_patients_interruptions_details_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_interruptions_details;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_patient_interruption_details_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_patient_interruption_details_update;


~-~-
CREATE PROCEDURE sp_fact_patient_interruption_details_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_patient_interruption_details_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_patient_interruption_details_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_IIT  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_IIT;


~-~-
CREATE PROCEDURE sp_data_processing_derived_IIT()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_IIT', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_IIT', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;

CALL sp_fact_no_of_interruptions_in_treatment;
CALL sp_fact_patient_interruption_details;


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_dim_agegroup_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_dim_agegroup_create;


~-~-
CREATE PROCEDURE sp_mamba_dim_agegroup_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_mamba_dim_agegroup_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_mamba_dim_agegroup_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    moh_2024_age_group VARCHAR(50) NULL,
    moh_2024_age_val   INT        NULL,
    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hiv_art_create();
CALL sp_fact_encounter_hiv_art_insert();
CALL sp_fact_encounter_hiv_art_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_query;
~-~-
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hiv_art()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hiv_art', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hiv_art', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_card_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_card_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_card_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    htn_status    VARCHAR(250) NULL,
    diabetes_mellitus_status       VARCHAR(250) NULL,
    anxiety_and_or_depression      VARCHAR(250) NULL,
    alcohol_and_substance_use_disorder         VARCHAR(250) NULL,
    oedema VARCHAR(250) NULL,
    inr_no  VARCHAR(50) NULL,
    pregnancy_status       VARCHAR(100) NULL,
    lnmp DATE NULL,
    anc_no VARCHAR(50) NULL,
    digital_health_messaging_registration VARCHAR(250) NULL,
    cacx_screening_visit_type         VARCHAR(250) NULL,
    cacx_screening_method             VARCHAR(250) NULL,
    cacx_screening_status             VARCHAR(250) NULL,
    cacx_treatment            VARCHAR(250) NULL,
    syphilis_status           VARCHAR(250) NULL,
    tb_regimen    VARCHAR(255) NULL,
    other_tpt_status       VARCHAR(255) NULL,
    hpvVacStatus   VARCHAR(255) NULL,
    interruption_reason VARCHAR(255) NULL,
    other_reason_stopped_treatment VARCHAR(255) NULL,
    hpv_vaccination_date  DATE NULL,
    covidVaccStatus  VARCHAR(255) NULL,
    covid_vaccination_date DATE NULL,
    reasons_for_next_appointment VARCHAR(255) NULL,
    clinical_notes TEXT,

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_card_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_card_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_card_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
                                               indication_for_viral_load_testing,
                                               htn_status    ,
                                               diabetes_mellitus_status,
                                               anxiety_and_or_depression,
                                               alcohol_and_substance_use_disorder,
                                               oedema ,
                                               inr_no,
                                               pregnancy_status,
                                               digital_health_messaging_registration ,
                                               cacx_screening_visit_type         ,
                                               cacx_screening_method,
                                               cacx_screening_status,
                                               cacx_treatment,
                                               syphilis_status,
                                               tb_regimen,
                                               other_tpt_status,
                                               hpvVacStatus,
                                               interruption_reason,
                                               hpv_vaccination_date,
                                               covidVaccStatus,
                                               covid_vaccination_date,
                                               reasons_for_next_appointment,
                                               clinical_notes )
SELECT a.encounter_id,
       a.client_id,
       a.encounter_datetime,
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
       indication_for_viral_load_testing,
       htn_status    ,
       diabetes_mellitus_status,
       anxiety_and_or_depression,
       alcohol_and_substance_use_disorder,
       oedema ,
       inr_no,
       pregnancy_status,
       digital_health_messaging_registration ,
       cacx_screening_visit_type         ,
       cacx_screening_method,
       cacx_screening_status,
       cacx_treatment,
       syphilis_status,
       tb_regimen,
       other_tpt_status,
       hpvVacStatus,
       interruption_reason,
       hpv_vaccination_date,
       covidVaccStatus,
       covid_vaccination_date,
       reasons_for_next_appointment,
       clinical_notes
FROM mamba_flat_encounter_art_card a inner join mamba_flat_encounter_art_card_1 b on a.encounter_id=b.encounter_id ;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_card_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_card_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_card_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_card()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_card', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_card', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hiv_art_card_create();
CALL sp_fact_encounter_hiv_art_card_insert();
CALL sp_fact_encounter_hiv_art_card_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_card_query;
~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_card_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_card hiv_card WHERE hiv_card.encounter_date >= START_DATE
      AND hiv_card.encounter_date <= END_DATE ;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_summary_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_summary_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    relationship_to_index_clients             VARCHAR(255) NULL,
    other_relationship_to_index_client        VARCHAR(255) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_client_id_index ON mamba_fact_encounter_hiv_art_summary (client_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_encounter_id_index ON mamba_fact_encounter_hiv_art_summary (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hiv_art_summary_encounter_date_index ON mamba_fact_encounter_hiv_art_summary (encounter_datetime);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_summary_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_summary_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
                                                  hiv_enrollment_date,
                                                  relationship_to_index_clients,
                                                  other_relationship_to_index_client)
SELECT a.encounter_id,
       a.client_id,
       a.encounter_datetime,
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
       hiv_enrollment_date,
       relationship_to_index_clients,
       other_relationship_to_index_client
FROM mamba_flat_encounter_art_summary_card a left join mamba_flat_encounter_art_summary_card_1 b on a.encounter_id = b.encounter_id ;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_summary_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_summary_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_summary', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_summary', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hiv_art_summary_create();
CALL sp_fact_encounter_hiv_art_summary_insert();
CALL sp_fact_encounter_hiv_art_summary_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_summary_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_summary_query;
~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_summary_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_summary hiv_sum WHERE hiv_sum.encounter_date >= START_DATE
      AND hiv_sum.encounter_date <= END_DATE ;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_health_education_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_health_education_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    ovc_no         VARCHAR(100)  DEFAULT NULL,
    patient_categorization VARCHAR(255)  DEFAULT NULL,
    dsdm_models       VARCHAR(255)  DEFAULT NULL,
    dsdm_approach     VARCHAR(255)  DEFAULT NULL,
    other_gmh_approach    VARCHAR(255)  DEFAULT NULL,
    other_imc_approach    VARCHAR(255)  DEFAULT NULL,
    other_gmc_approach    VARCHAR(255)  DEFAULT NULL,
    other_imf_approach    VARCHAR(255)  DEFAULT NULL,
    linkages_and_referrals1    VARCHAR(255)  DEFAULT NULL,
    arrange   VARCHAR(255)  DEFAULT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;


CREATE INDEX
    mamba_fact_encounter_hiv_art_health_education_client_id_index ON mamba_fact_encounter_hiv_art_health_education (client_id);

CREATE INDEX
    mamba_fact_health_education_encounter_id_index ON mamba_fact_encounter_hiv_art_health_education (encounter_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_health_education_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_health_education_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
                                                       health_education_disclosure,
                                                           ovc_no        ,
                                                           patient_categorization,
                                                           dsdm_models       ,
                                                           dsdm_approach     ,
                                                           other_gmh_approach   ,
                                                           other_imc_approach   ,
                                                           other_gmc_approach    ,
                                                           other_imf_approach    ,
                                                           linkages_and_referrals1   ,
                                                           arrange   )
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
       health_education_disclosure,
       ovc_no        ,
       patient_categorization,
       dsdm_models       ,
       dsdm_approach     ,
       other_gmh_approach   ,
       other_imc_approach   ,
       other_gmc_approach    ,
       other_imf_approach    ,
       linkages_and_referrals1   ,
       arrange


FROM mamba_flat_encounter_art_health_education;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_health_education_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_health_education_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education;


~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hiv_art_health_education', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hiv_art_health_education', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hiv_art_health_education_create();
CALL sp_fact_encounter_hiv_art_health_education_insert();
CALL sp_fact_encounter_hiv_art_health_education_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hiv_art_health_education_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_encounter_hiv_art_health_education_query;
~-~-
CREATE PROCEDURE sp_fact_encounter_hiv_art_health_education_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_hiv_art_health_education hiv_health WHERE hiv_health.encounter_date >= START_DATE
      AND hiv_health.encounter_date<= END_DATE ;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date;


~-~-
CREATE PROCEDURE sp_fact_current_arv_regimen_start_date()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_current_arv_regimen_start_date', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_current_arv_regimen_start_date', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_current_arv_regimen_start_date_create();
CALL sp_fact_current_arv_regimen_start_date_insert();
CALL sp_fact_current_arv_regimen_start_date_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_create;


~-~-
CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_current_arv_regimen_start_date_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_current_arv_regimen_start_date_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_insert;


~-~-
CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_current_arv_regimen_start_date_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_current_arv_regimen_start_date_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_current_arv_start_date_query;
~-~-
CREATE PROCEDURE sp_fact_current_arv_start_date_query()
BEGIN
    SELECT *
    FROM mamba_fact_current_arv_regimen_start_date;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_current_arv_regimen_start_date_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_current_arv_regimen_start_date_update;


~-~-
CREATE PROCEDURE sp_fact_current_arv_regimen_start_date_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_current_arv_regimen_start_date_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_current_arv_regimen_start_date_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_adherence_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_adherence_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_adherence_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_adherence_patients_create();
CALL sp_fact_latest_adherence_patients_insert();
CALL sp_fact_latest_adherence_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_adherence_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_adherence_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_adherence_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_adherence_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_adherence_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_adherence_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_adherence_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_adherence_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_adherence;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_adherence_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_adherence_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_adherence_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_adherence_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_adherence_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_advanced_disease_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_advanced_disease_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_advanced_disease_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_advanced_disease_patients_create();
CALL sp_fact_latest_advanced_disease_patients_insert();
CALL sp_fact_latest_advanced_disease_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_advanced_disease_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_advanced_disease_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_advanced_disease_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_advanced_disease_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_advanced_disease_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_advanced_disease_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_advanced_disease;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_advanced_disease_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_advanced_disease_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_advanced_disease_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_advanced_disease_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_advanced_disease_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_arv_days_dispensed_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_arv_days_dispensed_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_arv_days_dispensed_patients_create();
CALL sp_fact_latest_arv_days_dispensed_patients_insert();
CALL sp_fact_latest_arv_days_dispensed_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_arv_days_dispensed_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_arv_days_dispensed_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_arv_days_dispensed_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_arv_days_dispensed_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_arv_days_dispensed_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_arv_days_dispensed_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_arv_days_dispensed;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_arv_days_dispensed_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_arv_days_dispensed_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_arv_days_dispensed_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_arv_days_dispensed_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_arv_days_dispensed_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_current_regimen_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_current_regimen_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_current_regimen_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_current_regimen_patients_create();
CALL sp_fact_latest_current_regimen_patients_insert();
CALL sp_fact_latest_current_regimen_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_current_regimen_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_current_regimen_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_current_regimen_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_current_regimen_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_current_regimen_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_current_regimen_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_current_regimen_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_current_regimen_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_current_regimen;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_current_regimen_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_current_regimen_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_current_regimen_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_current_regimen_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_current_regimen_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_family_planning_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_family_planning_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_family_planning_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_family_planning_patients_create();
CALL sp_fact_latest_family_planning_patients_insert();
CALL sp_fact_latest_family_planning_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_family_planning_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_family_planning_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_family_planning_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_family_planning_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_family_planning_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_family_planning_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_family_planning_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_family_planning_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_family_planning;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_family_planning_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_family_planning_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_family_planning_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_family_planning_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_family_planning_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_hepatitis_b_test_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_hepatitis_b_test_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_hepatitis_b_test_patients_create();
CALL sp_fact_latest_hepatitis_b_test_patients_insert();
CALL sp_fact_latest_hepatitis_b_test_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_hepatitis_b_test_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_hepatitis_b_test_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_hepatitis_b_test_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_hepatitis_b_test_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_hepatitis_b_test_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_hepatitis_b_test_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_hepatitis_b_test;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_hepatitis_b_test_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_hepatitis_b_test_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_hepatitis_b_test_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_hepatitis_b_test_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_hepatitis_b_test_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_viral_load_patients_create();
CALL sp_fact_latest_viral_load_patients_insert();
CALL sp_fact_latest_viral_load_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_viral_load_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_viral_load_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_viral_load;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_decision_outcome_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_decision_outcome_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_iac_decision_outcome_patients_create();
CALL sp_fact_latest_iac_decision_outcome_patients_insert();
CALL sp_fact_latest_iac_decision_outcome_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_decision_outcome_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_decision_outcome_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_decision_outcome_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_decision_outcome_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_iac_decision_outcome_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_iac_decision_outcome_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_iac_decision_outcome;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_decision_outcome_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_decision_outcome_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_decision_outcome_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_decision_outcome_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_decision_outcome_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_sessions_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_sessions_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_sessions_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_iac_sessions_patients_create();
CALL sp_fact_latest_iac_sessions_patients_insert();
CALL sp_fact_latest_iac_sessions_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_sessions_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_sessions_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_sessions_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_sessions_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_arv_days_dispensed_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_arv_days_dispensed_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_arv_days_dispensed;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_iac_sessions_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_iac_sessions_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_iac_sessions_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_iac_sessions_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_iac_sessions_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_index_tested_children_patients_create();
CALL sp_fact_latest_index_tested_children_patients_insert();
CALL sp_fact_latest_index_tested_children_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_children_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_index_tested_children_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_children;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_index_tested_children_status_patients_create();
CALL sp_fact_latest_index_tested_children_status_patients_insert();
CALL sp_fact_latest_index_tested_children_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_children_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_index_tested_children_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_children_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_children_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_children_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_children_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_children_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_children_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_index_tested_partners_patients_create();
CALL sp_fact_latest_index_tested_partners_patients_insert();
CALL sp_fact_latest_index_tested_partners_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_patients_latest_index_tested_partners(client_id,
                                                             no)
Select person_id, count(*) as no from obs  WHERE concept_id = 164352
                                             AND value_coded IN (90288, 165274) AND voided=0 GROUP BY person_id;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_partners_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_index_tested_partners_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_partners;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_index_tested_partners_status_patients_create();
CALL sp_fact_latest_index_tested_partners_status_patients_insert();
CALL sp_fact_latest_index_tested_partners_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_index_tested_partners_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_index_tested_partners_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_index_tested_partners_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_index_tested_partners_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_index_tested_partners_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_index_tested_partners_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_index_tested_partners_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_index_tested_partners_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_assesment_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_assesment_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_nutrition_assesment_patients_create();
CALL sp_fact_latest_nutrition_assesment_patients_insert();
CALL sp_fact_latest_nutrition_assesment_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_assesment_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_assesment_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_assesment_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_assesment_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_nutrition_assesment_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_nutrition_assesment_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_nutrition_assesment;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_assesment_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_assesment_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_assesment_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_assesment_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_assesment_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_support_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_support_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_support_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_nutrition_support_patients_create();
CALL sp_fact_latest_nutrition_support_patients_insert();
CALL sp_fact_latest_nutrition_support_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_support_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_support_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_support_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_support_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_nutrition_support_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_nutrition_support_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_nutrition_support;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_nutrition_support_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_nutrition_support_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_nutrition_support_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_nutrition_support_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_nutrition_support_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_regimen_line_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_regimen_line_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_regimen_line_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_regimen_line_patients_create();
CALL sp_fact_latest_regimen_line_patients_insert();
CALL sp_fact_latest_regimen_line_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_regimen_line_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_regimen_line_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_regimen_line_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_regimen_line_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_regimen_line_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_regimen_line_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_regimen_line_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_regimen_line_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_regimen_line;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_regimen_line_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_line_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_regimen_line_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_regimen_line_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_regimen_line_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_return_date_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_return_date_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_return_date_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_return_date_patients_create();
CALL sp_fact_latest_return_date_patients_insert();
CALL sp_fact_latest_return_date_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_return_date_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_return_date_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_return_date_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_return_date_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_return_date_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_return_date_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_return_date_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_return_date_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_return_date;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_return_date_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_return_date_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_return_date_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_return_date_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_return_date_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_tb_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tb_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tb_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_tb_status_patients_create();
CALL sp_fact_latest_tb_status_patients_insert();
CALL sp_fact_latest_tb_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_tb_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tb_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tb_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_tb_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tb_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tb_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_tb_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_tb_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_tb_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tb_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tb_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_tb_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tb_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tb_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_tpt_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tpt_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tpt_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_tpt_status_patients_create();
CALL sp_fact_latest_tpt_status_patients_insert();
CALL sp_fact_latest_tpt_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_tpt_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tpt_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tpt_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_tpt_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tpt_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tpt_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_tpt_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_tpt_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_tpt_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_tpt_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_tpt_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_tpt_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_tpt_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_tpt_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_ordered_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_ordered_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_viral_load_ordered_patients_create();
CALL sp_fact_latest_viral_load_ordered_patients_insert();
CALL sp_fact_latest_viral_load_ordered_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_ordered_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_ordered_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_ordered_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_ordered_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_viral_load_ordered_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_viral_load_ordered_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_viral_load_ordered;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_viral_load_ordered_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_viral_load_ordered_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_viral_load_ordered_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_viral_load_ordered_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_viral_load_ordered_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_vl_after_iac_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_vl_after_iac_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_vl_after_iac_patients_create();
CALL sp_fact_latest_vl_after_iac_patients_insert();
CALL sp_fact_latest_vl_after_iac_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_vl_after_iac_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_vl_after_iac_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_vl_after_iac_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_vl_after_iac_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_vl_after_iac_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_vl_after_iac_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_vl_after_iac;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_vl_after_iac_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_vl_after_iac_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_vl_after_iac_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_vl_after_iac_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_vl_after_iac_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_who_stage_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_who_stage_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_who_stage_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_who_stage_patients_create();
CALL sp_fact_latest_who_stage_patients_insert();
CALL sp_fact_latest_who_stage_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_who_stage_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_who_stage_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_who_stage_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_who_stage_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_who_stage_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_who_stage_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_who_stage_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_who_stage_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_who_stage;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_who_stage_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_who_stage_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_who_stage_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_who_stage_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_who_stage_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients;


~-~-
CREATE PROCEDURE sp_fact_marital_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_marital_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_marital_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_marital_status_patients_create();
CALL sp_fact_marital_status_patients_insert();
CALL sp_fact_marital_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_marital_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_marital_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_marital_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_marital_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_marital_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_marital_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_marital_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_marital_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_marital_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_marital_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_marital_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_marital_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_marital_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_marital_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients;


~-~-
CREATE PROCEDURE sp_fact_nationality_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_nationality_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_nationality_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_nationality_patients_create();
CALL sp_fact_nationality_patients_insert();
CALL sp_fact_nationality_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_create;


~-~-
CREATE PROCEDURE sp_fact_nationality_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_nationality_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_nationality_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_nationality_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_nationality_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_nationality_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_nationality_query;
~-~-
CREATE PROCEDURE sp_fact_patient_nationality_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_nationality;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_nationality_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_nationality_patients_update;


~-~-
CREATE PROCEDURE sp_fact_nationality_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_nationality_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_nationality_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_patient_demographics_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_patient_demographics_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_patient_demographics_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_patient_demographics_patients_create();
CALL sp_fact_latest_patient_demographics_patients_insert();
CALL sp_fact_latest_patient_demographics_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_patient_demographics_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_patient_demographics_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_patient_demographics_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_patient_demographics_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_patient_demographics_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_patient_demographics_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_patient_demographics;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_patient_demographics_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_patient_demographics_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_patient_demographics_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_patient_demographics_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_patient_demographics_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_art_patients;


~-~-
CREATE PROCEDURE sp_fact_art_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_art_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_art_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_art_patients_create();
CALL sp_fact_art_patients_insert();
CALL sp_fact_art_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_art_patients_create;


~-~-
CREATE PROCEDURE sp_fact_art_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_art_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_art_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_art_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_art_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_art_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_art_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_art_patients_query;
~-~-
CREATE PROCEDURE sp_fact_art_patients_query()
BEGIN
    SELECT *
    FROM mamba_fact_art_patients ;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_art_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_art_patients_update;


~-~-
CREATE PROCEDURE sp_fact_art_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_art_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_art_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients;


~-~-
CREATE PROCEDURE sp_fact_calhiv_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_calhiv_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_calhiv_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_calhiv_patients_create();
CALL sp_fact_calhiv_patients_insert();
CALL sp_fact_calhiv_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_create;


~-~-
CREATE PROCEDURE sp_fact_calhiv_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_calhiv_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_calhiv_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    cd4_date                               DATE NULL,
    cd4                                    INT NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_audit_tool_art_patients_client_id_index ON mamba_fact_audit_tool_art_patients (client_id);

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_calhiv_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_calhiv_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_calhiv_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
                                                known_status_partners, age_group,
                                                cacx_date,
                                                cd4_date,
                                                cd4)
SELECT cohort.client_id,
       identifiers.identifier                                               AS identifier,
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
                  IF(days_left_to_be_lost > 28, 'LTFU (TX_ML)', ''))), '')  AS client_status,
       transfer_out_date,
       current_regimen,
       arv_regimen_start_date,
       adherence,
       days                                                                 AS arv_days_dispensed,
       hiv_viral_load_copies,
       hiv_viral_collection_date,
       IF(order_date > hiv_viral_collection_date, order_date, NULL)         AS new_sample_collection_date,
       advanced_disease,
       mfplfp.status                                                        AS family_planning_status,
       mfplna.status                                                        AS nutrition_assesment,
       mfplnsmfplns.support                                                 AS nutrition_support,
       IF(sub_art_summary.hepatitis_b_test_qualitative = 'UNKNOWN', 'INDETERMINATE',
          sub_art_summary.hepatitis_b_test_qualitative)                     AS hepatitis_b_test_qualitative,
       syphilis_test_result_for_partner,
       cervical_cancer_screening,
       mfplts.status                                                        AS tuberculosis_status,
       mfplts2.status                                                       AS tpt_status,
       crag_test_results,
       stage                                                                AS WHO_stage,
       baseline_cd4,
       baseline_regimen_start_date,
       IF(IFNULL(special_category, '') = '', '', 'Priority population(PP)') AS special_category,
       IF(regimen = 90271, 1,
          IF(regimen = 90305, 2,
             IF(regimen = 162987, 3, 1)))                                   AS regimen_line,
       health_education_setting,
       pss_issues_identified,
       art_preparation,
       depression_status,
       gender_based_violance,
       health_education_disclosure,
       ovc_screening,
       ovc_assessment,
       prevention_components,
       IF(hiv_viral_load_copies >= 1000, IFNULL(sessions, 0), NULL)         AS iac_sessions,
       IF(hiv_viral_load_copies >= 1000, hivdr_results, NULL)               AS hivdr_results,
       date_hivr_results_recieved_at_facility,
       IF(hiv_viral_load_copies >= 1000, mfplvai.results, NULL)             as vl_after_iac,
       IF(hiv_viral_load_copies >= 1000, mfplido.decision, NULL)            AS decision_outcome,
       TIMESTAMPDIFF(MONTH, baseline_regimen_start_date, last_visit_date)   AS duration_on_art,
       sub_side_effects.medication_or_other_side_effects                    AS side_effects,
       specimen_type                                                        AS specimen_source,
       hiv_vl_date,
       mfplitc.no                                                           AS children,
       mfplitcs.no                                                          AS known_status_children,
       mfplitp.no                                                           AS partners,
       mfplitps.no                                                          AS known_status_partners,
       cohort.age_group                                                     AS age_group,
       sub_cervical_cancer_screening.encounter_date                         AS cacx_date,
       cd4_test_date,
       mfto_cd4.test_value as cd4

FROM mamba_fact_art_patients cohort
         LEFT JOIN (SELECT mf_to.client_id
                    FROM mamba_fact_transfer_out mf_to
                             LEFT JOIN mamba_fact_transfer_in mf_ti ON mf_to.client_id = mf_ti.client_id
                    WHERE (transfer_out_date > transfer_in_date OR mf_ti.client_id IS NULL)) mfto
                   on mfto.client_id = cohort.client_id
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
         LEFT JOIN (SELECT b.client_id, b.encounter_date, cervical_cancer_screening
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          WHERE cervical_cancer_screening IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_cervical_cancer_screening
                   ON sub_cervical_cancer_screening.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, crag_test_results
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          WHERE crag_test_results IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_crag_test_results
                   ON sub_crag_test_results.client_id = cohort.client_id
         LEFT JOIN (SELECT client_id,
                           baseline_cd4,
                           baseline_regimen_start_date,
                           special_category,
                           hepatitis_b_test_qualitative
                    FROM mamba_fact_encounter_hiv_art_summary
                    GROUP BY client_id) sub_art_summary ON sub_art_summary.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, health_education_setting
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE health_education_setting IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_health_education_setting
                   ON sub_health_education_setting.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, pss_issues_identified
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE pss_issues_identified IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_pss_issues_identified
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
                         ON a.encounter_id = b.encounter_id) sub_gender_based_violance
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
                   ON sub_hiv_vl_date.client_id = cohort.client_id
         LEFT JOIN (SELECT a.client_id, cd4_test_date, b.test_value
                    FROM mamba_fact_test_orders_results b
                             join
                         (SELECT client_id, MAX(encounter_datetime) as cd4_test_date
                          from mamba_fact_test_orders_results
                          WHERE test_parameter = 'cd4'
                            and test_value is not null
                          GROUP BY client_id) a
                         ON a.client_id = b.client_id AND encounter_datetime = cd4_test_date
                    WHERE test_parameter = 'cd4'
                      and test_value is not null) mfto_cd4
                   ON mfto_cd4.client_id = cohort.client_id
WHERE mfto.client_id IS NULL;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_audit_tool_art_query;
~-~-
CREATE PROCEDURE sp_fact_audit_tool_art_query(IN id_list VARCHAR(255))
BEGIN
    SELECT *
    FROM mamba_fact_audit_tool_art_patients audit_tool where client_id in (id_list);
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_calhiv_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_calhiv_patients_update;


~-~-
CREATE PROCEDURE sp_fact_calhiv_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_calhiv_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_calhiv_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_active_in_care;


~-~-
CREATE PROCEDURE sp_fact_active_in_care()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_active_in_care', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_active_in_care', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_active_in_care_create();
CALL sp_fact_active_in_care_insert();
CALL sp_fact_active_in_care_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_create;


~-~-
CREATE PROCEDURE sp_fact_active_in_care_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_active_in_care_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_active_in_care_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_insert;


~-~-
CREATE PROCEDURE sp_fact_active_in_care_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_active_in_care_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_active_in_care_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_active_in_care_query;
~-~-
CREATE PROCEDURE sp_fact_active_in_care_query(IN DAYS_LOST INT)
BEGIN
    SELECT *
    FROM mamba_fact_active_in_care WHERE days_left_to_be_lost >= DAYS_LOST;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_active_in_care_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_active_in_care_update;


~-~-
CREATE PROCEDURE sp_fact_active_in_care_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_active_in_care_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_active_in_care_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients;


~-~-
CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_pregnancy_status_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_pregnancy_status_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_latest_pregnancy_status_patients_create();
CALL sp_fact_latest_pregnancy_status_patients_insert();
CALL sp_fact_latest_pregnancy_status_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_create;


~-~-
CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_pregnancy_status_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_pregnancy_status_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_pregnancy_status_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_pregnancy_status_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_patient_latest_pregnancy_status_query;
~-~-
CREATE PROCEDURE sp_fact_patient_latest_pregnancy_status_query()
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_pregnancy_status;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_latest_pregnancy_status_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_latest_pregnancy_status_patients_update;


~-~-
CREATE PROCEDURE sp_fact_latest_pregnancy_status_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_latest_pregnancy_status_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_latest_pregnancy_status_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_eid_patients;


~-~-
CREATE PROCEDURE sp_fact_eid_patients()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_eid_patients', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_eid_patients', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_eid_patients_create();
CALL sp_fact_eid_patients_insert();
CALL sp_fact_eid_patients_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_create;


~-~-
CREATE PROCEDURE sp_fact_eid_patients_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_eid_patients_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_eid_patients_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_insert;


~-~-
CREATE PROCEDURE sp_fact_eid_patients_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_eid_patients_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_eid_patients_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_eid_patients_query;
~-~-
CREATE PROCEDURE sp_fact_eid_patients_query()
BEGIN
    SELECT *
    FROM mamba_fact_eid_patients;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_eid_patients_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_eid_patients_update;


~-~-
CREATE PROCEDURE sp_fact_eid_patients_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_eid_patients_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_eid_patients_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_medication_orders_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_medication_orders_create;


~-~-
CREATE PROCEDURE sp_fact_medication_orders_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_medication_orders_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_medication_orders_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_medication_orders
(
    id        INT AUTO_INCREMENT,
    client_id INT NULL,
    order_id    INT NOT NULL,
    drug_concept_id  INT NOT NULL,
    drug        VARCHAR(255) NULL,
    encounter_id INT  NULL,
    instructions   VARCHAR(255) NULL,
    date_activated  DATETIME,
    urgency         VARCHAR(250) NULL,
    order_number    VARCHAR(100) NULL,
    dose            INT NULL ,
    dose_units      VARCHAR(200) NULL,
    quantity        INT NULL,
    quantity_units VARCHAR(200) NULL,
    duration        INT NULL,
    duration_units  VARCHAR(200) NULL,
        PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_medication_orders_client_id_index ON mamba_fact_medication_orders (client_id);
CREATE INDEX
    mamba_fact_medication_orders_order_id_index ON mamba_fact_medication_orders (order_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_medication_orders_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_medication_orders_insert;


~-~-
CREATE PROCEDURE sp_fact_medication_orders_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_medication_orders_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_medication_orders_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_medication_orders(order_id, client_id,
                                         drug_concept_id,
                                         encounter_id,
                                         instructions,
                                         date_activated,
                                         urgency,
                                         order_number,
                                         dose,
                                         dose_units,
                                         quantity,
                                         quantity_units,
                                         duration,
                                         duration_units)
SELECT o.order_id,
       patient_id   AS client,
       o.concept_id AS drug,
       encounter_id,
       instructions,
       date_activated,
       urgency,
       order_number,
       dose,
       cn3.name     AS dose_units,
       quantity,
       cn1.name     AS quantity_units,
       duration,
       cn2.name     AS duration_units
FROM orders o
         INNER JOIN order_type ot ON o.order_type_id = ot.order_type_id
         INNER JOIN drug_order d_o ON o.order_id = d_o.order_id
         LEFT JOIN concept_name cn1 ON d_o.quantity_units = cn1.concept_id
    AND cn1.locale = 'en' AND cn1.concept_name_type = 'FULLY_SPECIFIED' AND cn1.locale_preferred = 1
         LEFT JOIN concept_name cn2 ON d_o.duration_units = cn2.concept_id AND cn2.locale_preferred = 1
    AND cn2.locale = 'en' AND cn2.concept_name_type = 'FULLY_SPECIFIED'
         LEFT JOIN concept_name cn3 ON d_o.dose_units = cn3.concept_id AND cn3.locale_preferred = 1
    AND cn3.locale = 'en' AND cn3.concept_name_type = 'FULLY_SPECIFIED'

WHERE ot.uuid = '131168f4-15f5-102d-96e4-000c29c2a5d7'
  AND o.voided = 0
;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_medication_orders_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_medication_orders_update;


~-~-
CREATE PROCEDURE sp_fact_medication_orders_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_medication_orders_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_medication_orders_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
UPDATE mamba_fact_medication_orders mo
    JOIN (
        SELECT cn.concept_id, cn.name
        FROM concept_name cn
        WHERE cn.locale = 'en'
          AND cn.voided = 0
          AND (
            cn.locale_preferred = 1
                OR cn.concept_name_type = 'FULLY_SPECIFIED'
            )
    ) best_names ON best_names.concept_id = mo.drug_concept_id
SET mo.drug = best_names.name;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_medication_orders  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_medication_orders;


~-~-
CREATE PROCEDURE sp_fact_medication_orders()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_medication_orders', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_medication_orders', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_medication_orders_create();
CALL sp_fact_medication_orders_insert();
CALL sp_fact_medication_orders_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_medication_orders_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders;


~-~-
CREATE PROCEDURE sp_fact_test_orders()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_test_orders_create();
CALL sp_fact_test_orders_insert();
CALL sp_fact_test_orders_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_create;


~-~-
CREATE PROCEDURE sp_fact_test_orders_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_test_orders
(
    id        INT AUTO_INCREMENT,
    client_id INT NULL,
    order_id    INT NOT NULL,
    test_concept_id  INT NOT NULL,
    test_name        VARCHAR(255) NULL,
    encounter_id INT  NULL,
    orderer     INT NULL,
    instructions VARCHAR(255) NULL,
    date_activated DATE NULL,
    date_stopped   DATE NULL,
    accession_number VARCHAR(200) NULL,
    order_number     VARCHAR(150) NULL,
    specimen_source VARCHAR(250) NULL,
        PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_test_orders_client_id_index ON mamba_fact_test_orders (client_id);
CREATE INDEX
    mamba_fact_test_orders_order_id_index ON mamba_fact_test_orders (order_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_insert;


~-~-
CREATE PROCEDURE sp_fact_test_orders_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_test_orders(order_id, client_id,
                                   encounter_id,
                                   test_concept_id,
                                   test_name, orderer,
                                   instructions,
                                   date_activated,
                                   date_stopped,
                                   accession_number,
                                   order_number,
                                   specimen_source)
SELECT o.order_id,
       patient_id,
       encounter_id,
       o.concept_id,
       cn.name  as test_name,
       orderer,
       instructions,
       date_activated,
       date_stopped,
       accession_number,
       order_number,
       cn1.name as specimen_source
FROM orders o
         INNER JOIN order_type ot ON o.order_type_id = ot.order_type_id
         INNER JOIN test_order t_o ON o.order_id = t_o.order_id
         LEFT JOIN concept_name cn ON o.concept_id = cn.concept_id
    AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.locale_preferred = 1
         LEFT JOIN concept_name cn1 ON specimen_source = cn1.concept_id
    AND cn1.locale = 'en' AND cn1.concept_name_type = 'FULLY_SPECIFIED' AND cn1.locale_preferred = 1
WHERE ot.uuid = '52a447d3-a64a-11e3-9aeb-50e549534c5e'
  and o.voided = 0;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_update;


~-~-
CREATE PROCEDURE sp_fact_test_orders_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_results  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_results;


~-~-
CREATE PROCEDURE sp_fact_test_orders_results()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_results', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_results', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_test_orders_results_create();
CALL sp_fact_test_orders_results_insert();
CALL sp_fact_test_orders_results_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_results_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_results_create;


~-~-
CREATE PROCEDURE sp_fact_test_orders_results_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_results_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_results_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_test_orders_results
(
    id        INT AUTO_INCREMENT,
    test_orders_id INT NOT NULL,
    encounter_id INT NULL,
    encounter_datetime DATE NULL,
    client_id INT NULL,
    test_concept_id  INT NOT NULL,
    test_parameter        VARCHAR(255) NULL,
    test_value        TEXT NULL,

        PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_test_orders_client_id_index ON mamba_fact_test_orders_results (client_id);
CREATE INDEX
    mamba_fact_test_orders_order_id_index ON mamba_fact_test_orders_results (id);

CREATE INDEX
    mamba_fact_test_orders_test_order_results_id_index ON mamba_fact_test_orders_results (test_orders_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_results_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_results_insert;


~-~-
CREATE PROCEDURE sp_fact_test_orders_results_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_results_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_results_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_test_orders_results(test_orders_id,
                                          encounter_id,
                                          encounter_datetime,
                                          client_id,
                                          test_concept_id,
                                          test_parameter,
                                          test_value)
SELECT labtests.id                                                                         AS test_orders_id,
       labtests.encounter_id,
       encounter_datetime,
       client_id,
       labtests.concept_id                                                                 AS test_concept_id,
       cn.name                                                                             AS test_parameter,
       IF(cd.name = 'Numeric', value_numeric,
          IF(cd.name = 'Date', DATE(value_datetime), IF(cd.name = 'Coded', cn1.name, ''))) AS value
FROM (SELECT mfto.id,
             mfto.encounter_id,
             mfto.client_id,
             o.obs_id,
             DATE(obs_datetime) as encounter_datetime,
             o.concept_id
      FROM mamba_fact_test_orders mfto
               LEFT JOIN obs o
                         ON mfto.test_concept_id = o.concept_id AND mfto.encounter_id = o.encounter_id
               INNER JOIN concept c ON o.concept_id = c.concept_id
               INNER JOIN concept_class cc ON c.class_id = cc.concept_class_id
      WHERE cc.name = 'LabSet'
        AND c.is_set = 1
        AND o.voided = 0) labtests
         LEFT JOIN obs o ON o.obs_group_id = labtests.obs_id
         LEFT JOIN concept_name cn ON o.concept_id = cn.concept_id
         INNER JOIN concept c ON o.concept_id = c.concept_id
         INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
         left join concept_name cn1 on o.value_coded = cn1.concept_id AND
                                       IF(cn1.locale_preferred = 1, cn1.locale_preferred = 1,
                                          cn1.concept_name_type = 'FULLY_SPECIFIED')
WHERE IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED');


INSERT INTO mamba_fact_test_orders_results(test_orders_id,
                                          encounter_id,
                                          client_id,
                                          test_concept_id,
                                          test_parameter,
                                          test_value)
SELECT id                                                                                                    AS test_orders_id,
       encounter_id,
       client_id,
       concept_id                                                                                            AS test_concept_id,
       test_parameter,
       IF(datatype = 'Numeric', value_numeric,
          IF(datatype = 'Date', DATE(value_datetime), IF(datatype = 'Coded', coded_value_text, value_text))) AS value
FROM (SELECT mfto.id,
             mfto.encounter_id,
             mfto.client_id,
             o.concept_id,
             cn.name  AS test_parameter,
             cd.name  AS datatype,
             cn1.name AS coded_value_text,
             value_numeric,
             value_datetime,
             value_text

      FROM mamba_fact_test_orders mfto
               LEFT JOIN obs o
                         ON mfto.test_concept_id = o.concept_id AND mfto.encounter_id = o.encounter_id
               INNER JOIN concept c ON o.concept_id = c.concept_id
               LEFT JOIN concept_name cn ON c.concept_id = cn.concept_id
               INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
               INNER JOIN concept_class cc ON c.class_id = cc.concept_class_id
               LEFT JOIN concept_name cn1 ON o.value_coded = cn1.concept_id AND
                                             IF(cn1.locale_preferred = 1, cn1.locale_preferred = 1,
                                                cn1.concept_name_type = 'FULLY_SPECIFIED')
      WHERE cc.name <> 'LabSet'
        AND o.voided = 0
        AND IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED')) labtests;


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_results_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_test_orders_results_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_test_orders_results_update;


~-~-
CREATE PROCEDURE sp_fact_test_orders_results_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_test_orders_results_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_test_orders_results_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hiv_art_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art_card;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hiv_art_card()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hiv_art_card', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hiv_art_card', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- CALL sp_dim_client_hiv_hts;
CALL sp_fact_encounter_hiv_art_card;
CALL sp_fact_encounter_hiv_art_summary;
CALL sp_fact_encounter_hiv_art_health_education;
CALL sp_fact_active_in_care;
CALL sp_fact_medication_orders;
CALL sp_fact_test_orders;
CALL sp_fact_test_orders_results;
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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_dim_client_covid_create;


~-~-
CREATE PROCEDURE sp_dim_client_covid_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_dim_client_covid_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_dim_client_covid_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_dim_client_covid_insert;


~-~-
CREATE PROCEDURE sp_dim_client_covid_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_dim_client_covid_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_dim_client_covid_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_dim_client_covid_update;


~-~-
CREATE PROCEDURE sp_dim_client_covid_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_dim_client_covid_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_dim_client_covid_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_dim_client_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_dim_client_covid;


~-~-
CREATE PROCEDURE sp_dim_client_covid()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_dim_client_covid', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_dim_client_covid', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_dim_client_covid_create();
CALL sp_dim_client_covid_insert();
CALL sp_dim_client_covid_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_covid_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_covid_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_covid_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_covid_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_covid_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_covid_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_covid_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_covid_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_covid_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_covid;


~-~-
CREATE PROCEDURE sp_fact_encounter_covid()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_covid', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_covid', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_covid_create();
CALL sp_fact_encounter_covid_insert();
CALL sp_fact_encounter_covid_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_covid  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_covid;


~-~-
CREATE PROCEDURE sp_data_processing_derived_covid()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_covid', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_covid', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_dim_client_covid;
CALL sp_fact_encounter_covid;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_calculate_moh_age_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_calculate_moh_age_group;


~-~-
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
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  fn_mamba_calculate_moh_2024_age_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_mamba_calculate_moh_2024_age_group;


~-~-
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
END;
~-~-




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_mamba_insert_age_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_mamba_load_agegroup;


~-~-
CREATE PROCEDURE sp_mamba_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO mamba_dim_agegroup(age, datim_agegroup, normal_agegroup,moh_age_group,moh_2024_age_group)
            VALUES (age, fn_mamba_calculate_agegroup(age), IF(age < 15, '<15', '15+'),fn_mamba_calculate_moh_age_group(age),fn_mamba_calculate_moh_2024_age_group(age));
            SET age = age + 1;
        END WHILE;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card;


~-~-
CREATE PROCEDURE sp_fact_encounter_hts_card()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hts_card', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hts_card', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hts_card_create();
CALL sp_fact_encounter_hts_card_insert();
CALL sp_fact_encounter_hts_card_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_hts_card_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hts_card_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hts_card_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_encounter_hts_card
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    encounter_date                        DATETIME         NULL,
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
    serial_number     VARCHAR(100) NULL,
    client_at_risk_of_acquiring_hiv VARCHAR(255) NULL,
    risk_profile          VARCHAR(255) NULL,
    do_you_consent_for_an_hiv_test        VARCHAR(255) NULL,
    consent_date          DATE NULL,
    hiv_test_1_kit        VARCHAR(255) NULL,
    hiv_test_1_kit_results        VARCHAR(255) NULL,
    hiv_test_2_kit            VARCHAR(255) NULL,
    hiv_test_2_kit_results        VARCHAR(255) NULL,
    hiv_test_3_kit        VARCHAR(255) NULL,
    hiv_test_3_kit_results            VARCHAR(255) NULL,
    sample_sent_to_reference_laboratory   VARCHAR(255) NULL,
    client_screened_for_tb        VARCHAR(255) NULL,
    art_no        VARCHAR(30) NULL,
    received_prevention_services VARCHAR(30) NULL,
    test_name         VARCHAR(255) NULL,
    test_date DATE NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hts_card_client_id_index ON mamba_fact_encounter_hts_card (client_id);

CREATE INDEX
    mamba_fact_encounter_hts_encounter_id_index ON mamba_fact_encounter_hts_card (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_encounter_date_index ON mamba_fact_encounter_hts_card (encounter_date);
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_hts_card_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hts_card_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hts_card_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_encounter_hts_card (encounter_id,
                                           client_id,
                                           encounter_date,
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
                                           has_client_been_linked_to_care, name_of_location_transferred_to,
                                           serial_number     ,
                                           client_at_risk_of_acquiring_hiv ,
                                           risk_profile          ,
                                           do_you_consent_for_an_hiv_test ,
                                           consent_date          ,
                                           hiv_test_1_kit        ,
                                           hiv_test_1_kit_results       ,
                                           hiv_test_2_kit           ,
                                           hiv_test_2_kit_results        ,
                                           hiv_test_3_kit       ,
                                           hiv_test_3_kit_results            ,
                                           sample_sent_to_reference_laboratory   ,
                                           client_screened_for_tb       ,
                                           art_no        ,
                                           received_prevention_services ,
                                           test_name        ,
                                           test_date )
SELECT a.encounter_id,
    a.client_id,
    a.encounter_datetime,
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
       name_of_location_transferred_to,
       serial_number     ,
       client_at_risk_of_acquiring_hiv ,
       risk_profile          ,
       do_you_consent_for_an_hiv_test ,
       consent_date          ,
       hiv_test_1_kit        ,
       hiv_test_1_kit_results       ,
       hiv_test_2_kit           ,
       hiv_test_2_kit_results        ,
       hiv_test_3_kit       ,
       hiv_test_3_kit_results            ,
       sample_sent_to_reference_laboratory   ,
       client_screened_for_tb       ,
       art_no        ,
       received_prevention_services ,
       test_name        ,
       test_date

FROM mamba_flat_encounter_hts_card a left join mamba_flat_encounter_hts_card_1 b on a.encounter_id = b.encounter_id;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_hts_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_hts_card_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_hts_card_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_hts_card_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_hts  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts;


~-~-
CREATE PROCEDURE sp_data_processing_derived_hts()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_hts', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_hts', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_hts_card;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_card_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_card_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
    emtct                      VARCHAR(80) NULL,
    pregnant_status               VARCHAR(100) NULL,
    diagnosed_with_cryptococcal_meningitis    VARCHAR(100) NULL,
    treated_for_ccm       VARCHAR(30) NULL,
    histoplasmosis_screening  VARCHAR(80) NULL,
    histoplasmosis_results    VARCHAR(255) NULL,
    aspergillosis_screening       VARCHAR(80) NULL,
    other_clinical_decision          VARCHAR(80) NULL,
    date_of_decision          DATE NULL,
    outcome                   VARCHAR(100) NULL,
    other_outcome              TEXT,
    comments                  TEXT,
        PRIMARY KEY (id)
) CHARSET = UTF8;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_card_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_card_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
                                                      hivdr_results,
                                                      emtct                      ,
                                                      pregnant_status               ,
                                                      diagnosed_with_cryptococcal_meningitis   ,
                                                      treated_for_ccm      ,
                                                      histoplasmosis_screening  ,
                                                      histoplasmosis_results   ,
                                                      aspergillosis_screening       ,
                                                      other_clinical_decision          ,
                                                      date_of_decision          ,
                                                      outcome                  ,
                                                      other_outcome            ,
                                                      comments )
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
       hivdr_results,
       emtct                      ,
       pregnant_status               ,
       diagnosed_with_cryptococcal_meningitis   ,
       treated_for_ccm      ,
       histoplasmosis_screening  ,
       histoplasmosis_results   ,
       aspergillosis_screening       ,
       other_clinical_decision          ,
       date_of_decision          ,
       outcome                  ,
       other_outcome            ,
       comments

FROM mamba_flat_encounter_non_suppressed;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_card_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_card_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card_query  ----------------------------
-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card_query;
~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card_query(IN START_DATE
                                                     DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_non_suppressed_card non_suppressed WHERE non_suppressed.encounter_date >= START_DATE
      AND non_suppressed.encounter_date <= END_DATE ;
END;
~-~-



        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_card  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_card;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_card()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_card', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_card', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card_create();
CALL sp_fact_encounter_non_suppressed_card_insert();
CALL sp_fact_encounter_non_suppressed_card_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_obs_group_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_obs_group_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_obs_group_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_obs_group_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_obs_group_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_non_suppressed_obs_group
(
    id                   INT AUTO_INCREMENT,
    client_id            INT  NULL,
    encounter_id           INT NULL,
    obs_group_id            INT NULL,
    obs_datetime            DATETIME NULL,
    session_date            DATE NULL,
    adherence_code                   VARCHAR(250) NULL,
    score                   INT NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_non_suppressed_obs_group_client_id_index ON mamba_fact_non_suppressed_obs_group (client_id);
CREATE INDEX
    mamba_fact_non_suppressed_obs_group_encounter_id_index ON mamba_fact_non_suppressed_obs_group (encounter_id);
CREATE INDEX
    mamba_fact_non_suppressed_obs_group_obs_group_id_index ON mamba_fact_non_suppressed_obs_group (obs_group_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_obs_group_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_obs_group_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_obs_group_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_obs_group_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_obs_group_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_non_suppressed_obs_group (encounter_id,
                                               client_id,
                                                 obs_datetime,
                                                 obs_group_id,
                                                 session_date,
                                                 adherence_code,
                                                 score )
SELECT
    og.encounter_id,
    og.person_id,
    og.obs_datetime,
    og.obs_id AS obs_group_id,

    MAX(CASE WHEN o.concept_id = 163154 THEN o.value_datetime END) AS session_date,
    MAX(CASE WHEN o.concept_id = 90221 THEN cn.name END) AS adherence_code,
    MAX(CASE WHEN o.concept_id = 163155 THEN o.value_numeric END) AS score

FROM
    obs og
        LEFT JOIN obs o ON o.obs_group_id = og.obs_id AND o.voided = 0
        LEFT JOIN concept_name cn
                  ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.voided = 0 and cn.concept_name_type='FULLY_SPECIFIED'
WHERE
    og.concept_id = 163153

  AND og.voided = 0
GROUP BY
    og.obs_id, og.encounter_id, og.person_id, og.obs_datetime;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_obs_group_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_obs_group_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_obs_group_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_obs_group_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_obs_group_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_obs_group_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_obs_group  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_obs_group;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_obs_group()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_obs_group', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_obs_group', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_obs_group_create();
CALL sp_fact_encounter_non_suppressed_obs_group_insert();
CALL sp_fact_encounter_non_suppressed_obs_group_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_repeat_vl  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_repeat_vl;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_repeat_vl()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_repeat_vl', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_repeat_vl', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_repeat_vl_create();
CALL sp_fact_encounter_non_suppressed_repeat_vl_insert();
CALL sp_fact_encounter_non_suppressed_repeat_vl_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_repeat_vl_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_repeat_vl_create;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_repeat_vl_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_repeat_vl_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_repeat_vl_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CREATE TABLE mamba_fact_non_suppressed_repeat_vl
(
    id                   INT AUTO_INCREMENT,
    client_id            INT  NULL,
    encounter_id           INT NULL,
    obs_group_id            INT NULL,
    obs_datetime            DATETIME NULL,
    vl_sample_collection      VARCHAR(50) NULL,
    hivdr_sample_Collection     VARCHAR(100) NULL,
    vl_repeat_date                   DATE NULL,
    iac_results                VARCHAR(250) NULL,
    copies                INT NULL,
    date_vl_received                   DATE NULL,
    hivdr_results_received                  DATE NULL,
    hivdr_results                   VARCHAR(250) NULL,
    hivdr_result_date                   DATE NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_non_suppressed_repeat_vl_client_id_index ON mamba_fact_non_suppressed_repeat_vl (client_id);
CREATE INDEX
    mamba_fact_non_suppressed_repeat_vl_encounter_id_index ON mamba_fact_non_suppressed_repeat_vl (encounter_id);
CREATE INDEX
    mamba_fact_non_suppressed_repeat_vl_obs_group_id_index ON mamba_fact_non_suppressed_repeat_vl (obs_group_id);


-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_repeat_vl_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_repeat_vl_insert;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_repeat_vl_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_repeat_vl_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_repeat_vl_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_non_suppressed_repeat_vl (encounter_id,
                                               client_id,
                                                 obs_datetime,
                                                 obs_group_id,
                                                 vl_sample_collection,
                                                 hivdr_sample_Collection,
                                                 vl_repeat_date,
                                                 iac_results,
                                                 copies ,
                                                 date_vl_received,
                                                 hivdr_results_received,
                                                 hivdr_results,
                                                 hivdr_result_date)
SELECT
    og.encounter_id,
    og.person_id,
    og.obs_datetime,
    og.obs_id AS obs_group_id,

    MAX(CASE WHEN o.concept_id = 199121 THEN o.value_coded END) AS vl_sample_collected,
    MAX(CASE WHEN o.concept_id = 164989 THEN o.value_coded END) AS hivdr_sample_sample_collected,
    MAX(CASE WHEN o.concept_id = 163023 THEN o.value_datetime END) AS vl_repeat_date,
    MAX(CASE WHEN o.concept_id = 1305 THEN o.value_coded END) AS iac_results,
    MAX(CASE WHEN o.concept_id = 856 THEN o.value_numeric END) AS copies,
    MAX(CASE WHEN o.concept_id = 163150 THEN o.value_datetime END) AS recieved_vl_date,
    MAX(CASE WHEN o.concept_id = 199122 THEN o.value_coded END) AS hivdr_results_received,
    MAX(CASE WHEN o.concept_id = 165824 THEN o.value_text END) AS hivdr_results,
    MAX(CASE WHEN o.concept_id = 165823 THEN o.value_datetime END) AS hivdr_results_date

FROM
    obs og
        LEFT JOIN obs o ON o.obs_group_id = og.obs_id AND o.voided = 0

WHERE
    og.concept_id = 163157

  AND og.voided = 0
GROUP BY
    og.obs_id, og.encounter_id, og.person_id, og.obs_datetime;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_repeat_vl_query  ----------------------------
-- ---------------------------------------------------------------------------------------------




        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_encounter_non_suppressed_repeat_vl_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_encounter_non_suppressed_repeat_vl_update;


~-~-
CREATE PROCEDURE sp_fact_encounter_non_suppressed_repeat_vl_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_encounter_non_suppressed_repeat_vl_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_encounter_non_suppressed_repeat_vl_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_non_suppressed  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_non_suppressed;


~-~-
CREATE PROCEDURE sp_data_processing_derived_non_suppressed()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_non_suppressed', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_non_suppressed', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_encounter_non_suppressed_card;
CALL sp_fact_encounter_non_suppressed_obs_group;
CALL sp_fact_encounter_non_suppressed_repeat_vl;
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_in;


~-~-
CREATE PROCEDURE sp_fact_transfer_in()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_in', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_in', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_transfer_in_create();
CALL sp_fact_transfer_in_insert();
CALL sp_fact_transfer_in_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_create;


~-~-
CREATE PROCEDURE sp_fact_transfer_in_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_in_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_in_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_insert;


~-~-
CREATE PROCEDURE sp_fact_transfer_in_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_in_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_in_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_transfer_in (
                                  client_id,
                                  encounter_date,
                                  transfer_in_date
                                 )
SELECT person_id, obs_datetime, value_datetime from obs where concept_id=99160 and voided =0 ;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_in_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_in_update;


~-~-
CREATE PROCEDURE sp_fact_transfer_in_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_in_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_in_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_out;


~-~-
CREATE PROCEDURE sp_fact_transfer_out()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_out', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_out', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
CALL sp_fact_transfer_out_create();
CALL sp_fact_transfer_out_insert();
CALL sp_fact_transfer_out_update();
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_create  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_create;


~-~-
CREATE PROCEDURE sp_fact_transfer_out_create()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_out_create', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_out_create', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

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
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_insert  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_insert;


~-~-
CREATE PROCEDURE sp_fact_transfer_out_insert()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_out_insert', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_out_insert', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
INSERT INTO mamba_fact_transfer_out (
                                  client_id,
                                  encounter_date,
                                  transfer_out_date
                                 )
SELECT person_id, obs_datetime, value_datetime from obs where concept_id=99165 and voided =0 ;

-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_fact_transfer_out_update  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_fact_transfer_out_update;


~-~-
CREATE PROCEDURE sp_fact_transfer_out_update()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_fact_transfer_out_update', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_fact_transfer_out_update', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN
-- $END
END;
~-~-


        
-- ---------------------------------------------------------------------------------------------
-- ----------------------  sp_data_processing_derived_transfers  ----------------------------
-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_data_processing_derived_transfers;


~-~-
CREATE PROCEDURE sp_data_processing_derived_transfers()
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1

    @message_text = MESSAGE_TEXT,
    @mysql_errno = MYSQL_ERRNO,
    @returned_sqlstate = RETURNED_SQLSTATE;

    CALL sp_mamba_etl_error_log_insert('sp_data_processing_derived_transfers', @message_text, @mysql_errno, @returned_sqlstate);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        completion_status          = 'ERROR',
        transaction_status         = 'COMPLETED',
        success_or_error_message   = CONCAT('sp_data_processing_derived_transfers', ', ', @mysql_errno, ', ', @message_text)
        WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

    RESIGNAL;
END;

-- $BEGIN

CALL sp_fact_transfer_in;
CALL sp_fact_transfer_out;
-- $END
END;
~-~-



-- ---------------------------------------------------------------------------------------------
-- ----------------------------  Setup the MambaETL Scheduler  ---------------------------------
-- ---------------------------------------------------------------------------------------------


-- Enable the event etl_scheduler
SET GLOBAL event_scheduler = ON;

~-~-

-- Drop/Create the Event responsible for firing up the ETL process
DROP EVENT IF EXISTS _mamba_etl_scheduler_event;

~-~-

-- Drop/Create the Event responsible for maintaining event logs at a max. 20 elements
DROP EVENT IF EXISTS _mamba_etl_scheduler_trim_log_event;

~-~-

-- Setup ETL configurations
CALL sp_mamba_etl_setup(?, ?, ?, ?, ?, ?, ?);

-- pass them from the runtime properties file

~-~-

CREATE EVENT IF NOT EXISTS _mamba_etl_scheduler_event
    ON SCHEDULE EVERY ? SECOND
        STARTS CURRENT_TIMESTAMP
    DO CALL sp_mamba_etl_schedule();

~-~-

-- Setup a trigger that trims record off _mamba_etl_schedule to just leave 20 latest records.
-- to avoid the table growing too big

 CREATE EVENT IF NOT EXISTS _mamba_etl_scheduler_trim_log_event
    ON SCHEDULE EVERY 3 HOUR
        STARTS CURRENT_TIMESTAMP
    DO CALL sp_mamba_etl_schedule_trim_log_event();

 ~-~-

