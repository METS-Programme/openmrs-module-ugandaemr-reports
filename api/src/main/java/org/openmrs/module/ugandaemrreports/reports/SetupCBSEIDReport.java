/*
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandaemrreports.reports;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.openmrs.module.ugandaemrreports.library.CommonCohortDefinitionLibrary;
import org.openmrs.module.ugandaemrreports.library.DataFactory;
import org.openmrs.module.ugandaemrreports.library.EIDCohortDefinitionLibrary;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class SetupCBSEIDReport extends UgandaEMRDataExportManager {

	@Autowired
	private DataFactory df;

	@Autowired
	private EIDCohortDefinitionLibrary eidCohorts;

	@Autowired
	private CommonCohortDefinitionLibrary commonCohortDefinitionLibrary;

	public SetupCBSEIDReport() {
	}

	@Override
	public String getUuid() {
		return "167cf668-0715-488b-b159-d5f391774099";
	}

	@Override
	public String getName() {
		return "CBS EID Cohort Report";
	}

	@Override
	public String getDescription() {
		return "CBS Cohort for HIV Exposed Infants";
	}

	@Override
	public List<Parameter> getParameters() {
		List<Parameter> l = new ArrayList<Parameter>();
		l.add(df.getStartDateParameter());
		l.add(df.getEndDateParameter());
		return l;
	}

	@Override
	public ReportDefinition constructReportDefinition() {

		ReportDefinition rd = new ReportDefinition();
		rd.setUuid(getUuid());
		rd.setName(getName());
		rd.setDescription(getDescription());
		rd.setParameters(getParameters());

		rd.setBaseCohortDefinition(Mapped.mapStraightThrough(eidCohorts.getPatientsWithAnEIDNumber()));

		CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
		dsd.setParameters(getParameters());
		rd.addDataSetDefinition("cohort", Mapped.mapStraightThrough(dsd));

		CohortDefinition allEIDPatients = eidCohorts.getAllEIDPatients();
		CohortDefinition getTransferIns = eidCohorts.getEIDTransferIns();
		CohortDefinition getTransferOuts = eidCohorts.getEIDPatientsFinallyTransferredOut();

		CohortDefinition netCurrentCohort = df.getPatientsInAny(allEIDPatients,
				df.getPatientsNotIn(getTransferIns, getTransferOuts));

		CohortDefinition males = commonCohortDefinitionLibrary.males();
		CohortDefinition females = commonCohortDefinitionLibrary.females();

		CohortDefinition givenNVPAtBirth = eidCohorts.getEIDPatientsGivenNVP();
		CohortDefinition initiatedOnCPT = eidCohorts.getEIDPatientsInitiatedOnCPT();

		CohortDefinition testedUsingFirstDNAPCR = eidCohorts.getEIDPatientsTestedUsingFirstDNAPCR();
		CohortDefinition testedUsingSecondDNAPCR = eidCohorts.getEIDPatientsTestedUsingSecondDNAPCR();
		CohortDefinition testedUsingABTest = eidCohorts.getEIDPatientsTestedUsingABTest();

		CohortDefinition getEIDWHODiedDied = eidCohorts.getEIDPatientsWhoDied();

		CohortDefinition getEIDPatientsFinallyPositive = eidCohorts.getEIDPatientsFinallyPositive();

		CohortDefinition getEIDPatientsFinallyNegative = eidCohorts.getEIDPatientsFinallyNegative();

		CohortDefinition getFinallyPositiveWhoDied = df.getPatientsInAll(getEIDPatientsFinallyPositive, getEIDWHODiedDied);
		CohortDefinition getFinallyNegativeWhoDied = df.getPatientsInAll(getEIDPatientsFinallyNegative, getEIDWHODiedDied);
		CohortDefinition getOthersWhoDied = df.getPatientsNotIn(getEIDWHODiedDied,
				df.getPatientsInAny(getEIDPatientsFinallyPositive, getEIDPatientsFinallyNegative));

		CohortDefinition firstDNAPCRWhoseResultsGivenToCareGiver = eidCohorts
				.getEIDPatientsTestedUsingFirstDNAPCRWhoseResultsGivenToCareGiver();
		CohortDefinition secondDNAPCRWhoseResultsGivenToCareGiver = eidCohorts
				.getEIDPatientsTestedUsingSecondDNAPCRWhoseResultsGivenToCareGiver();
		CohortDefinition aBTestWhoseResultsGivenToCareGiver = eidCohorts
				.getEIDPatientsTestedUsingABTestWhoseResultsGivenToCareGiver();

		CohortDefinition testedPositiveUsingFirstDNAPCR = eidCohorts.getEIDPatientsTestedPositiveUsingFirstDNAPCR();
		CohortDefinition testedPositiveUsingSecondDNAPCR = eidCohorts.getEIDPatientsTestedPositiveUsingSecondDNAPCR();
		CohortDefinition testedPositiveUsingABTest = eidCohorts.getEIDPatientsTestedPositiveUsingABTest();

		CohortDefinition getLostToFollowup = eidCohorts.getEIDLostToFollowup();

		CohortDefinition getEIDPatientsOnART = eidCohorts.getEIDOnART();

		addIndicator(dsd, "1m", "Original Cohort Males", df.getPatientsInAll(allEIDPatients, males));
		addIndicator(dsd, "2m", "Males transferred in", df.getPatientsInAll(getTransferIns, males));
		addIndicator(dsd, "3m", "Males transferred out", df.getPatientsInAll(getTransferOuts, males));
		addIndicator(dsd, "4m", "Males net current cohort", df.getPatientsInAll(netCurrentCohort, males));
		addIndicator(dsd, "5m", "Males give NVP", df.getPatientsInAll(netCurrentCohort, givenNVPAtBirth, males));
		addIndicator(dsd, "6m", "Males initiated on CPT", df.getPatientsInAll(netCurrentCohort, initiatedOnCPT, males));
		addIndicator(dsd, "7m", "Males tested using first DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedUsingFirstDNAPCR, males));
		addIndicator(dsd, "8m", "Males tested using first DNA PCR test whose result where given to the caregiver",
				df.getPatientsInAll(netCurrentCohort, firstDNAPCRWhoseResultsGivenToCareGiver, males));
		addIndicator(dsd, "9m", "Males tested positive using first DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingFirstDNAPCR, males));
		addIndicator(dsd, "10m", "Males tested using second DNA PCR Test",
				df.getPatientsInAll(netCurrentCohort, testedUsingSecondDNAPCR, males));
		addIndicator(dsd, "11m", "Males tested using second DNA PCR test whose result where given to the caregiver",
				df.getPatientsInAll(netCurrentCohort, secondDNAPCRWhoseResultsGivenToCareGiver, males));
		addIndicator(dsd, "12m", "Males tested positive using second DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingSecondDNAPCR, males));
		addIndicator(dsd, "13m", "Males tested using AB Test",
				df.getPatientsInAll(netCurrentCohort, testedUsingABTest, males));
		addIndicator(dsd, "14m", "Males tested positive using second AB PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingABTest, males));
		addIndicator(dsd, "15m", "Males HIV positive babies initiated on ART",
				df.getPatientsInAll(netCurrentCohort, getEIDPatientsOnART, males));
		addIndicator(dsd, "16m", "Males HIV positive HEI who died",
				df.getPatientsInAll(netCurrentCohort, getFinallyPositiveWhoDied, males));
		addIndicator(dsd, "17m", "Males HIV negative HEI who died",
				df.getPatientsInAll(netCurrentCohort, getFinallyNegativeWhoDied, males));
		addIndicator(dsd, "18m", "Males unknown status HEI who died",
				df.getPatientsInAll(netCurrentCohort, getOthersWhoDied, males));
		addIndicator(dsd, "19m", "Males discharged as negative",
				df.getPatientsInAll(netCurrentCohort, getEIDPatientsFinallyNegative, males));
		addIndicator(dsd, "20m", "Males lost to followup", df.getPatientsInAll(netCurrentCohort, getLostToFollowup, males));

		addIndicator(dsd, "1f", "Original Cohort Females", df.getPatientsInAll(allEIDPatients, females));
		addIndicator(dsd, "2f", "Females transferred in", df.getPatientsInAll(getTransferIns, females));
		addIndicator(dsd, "3f", "Females transferred out", df.getPatientsInAll(getTransferOuts, females));
		addIndicator(dsd, "4f", "Females net current cohort", df.getPatientsInAll(netCurrentCohort, females));
		addIndicator(dsd, "5f", "Females give NVP", df.getPatientsInAll(netCurrentCohort, givenNVPAtBirth, females));
		addIndicator(dsd, "6f", "Females initiated on CPT", df.getPatientsInAll(netCurrentCohort, initiatedOnCPT, females));
		addIndicator(dsd, "7f", "Females tested using first DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedUsingFirstDNAPCR, females));
		addIndicator(dsd, "8f", "Females tested using first DNA PCR test whose result where given to the caregiver",
				df.getPatientsInAll(netCurrentCohort, firstDNAPCRWhoseResultsGivenToCareGiver, females));
		addIndicator(dsd, "9f", "Females tested positive using first DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingFirstDNAPCR, females));
		addIndicator(dsd, "10f", "Females tested using second DNA PCR Test",
				df.getPatientsInAll(netCurrentCohort, testedUsingSecondDNAPCR, females));
		addIndicator(dsd, "11f", "Females tested using second DNA PCR test whose result where given to the caregiver",
				df.getPatientsInAll(netCurrentCohort, secondDNAPCRWhoseResultsGivenToCareGiver, females));
		addIndicator(dsd, "12f", "Females tested positive using second DNA PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingSecondDNAPCR, females));
		addIndicator(dsd, "13f", "Females tested using AB Test",
				df.getPatientsInAll(netCurrentCohort, testedUsingABTest, females));
		addIndicator(dsd, "14f", "Females tested positive using second AB PCR test",
				df.getPatientsInAll(netCurrentCohort, testedPositiveUsingABTest, females));
		addIndicator(dsd, "15f", "Females HIV positive babies initiated on ART",
				df.getPatientsInAll(netCurrentCohort, getEIDPatientsOnART, females));
		addIndicator(dsd, "16f", "Females HIV positive HEI who died",
				df.getPatientsInAll(netCurrentCohort, getFinallyPositiveWhoDied, females));
		addIndicator(dsd, "17f", "Females HIV negative HEI who died",
				df.getPatientsInAll(netCurrentCohort, getFinallyNegativeWhoDied, females));
		addIndicator(dsd, "18f", "Females unknown status HEI who died",
				df.getPatientsInAll(netCurrentCohort, getOthersWhoDied, females));
		addIndicator(dsd, "19f", "Females discharged as negative",
				df.getPatientsInAll(netCurrentCohort, getEIDPatientsFinallyNegative, females));
		addIndicator(dsd, "20f", "Females lost to followup",
				df.getPatientsInAll(netCurrentCohort, getLostToFollowup, females));

		return rd;
	}

	public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label,
	                         CohortDefinition cohortDefinition) {
		CohortIndicator ci = new CohortIndicator();
		ci.addParameters(dsd.getParameters());
		ci.setType(CohortIndicator.IndicatorType.COUNT);
		ci.setCohortDefinition(Mapped.mapStraightThrough(cohortDefinition));
		dsd.addColumn(key, label, Mapped.mapStraightThrough(ci), "");
	}

	@Override
	public String getExcelDesignUuid() {
		return "b98ab976-9c9d-4a28-9760-ac3119cbef44";
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
		return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "CBSEIDCohortReport.xls");
	}

	@Override
	public String getVersion() {
		return "0.1.1";
	}
}
