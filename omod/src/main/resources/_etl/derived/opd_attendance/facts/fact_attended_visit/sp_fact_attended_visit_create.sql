-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_fact_attended_visit
(
    id INT AUTO_INCREMENT,
    visit_id INT NOT NULL,
    client_id INT NOT NULL,
    visit_type_id INT NULL,
    visit_start_datetime DATETIME NOT NULL,
    visit_stop_datetime DATETIME NULL,
    first_qualifying_encounter_datetime DATETIME NOT NULL,
    last_qualifying_encounter_datetime DATETIME NOT NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_mf_attended_visit_visit_id (visit_id)
);
-- $END
