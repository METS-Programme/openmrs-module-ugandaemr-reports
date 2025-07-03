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