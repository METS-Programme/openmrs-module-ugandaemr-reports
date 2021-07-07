package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.*;
import org.openmrs.api.EncounterService;
import org.openmrs.api.context.Context;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.data.DataDefinition;
import org.openmrs.module.reporting.data.converter.*;
import org.openmrs.module.reporting.data.encounter.definition.ConvertedEncounterDataDefinition;
import org.openmrs.module.reporting.data.patient.definition.ConvertedPatientDataDefinition;
import org.openmrs.module.reporting.data.patient.definition.PatientIdentifierDataDefinition;
import org.openmrs.module.reporting.data.patient.library.BuiltInPatientDataLibrary;
import org.openmrs.module.reporting.data.person.definition.BirthdateDataDefinition;
import org.openmrs.module.reporting.data.person.definition.GenderDataDefinition;
import org.openmrs.module.reporting.data.person.definition.PersonAttributeDataDefinition;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.data.converter.CalculationResultDataConverter;
import org.openmrs.module.ugandaemrreports.data.converter.ObsDataConverter;
import org.openmrs.module.ugandaemrreports.data.converter.PersonAttributeDataConverter;
import org.openmrs.module.ugandaemrreports.definition.data.definition.CalculationDataDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.GlobalPropertyParametersDatasetDefinition;
import org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.openmrs.module.ugandaemrreports.reporting.calculation.smc.SMCEncounterDateCalculation;
import org.openmrs.module.ugandaemrreports.reporting.dataset.definition.SharedDataDefintion;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * HTS Client card export Report
 * */

@Component
public class SetUpRecencyHTSClientCardDataExportReport2019 extends UgandaEMRDataExportManager {


	@Autowired
	private DataFactory df;

	@Autowired
	SharedDataDefintion sdd;

	@Autowired
	private BuiltInPatientDataLibrary builtInPatientData;

	@Override
	public String getDescription() {
		return "Data Export for 2019 Version of the Recency HTS Client Card" ;
	}

	@Override
	public String getName() {
		return "Recency HTS Client Card Data Export 2019";
	}

	@Override
	public String getUuid() {
		return "662d4c00-d6bb-4494-8180-48776f415802";
	}

	@Override
	public String getVersion() {
		return "1.1.5";
	}

	/**
	 * @return the uuid for the report design for exporting to Excel
	 */
	@Override
	public String getExcelDesignUuid() {
		return "152a4845-37e1-40c0-8fa8-5ef343e65ba5";
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
		ReportDesign rd = createCSVDesign(getExcelDesignUuid(), reportDefinition);
		return rd;
	}


	@Override
	public ReportDefinition constructReportDefinition() {

		ReportDefinition rd = new ReportDefinition();
		rd.setUuid(getUuid());
		rd.setName(getName());
		rd.setDescription(getDescription());
		rd.setParameters(getParameters());
		rd.addDataSetDefinition("HTSCARDDATAEXPORT", Mapped.mapStraightThrough(dataSetDefinition()));
		rd.addDataSetDefinition("HTSCARDDATAEXPORT", Mapped.mapStraightThrough(CommonDatasetLibrary.settings()));
		return rd;
	}
	private Concept getConcept(String uuid) {
		return Dictionary.getConcept(uuid);
	}

