package org.openmrs.module.ugandaemrreports.reporting.metadata;

/**
 * Metadata for reporting functionality
 */
public class Metadata {

    public static class Concept {
//        public final static String PREGNANT = "dcd695dc-30ab-102d-86b0-7a5022ba4115";
        public final static String YES_CIEL = "1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public final static String YES_WHO = "dcd695dc-30ab-102d-86b0-7a5022ba4115";
        public final static String TRANSFER_IN = "ea730d69-7eec-486a-aaf2-54f8bab5a44c";
        public final static String CARE_ENTRY_POINT = "dcdfe3ce-30ab-102d-86b0-7a5022ba4115";
        public final static String CARE_ENTRY_POINT_EMTCT = "dcd7e8e5-30ab-102d-86b0-7a5022ba4115";
        public final static String RETURN_VISIT_DATE = "dcac04cf-30ab-102d-86b0-7a5022ba4115";


        public final static String ART_START_DATE = "ab505422-26d9-41f1-a079-c3d222000440";
        public final static String PREGNANT_AT_ART_START = "b253be65-0155-4b43-ad15-88bc797322c9";
        public final static String LACTATING_AT_ART_START = "ab7bb4db-1a54-4225-b71c-d8e138b471e9";

        public final static String CURRENT_REGIMEN = "dd2b0b4d-30ab-102d-86b0-7a5022ba4115";

        public final static String CHILDREN_FIRST_LINE_REGIMEN = "dd2b361c-30ab-102d-86b0-7a5022ba4115,dd2b3eee-30ab-102d-86b0-7a5022ba4115,dd2b84c5-30ab-102d-86b0-7a5022ba4115,dd2b8b27-30ab-102d-86b0-7a5022ba4115,25b0b83c-a7b8-4663-b727-0c03c982bab2,f99ef0fa-b299-4573-ae31-f4d09b1b69d5,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,6cdbfee8-87bf-406c-8dc3-3a22d95e952c,583a954b-0cd5-4b69-aef6-87c281e03a55,14c56659-3d4e-4b88-b3ff-e2d43dbfb865,dcd68a88-30ab-102d-86b0-7a5022ba4115"; // Last Concept is Other Specify which includes any unknown regimens

        public final static String ADULT_FIRST_LINE_REGIMEN = "dd2b361c-30ab-102d-86b0-7a5022ba4115,dd2b3eee-30ab-102d-86b0-7a5022ba4115,dd2b84c5-30ab-102d-86b0-7a5022ba4115,dd2b8b27-30ab-102d-86b0-7a5022ba4115,012a1378-b005-4793-8ea0-d01fceea769d,25b0b83c-a7b8-4663-b727-0c03c982bab2,f99ef0fa-b299-4573-ae31-f4d09b1b69d5,20bcbf56-2784-4bf0-a6b4-23ba43764163,b3bd1d21-aa40-4e8a-959f-2903b358069c,6cdbfee8-87bf-406c-8dc3-3a22d95e952c,583a954b-0cd5-4b69-aef6-87c281e03a55,,a58d12c5-abc2-4575-8fdb-f30960f348fc,6cc36637-596a-4426-92cf-170f76ea437d,a779d984-9ccf-4424-a750-47506bf8212b,dcd68a88-30ab-102d-86b0-7a5022ba4115"; // Last Concept is Other Specify which includes any unknown drugs

        public final static String CHILDREN_SECOND_LINE_REGIMEN = "dd2b3eee-30ab-102d-86b0-7a5022ba4115,dd2b9181-30ab-102d-86b0-7a5022ba4115,dd2b97d3-30ab-102d-86b0-7a5022ba4115,dd2b9e11-30ab-102d-86b0-7a5022ba4115,b06bdb63-dd08-4b80-af5a-d17f6b3062a5,4b9c639e-3d06-4f2a-9c34-dd07e44f4fa6,4a608d68-516f-44d2-9e0b-1783dc0d870e,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,f00e5ff7-73bb-4385-8ee1-ea7aa772ec3e,faf13d3c-7ca8-4995-ab29-749f3960b83d,d4393bd0-3a9e-4716-8968-1057c58c32bc,6cdbfee8-87bf-406c-8dc3-3a22d95e952c,583a954b-0cd5-4b69-aef6-87c281e03a55,fe78521e-eb7a-440f-912d-0eb9bf2d4b2c,14c56659-3d4e-4b88-b3ff-e2d43dbfb865";

