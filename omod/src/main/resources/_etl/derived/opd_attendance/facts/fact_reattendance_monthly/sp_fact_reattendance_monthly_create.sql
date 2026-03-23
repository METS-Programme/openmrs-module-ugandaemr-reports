-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_fact_reattendance_monthly
(
    id INT AUTO_INCREMENT,
    client_id INT NOT NULL,
    report_month DATE NOT NULL,
    attended_visit_count INT NOT NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_mf_reattendance_month (client_id, report_month)
);
-- $END
