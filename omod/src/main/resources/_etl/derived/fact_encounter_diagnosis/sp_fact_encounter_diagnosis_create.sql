-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_fact_encounter_diagnosis
(
    id INT AUTO_INCREMENT,
    diagnosis_id INT NOT NULL,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    condition_id INT NULL,
    certainty VARCHAR(255) NOT NULL,
    dx_rank INT NOT NULL,
    diagnosis_coded INT NULL,
    diagnosis_non_coded VARCHAR(255) NULL,
    diagnosis_coded_name INT NULL,
    coded_diagnosis_name VARCHAR(255) NULL,
    diagnosis_display VARCHAR(255) NULL,
    diagnosis_name_locale VARCHAR(50) NULL,
    diagnosis_name_type VARCHAR(50) NULL,
    uuid CHAR(38) NOT NULL,
    creator INT NOT NULL,
    date_created DATETIME NOT NULL,
    changed_by INT NULL,
    date_changed DATETIME NULL,
    voided TINYINT(1) NOT NULL,
    voided_by INT NULL,
    date_voided DATETIME NULL,
    void_reason VARCHAR(255) NULL,
    form_namespace_and_path VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_mf_enc_dx_diagnosis_id (diagnosis_id)
);
-- $END
