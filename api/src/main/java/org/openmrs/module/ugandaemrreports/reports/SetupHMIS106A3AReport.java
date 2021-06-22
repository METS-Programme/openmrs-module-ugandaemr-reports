package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.Concept;
import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CodedObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.SetComparator;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.metadata.TBMetadata;
import org.openmrs.reporting.data.DatasetDefinition;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary.getConcept;

/**
 *  TX Current Report
 */
@Component
public class SetupHMIS106A3AReport extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    SetupMERTxNew2019Report setupTxNewReport;

    @Autowired
    TBCohortDefinitionLibrary tbCohortDefinitionLibrary;

    @Autowired
    HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private TBMetadata tbMetadata;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonCohortDefinitionLibrary cohortDefinitionLibrary;



    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "220e7492-e56d-4f99-a424-40eda06668f2";
    }

    @Override
    public String getUuid() {
        return "dc69d1a2-2f2e-4512-896e-44c6bf7d1c42";
    }

    @Override
    public String getName() {
        return "HMIS 1061a 3A Report";
    }

    @Override
    public String getDescription() {
        return "HMIS 1061a 3A Report ";
    }

    @Override
    public List<Parameter> getParameters() {
        List<Parameter> l = new ArrayList<Parameter>();
        l.add(df.getStartDateParameter());
        l.add(df.getEndDateParameter());
        return l;
    }


    @Override
    public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
        return Arrays.asList(buildReportDesign(reportDefinition));
    }

    /**
     * Build the report design for the specified report, this allows a user to override the report design by adding
     * properties and other metadata to the report design
     *
     * @param reportDefinition
     * @return The report design
     */
    @Override
    public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "106A3_1.xls");
    }



    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd1 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd2 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd3 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd4 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd5 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd6 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd7 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd8 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd9 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd10 = new CohortIndicatorDataSetDefinition();
        dsd.setParameters(getParameters());
        dsd1.setParameters(getParameters());
        dsd2.setParameters(getParameters());
        dsd3.setParameters(getParameters());
        dsd4.setParameters(getParameters());
        dsd5.setParameters(getParameters());
        dsd6.setParameters(getParameters());
        dsd7.setParameters(getParameters());
        dsd8.setParameters(getParameters());
        dsd9.setParameters(getParameters());
        dsd10.setParameters(getParameters());


        CohortDefinitionDimension patientTypeDimensions = commonDimensionLibrary.getPatientTypeDimension();


        CohortDefinitionDimension ageDimension = commonDimensionLibrary.getTxCurrentAgeGenderGroup();
        dsd2.addDimension("age", Mapped.mapStraightThrough(ageDimension));
        dsd3.addDimension("age", Mapped.mapStraightThrough(ageDimension));
        dsd9.addDimension("indicator", Mapped.mapStraightThrough(getTBCohortAnalysisIndicators()));
        dsd10.addDimension("indicator", Mapped.mapStraightThrough(getTBCohortAnalysisIndicators()));



        dsd.addDimension("type", Mapped.mapStraightThrough(patientTypeDimensions));
        dsd1.addDimension("type", Mapped.mapStraightThrough(patientTypeDimensions));
        dsd8.addDimension("type", Mapped.mapStraightThrough(patientTypeDimensions));

        rd.addDataSetDefinition("A1", Mapped.mapStraightThrough(dsd));
        rd.addDataSetDefinition("A2", Mapped.mapStraightThrough(dsd1));
        rd.addDataSetDefinition("B", Mapped.mapStraightThrough(dsd2));
        rd.addDataSetDefinition("C", Mapped.mapStraightThrough(dsd3));
        rd.addDataSetDefinition("D", Mapped.mapStraightThrough(dsd4));
        rd.addDataSetDefinition("E", Mapped.mapStraightThrough(dsd5));
        rd.addDataSetDefinition("G", Mapped.mapStraightThrough(dsd6));
        rd.addDataSetDefinition("H", Mapped.mapStraightThrough(dsd7));
        rd.addDataSetDefinition("I", Mapped.mapStraightThrough(dsd8));
        rd.addDataSetDefinition("J", Mapped.mapStraightThrough(dsd9));
        rd.addDataSetDefinition("J2", Mapped.mapStraightThrough(dsd10));

        CohortDefinition males = cohortDefinitionLibrary.males();
        CohortDefinition females = cohortDefinitionLibrary.females();


        CohortDefinition TBTransferInDuringPeriod = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(getConcept("34c5cbad-681a-4aca-bcc3-c7ddd2a88db8"), tbMetadata.getTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition TBTransferInAYearAgo = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(getConcept("34c5cbad-681a-4aca-bcc3-c7ddd2a88db8"), tbMetadata.getTBEnrollmentEncounterType(),"12m", BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition below15Years = cohortDefinitionLibrary.MoHChildren();

        CohortDefinition registered = df.getPatientsNotIn(tbCohortDefinitionLibrary.getEnrolledOnDSTBDuringPeriod(),TBTransferInDuringPeriod);
        CohortDefinition startedOnTBTreatmentDuringPeriod = tbCohortDefinitionLibrary.getPatientsStartedOnTreatmentDuringperiod();

        CohortDefinition bacteriologicallyConfirmed = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getBacteriologicallyConfirmed()), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition clinicallyConfirmed = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getClinicallyDiagnosed()), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition EPTBConfirmed = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getEPTB()), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition bacteriologicallyConfirmedAndRegistered = df.getPatientsInAll(registered,bacteriologicallyConfirmed);
        CohortDefinition bacteriologicallyConfirmedAndStartedOnTratment = df.getPatientsInAll(startedOnTBTreatmentDuringPeriod,bacteriologicallyConfirmedAndRegistered);

        CohortDefinition clinicallyConfirmedAndRegistered = df.getPatientsInAll(registered,clinicallyConfirmed);
        CohortDefinition clinicallyConfirmedAndStartedOnTratment = df.getPatientsInAll(startedOnTBTreatmentDuringPeriod,clinicallyConfirmedAndRegistered);

        CohortDefinition EPTBConfirmedAndRegistered = df.getPatientsInAll(registered,EPTBConfirmed);
        CohortDefinition EPTBConfirmedAndStartedOnTratment = df.getPatientsInAll(startedOnTBTreatmentDuringPeriod,EPTBConfirmedAndRegistered);

        CohortDefinition newAndRelapsedPatients = tbCohortDefinitionLibrary.getNewAndRelapsedPatientsDuringPeriod();
        CohortDefinition newAndRelapsedRegisteredClients = df.getPatientsInAll(newAndRelapsedPatients,registered);

        CohortDefinition HIVStatusNewlyDocumented = tbCohortDefinitionLibrary.getPatientsWhoseHIVStatusIsNewlyDocumented();
        CohortDefinition newAndRelapsedPatientsWhoHaveHIVStatusNewlyDocumented= df.getPatientsInAll(newAndRelapsedRegisteredClients,HIVStatusNewlyDocumented);

        CohortDefinition newlyDiagnosedHIVPositive = tbCohortDefinitionLibrary.getPatientsWhoseHIVStatusIsNewlyPositive();
        CohortDefinition knownHIVPositive = tbCohortDefinitionLibrary.getPatientsWhoseHIVStatusIsKnownPositive();
        CohortDefinition newAndRelapsedPatientsWhoHaveKnownHIVPositive = df.getPatientsInAll(knownHIVPositive,newAndRelapsedRegisteredClients);

        CohortDefinition initiatedOnCPTDuringPeriod = tbCohortDefinitionLibrary.getPatientsOnCPTOnTBEnrollment();
        CohortDefinition initiatedOnARTDuringPeriod = tbCohortDefinitionLibrary.getPatientsStartedOnARTOnTBEnrollment();

        CohortDefinition noOfPatientsWithTreatmentSupporters =tbCohortDefinitionLibrary.getPatientsWithTreatmentSupporters();
        CohortDefinition patientsWhoAreHealthWorkers = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("5619AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreTBContacts = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("b5171d08-77bf-40a8-a864-51caa6cd2480")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreRefugees = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("165127AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoArePrisoners = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("162277AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreUniformedPeople = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("165125AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreFisherMen = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("159674AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreDiabetic = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("119481AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreMiners = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("952c6973-e163-4c0d-b6c8-a7071bd05e2a")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreSmokers = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("1455AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreMentallyIll = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("134337AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition transferredInTheQuarter = hivCohortDefinitionLibrary.getTransferredInToCareDuringPeriod();

        CohortDefinition havingArtStartDateDuringQuarter = hivCohortDefinitionLibrary.getArtStartDateBetweenPeriod();
        CohortDefinition havingArtStartDateBeforeQuarter = hivCohortDefinitionLibrary.getArtStartDateBeforePeriod();
        CohortDefinition clientsStartedOnARTAtThisFacilityDuringPeriod = df.getPatientsNotIn(havingArtStartDateDuringQuarter,transferredInTheQuarter);
        CohortDefinition clientsStartedOnARTAtThisFacilityBeforePeriod = df.getPatientsNotIn(havingArtStartDateBeforeQuarter,hivCohortDefinitionLibrary.getPatientsTransferredOutDuringPeriod());
        CohortDefinition noSignsOfTBDuringPeriod =  hivCohortDefinitionLibrary.getScreenedForTBNegativeDuringPeriod();
        CohortDefinition startedTPTDuringQuarter = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getConcept("483939c7-79ba-4ca4-8c3e-346488c97fc7"),hivMetadata.getARTSummaryPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWithTPTStartDate =  df.getPatientsWhoseObs(hivMetadata.getConcept("483939c7-79ba-4ca4-8c3e-346488c97fc7"),hivMetadata.getARTSummaryPageEncounterType());
        CohortDefinition patientsWithTPTEndDate =  df.getPatientsWhoseObs(hivMetadata.getConcept("813e21e7-4ccb-4fe9-aaab-3c0e40b6e356"),hivMetadata.getARTSummaryPageEncounterType());
        CohortDefinition patientsWithEitherTPTStartDateOrTPTEndDate = df.getPatientsInAny(patientsWithTPTStartDate,patientsWithTPTEndDate);
        CohortDefinition patientsEverOnART = df.getAnyEncounterOfTypesByEndOfDate(hivMetadata.getARTSummaryPageEncounterType());
        CohortDefinition patientsWithOutBothTPTStartAndEndDates = df.getPatientsNotIn(patientsEverOnART,patientsWithEitherTPTStartDateOrTPTEndDate);

        CohortDefinition eligibleForTPT = df.getPatientsInAny(startedTPTDuringQuarter,patientsWithOutBothTPTStartAndEndDates);

        CohortDefinition newOnARTEligbleForTPT = df.getPatientsInAll(clientsStartedOnARTAtThisFacilityDuringPeriod,noSignsOfTBDuringPeriod,eligibleForTPT);
        CohortDefinition alreadyOnARTEligbleForTPT = df.getPatientsInAll(clientsStartedOnARTAtThisFacilityBeforePeriod,noSignsOfTBDuringPeriod,eligibleForTPT);

        CohortDefinition bacteriallyConfirmedInPreviousQuarter = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getBacteriologicallyConfirmed()),"3m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition registeredInPreviousQuarter = tbCohortDefinitionLibrary.getEnrolledOnDSTBDuringPeriod("3m");
        CohortDefinition registeredAndBacteriallyConfirmedInPreviousQuarter = df.getPatientsInAll(bacteriallyConfirmedInPreviousQuarter,registeredInPreviousQuarter);
        CohortDefinition patientsWithSmearTestDoneAfterIntensivePhase = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dce0532c-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getEncounterTypeList("455bad1f-5e97-4ee9-9558-ff1df8808732"), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWithWithExaminationDateOfSmearTestDoneAfterIntensivePhase = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getConcept("d2f31713-aada-4d0d-9340-014b2371bdd8"),tbMetadata.getEncounterTypeList("455bad1f-5e97-4ee9-9558-ff1df8808732"), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition registeredInPreviousAndSmearDoneAfter2MonthsIntensiveTreatment = df.getPatientsInAll(registeredAndBacteriallyConfirmedInPreviousQuarter,patientsWithSmearTestDoneAfterIntensivePhase,patientsWithWithExaminationDateOfSmearTestDoneAfterIntensivePhase);

        CohortDefinition positiveSmearResults  =df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dce0532c-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getEncounterTypeList("455bad1f-5e97-4ee9-9558-ff1df8808732"),Arrays.asList(tbMetadata.getConcept("dcdab74d-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getConcept("dcdabb4b-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getConcept("dcdabf68-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition negativeSmearResults  =df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dce0532c-30ab-102d-86b0-7a5022ba4115"),tbMetadata.getEncounterTypeList("455bad1f-5e97-4ee9-9558-ff1df8808732"),Arrays.asList(tbMetadata.getConcept("dcdab32a-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition accessedGeneXpertTest = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("162203AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),getConcept("162204AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),getConcept("164104AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),getConcept("1138AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition registeredAndAccessedGeneXpertTestDuringPeriod = df.getPatientsInAll(registered,accessedGeneXpertTest);

        CohortDefinition geneXpertBaselineTestResultsMTBPositiveAndRifR = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("162203AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition geneXpertBaselineTestResultsMTBPositiveAndRifS = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("162204AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition geneXpertBaselineTestResultsMTBPositiveAndRifIndeterminate = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("164104AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition MTBTraceDetectedRRIndeterminate = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("164104AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition MTBNotDetected  = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("162202AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(getConcept("1138AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition registeredAYearAgo = df.getPatientsNotIn(df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),null,"12m", BaseObsCohortDefinition.TimeModifier.ANY),TBTransferInAYearAgo);

       CohortDefinition transferredto2ndLineTreatment = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(tbMetadata.getTransferredTo2ndLineTreatmentDate(),tbMetadata.getTBEnrollmentEncounterType(),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
       CohortDefinition curedOutcome = getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram(Arrays.asList(tbMetadata.getTBOutcomeCured()));
       CohortDefinition diedOutcome = getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram(Arrays.asList(tbMetadata.getTBOutcomeDied()));
       CohortDefinition treatmentCompletedOutcome = getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram(Arrays.asList(tbMetadata.getTBOutcomeTreatmentCompleted()));
       CohortDefinition treatmentFailureOutcome = getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram(Arrays.asList(tbMetadata.getTBOutcomeTreatmentFailure()));
       CohortDefinition LTFPOutcome = getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram(Arrays.asList(tbMetadata.getTBOutcomeLTFP()));

        add1AIndicators(dsd,"a","bacteria and registered ",bacteriologicallyConfirmedAndRegistered);
            add1AIndicators(dsd,"b","bacteria and on treatment",bacteriologicallyConfirmedAndStartedOnTratment);
            add1AIndicators(dsd,"c","clinicallyConfirmedAndRegistered",clinicallyConfirmedAndRegistered);
            add1AIndicators(dsd,"d","clinicallyConfirmedAndStartedOnTratment",clinicallyConfirmedAndStartedOnTratment);
            add1AIndicators(dsd,"e","EPTBConfirmedAndRegistered",EPTBConfirmedAndRegistered);
            add1AIndicators(dsd,"f","EPTBConfirmedAndStartedOnTratment",EPTBConfirmedAndStartedOnTratment);
            add1AIndicators(dsd,"g","assigned treatment supporter", noOfPatientsWithTreatmentSupporters);

            add1AIndicators(dsd1,"x","bacteria and registered children",df.getPatientsInAll(bacteriologicallyConfirmedAndRegistered,below15Years));
            add1AIndicators(dsd1,"h","bacteria and on treatment children",df.getPatientsInAll(bacteriologicallyConfirmedAndStartedOnTratment,below15Years));
            add1AIndicators(dsd1,"i","clinicallyConfirmedAndRegistered children",df.getPatientsInAll(clinicallyConfirmedAndRegistered,below15Years));
            add1AIndicators(dsd1,"j","clinicallyConfirmedAndStartedOnTratment children",df.getPatientsInAll(clinicallyConfirmedAndStartedOnTratment,below15Years));
            add1AIndicators(dsd1,"k","EPTBConfirmedAndRegistered children",df.getPatientsInAll(EPTBConfirmedAndRegistered,below15Years));
            add1AIndicators(dsd1,"l","EPTBConfirmedAndStartedOnTratment children",df.getPatientsInAll(EPTBConfirmedAndStartedOnTratment,below15Years));


            addGender(dsd2,"n","new relapsed and enrolled females",newAndRelapsedRegisteredClients);
            addGender(dsd2,"m","new relapsed and enrolled males ",newAndRelapsedRegisteredClients);

            splitGenderKeyAssigning(dsd3,"a","Total tested for HIV and with documented HIV Status ",newAndRelapsedPatientsWhoHaveHIVStatusNewlyDocumented);
            splitGenderKeyAssigning(dsd3,"b","newly Diagnosed HIV Positive ",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveHIVStatusNewlyDocumented,newlyDiagnosedHIVPositive));
            splitGenderKeyAssigning(dsd3,"c","initiated On CPT During Period",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveHIVStatusNewlyDocumented,newlyDiagnosedHIVPositive,initiatedOnCPTDuringPeriod));
            splitGenderKeyAssigning(dsd3,"d","initiated On ART During Period",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveHIVStatusNewlyDocumented,newlyDiagnosedHIVPositive,initiatedOnARTDuringPeriod));
            splitGenderKeyAssigning(dsd3,"e","total known HIV+",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveKnownHIVPositive));
            splitGenderKeyAssigning(dsd3,"f","total known HIV+ on CPT",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveKnownHIVPositive,tbCohortDefinitionLibrary.getPatientsOnCPT()));
            splitGenderKeyAssigning(dsd3,"g","total known HIV+ on ART",df.getPatientsInAll(newAndRelapsedPatientsWhoHaveKnownHIVPositive,tbCohortDefinitionLibrary.getPatientsWhoAreAlreadyOnART()));

            addIndicator(dsd4,"FDOT","FDOT",df.getPatientsInAll(tbCohortDefinitionLibrary.getPatientsOnFacilityDOTSTreatmentModel(),newAndRelapsedPatients),"");
            addIndicator(dsd4,"CDOT","CDOT",df.getPatientsInAll(tbCohortDefinitionLibrary.getPatientsOnCommunityDOTSTreatmentModel(),newAndRelapsedPatients),"");

            addIndicator(dsd5,"healthWorkers","health workers",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreHealthWorkers),"");
            addIndicator(dsd5,"TBContacts","contacts",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreTBContacts),"");
            addIndicator(dsd5,"Refugees","Refugees",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreRefugees),"");
            addIndicator(dsd5,"prisoners","prisoners",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoArePrisoners),"");
            addIndicator(dsd5,"uniformed","uniformed",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreUniformedPeople),"");
            addIndicator(dsd5,"fisher","fisher folks",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreFisherMen),"");
            addIndicator(dsd5,"diabetic","diabetic",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreDiabetic),"");
            addIndicator(dsd5,"miner","miner",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreMiners),"");
            addIndicator(dsd5,"smoker","smoker",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreSmokers),"");
            addIndicator(dsd5,"mental","mental",df.getPatientsInAll(newAndRelapsedPatients,patientsWhoAreMentallyIll),"");

            addIndicator(dsd6,"newMale1","newOnARTMale1",df.getPatientsInAll(newOnARTEligbleForTPT,males,cohortDefinitionLibrary.between0And4years()),"");
            addIndicator(dsd6,"newFemale1","newOnARTFemale1",df.getPatientsInAll(newOnARTEligbleForTPT,females,cohortDefinitionLibrary.between0And4years()),"");
            addIndicator(dsd6,"newMale2","newOnARTMale2",df.getPatientsInAll(newOnARTEligbleForTPT,males,cohortDefinitionLibrary.agedAtLeast(5)),"");
            addIndicator(dsd6,"newFemale2","newOnARTFemale2",df.getPatientsInAll(newOnARTEligbleForTPT,females,cohortDefinitionLibrary.agedAtLeast(5)),"");
            addIndicator(dsd6,"alreadyMale1","alreadyOnARTMale1",df.getPatientsInAll(alreadyOnARTEligbleForTPT,males,cohortDefinitionLibrary.between0And4years()),"");
            addIndicator(dsd6,"alreadyFemale1","alreadyOnARTFemale1",df.getPatientsInAll(alreadyOnARTEligbleForTPT,females,cohortDefinitionLibrary.between0And4years()),"");
            addIndicator(dsd6,"alreadyMale2","alreadyOnARTMale2",df.getPatientsInAll(alreadyOnARTEligbleForTPT,males,cohortDefinitionLibrary.agedAtLeast(5)),"");
            addIndicator(dsd6,"alreadyFemale2","alreadyOnARTFemale2",df.getPatientsInAll(alreadyOnARTEligbleForTPT,females,cohortDefinitionLibrary.agedAtLeast(5)),"");

            addIndicator(dsd7, "A","all registered with PTB previous quarter ",registeredAndBacteriallyConfirmedInPreviousQuarter,"");
            addIndicator(dsd7, "B","all registered with PTB previous quarter that had smear test done ",registeredInPreviousAndSmearDoneAfter2MonthsIntensiveTreatment,"");
            addIndicator(dsd7, "C"," had smear test done with negative results ",df.getPatientsInAll(registeredInPreviousAndSmearDoneAfter2MonthsIntensiveTreatment,negativeSmearResults),"");
            addIndicator(dsd7, "D"," had smear test done with postive results ",df.getPatientsInAll(registeredInPreviousAndSmearDoneAfter2MonthsIntensiveTreatment,positiveSmearResults),"");

            add1AIndicators(dsd8,"o","total accessed Genexpert at baseline ",registeredAndAccessedGeneXpertTestDuringPeriod);
            add1AIndicators(dsd8,"p","MTB positive Rif S ",df.getPatientsInAll(registeredAndAccessedGeneXpertTestDuringPeriod,geneXpertBaselineTestResultsMTBPositiveAndRifS));
            add1AIndicators(dsd8,"q","MTB positive Rif R",df.getPatientsInAll(registeredAndAccessedGeneXpertTestDuringPeriod,geneXpertBaselineTestResultsMTBPositiveAndRifR));
            add1AIndicators(dsd8,"r","MTB positive Rif Indeterminant",df.getPatientsInAll(registeredAndAccessedGeneXpertTestDuringPeriod,geneXpertBaselineTestResultsMTBPositiveAndRifIndeterminate));
