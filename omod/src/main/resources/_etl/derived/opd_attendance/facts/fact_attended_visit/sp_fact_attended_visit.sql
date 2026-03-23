-- $BEGIN
CALL sp_fact_attended_visit_create();
CALL sp_fact_attended_visit_insert();
CALL sp_fact_attended_visit_update();
-- $END
