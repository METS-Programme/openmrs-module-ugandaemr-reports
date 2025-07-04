package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
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
 * SMS Reports with people on appointment in a particular period
 */
@Component
public class SetupSMSAppointmentsReports extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;

    @Autowired
    private HIVPatientDataLibrary hivPatientData;

    @Autowired
    private BasePatientDataLibrary basePatientData;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;


    @Override
    public String getExcelDesignUuid() {
        return "20f4c992-f657-4952-af51-9d71d3205901";
    }

    public String getCSVDesignUuid() {
        return "e8cd7d9f-e30e-463f-8073-ea7ccf3d3574";
    }

    @Override
    public String getUuid() {
        return "9a4bfceb-6205-4811-9a09-f95589249f65";
    }

    @Override
    public String getName() {
        return "SMS Reminder Appointments List";
    }

    @Override
    public String getDescription() {
        return "Lists Patients to Send SMS With Appointments in a particular period";
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
        return l;
    }

    @Override
    public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
        return createCSVDesign(getCSVDesignUuid(), reportDefinition);

    }

    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        PatientDataSetDefinition dsd = new PatientDataSetDefinition();

        CohortDefinition appointmentList = df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getReturnVisitDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsDeadAndTransferredOut = hivCohortDefinitionLibrary.getDeadAndTransferredOutPatientsDuringPeriod();
        CohortDefinition hadEncounterInPeriod = hivCohortDefinitionLibrary.getArtPatientsWithEncounterOrSummaryPagesBetweenDates();
        CohortDefinition cohortstoExclude =df.getPatientsInAny(hadEncounterInPeriod,patientsDeadAndTransferredOut);
        CohortDefinition patientsWithAppointments=df.getPatientsNotIn(appointmentList,cohortstoExclude);



        dsd.setName(getName());
        dsd.setParameters(getParameters());
        dsd.addRowFilter(Mapped.mapStraightThrough(patientsWithAppointments));
        addColumn(dsd, "Appointment Date", hivPatientData.getExpectedReturnDateBetween());
        addColumn(dsd, "Telephone", df.getSMSTelephoneNumber());
        addColumn(dsd, "Message", hivPatientData.getPatientSMSTemplateMessage());


        rd.addDataSetDefinition("APPOINTMENT_LIST", Mapped.mapStraightThrough(dsd));
        return rd;
    }

    @Override
    public String getVersion() {
        return "1.0.14";
    }


}
