-- $BEGIN
/*
  Update existing fact rows when the source encounter_diagnosis row changes (including voiding),
  and refresh the resolved concept name.
*/

UPDATE mamba_fact_encounter_diagnosis f
JOIN conceptreview.encounter_diagnosis ed
  ON ed.diagnosis_id = f.diagnosis_id

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

SET
    f.encounter_id = ed.encounter_id,
    f.patient_id = ed.patient_id,
    f.condition_id = ed.condition_id,
    f.certainty = ed.certainty,
    f.dx_rank = ed.dx_rank,
    f.diagnosis_coded = ed.diagnosis_coded,
    f.diagnosis_non_coded = ed.diagnosis_non_coded,
    f.diagnosis_coded_name = ed.diagnosis_coded_name,

    f.coded_diagnosis_name = COALESCE(cn_by_id.name, cn_pref.name, cn_any.name),
    f.diagnosis_display = COALESCE(ed.diagnosis_non_coded, cn_by_id.name, cn_pref.name, cn_any.name),

    f.diagnosis_name_locale = COALESCE(cn_by_id.locale, cn_pref.locale, cn_any.locale),
    f.diagnosis_name_type = COALESCE(cn_by_id.concept_name_type, cn_pref.concept_name_type, cn_any.concept_name_type),

    f.uuid = ed.uuid,
    f.creator = ed.creator,
    f.date_created = ed.date_created,
    f.changed_by = ed.changed_by,
    f.date_changed = ed.date_changed,

    f.voided = ed.voided,
    f.voided_by = ed.voided_by,
    f.date_voided = ed.date_voided,
    f.void_reason = ed.void_reason,

    f.form_namespace_and_path = ed.form_namespace_and_path
WHERE
    (
        (ed.date_changed IS NOT NULL AND (f.date_changed IS NULL OR ed.date_changed > f.date_changed))
        OR ed.voided <> f.voided
        OR ( (ed.diagnosis_coded IS NULL) <> (f.diagnosis_coded IS NULL) )
        OR (ed.diagnosis_coded <> f.diagnosis_coded)
        OR ( (ed.diagnosis_non_coded IS NULL) <> (f.diagnosis_non_coded IS NULL) )
        OR (ed.diagnosis_non_coded <> f.diagnosis_non_coded)
    );
-- $END
