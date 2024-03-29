-- $BEGIN
INSERT INTO mamba_fact_encounter_hiv_art (encounter_id,
                                          client_id,
                                          encounter_date,
                                          hemoglobin, malnutrition, method_of_family_planning, oedema, cd4_panel,
                                          cd4_percent, hiv_viral_load, historical_drug_start_date,
                                          historical_drug_stop_date, current_drugs_used, tests_ordered,
                                          number_of_weeks_pregnant, medication_orders, viral_load_qualitative,
                                          hepatitis_b_test_qualitative, mid_upper_arm_circumference,
                                          medication_strength, register_serial_number, duration_units,
                                          systolic_blood_pressure, diastolic_blood_pressure, pulse, temperature, weight,
                                          height, return_visit_date, respiratory_rate, head_circumference, cd4_count,
                                          estimated_date_of_confinement, pmtct, pregnant, scheduled_patient_visit,
                                          entry_point_into_hiv_care, who_hiv_clinical_stage,
                                          name_of_location_transferred_to, tuberculosis_status,
                                          tuberculosis_treatment_start_date, adherence_to_cotrim,
                                          arv_adherence_assessment_code, reason_for_missing_arv,
                                          medication_or_other_side_effects, history_of_functional_status, body_weight,
                                          family_planning_status, symptom_diagnosis, address,
                                          date_positive_hiv_test_confirmed, treatment_supporter_telephone_number,
                                          transferred_out, tuberculosis_treatment_stop_date, current_arv_regimen,
                                          art_duration, current_art_duration, antenatal_number,
                                          mid_upper_arm_circumference_code, district_tuberculosis_number,
                                          opportunistic_infection, trimethoprim_days_dispensed,
                                          other_medications_dispensed, arv_regimen_days_dispensed, trimethoprim_dosage,
                                          ar_regimen_dose, nutrition_support_and_infant_feeding, baseline_regimen,
                                          baseline_weight, baseline_stage, baseline_cd4, baseline_pregnancy,
                                          name_of_family_member, age_of_family_member, family_member_set, hiv_test,
                                          hiv_test_facility, other_side_effects, other_tests_ordered,
                                          care_entry_point_set, treatment_supporter_tel_no,
                                          other_reason_for_missing_arv, current_regimen_other, treatment_supporter_name,
                                          cd4_classification_for_infants, baseline_regimen_start_date,
                                          baseline_regimen_set, transfer_out_date, transfer_out_set,
                                          health_education_disclosure, other_referral_ordered, age_in_months,
                                          test_result_type, lab_result_txt, lab_result_set, counselling_session_type,
                                          cotrim_given, eid_visit_1_appointment_date, feeding_status_at_eid_visit_1,
                                          counselling_approach, current_hiv_test_result, results_received_as_a_couple,
                                          tb_suspect, baseline_lactating, inh_dosage, inh_days_dispensed, age_unit,
                                          syphilis_test_result, syphilis_test_result_for_partner,
                                          ctx_given_at_eid_visit_1, nvp_given_at_eid_visit_1, eid_visit_1_muac,
                                          medication_duration, clinical_impression_comment, reason_for_appointment,
                                          medication_history, quantity_of_medication,
                                          tb_with_rifampin_resistance_checking, specimen_sources,
                                          eid_immunisation_codes, clinical_assessment_codes,
                                          refiil_of_art_for_the_mother, development_milestone, pre_test_counseling_done,
                                          hct_entry_point, linked_to_care, estimated_gestational_age, eid_concept_type,
                                          hiv_viral_load_date, relationship_to_patient, other_reason_for_appointment,
                                          nutrition_assessment, art_pill_balance, differentiated_service_delivery,
                                          stable_in_dsdm, reason_for_testing, previous_hiv_tests_date,
                                          milligram_per_meter_squared, hiv_testing_service_delivery_model,
                                          hiv_syphillis_duo, prevention_services_received, hiv_first_time_tester,
                                          previous_hiv_test_results, results_received_as_individual,
                                          health_education_setting, health_edu_intervation_approaches,
                                          health_education_depression_status, ovc_screening, art_preparation_readiness,
                                          ovc_assessment, phdp_components, tpt_start_date, tpt_completion_date,
                                          advanced_disease_status, family_member_hiv_status, tpt_status,
                                          rpr_test_results, crag_test_results, tb_lam_results, gender_based_violance,
                                          dapsone_ctx_medset, tuberculosis_medication_set, fluconazole_medication_set,
                                          cervical_cancer_screening, intention_to_conceive, viral_load_test,
                                          genexpert_test, tb_microscopy_results, tb_microscopy_test, tb_lam, rpr_test,
                                          crag_test, arv_med_set, quantity_unit, tpt_side_effects, split_into_drugs,
                                          lab_number, other_drug_dispensed_set, test, test_result, other_tests,
                                          refill_point_code, next_return_date_at_facility)