        public final static String ADULT_SECOND_LINE_REGIMEN = "dd2b452c-30ab-102d-86b0-7a5022ba4115,dd2b4d82-30ab-102d-86b0-7a5022ba4115,dd2b9181-30ab-102d-86b0-7a5022ba4115,dd2b97d3-30ab-102d-86b0-7a5022ba4115,dd2b9e11-30ab-102d-86b0-7a5022ba4115,b06bdb63-dd08-4b80-af5a-d17f6b3062a5,4b9c639e-3d06-4f2a-9c34-dd07e44f4fa6,4a608d68-516f-44d2-9e0b-1783dc0d870e,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,834625e9-3273-445e-be99-2beca081702c,942e427c-7a3b-49b6-97f3-5cdbfeb8d0e3,29439504-5f5d-49ac-b8e4-258adc08c67a,f00e5ff7-73bb-4385-8ee1-ea7aa772ec3e,faf13d3c-7ca8-4995-ab29-749f3960b83d,d4393bd0-3a9e-4716-8968-1057c58c32bc,fe78521e-eb7a-440f-912d-0eb9bf2d4b2c,25186d70-ed8f-486c-83e5-fc31cbe95630";

        public final static String THIRD_LINE_REGIMEN = "607ffca4-6f15-4e85-b0a5-8226d4f25592,4c27fe52-98fd-4068-9e81-ea9caba4b583";

        public final static String INH_DOSAGE = "be211d29-1507-4e2e-9906-4bfeae4ddc1f";
        public final static String CPT_DAPSONE_PILLS_DISPENSED = "38801143-01ac-4328-b0e1-a7b23c84c8a3";
        public static final String ASSESSED_FOR_TB = "dce02aa1-30ab-102d-86b0-7a5022ba4115";

        public static final String DIAGNOSED_WITH_TB = "dcdac38b-30ab-102d-86b0-7a5022ba4115";
        public static final String TB_TREATMENT_START_DATE = "dce02eca-30ab-102d-86b0-7a5022ba4115";
        public static final String ON_TB_TREATMENT = "dcdaa6b4-30ab-102d-86b0-7a5022ba4115";
        public static final String ASSESSED_FOR_MALNUTRITION = "dc655734-30ab-102d-86b0-7a5022ba4115";
        public static final String PREVIOUS_HIV_TEST_RESULTS = "49ba801d-b6ff-47cd-8d29-e0ac8649cb7d";

