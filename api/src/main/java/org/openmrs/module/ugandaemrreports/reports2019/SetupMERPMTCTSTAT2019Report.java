package org.openmrs.module.ugandaemrreports.reports2019;

import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.openmrs.module.ugandaemrreports.reports.SetupPMTCTSTATReport;
import org.openmrs.module.ugandaemrreports.reports.UgandaEMRDataExportManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 *  PMTCT STAT Report
 */
@Component
public class SetupMERPMTCTSTAT2019Report extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    SetupPMTCTSTATReport setupPMTCTSTATReport;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private Moh105IndicatorLibrary indicatorLibrary;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "c5e1cdab-399b-461e-ba93-d435a01df03b";
    }

    @Override
    public String getUuid() {
        return "de1f5094-10eb-4f3d-af0c-30c286f50f64";
    }

    @Override
    public String getName() {
        return "PMTCT STAT Report 2019";
    }

    @Override
    public String getDescription() {
        return "MER Indicator Report for PMTCT STAT 2019";
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MER_PMTCT_STAT_2019.xls");
    }

    @Override
    public ReportDefinition constructReportDefinition() {
        CohortDefinitionDimension ageDimension =commonDimensionLibrary.getPMTCT_STAT_AgeGenderGroup();
        String params = "startDate=${startDate},endDate=${endDate}";
        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();

        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("PMTCT_STAT", Mapped.mapStraightThrough(dsd));
        dsd.addDimension("age", Mapped.mapStraightThrough(ageDimension));

        setupPMTCTSTATReport.addGender(dsd,"a","Total  Pregnant Known HIV positives at entry(TRRK)",ReportUtils.map(indicatorLibrary.pregnantTrrkAt1stANC(),params),"female");
        setupPMTCTSTATReport.addGender(dsd,"b","Total  Pregnant With known HIV- status at entry (TRK)", ReportUtils.map(indicatorLibrary.pregnantTrkAt1stANC(),params),"female"); ;
        setupPMTCTSTATReport.addGender(dsd,"c","Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at 1st visit ",ReportUtils.map(indicatorLibrary.pregnantWomenNewlyTestedForHivThisPregnancyTRRAt1stVisit(),params),"female");
        setupPMTCTSTATReport.addGender(dsd,"d","Pregnant Women tested HIV- for 1st time this pregnancy (TR) at 1st visit",ReportUtils.map(indicatorLibrary.pregnantWomenNewlyTestedNegativeForHivThisPregnancyTRAt1stVisit(),params),"female");
        setupPMTCTSTATReport.addGender(dsd,"e","Total  Number of NEW ANC Clients",ReportUtils.map(indicatorLibrary.ANCFirstContact(),params),"female");

        return rd;
    }


    @Override
    public String getVersion() {
        return "0.3";
    }
}
