-- $BEGIN
INSERT INTO mamba_fact_reattendance_monthly
(
  client_id,
  report_month,
  attended_visit_count
)
SELECT
  av.client_id,
  STR_TO_DATE(DATE_FORMAT(av.first_qualifying_encounter_datetime,'%Y-%m-01'),'%Y-%m-%d'),
  COUNT(DISTINCT av.visit_id)
FROM mamba_fact_attended_visit av
GROUP BY
  av.client_id,
  STR_TO_DATE(DATE_FORMAT(av.first_qualifying_encounter_datetime,'%Y-%m-01'),'%Y-%m-%d')
HAVING COUNT(DISTINCT av.visit_id) > 1
ON DUPLICATE KEY UPDATE
  attended_visit_count = VALUES(attended_visit_count);
-- $END
