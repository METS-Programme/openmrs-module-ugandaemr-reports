package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.RangeComparator;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 *  TX Current Report
 */
@Component
public class SetupTxCurrent_90Days2019Report extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    private SetupTxNewReport setupTxNewReport;
    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonCohortDefinitionLibrary cohortDefinitionLibrary;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "0b5d6aad-ca33-49a7-9a5c-718941d1c02d";
    }

    @Override
    public String getUuid() {
        return "214fb8ef-6219-43f3-b20b-023261c0dec6";
    }

    @Override
    public String getName() {
        return "Tx_Current90Days 2019 Report";
    }

    @Override
    public String getDescription() {
        return "TX_CURR MER Indicator report for MoH with Lost to Followup taken as 90 days from the last scheduled appointment";
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MER_TX_CURRENT_2019.xls");
    }

    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();

        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("TX_CURR", Mapped.mapStraightThrough(dsd));

        CohortDefinitionDimension ageDimension =commonDimensionLibrary.getTxNewAgeGenderGroup();
        dsd.addDimension("age", Mapped.mapStraightThrough(ageDimension));

        CohortDefinition PWIDS = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("927563c5-cb91-4536-b23c-563a72d3f829"),hivMetadata.getARTSummaryPageEncounterType(),
                Arrays.asList(Dictionary.getConcept("160666AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition PIPS = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("927563c5-cb91-4536-b23c-563a72d3f829"),hivMetadata.getARTSummaryPageEncounterType(),
                Arrays.asList(Dictionary.getConcept("162277AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition males = cohortDefinitionLibrary.males();
        CohortDefinition females = cohortDefinitionLibrary.females();

        CohortDefinition patientsWithLessThan3MonthsOfARVDrugsDispensed = hivCohortDefinitionLibrary.getPatientsThatReceivedDrugsForNoOfDaysByEndOfPeriod(90.0, RangeComparator.LESS_THAN);
        CohortDefinition patientsWithEqualOrGreaterThan6MonthsOfARVDrugsDispensed = hivCohortDefinitionLibrary.getPatientsThatReceivedDrugsForNoOfDaysByEndOfPeriod(180.0, RangeComparator.GREATER_EQUAL);
        CohortDefinition patientsWith3To5MonthsOfARVDrugsDispensed = hivCohortDefinitionLibrary.getPatientsThatReceivedDrugsForNoOfDaysByEndOfPeriod(90.0,RangeComparator.GREATER_EQUAL,150.0,RangeComparator.LESS_EQUAL);

        CohortDefinition above15Years = cohortDefinitionLibrary.above15Years();
        CohortDefinition below15Years = cohortDefinitionLibrary.MoHChildren();


        CohortDefinition beenOnArtDuringQuarter = hivCohortDefinitionLibrary.getActivePatientsWithLostToFollowUpAsByDays("90");

        CohortDefinition currentOnARTAndDrugsDispensedToPatientsBelow15Years = df.getPatientsInAll(beenOnArtDuringQuarter,below15Years);
        CohortDefinition currentOnARTAndDrugsDispensedToPatientsBelow15YearsFemales = df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15Years,females);
        CohortDefinition currentOnARTAndDrugsDispensedToPatientsBelow15YearsMales = df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15Years,males);
        CohortDefinition currentOnARTAndDrugsDispensedToPatientsAbove15Years = df.getPatientsInAll(beenOnArtDuringQuarter,above15Years);
        CohortDefinition currentOnARTAndDrugsDispensedToPatientsAbove15YearsFemales = df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15Years,females);
        CohortDefinition currentOnARTAndDrugsDispensedToPatientsAbove15YearsMales = df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15Years,males);




        setupTxNewReport.addGender(dsd,"a","TX Curr on ART female",beenOnArtDuringQuarter);
        setupTxNewReport.addGender(dsd,"b","TX Curr on ART male",beenOnArtDuringQuarter);

        setupTxNewReport.addIndicator(dsd,"PWIDSf","PWIDs TX Curr on ART female",df.getPatientsInAll(females,PWIDS,beenOnArtDuringQuarter),"");
        setupTxNewReport.addIndicator(dsd,"PWIDSm","PWIDs TX Curr on ART male",df.getPatientsInAll(males,PWIDS,beenOnArtDuringQuarter),"");

        setupTxNewReport.addIndicator(dsd,"PIPf","PIPs TX Curr on ART female",df.getPatientsInAll(females,PIPS,beenOnArtDuringQuarter),"");
        setupTxNewReport.addIndicator(dsd,"PIPm","PIPs TX Curr on ART male",df.getPatientsInAll(males,PIPS,beenOnArtDuringQuarter),"");

        setupTxNewReport.addIndicator(dsd,"14a","<3 mnths ARV dispensing female less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsFemales,patientsWithLessThan3MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"14b","<3 mnths ARV dispensing male less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsMales,patientsWithLessThan3MonthsOfARVDrugsDispensed),"");

        setupTxNewReport.addIndicator(dsd,"15a","<3 mnths ARV dispensing female more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsFemales,patientsWithLessThan3MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"15b","<3 mnths ARV dispensing male more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsMales,patientsWithLessThan3MonthsOfARVDrugsDispensed),"");

        setupTxNewReport.addIndicator(dsd,"16a","3-5 mnths ARV dispensing female less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsFemales,patientsWith3To5MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"16b","3-5 mnths ARV dispensing male less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsMales,patientsWith3To5MonthsOfARVDrugsDispensed),"");

        setupTxNewReport.addIndicator(dsd,"17a","3-5 mnths ARV dispensing female more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsFemales,patientsWith3To5MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"17b","3-5 mnths ARV dispensing male more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsMales,patientsWith3To5MonthsOfARVDrugsDispensed),"");

        setupTxNewReport.addIndicator(dsd,"18a","6 mnths ARV dispensing female less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsFemales,patientsWithEqualOrGreaterThan6MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"18b","6 mnths ARV dispensing male less than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsBelow15YearsMales,patientsWithEqualOrGreaterThan6MonthsOfARVDrugsDispensed),"");

        setupTxNewReport.addIndicator(dsd,"19a","6 mnths ARV dispensing female more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsFemales,patientsWithEqualOrGreaterThan6MonthsOfARVDrugsDispensed),"");
        setupTxNewReport.addIndicator(dsd,"19b","6 mnths ARV dispensing male more than 15",df.getPatientsInAll(currentOnARTAndDrugsDispensedToPatientsAbove15YearsMales,patientsWithEqualOrGreaterThan6MonthsOfARVDrugsDispensed),"");

        return rd;
    }





    @Override
    public String getVersion() {
        return "0.3.3";
    }
}
