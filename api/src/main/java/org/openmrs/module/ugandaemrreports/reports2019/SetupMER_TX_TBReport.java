package org.openmrs.module.ugandaemrreports.reports2019;

import org.openmrs.Concept;
import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reports.SetupTxNewReport;
import org.openmrs.module.ugandaemrreports.reports.UgandaEMRDataExportManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.awt.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 *  PMTCT STAT Report
 */
@Component
public class SetupMER_TX_TBReport extends UgandaEMRDataExportManager {

    @Autowired
    private SetupTxNewReport setupTxNewReport;

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    HIVMetadata hivMetadata;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private CommonCohortDefinitionLibrary cohortDefinitionLibrary;

    @Autowired
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "94478e16-3916-4c88-a4ac-0f279dab1a80";
    }

    @Override
    public String getUuid() {
        return "d055029b-655f-4adb-84a0-405351892e09";
    }

    @Override
    public String getName() {
        return "MER TX TB Report";
    }

    @Override
    public String getDescription() {
        return "MER Indicator Report for TX TB";
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MER_TX_TB.xls");
    }

    @Override
    public ReportDefinition constructReportDefinition() {
        String params = "startDate=${startDate},endDate=${endDate}";
        ReportDefinition rd = new ReportDefinition();
        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());



        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("TX_TB", Mapped.mapStraightThrough(dsd));

        dsd.addDimension("gender", Mapped.mapStraightThrough(getGender()));

        CohortDefinition havingArtStartDateDuringQuarter = hivCohortDefinitionLibrary.getArtStartDateBetweenPeriod();
        CohortDefinition havingArtStartDateBeforeQuarter = hivCohortDefinitionLibrary.getArtStartDateBeforePeriod();
        CohortDefinition onART = df.getPatientsInAny(havingArtStartDateBeforeQuarter,havingArtStartDateDuringQuarter);

        CohortDefinition startedTBTreatmentDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getTBStatus(), hivMetadata.getARTEncounterPageEncounterType(), Arrays.asList(hivMetadata.getTBStatusRx()), BaseObsCohortDefinition.TimeModifier.ANY);


        CohortDefinition onARTAndStartedTBDuringPeriod = df.getPatientsInAll(onART,startedTBTreatmentDuringPeriod);

        CohortDefinition above15Years = cohortDefinitionLibrary.above15Years();
        CohortDefinition below15Years = cohortDefinitionLibrary.agedAtMost(14);

        CohortDefinition screenedNegative = hivCohortDefinitionLibrary.getScreenedForTBNegativeDuringPeriod();
        CohortDefinition screenedPositive  = df.getPatientsNotIn(hivCohortDefinitionLibrary.getAssessedForTBDuringPeriod(),screenedNegative);

        CohortDefinition newOnARTAndStartedTBTreatmentDuringPeriod = df.getPatientsInAll(havingArtStartDateDuringQuarter,startedTBTreatmentDuringPeriod);
        CohortDefinition previouslyOnARTAndStartedTBTreatmentDuringPeriod = df.getPatientsInAll(havingArtStartDateBeforeQuarter,startedTBTreatmentDuringPeriod);

        addGender(dsd,"1","new on ART start TB treatment below 15 years ", df.getPatientsInAll(newOnARTAndStartedTBTreatmentDuringPeriod,below15Years));
        addGender(dsd,"2","new on ART start TB treatment above 15 years ", df.getPatientsInAll(newOnARTAndStartedTBTreatmentDuringPeriod,above15Years));

        addGender(dsd,"3","previously on ART start TB treatment below 15 years ", df.getPatientsInAll(previouslyOnARTAndStartedTBTreatmentDuringPeriod,below15Years));
        addGender(dsd,"4","previously on ART start TB treatment above 15 years ", df.getPatientsInAll(previouslyOnARTAndStartedTBTreatmentDuringPeriod,above15Years));


        addGender(dsd,"5","new on ART start TB treatment screen positive below 15 years ", df.getPatientsInAll(havingArtStartDateDuringQuarter,screenedPositive,below15Years));
        addGender(dsd,"6","new on ART start TB treatment screen positive above 15 years ", df.getPatientsInAll(havingArtStartDateDuringQuarter,screenedPositive,above15Years));

        addGender(dsd,"7","new on ART start TB treatment screen negative below 15 years ", df.getPatientsInAll(havingArtStartDateDuringQuarter,screenedNegative,below15Years));
        addGender(dsd,"8","new on ART start TB treatment screen negative above 15 years ", df.getPatientsInAll(havingArtStartDateDuringQuarter,screenedNegative,above15Years));

        addGender(dsd,"9","previously on ART start TB treatment screen positive below 15 years ", df.getPatientsInAll(havingArtStartDateBeforeQuarter,screenedPositive,below15Years));
        addGender(dsd,"10","previously on ART start TB treatment screen positive above 15 years ", df.getPatientsInAll(havingArtStartDateBeforeQuarter,screenedPositive,above15Years));

        addGender(dsd,"11","previously on ART start TB treatment screen negative below 15 years ", df.getPatientsInAll(havingArtStartDateBeforeQuarter,screenedNegative,below15Years));
        addGender(dsd,"12","previously on ART start TB treatment screen negative above 15 years ", df.getPatientsInAll(havingArtStartDateBeforeQuarter,screenedNegative,above15Years));



        return rd;
    }

    public CohortDefinitionDimension getGender(){
        CohortDefinition males = cohortDefinitionLibrary.males();
        CohortDefinition females = cohortDefinitionLibrary.females();

        CohortDefinitionDimension genderDimension = new CohortDefinitionDimension();

        genderDimension.addParameter(ReportingConstants.END_DATE_PARAMETER);
        genderDimension.addCohortDefinition("female", Mapped.mapStraightThrough(females));
        genderDimension.addCohortDefinition("male", Mapped.mapStraightThrough(males));

        return genderDimension;
    }

    public void addGender(CohortIndicatorDataSetDefinition dsd, String key,String label, CohortDefinition cohortDefinition){
        setupTxNewReport.addIndicator(dsd,  key+"a", label, cohortDefinition, "gender=female");
        setupTxNewReport.addIndicator(dsd,  key+"b", label, cohortDefinition, "gender=male");
    }



    @Override
    public String getVersion() {
        return "0.1.5";
    }
}