        public static final String FAMILY_PLANNING_METHOD = "dc7620b3-30ab-102d-86b0-7a5022ba4115";
        public static final String COUNSELING_SESSION_TYPE = "b92b1777-4356-49b2-9c83-a799680dc7d4";
        public static final String PRETEST_COUNSELING_DONE = "193039f1-c378-4d81-bb72-653b66c69914";
        public static final String CURRENT_HIV_TEST_RESULTS = "3d292447-d7df-417f-8a71-e53e869ec89d";
        public static final String TIMES_TESTED_IN_LAST_12_MONTHS = "8037192e-8f0c-4af3-ad8d-ccd1dd6880ba";
        public static final String HIV_TEST = "d6522d62-093d-4157-a9d3-9359d1a33480";
        public static final String FIRST_HIV_TEST = "2766c090-c057-44f2-98f0-691b6d0336dc";
        public static final String RECEIVED_HIV_TEST_RESULTS = "3437ae80-bcc5-41e2-887e-d56999a1b467";
        public static final String RECEIVED_HIV_TEST_RESULTS_AS_COUPLE = "2aa9f0c1-3f7e-49cd-86ee-baac0d2d5f2d";
        public static final String COUPLE_RESULTS = "94a5bd0a-b79d-421e-ab71-8e382eed100f";
        public static final String CONCORDANT_POSITIVE = "799fe713-c665-463a-ae6f-3c9d539eff15";
        public static final String HIV_POSITIVE = "dcdf4241-30ab-102d-86b0-7a5022ba4115";
        public static final String TB_SUSPECT = "b80f04a4-1559-42fd-8923-f8a6d2456a04";
        public static final String POST_EXPOSURE_PROPHYLAXIS = "966db6f2-a9f2-4e47-bba2-051467c77c17";
        public static final String HCT_ENTRY_POINT = "720a1e85-ea1c-4f7b-a31e-cb896978df79";
        public static final String FACILITY_BASED = "ecb88326-0a3f-44a5-9bbf-df4bfc3239e1";
        public static final String COMMUNITY_TESTING_POINT = "4f4e6d1d-4343-42cc-ba47-2319b8a84369";
        public static final String WORK_PLACE = "6080ad91-fc24-49dd-aa5d-3ce7c1b4ce2e";
        public static final String HBCT = "e8dd38d8-28a2-4c09-8cb4-f93f112279ea";
        public static final String DIC = "b928b2e7-3ab4-4924-b730-5a13d8305408";
        public static final String HOT_SPOT = "29d1a223-4ce4-43df-96fc-6d53c0e022b1";
        public static final String OTHER_COMMUNITY_TESTING_POINTS = "16820069-b4bf-4c47-9efc-408746e1636b";
        public static final String COUNSELLING_APPROACH = "ff820a28-1adf-4530-bf27-537bfa9ce0b2";
        public static final String HTC_DELIVERY_MODEL = "46648b1d-b099-433b-8f9c-3815ff1e0a0f";
        public static final String PITC = "74120d00-5483-4148-acc3-00647dc13add";
        public static final String CICT = "a0857c20-9dc3-410f-9fda-d8fde202b727";
        public static final String HIV_RECENCY_RESULT = "141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        public static final String SPOUSE_TESTED_HIV = "adc0b1a1-39cf-412b-9ab0-28ec0f731220";
        public static final String RECENT = "141518BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        public static final String LONG_TERM = "141519BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        public static final String SPECIAL_CATEGORIES = "927563c5-cb91-4536-b23c-563a72d3f829";
        public static final String PRISONERS = "162277AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PWIDs = "160666AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String UNIFORMED_MEN = "165125AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String MIGRANT_WORKERS = "165126AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TRUCKER_DRIVERS = "162198AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String FISHER_FOLKS = "159674AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String REFUGEES = "165127AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PREGNANT_WOMEN = "dcda5179-30ab-102d-86b0-7a5022ba4115";
        public static final String BREAST_FEEDING_WOMEN = "9e5ac0a8-6041-4feb-8c07-fe522ef5f9ab";
        public static final String AGYW = "165132AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PWDs = "162558AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        public static final String OPD = "160542AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ART = "165047AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TB_CLINIC ="165048AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String NUTRITION_UNIT = "11c12455-2f54-4bb5-b051-0ecfd4a5fe96";
        public static final String STI_UNIT = "dcd98f72-30ab-102d-86b0-7a5022ba4115";
        public static final String YCC_UNIT = "e9469d61-b0c3-4785-81c6-057c7bc099fc";
        public static final String ANC = "164983AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String MATERNITY = "160456AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PNC = "165046AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SMC = "409eae6b-9457-4896-b5fa-2667ad5ceffc";
        public static final String DISCORDANT_COUPLE = "dcd6774e-30ab-102d-86b0-7a5022ba4115";
        public static final String REASON_FOR_TESTING = "2afe1128-c3f6-4b35-b119-d17b9b9958ed";
        public static final String EID = "164981AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHERS = "dcd68a88-30ab-102d-86b0-7a5022ba4115";
        public static final String MARPS = "b2706f7a-c4b8-4cd4-ad97-59396cf5bb3d";
        public static final String LINKED_TO_CARE = "3d620422-0641-412e-ab31-5e45b98bc459";
        public static final String CD4_COUNT = "dcbcba2c-30ab-102d-86b0-7a5022ba4115";
        public static final String PARTNER_HIV_TEST_RESULT = "ee802cf2-295b-4297-b53c-205f794294a5";
        public static final String HIV_NEGATIVE = "dcdf4653-30ab-102d-86b0-7a5022ba4115";
        public static final String TYPE_OF_PATIENT = "162728AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String NEW_ENCOUNTER = "1597AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String REPEAT_ENCOUNTER = "164142AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String REFERRAL_NUMBER = "c9159851-557b-4c09-8942-65b7989aa20a";
        public static final String TRANSFER_IN_NUMBER = "9bf35577-f802-437d-8ca3-84ab15191d6e";
        public static final String OPD_DIAGNOSIS = "ddab2f41-b188-4fde-b2e2-b6f0c9b47e0c";
        public static final String ACUTE_FLACCID_PARALYSIS = "160426AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ANIMAL_BITE = "dc68b0b3-30ab-102d-86b0-7a5022ba4115";
        public static final String CHOLERA = "dc695167-30ab-102d-86b0-7a5022ba4115";
        public static final String DYSENTERY = "dc546780-30ab-102d-86b0-7a5022ba4115";
        public static final String GUINEA_WORM = "137458AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CIEL_MALARIA = "116128AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CLINICAL_MALARIA = "dc668353-30ab-102d-86b0-7a5022ba4115";
        public static final String CONFIRMED_MALARIA = "160148AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String MEASLES = "dc6540eb-30ab-102d-86b0-7a5022ba4115";
        public static final String BACTERIAL_MENINGITIS = "dc91c6c9-30ab-102d-86b0-7a5022ba4115";
        public static final String NEONATAL_TETANUS = "124954AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PLAGUE = "114120AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String YELLOW_FEVER = "122759AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_VIRAL_HEMORRHAGIC_FEVERS = "123112AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SEVERE_ACUTE_RESPIRATORY_INFECTION = "113021AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ADVERSE_EVENTS_FOLLOWING_IMMUNIZATION = "151956AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TYPHOID_FEVER = "dc673ab9-30ab-102d-86b0-7a5022ba4115";
        public static final String PRESUMPTIVE_MDR_TB_CASES = "160039AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_EMERGING_INFECTIOUS_DISEASES = "b498df96-0e4a-4eaf-9b42-dacf9e486cba";
        public static final String TYPE_OF_MALARIA_TEST = "18f97e54-9f02-437e-bb67-35761f04531c";
        public static final String MALARIAL_SMEAR = "dc54c43f-30ab-102d-86b0-7a5022ba4115";
        public static final String RAPID_TEST_FOR_MALARIA = "1643AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String MALARIA_TEST_RESULT = "d6205784-0634-4a2b-b561-a51ed2668bb7";
        public static final String POSITIVE = "dc866728-30ab-102d-86b0-7a5022ba4115";
        public static final String NEGATIVE = "dc85aa72-30ab-102d-86b0-7a5022ba4115";
        public static final String ACUTE_DIARRHOEA = "149856AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PERSISTENT_DIARRHOEA = "5018AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String URETHRAL_DISCHARGES = "dcd041e4-30ab-102d-86b0-7a5022ba4115";
        public static final String GENITAL_ULCERS = "ab684ea7-9ad5-4efa-9210-f324e0dd1fa6";
        public static final String SEXUALLY_TRANSMITTED_INFECTION_DUE_TO_SEXUAL_GENDER_BASED_VIOLENCE = "ef4094f3-563c-48f6-bbe4-9c270744acde";
        public static final String OTHER_SEXUALLY_TRANSMITTED_INFECTIONS = "112992AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String URINARY_TRACT_INFECTIONS = "dc651994-30ab-102d-86b0-7a5022ba4115";
        public static final String INTESTINAL_WORMS = "199AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String HEMATOLOGICAL_MENINGITIS = "9d913f9a-0a69-4dd6-a033-fedcbc0a3204";
        public static final String OTHER_TYPES_OF_MENINGITIS = "dc65303e-30ab-102d-86b0-7a5022ba4115";
        public static final String NO_PNEUMONIA__COUGH_OR_COLD = "dc662180-30ab-102d-86b0-7a5022ba4115";
        public static final String PNEUMONIA = "dc54f5de-30ab-102d-86b0-7a5022ba4115";
        public static final String SKIN_DISEASES = "dc658a81-30ab-102d-86b0-7a5022ba4115";
        public static final String NEW_TB_CASES_DIAGNOSED__BACTERIOLOGICALLY_CONFIRMED = "164397AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String NEW_TB_CASES_DIAGNOSED__CLINICALLY_DIAGNOSED = "113491AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String NEW_TB_CASES_DIAGNOSED__EPTB = "dca7ae44-30ab-102d-86b0-7a5022ba4115";
        public static final String LEPROSY = "dc8e2e85-30ab-102d-86b0-7a5022ba4115";
        public static final String TETANUS = "124957AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SLEEPING_SICKNESS = "149241AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PELVIC_INFLAMMATORY_DISEASE = "dcdeac6a-30ab-102d-86b0-7a5022ba4115";
        public static final String BRUCELLOSIS = "dc688be2-30ab-102d-86b0-7a5022ba4115";
        public static final String NEONATAL_SEPSIS_07DAYS = "25a5aead-8393-4eda-80b3-d7901a8fe9e7";
        public static final String NEONATAL_SEPSIS_828DAYS = "e90756be-6f62-4618-b50a-0eedd8ac521c";
        public static final String NEONATAL_PNEUMONIA = "157907AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String NEONATAL_MENINGITIS = "bf930972-383f-4922-84fe-54219b8c3bf8";
        public static final String NEONATAL_JAUNDICE = "115368AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PREMATURE_BABY_AS_A_CONDITION_FOR_MANAGEMENT = "159908AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_NEONATAL_CONDITIONS = "164122AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SICKLE_CELL_ANAEMIA = "117703AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_TYPES_OF_ANAEMIA = "9222cefa-35a7-47d8-ac95-4e78e81e1d47";
        public static final String GASTROINTESTINAL_DISORDERS_NONINFECTIVE = "119242AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PAIN_REQUIRING_PALLIATIVE_CARE = "01e230be-ac8a-4581-85c3-7b91e508ffdd";
        public static final String DENTAL_CARIES = "dc66a9b1-30ab-102d-86b0-7a5022ba4115";
        public static final String GINGIVITIS = "139438AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ORAL_HAIRY_LEUKOPLAKIA = "dcb5e84b-30ab-102d-86b0-7a5022ba4115";
        public static final String ORAL_CANDIDIASIS = "dcb5dbbb-30ab-102d-86b0-7a5022ba4115";

