-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_who_stage
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    encounter_date DATE NULL,
    stage         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_who_stage_client_id_index ON mamba_fact_patients_latest_who_stage (client_id);

-- $END

