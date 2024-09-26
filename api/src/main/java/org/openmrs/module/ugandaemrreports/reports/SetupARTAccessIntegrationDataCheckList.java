package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.data.patient.library.BuiltInPatientDataLibrary;
import org.openmrs.module.reporting.data.person.definition.GenderDataDefinition;
import org.openmrs.module.reporting.data.person.definition.PreferredNameDataDefinition;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.ARTAccessCohortDefinition;
import org.openmrs.module.ugandaemrreports.definition.data.converter.BirthDateConverter;
import org.openmrs.module.ugandaemrreports.library.BasePatientDataLibrary;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.openmrs.module.ugandaemrreports.library.HIVPatientDataLibrary;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;

/**
 * ARTAccessIntegrationDataCheckList
 * */

@Component
public class SetupARTAccessIntegrationDataCheckList extends UgandaEMRDataExportManager {
	
	
	@Autowired
	private DataFactory df;

	@Autowired
	private HIVMetadata hivMetadata;

	@Autowired
	private BuiltInPatientDataLibrary builtInPatientData;

	@Autowired
	private HIVPatientDataLibrary hivPatientData;

	@Autowired
	private BasePatientDataLibrary basePatientData;
	
	@Override
	public String getDescription() {
		return "ARTAccess Integration Data CheckList";
	}
	
	@Override
	public String getName() {
		return "ARTAccess Integration Data CheckList";
	}
	
	@Override
	public String getUuid() {
		return "acb08bcb-9ec2-4856-b2c4-7c2f880c6b67";
	}
	

	/**
     * @return the uuid for the report design for exporting to Excel
     */
	@Override
	public String getExcelDesignUuid() {
		return "08485222-be5f-4736-9a85-ab45249f2ed3";
	}
	
	@Override
	public List<Parameter> getParameters() {
		List<Parameter> l = new ArrayList<Parameter>();
		l.add(df.getEndDateParameter());
		return l;
	}
	
	@Override
	public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
		List<ReportDesign> l = new ArrayList<ReportDesign>();
		l.add(buildReportDesign(reportDefinition));
		return l;
	}
	
	/**
	 * Build the report design for the specified report, this allows a user to override the report
	 * design by adding properties and other metadata to the report design
	 *
	 * @param reportDefinition
	 * @return The report design
	 */
	@Override	
	public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
		ReportDesign rd = createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "ARTACCESSCheckList.xls");
		Properties props = new Properties();
		props.put("repeatingSections", "sheet:1,row:5,dataset:A");
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

		dsd.setName(getName());
		dsd.setParameters(getParameters());
		rd.addDataSetDefinition("A", Mapped.mapStraightThrough(dsd));

		CohortDefinition cd = new ARTAccessCohortDefinition();
		dsd.addRowFilter(Mapped.mapStraightThrough(cd));

		addColumn(dsd, "Clinic No", hivPatientData.getClinicNumber());
		addColumn(dsd,"Person UUID",hivPatientData.getPatientUUID());
		dsd.addColumn( "Patient Name",  new PreferredNameDataDefinition(), (String) null);
		dsd.addColumn( "Sex", new GenderDataDefinition(), (String) null);
		dsd.addColumn("Birth Date", builtInPatientData.getBirthdate(), "", new BirthDateConverter());
		addColumn(dsd, "Current Regimen", hivPatientData.getCurrentRegimen());
		addColumn(dsd, "ART Start Date", hivPatientData.getARTStartDate());
		addColumn(dsd, "returnVisitDate", hivPatientData.getLastReturnDateByEndDate());
		addColumn(dsd, "Telephone", basePatientData.getTelephone());
		addColumn(dsd,"refillPointCode",df.getObsByEndDate(Dictionary.getConcept("7a22cfcb-a272-4eff-968c-5e9467125a7b"), Arrays.asList(hivMetadata.getARTEncounterEncounterType()),TimeQualifier.LAST,df.getObsValueTextConverter()));

		rd.addDataSetDefinition("A", Mapped.mapStraightThrough(dsd));
		rd.addDataSetDefinition("S",Mapped.mapStraightThrough(settings()));
		rd.setBaseCohortDefinition(Mapped.mapStraightThrough(cd));
		return rd;
	}

	@Override
	public String getVersion() {
		return "0.1.3";
	}

}