	private CohortDefinition getPatientWithHCTEncounterDuringPeriod(){
		return df.getAnyEncounterOfTypesBetweenDates(
				Arrays.asList(Dictionary.getEncounterType("264daIZd-f80e-48fe-nba9-P37f2W1905Pv")));
	}
	private DataSetDefinition dataSetDefinition() {
		PatientDataSetDefinition dsd = new PatientDataSetDefinition();
		dsd.setName("HTS");
		dsd.addParameters(getParameters());
		dsd.addRowFilter(Mapped.mapStraightThrough(getPatientWithHCTEncounterDuringPeriod()));

		//start constructing of the dataset
		PersonAttributeType maritalStatus = Context.getPersonService().getPersonAttributeTypeByUuid("dce0c134-30ab-102d-86b0-7a5022ba4115");

		dsd.addColumn("encounter_uuid", df.getEncounterUuid(), (String) null);
		dsd.addColumn("serial_number", sdd.definition("serialNo",  getConcept("1646AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("visit_date", df.getHTSVisitDate(), (String)null, new DateConverter("yyyy-MM-dd"));
		dsd.addColumn("health_unit_name",df.getPreferredAddress("address4") ,(String)null);
		dsd.addColumn("health_unit_sub_county",df.getPreferredAddress("address3") ,(String)null);
		dsd.addColumn("health_unit_district",df.getPreferredAddress("countyDistrict") ,(String)null);
		dsd.addColumn("sex", new GenderDataDefinition(), (String) null);
		dsd.addColumn("date_of_birth", new BirthdateDataDefinition(), (String) null, new BirthdateConverter("yyyy-MM-dd"));
		dsd.addColumn("marital_status", new PersonAttributeDataDefinition("MaritalStatus", maritalStatus), "", new PersonAttributeDataConverter());
		dsd.addColumn("accompanied_by", sdd.definition("accompaniedBy",  getConcept("dc911cc1-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("accompanied_by_other", sdd.definition("accompaniedByOther",  getConcept("6cb349b1-9f45-4c96-84c7-9d7037c6a056")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("hts_delivery_model", sdd.definition("htsModel",  getConcept("46648b1d-b099-433b-8f9c-3815ff1e0a0f")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("hts_approach", sdd.definition("htsApproach",  getConcept("ff820a28-1adf-4530-bf27-537bfa9ce0b2")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("health_unit_testing_entry_point", sdd.definition("entrypoint",  getConcept("720a1e85-ea1c-4f7b-a31e-cb896978df79")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("health_unit_testing_entry_point_other", sdd.definition("entrypointSpecify",  getConcept("adf31c43-c9a0-4ab8-b53a-42097eb3d2b6")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("community_testing_entry_point", sdd.definition("testingPoints",  getConcept("4f4e6d1d-4343-42cc-ba47-2319b8a84369")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("community_testing_entry_point_other", sdd.definition("testingPointsOther",  getConcept("16820069-b4bf-4c47-9efc-408746e1636b")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("reason_for_testing", sdd.definition("reason",  getConcept("2afe1128-c3f6-4b35-b119-d17b9b9958ed")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("reason_for_testing_other", sdd.definition("reasonOther", getConcept("8c628b5b-0045-40dc-a480-7e1518ffb256")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("special_category", sdd.definition("special",  getConcept("927563c5-cb91-4536-b23c-563a72d3f829")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("special_category_other", sdd.definition("special",  getConcept("927563c5-cb91-4536-b23c-563a72d3f829")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());//TODO get concept_id
		dsd.addColumn("first_time_hiv_test",sdd.definition("firstTime",  getConcept("2766c090-c057-44f2-98f0-691b6d0336dc")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("last_hiv_test_date",sdd.definition("lastHIVTestDate",  getConcept("34c917f0-356b-40d0-b3d1-cf609517b5fc")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("last_hiv_test_result",sdd.definition("lastTestResults",  getConcept("49ba801d-b6ff-47cd-8d29-e0ac8649cb7d")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("number_of_tests_last_12_months",sdd.definition("timesTested",  getConcept("8037192e-8f0c-4af3-ad8d-ccd1dd6880ba")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("number_of_sexual_partners_last_12_months",sdd.definition("noOfSexualPartners",  getConcept("f1a6ede9-052e-4707-9cd8-a77fdeb2a02b")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("prior_partner_testing",sdd.definition("Partner Tested Before",  getConcept("adc0b1a1-39cf-412b-9ab0-28ec0f731220")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("partner_recent_test_result",sdd.definition("PartnerResults",  getConcept("ee802cf2-295b-4297-b53c-205f794294a5")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("pretest_counselling_done",sdd.definition("pre-testConseling",  getConcept("193039f1-c378-4d81-bb72-653b66c69914")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("counseled_as", sdd.definition("counseled as",  getConcept("b92b1777-4356-49b2-9c83-a799680dc7d4")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("hiv_final_test_result", sdd.definition("HIVresults",  getConcept("3d292447-d7df-417f-8a71-e53e869ec89d")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("hiv_final_syphillis_duo_result",sdd.definition("syphillis duo results",  getConcept("16091701-69b8-4bc7-82b3-b1726cf5a5df")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("recency_test_concent", sdd.definition("consent",  getConcept("0698a45b-771c-4d11-84ff-095598c8883c")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("recent_hiv_test_result", sdd.definition("recency Results",  getConcept("141520BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("individual_result_received", sdd.definition("individualResultsRecived",  getConcept("3437ae80-bcc5-41e2-887e-d56999a1b467")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("couple_result_received", sdd.definition("coupleResultsReceived",  getConcept("2aa9f0c1-3f7e-49cd-86ee-baac0d2d5f2d")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("couple_result", sdd.definition("coupleResults",  getConcept("94a5bd0a-b79d-421e-ab71-8e382eed100f")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("presumtive_tb", sdd.definition("TBCase",  getConcept("b80f04a4-1559-42fd-8923-f8a6d2456a04")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("referred_to_tb_services", sdd.definition("referedForTBServices",  getConcept("c5da115d-f6a3-4d13-b182-c2e982a3a796")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("referred_to_hiv_care", sdd.definition("refferedTonrollment",  getConcept("3d620422-0641-412e-ab31-5e45b98bc459")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
		dsd.addColumn("referred_location", sdd.definition("referralPlace",  getConcept("dce015bb-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}", new ObsDataConverter());
//		dsd.addColumn("counselor_name", builtInPatientData.getPreferredFamilyName(), (String) null);//TODO: Get the service provider
		return dsd;
	}
}
