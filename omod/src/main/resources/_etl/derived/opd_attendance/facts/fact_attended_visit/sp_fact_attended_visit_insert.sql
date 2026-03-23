-- $BEGIN
INSERT INTO mamba_fact_attended_visit
(
  visit_id,
  client_id,
  visit_type_id,
  visit_start_datetime,
  visit_stop_datetime,
  first_qualifying_encounter_datetime,
  last_qualifying_encounter_datetime
)
SELECT
  v.visit_id,
  v.patient_id,
  v.visit_type_id,
  v.date_started,
  v.date_stopped,
  MIN(e.encounter_datetime),
  MAX(e.encounter_datetime)
FROM conceptreview.visit v
JOIN conceptreview.encounter e ON e.visit_id = v.visit_id
JOIN conceptreview.encounter_type et ON et.encounter_type_id = e.encounter_type
WHERE v.voided = 0
  AND e.voided = 0
  AND et.uuid NOT IN (
    '5021b1a1-e7f6-44b4-ba02-da2f2bcf8718',
    '181820aa-88c9-479b-9077-af92f5364329',
    'e22e39fd-7db2-45e7-80f1-60fa0d5a4378',
    '7b68d557-85ef-4fc8-b767-4fa4f5eb5c23',
    '044daI6d-f80e-48fe-aba9-037f241905Pe',
    '9fcfcc91-ad60-4d84-9710-11cc25258719',
    'a9f11592-22e7-45fc-904d-dfe24cb1fc67',
    'fa6f3ff5-b784-43fb-ab35-a08ab7dbf074',
    '1458b726-4a62-4444-be97-bb3e08c73745'
  )
GROUP BY
  v.visit_id,
  v.patient_id,
  v.visit_type_id,
  v.date_started,
  v.date_stopped
ON DUPLICATE KEY UPDATE
  client_id = VALUES(client_id);
-- $END
