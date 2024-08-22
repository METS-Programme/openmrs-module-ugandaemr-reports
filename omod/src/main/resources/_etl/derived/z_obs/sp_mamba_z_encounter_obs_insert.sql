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