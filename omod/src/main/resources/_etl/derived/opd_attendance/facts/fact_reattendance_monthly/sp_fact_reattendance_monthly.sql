-- $BEGIN
CALL sp_fact_reattendance_monthly_create();
CALL sp_fact_reattendance_monthly_insert();
CALL sp_fact_reattendance_monthly_update();
-- $END
