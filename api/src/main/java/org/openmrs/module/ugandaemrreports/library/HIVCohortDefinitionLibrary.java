package org.openmrs.module.ugandaemrreports.library;

import org.openmrs.Concept;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CompositionCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.GenderCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.SqlCohortDefinition;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.RangeComparator;
import org.openmrs.module.reporting.definition.library.BaseDefinitionLibrary;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reportingcompatibility.service.ReportService.TimeModifier;
import org.openmrs.module.ugandaemrreports.common.Enums;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.PatientsWithNoClinicalContactDefinition;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Date;

/**
 *
 */
@Component
public class HIVCohortDefinitionLibrary extends BaseDefinitionLibrary<CohortDefinition> {

    @Autowired
    private DataFactory df;

    @Autowired
    private HIVMetadata hivMetadata;

    @Override
    public Class<? super CohortDefinition> getDefinitionType() {
        return CohortDefinition.class;
    }

    @Override
    public String getKeyPrefix() {
        return "ugemr.cohort.hiv.";
    }


    public CohortDefinition getEverEnrolledInCare() {
        return df.getPatientsWithIdentifierOfType(hivMetadata.getHIVIdentifier());
    }

    public CohortDefinition getYearlyPatientsOnCare() {
        return df.getPatientsInPeriod(hivMetadata.getARTSummaryPageEncounterType(), Enums.Period.YEARLY);
    }

    public CohortDefinition getEnrolledInCareByEndOfPreviousDate() {
        return df.getAnyEncounterOfTypesByStartDate(hivMetadata.getARTSummaryPageEncounterType());
    }

    public CohortDefinition getEnrolledInCareBetweenDates() {
        return df.getAnyEncounterOfTypesBetweenDates(hivMetadata.getARTSummaryPageEncounterType());
    }

    public CohortDefinition getArtPatientsWithEncounterOrSummaryPagesBetweenDates() {
        return df.getAnyEncounterOfTypesBetweenDates(hivMetadata.getArtEncounterTypes());

    }

