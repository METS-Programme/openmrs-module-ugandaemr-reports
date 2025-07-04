package org.openmrs.module.ugandaemrreports.reports2019;

import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.EMRVersionDatasetDefinition;
import org.openmrs.module.ugandaemrreports.reports.AggregateReportDataExportManager;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;

/**
 */
@Component
public class Setup106A1A2024Report extends AggregateReportDataExportManager {


    @Override
    public String getExcelDesignUuid() {
        return "72aadc78-e3e5-421e-8152-bc69932fadec";
    }

    public String getJSONDesignUuid() {
        return "1d935bb7-4999-41fb-ba53-6fa1aecaac3d";
    }

    @Override
    public String getUuid() {
        return "8c12b314-564e-4df6-9d06-410176de9461";
    }

    @Override
    public String getName() {
        return "HMIS 106A1A 2024";
    }

    @Override
    public String getDescription() {
        return "This is the 2024 version of the HMIS 106A Section 1A ";
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
        List<ReportDesign> l = new ArrayList<ReportDesign>();
        l.add(buildReportDesign(reportDefinition));
        l.add(buildJSONReportDesign(reportDefinition));

        return l;
    }

    @Override
    public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "106A1A2024Report.xls");
    }

    public ReportDesign buildJSONReportDesign(ReportDefinition reportDefinition) {
        ReportDesign rd = createJSONTemplateDesign(getJSONDesignUuid(), reportDefinition, "106A1A2024Report.json");
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
        rd.addDataSetDefinition("x", Mapped.mapStraightThrough(dsd));
        rd.addDataSetDefinition("aijar",Mapped.mapStraightThrough(getUgandaEMRVersion()));
        rd.addDataSetDefinition("S", Mapped.mapStraightThrough(settings()));
        return rd;
    }

    public static DataSetDefinition getUgandaEMRVersion(){
        EMRVersionDatasetDefinition dsd= new EMRVersionDatasetDefinition();
        return dsd;
    }

    @Override
    public String getVersion() {
        return "1.0.13";
    }
}