SELECT encounter_id,
       client_id,
       encounter_date,
       hemoglobin,
       malnutrition,
       method_of_family_planning,
       oedema,
       cd4_panel,
       cd4_percent,
       hiv_viral_load,
       historical_drug_start_date,
       historical_drug_stop_date,
       current_drugs_used,
       tests_ordered,
       number_of_weeks_pregnant,
       medication_orders,
       viral_load_qualitative,
       hepatitis_b_test_qualitative,
       mid_upper_arm_circumference,
       medication_strength,
       register_serial_number,
       duration_units,
       systolic_blood_pressure,
       diastolic_blood_pressure,
       pulse,
       temperature,
       weight,
       height,
       return_visit_date,
       respiratory_rate,
       head_circumference,
       cd4_count,
       estimated_date_of_confinement,
       pmtct,
       pregnant,
       scheduled_patient_visit,
       entry_point_into_hiv_care,
       who_hiv_clinical_stage,
       name_of_location_transferred_to,
       tuberculosis_status,
       tuberculosis_treatment_start_date,
       adherence_to_cotrim,
       arv_adherence_assessment_code,
       reason_for_missing_arv,
       medication_or_other_side_effects,
       history_of_functional_status,
       body_weight,
       family_planning_status,
       symptom_diagnosis,
       address,
       date_positive_hiv_test_confirmed,
       treatment_supporter_telephone_number,
       transferred_out,
       tuberculosis_treatment_stop_date,
       current_arv_regimen,
       art_duration,
       current_art_duration,
       antenatal_number,
       mid_upper_arm_circumference_code,
       district_tuberculosis_number,
       opportunistic_infection,
       trimethoprim_days_dispensed,
       other_medications_dispensed,
       arv_regimen_days_dispensed,
       trimethoprim_dosage,
       ar_regimen_dose,
       nutrition_support_and_infant_feeding,
       baseline_regimen,
       baseline_weight,
       baseline_stage,
       baseline_cd4,
       baseline_pregnancy,
       name_of_family_member,
       age_of_family_member,
       family_member_set,
       hiv_test,
       hiv_test_facility,
       other_side_effects,
       other_tests_ordered,
       care_entry_point_set,
       treatment_supporter_tel_no,
       other_reason_for_missing_arv,
       current_regimen_other,
       treatment_supporter_name,
       cd4_classification_for_infants,
       baseline_regimen_start_date,
       baseline_regimen_set,
       transfer_out_date,
       transfer_out_set,
       health_education_disclosure,
       other_referral_ordered,
       age_in_months,
       test_result_type,
       lab_result_txt,
       lab_result_set,
       counselling_session_type,
       cotrim_given,
       eid_visit_1_appointment_date,
       feeding_status_at_eid_visit_1,
       counselling_approach,
       current_hiv_test_result,
       results_received_as_a_couple,
       tb_suspect,
       baseline_lactating,
       inh_dosage,
       inh_days_dispensed,
       age_unit,
       syphilis_test_result,
       syphilis_test_result_for_partner,
       ctx_given_at_eid_visit_1,
       nvp_given_at_eid_visit_1,
       eid_visit_1_muac,
       medication_duration,
       clinical_impression_comment,
       reason_for_appointment,
       medication_history,
       quantity_of_medication,
       tb_with_rifampin_resistance_checking,
       specimen_sources,
       eid_immunisation_codes,
       clinical_assessment_codes,
       refiil_of_art_for_the_mother,
       development_milestone,
       pre_test_counseling_done,
       hct_entry_point,
       linked_to_care,
       estimated_gestational_age,
       eid_concept_type,
       hiv_viral_load_date,
       relationship_to_patient,
       other_reason_for_appointment,
       nutrition_assessment,
       art_pill_balance,
       differentiated_service_delivery,
       stable_in_dsdm,
       reason_for_testing,
       previous_hiv_tests_date,
       milligram_per_meter_squared,
       hiv_testing_service_delivery_model,
       hiv_syphillis_duo,
       prevention_services_received,
       hiv_first_time_tester,
       previous_hiv_test_results,
       results_received_as_individual,
       health_education_setting,
       health_edu_intervation_approaches,
       health_education_depression_status,
       ovc_screening,
       art_preparation_readiness,
       ovc_assessment,
       phdp_components,
       tpt_start_date,
       tpt_completion_date,
       advanced_disease_status,
       family_member_hiv_status,
       tpt_status,
       rpr_test_results,
       crag_test_results,
       tb_lam_results,
       gender_based_violance,
       dapsone_ctx_medset,
       tuberculosis_medication_set,
       fluconazole_medication_set,
       cervical_cancer_screening,
       intention_to_conceive,
       viral_load_test,
       genexpert_test,
       tb_microscopy_results,
       tb_microscopy_test,
       tb_lam,
       rpr_test,
       crag_test,
       arv_med_set,
       quantity_unit,
       tpt_side_effects,
       split_into_drugs,
       lab_number,
       other_drug_dispensed_set,
       test,
       test_result,
       other_tests,
       refill_point_code,
       next_return_date_at_facility
FROM mamba_flat_encounter_art_card as fu;
-- $END