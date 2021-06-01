package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.TB009DatasetDefinition;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

/**
 * Health Unit TB Register Report
 * */

@Component
public class SetupHMISTB009Register extends UgandaEMRDataExportManager {
	
	
	@Autowired
	private DataFactory df;
	
	@Override
	public String getDescription() {
		return "Health Unit TB Register";
	}
	
	@Override
	public String getName() {
		return "009 - Health Unit TB Register";
	}
	
	@Override
	public String getUuid() {
		return "3b9d317f-ac87-4141-b4c2-d93c8419b324";
	}
	

	/**
     * @return the uuid for the report design for exporting to Excel
     */
	@Override
	public String getExcelDesignUuid() {
		return "80d288d7-c8ce-4b0a-a636-4e4497533fd9";
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
	
	/**
	 * Build the report design for the specified report, this allows a user to override the report
	 * design by adding properties and other metadata to the report design
	 *
	 * @param reportDefinition
	 * @return The report design
	 */
	@Override	
	public ReportDesign buildReportDesign(ReportDefinition reportDefinition) {
		ReportDesign rd = createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "0009-HealthUnitTBRegister.xls");
		Properties props = new Properties();
		props.put("repeatingSections", "sheet:1,row:8-11,dataset:TB");
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

		TB009DatasetDefinition dsd = new TB009DatasetDefinition();
		dsd.setName(getName());
		dsd.setParameters(getParameters());
		rd.addDataSetDefinition("TB", Mapped.mapStraightThrough(dsd));
		return rd;
	}

	@Override
	public String getVersion() {
		return "1.3.9";
	}

}
