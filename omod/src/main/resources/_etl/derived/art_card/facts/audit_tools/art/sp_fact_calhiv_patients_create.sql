-- $BEGIN
CREATE TABLE mamba_fact_audit_tool_art_patients
(
    id                                     INT AUTO_INCREMENT,
    client_id                              INT NOT NULL,
    identifier                             VARCHAR(80) NULL,
    nationality                            VARCHAR(80) NULL,
    marital_status                         VARCHAR(80) NULL,
    birthdate                              DATE NULL,
    age                                   INT NULL,
    dead                                  BIT NOT NULL,
    gender                                VARCHAR(10) NULL,
    last_visit_date                       DATE NULL,
    return_date                           DATE NULL,
    client_status                         VARCHAR(50) NULL,
    transfer_out_date                      DATE NULL,
    current_regimen                        VARCHAR(255) NULL,
    arv_regimen_start_date                 DATE NULL,
    adherence                              VARCHAR(100) NULL,
    arv_days_dispensed                     INT NULL,
    hiv_viral_load_copies                  INT NULL,
    hiv_viral_collection_date              DATE NULL,
    new_sample_collection_date             DATE NULL,
    advanced_disease                       VARCHAR(255) NULL,
    family_planning_status                 VARCHAR(255) NULL,
    nutrition_assesment                    VARCHAR(100) NULL,
    nutrition_support                      VARCHAR(250) NULL,
    hepatitis_b_test_qualitative           VARCHAR(80) NULL,
    syphilis_test_result_for_partner       VARCHAR(80) NULL,
    cervical_cancer_screening              VARCHAR(250) NULL,
    tuberculosis_status                    VARCHAR(250) NULL,
    tpt_status                             VARCHAR(250) NULL,
    crag_test_results                      VARCHAR(250) NULL,
    WHO_stage                              VARCHAR(250) NULL,
    baseline_cd4                           INT NULL,
    baseline_regimen_start_date            DATE NULL,
    special_category                       VARCHAR(250) NULL,
    regimen_line                           INT NULL,
    health_education_setting               VARCHAR(250),
    pss_issues_identified                  VARCHAR(250),
    art_preparation                        VARCHAR(250) NULL,
    depression_status                      VARCHAR(250) NULL,
    gender_based_violance                  VARCHAR(250) NULL,
    health_education_disclosure            VARCHAR(250) NULL,
    ovc_screening                          VARCHAR(250) NULL,
    ovc_assessment                         VARCHAR(250) NULL,
    prevention_components                  VARCHAR(250) NULL,
    iac_sessions                           INT NULL,
    hivdr_results                          VARCHAR(250) NULL,
    date_hivr_results_recieved_at_facility DATE NULL,
    vl_after_iac                           VARCHAR(100) NULL,
    decision_outcome                       VARCHAR(250) NULL,
    duration_on_art                        INT NULL,
    side_effects                           VARCHAR(250) NULL,
    specimen_source                        VARCHAR(80),
    hiv_vl_date                            DATE NULL,
    children                               INT NULL,
    known_status_children                  INT NULL,
    partners                               INT NULL,
    known_status_partners                   INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

-- $END

