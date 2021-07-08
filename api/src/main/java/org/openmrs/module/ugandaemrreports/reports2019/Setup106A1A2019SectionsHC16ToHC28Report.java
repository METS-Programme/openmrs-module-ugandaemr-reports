package org.openmrs.module.ugandaemrreports.reports2019;

import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.RangeComparator;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.MedianBaselineCD4DatasetDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.openmrs.module.ugandaemrreports.reports.UgandaEMRDataExportManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

/**
 */
@Component
public class Setup106A1A2019SectionsHC16ToHC28Report extends UgandaEMRDataExportManager {
    @Autowired
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private CommonCohortDefinitionLibrary commonCohortDefinitionLibrary;

    @Autowired
    private DataFactory df;

    @Autowired
    private HIVMetadata hivMetadata;

    @Override
    public String getExcelDesignUuid() {
        return "795b670f-4d90-402d-9233-defa34727f39";
    }

    @Override
    public String getUuid() {
        return "0e3bdfde-3ee0-4f94-b105-bff844feba30";
    }

    @Override
    public String getName() {
        return "HMIS 106A1A 2019 Sections HC16 To HC28";
    }

    @Override
    public String getDescription() {
        return "This is the 2019 version of the HMIS 106A Section 1A SectionsHC16ToHC28 ";
    }

    @Override
    public List<Parameter> getParameters() {
        List<Parameter> l = new ArrayList<Parameter>();
        l.add(new Parameter("startDate", "Start date (Start of quarter)", Date.class));
        l.add(new Parameter("endDate", "End date (End of quarter)", Date.class));
        return l;
    }

