-- $BEGIN
INSERT INTO mamba_fact_audit_tool_art_patients (client_id,
                                                identifier,
                                                nationality,
                                                marital_status,
                                                birthdate,
                                                age,
                                                dead,
                                                gender,
                                                last_visit_date,
                                                return_date,
                                                client_status,
                                                transfer_out_date,
                                                current_regimen,
                                                arv_regimen_start_date,
                                                adherence,
                                                arv_days_dispensed,
                                                hiv_viral_load_copies,
                                                hiv_viral_collection_date,
                                                new_sample_collection_date,
                                                advanced_disease,
                                                family_planning_status,
                                                nutrition_assesment,
                                                nutrition_support,
                                                hepatitis_b_test_qualitative,
                                                syphilis_test_result_for_partner,
                                                cervical_cancer_screening,
                                                tuberculosis_status,
                                                tpt_status,
                                                crag_test_results,
                                                WHO_stage,
                                                baseline_cd4,
                                                baseline_regimen_start_date,
                                                special_category,
                                                regimen_line,
                                                health_education_setting,
                                                pss_issues_identified,
                                                art_preparation,
                                                depression_status,
                                                gender_based_violance,
                                                health_education_disclosure,
                                                ovc_screening,
                                                ovc_assessment,
                                                prevention_components,
                                                iac_sessions,
                                                hivdr_results,
                                                date_hivr_results_recieved_at_facility,
                                                vl_after_iac,
                                                decision_outcome,
                                                duration_on_art,
                                                side_effects,
                                                specimen_source,
                                                hiv_vl_date,
                                                children,
                                                known_status_children,
                                                partners,
                                                known_status_partners, age_group,
                                                cacx_date,
                                                cd4_date,
                                                cd4)
SELECT cohort.client_id,
       identifiers.identifier                                               AS identifier,
       nationality,
       marital_status,
       cohort.birthdate,
       cohort.age,
       cohort.dead,
       cohort.gender,
       last_visit_date,
       return_date,
       IF(dead = 0 AND (transfer_out_date IS NULL OR last_visit_date > transfer_out_date),
          IF(days_left_to_be_lost <= 0, 'Active(TX_CURR)', IF(
                  days_left_to_be_lost >= 1 AND days_left_to_be_lost <= 28, 'Lost(TX_CURR)',
                  IF(days_left_to_be_lost > 28, 'LTFU (TX_ML)', ''))), '')  AS client_status,
       transfer_out_date,
       current_regimen,
       arv_regimen_start_date,
       adherence,
       days                                                                 AS arv_days_dispensed,
       hiv_viral_load_copies,
       hiv_viral_collection_date,
       IF(order_date > hiv_viral_collection_date, order_date, NULL)         AS new_sample_collection_date,
       advanced_disease,
       mfplfp.status                                                        AS family_planning_status,
       mfplna.status                                                        AS nutrition_assesment,
       mfplnsmfplns.support                                                 AS nutrition_support,
       IF(sub_art_summary.hepatitis_b_test_qualitative = 'UNKNOWN', 'INDETERMINATE',
          sub_art_summary.hepatitis_b_test_qualitative)                     AS hepatitis_b_test_qualitative,
       syphilis_test_result_for_partner,
       cervical_cancer_screening,
       mfplts.status                                                        AS tuberculosis_status,
       mfplts2.status                                                       AS tpt_status,
       crag_test_results,
       stage                                                                AS WHO_stage,
       baseline_cd4,
       baseline_regimen_start_date,
       IF(IFNULL(special_category, '') = '', '', 'Priority population(PP)') AS special_category,
       IF(regimen = 90271, 1,
          IF(regimen = 90305, 2,
             IF(regimen = 162987, 3, 1)))                                   AS regimen_line,
       health_education_setting,
       pss_issues_identified,
       art_preparation,
       depression_status,
       gender_based_violance,
       health_education_disclosure,
       ovc_screening,
       ovc_assessment,
       prevention_components,
       IF(hiv_viral_load_copies >= 1000, IFNULL(sessions, 0), NULL)         AS iac_sessions,
       IF(hiv_viral_load_copies >= 1000, hivdr_results, NULL)               AS hivdr_results,
       date_hivr_results_recieved_at_facility,
       IF(hiv_viral_load_copies >= 1000, mfplvai.results, NULL)             as vl_after_iac,
       IF(hiv_viral_load_copies >= 1000, mfplido.decision, NULL)            AS decision_outcome,
       TIMESTAMPDIFF(MONTH, baseline_regimen_start_date, last_visit_date)   AS duration_on_art,
       sub_side_effects.medication_or_other_side_effects                    AS side_effects,
       specimen_type                                                        AS specimen_source,
       hiv_vl_date,
       mfplitc.no                                                           AS children,
       mfplitcs.no                                                          AS known_status_children,
       mfplitp.no                                                           AS partners,
       mfplitps.no                                                          AS known_status_partners,
       cohort.age_group                                                     AS age_group,
       sub_cervical_cancer_screening.encounter_date                         AS cacx_date,
       mfto_cd4.last_visit_date,
       mfto_cd4.test_value as cd4