        public static final String MALIGNANT_NEOPLASM_OF_ORAL_CAVITY = "113705AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ORAL_NEOPLASM = "115355AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String HERPETIFORM_APHTHOUS_STOMATITIS = "138680AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String APHTHOUS_ULCERATION = "148531AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PERIADENITIS_MUCOSA_NECROTICA_RECURRENS = "130576AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTITIS_MEDIA = "dc6656e9-30ab-102d-86b0-7a5022ba4115";
        public static final String HEARING_LOSS = "117698AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_ENT_CONDITIONS = "08e8a8a4-05c6-4945-a2cc-211035a32cff";
        public static final String OPHTHALMIA_NEONATORUM = "133414AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CATARACTS = "dc655f87-30ab-102d-86b0-7a5022ba4115";
        public static final String REFRACTIVE_ERRORS = "119056AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String GLAUCOMA = "117789AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TRACHOMA = "112287AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TUMORS = "8cabb31c-e3a0-46d3-9e21-9bd51d8b328b";
        public static final String BLINDNESS = "147215AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DIABETIC_RETINOPATHY = "142429AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_EYE_CONDITIONS = "c89fb8f6-d5cc-4e08-881f-91fb33bab8c7";
        public static final String BIPOLAR_DISORDERS = "121131AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DEPRESSION = "dc6979b9-30ab-102d-86b0-7a5022ba4115";
        public static final String EPILEPSY = "155AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DEMENTIA = "dcacdc90-30ab-102d-86b0-7a5022ba4115";
        public static final String CHILDHOOD_MENTAL_DISORDERS = "134334AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SCHIZOPHRENIA = "dc7c7b83-30ab-102d-86b0-7a5022ba4115";
        public static final String HIV_RELATED_PSYCHOSIS = "97af98fa-eeab-4faa-9947-7d8ff8b14ec4";
        public static final String ANXIETY_DISORDERS = "121540AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ALCOHOL_ABUSE = "121725AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DRUG_ABUSE = "118855AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_MENTAL_HEALTH_CONDITIONS = "dc657b8b-30ab-102d-86b0-7a5022ba4115";
        public static final String ASTHMA = "dc540e3c-30ab-102d-86b0-7a5022ba4115";
        public static final String CHRONIC_OBSTRUCTIVE_PULMONARY_DISEASE_COPD = "dca0ee38-30ab-102d-86b0-7a5022ba4115";
        public static final String CANCER_CERVIX = "155424AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CANCER_PROSTATE = "146221AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CANCER_BREAST = "116026AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CANCER_LUNG = "133328AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CANCER_LIVER = "135721AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String CANCER_COLON = "113729AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String KAPOSIS_SARCOMA = "dc7d74ec-30ab-102d-86b0-7a5022ba4115";
        public static final String CANCER_OTHERS = "29ed0e74-ed49-429c-9e3a-9c2a8c7f5c6c";
        public static final String CARDIOVASCULAR_ACCIDENT = "111103AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String HYPERTENSION = "dc8f22f9-30ab-102d-86b0-7a5022ba4115";
        public static final String HEART_FAILURE = "139069AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ISCHEMIC_HEART_DISEASES = "116608AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String RHEUMATIC_HEART_DISEASES = "dc69bd16-30ab-102d-86b0-7a5022ba4115";
        public static final String CHRONIC_HEART_DISEASES = "145349AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_CARDIOVASCULAR_DISEASES = "119270AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DIABETES_MELLITUS = "119481AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String THYROID_DISEASE = "118976AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_ENDOCRINE_AND_METABOLIC_DISEASES = "119235AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SEVERE_ACUTE_MALNUTRITION_WITH_OEDEMA = "e4d7bc04-14e6-4ed2-a0d8-1ad85314b071";
        public static final String SEVERE_ACUTE_MALNUTRITION_WITHOUT_OEDEMA = "a4543170-8155-41c7-b618-da6962b81f45";
        public static final String MILD_ACUTE_MALNUTRITION = "157793AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String JAW_INJURIES = "136973AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String INJURIES_ROAD_TRAFFIC_ACCIDENTS = "119964AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String INJURIES_DUE_TO_MOTORCYCLEBODABODA = "546e71c1-0043-4e2c-bbf5-99db05443307";
        public static final String INJURIES_DUE_TO_GENDER_BASED_VIOLENCE = "ba6838ab-ab94-4b19-85a2-2a9de8ff4d4d";
        public static final String INJURIES_TRAUMA_DUE_TO_OTHER_CAUSES = "c044adc0-cef4-4d85-b646-b249e73bebfa";
        public static final String ANIMAL_BITES_DOMESTIC = "edfcdabf-8c97-40f7-ac09-05f6419f27ba";
        public static final String ANIMAL_BITES_WILD = "1fed0451-a8e5-4f00-a5d0-5ef4eda73ccc";
        public static final String ANIMAL_BITES_INSECTS = "116758AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String DOG_BITE = "dc68ac75-30ab-102d-86b0-7a5022ba4115";
        public static final String SNAKE_BITES = "126323AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TOOTH_EXTRACTIONS = "5b736186-3d5b-4401-83cb-d3f2b04d1695";
        public static final String DENTAL_FILLINGS = "3d314ee1-ad7e-4cea-8f9b-53706a19d41c";
        public static final String OTHER_MINOR_OPERATIONS = "fe605c9b-8a46-4a83-9147-1b242db222db";
        public static final String LEISHMANIASIS = "116350AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String LYMPHATIC_FILARIASIS_HYDROCELE = "117474AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String LYMPHATIC_FILARIASIS_LYMPOEDEMA = "135480AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String URINARY_SCHISTOSOMIASIS = "123493AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String INTESTINAL_SCHISTOSOMIASIS = "136675AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ONCHOCERCIASIS = "137393AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ABORTIONS_DUE_TO_GENDERBASED_VIOLENCE_GBV = "49f5e940-b8e7-4d3b-bfe6-606df2f5e4b5";
        public static final String ABORTIONS_DUE_TO_OTHER_CAUSES = "dc6504d3-30ab-102d-86b0-7a5022ba4115";
        public static final String MALARIA_IN_PREGNANCY = "135361AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String HIGH_BLOOD_PRESSURE_IN_PREGNANCY = "dc55064a-30ab-102d-86b0-7a5022ba4115";
        public static final String OBSTRUCTED_LABOUR = "115036AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String PUERPERAL_SEPSIS = "130AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ANTEPARTUM_HAEMORRHAGE = "dc69f6f5-30ab-102d-86b0-7a5022ba4115";
        public static final String POSTPARTUM_HAEMORRHAGE = "dc650021-30ab-102d-86b0-7a5022ba4115";
        public static final String OTHER_DIAGNOSES = "280fc8c8-5145-4337-a854-690b9c09bebd";
        public static final String DEATHS_IN_OPD = "dca27d22-30ab-102d-86b0-7a5022ba4115";
        public static final String OTHERS_NON_CODED = "5622AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String OTHER_SPECIFY = "dcd68a88-30ab-102d-86b0-7a5022ba4115";
        public static final String TB_TREATMENT_OUTCOME = "e44c8c4c-db50-4d1e-9d6e-092d3b31cfd6";
        public static final String TREATMENT_FAILURE = "159874AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String BMI = "dca1f717-30ab-102d-86b0-7a5022ba4115";
        public static final String ALCOHOL_USE = "159449AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String TOBACCO_USE = "163731AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String STARTED_ON_CPT = "9fc5bf9d-a79e-4548-9207-b2afbbeba796";
        public static final String ENROLLED_IN_HIV_CARE_PROGRAM = "d697d1db-32ff-4efe-a9d9-563e7c5f0827";
        public static final String FINAL_EID_PCR_TEST_RESULT = "977b16f4-2d3e-40d2-ba51-54794c98f7ef";
        public static final String RAPID_HIV_TEST_AT_18_MONTHS_DATE = "7065b181-abb0-4ad6-8082-62e99398f735";
        public static final String RAPID_HIV_TEST_AT_18_MONTHS_TEST_RESULT = "71e135e8-cf63-4031-adc7-09a0a9b61c33";
        public static final String FIRST_EID_PCR_TEST_RESULT = "b6a6210b-ccdf-45fc-80dd-1567f65e2d98";
        public static final String SECOND_EID_PCR_TEST_RESULT = "e1b4efbf-0dff-4e9e-a2f2-34edcb02a5d0";
        public static final String DATE_FIRST_EID_PCR_TEST_RESULT_GIVEN_TO_CARE_PROVIDER = "f4d8932c-2b95-46c5-8aac-1fc345c3f01f";
        public static final String DATE_SECOND_EID_PCR_TEST_RESULT_GIVEN_TO_CARE_PROVIDER = "358cbf29-0d6f-4be0-9af4-5844049d5f28";
        public static final String DATE_OF_FIRST_PCR_TEST = "51941f01-307f-44ca-9351-401bc008a208";
        public static final String DATE_OF_SECOND_PCR_TEST = "1f627527-2f97-4f21-9b61-2b79d887950f";
        public static final String DATE_OF_18_MONTH_RAPID_PCR_TEST = "7065b181-abb0-4ad6-8082-62e99398f735";
        public static final String EMTCT_CODES = "d5b0394c-424f-41db-bc2f-37180dcdbe74";
        public static final String EMTCT_CODESP = "62a37075-fc2a-4729-8950-b9fae9b22cfb";
        public static final String HIV_PROHYLAXIS="f42e40f3-7f76-4c0d-b9cc-f66acbb092c4";
        public static final String PREGNANCY_OUTCOME = "161033AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String HIV_STATUS = "dce0e886-30ab-102d-86b0-7a5022ba4115";
        public static final String ARV_FOR_BABY = "9e825e42-be00-4d4d-8774-257ddb29581b";
        public static final String NVP_SYRUP = "04711d8f-c60d-4b1c-9451-0b32debbb8b0";
        public static final String NEVERAPINE = "dc800d9d-30ab-102d-86b0-7a5022ba4115";
        public static final String ART_CODE = "a615f932-26ee-449c-8e20-e50a15232763";
            public static final String ART_CODE_PARTNER = "11dafd93-23c1-4b89-86e0-593e5f7ca386";
            public static final String INITIATED_ON_ART = "026e31b7-4a26-44d0-8398-9a41c40ff7d3";
        public static final String TETANUS_DOSE_GIVEN = "39217e3d-6a39-4679-bf56-f0954a7ffdb8";
        public static final String FIRST_DOSE = "0192ca59-b647-4f88-b07e-8fda991ba6d6";
        public static final String SECOND_DOSE = "f1d5afce-8dfe-4d2d-b24b-051815d61848";
        public static final String THIRD_DOSE = "a5497b5a-7da1-42d2-9985-b5ec695b4199";
        public static final String FOURTH_DOSE = "da40fa2a-074f-4d90-a875-5bb8316bc753";
        public static final String FIFTH_DOSE = "18f11bf4-c986-4cdd-b31c-fb189ea39333";
        public static final String EMTCT_CODE_TRRK = "1f177240-85f6-4f10-964a-cfc7722408b3";
        public static final String ARV_REGIMEN = "35ae2043-a3b0-48de-8e22-05f377ac39a2";
        public static final String EMTCT_CODE_TRP = "a08d9331-b437-485c-8eff-1923f3d43630";
        public static final String EMTCT_CODE_TRRP = "8dcaefaa-aa91-4c24-aaeb-122cff549ab3";
        public static final String EMTCT_CODE_TRRTICK = "4d301db0-c517-4556-9f7c-d837bac90144";
        public static final String EMTCT_CODE_T = "05f16fc5-1d82-4ce8-9b44-a3125fbbf2d7";
        public static final String EMTCT_CODE_TR = "86e394fd-8d85-4cb3-86d7-d4b9bfc3e43a";
        public static final String EMTCT_CODE_TRR = "25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465";
        public static final String EMTCT_CODE_TRK = "81bd3e58-9389-41e7-be1a-c6723f899e56";
        public static final String ASPHYXIA = "121397AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String SYPHILLS_TEST = "275a6f72-b8a4-4038-977a-727552f69cb8";
        public static final String SYPHILLS_TEST_PARTNER = "d8bc9915-ed4b-4df9-9458-72ca1bc2cd06";

