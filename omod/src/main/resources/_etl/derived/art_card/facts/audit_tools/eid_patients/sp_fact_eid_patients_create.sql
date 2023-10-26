-- $BEGIN
CREATE TABLE mamba_fact_eid_patients
(
    id        INT AUTO_INCREMENT,
    client_id INT  NULL,
    EDD DATE DEFAULT NULL ,
    EID_NO VARCHAR(80) DEFAULT NULL ,
    EID_DOB DATE DEFAULT NULL ,
    EID_AGE INT DEFAULT NULL ,
    EID_WEIGHT INT DEFAULT NULL ,
    EID_NEXT_APPT DATE DEFAULT NULL,
    EID_FEEDING varchar(80) DEFAULT NULL,
    CTX_START varchar(80) DEFAULT NULL,
    CTX_AGE INT DEFAULT NULL,
    1ST_PCR_DATE DATE DEFAULT NULL,
    1ST_PCR_AGE INT DEFAULT NULL,
    1ST_PCR_RESULT varchar(80) DEFAULT NULL,
    1ST_PCR_RECEIVED DATE DEFAULT NULL,
    2ND_PCR_DATE DATE DEFAULT NULL,
    2ND_PCR_AGE INT DEFAULT NULL,
    2ND_PCR_RESULT varchar(80) DEFAULT NULL,
    2ND_PCR_RECEIVED DATE DEFAULT NULL,
    REPEAT_PCR_DATE DATE DEFAULT NULL,
    REPEAT_PCR_AGE INT DEFAULT NULL,
    REPEAT_PCR_RESULT varchar(80) DEFAULT NULL,
    REPEAT_PCR_RECEIVED DATE DEFAULT NULL,
    RAPID_PCR_DATE DATE DEFAULT NULL,
    RAPID_PCR_AGE INT DEFAULT NULL,
    RAPID_PCR_RESULT varchar(80) DEFAULT NULL,
    FINAL_OUTCOME varchar(80) DEFAULT NULL,
    LINKAGE_NO varchar(80) DEFAULT NULL,
    NVP_AT_BIRTH varchar(80) DEFAULT NULL,
    BREAST_FEEDING_STOPPED DATE DEFAULT  NULL,
    PMTCT_STATUS VARCHAR(250) DEFAULT NULL,
    PMTCT_ENROLLMENT_DATE DATE DEFAULT NULL,
    BABY INT DEFAULT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX
    mamba_fact_eid_patients_client_id_index ON mamba_fact_eid_patients (client_id);

CREATE INDEX
    mamba_fact_eid_patients_baby_id_index ON mamba_fact_eid_patients (BABY);

-- $END

