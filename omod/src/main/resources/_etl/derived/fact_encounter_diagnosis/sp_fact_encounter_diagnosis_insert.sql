-- $BEGIN
INSERT INTO mamba_fact_encounter_diagnosis
(
    diagnosis_id,
    encounter_id,
    patient_id,
    condition_id,
    certainty,
    dx_rank,
    diagnosis_coded,
    diagnosis_non_coded,
    diagnosis_coded_name,
    coded_diagnosis_name,
    diagnosis_display,
    diagnosis_name_locale,
    diagnosis_name_type,
    uuid,
    creator,
    date_created,
    changed_by,
    date_changed,
    voided,
    voided_by,
    date_voided,
    void_reason,
    form_namespace_and_path
)
SELECT
    ed.diagnosis_id,
    ed.encounter_id,
    ed.patient_id,
    ed.condition_id,
    ed.certainty,
    ed.dx_rank,
    ed.diagnosis_coded,
    ed.diagnosis_non_coded,
    ed.diagnosis_coded_name,

    COALESCE(cn_by_id.name, cn_pref.name, cn_any.name) AS coded_diagnosis_name,
    COALESCE(ed.diagnosis_non_coded, cn_by_id.name, cn_pref.name, cn_any.name) AS diagnosis_display,

    COALESCE(cn_by_id.locale, cn_pref.locale, cn_any.locale) AS diagnosis_name_locale,
    COALESCE(cn_by_id.concept_name_type, cn_pref.concept_name_type, cn_any.concept_name_type) AS diagnosis_name_type,

    ed.uuid,
    ed.creator,
    ed.date_created,
    ed.changed_by,
    ed.date_changed,
    ed.voided,
    ed.voided_by,
    ed.date_voided,
    ed.void_reason,
    ed.form_namespace_and_path
FROM conceptreview.encounter_diagnosis ed

LEFT JOIN conceptreview.concept_name cn_by_id
       ON cn_by_id.concept_name_id = ed.diagnosis_coded_name
      AND cn_by_id.voided = 0

LEFT JOIN (
    SELECT concept_id, name, locale, concept_name_type
    FROM conceptreview.concept_name
    WHERE voided = 0
      AND locale = 'en'
      AND locale_preferred = 1
) cn_pref
       ON cn_pref.concept_id = ed.diagnosis_coded

LEFT JOIN (
    SELECT cn1.concept_id, cn1.name, cn1.locale, cn1.concept_name_type
    FROM conceptreview.concept_name cn1
    JOIN (
        SELECT concept_id, MIN(concept_name_id) AS min_id
        FROM conceptreview.concept_name
        WHERE voided = 0
          AND locale = 'en'
        GROUP BY concept_id
    ) m
      ON m.concept_id = cn1.concept_id
     AND m.min_id = cn1.concept_name_id
) cn_any
       ON cn_any.concept_id = ed.diagnosis_coded

ON DUPLICATE KEY UPDATE
    encounter_id = VALUES(encounter_id),
    patient_id = VALUES(patient_id),
    condition_id = VALUES(condition_id),
    certainty = VALUES(certainty),
    dx_rank = VALUES(dx_rank),
    diagnosis_coded = VALUES(diagnosis_coded),
    diagnosis_non_coded = VALUES(diagnosis_non_coded),
    diagnosis_coded_name = VALUES(diagnosis_coded_name),
    coded_diagnosis_name = VALUES(coded_diagnosis_name),
    diagnosis_display = VALUES(diagnosis_display),
    diagnosis_name_locale = VALUES(diagnosis_name_locale),
    diagnosis_name_type = VALUES(diagnosis_name_type),
    uuid = VALUES(uuid),
    creator = VALUES(creator),
    date_created = VALUES(date_created),
    changed_by = VALUES(changed_by),
    date_changed = VALUES(date_changed),
    voided = VALUES(voided),
    voided_by = VALUES(voided_by),
    date_voided = VALUES(date_voided),
    void_reason = VALUES(void_reason),
    form_namespace_and_path = VALUES(form_namespace_and_path);
-- $END