        public final static String CDDP_PROGRAM_STATE_CRPDDP_STATE = "a6a0ab45-b7dc-43b2-b28c-45a91f968ebf";

            public static final String ANC_VISIT_NUMBER = "c0b1b5f1-a692-49d1-9a69-ff901e07fa27";
            public static final String FIRST_ANC_VISIT = "588ac57f-a4d0-47c2-9852-92502194ec4a";
            public static final String SECOND_ANC_VISIT = "a3ff912e-8298-4743-84cb-62e267c91b58";
            public static final String THIRD_ANC_VISIT = "6fd18b93-4c93-417c-9844-b53f467e9a13";
            public static final String FOURTH_ANC_VISIT = "e4f09b29-061e-42b4-a142-68a4ceda373c";
            public static final String FIFTH_ANC_VISIT = "6a6df844-565a-44cc-b0b9-d3f77e42c9cc";
            public static final String SIXTH_ANC_VISIT = "ff8de97a-4279-470e-aae9-927bf2a45f27";
            public static final String SEVENTH_ANC_VISIT = "badb383d-022c-40a5-9ddb-82e6653d9676";
            public static final String EITH_ANC_VISIT = "e01e2533-6f3c-41e1-a67f-a1e5b84eaebf";
            public static final String NINETH_ANC_VISIT = "cb56e6a2-4886-4a14-b232-accc37a1043e";




