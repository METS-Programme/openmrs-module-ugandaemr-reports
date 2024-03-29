-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_patient_demographics
(
    id         INT AUTO_INCREMENT,
    patient_id INT NOT NULL,
    birthdate  DATE NULL,
    age        INT NULL,
    gender     VARCHAR(10) NULL,
    dead       BIT NOT NULL DEFAULT 0,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_patient_demos_patient_id_index ON mamba_fact_patients_latest_patient_demographics (patient_id);

-- $END

