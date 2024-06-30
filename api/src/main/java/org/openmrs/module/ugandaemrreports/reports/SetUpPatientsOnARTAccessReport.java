package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.Location;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.data.patient.library.BuiltInPatientDataLibrary;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.data.converter.BirthDateConverter;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.dataset.definition.SharedDataDefintion;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

/**
 * Patients on ART Access CRPDDP Program
 */
@Component
public class SetUpPatientsOnARTAccessReport extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    private BuiltInPatientDataLibrary builtInPatientData;

    @Autowired
    HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    SharedDataDefintion sdd;

    @Autowired
    private HIVPatientDataLibrary hivPatientData;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "3050a89b-a50f-47e8-b420-ef9ac761d033";
    }

    public String getCSVDesignUuid() {
        return "3aa0f2d7-4172-498f-9794-b1e0e90da809";
    }

    @Override
    public String getUuid() {
        return "1cd3041d-5779-42c3-81b9-9617cba26be0";
    }

    @Override
    public String getName() {
        return "Patients on CRPDDP Program";
    }

    @Override
    public String getDescription() {
        return "List of Patients expected to be on CRPDDP Program";
    }

    @Override
    public List<Parameter> getParameters() {
        List<Parameter> l = new ArrayList<Parameter>();
        l.add(df.getEndDateParameter());
        return l;
    }

    public ReportDesign buildCSVReportDesign(ReportDefinition reportDefinition) {
        ReportDesign rd = createCSVDesign(getCSVDesignUuid(), reportDefinition);
        return rd;
    }

    @Override
    public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
        List<ReportDesign> l = new ArrayList<ReportDesign>();
        l.add(buildReportDesign(reportDefinition));
        l.add(buildCSVReportDesign(reportDefinition));
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
        ReportDesign rd = createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "CRPDDP_PatientList.xls");
        Properties props = new Properties();
        props.put("repeatingSections", "sheet:1,row:3,dataset:CRPDDP");
        props.put("sortWeight", "5000");
        rd.setProperties(props);
        return rd;
    }

    @Override
    public ReportDefinition constructReportDefinition() {
        ReportDefinition rd = new ReportDefinition();
        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        PatientDataSetDefinition dsd = new PatientDataSetDefinition();
        Location ART_Clinician = commonDimensionLibrary.getLocationByUuid("86863db4-6101-4ecf-9a86-5e716d6504e4");
        Location Pharmacy = commonDimensionLibrary.getLocationByUuid("3ec8ff90-3ec1-408e-bf8c-22e4553d6e17");

        CohortDefinition patientsOnCRPDDP = df.getWorkFlowStateCohortDefinition(hivMetadata.getCRPDDPState());
        dsd.setName(getName());
        dsd.setParameters(getParameters());
        dsd.addRowFilter(Mapped.mapStraightThrough(patientsOnCRPDDP));
        addColumn(dsd, "Clinic number", hivPatientData.getClinicNumber());
        addColumn(dsd, "Surname", builtInPatientData.getPreferredFamilyName());
        addColumn(dsd, "Given Name", builtInPatientData.getPreferredGivenName());
        addColumn(dsd, "Sex", builtInPatientData.getGender());
        dsd.addColumn("Birth Date", builtInPatientData.getBirthdate(), "", new BirthDateConverter());
        addColumn(dsd, "Art Start Date", hivPatientData.getArtStartDate());
        addColumn(dsd, "Current Regimen", hivPatientData.getCurrentRegimen());
        addColumn(dsd,"Last Facility Visit Date", df.getLatestARTVisitDate(ART_Clinician));
        addColumn(dsd,"Last Pharmacy Visit Date", df.getLatestARTVisitDate(Pharmacy));
        addColumn(dsd,"Pharmacy Return Date", hivPatientData.getLastReturnDateByEndDate());
        addColumn(dsd,"Next facility Return Date",df.getObsByEndDate(Dictionary.getConcept("f6c456f7-1ab4-4b4d-a3b4-e7417c81002a"), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST,df.getObsValueDatetimeConverter()));
        addColumn(dsd,"refillPointCode",df.getObsByEndDate(Dictionary.getConcept("7a22cfcb-a272-4eff-968c-5e9467125a7b"), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST,df.getObsValueTextConverter()));
        rd.addDataSetDefinition("CRPDDP", Mapped.mapStraightThrough(dsd));
        rd.setBaseCohortDefinition(Mapped.mapStraightThrough(patientsOnCRPDDP));

        return rd;
    }

    @Override
    public String getVersion() {
        return "0.1.4";
    }
}