        public static final String HEPB_TEST = "eeab75e4-dd7b-4a8f-81e5-b50b819042c4";

        public static final String TRANSFER_IN_REGIMEN_START_DATE = "f363f153-f659-438b-802f-9cc1828b5fa9";
        public static final String TRANSFER_IN_REGIMEN = "9a9314ed-0756-45d0-b37c-ace720ca439c";
        public static final String TRANSFER_IN_REGIMEN_OTHER = "a5bfc18e-c6db-4d5d-81f5-18d61b1355a8";

        public static final String  TRANSFER_OUT_DATE = "fc1b1e96-4afb-423b-87e5-bb80d451c967";
        public static final String TB_LAM_RESULTS ="066b84a0-e18f-4cdd-a0d7-189454f4c7a4";
        public static final String CRAG_RESULTS ="43c33e93-90ff-406b-b7b2-9c655b2a561a";

        public static final String DTG_TLD_REGIMEN_LIST = "a58d12c5-abc2-4575-8fdb-f30960f348fc,6cc36637-596a-4426-92cf-170f76ea437d,a779d984-9ccf-4424-a750-47506bf8212b,29abb0ac-fcda-4dc0-b69b-9a2558e6a122,3b5248cc-0527-468e-8eb5-23565a4bad1f,2ae8fb21-1070-4d54-ab0e-c3afeb570dca";
    }

