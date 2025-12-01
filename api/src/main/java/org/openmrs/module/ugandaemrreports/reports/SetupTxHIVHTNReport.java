package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;
import org.openmrs.module.ugandaemrreports.library.ARTClinicCohortDefinitionLibrary;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.getUgandaEMRVersion;
import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;

/**
 *  TX Current Report
 */
@Component
public class SetupTxHIVHTNReport extends AggregateReportDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "af2a25f3-248b-4974-bc07-0cc3fc547a06";
    }

    public String getJSONDesignUuid() {
        return "5face04c-dcad-4ccc-978a-438b1107ed05";
    }

    @Override
    public String getUuid() {
        return "2fa71b64-c075-4726-b8b5-4730e3bc1788";
    }

    @Override
    public String getName() {
        return "TX HIV HTN Report";
    }

    @Override
    public String getDescription() {
        return "TX_HIV_HTN MER Indicator report for PEPFAR";
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
        return Arrays.asList(buildReportDesign(reportDefinition),buildJSONReportDesign(reportDefinition));
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "TX_HIV_HTN.xls");
    }

    public ReportDesign buildJSONReportDesign(ReportDefinition reportDefinition) {
        return createJSONTemplateDesign(getJSONDesignUuid(), reportDefinition, "TX_HIV_HTN.json");
    }

    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        AggregateReportDataSetDefinition dsd = new AggregateReportDataSetDefinition();

        dsd.setParameters(getParameters());
        dsd.setReportDesign(getJsonReportDesign());
        rd.addDataSetDefinition("TX", Mapped.mapStraightThrough(dsd));
        rd.addDataSetDefinition("S",Mapped.mapStraightThrough(settings()));
        rd.addDataSetDefinition("aijar", Mapped.mapStraightThrough(getUgandaEMRVersion()));

        return rd;
    }


    @Override
    public String getVersion() {
        return "4.0";
    }
}
