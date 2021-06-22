package org.openmrs.module.ugandaemrreports.library;

import org.openmrs.ProgramWorkflowState;
import org.openmrs.module.reporting.cohort.definition.*;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.definition.library.BaseDefinitionLibrary;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.metadata.TBMetadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary.getConcept;

/**
 */
@Component
public class TBCohortDefinitionLibrary extends BaseDefinitionLibrary<CohortDefinition> {

    @Autowired
    private DataFactory df;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private TBMetadata tbMetadata;

    @Override
    public Class<? super CohortDefinition> getDefinitionType() {
        return CohortDefinition.class;
    }

    @Override
    public String getKeyPrefix() {
        return "ugemr.cohort.tb.";
    }


    public CohortDefinition getEverEnrolledInTBCare() {
        return df.getPatientsWithIdentifierOfType(tbMetadata.getTBIdentifier());
    }

    public CohortDefinition getNewAndRelapsedPatientsDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewPatientType(), tbMetadata.getRelapsedPatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getEnrolledTBDuringPeriod(){
        ProgramEnrollmentCohortDefinition cd = new ProgramEnrollmentCohortDefinition();
        cd.setName("Enrolled in program During Period");
        cd.addParameter(new Parameter("onOrBefore", "Enrolled on or before", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "Enrolled on or after", Date.class));
        cd.setPrograms(Arrays.asList(commonDimensionLibrary.getProgramByUuid("de5d54ae-c304-11e8-9ad0-529269fb1459")));
        return df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));

    }

    public CohortDefinition getEnrolledOnDSTBDuringPeriod(){
        return df.getPatientsInAll(getEnrolledTBDuringPeriod(),getPatientsInDSTBState());
    }

    public CohortDefinition getEnrolledOnDSTBDuringPeriod(String olderThan){
        ProgramEnrollmentCohortDefinition cd = new ProgramEnrollmentCohortDefinition();
        cd.setName("Enrolled in program During Period");
        cd.addParameter(new Parameter("onOrBefore", "Enrolled on or before", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "Enrolled on or after", Date.class));
        cd.setPrograms(Arrays.asList(commonDimensionLibrary.getProgramByUuid("de5d54ae-c304-11e8-9ad0-529269fb1459")));
        CohortDefinition cd1= df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate-"+olderThan+",onOrBefore=endDate-"+olderThan));


        InStateCohortDefinition cd2 = new InStateCohortDefinition();
        cd2.setStates(Arrays.asList(commonDimensionLibrary.getProgramState("dc3fbc52-15a9-444c-99d1-65f01f9199dd")));
        cd2.addParameter(new Parameter("onOrAfter", "reporting.parameter.onOrAfter", Date.class));
        cd2.addParameter(new Parameter("onOrBefore", "reporting.parameter.onOrBefore", Date.class));
        return df.getPatientsInAll( df.convert(cd2, ObjectUtil.toMap("onOrAfter=startDate-"+olderThan+",onOrBefore=endDate-"+olderThan)),cd1);
    }

    public CohortDefinition getNewPatientsDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewPatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getRelapsedPatientsDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getRelapsedPatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTreatedAfterLTFPPatientsDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getTreatmentAfterLTFPPatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTreatedAfterFailurePatientsDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getTreatmentAfterFailurePatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTreatmentHistoryUnknownPatientsDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getTreatmentHistoryUnknownPatientType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsStartedOnTreatmentDuringperiod(){
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(tbMetadata.getDateStartedTBTreatment(),tbMetadata.getTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoseHIVStatusIsNewlyDocumented(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getHIVStatusCategory(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewlyPositiveHIVStatus(),tbMetadata.getNegativeHIVStatus(),tbMetadata.getUnknownHIVStatus()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoseHIVStatusIsKnownPositive(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getHIVStatusCategory(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getKnownPositiveHIVStatus()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoseHIVStatusIsNewlyPositive(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getHIVStatusCategory(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewlyPositiveHIVStatus()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsStartedOnARTOnTBEnrollment(){
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(getConcept("ab505422-26d9-41f1-a079-c3d222000440"),tbMetadata.getTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsOnCPTOnTBEnrollment(){
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(getConcept("481c5fdb-4719-4be3-84c0-a64172a426c7"),tbMetadata.getTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsOnCPT(){
        return df.getPatientsWithCodedObsDuringPeriod(getConcept("bb77f9f0-9743-4c60-8e70-b20b5e800a50"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")) ,BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoAreAlreadyOnART(){
        return df.getPatientsWithCodedObsDuringPeriod(getConcept("dca25616-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("dca2817c-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsInitiatedOnART(){
        return df.getPatientsWithCodedObsDuringPeriod(getConcept("dca25616-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("dca2670e-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsOnFacilityDOTSTreatmentModel(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTreatmentModel(),null,Arrays.asList(tbMetadata.getFacilityDOTsTreatmentModel()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsOnCommunityDOTSTreatmentModel(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTreatmentModel(),null,Arrays.asList(tbMetadata.getDigitalCommunityDOTsTreatmentModel(),tbMetadata.getNonDigitalCommunityDOTsTreatmentModel()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithTreatmentSupporters(){
        return df.getPatientsWithCodedObsDuringPeriod(getConcept("805a9d40-8922-4fb0-8208-7c0fdf57936a"),tbMetadata.getTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsReferredFromComunity(){
        return df.getPatientsWithCodedObsDuringPeriod(getConcept("67ea4375-0f4f-4e67-b8b0-403942753a4d"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("1ca0db4a-c5c6-48ed-9e17-84905f4487eb")), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getDRTBEnrolledDuringPeriod(){
        return df.getPatientsInAll(getEnrolledTBDuringPeriod(),getPatientsInDRTBState());
    }

    public CohortDefinition getPatientsInDSTBState(){
        InStateCohortDefinition cd = new InStateCohortDefinition();
        cd.setStates(Arrays.asList(commonDimensionLibrary.getProgramState("dc3fbc52-15a9-444c-99d1-65f01f9199dd")));
        cd.addParameter(new Parameter("onOrAfter", "reporting.parameter.onOrAfter", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "reporting.parameter.onOrBefore", Date.class));
        return df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsInDRTBState(){
        InStateCohortDefinition cd = new InStateCohortDefinition();
        cd.setStates(Arrays.asList(commonDimensionLibrary.getProgramState("673966b1-e181-4b46-a526-f7ac6954c59b")));
        cd.addParameter(new Parameter("onOrAfter", "reporting.parameter.onOrAfter", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "reporting.parameter.onOrBefore", Date.class));
        return df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsInDRTBState(String olderThan){
        InStateCohortDefinition cd = new InStateCohortDefinition();
        cd.setStates(Arrays.asList(commonDimensionLibrary.getProgramState("673966b1-e181-4b46-a526-f7ac6954c59b")));
        cd.addParameter(new Parameter("onOrAfter", "reporting.parameter.onOrAfter", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "reporting.parameter.onOrBefore", Date.class));
        return df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate-"+olderThan+",onOrBefore=endDate-"+olderThan));
    }

    public CohortDefinition getPatientWithRifampicinResitance(String periodInMonths){
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded=767 and p.concept_id=159984 and p.value_coded=159956\n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }


    public CohortDefinition getPatientWithIsonaizidSus_ceptibility(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                " inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded=78280 and p.concept_id=159984 and p.value_coded =159958 \n" +
                "and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithIsonaizidResistant(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                " inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded=78280 and p.concept_id=159984 and p.value_coded = 159956 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithAmikacinSus_ceptibility(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded=71060 and p.concept_id=159984 and p.value_coded =159958 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithAmikacinResistant(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded=71060 and p.concept_id=159984 and p.value_coded = 159956 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithFQSus_ceptibility(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded in (78788,80133,76835) and p.concept_id=159984 and p.value_coded =159958 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithSL_InjectableSus_ceptibility(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded in (71060,72794,78385) and p.concept_id=159984 and p.value_coded =159958 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithFQResistant(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded in (78788,80133,76835) and p.concept_id=159984 and p.value_coded = 159956 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientWithSl_InjectableResistant(String periodInMonths) {
        String query = "select p.person_id from obs o inner  join obs p on o.obs_group_id = p.obs_group_id inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner join encounter_type et on e.encounter_type = et.encounter_type_id where o.concept_id=159956 and o.value_coded in (71060,72794,78385) and p.concept_id=159984 and p.value_coded = 159956 \n" +
                " and et.uuid='0271ee3d-f274-49d1-b376-c842f075413f' and e.encounter_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH)";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return  cd;
    }

    public CohortDefinition getPatientsWithBacteriallyConfirmedMDRXDRRRDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getReasonForEnteringInThe2ndLineTreatment(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getBacteriallyConfirmedMDRXDRRR()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }

    public CohortDefinition getPatientsWithPresumptiveMDRXDRRRDuringPeriod(){
        return df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getReasonForEnteringInThe2ndLineTreatment(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getPresumptiveMDRXDRRR()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }
}
