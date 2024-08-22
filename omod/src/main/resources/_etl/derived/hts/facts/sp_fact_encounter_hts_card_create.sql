-- $BEGIN
CREATE TABLE mamba_fact_encounter_hts_card
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    encounter_date                        DATE         NULL,
    family_member_accompanying_patient    VARCHAR(255) NULL,
    other_specified_family_member         VARCHAR(255) NULL,
    delivery_model                        VARCHAR(255) NULL,
    counselling_approach                  VARCHAR(255) NULL,
    hct_entry_point                       VARCHAR(255) NULL,
    community_testing_point               VARCHAR(255) NULL,
    other_community_testing               VARCHAR(255) NULL,
    anc_visit_number                      VARCHAR(255) NULL,
    other_care_entry_point                VARCHAR(255) NULL,
    reason_for_testing                    VARCHAR(255) NULL,
    reason_for_testing_other_specify      TEXT NULL,
    special_category                      VARCHAR(255) NULL,
    other_special_category                TEXT NULL,
    hiv_first_time_tester                 VARCHAR(255) NULL,
    previous_hiv_tests_date               DATE NULL,
    months_since_first_hiv_aids_symptoms  VARCHAR(255),
    previous_hiv_test_results             VARCHAR(255),
    referring_health_facility             VARCHAR(255),
    no_of_times_tested_in_last_12_months  INT NULL,
    no_of_partners_in_the_last_12_months  INT NULL,
    partner_tested_for_hiv                VARCHAR(255) NULL,
    partner_hiv_test_result               VARCHAR(255) NULL,
    pre_test_counseling_done              VARCHAR(255) NULL,
    counselling_session_type              VARCHAR(255) NULL,
    current_hiv_test_result               VARCHAR(255) NULL,
    hiv_syphilis_duo                      VARCHAR(255) NULL,
    consented_for_blood_drawn_for_testing VARCHAR(255) NULL,
    hiv_recency_result                    VARCHAR(255) NULL,
    hiv_recency_viral_load_results        VARCHAR(255) NULL,
    hiv_recency_viral_load_qualitative DOUBLE NULL,
    hiv_recency_sample_id                 VARCHAR(255) NULL,
    hts_fingerprint_captured              VARCHAR(255) NULL,
    results_received_as_individual        VARCHAR(255) NULL,
    results_received_as_a_couple          VARCHAR(255) NULL,
    couple_results                        VARCHAR(255) NULL,
    tb_suspect                            VARCHAR(255) NULL,
    presumptive_tb_case_referred          VARCHAR(255) NULL,
    prevention_services_received          VARCHAR(255) NULL,
    other_prevention_services             VARCHAR(255) NULL,
    has_client_been_linked_to_care        VARCHAR(255) NULL,
    name_of_location_transferred_to       VARCHAR(255) NULL,
    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hts_card_client_id_index ON mamba_fact_encounter_hts_card (client_id);

CREATE INDEX
    mamba_fact_encounter_hts_encounter_id_index ON mamba_fact_encounter_hts_card (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_encounter_date_index ON mamba_fact_encounter_hts_card (encounter_date);
-- $END

