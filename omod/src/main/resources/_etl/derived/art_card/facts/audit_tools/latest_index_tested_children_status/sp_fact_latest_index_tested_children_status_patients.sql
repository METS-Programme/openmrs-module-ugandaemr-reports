-- $BEGIN
CALL sp_fact_latest_index_tested_children_status_patients_create();
CALL sp_fact_latest_index_tested_children_status_patients_insert();
CALL sp_fact_latest_index_tested_children_status_patients_update();
-- $END