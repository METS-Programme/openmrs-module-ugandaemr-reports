-- $BEGIN
CREATE TABLE mamba_fact_encounter_anc_card
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    encounter_date                        DATETIME         NULL,
    cd4                            DOUBLE       NULL,
    where_                        TEXT         NULL,
    parity                         DOUBLE       NULL,
    gravida                        DOUBLE       NULL,
    art_codes                      VARCHAR(250) NULL,
    stk_given                      VARCHAR(250) NULL,
    ref_in_no                  TEXT         NULL,
    viral_load                     DOUBLE       NULL,
    return_date                    DATE         NULL,
    unit_tb_no                  TEXT         NULL,
    woman_hbsag                    VARCHAR(250) NULL,
    anc_1_timimg                   VARCHAR(250) NULL,
    partners_age                   DOUBLE       NULL,
    risk_factors                   TEXT         NULL,
    client_number                  DOUBLE       NULL,
    gbv_risk_type                  VARCHAR(250) NULL,
    gestation_age                  DOUBLE       NULL,
    referral_type                  VARCHAR(250) NULL,
    serial_number                  TEXT         NULL,
    woa_scan_done                  DOUBLE       NULL,
    linkage_art_no              TEXT         NULL,
    screened_for_tb                VARCHAR(250) NULL,
    anc_visit_number               VARCHAR(250) NULL,
    partner_clinic_no           TEXT         NULL,
    who_clinical_stage             VARCHAR(250) NULL,
    hiv_viral_load_date            DATE         NULL,
    partners_stk_result            VARCHAR(250) NULL,
    emtct_risk_assesment           VARCHAR(250) NULL,
    other_treatment_given          TEXT         NULL,
    partner_linked_to_art          VARCHAR(250) NULL,
    womans_initial_result          VARCHAR(250) NULL,
    infant_arv_prophylaxis         VARCHAR(250) NULL,
    client_has_presumptive_tb      VARCHAR(250) NULL,
    date_cd4_sample_collected      DATE         NULL,
    family_planning_counseling     VARCHAR(250) NULL,
    reason_for_next_appointment    VARCHAR(250) NULL,
    complications_and_risk_factors TEXT         NULL,
    infant_and_young_child_feeding VARCHAR(250) NULL,
    maternal_nutrition_counselling VARCHAR(250) NULL,
    womans_syphilis_hep_b_results      VARCHAR(250) NULL,
    other_reason_for_next_appointment      TEXT         NULL,
    partners_syphilis_hep_b_results    VARCHAR(250) NULL,
    findings_after_clinical_assessment     TEXT         NULL,
    partners_test_for_verification_results VARCHAR(250) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_anc_card_client_id_index ON mamba_fact_encounter_anc_card (client_id);

CREATE INDEX
    mamba_fact_encounter_anc_encounter_id_index ON mamba_fact_encounter_anc_card (encounter_id);

CREATE INDEX
    mamba_fact_encounter_anc_card_encounter_date_index ON mamba_fact_encounter_anc_card (encounter_date);
-- $END

