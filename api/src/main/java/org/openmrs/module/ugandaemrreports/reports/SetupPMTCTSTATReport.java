package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.data.patient.library.BuiltInPatientDataLibrary;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 *  PMTCT STAT Report
 */
@Component
public class SetupPMTCTSTATReport extends UgandaEMRDataExportManager {

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
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    private CommonCohortDefinitionLibrary commonCohortDefinitionLibrary;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private Moh105IndicatorLibrary indicatorLibrary;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "880cf4b5-07eb-4951-b13d-c77701daef5c";
    }

    @Override
    public String getUuid() {
        return "2356ee4a-c974-40e3-b28d-5b56f76ce295";
    }

    @Override
    public String getName() {
        return "PMTCT STAT Report";
    }

    @Override
    public String getDescription() {
        return "MER Indicator Report for PMTCT STAT";
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MER_PMTCT_STAT.xls");
    }

    @Override
    public ReportDefinition constructReportDefinition() {
        String params = "startDate=${startDate},endDate=${endDate}";

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();

        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("PMTCT_STAT", Mapped.mapStraightThrough(dsd));

        CohortDefinitionDimension ageDimension =commonDimensionLibrary.getPMTCT_STAT_AgeGenderGroup();
        dsd.addDimension("age", Mapped.mapStraightThrough(ageDimension));

        addGender(dsd,"a","Total  Pregnant With known HIV- status at entry (TRK)",ReportUtils.map(indicatorLibrary.pregnantTrkAt1stANC(),params),"female"); ;
        addGender(dsd,"b","Total  Pregnant Known HIV positives at entry(TRRK)",ReportUtils.map(indicatorLibrary.pregnantTrrkAt1stANC(),params),"female");
        addGender(dsd,"e","Total  Number of NEW ANC Clients",ReportUtils.map(indicatorLibrary.ANCFirstContact(),params),"female");
        addGender(dsd,"d","Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at any visit ",ReportUtils.map(indicatorLibrary.pregnantWomenNewlyTestedForHivThisPregnancyTRRAt1stVisit(),params),"female");
        addGender(dsd,"c","Pregnant Women tested HIV- for 1st time this pregnancy (TRR) at 1st visit",ReportUtils.map(indicatorLibrary.pregnantWomenNewlyTestedNegativeForHivThisPregnancyTRAt1stVisit(),params),"female");

         return rd;
    }


    public void addGender (CohortIndicatorDataSetDefinition dsd,String key ,String label,Mapped<? extends CohortIndicator> cohortIndicator , String gender){
        addIndicator(dsd, "1" + key, label , cohortIndicator, "age=below10"+gender);
        addIndicator(dsd, "2" + key, label , cohortIndicator, "age=between10and14"+gender);
        addIndicator(dsd, "3" + key, label , cohortIndicator, "age=between15and19"+gender);
        addIndicator(dsd, "4" + key, label , cohortIndicator, "age=between20and24"+gender);
        addIndicator(dsd, "5" + key, label , cohortIndicator, "age=between25and29"+gender);
        addIndicator(dsd, "6" + key, label , cohortIndicator, "age=between30and34"+gender);
        addIndicator(dsd, "7" + key, label , cohortIndicator, "age=between35and39"+gender);
        addIndicator(dsd, "8" + key, label , cohortIndicator, "age=between40and44"+gender);
        addIndicator(dsd, "9" + key, label , cohortIndicator, "age=between45and49"+gender);
        addIndicator(dsd, "10" + key, label , cohortIndicator, "age=above50"+gender);
    }


    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, Mapped<? extends CohortIndicator> ci, String dimensionOptions) {
        dsd.addColumn(key, label, ci, dimensionOptions);
    }


    @Override
    public String getVersion() {
        return "0.2.1";
    }
}