FROM mamba_fact_art_patients cohort
         LEFT JOIN (SELECT mf_to.client_id
                    FROM mamba_fact_transfer_out mf_to
                             LEFT JOIN mamba_fact_transfer_in mf_ti ON mf_to.client_id = mf_ti.client_id
                    WHERE (transfer_out_date > transfer_in_date OR mf_ti.client_id IS NULL)) mfto
                   on mfto.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_nationality mfpn ON mfpn.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_marital_status mfpms ON mfpms.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_return_date mfplrd ON mfplrd.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_current_regimen mfplcr ON mfplcr.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_adherence mfpla ON mfpla.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_arv_days_dispensed mfpladd ON mfpladd.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_viral_load mfplvl ON mfplvl.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_viral_load_ordered mfplvlo ON mfplvlo.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_advanced_disease mfplad ON mfplad.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_family_planning mfplfp ON mfplfp.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_nutrition_assesment mfplna ON mfplna.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_nutrition_support mfplnsmfplns
                   ON mfplnsmfplns.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_tb_status mfplts ON mfplts.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_tpt_status mfplts2 ON mfplts2.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_who_stage who_stage ON who_stage.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_regimen_line mfplrl ON mfplrl.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_iac_sessions mfplis ON mfplis.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_vl_after_iac mfplvai ON mfplvai.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_iac_decision_outcome mfplido ON mfplido.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_index_tested_children mfplitc ON mfplitc.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_index_tested_children_status mfplitcs
                   ON mfplitcs.client_id = cohort.client_id

         LEFT JOIN mamba_fact_patients_latest_index_tested_partners mfplitp ON mfplitp.client_id = cohort.client_id
         LEFT JOIN mamba_fact_patients_latest_index_tested_partners_status mfplitps
                   ON mfplitps.client_id = cohort.client_id
         LEFT JOIN (SELECT client_id, MAX(encounter_datetime) AS last_visit_date
                    FROM mamba_flat_encounter_art_card
                    GROUP BY client_id) last_encounter ON last_encounter.client_id = cohort.client_id

         LEFT JOIN (SELECT b.client_id, syphilis_test_result_for_partner
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          WHERE syphilis_test_result_for_partner IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_syphilis_test_result_for_partner
                   ON sub_syphilis_test_result_for_partner.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, b.encounter_date, cervical_cancer_screening
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          WHERE cervical_cancer_screening IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_cervical_cancer_screening
                   ON sub_cervical_cancer_screening.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, crag_test_results
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          WHERE crag_test_results IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_crag_test_results
                   ON sub_crag_test_results.client_id = cohort.client_id
         LEFT JOIN (SELECT client_id,
                           baseline_cd4,
                           baseline_regimen_start_date,
                           special_category,
                           hepatitis_b_test_qualitative
                    FROM mamba_fact_encounter_hiv_art_summary
                    GROUP BY client_id) sub_art_summary ON sub_art_summary.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, health_education_setting
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE health_education_setting IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_health_education_setting
                   ON sub_health_education_setting.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, pss_issues_identified
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE pss_issues_identified IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_pss_issues_identified
                   ON sub_pss_issues_identified.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, art_preparation
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE art_preparation IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_art_preparation
                   ON sub_art_preparation.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, depression_status
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE depression_status IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_depression_status
                   ON sub_depression_status.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, gender_based_violance
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE gender_based_violance IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_gender_based_violance
                   ON sub_gender_based_violance.client_id = cohort.client_id
         LEFT JOIN (SELECT client_id, MAX(encounter_datetime) AS latest_encounter_date, health_education_disclosure
                    FROM mamba_fact_encounter_hiv_art_health_education
                    WHERE health_education_disclosure IS NOT NULL
                    GROUP BY client_id) sub_health_education_disclosure
                   ON sub_health_education_disclosure.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, ovc_screening
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE ovc_screening IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_ovc_screening
                   ON sub_ovc_screening.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, ovc_assessment
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE ovc_assessment IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_ovc_assessment
                   ON sub_ovc_assessment.client_id = cohort.client_id
         LEFT JOIN (SELECT b.client_id, prevention_components
                    FROM mamba_fact_encounter_hiv_art_health_education b
                             JOIN
                         (SELECT encounter_id, MAX(encounter_datetime) AS latest_encounter_date
                          FROM mamba_fact_encounter_hiv_art_health_education
                          WHERE prevention_components IS NOT NULL
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id) sub_prevention_components
                   ON sub_prevention_components.client_id = cohort.client_id

         LEFT JOIN (SELECT client_id, days_left_to_be_lost, transfer_out_date FROM mamba_fact_active_in_care) actives
                   ON actives.client_id = cohort.client_id
         LEFT JOIN mamba_fact_current_arv_regimen_start_date mfcarsd ON mfcarsd.client_id = cohort.client_id
         LEFT JOIN (SELECT a.client_id, hivdr_sample_collected
                    FROM mamba_fact_encounter_non_suppressed_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_date) AS hivdr_sample_collected_date
                          FROM mamba_fact_encounter_non_suppressed_card
                          WHERE hivdr_sample_collected IS NOT NULL
                          GROUP BY client_id) a ON a.client_id = b.client_id AND encounter_date =
                                                                                 hivdr_sample_collected_date) sub_hivdr_sample_collected
                   ON sub_hivdr_sample_collected.client_id = cohort.client_id
         LEFT JOIN (SELECT a.client_id, hivdr_results
                    FROM mamba_fact_encounter_non_suppressed_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_date) AS latest_encounter_date
                          FROM mamba_fact_encounter_non_suppressed_card
                          WHERE hivdr_results IS NOT NULL
                          GROUP BY client_id) a
                         ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_hivdr_results
                   ON sub_hivdr_results.client_id = cohort.client_id
         LEFT JOIN (SELECT pi.patient_id AS patientid, identifier
                    FROM patient_identifier pi
                             INNER JOIN patient_identifier_type pit
                                        ON pi.identifier_type = pit.patient_identifier_type_id AND
                                           pit.uuid = 'e1731641-30ab-102d-86b0-7a5022ba4115'
                    WHERE pi.voided = 0
                    GROUP BY pi.patient_id) identifiers ON cohort.client_id = identifiers.patientid
         LEFT JOIN (SELECT a.client_id, date_hivr_results_recieved_at_facility
                    FROM mamba_fact_encounter_non_suppressed_card b
                             JOIN
                         (SELECT client_id,
                                 MAX(encounter_date) AS latest_encounter_date
                          FROM mamba_fact_encounter_non_suppressed_card
                          WHERE date_hivr_results_recieved_at_facility IS NOT NULL
                          GROUP BY client_id) a
                         ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_date_hivr_results_recieved_at_facility
                   ON sub_date_hivr_results_recieved_at_facility.client_id = cohort.client_id

         LEFT JOIN (SELECT b.client_id, medication_or_other_side_effects
                    FROM mamba_fact_encounter_hiv_art_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_id) as encounter_id
                          FROM mamba_fact_encounter_hiv_art_card
                          GROUP BY client_id) a
                         ON a.encounter_id = b.encounter_id
                    WHERE medication_or_other_side_effects IS NOT NULL) sub_side_effects
                   ON sub_side_effects.client_id = cohort.client_id
         LEFT JOIN (SELECT a.client_id, hiv_vl_date
                    FROM mamba_fact_encounter_non_suppressed_card b
                             JOIN
                         (SELECT client_id, MAX(encounter_date) AS latest_encounter_date
                          FROM mamba_fact_encounter_non_suppressed_card
                          WHERE hiv_vl_date IS NOT NULL
                          GROUP BY client_id) a
                         ON a.client_id = b.client_id AND encounter_date = latest_encounter_date) sub_hiv_vl_date
                   ON sub_hiv_vl_date.client_id = cohort.client_id
         LEFT JOIN (SELECT a.client_id, last_visit_date, b.test_value
                    FROM mamba_fact_test_orders_rsults b
                             join
                         (SELECT client_id, MAX(encounter_datetime) as last_visit_date
                          from mamba_fact_test_orders_rsults
                          WHERE test_parameter = 'cd4'
                            and test_value is not null
                          GROUP BY client_id) a
                         ON a.client_id = b.client_id AND encounter_datetime = last_visit_date
                    WHERE test_parameter = 'cd4'
                      and test_value is not null) mfto_cd4
                   ON mfto_cd4.client_id = cohort.client_id
WHERE mfto.client_id IS NULL;
-- $END