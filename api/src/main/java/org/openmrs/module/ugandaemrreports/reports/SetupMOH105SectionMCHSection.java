package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.data.patient.library.BuiltInPatientDataLibrary;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.library.dimension.CommonReportDimensionLibrary;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.period;
import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;

/**
 * Daily Appointments List report
 */
@Component

public class SetupMOH105SectionMCHSection extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    private BuiltInPatientDataLibrary builtInPatientData;

    @Autowired
    private HIVPatientDataLibrary hivPatientData;

    @Autowired
    private BasePatientDataLibrary basePatientData;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonReportDimensionLibrary dimensionLibrary;

    @Autowired
    private Moh105IndicatorLibrary indicatorLibrary;

    private static final String PARAMS = "startDate=${startDate},endDate=${endDate}";


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "ae528aaa-fddc-444b-a0e3-c466cbbc5a3c";
    }
    public String getJSONDesignUuid() {
        return "fecd3eaf-4417-4ede-8e69-b9b91bfe69cc";
    }

    @Override
    public String getUuid() {
        return "27f4804f-ec6f-466e-b4ea-21f9ca584880";
    }

    @Override
    public String getName() {
        return "HMIS 105 Section 4: HTS";
    }

    @Override
    public String getDescription() {
        return "HMIS 105 Section 4: HTS 2019";
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
        List<ReportDesign> l = new ArrayList<ReportDesign>();
        l.add(buildReportDesign(reportDefinition));
        l.add(buildJSONReportDesign(reportDefinition));

        return l;
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
        ReportDesign rd = createExcelTemplateDesign("04c3d0f2-fd33-4b48-ada7-fc78346917b3", reportDefinition, "HMIS105Section4_2019.xls");
        return rd;
    }

    public ReportDesign buildJSONReportDesign(ReportDefinition reportDefinition) {
        ReportDesign rd = createJSONTemplateDesign(getJSONDesignUuid(), reportDefinition, "HMIS105Section4_2019.json");
        return rd;
    }


    /**
     * Build the report design for the specified report, this allows a user to override the report design by adding
     * properties and other metadata to the report design
     *
     * @param reportDefinition
     * @return The report design
     */



    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        rd.addDataSetDefinition("S", Mapped.mapStraightThrough(settings()));
        rd.addDataSetDefinition("105", Mapped.mapStraightThrough(eid()));
        rd.addDataSetDefinition("P", Mapped.mapStraightThrough(period()));
        return rd;

    }

    protected DataSetDefinition eid() {
        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        dsd.setParameters(getParameters());
        dsd.addDimension("age", ReportUtils.map(dimensionLibrary.HTCAgeGroups(), "effectiveDate=${endDate}"));
        dsd.addDimension("gender", ReportUtils.map(dimensionLibrary.gender()));

        dsd.addParameter(new Parameter("startDate", "Start Date", Date.class));
        dsd.addParameter(new Parameter("endDate", "End Date", Date.class));





        addRowWithColumns(dsd, "HT06","H3-Number of Individuals who received HIV test results", indicatorLibrary.individualsWhoReceivedHIVTestResults());
        addRowWithColumns(dsd, "HT07","H5-Number of individuals tested for the first time", indicatorLibrary.individualsTestedForTheFirstTime());
        addRowWithColumns(dsd, "HT08","H6-Number of Individuals who tested HIV positive", indicatorLibrary.individualsWhoTestedHivPositive());
        addRowWithColumns(dsd, "HT09A","H14-Individuals With Long Term test Results", indicatorLibrary.individualswithLongTermTestsResults());
        addRowWithColumns(dsd, "HT09B","H15-Individuals With Recent  test Results", indicatorLibrary.individualswithRecentTestsResults());
        addRowWithColumns(dsd, "HT10","H10-HIV positive individuals with presumptive TB", indicatorLibrary.individualsWhoTestedHivPositiveAndWithPresumptiveTb());
        addRowWithColumns(dsd, "HT11","H8-Number of Individuals tested more than ONCE in the last 12 months", indicatorLibrary.individualsTestedMoreThanTwiceInLast12Months());
        addRowWithColumns(dsd, "HT12","H9-Number of individuals who were Counseled and Tested together as a Couple", indicatorLibrary.individualsCounseledAndTestedAsCouple());
        addRowWithColumns(dsd, "HT13","H10-Number of individuals who were Tested and Received results together as a Couple", indicatorLibrary.individualsTestedAndReceivedResultsAsACouple());
        addRowWithColumns(dsd, "HT14","H11-Number of couples with Concordant positive results", indicatorLibrary.couplesWithConcordantPositiveResults());
        addRowWithColumns(dsd, "HT15","H12- Number of couples with Discordant results", indicatorLibrary.couplesWithDiscordantResults());
        addRowWithColumns(dsd, "HT16","H13-Individuals counseled and tested for PEP", indicatorLibrary.individualsCounselledAndTestedForPep());
        addRowWithColumns(dsd, "HT17","H13-Individuals counseled and tested As Special Category", indicatorLibrary.testedAsSpecialCategory());

        return dsd;
    }

    public void addRowWithColumns(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortIndicator cohortIndicator) {

        addIndicator(dsd, key + "aM", label + " (Below 1 year) Male", cohortIndicator, "gender=M|age=Below1yr");
        addIndicator(dsd, key + "aF", label + " (Below 1 year) Female", cohortIndicator, "gender=F|age=Below1yr");
        addIndicator(dsd, key + "bM", label + " (Between 1 and 4 Years) Male", cohortIndicator, "gender=M|age=Between1And4yrs");
        addIndicator(dsd, key + "bF", label + " (Between  1 and 4 Years) Female", cohortIndicator, "gender=F|age=Between1And4yrs");
        addIndicator(dsd, key + "lM", label + " (Between 5 and 9 Years) Male", cohortIndicator, "gender=M|age=Between5And9yrs");
        addIndicator(dsd, key + "lF", label + " (Between 5 and 9 Years) Female", cohortIndicator, "gender=F|age=Between5And9yrs");
        addIndicator(dsd, key + "cM", label + " (Between 10 and 14 Years) Male", cohortIndicator, "gender=M|age=Between10And14yrs");
        addIndicator(dsd, key + "cF", label + " (Between 10 and 14 Years) Female", cohortIndicator, "gender=F|age=Between10And14yrs");
        addIndicator(dsd, key + "dM", label + " (Between 15 and 19 Years) Male", cohortIndicator, "gender=M|age=Between15And19yrs");
        addIndicator(dsd, key + "dF", label + " (Between 15 and 19 Years) Female", cohortIndicator, "gender=F|age=Between15And19yrs");
        addIndicator(dsd, key + "eM", label + " (Between 20 and 24 Years) Male", cohortIndicator, "gender=M|age=Between20And24yrs");
        addIndicator(dsd, key + "eF", label + " (Between 20 and 24 Years) Female", cohortIndicator, "gender=F|age=Between20And24yrs");
        addIndicator(dsd, key + "mM", label + " (Between 25 and 29 Years) Male", cohortIndicator, "gender=M|age=Between25And29yrs");
        addIndicator(dsd, key + "mF", label + " (Between 25 and 29 Years) Female", cohortIndicator, "gender=F|age=Between25And29yrs");
        addIndicator(dsd, key + "fM", label + " (Between 30 and 34 Years) Male", cohortIndicator, "gender=M|age=Between30And34yrs");
        addIndicator(dsd, key + "fF", label + " (Between 30 and 34 Years) Female", cohortIndicator, "gender=F|age=Between30And34yrs");
        addIndicator(dsd, key + "gM", label + " (Between 35 and 39 Years) Male", cohortIndicator, "gender=M|age=Between35And39yrs");
        addIndicator(dsd, key + "gF", label + " (Between 35 and 39 Years) Female", cohortIndicator, "gender=F|age=Between35And39yrs");
        addIndicator(dsd, key + "hM", label + " (Between 40 and 44 Years) Male", cohortIndicator, "gender=F|age=Between40And44yrs");
        addIndicator(dsd, key + "hF", label + " (Between 40 and 44 Years) Female", cohortIndicator, "gender=F|age=Between40And44yrs");
        addIndicator(dsd, key + "jM", label + " (Between 45 and 49 Years) Male", cohortIndicator, "gender=M|age=Between45And49yrs");
        addIndicator(dsd, key + "jF", label + " (Between 45 and 49 Years) Female", cohortIndicator, "gender=F|age=Between45And49yrs");
        addIndicator(dsd, key + "kM", label + " (>50) Male", cohortIndicator, "gender=M|age=GreaterThan50yrs");
        addIndicator(dsd, key + "kF", label + " (>50) Female", cohortIndicator, "gender=F|age=GreaterThan50yrs");
        addIndicator(dsd, key + "g", label + " (Total) ", cohortIndicator, "");
    }

    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortIndicator cohortIndicator, String dimensionOptions) {
        dsd.addColumn(key, label, ReportUtils.map(cohortIndicator, PARAMS), dimensionOptions);

    }

    @Override
    public String getVersion() {
        return "6.0.2";
    }
}
