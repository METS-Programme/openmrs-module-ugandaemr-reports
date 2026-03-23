package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.EMRVersionDatasetDefinition;
import org.openmrs.module.ugandaemrreports.library.ARTClinicCohortDefinitionLibrary;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.period;
import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;

/**
 * Daily Appointments List report
 */
@Component

public class SetupMOH105Section1_2024Report extends AggregateReportDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    private static final String PARAMS = "startDate=${startDate},endDate=${endDate}";


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "d7c0d1d2-f5f3-11f0-982d-cfe0f6300daf";
    }
    public String getJSONDesignUuid() {
        return "e145c640-f5f3-11f0-982d-cfe0f6300daf";
    }

    @Override
    public String getUuid() {
        return "88c2a1c4-ff7f-11f0-982d-cfe0f6300daf";
    }

    @Override
    public String getName() {
        return "HMIS 105 1.0 OPD ATTENDANCES, REFERRALS AND DIAGNOSES";
    }

    @Override
    public String getDescription() {
        return "HMIS 105 1.0 OPD ATTENDANCES, REFERRALS AND DIAGNOSES";
    }

    @Override
    public List<Parameter> getParameters() {
        List<Parameter> l = new ArrayList<>();
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
        ReportDesign rd = createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "HMIS105Section1_2024.xls");
        return rd;
    }

    public ReportDesign buildJSONReportDesign(ReportDefinition reportDefinition) {
        ReportDesign rd = createJSONTemplateDesign(getJSONDesignUuid(), reportDefinition, "HMIS105Section1_2024.json");
        return rd;
    }


    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        AggregateReportDataSetDefinition dsd = new AggregateReportDataSetDefinition();
        dsd.setName(getName());
        dsd.setParameters(getParameters());
        dsd.setReportDesign(getJsonReportDesign());
        rd.addDataSetDefinition("S", Mapped.mapStraightThrough(settings()));
        rd.addDataSetDefinition("x", Mapped.mapStraightThrough(dsd));
        rd.addDataSetDefinition("P", Mapped.mapStraightThrough(period()));
        rd.addDataSetDefinition("aijar", Mapped.mapStraightThrough(getUgandaEMRVersion()));
        return rd;

    }



    public static DataSetDefinition getUgandaEMRVersion(){
        EMRVersionDatasetDefinition dsd= new EMRVersionDatasetDefinition();
        return dsd;
    }
    @Override
    public String getVersion() {
        return "1.0.1-SNAPSHOT";
    }
}