    public CohortDefinition getTransferredInToCareDuringPeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtRegimenTransferInDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredInToCarePreviousQuarter(String olderThan) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtRegimenTransferInDate(), hivMetadata.getARTSummaryPageEncounterType(),olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsTransferredOutDuringPeriod() {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getTransferredOutDate(), null, BaseObsCohortDefinition.TimeModifier.ANY);    }

    public CohortDefinition getPatientsTransferredOutDuringPeriod(String olderThan) {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getTransferredOutDate(), null, BaseObsCohortDefinition.TimeModifier.ANY,olderThan);    }

    public CohortDefinition getTransferredInToCareDuringPeriod(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTransferIn(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredOut() {
        return df.getPatientsWithCodedObs(hivMetadata.getTransferredOut(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredOutDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTransferredOut(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredOutBy(String olderThan) {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getTransferredOut(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredOut(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTransferredOut(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getInterruptedMedically() {
        return df.getPatientsWithCodedObs(hivMetadata.getArtInterruption(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getArtInterruptionStopped()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getInterruptedMedically(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getArtInterruption(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getArtInterruptionStopped()), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition gePatientsWhoDied() {
        return df.getPatientsWithCodedObs(hivMetadata.getDead(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition gePatientsWhoDiedBy(String olderThan) {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getDead(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition gePatientsWhoDied(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getDead(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getTransferredInToCareBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getTransferIn(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getEnrolledInCareToCareWhenPregnantOrLactating() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getEntryPoint(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getEMTCTAtEnrollment()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getStartedOnARTWhenPregnantOrLactating() {
        return df.getPatientsInAny(getPregnantAtArtStartDuringPeriod(), getLactatingAtArtStartDuringPeriod());
    }

    public CohortDefinition getPregnantOrLactating() {
        return df.getPatientsWithCodedObs(hivMetadata.getEMTCTAtEnrollment(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }

    public CohortDefinition getPregnantAtArtStartDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getPregnantAtArtStart(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getLactatingAtArtStartDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getLactatingAtArtStart(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPregnantOrLactating(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getEMTCTAtEnrollment(), hivMetadata.getARTSummaryPageEncounterType(), Arrays.asList(hivMetadata.getYes()), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getOnINHDuringPeriod() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getINHDosage(), hivMetadata.getARTEncounterPageEncounterType(), RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getOnINHDuringBeforePeriod() {
        return df.getPatientsWithNumericObsByEndOfPreviousDate(hivMetadata.getINHDosage(), hivMetadata.getARTEncounterPageEncounterType(), RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtStartDateBetweenPeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtStartDate() {
        return df.getPatientsWhoseObsValueAfterDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtStartDateBetweenPeriod(String olderThan) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtStartDateBeforePeriod() {
        return df.getPatientsWhoseMostRecentObsDateIsBetweenValuesByEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY, "1d", null);
    }

    public CohortDefinition getArtStartDateBeforePeriod(String olderThan) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtRegimenTransferInDateBetweenPeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtRegimenTransferInDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getArtRegimenTransferInDateBeforePeriod() {
        return df.getPatientsWhoseMostRecentObsDateIsBetweenValuesByEndDate(hivMetadata.getArtRegimenTransferInDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY, "1d", null);
    }

    public CohortDefinition getPatientsHavingRegimenBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingRegimenBeforePeriod(String olderThan) {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientWithRecentHIVInfectionDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"), hivMetadata.getHCTEncounterType(), Arrays.asList(Dictionary.getConcept("141518BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientWithLongTermHIVInfectionDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"), hivMetadata.getHCTEncounterType(), Arrays.asList(Dictionary.getConcept("141519BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientWhoTestedForRecencyHIVInfectionDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"), hivMetadata.getHCTEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsHavingRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingRegimenDuringPeriod(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingBaseRegimenBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getArtStartRegimen(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingBaseRegimenBeforePeriod(String olderThan) {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getArtStartRegimen(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingBaseRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getArtStartRegimen(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingBaseRegimenDuringPeriod(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getArtStartRegimen(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingTransferInRegimenBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getArtTransferInRegimen(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsHavingTransferInRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getArtTransferInRegimen(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsTransferredOutBetweenStartAndEndDate() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getTransferredOutDate(), null, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsTransferredOutByEndOfPeriod() {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getTransferredOutDate(), null, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getDeadAndTransferredOutPatientsDuringPeriod() {
        CohortDefinition deadPatients = df.getDeadPatientsByEndDate();
        CohortDefinition transferredOutPatients = getPatientsTransferredOutByEndOfPeriod();
        return df.getPatientsInAny(deadPatients, transferredOutPatients);
    }

    public CohortDefinition getPatientsHavingTransferInRegimenDuringPeriod(String olderThan) {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getArtTransferInRegimen(), hivMetadata.getARTSummaryPageEncounterType(), olderThan, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getOnCPTDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("c3d744f6-00ef-4774-b9a7-d33c58f5b014"), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getEligibleOnCPTDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("c3d744f6-00ef-4774-b9a7-d33c58f5b014"), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getOnCPTBeforePeriod() {
        return df.getPatientsWithNumericObsByEndOfPreviousDate(hivMetadata.getCPTDosage(), hivMetadata.getARTEncounterPageEncounterType(), RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getAssessedForTBDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getDiagnosedWithTBDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getTBStatusDiagnosed(),
                hivMetadata.getConcept("ff246b26-f2d1-45f6-9e33-385eb8d19d3f"), hivMetadata.getConcept("e2fd439a-619e-4067-a2f1-8e2454120a58"), hivMetadata.getConcept("d5a86db5-3e7f-4344-85d7-572c8bb6b966"),
                hivMetadata.getConcept("d941bfbc-7546-464b-90ff-b8e28d247d47"), hivMetadata.getConcept("36cd82a6-370d-4188-bf69-ad8ebbc86d37"), hivMetadata.getConcept("1435dcb2-9470-4b69-8d05-199e5f13044c")), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getScreenedForTBNegativeDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getTBStatusNoSignsOrSymptoms()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getStartedTBRxBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getTBStatusRx()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsOnTBRxDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getTBStatusRx()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPresumptiveTBDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getConcept("dcdaaf0f-30ab-102d-86b0-7a5022ba4115"), hivMetadata.getTBStatusDiagnosed(),
                hivMetadata.getConcept("ff246b26-f2d1-45f6-9e33-385eb8d19d3f"), hivMetadata.getConcept("e2fd439a-619e-4067-a2f1-8e2454120a58"), hivMetadata.getConcept("d5a86db5-3e7f-4344-85d7-572c8bb6b966"),
                hivMetadata.getConcept("d941bfbc-7546-464b-90ff-b8e28d247d47"), hivMetadata.getConcept("36cd82a6-370d-4188-bf69-ad8ebbc86d37"), hivMetadata.getConcept("1435dcb2-9470-4b69-8d05-199e5f13044c")), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoseTBStartDateDuringThePeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getTBStartDate(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoseFluconazoleStartDateIsDuringThePeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getFluconazoleStartDate(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoWeightWasTakenDuringPeriod() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getBodyWeight(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWhoBaseWeightWasTakenDuringPeriod() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getBaselineBodyWeight(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoHeightWasTakenDuringPeriod() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getBodyHeight(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWhoMUACWasTakenDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getMUAC(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWhoseOedemaWasTakenDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getOedema(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsAssessedForMalnutrition() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getMalnutrition(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsAssessedForNutrition() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getNutritionStatus(), hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithModeratelyAcuteMalnutritionDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getNutritionStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getConcept("267a937a-f03c-487b-963c-1858f1382a5a")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWithSevereAcuteMalnutritionDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getNutritionStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getConcept("a4543170-8155-41c7-b618-da6962b81f45")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWithSevereAcuteMalnutritionWithOedemaDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getNutritionStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getConcept("e4d7bc04-14e6-4ed2-a0d8-1ad85314b071")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    //
    public CohortDefinition getPatientsWhoMUACWasRedOrYellowDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getMUAC(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getMUACYellow(), hivMetadata.getMUACRed()), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWhoseOedemaWasYesDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getOedema(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getYes()), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWhoAreMalnourishedDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getMalnutrition(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getMalnutritionYes(), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getPatientsWithGoodAdherence() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getAdherence(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getGoodAdherence()), BaseObsCohortDefinition.TimeModifier.MAX);
    }

    public CohortDefinition getChildrenOnFirstLineRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getFirstLineDrugsChildren(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getChildrenOnFirstLineRegimen() {
        return df.getPatientsWithCodedObs(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getFirstLineDrugsChildren(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getChildrenOnSecondLineRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getSecondLineDrugsChildren(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getChildrenOnSecondLineRegimen() {
        return df.getPatientsWithCodedObs(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getSecondLineDrugsChildren(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getAdultsOnFirstLineRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getFirstLineDrugsAdult(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getAdultsOnFirstLineRegimen() {
        return df.getPatientsWithCodedObs(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getFirstLineDrugsAdults(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getAdultsOnSecondLineRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getSecondLineDrugsAdult(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getAdultsOnSecondLineRegimen() {
        return df.getPatientsWithCodedObs(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getSecondLineDrugsAdults(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsOnThirdLineRegimenDuringPeriod() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getThirdLineDrugs(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsOnThirdLineRegimen() {
        return df.getPatientsWithCodedObs(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getThirdLineDrugs(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsStartedArtBasedOnCD4() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getCD4AtEnrollment(), hivMetadata.getARTSummaryPageEncounterType(), RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithBaselineCD4() {
        return df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getBaselineCD4(), hivMetadata.getARTSummaryPageEncounterType(), RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsPregnantAtFirstEncounter() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getPregnant(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getYesPregnant()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }

    public CohortDefinition getPregnantPatientsAtArtStart() {
        return df.getPatientsWithCodedObs(hivMetadata.getPregnantAtArtStart(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getYesPregnant()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }

    public CohortDefinition getLactatingPatientsAtArtStart() {
        return df.getPatientsWithCodedObs(hivMetadata.getLactatingAtArtStart(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getYesPregnant()), BaseObsCohortDefinition.TimeModifier.FIRST);
    }

    public CohortDefinition getLastVisitDateByEndOfQuarter() {
        return df.getPatientsWhoseMostRecentObsDateIsBetweenValuesByEndDate(hivMetadata.getReturnVisitDate(), hivMetadata.getArtEncounterTypes(), BaseObsCohortDefinition.TimeModifier.MAX, null, null);
    }

    public CohortDefinition getAppointments() {
        return df.getLastVisitInTheQuarter(hivMetadata.getReturnVisitDate(), TimeModifier.MAX);
    }

    public CohortDefinition getEligibleAndReadyByEndOfQuarter() {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getDateEligibleAndReadyForART(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getEarlyWarningIndicatorDataAbstractionCohort() {
        return df.EarlyWarningIndicatorDataAbstractionCohort(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithFirstEncounterInThePeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
    }


    public CohortDefinition getPatientsWithTransferInPlace() {
        return df.getTextBasedObs(hivMetadata.getTransferInPlace());
    }

    public CohortDefinition getPatientsWhoStartedArtQuartersAgo(Integer quartersBack) {
        return df.getWhoStartedArtDuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack);
    }

    public CohortDefinition getPatientsWhoStartedPregnantQuartersAgo(Integer quartersBack) {
        return df.getPregnantOrLactatingDuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack);
    }

    public CohortDefinition getPatientsOnArtWithCD4QuartersAgo(Integer quartersBack, Boolean allBaseCD4) {
        return df.getStartedArtWithCD4DuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack, allBaseCD4);
    }

    public CohortDefinition getDeadPatientsOnArtQuartersAgo(Integer quartersBack) {
        return df.getDeadPatientsOnArtBeforePeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack);
    }

    public CohortDefinition getStoppedPatientsOnSArtQuartersAgo(Integer quartersBack) {
        return df.getStoppedPatientsOnArtDuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack);
    }

    public CohortDefinition getPatientsOnArtWhoMissedQuartersAgo(Integer quartersBack) {
        return df.getLostPatientsOnArtDuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack, Boolean.FALSE);
    }

    public CohortDefinition getLostPatientsOnArtQuartersAgo(Integer quartersBack) {
        return df.getLostPatientsOnArtDuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack, Boolean.TRUE);
    }

    public CohortDefinition getPatientsOnArtWithCD4BeforeQuartersAgo(Integer quartersBack, Boolean allBaseCD4) {
        return df.getStartedArtWithCD4BeforePeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack, allBaseCD4);
    }

    public CohortDefinition getActiveWithNoEncounterInQuarter() {
        return df.getActiveInPeriodWithoutVisit();
    }

    public CohortDefinition getPatientsWhoStartedArtMonthsAgo(String monthsBack) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getArtStartDate(),
                hivMetadata.getARTSummaryPageEncounterType(), monthsBack, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithViralLoadDuringPeriod() {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithViralLoadDuringPeriod(String monthsBack) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), monthsBack, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWithViralLoadDuringPeriodPlusMnths(String monthsadded) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDatePlusMonths(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), monthsadded, BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsWhoseLastViralLoadWasMonthsAgoFromPeriod(String monthsBack) {
        return df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), monthsBack, BaseObsCohortDefinition.TimeModifier.LAST
        );
    }

    public CohortDefinition getPatientsWhoseLastViralLoadWasMonthsAgoFromEndDate(String monthsBack) {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), BaseObsCohortDefinition.TimeModifier.LAST, monthsBack);
    }

    public CohortDefinition getPatientsWithLastViralLoadByEndDate() {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getViralLoadDate(),
                Arrays.asList(hivMetadata.getARTEncounterEncounterType()), BaseObsCohortDefinition.TimeModifier.ANY
        );
    }

    public CohortDefinition getPatientsWithArtStartDateByEndDate(String olderThan) {
        return df.getPatientsWhoseObsValueDateIsByEndDate(hivMetadata.getArtStartDate(), hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY, olderThan);
    }

    public CohortDefinition getPatientsWhoTestedHIVPositiveDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS), null, Arrays.asList(Dictionary.getConcept(Metadata.Concept.HIV_POSITIVE)), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoTestedHIVNegativeDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS), null, Arrays.asList(Dictionary.getConcept(Metadata.Concept.HIV_NEGATIVE)), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    /**
     * HTS report cohorts
     *
     * @return
     */
    public CohortDefinition getPatientsTestedForHIV() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS), hivMetadata.getHCTEncounterType(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoReceivedHIVResultsAsIndividuals() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("3437ae80-bcc5-41e2-887e-d56999a1b467"), hivMetadata.getHCTEncounterType(), Arrays.asList(Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoReceivedHIVResultsAsCouple() {
        return df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("2aa9f0c1-3f7e-49cd-86ee-baac0d2d5f2d"), hivMetadata.getHCTEncounterType(), Arrays.asList(Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWhoReceivedHIVResults() {
        return df.getPatientsInAny(getPatientsWhoReceivedHIVResultsAsCouple(), getPatientsWhoReceivedHIVResultsAsIndividuals());
    }

    public CohortDefinition getPatientsTestedForHIVAndReceivedResults() {
        return df.getPatientsInAll(getPatientsTestedForHIV(), getPatientsWhoReceivedHIVResults());
    }

    public CohortDefinition getPatientsThatReceivedDrugsForNoOfDaysByEndOfPeriod(Double noOfDrugs, RangeComparator rangeComparator){
        return df.getPatientsWithNumericObsByEndDate(hivMetadata.getNumberOfDaysDispensed(), hivMetadata.getARTEncounterPageEncounterType(), rangeComparator, noOfDrugs, BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsThatReceivedDrugsForNoOfDaysByEndOfPeriod(Double value1, RangeComparator rangeComparator1, Double value2, RangeComparator rangeComparator2){
        return df.getPatientsWithNumericObsByEndOfPeriod(hivMetadata.getNumberOfDaysDispensed(), hivMetadata.getARTEncounterPageEncounterType(), rangeComparator1,value1,rangeComparator2,value2, BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWithNoClinicalContactsByEndDateForDays(Integer days) {
        String query = String.format("select person_id from (select o.person_id,last_enc_date,max(o.value_datetime)next_visit from obs o inner join\n" +
                "(select patient_id,max(encounter_datetime)last_enc_date from encounter where encounter_datetime >=:startDate and encounter_datetime <=:endDate group by patient_id) last_encounter\n" +
                "on o.person_id=patient_id where o.concept_id=5096 and o.value_datetime <= :endDate group by person_id)t1\n" +
                "where next_visit > last_enc_date and datediff(:endDate,next_visit)>='%d'", days);
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return cd;
    }

    public CohortDefinition getPatientsWithConfirmedAdvancedDiseaseDuringPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getAdvancedDiseaseStatus(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getConfirmedAdvancedDiseaseConcepts(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWithConfirmedAdvancedDiseaseByEndDate() {
        return df.getPatientsWithCodedObsByEndDate(hivMetadata.getAdvancedDiseaseStatus(), hivMetadata.getARTEncounterPageEncounterType(), hivMetadata.getConfirmedAdvancedDiseaseConcepts(), BaseObsCohortDefinition.TimeModifier.LAST);
    }

    public CohortDefinition getPatientsWithNoClinicalContactSinceLastExpectedContactByEndDate() {
        PatientsWithNoClinicalContactDefinition cd = new PatientsWithNoClinicalContactDefinition();
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return df.convert(cd, ObjectUtil.toMap("endDate=endDate"));
    }

    public CohortDefinition getPatientsWhoHadAViralLoadTestPeriodAfterArtInitiationByEndDate(String periodInMonths) {
        String query = "select  p.person_id from obs  p inner join\n" +
                "            (select person_id,value_datetime from obs o where o.voided =0 and o.concept_id = 99161 and o.value_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH))\n" +
                "              as art_start on p.person_id = art_start.person_id where p.concept_id=163023 and p.value_datetime BETWEEN :startDate AND :endDate and p.voided= 0 group by p.person_id";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return cd;
    }

    public CohortDefinition getPatientsWhoHadAViralLoadTestPeriodAfterArtInitiationAndAreSuppressedByEndDate(String periodInMonths) {
        String query = "select obs.person_id from obs inner join (select  p.person_id,p.encounter_id from obs  p inner join\n" +
                "            (select person_id,value_datetime from obs o where o.voided =0 and o.concept_id = 99161 and o.value_datetime between date_sub(:startDate, interval " + periodInMonths + " MONTH) AND date_sub(:endDate, interval " + periodInMonths + " MONTH))\n" +
                "              as art_start on p.person_id = art_start.person_id where p.concept_id=163023 and p.value_datetime BETWEEN :startDate AND :startDate and p.voided= 0 group by p.person_id)vl on obs.encounter_id= vl.encounter_id where obs.concept_id=856  and obs.voided=0 and obs.value_numeric<1000";
        SqlCohortDefinition cd = new SqlCohortDefinition(query);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return cd;
    }

   public CohortDefinition getPatientsWhoHadAViralLoadTestDuringThePastPeriodFromEndDate(String pastPeriods){
       return df.getPatientsWhoseObsValueDateIsBetweenPastPeriodFromEndDate(hivMetadata.getViralLoadDate(),hivMetadata.getARTEncounterPageEncounterType(),pastPeriods, BaseObsCohortDefinition.TimeModifier.ANY);
   }

    public CohortDefinition getPatientsOnDTGRegimenInPeriod() {
        return df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), Dictionary.getConceptList(Metadata.Concept.DTG_TLD_REGIMEN_LIST), BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public CohortDefinition getPatientsOnDTGRegimenBeforePeriod() {
        return df.getPatientsWithCodedObsByEndOfPreviousDate(hivMetadata.getCurrentRegimen(), hivMetadata.getARTEncounterPageEncounterType(), Dictionary.getConceptList(Metadata.Concept.DTG_TLD_REGIMEN_LIST), "1d", BaseObsCohortDefinition.TimeModifier.ANY);
    }

    public static SqlCohortDefinition getPatientsWithEncountersBeforeEndDateThatHaveReturnVisitDatesByStartDate() {
        SqlCohortDefinition cohortDefinition = new SqlCohortDefinition("select distinct patient_id from encounter e inner  join obs o on e.encounter_id = o.encounter_id  inner join encounter_type t on  t.encounter_type_id =e.encounter_type where encounter_datetime <= :endDate and t.uuid = '8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' and  o.concept_id=5096 and o.value_datetime >= :startDate and e.voided=0 and o.voided=0;");
        cohortDefinition.addParameter(new Parameter("startDate", "startDate", Date.class));
        cohortDefinition.addParameter(new Parameter("endDate", "endDate", Date.class));

        return cohortDefinition;

    }

    public CohortDefinition getPatientsWithEncountersBeforeEndDateOfPreviousQuarterThatHaveReturnVisitDatesByStartDateOfPreviousQuarter(String olderThan) {
        return df.convert(getPatientsWithEncountersBeforeEndDateThatHaveReturnVisitDatesByStartDate(),ObjectUtil.toMap("startDate=startDate-"+olderThan +",endDate=endDate-"+olderThan));
    }

    public CohortDefinition getPatientsTxLostToFollowupByDays(String days) {
        SqlCohortDefinition cohortDefinition = new SqlCohortDefinition("select t.patient_id from (select patient_id, max(value_datetime) return_visit_date,datediff(:endDate,max(value_datetime)) ltfp_days from encounter e inner  join obs o on e.encounter_id = o.encounter_id inner join encounter_type t on  t.encounter_type_id =e.encounter_type where encounter_datetime <=:endDate " +
                "and t.uuid = '8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' and  o.concept_id=5096 and o.value_datetime >= :startDate and e.voided=0 and o.voided=0 group by patient_id) as t  where ltfp_days >=" + days +" ;");
        cohortDefinition.addParameter(new Parameter("startDate", "startDate", Date.class));
        cohortDefinition.addParameter(new Parameter("endDate", "endDate", Date.class));
        CohortDefinition lostClientsWithInPeriod = df.convert(cohortDefinition,ObjectUtil.toMap("startDate=startDate,endDate=endDate"));

        //adding clients from previous period that will turn lost with in reporting period
        CohortDefinition clientsFromPreviousQuarterThatWIllBeLostIfTheyDontAppearWithinReportingPeriod =getPatientsWhoseLatestReturnVisitDateBeforeReportingPeriodExpiresDuringReportingPeriodToBeConsideredLostAfterNumberOfDays(days);
        CohortDefinition hasEncounterWithInReportingPeriod = getArtPatientsWithEncounterOrSummaryPagesBetweenDates();
        CohortDefinition lostClientsFromPreviousQuarter = df.getPatientsNotIn(clientsFromPreviousQuarterThatWIllBeLostIfTheyDontAppearWithinReportingPeriod,hasEncounterWithInReportingPeriod);
        return df.getPatientsInAny(lostClientsWithInPeriod,lostClientsFromPreviousQuarter);

    }

    public  CohortDefinition getPatientsTxLostToFollowupByDaysInPreviousQuarter(String days,String olderThan) {
        return df.convert(getPatientsTxLostToFollowupByDays(days),ObjectUtil.toMap("startDate=startDate-" +olderThan +",endDate=endDate-"+olderThan));
    }

    /**
     * This method looks at patients whose next return visit date by the start of period is not
     * yet considered lost by the days  passed as @param days but will be lost in considered lost in the current
     * reporting period , if they dont turn up by the end of period
     */

    public CohortDefinition getPatientsWhoseLatestReturnVisitDateBeforeReportingPeriodExpiresDuringReportingPeriodToBeConsideredLostAfterNumberOfDays(String days){
        SqlCohortDefinition cohortDefinition = new SqlCohortDefinition("select t.patient_id from (select patient_id, max(value_datetime) return_visit_date,datediff(:startDate,max(value_datetime)) ltfp_days from encounter e\n" +
                "    inner  join obs o on e.encounter_id = o.encounter_id inner join encounter_type t on  t.encounter_type_id =e.encounter_type where encounter_datetime <=:startDate and encounter_datetime>= DATE_SUB(:startDate, INTERVAL 3 month )\n" +
                "                and t.uuid = '8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' and  o.concept_id=5096 and e.voided=0 and o.voided=0 group by patient_id) as t  where return_visit_date < :startDate and  ltfp_days <" + days +" ;");
        cohortDefinition.addParameter(new Parameter("startDate", "startDate", Date.class));

        return df.convert(cohortDefinition,ObjectUtil.toMap("startDate=startDate"));
    }

    public static  SqlCohortDefinition getPatientsHavingAppointmentToday() {
        SqlCohortDefinition haveAppointmentToday = new SqlCohortDefinition("select person_id from  obs o where  o.concept_id=5096 and o.value_datetime >= :startDate and o.value_datetime <= :startDate and o.voided=0;");
        haveAppointmentToday.addParameter(new Parameter("startDate", "startDate", Date.class));
        return haveAppointmentToday;
    }

    public static  SqlCohortDefinition getPatientsHavingAnEncounterToday(){
        SqlCohortDefinition haveEncounterToday = new SqlCohortDefinition("select patient_id from encounter inner join encounter_type et on encounter.encounter_type = et.encounter_type_id where encounter_datetime >= :startDate and encounter_datetime <= :startDate  and et.uuid='8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' and encounter.voided=0");
        haveEncounterToday.addParameter(new Parameter("startDate", "startDate", Date.class));
        return haveEncounterToday;
    }

    public  CohortDefinition getDailyMissedAppointmentCohort() {
        CohortDefinition patientsWithReturnVisitDateGreaterThanToday = df.getPatientsWhoseObsValueAfterDate(hivMetadata.getReturnVisitDate(),hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition excludedPatients = df.getPatientsInAny(patientsWithReturnVisitDateGreaterThanToday,getPatientsHavingAnEncounterToday());
        return df.getPatientsNotIn(getPatientsHavingAppointmentToday(),excludedPatients);
    }

    public CohortDefinition getActivePatientsWithLostToFollowUpAsByDays(String days){
        CohortDefinition deadPatients = df.getDeadPatientsByEndDate();

        CohortDefinition tx_Curr_lost_to_followup = getPatientsTxLostToFollowupByDays(days);
        CohortDefinition transferredOut =getPatientsTransferredOutDuringPeriod();
        CohortDefinition excludedPatients =df.getPatientsInAny(deadPatients,transferredOut,tx_Curr_lost_to_followup);

        CohortDefinition transferredInToCareDuringPeriod= getTransferredInToCareDuringPeriod();
        CohortDefinition havingBaseRegimenDuringQuarter = getPatientsHavingBaseRegimenDuringPeriod();
        CohortDefinition havingArtStartDateDuringQuarter = getArtStartDateBetweenPeriod();
        CohortDefinition onArtDuringQuarter = getPatientsHavingRegimenDuringPeriod();

        CohortDefinition patientsWithactiveReturnVisitDate = getPatientsWithEncountersBeforeEndDateThatHaveReturnVisitDatesByStartDate();
        CohortDefinition allActivePatients = df.getPatientsInAny(patientsWithactiveReturnVisitDate,transferredInToCareDuringPeriod,havingArtStartDateDuringQuarter,
                onArtDuringQuarter, havingBaseRegimenDuringQuarter);
        CohortDefinition activeExcludingDeadLostAndTransfferedOut= df.getPatientsNotIn(allActivePatients,excludedPatients);

        return activeExcludingDeadLostAndTransfferedOut;
    }
}