    public static class Identifier {

    }

    public static class EncounterType {
        public final static String ART_SUMMARY_PAGE = "8d5b27bc-c2cc-11de-8d13-0010c6dffd0f";
        public final static String ART_ENCOUNTER_PAGE = "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f";
        public final static String ART_HEALTH_EDUCATION_PAGE = "6d88e370-f2ba-476b-bf1b-d8eaf3b1b67e";
        public final static String EID_SUMMARY_PAGE = "9fcfcc91-ad60-4d84-9710-11cc25258719";
        public final static String EID_ENCOUNTER_PAGE = "4345dacb-909d-429c-99aa-045f2db77e2b";
        public final static String ANC_ENCOUNTER = "044daI6d-f80e-48fe-aba9-037f241905Pe";
        public final static String PNC_ENCOUNTER = "fa6f3ff5-b784-43fb-ab35-a08ab7dbf074";
        public static final String MATERNITY_ENCOUNTER = "a9f11592-22e7-45fc-904d-dfe24cb1fc67";
        public static final String OPD_ENCOUNTER = "ee4780f5-b5eb-423b-932f-00b5879df5ab";
        public final static String SMC_ENCOUNTER = "244da86d-f80e-48fe-aba9-067f241905ee";
        public final static String APPOINTMENT_FOLLOWUP_ENCOUNTER = "dc551efc-024d-4c40-aeb8-2147c4033778";

    }

    public static class Program {
        public final static String HIV_PROGRAM = "18c6d4aa-0a36-11e7-8dbb-507b9dc4c741";
    }

        public static class ProgramWorkflow {
                public final static String HIV_PROGRAM_WORKFLOW_REGIMEN_LINES = "4c30d724-dbcc-42db-ba9b-a9b9d2aadc00";
        }

        public static class ProgramState {
                public final static String HIV_PROGRAM_STATE_UNKNOWN = "ec890f83-fd47-4406-9c86-8f779b38f6d6";
                public final static String HIV_PROGRAM_STATE_FIRST_LINE_REGIMEN = "ab6d1f1d-fcf6-4255-8b6f-2bf8959ad8f2";
                public final static String HIV_PROGRAM_STATE_SECOND_LINE_REGIMEN = "9a42a3ad-d8a4-4f2e-9fa0-04d5f2e6436e";
                public final static String HIV_PROGRAM_STATE_THIRD_LINE_REGIMEN = "5d2d0e7e-69a6-408a-b5ce-8d93fb72bc21";
        }
}