    @Override
    public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
        return Arrays.asList(buildReportDesign(reportDefinition));
    }

    @Override
    public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "106A1A2019HC16ToHC28Report.xls");
    }

    @Override
    public ReportDefinition constructReportDefinition() {
        ReportDefinition rd = new ReportDefinition();
        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        rd.addDataSetDefinition("m",Mapped.mapStraightThrough(getMedianCD4AtARTInitiation()));
        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("x", Mapped.mapStraightThrough(dsd));

        CohortDefinitionDimension finerAgeDisaggregations = commonDimensionLibrary.getFinerAgeDisaggregations();
        dsd.addDimension("age", Mapped.mapStraightThrough(finerAgeDisaggregations));

        CohortDefinition enrolledBeforeQuarter = hivCohortDefinitionLibrary.getEnrolledInCareByEndOfPreviousDate();
        CohortDefinition enrolledInTheQuarter = hivCohortDefinitionLibrary.getEnrolledInCareBetweenDates();

        CohortDefinition transferredInTheQuarter = hivCohortDefinitionLibrary.getTransferredInToCareDuringPeriod();
        CohortDefinition transferredInBeforeQuarter = hivCohortDefinitionLibrary.getTransferredInToCareBeforePeriod();

        CohortDefinition havingArtStartDateDuringQuarter = hivCohortDefinitionLibrary.getArtStartDateBetweenPeriod();
        CohortDefinition clientsStartedOnARTAtThisFacilityDuringPeriod = df.getPatientsNotIn(havingArtStartDateDuringQuarter,transferredInTheQuarter);
        CohortDefinition havingArtStartDateBeforeQuarter = hivCohortDefinitionLibrary.getArtStartDateBeforePeriod();


        CohortDefinition onTBRxDuringQuarter = hivCohortDefinitionLibrary.getPatientsOnTBRxDuringPeriod();

        CohortDefinition baseCD4L200 = df.getPatientsWithNumericObsDuringPeriod(hivMetadata.getBaselineCD4(), hivMetadata.getARTSummaryPageEncounterType(),RangeComparator.LESS_EQUAL, 200.0, BaseObsCohortDefinition.TimeModifier.FIRST);

        CohortDefinition childrenOnFirstLineDuringQuarter = df.getPatientsInAll(commonCohortDefinitionLibrary.MoHChildren(), hivCohortDefinitionLibrary.getChildrenOnFirstLineRegimenDuringPeriod());
        CohortDefinition childrenOnSecondLineDuringQuarter = df.getPatientsInAll(commonCohortDefinitionLibrary.MoHChildren(), hivCohortDefinitionLibrary.getChildrenOnSecondLineRegimenDuringPeriod());

        CohortDefinition adultsOnFirstLineDuringQuarter = df.getPatientsInAll(commonCohortDefinitionLibrary.MoHAdult(), hivCohortDefinitionLibrary.getAdultsOnFirstLineRegimenDuringPeriod());
        CohortDefinition adultsOnSecondLineDuringQuarter = df.getPatientsInAll(commonCohortDefinitionLibrary.MoHAdult(), hivCohortDefinitionLibrary.getAdultsOnSecondLineRegimenDuringPeriod());

        CohortDefinition onThirdLineRegimenDuringQuarter = hivCohortDefinitionLibrary.getPatientsOnThirdLineRegimenDuringPeriod();


        CohortDefinition everEnrolledByEndQuarter = df.getPatientsNotIn(enrolledBeforeQuarter, enrolledInTheQuarter);
        CohortDefinition transferredOutPatients = hivCohortDefinitionLibrary.getPatientsTransferredOutBetweenStartAndEndDate();
        CohortDefinition deadPatientsDuringPeriod =df.getPatientsInAll(everEnrolledByEndQuarter, df.getDeadPatientsDuringPeriod());
        CohortDefinition lost_to_followup = hivCohortDefinitionLibrary.getPatientsTxLostToFollowupByDays("90");

         CohortDefinition activePatientsInCareDuringPeriod = hivCohortDefinitionLibrary.getActivePatientsWithLostToFollowUpAsByDays("90");

        CohortDefinition onFirstLineRegimen = df.getPatientsInAll(activePatientsInCareDuringPeriod, df.getPatientsInAny(childrenOnFirstLineDuringQuarter, adultsOnFirstLineDuringQuarter));
        CohortDefinition onSecondLineRegimen = df.getPatientsInAll(activePatientsInCareDuringPeriod, df.getPatientsInAny(childrenOnSecondLineDuringQuarter, adultsOnSecondLineDuringQuarter));


        CohortDefinition clientsStartedOnARTAtThisFacilityBeforePeriod = df.getPatientsNotIn(havingArtStartDateBeforeQuarter,transferredInBeforeQuarter);
        CohortDefinition accessedTBLAM = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.TB_LAM_RESULTS),hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition accessedCRAG = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.CRAG_RESULTS),hivMetadata.getARTEncounterPageEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition positiveForTBLAM = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.TB_LAM_RESULTS),hivMetadata.getARTEncounterPageEncounterType(),Arrays.asList(Dictionary.getConcept(Metadata.Concept.POSITIVE)), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition positiveForCRAG = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept(Metadata.Concept.CRAG_RESULTS),hivMetadata.getARTEncounterPageEncounterType(),Arrays.asList(Dictionary.getConcept(Metadata.Concept.POSITIVE)), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsPositiveForTBLAMAndTreatedForTB= df.getPatientsInAll(positiveForTBLAM,onTBRxDuringQuarter);
        CohortDefinition patientsWithNoClinicalContactSinceLastExpectedContact=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                hivMetadata.getNoClinicalContactOutcomes(), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition onFluconazoleTreatment = df.getPatientsWithNumericObsDuringPeriod(Dictionary.getConcept("7dea17d4-17eb-43b6-8029-785aeb6aa453"), hivMetadata.getARTEncounterPageEncounterType(),RangeComparator.GREATER_THAN, 0.0, BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition cumulativeOnArt = df.getPatientsInAny( clientsStartedOnARTAtThisFacilityBeforePeriod,clientsStartedOnARTAtThisFacilityDuringPeriod);

        CohortDefinition patientWithConfirmedAdvancedDiseaseByEndDate = hivCohortDefinitionLibrary.getPatientsWithConfirmedAdvancedDiseaseByEndDate();
        CohortDefinition newClientsWithBaselineCd4LessEqual200 = df.getPatientsInAll(clientsStartedOnARTAtThisFacilityDuringPeriod,baseCD4L200);
             CohortDefinition silentlyTransferred=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
              Arrays.asList(hivMetadata.getConcept("f57b1500-7ff2-46b4-b183-fed5bce479a9")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition incompleteTracingAttempts=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("1a467610-b640-4d9b-bc13-d2631fa57a45")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition unableToBeLocated=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("8b386488-9494-4bb6-9537-dcad6030fab0")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition stoppedARVTaking=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("dca26b47-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition noAttemptToTrace=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("b192a41c-f7e8-47a9-89c5-62e7a4bffddd")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition diedTraceOutcome=df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("8f889d84-8e5c-4a66-970d-458d6d01e8a4"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("160034AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition diedOfTB =df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("dc6527eb-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfCancer = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("116030AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfInfectiousDiseases = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("73d67c86-06df-4863-9819-ccb2a6bb98f8")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfNonInfectiousDiseases = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("13a7b84b-b661-48a5-8315-0bcc0174e5c8")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfNaturalCauses = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("84899c95-d455-4293-be6f-7db600af058f")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfNonNaturalCauses = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("ab115b14-8a9f-4185-9deb-79c214dc1063")), BaseObsCohortDefinition.TimeModifier.LAST);
        CohortDefinition diedOfUnknown =df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("dca2c3f2-30ab-102d-86b0-7a5022ba4115"),hivMetadata.getMissedAppointmentEncounterType(),
                Arrays.asList(hivMetadata.getConcept("dcd6865a-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.LAST);
        // 2019 Report Cohorts

        CohortDefinition newClientsWithBaselineCd4LessEqual200AndAccessedTBLAM= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,accessedTBLAM);
        CohortDefinition newClientsWithBaselineCd4LessEqual200AndPositiveForTBLAM= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,positiveForTBLAM);
        CohortDefinition newClientsWithBaselineCd4LessEqual200AndPositiveForTBLAMAndTreatedForTB= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,patientsPositiveForTBLAMAndTreatedForTB);
        CohortDefinition newClientsWithBaselineCd4LessEqual200AndAccessedCRAG= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,accessedCRAG);
        CohortDefinition newClientsWithBaselineCd4LessEqual200AndPositiveForCRAG= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,positiveForCRAG);
        CohortDefinition activeClientsWithConfirmedAdvancedDiseaseByEndOfReportingPeriod = df.getPatientsInAll(patientWithConfirmedAdvancedDiseaseByEndDate,activePatientsInCareDuringPeriod);
        CohortDefinition newClientsWithBaselineCd4LessEqual200AndPositiveForCRAGTreatedWithFluconazole= df.getPatientsInAll(newClientsWithBaselineCd4LessEqual200,positiveForCRAG,onFluconazoleTreatment);



        addAgeGender(dsd, "16a-", "new clients accessed TB LAM", newClientsWithBaselineCd4LessEqual200AndAccessedTBLAM );
        addAgeGender(dsd, "16b-", "new clients positive for TB LAM", newClientsWithBaselineCd4LessEqual200AndPositiveForTBLAM);
        addAgeGender(dsd, "16c-", "new clients positive for TB LAM treated foe TB LAM", newClientsWithBaselineCd4LessEqual200AndPositiveForTBLAMAndTreatedForTB);
        addAgeGender(dsd, "16d-", "new clients accesses CRAG", newClientsWithBaselineCd4LessEqual200AndAccessedCRAG);
        addAgeGender(dsd, "16e-", "new clients positive for CRAG", newClientsWithBaselineCd4LessEqual200AndPositiveForCRAG);
        addAgeGender(dsd, "16f-", "new clients positive for CRAG treated with fluconazole", newClientsWithBaselineCd4LessEqual200AndPositiveForCRAGTreatedWithFluconazole );
        addAgeGender(dsd, "17", "cumulative no of individuals ever started on ART", cumulativeOnArt);
        addAgeGender(dsd, "18", "active on 1st line", onFirstLineRegimen);
        addAgeGender(dsd, "19", "active on 2nd line", onSecondLineRegimen);
        addAgeGender(dsd, "20", "active on 3rd line", onThirdLineRegimenDuringQuarter);
        addAgeGender(dsd, "21", "No. of active clients with confirmed Advanced Disease By end of quarter",activeClientsWithConfirmedAdvancedDiseaseByEndOfReportingPeriod);
        addAgeGender(dsd, "22", "no of ART Clients transferred in during quarter", transferredInTheQuarter);
        addAgeGender(dsd, "23", "no of ART Clients that died in the quarter", deadPatientsDuringPeriod);
        addAgeGender(dsd, "24", "no of ART Clients that were lost to follow up",lost_to_followup);
        addAgeGender(dsd, "25", "no of ART Clients that were transferred out during period", transferredOutPatients);
        addAgeGender(dsd, "26", "clients with no clinical contact since last expected contact by the end of quarter", patientsWithNoClinicalContactSinceLastExpectedContact);
        addAgeGender(dsd, "27a-", "clients with no clinical contact since last expected contact silently transfered", silentlyTransferred);
        addAgeGender(dsd, "27b-", "clients with no clinical contact since last expected contact incompleteTracingAttempts",incompleteTracingAttempts);
        addAgeGender(dsd, "27c-", "clients with no clinical contact since last expected contact unableToBeLocated",unableToBeLocated);
        addAgeGender(dsd, "27d-", "clients with no clinical contact since last expected contact stoppedARVTaking",stoppedARVTaking);
        addAgeGender(dsd, "27e-", "clients with no clinical contact since last expected contact noAttemptToTrace",noAttemptToTrace);
        addAgeGender(dsd, "27f-", "clients with no clinical contact since last expected contact died",diedTraceOutcome);
        addAgeGender(dsd, "28a-", "clients with no clinical contact since last expected contact died cause of 1 TB",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfTB));
        addAgeGender(dsd, "28b-", "clients with no clinical contact since last expected contact died cause of 2 cancer",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfCancer));
        addAgeGender(dsd, "28c-", "clients with no clinical contact since last expected contact died cause of 3 infectious disease",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfInfectiousDiseases));
        addAgeGender(dsd, "28d-", "clients with no clinical contact since last expected contact died cause of 4 HIV non infectious disease",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfNonInfectiousDiseases));
        addAgeGender(dsd, "28e-", "clients with no clinical contact since last expected contact died cause of 5 natural causes",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfNaturalCauses));
        addAgeGender(dsd, "28f-", "clients with no clinical contact since last expected contact died cause of 6 non natural causes",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfNonNaturalCauses));
        addAgeGender(dsd, "28g-", "clients with no clinical contact since last expected contact died cause of 7 unknown",df.getPatientsInAll(deadPatientsDuringPeriod,diedOfUnknown));


        return rd;
    }

    private void addAgeGender(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition) {
        addIndicator(dsd, key + "a", label + " (Below 1 Males)", cohortDefinition, "age=below1male");
        addIndicator(dsd, key + "b", label + " (Below 1 Females)", cohortDefinition, "age=below1female");
        addIndicator(dsd, key + "c", label + " (Between 1 and 1 Males)", cohortDefinition, "age=between1and4male");
        addIndicator(dsd, key + "d", label + " (Between 1 and 4 Females)", cohortDefinition, "age=between1and4female");
        addIndicator(dsd, key + "e", label + " (Between 5 and 9 Males)", cohortDefinition, "age=between5and9male");
        addIndicator(dsd, key + "f", label + " (Between 5 and 9 Females)", cohortDefinition, "age=between5and9female");
        addIndicator(dsd, key + "g", label + " (Between 10 and 14 Males)", cohortDefinition, "age=between10and14male");
        addIndicator(dsd, key + "h", label + " (Between 10 and 14 Females)", cohortDefinition, "age=between10and14female");
        addIndicator(dsd, key + "i", label + " (Between 15 and 19 Males)", cohortDefinition, "age=between15and19male");
        addIndicator(dsd, key + "j", label + " (Between 15 and 19 Females)", cohortDefinition, "age=between15and19female");
        addIndicator(dsd, key + "k", label + " (Between 20 and 24 Males)", cohortDefinition, "age=between20and24male");
        addIndicator(dsd, key + "l", label + " (Between 20 and 24 Females)", cohortDefinition, "age=between20and24female");
        addIndicator(dsd, key + "m", label + " (Between 25 and 29 Males)", cohortDefinition, "age=between25and29male");
        addIndicator(dsd, key + "n", label + " (Between 25 and 29 Females)", cohortDefinition, "age=between25and29female");
        addIndicator(dsd, key + "o", label + " (Between 30 and 34 Males)", cohortDefinition, "age=between30and34male");
        addIndicator(dsd, key + "p", label + " (Between 30 and 34 Females)", cohortDefinition, "age=between30and34female");
        addIndicator(dsd, key + "q", label + " (Between 35 and 39 Males)", cohortDefinition, "age=between35and39male");
        addIndicator(dsd, key + "r", label + " (Between 35 and 39 Females)", cohortDefinition, "age=between35and39female");
        addIndicator(dsd, key + "s", label + " (Between 40 and 44 Males)", cohortDefinition, "age=between40and44male");
        addIndicator(dsd, key + "t", label + " (Between 40 and 44 Females)", cohortDefinition, "age=between40and44female");
        addIndicator(dsd, key + "u", label + " (Between 45 and 49 Males)", cohortDefinition, "age=between45and49male");
        addIndicator(dsd, key + "v", label + " (Between 45 and 49 Females)", cohortDefinition, "age=between45and49female");
        addIndicator(dsd, key + "w", label + " (Above 50 Males)", cohortDefinition, "age=above50male");
        addIndicator(dsd, key + "x", label + " (Above 50 Females)", cohortDefinition, "age=above50female");
        addIndicator(dsd, key + "y", label + " Total", cohortDefinition, "");
    }

    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition, String dimensionOptions) {
        CohortIndicator ci = new CohortIndicator();
        ci.addParameter(ReportingConstants.START_DATE_PARAMETER);
        ci.addParameter(ReportingConstants.END_DATE_PARAMETER);
        ci.setType(CohortIndicator.IndicatorType.COUNT);
        ci.setCohortDefinition(Mapped.mapStraightThrough(cohortDefinition));
        dsd.addColumn(key, label, Mapped.mapStraightThrough(ci), dimensionOptions);
    }

    public CohortDefinition addParameters(CohortDefinition cohortDefinition){
        return   df.convert(cohortDefinition, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    private DataSetDefinition getMedianCD4AtARTInitiation() {
        MedianBaselineCD4DatasetDefinition dsd = new MedianBaselineCD4DatasetDefinition();
       dsd.setParameters(getParameters());
        return dsd;
    }

    @Override
    public String getVersion() {
        return "1.0.2";
    }
}