//            add1AIndicators(dsd8,"s","MTB  detected RR indeterminant",df.getPatientsInAll(registeredAndAccessedGeneXpertTestDuringPeriod,MTBTraceDetectedRRIndeterminate));
            add1AIndicators(dsd8,"u","MTB not detected",df.getPatientsInAll(registeredAndAccessedGeneXpertTestDuringPeriod,MTBNotDetected));

             addCohortAnalysisIndicatorColumns(dsd9, "aa","aa", df.getPatientsInAll(males,registeredAYearAgo));
             addCohortAnalysisIndicatorColumns(dsd9, "bb","bb", df.getPatientsInAll(females,registeredAYearAgo));
            addCohortAnalysisIndicatorColumns(dsd9, "cc","cc", df.getPatientsInAll(males,transferredto2ndLineTreatment));
            addCohortAnalysisIndicatorColumns(dsd9, "dd","dd", df.getPatientsInAll(females,transferredto2ndLineTreatment));
            addCohortAnalysisIndicatorColumns(dsd9, "ee","ee", df.getPatientsInAll(males,curedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "ff","ff", df.getPatientsInAll(females,curedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "gg","gg", df.getPatientsInAll(males,treatmentCompletedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "hh","hh", df.getPatientsInAll(females,treatmentCompletedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "ii","ii", df.getPatientsInAll(males,diedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "jj","jj", df.getPatientsInAll(females,diedOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "kk","kk", df.getPatientsInAll(males,treatmentFailureOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "ll","ll", df.getPatientsInAll(females,treatmentFailureOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "mm","mm", df.getPatientsInAll(males,LTFPOutcome));
            addCohortAnalysisIndicatorColumns(dsd9, "nn","nn", df.getPatientsInAll(females,LTFPOutcome));

        addCohortAnalysisIndicatorColumns(dsd10, "aa","aa", df.getPatientsInAll(males,registeredAYearAgo));
        addCohortAnalysisIndicatorColumns(dsd10, "bb","bb", df.getPatientsInAll(females,registeredAYearAgo));
        addCohortAnalysisIndicatorColumns(dsd10, "cc","cc", df.getPatientsInAll(males,transferredto2ndLineTreatment));
        addCohortAnalysisIndicatorColumns(dsd10, "dd","dd", df.getPatientsInAll(females,transferredto2ndLineTreatment));
        addCohortAnalysisIndicatorColumns(dsd10, "ee","ee", df.getPatientsInAll(males,curedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "ff","ff", df.getPatientsInAll(females,curedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "gg","gg", df.getPatientsInAll(males,treatmentCompletedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "hh","hh", df.getPatientsInAll(females,treatmentCompletedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "ii","ii", df.getPatientsInAll(males,diedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "jj","jj", df.getPatientsInAll(females,diedOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "kk","kk", df.getPatientsInAll(males,treatmentFailureOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "ll","ll", df.getPatientsInAll(females,treatmentFailureOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "mm","mm", df.getPatientsInAll(males,LTFPOutcome));
        addCohortAnalysisIndicatorColumns(dsd10, "nn","nn", df.getPatientsInAll(females,LTFPOutcome));


        return rd;
    }



    public void add1AIndicators(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition) {
        addIndicator(dsd, "1"+key , label + " new  ", cohortDefinition, "type=newPatients");
        addIndicator(dsd, "2"+key , label + " relapsed ", cohortDefinition, "type=relapsedPatients");
        addIndicator(dsd, "3"+key , label + " treatedAfterLTFP", cohortDefinition, "type=treatedAfterLTFP");
        addIndicator(dsd, "4"+key , label + " treatedAfterFailure ", cohortDefinition, "type=treatedAfterFailure");
        addIndicator(dsd, "5"+key , label + " treatementHistoryUnknown", cohortDefinition, "type=treatementHistoryUnknown");
        addIndicator(dsd, "6"+key , label + " overall", cohortDefinition, "");
        addIndicator(dsd, "7"+key , label + " Referred from Community activities", cohortDefinition, "type=referred");
    }

    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition, String dimensionOptions) {
        CohortIndicator ci = new CohortIndicator();
        ci.addParameter(ReportingConstants.START_DATE_PARAMETER);
        ci.addParameter(ReportingConstants.END_DATE_PARAMETER);
        ci.setType(CohortIndicator.IndicatorType.COUNT);
        ci.setCohortDefinition(Mapped.mapStraightThrough(cohortDefinition));
        dsd.addColumn(key, label, Mapped.mapStraightThrough(ci), dimensionOptions);
    }



    public void addGender(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition) {
        if (key == "n") {
            addIndicator(dsd, "2n", label, cohortDefinition, "age=below1female");
            addIndicator(dsd, "3n", label, cohortDefinition, "age=between1and4female");
            addIndicator(dsd, "4n", label, cohortDefinition, "age=between5and9female");
            addIndicator(dsd, "5n", label, cohortDefinition, "age=between10and14female");
            addIndicator(dsd, "6n", label, cohortDefinition, "age=between15and19female");
            addIndicator(dsd, "7n", label, cohortDefinition, "age=between20and24female");
            addIndicator(dsd, "8n", label, cohortDefinition, "age=between25and29female");
            addIndicator(dsd, "9n", label, cohortDefinition, "age=between30and34female");
            addIndicator(dsd, "10n", label, cohortDefinition, "age=between35and39female");
            addIndicator(dsd, "11n", label, cohortDefinition, "age=between40and44female");
            addIndicator(dsd, "12n", label, cohortDefinition, "age=between45and49female");
            addIndicator(dsd, "13n", label, cohortDefinition, "age=above50female");
        } else if (key == "m") {
            addIndicator(dsd, "2m", label, cohortDefinition, "age=below1male");
            addIndicator(dsd, "3m", label, cohortDefinition, "age=between1and4male");
            addIndicator(dsd, "4m", label, cohortDefinition, "age=between5and9male");
            addIndicator(dsd, "5m", label, cohortDefinition, "age=between10and14male");
            addIndicator(dsd, "6m", label, cohortDefinition, "age=between15and19male");
            addIndicator(dsd, "7m", label, cohortDefinition, "age=between20and24male");
            addIndicator(dsd, "8m", label, cohortDefinition, "age=between25and29male");
            addIndicator(dsd, "9m", label, cohortDefinition, "age=between30and34male");
            addIndicator(dsd, "10m", label, cohortDefinition, "age=between35and39male");
            addIndicator(dsd, "11m", label, cohortDefinition, "age=between40and44male");
            addIndicator(dsd, "12m", label, cohortDefinition, "age=between45and49male");
            addIndicator(dsd, "13m", label, cohortDefinition, "age=above50male");
        }
    }

    public void addOtherDimensionWithKey(CohortIndicatorDataSetDefinition dsd,String dimensionKey, String key, String label, CohortDefinition cohortDefinition) {
        if (key == "n") {
            addIndicator(dsd, dimensionKey+"2n", label, cohortDefinition, "age=below1female");
            addIndicator(dsd, dimensionKey+"3n", label, cohortDefinition, "age=between1and4female");
            addIndicator(dsd, dimensionKey+"4n", label, cohortDefinition, "age=between5and9female");
            addIndicator(dsd, dimensionKey+"5n", label, cohortDefinition, "age=between10and14female");
            addIndicator(dsd, dimensionKey+"6n", label, cohortDefinition, "age=between15and19female");
            addIndicator(dsd, dimensionKey+"7n", label, cohortDefinition, "age=between20and24female");
            addIndicator(dsd, dimensionKey+"8n", label, cohortDefinition, "age=between25and29female");
            addIndicator(dsd, dimensionKey+"9n", label, cohortDefinition, "age=between30and34female");
            addIndicator(dsd, dimensionKey+"10n", label, cohortDefinition, "age=between35and39female");
            addIndicator(dsd, dimensionKey+"11n", label, cohortDefinition, "age=between40and44female");
            addIndicator(dsd, dimensionKey+"12n", label, cohortDefinition, "age=between45and49female");
            addIndicator(dsd, dimensionKey+"13n", label, cohortDefinition, "age=above50female");
        } else if (key == "m") {
            addIndicator(dsd, dimensionKey+"2m", label, cohortDefinition, "age=below1male");
            addIndicator(dsd, dimensionKey+"3m", label, cohortDefinition, "age=between1and4male");
            addIndicator(dsd, dimensionKey+"4m", label, cohortDefinition, "age=between5and9male");
            addIndicator(dsd, dimensionKey+"5m", label, cohortDefinition, "age=between10and14male");
            addIndicator(dsd, dimensionKey+"6m", label, cohortDefinition, "age=between15and19male");
            addIndicator(dsd, dimensionKey+"7m", label, cohortDefinition, "age=between20and24male");
            addIndicator(dsd, dimensionKey+"8m", label, cohortDefinition, "age=between25and29male");
            addIndicator(dsd, dimensionKey+"9m", label, cohortDefinition, "age=between30and34male");
            addIndicator(dsd, dimensionKey+"10m", label, cohortDefinition, "age=between35and39male");
            addIndicator(dsd, dimensionKey+"11m", label, cohortDefinition, "age=between40and44male");
            addIndicator(dsd, dimensionKey+"12m", label, cohortDefinition, "age=between45and49male");
            addIndicator(dsd, dimensionKey+"13m", label, cohortDefinition, "age=above50male");
        }
    }

    public void splitGenderKeyAssigning(CohortIndicatorDataSetDefinition dsd,String dimensionKey,String label,CohortDefinition cohortDefinition){
        addOtherDimensionWithKey(dsd,dimensionKey,"n",label+" females",cohortDefinition);
        addOtherDimensionWithKey(dsd,dimensionKey,"m",label+" males",cohortDefinition);

    }

    private CohortDefinition getFirstTBOutComeAfterStartOfTBProgramForPreviousProgram( List<Concept> codedValues){
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.FIRST);
        cd.setQuestion(tbMetadata.getTreatmentOutcome());
        cd.setEncounterTypeList(tbMetadata.getTBFollowupEncounterType());
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate-12m"));
    }

    private void addCohortAnalysisIndicatorColumns(CohortIndicatorDataSetDefinition dsd, String dimensionKey,String label, CohortDefinition cohortDefinition){
        addIndicator(dsd, "1"+dimensionKey, label, cohortDefinition, "indicator=19a");
        addIndicator(dsd, "2"+dimensionKey, label, cohortDefinition, "indicator=19b");
        addIndicator(dsd, "3"+dimensionKey, label, cohortDefinition, "indicator=19c");
        addIndicator(dsd, "4"+dimensionKey, label, cohortDefinition, "indicator=total");
        addIndicator(dsd, "5"+dimensionKey, label, cohortDefinition, "indicator=19d");
        addIndicator(dsd, "6"+dimensionKey, label, cohortDefinition, "indicator=19e");
        addIndicator(dsd, "7"+dimensionKey, label, cohortDefinition, "indicator=19f");
        addIndicator(dsd, "8"+dimensionKey, label, cohortDefinition, "indicator=20a");
        addIndicator(dsd, "9"+dimensionKey, label, cohortDefinition, "indicator=20b");
        addIndicator(dsd, "10"+dimensionKey, label, cohortDefinition, "indicator=20c");

    }

    public CohortDefinitionDimension getTBCohortAnalysisIndicators(){
        CohortDefinitionDimension indicatorDimension= new CohortDefinitionDimension();

        CohortDefinition TBTransferInAYearAgo = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(getConcept("34c5cbad-681a-4aca-bcc3-c7ddd2a88db8"), tbMetadata.getTBEnrollmentEncounterType(),"12m", BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition registeredAYearAgo = df.getPatientsNotIn( tbCohortDefinitionLibrary.getEnrolledOnDSTBDuringPeriod("12m"),TBTransferInAYearAgo);
        CohortDefinition newAndRelapsedPatientsAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewPatientType(),tbMetadata.getRelapsedPatientType()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition registeredAndNewAndRelapsedPatientsAYearAgo = df.getPatientsInAll(registeredAYearAgo,newAndRelapsedPatientsAYearAgo);

        CohortDefinition bacteriologicallyConfirmedAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getBacteriologicallyConfirmed()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition clinicallyConfirmedAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getClinicallyDiagnosed()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition EPTBConfirmedAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getPatientType(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getEPTB()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);


        CohortDefinition treatmentAfterLostToFollowupOrTreatmentAfterFailureAyearAgo =  df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getTreatmentAfterLTFPPatientType(),tbMetadata.getTreatmentAfterFailurePatientType()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition treatmentHistoryUnknownAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTypeOfPatient(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getTreatmentHistoryUnknownPatientType()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition communityDOTSAYearAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getTreatmentModel(),null,Arrays.asList(tbMetadata.getDigitalCommunityDOTsTreatmentModel(),tbMetadata.getNonDigitalCommunityDOTsTreatmentModel()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition allKnownHIVPositiveAtEndOfTreatment = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getHIVStatusCategory(),tbMetadata.getTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getNewlyPositiveHIVStatus(),tbMetadata.getKnownPositiveHIVStatus()),"12m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition childrenNewAndRelapsePatients = df.getPatientsInAll(cohortDefinitionLibrary.agedAtMost(14,"12m"),newAndRelapsedPatientsAYearAgo);
        CohortDefinition childrenKnownHIVPositivePatients = df.getPatientsInAll(cohortDefinitionLibrary.agedAtMost(14,"12m"),allKnownHIVPositiveAtEndOfTreatment);

        indicatorDimension.addParameter(ReportingConstants.START_DATE_PARAMETER);
        indicatorDimension.addParameter(ReportingConstants.END_DATE_PARAMETER);

        indicatorDimension.addCohortDefinition("19a", Mapped.mapStraightThrough(df.getPatientsInAll(registeredAndNewAndRelapsedPatientsAYearAgo,bacteriologicallyConfirmedAYearAgo)));
        indicatorDimension.addCohortDefinition("19b", Mapped.mapStraightThrough(df.getPatientsInAll(registeredAndNewAndRelapsedPatientsAYearAgo,clinicallyConfirmedAYearAgo)));
        indicatorDimension.addCohortDefinition("19c", Mapped.mapStraightThrough(df.getPatientsInAll(registeredAndNewAndRelapsedPatientsAYearAgo,EPTBConfirmedAYearAgo)));
        indicatorDimension.addCohortDefinition("total", Mapped.mapStraightThrough(registeredAndNewAndRelapsedPatientsAYearAgo));
        indicatorDimension.addCohortDefinition("19d", Mapped.mapStraightThrough(treatmentAfterLostToFollowupOrTreatmentAfterFailureAyearAgo));
        indicatorDimension.addCohortDefinition("19e", Mapped.mapStraightThrough(treatmentHistoryUnknownAYearAgo));
        indicatorDimension.addCohortDefinition("19f", Mapped.mapStraightThrough(communityDOTSAYearAgo));
        indicatorDimension.addCohortDefinition("20a", Mapped.mapStraightThrough(allKnownHIVPositiveAtEndOfTreatment));
        indicatorDimension.addCohortDefinition("20b", Mapped.mapStraightThrough(childrenNewAndRelapsePatients));
        indicatorDimension.addCohortDefinition("20c", Mapped.mapStraightThrough(childrenKnownHIVPositivePatients));

        return indicatorDimension;
    }

        @Override
    public String getVersion() {
        return "1.2.0";
    }
}
