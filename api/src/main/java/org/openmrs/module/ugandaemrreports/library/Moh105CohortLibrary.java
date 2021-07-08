/**
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
package org.openmrs.module.ugandaemrreports.library;

import org.openmrs.Concept;
import org.openmrs.EncounterType;
import org.openmrs.api.context.Context;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.reporting.cohort.definition.*;
import org.openmrs.module.reporting.common.RangeComparator;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.calculation.EmptyProcedureMethods;
import org.openmrs.module.ugandaemrreports.reporting.calculation.EmptySiteType;
import org.openmrs.module.ugandaemrreports.reporting.calculation.smc.SmcReturnFollowUpCalculation;
import org.openmrs.module.ugandaemrreports.reporting.cohort.definition.CalculationCohortDefinition;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.openmrs.module.ugandaemrreports.reporting.utils.CoreUtils;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

/**
 * 
 */
@Component
public class Moh105CohortLibrary {

    @Autowired
    CommonCohortDefinitionLibrary definitionLibrary;
    
    @Autowired
    HIVMetadata hivMetadata;
    
    @Autowired
    private DataFactory df;

    public CohortDefinition femaleAndHasAncVisit(double lower, double upper){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Female and has ANC Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("female", ReportUtils.map(definitionLibrary.females(), ""));
        cd.addSearch("ancVist", ReportUtils.map(totalAncVisits(lower, upper), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("female AND ancVist AND ancEncounter");
        return cd;
    }

    public CohortDefinition femaleAndHasAncVisitBeforePeriod(double lower, double upper){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Female and has ANC Visit");
//        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("female", ReportUtils.map(definitionLibrary.females(), ""));
        cd.addSearch("ancVist", ReportUtils.map(totalAncVisitsBeforePeriod(lower, upper), "onOrBefore=${endDate}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrBefore=${endDate}"));
        cd.setCompositionString("female AND ancVist AND ancEncounter");
        return cd;
    }

    public CohortDefinition testedForAneamiaAndANCVisit(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Tested for Anaemia and ANC Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("testedForAnaemia",ReportUtils.map(testedForAnaemia(0.0,15.5)));
        cd.addSearch("ancVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrBefore=${endDate}"));
        cd.setCompositionString("ancVisit AND testedForAnaemia ");
        return cd;
    }

    public CohortDefinition pregnantWomenTestedForAneamiaat36(double value){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Tested for Anaemia and ANC Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("testedForAnaemia",ReportUtils.map(testedForAnaemia(0.0,15.5)));
        cd.addSearch("gestationAge", ReportUtils.map(gestationAge(value), "onOrBefore=${endDate}"));
        cd.setCompositionString("gestationAge AND testedForAnaemia");
        return cd;
    }
    public CohortDefinition pregnantWomenTestedPositiveForAneamiaat36(double value){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Tested for Anaemia and ANC Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("testedPositiveForAnaemia",ReportUtils.map(testedForAnaemia(0.0,10.0)));
        cd.addSearch("gestationAge", ReportUtils.map(gestationAge(value), "onOrBefore=${endDate}"));
        cd.setCompositionString("gestationAge AND testedPositiveForAnaemia ");
        return cd;
    }

    public CohortDefinition testedPositiveAneamiaAndANCVisit(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Tested for Anaemia and ANC Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("testedPositiveAnaemia",ReportUtils.map(testedForAnaemia(0.0,9.0)));
        cd.addSearch("ancVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrBefore=${endDate}"));
        cd.setCompositionString("ancVisit AND testedPositiveAnaemia");
        return cd;
    }
    public CohortDefinition recievedFreeLLNonANCVisit(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women receiving LLN on ANC 1st Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("femaleAndHasAncVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("recievingLLN", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("3e7bb52c-e6ae-4a0b-bce0-3b36286e8658"), Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ancEncounter AND femaleAndHasAncVisit AND recievingLLN");
        return cd;
    }

    /**
     * Total ANC visits - including new clients and re-attendances
     * @return CohortDefinition
     */
    public CohortDefinition totalAncVisits(double lower, double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Anc visit between "+lower+" and "+upper);
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept("c7231d96-34d8-4bf7-a509-c810f75e3329"));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.setValue2(upper);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }

    public CohortDefinition testedForAnaemia(double lower, double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Tested for Anemia "+lower+" and "+upper);
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept("55a56b88-579b-408f-8f8d-d133d9c6a9a6"));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.setValue2(upper);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }
    public CohortDefinition gestationAge(double value) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Tested for Anemia at 36 weeks");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept("a851cc3a-bc18-4279-8231-9ddd5230af57"));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.setValue1(value);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }

    public CohortDefinition totalAncVisitsBeforePeriod(double lower, double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Anc visit between "+lower+" and "+upper);
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept("801b8959-4b2a-46c0-a28f-f7d3fc8b98bb"));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.setValue2(upper);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }


    /**
     * Pregnant women receiving iron/folic acid on ANC 1st Visit
     * @return CohortDefinition
     */
    public CohortDefinition pregnantAndReceivingIronOrFolicAcidAnc1stVisit(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women receiving iron/folic acid on ANC 1st Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("femaleAndHasAncVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("takingIron", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("315825e8-8ba4-4551-bdd1-aa4e02a36639"), Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("takingFolic", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("8c346216-c444-4528-a174-5139922218ed"), Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("(ancEncounter AND femaleAndHasAncVisit) AND (takingIron OR takingFolic)");
        return cd;
    }

    /**
     * Numeric Concept Observations Question
     */
    public CohortDefinition numericObservations(String concept,double lower) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("NUmeric Observations");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept(concept));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.setValue1(lower);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }
    public CohortDefinition numericObservations(String concept,double lower,double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("NUmeric Observations");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept(concept));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_THAN);
        cd.setValue2(upper);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        return cd;
    }

    /**
     * Pregnant women recieving atleast 30 tablets of follic acid and iron on first anc visit
     * @return
     */
    public CohortDefinition pregnantAndRecievedIronandFollicAcidGreaterthan30() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women receiving iron/folic acid on ANC 1st Visit");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("femaleAndHasAncVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("iron",ReportUtils.map(numericObservations("02d9887-6a46-43cc-9495-5ec034dc05d6",30.0)));
        cd.addSearch("follicacid",ReportUtils.map(numericObservations("961ff308-bc19-4ae4-ba11-fe29157d20f9",30.0)));
        cd.addSearch("combined",ReportUtils.map(numericObservations("b1e565e0-833e-4c9e-aea4-43ebf781c1e4",30.0)));
        cd.setCompositionString("femaleAndHasAncVisit AND (iron OR follicacid OR combined )");
        return cd;
    }
    public CohortDefinition pregnantAndRecievedIronandFollicAcidGreaterthan30After36Weeks() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women receiving iron/folic acid after 36 weeks");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("gestationAge", ReportUtils.map(gestationAge(36.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("iron",ReportUtils.map(numericObservations("02d9887-6a46-43cc-9495-5ec034dc05d6",30.0)));
        cd.addSearch("follicacid",ReportUtils.map(numericObservations("961ff308-bc19-4ae4-ba11-fe29157d20f9",30.0)));
        cd.addSearch("combined",ReportUtils.map(numericObservations("b1e565e0-833e-4c9e-aea4-43ebf781c1e4",30.0)));
        cd.setCompositionString("gestationAge AND (iron OR follicacid OR combined )");
        return cd;
    }
    /**
     * Recieving Mabendazole after 28 weeks of gestation
     */
    public CohortDefinition pregnantAndRecievedMabendazoleAfter28Weeks() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women receiving Mabendazole After 28 Weeks");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("mabendazole", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("9d6abbc4-707a-4ec7-a32a-4090b1c3af87"), Dictionary.getConcept("a7a9d632-b266-4085-9a5e-57fc8dd56f0c")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("gestationAge", ReportUtils.map(gestationAge(28.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("gestationAge AND mabendazole");
        return cd;
    }



    /**
     * Pregnant women diagonised with TB
     * @return
     */

    public CohortDefinition pregnantAndDiagnisedWithTB(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Pregnant women Diagnosed with TB");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("femaleAndHasAncVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("clinicalDiagnosis", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("1435dcb2-9470-4b69-8d05-199e5f13044c")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("genexpert", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("36cd82a6-370d-4188-bf69-ad8ebbc86d37")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("tbLAM", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("d941bfbc-7546-464b-90ff-b8e28d247d47")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("tbMicroscopy", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("d5a86db5-3e7f-4344-85d7-572c8bb6b966")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("chestXray", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("e2fd439a-619e-4067-a2f1-8e2454120a58")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("otherDiagnosis", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("ff246b26-f2d1-45f6-9e33-385eb8d19d3f")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("(ancEncounter AND femaleAndHasAncVisit) AND (clinicalDiagnosis OR genexpert OR tbLAM OR tbMicroscopy OR chestXray OR otherDiagnosis)");
        return cd;
    }
    
    /**
     * HIV Positive before first ANC
     * @return
     */
    public CohortDefinition hivPostiveBeforeFirstANCVisit() {
        return definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.HIV_STATUS), Dictionary.getConcept(Metadata.Concept.HIV_POSITIVE));
    }

    /**
     * Assessed by
     * @return CohortDefinition
     */
    public CohortDefinition assessedByNumericValues(Concept question) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Numeric obs based on question");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(question);
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        return cd;
    }

    /**
     * HIV+ pregnant women assessed by CD4 or WHO clinical stage for the 1st time
     * @return CohortDefinition
     */
    public CohortDefinition hivPositiveAndAccessedWithCd4WhoStage(Concept question) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ assed by "+question.getName().getName());
        cd.addSearch("assessedBy", ReportUtils.map(assessedByNumericValues(question), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("assessedBy AND ancEncounter");
        return cd;
    }
        
    /**
     * Mothers admitted to Maternity Clinic
     *
     * @return the cohort definition
     */
    public CohortDefinition maternityAdmissions() {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(Arrays.asList(CoreUtils.getEncounterType(Metadata.EncounterType.MATERNITY_ENCOUNTER)));
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        return cd;
    }    

	/**
	 * HIV Positive Persons
	 * @return CohortDefinition 
	 */
    public CohortDefinition hivPositivePersons() {
    	return definitionLibrary.hasObs(Dictionary.getConcept("dce0e886-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dcdf4241-30ab-102d-86b0-7a5022ba4115"));
    }    
    
    /**
     * HIV+ women
     * @return CohortDefinition
     */
    public CohortDefinition hivPositiveWomen() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ Women");
        cd.addSearch("female", ReportUtils.map(definitionLibrary.females(), ""));
        cd.addSearch("hivPositive", ReportUtils.map(hivPositivePersons(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("female AND hivPositive");
        return cd;
    }

    /**
     * Deliveries in unit
     * @return CohortDefinition
     */
    public CohortDefinition deliveriesInUnit() {
        return definitionLibrary.hasObs(Dictionary.getConcept("161033AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"));
    }    
    
    /**
     * Deliveries in unit 10-19
     * @return CohortDefinition
     */
    public CohortDefinition deliveriesInUnit10To19() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Deliveries in unit 10-19");
        cd.addSearch("deliveriesInUnit", ReportUtils.map(deliveriesInUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("Age10To19", ReportUtils.map(definitionLibrary.agedBetween(10,19), "endDate=${onOrBefore}"));
        cd.setCompositionString("deliveriesInUnit AND Age10To19");
        return cd;
    }

    public CohortDefinition discordantCouples() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Discordant Couples");
        cd.addSearch("positiveFemaleNegativePartner", ReportUtils.map(positiveFemaleNegativePartner(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("negativeFemalePositivePartner", ReportUtils.map(negativeFemalePositivePartner(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("positiveFemaleNegativePartner AND negativeFemalePositivePartner");
        return cd;
    }

    public CohortDefinition positiveFemaleNegativePartner() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Discordant Couples");
        cd.addSearch("positiveFemales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRTICK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("negativeMales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODESP),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRP),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("positiveFemales AND negativeMales");
        return cd;
    }

    public CohortDefinition negativeFemalePositivePartner() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Discordant Couples");
        cd.addSearch("negativeFemales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRP),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("positiveMales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODESP),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRTICK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("positiveMales AND negativeFemales");
        return cd;
    }


    public CohortDefinition marternalCounsellingandPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Maternal Counselling and Positive");
        cd.addSearch("positiveFemales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRTICK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("maternalCounselling", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept("af7dccfd-4692-4e16-bd74-5ac4045bb6bf"),Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.setCompositionString("positiveFemales AND maternalCounselling");
        return cd;
    }

    public CohortDefinition infantCounsellingAndPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Infant Counselling and Positive");
        cd.addSearch("positiveFemales", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRTICK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("infantCounselling", ReportUtils.map(definitionLibrary.hasANCObs(Dictionary.getConcept("5d993591-9334-43d9-a208-11b10adfad85"),Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.setCompositionString("positiveFemales AND infantCounselling");
        return cd;
    }





    /**
     * Deliveries in unit 20-24
     * @return CohortDefinition
     */
    public CohortDefinition deliveriesInUnit20To24() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Deliveries in unit 20-24");
        cd.addSearch("deliveriesInUnit", ReportUtils.map(deliveriesInUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("Age20To24", ReportUtils.map(definitionLibrary.agedBetween(20,24), "endDate=${onOrBefore}"));
        cd.setCompositionString("deliveriesInUnit AND Age20To24");
        return cd;
    }    

    /**
     * Deliveries in unit 25 and above
     * @return CohortDefinition
     */
    public CohortDefinition deliveriesInUnit25AndAbove() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Deliveries in unit 25 and above");
        cd.addSearch("deliveriesInUnit", ReportUtils.map(deliveriesInUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("Age25AndABove", ReportUtils.map(definitionLibrary.agedAtLeast(25), "endDate=${onOrBefore}"));
        cd.setCompositionString("deliveriesInUnit AND Age25AndABove");
        return cd;
    }    
    
    /**
     * HIV+ women initiating ARV in maternity
     * @return CohortDefinition
     */
    public CohortDefinition hivPositiveWomenInitiatingArvInMaternity() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ Initiating Maternity");
        cd.addSearch("hivPositive", ReportUtils.map(hivPositiveWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("InitiatingARV", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("35ae2043-a3b0-48de-8e22-05f377ac39a2")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("hivPositive AND InitiatingARV");
        return cd;
    }
    
    /**
     * Deliveries to HIV+ women
     * @return CohortDefinition
     */
    public CohortDefinition deliveriesToHIVPositiveWomen() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ Women Deliveries");
        cd.addSearch("hivPositive", ReportUtils.map(hivPositiveWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("deliveries", ReportUtils.map(deliveriesInUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("hivPositive AND deliveries");
        return cd;
    }

    /**
     * Total HIV+ mothers attending postnatal
     * Those who are hiv postive
     * Counselled tested and results given - Client tested HIV+ in PNC,
     *Client tested HIV+ on a re-test
     * Client tested on previous visit with known HIV+ status
     */
    public CohortDefinition hivPositiveMothersInAnc() {
        Concept emtctQ = Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74");
        Concept trr = Dictionary.getConcept("86e394fd-8d85-4cb3-86d7-d4b9bfc3e43a");
        Concept trrPlus = Dictionary.getConcept("60155e4d-1d49-4e97-9689-758315967e0f");
        Concept trrTick = Dictionary.getConcept("1f177240-85f6-4f10-964a-cfc7722408b3");

        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("emctCodes", ReportUtils.map(definitionLibrary.hasObs(emtctQ, trr, trrPlus, trrTick), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.PNC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("emctCodes AND ancEncounter");
        return cd;
    }

    /**ancEncounter
     * Mother-baby pairs enrolled at Mother-Baby care point
     * @return CohortDefinition
     */
    public CohortDefinition motherBabyEnrolled() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("hasEncounter", ReportUtils.map(definitionLibrary.hasEncounter(Context.getEncounterService().getEncounterTypeByUuid("fa6f3ff5-b784-43fb-ab35-a08ab7dbf074")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("babyAl", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("dd8a2ad9-16f6-44db-82d7-87d6eef14886"), Dictionary.getConcept("9d9e6b5a-8b5d-4b8c-8ab7-9fdabb279493")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("hasEncounter AND babyAl");
        return cd;
    }

    
    public CohortDefinition missedANCAppointment() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("hasAppointment", ReportUtils.map(
                df.getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(hivMetadata.getReturnVisitDate(), Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), BaseObsCohortDefinition.TimeModifier.ANY), "startDate=${onOrAfter},endDate=${onOrBefore}"));
        
        cd.addSearch("hasVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 10.0), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
    
        cd.setCompositionString("hasAppointment NOT hasVisit");
		return cd;
    }
        
    /** Maternal deaths - Age 20-24
     * @return CohortDefinition
     */
    public CohortDefinition maternalDeathsAge20To24() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Maternal deaths 20-24");
        cd.addSearch("maternalDeaths", ReportUtils.map(maternalDeaths(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("Age20To24", ReportUtils.map(definitionLibrary.agedBetween(20,24), "endDate=${onOrBefore}"));
        cd.setCompositionString("maternalDeaths AND Age20To24");
        return cd;
    }

    /**
     * Maternal deaths - Age 25 and above
     * @return CohortDefinition
     */
    public CohortDefinition maternalDeathsAge25AndAbove() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Maternal deaths 25 and above");
        cd.addSearch("maternalDeaths", ReportUtils.map(maternalDeaths(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("Age25AndAbove", ReportUtils.map(definitionLibrary.agedAtLeast(25), "endDate=${onOrBefore}"));
        cd.setCompositionString("maternalDeaths AND Age25AndAbove");
        return cd;
    }

    /**
     * All Family Planning Users
     * @return CohortDefinition
     */    
	public CohortDefinition allFamilyPlanningUsers() {
		return definitionLibrary.hasObs(
			Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),
			Dictionary.getConceptList("38aa1dc0-1aaa-4bdd-b26f-28f960dfb16c,"
				+ "4b0899f2-395e-4e0f-8b58-d304b214615e,"
				+ "82624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,"
				+ "670b7048-d71e-483a-b2ec-f10d2326dd84,"
				+ "dc882c84-30ab-102d-86b0-7a5022ba4115,"
				+ "aeee4ccf-cbf8-473c-9d9f-846643afbf11,"
				+ "dcb2f595-30ab-102d-86b0-7a5022ba4115,"
				+ "fed07c37-7bb6-4baa-adf9-596ce4c4e93c,"
				+ "dd4c3016-13cf-458a-8e93-fe54460be667,"
				+ "dcb30ba3-30ab-102d-86b0-7a5022ba4115,"
				+ "dcb30381-30ab-102d-86b0-7a5022ba4115,"
				+ "5622AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,"
				+ "dcb2fba9-30ab-102d-86b0-7a5022ba4115,"
				+ "dcdd8d8d-30ab-102d-86b0-7a5022ba4115,"
				+ "bb83fd9d-24c5-4d49-89c0-97e13c792aaf,"
				+ "dcdd91a7-30ab-102d-86b0-7a5022ba4115,"
				+ "efbe5bf3-3411-4949-855b-636ada05f5e7,"
				+ "336650b2-65f7-4202-80eb-3c6437878262,"
				+ "3e18cafc-8edc-4648-94b3-835de371a2f2,"
				+ "aa14bbbb-cbbe-445d-8958-9f521220b0fd,"
				+ "dc692ad3-30ab-102d-86b0-7a5022ba4115"));
	}
	
    /**
     * HIV+ Family Planning Users 
     * @return CohortDefinition
     */
    public CohortDefinition hivPositiveFamilyPlanningUsers() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ And Family Planning Users");
        cd.addSearch("fpUsers", ReportUtils.map(allFamilyPlanningUsers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("hivPositive", ReportUtils.map(hivPositivePersons(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("fpUsers AND hivPositive");
        return cd;
    }
    
    //Begin HCT Section
    
    /**
     * Pre-test Counseling done
     * @return CohortDefinition
     */
    public CohortDefinition pretestCounselingDone() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.PRETEST_COUNSELING_DONE),Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115"));
    }

    /**
     * Counseled as individuals
     * @return CohortDefinition
     */
    public CohortDefinition counseledAsIndividuals() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUNSELING_SESSION_TYPE),Dictionary.getConcept("c61ea879-2a23-484d-bec1-ab177a926265"));
    }

    /**
     * Counseled as couples
     * @return CohortDefinition
     */
    public CohortDefinition counseledAsACouple() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUNSELING_SESSION_TYPE),Dictionary.getConcept("6ef3d796-7940-44fe-b0d9-06ab1b824e5b"));
    }

    /**
     * Individuals Counseled 
     * @return CohortDefinition
     */
    public CohortDefinition individualsCounseled() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals Counseled");
        cd.addSearch("PretestCounselingDone", ReportUtils.map(pretestCounselingDone(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PretestCounselingDone AND counseledAsIndividuals");
        return cd;
    }

    /**
     * pregnantWomenNewlyTestedForHivThisPregnancyTRR at any visit
     * @return CohortDefinition
     */
    public CohortDefinition pregnantWomenNewlyTestedForHivThisPregnancyTRRAnyVisit(){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("trr", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"), Dictionary.getConcept("25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.addSearch("anyVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 10.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("trr AND anyVisit AND ancEncounter");
		return cd;
    }

    /**
     * pregnantWomenNewlyTestedForHivThisPregnancyTRR at 1st visit
     * @return CohortDefinition
     */
    public CohortDefinition pregnantWomenNewlyTestedForHivThisPregnancyAt1stVisitTRR(){
        return pregnantWomenThisPregnancyAt1stANCVisit(Dictionary.getConcept("25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465"),"trr");
    }

    /**
     * pregnantWomenNewlyTestedForHivThisPregnancyTR at 1st visit
     * @return CohortDefinition
     */
    public CohortDefinition pregnantWomenNewlyTestedForHivThisPregnancyAt1stVisitTR(){
     return pregnantWomenThisPregnancyAt1stANCVisit(Dictionary.getConcept("86e394fd-8d85-4cb3-86d7-d4b9bfc3e43a"),"tr");
    }

    public CohortDefinition pregnantWomenThisPregnancyAt1stANCVisit(Concept answer,String name){
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch(name, ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"),answer), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.addSearch("firstVisit", ReportUtils.map(femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString(name+" AND firstVisit AND ancEncounter");
        return cd;
    }
     /** With HIV Test Results
     * @return CohortDefinition
     */
    public CohortDefinition haveHivTestResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS));
    }    
    
    /**
     * Individuals Tested 
     * @return CohortDefinition
     */
    public CohortDefinition individualsTested() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals Tested");
        cd.addSearch("withHivTestResults", ReportUtils.map(haveHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("withHivTestResults");
        return cd;
    }

    /**
     * combine the has obs cohort definiton with the encounter provided
     * @return CohortDefinition
     */
    public CohortDefinition hasObsAndEncounter(String encounterType, Concept q, Concept ... a){
    	return hasObsAndEncounter(encounterType, q, Arrays.asList(a));
    }

	public CohortDefinition hasObsAndEncounter(String encounterType, Concept q, List<Concept> a) {
    	CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("hasEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, encounterType)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("hasObs", ReportUtils.map(definitionLibrary.hasObs(q, a), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("hasEncounter AND hasObs");
        return cd;
	}    
    
    /** Received HIV Test Results
     * @return CohortDefinition
     */
    public CohortDefinition receivedHivTestResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.RECEIVED_HIV_TEST_RESULTS),Dictionary.getConceptList(Metadata.Concept.YES_CIEL));
    }
    public CohortDefinition receivedHivTestResultsAsaCouple() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.RECEIVED_HIV_TEST_RESULTS_AS_COUPLE),Dictionary.getConceptList(Metadata.Concept.YES_CIEL));
    }
    /**
     * Tested HIV Positive
     * @return CohortDefinition
     */    
    public CohortDefinition testedHivPositive() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS), Dictionary.getConcept(Metadata.Concept.HIV_POSITIVE));
	}

    public CohortDefinition previousHIVtestResult() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.PREVIOUS_HIV_TEST_RESULTS), Dictionary.getConcept(Metadata.Concept.HIV_NEGATIVE));
    }
    /**
     * Tested HIV Negative
     * @return CohortDefinition
     */    
    public CohortDefinition testedHivNegative() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.CURRENT_HIV_TEST_RESULTS), Dictionary.getConcept(Metadata.Concept.HIV_NEGATIVE));
	}    
	
    /**
     * Ever Tested for HIV Before
     * @return CohortDefinition
     */
    public CohortDefinition everTestedForHivBefore() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HIV_TEST), Dictionary.getConcept(Metadata.Concept.YES_CIEL));
    }

    public CohortDefinition individualsTestingFortheFirstTime() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FIRST_HIV_TEST), Dictionary.getConcept(Metadata.Concept.YES_WHO));
    }

    /**
     * Tested in last 12 Months
     * @return CohortDefinition
     */
    public CohortDefinition testedInLast12Months() {
    	return definitionLibrary.hasNumericObs(Dictionary.getConcept(Metadata.Concept.TIMES_TESTED_IN_LAST_12_MONTHS),RangeComparator.GREATER_THAN,(double) 0);    	
    }

    /**
     * Tested more than twice in the last 12 Months
     * @return CohortDefinition
     */    
	public CohortDefinition testedMoreThanTwiceInLast12Months() {
    	return definitionLibrary.hasNumericObs(Dictionary.getConcept(Metadata.Concept.TIMES_TESTED_IN_LAST_12_MONTHS),RangeComparator.GREATER_THAN,(double) 2);
    }

    public CohortDefinition testedMoreThanOnceInLast12Months() {
    	return definitionLibrary.hasNumericObs(Dictionary.getConcept(Metadata.Concept.TIMES_TESTED_IN_LAST_12_MONTHS),RangeComparator.GREATER_THAN,(double) 1);
    }
    public CohortDefinition testedForPEP() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.REASON_FOR_TESTING), Dictionary.getConcept(Metadata.Concept.POST_EXPOSURE_PROPHYLAXIS));
    }
    /**
     * Individuals who received HIV Test Results
     * @return CohortDefinition
     */
    public CohortDefinition individualsWhoReceivedHIVTestResults() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who received HIV Test Results");
        cd.addSearch("receivedHivTestResults", ReportUtils.map(receivedHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("receivedHivTestResults AND counseledAsIndividuals");
        return cd;
	}
    public CohortDefinition individualsWhoPreviouslyareNegativeAndCurrentlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who received HIV Test Results");
        cd.addSearch("currentlyHIVpositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("previouslyHIVnegative", ReportUtils.map(previousHIVtestResult(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("currentlyHIVpositive AND previouslyHIVnegative");
        return cd;
    }

    public CohortDefinition newHIVpositiveClients() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who received HIV Test Results");
        cd.addSearch("currentlyHIVpositive", ReportUtils.map(individualsWhoPreviouslyareNegativeAndCurrentlyPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("newlyTested", ReportUtils.map(totalNumberofInidividualsNewlyTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("currentlyHIVpositive OR newlyTested");
        return cd;
    }
    public CohortDefinition totalNumberofInidividualsNewlyTested() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who newly tested for HIV");
        cd.addSearch("testedHivPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedHivPositive AND firsttimetesting");
        return cd;
    }
    /**
     * Number of individuals who received HIV results in the last 12months
     * @return CohortDefinition
     */
    public CohortDefinition individualsWhoReceivedHIVTestResultsInLast12Months() {
	    /**
	     * Individuals Who Received HIV Test Results
	     * @return CohortDefinition
	     */
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who received HIV Test Results in Last 12 Months");
        cd.addSearch("receivedHivTestResults", ReportUtils.map(receivedHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("TestedInLast12Months", ReportUtils.map(testedInLast12Months(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("receivedHivTestResults AND counseledAsIndividuals AND TestedInLast12Months");
        return cd;
	}    
    
    /**
     * Individuals Tested for the first time
     * @return CohortDefinition
     */
    public CohortDefinition individualsTestedFirstTime() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals Tested First Time");
        cd.addSearch("testedFirstTime", ReportUtils.map(everTestedForHivBefore(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedFirstTime AND counseledAsIndividuals");
        return cd;
    }

    /**
     * Individuals who Tested HIV Positive
     * @return CohortDefinition
     */
    public CohortDefinition individualsWhoTestedHivPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who Tested HIV Positive");
        cd.addSearch("testedHivPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedHivPositive AND counseledAsIndividuals");
        return cd;
	}

    /**
     * HIV positive individuals with presumptive TB
     * @return CohortDefinition
     */
	public CohortDefinition individualsWhoTestedHivPositiveAndWithPresumptiveTB() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who Tested HIV Positive And With Presumptive TB");
        cd.addSearch("tbSuspect", ReportUtils.map(tbSuspect(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedHivPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedHivPositive AND tbSuspect");
        return cd;
	}

    /**
     * TB Suspect
     * @return CohortDefinition
     */
	public CohortDefinition tbSuspect() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TB_SUSPECT), Dictionary.getConcept(Metadata.Concept.YES_CIEL));
	}

	/**
	 * Individuals tested more than twice in the last 12 months
	 * @return CohortDefinition
	 */			
	public CohortDefinition individualsTestedMoreThanTwiceInLast12Months() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals tested more than twice in the last 12 months");
        cd.addSearch("testedMoreThanTwiceInlast12Months", ReportUtils.map(testedMoreThanTwiceInLast12Months(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedMoreThanTwiceInlast12Months AND counseledAsIndividuals");
        return cd;
	}

	/**
	 * Individuals who were Counseled and Tested together as a Couple
	 * @return CohortDefinition
	 */			
	public CohortDefinition individualsCounseledAndTestedAsACouple() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals Counseled and Tested together as a Couple");
        cd.addSearch("tested", ReportUtils.map(haveHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CounseledAsACouple", ReportUtils.map(counseledAsACouple(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("tested AND CounseledAsACouple");
        return cd;
	}

	/**
	 * Number of individuals who were Tested and Received results together as a Couple
	 * @return CohortDefinition
	 */			
	public CohortDefinition individualsTestedAndReceivedResultsAsACouple() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals who were Tested and Received results together as a Couple");
        cd.addSearch("testedAsACouple", ReportUtils.map(haveHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("ReceivedResultsAsCouple", ReportUtils.map(receivedHivTestResultsAsaCouple(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedAsACouple AND ReceivedResultsAsCouple");
        return cd;
	}

	/**
	 * Individuals counseled and tested for PEP
	 * @return
	 */
	public CohortDefinition individualsCounseledAndTestedForPep() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals counselled and tested for PEP");
        cd.addSearch("testedForPep", ReportUtils.map(testedForPEP(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedForPep AND counseledAsIndividuals");
        return cd;
	}
    public CohortDefinition individualsWithANCandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Individuals with ANC as the HCT Entry Point");
        cd.addSearch("ANCHCTEntryPoint", ReportUtils.map(clientsWithANCEntryPoint(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedHIVPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ANC Entry Point and tested Positive");
        return cd;
    }

    /**
	 * Tested for PEP
	 * @return CohortDefiniton
	 */
	public CohortDefinition testedForPep() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.POST_EXPOSURE_PROPHYLAXIS));
	}

    /**
     * HCT Entry Points
     * @return CohortDefiniton
     */

    public CohortDefinition clientsWithANCEntryPoint() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.ANC));
    }

    public CohortDefinition clientsWithFamilyPlanningDepartmentasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept("164984AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"));
    }
    public CohortDefinition clientsWithMaternityDepartmentasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.MATERNITY));
    }
    public CohortDefinition clientsWithPNCDepartmentasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.PNC));
    }

    public CohortDefinition clientsWithHBHCTasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept("ccb72ac4-7fdb-4695-be5e-68815dda90c4"));
    }

    public CohortDefinition clientsWithWardasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept("c09c3d3d-d07d-4d34-84f0-89ea4fd5d6d5"));
    }
    public CohortDefinition clientsWithOPDasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.OPD));
    }
    public CohortDefinition clientsWithARTasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.ART));
    }
    public CohortDefinition clientsWithTB_CLINICasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.TB_CLINIC));
    }
    public CohortDefinition clientsWithNUTRITION_UNIT_CLINICasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.NUTRITION_UNIT));
    }
    public CohortDefinition clientsWithSTI_UNIT_CLINICasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.STI_UNIT));
    }

    public CohortDefinition clientsWithYCCCLINICasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.YCC_UNIT));
    }
    public CohortDefinition clientsWithSMCDepartmentasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.SMC));
    }
    public CohortDefinition clientsWithEIDDepartmentasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.EID));
    }
    public CohortDefinition clientsWithOtherFacilityPointsasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.OTHERS));
    }

//    COMMUNITY TESTING POINTS

    public CohortDefinition clientsWithWorkPlaceasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT), Dictionary.getConcept(Metadata.Concept.WORK_PLACE));
    }
    public CohortDefinition clientsWithHBCTasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT), Dictionary.getConcept(Metadata.Concept.HBCT));
    }

    public CohortDefinition clientsWithDICasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT), Dictionary.getConcept(Metadata.Concept.DIC));
    }
    public CohortDefinition clientsWithHotSpotasEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT), Dictionary.getConcept(Metadata.Concept.HOT_SPOT));
    }
    public CohortDefinition clientsWithOtherCommunityTestingAsEntryinHTC() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT), Dictionary.getConcept(Metadata.Concept.OTHER_COMMUNITY_TESTING_POINTS));
    }

    public CohortDefinition clientsWithPITCTestingApproach() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUNSELLING_APPROACH), Dictionary.getConcept(Metadata.Concept.PITC));
    }
    public CohortDefinition clientsWithFaciltyBasedDeliveryModel() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HTC_DELIVERY_MODEL), Dictionary.getConcept(Metadata.Concept.FACILITY_BASED));
    }
    public CohortDefinition clientsWithCommunityBasedDeliveryModel() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HTC_DELIVERY_MODEL), Dictionary.getConcept(Metadata.Concept.COMMUNITY_TESTING_POINT));
    }
    public CohortDefinition clientsWithCICTTestingApproach() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUNSELLING_APPROACH), Dictionary.getConcept(Metadata.Concept.CICT));
    }


    /** All special categories people
     * **/
    public CohortDefinition clientsCategorisedAsSpecialCategories() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES));
    }

    /**
     * SPECIAL CATEGORIES CONCEPT ANSWERA
     */
    public CohortDefinition clientsCategorisedAsPrisoners() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.PRISONERS));
    }

    public CohortDefinition clientsCategorisedAsPWIDS() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.PWIDs));
    }
    public CohortDefinition clientsCategorisedAsUniformedMen() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.UNIFORMED_MEN));
    }

    public CohortDefinition clientsCategorisedAsMigrantWorkers() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.MIGRANT_WORKERS));
    }
    public CohortDefinition clientsCategorisedAsTruckerDrivers() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.TRUCKER_DRIVERS));
    }
    public CohortDefinition clientsCategorisedAsFisherFolks() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.FISHER_FOLKS));
    }
    public CohortDefinition clientsCategorisedAsRefugees() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.REFUGEES));
    }
    public CohortDefinition clientsCategorisedAsPregnantWomen() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.PREGNANT_WOMEN));
    }

    public CohortDefinition clientsCategorisedAsBreastFeedingWomen() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.BREAST_FEEDING_WOMEN));
    }
    public CohortDefinition clientsCategorisedAsAGYW() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.AGYW));
    }
    public CohortDefinition clientsCategorisedAsPWDs() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.PWDs));
    }
    public CohortDefinition clientsCategorisedAsOthers() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPECIAL_CATEGORIES), Dictionary.getConcept(Metadata.Concept.OTHERS));
    }
    public CohortDefinition clientsWithRecentTestResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HIV_RECENCY_RESULT), Dictionary.getConcept(Metadata.Concept.RECENT));
    }
    public CohortDefinition clientsWithLongTermTestResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HIV_RECENCY_RESULT), Dictionary.getConcept(Metadata.Concept.LONG_TERM));
    }
    public CohortDefinition totalNumberofPartnersTested() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.SPOUSE_TESTED_HIV), Dictionary.getConcept(Metadata.Concept.YES_CIEL));
    }

    /**
	 * Number of individuals tested as MARPS
	 * @return CohortDefiniton
	 */
	public CohortDefinition individualsCounseledAndTestedAsMarps() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals tested as MARPS");
        cd.addSearch("testedAsMarps", ReportUtils.map(testedAsMarps(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedAsMarps AND counseledAsIndividuals");
        return cd;
	}

    public CohortDefinition individualsCounseledAndTestedAsSpecial() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals tested as Special Category");
        cd.addSearch("testedAsSpecialCategories", ReportUtils.map(clientsCategorisedAsSpecialCategories(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedAsSpecialCategories AND counseledAsIndividuals");
        return cd;
    }

    /**
     * Number with Facility Based Entry Point and tested for HIV
     * @return CohortDefiniton
     */
    public CohortDefinition individualsAtWardEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("WardBasedEntry", ReportUtils.map(clientsWithWardasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WardBasedEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsAtWardEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("WardBasedEntry", ReportUtils.map(clientsWithWardasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WardBasedEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }

    public CohortDefinition individualsAWardEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("WardBasedEntry", ReportUtils.map(clientsWithWardasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WardBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithOPDEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("OPDBasedEntry", ReportUtils.map(clientsWithOPDasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OPDBasedEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithOPDEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("OPDBasedEntry", ReportUtils.map(clientsWithOPDasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OPDBasedEntry AND testedPositive AND firstTimeTesting ");
        return cd;
    }

    public CohortDefinition individualsWithOPDEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("OPDBasedEntry", ReportUtils.map(clientsWithOPDasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OPDBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithART_CLINICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("ARTBasedEntryPoint", ReportUtils.map(clientsWithARTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ARTBasedEntryPoint AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithART_CLINICEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("ARTBasedEntryPoint", ReportUtils.map(clientsWithARTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ARTBasedEntryPoint AND testedPositive AND firstTimeTesting ");
        return cd;
    }
    public CohortDefinition individualsWithART_CLINICEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Facility Based HCT Entry point and Tested for HIV");
        cd.addSearch("OPDBasedEntry", ReportUtils.map(clientsWithARTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OPDBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithTB_CLINICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with TB Based HCT Entry point and Tested for HIV");
        cd.addSearch("TBBasedEntry", ReportUtils.map(clientsWithTB_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TBBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithTB_CLINICEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with TB Based HCT Entry point and Tested Positive");
        cd.addSearch("TBBasedEntry", ReportUtils.map(clientsWithTB_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TBBasedEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithTB_CLINICEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with TB Based HCT Entry point and Tested and are linked to Care");
        cd.addSearch("TBBasedEntry", ReportUtils.map(clientsWithTB_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TBBasedEntry AND linkedtoCare");
        return cd;
    }
    public CohortDefinition individualsWithNUTRITION_UNIT_CLINICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Nutrition Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("NUTRITIONUNITBasedEntry", ReportUtils.map(clientsWithNUTRITION_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("NUTRITIONUNITBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithNUTRITION_UNIT_CLINICEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Nutrition Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("NUTRITIONUNITBasedEntry", ReportUtils.map(clientsWithNUTRITION_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("NUTRITIONUNITBasedEntry AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithNUTRITION_UNIT_CLINICEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Nutrition Unit Based HCT Entry point and are linked to care");
        cd.addSearch("NUTRITIONUNITBasedEntry", ReportUtils.map(clientsWithNUTRITION_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("NUTRITIONUNITBasedEntry AND linkedtoCare");
        return cd;
    }
    public CohortDefinition individualsWithSTI_UNIT_CLINICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with STI Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("STIUNITBasedEntry", ReportUtils.map(clientsWithSTI_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("STIUNITBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithSTI_UNIT_CLINICEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with STI Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("STIUNITBasedEntry", ReportUtils.map(clientsWithSTI_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("STIUNITBasedEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithSTI_UNIT_CLINICEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with STI Unit Based HCT Entry point and are linked to care");
        cd.addSearch("STIUNITBasedEntry", ReportUtils.map(clientsWithSTI_UNIT_CLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("STIUNITBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithYCC_CLINICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with YCC Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("YCCBasedEntry", ReportUtils.map(clientsWithYCCCLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("YCCBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithYCC_CLINICEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with YCC Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("YCCBasedEntry", ReportUtils.map(clientsWithYCCCLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("YCCBasedEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithYCC_CLINICEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with YCC Unit Based HCT Entry point and are linked to care");
        cd.addSearch("YCCBasedEntry", ReportUtils.map(clientsWithYCCCLINICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("YCCBasedEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithANCEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with ANC Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("ANCBASEDEntry", ReportUtils.map(clientsWithANCEntryPoint(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ANCBASEDEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithANCEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with ANC Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("ANCBASEDEntry", ReportUtils.map(clientsWithANCEntryPoint(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ANCBASEDEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithANCEntryandLinkedToCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with ANC Unit Based HCT Entry point and are linked to care");
        cd.addSearch("ANCBASEDEntry", ReportUtils.map(clientsWithANCEntryPoint(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("ANCBASEDEntry AND linkedtoCare");
        return cd;
    }
    public CohortDefinition individualsWithMaternityEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Maternity Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("MATERNITYBASEDEntry", ReportUtils.map(clientsWithMaternityDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("MATERNITYBASEDEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithMaternityEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Maternity Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("MATERNITYBASEDEntry", ReportUtils.map(clientsWithMaternityDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("MATERNITYBASEDEntry AND testedPositive AND firstTimeTesting ");
        return cd;
    }
    public CohortDefinition individualsWithMaternityEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Maternity Unit Based HCT Entry point and are linked to care");
        cd.addSearch("MATERNITYBASEDEntry", ReportUtils.map(clientsWithMaternityDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("MATERNITYBASEDEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithPNCEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with PNC Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("PNCBASEDEntry", ReportUtils.map(clientsWithPNCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PNCBASEDEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithPNCEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with PNC Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("PNCBASEDEntry", ReportUtils.map(clientsWithPNCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PNCBASEDEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithPNCEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with PNC Unit Based HCT Entry point and are linked to care");
        cd.addSearch("PNCBASEDEntry", ReportUtils.map(clientsWithPNCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PNCBASEDEntry AND linkedtoCare");
        return cd;
    }
    public CohortDefinition individualsWithFamilyPlanningEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Family Planning Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("FamilyPlanningBASEDEntry", ReportUtils.map(clientsWithFamilyPlanningDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FamilyPlanningBASEDEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithFamilyPlanningEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Family Planning Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("FamilyPlanningBASEDEntry", ReportUtils.map(clientsWithFamilyPlanningDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FamilyPlanningBASEDEntry AND testedPositive AND firstTimeTesting ");
        return cd;
    }
    public CohortDefinition individualsWithFamilyPlanningEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Family Planning Unit Based HCT Entry point and are linked to care");
        cd.addSearch("FamilyPlanningBASEDEntry", ReportUtils.map(clientsWithFamilyPlanningDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FamilyPlanningBASEDEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithSMCEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with SMC Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("SMCBASEDEntry", ReportUtils.map(clientsWithSMCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("SMCBASEDEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithSMCEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with SMC Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("SMCBASEDEntry", ReportUtils.map(clientsWithSMCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("SMCBASEDEntry AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithSMCEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with SMC Unit Based HCT Entry point and are linked to care");
        cd.addSearch("SMCBASEDEntry", ReportUtils.map(clientsWithSMCDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("SMCBASEDEntry AND linkedtoCare");
        return cd;
    }
    public CohortDefinition individualsWithEIDEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with EID Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("EIDBASEDEntry", ReportUtils.map(clientsWithEIDDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("EIDBASEDEntry AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithEIDEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with EID Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("EIDBASEDEntry", ReportUtils.map(clientsWithEIDDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("EIDBASEDEntry AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithEIDEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with EID Unit Based HCT Entry point and are linked to care");
        cd.addSearch("EIDBASEDEntry", ReportUtils.map(clientsWithEIDDepartmentasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("EIDBASEDEntry AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithOtherFacilityPointEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Facility Points Unit Based HCT Entry point and Tested for HIV");
        cd.addSearch("OtherFacilityPoints", ReportUtils.map(clientsWithOtherFacilityPointsasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherFacilityPoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithOtherFacilityPointEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Facility Points Unit Based HCT Entry point and Tested Positive");
        cd.addSearch("OtherFacilityPoints", ReportUtils.map(clientsWithOtherFacilityPointsasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherFacilityPoints AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithOtherFacilityPointEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Facility Points Unit Based HCT Entry point and are linked to care");
        cd.addSearch("OtherFacilityPoints", ReportUtils.map(clientsWithOtherFacilityPointsasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherFacilityPoints AND linkedtoCare");
        return cd;
    }

    /**
     * Community Testing Points
     */
    public CohortDefinition individualsWithWorkPlaceEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Work Place  HCT Entry point and Tested for HIV");
        cd.addSearch("WorkPlacePoints", ReportUtils.map(clientsWithWorkPlaceasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedForHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WorkPlacePoints AND testedForHIV");
        return cd;
    }

    public CohortDefinition individualsWithWorkPlaceEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Work Place  HCT Entry point and Tested Positive");
        cd.addSearch("WorkPlacePoints", ReportUtils.map(clientsWithWorkPlaceasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WorkPlacePoints AND testedPositive AND  firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithWorkPlaceEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Work Place  HCT Entry point and are linked to care");
        cd.addSearch("WorkPlacePoints", ReportUtils.map(clientsWithWorkPlaceasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("WorkPlacePoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithHBCTEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HBCT HCT Entry point and Tested for HIV");
        cd.addSearch("HBCTPoints", ReportUtils.map(clientsWithHBCTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HBCTPoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithHBCTEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HBCT HCT Entry point and Tested Positive");
        cd.addSearch("HBCTPoints", ReportUtils.map(clientsWithHBCTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HBCTPoints AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithHBCTEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HBCT HCT Entry point and are linked to care");
        cd.addSearch("HBCTPoints", ReportUtils.map(clientsWithHBCTasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HBCTPoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithDICEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with DIC HCT Entry point and Tested for HIV");
        cd.addSearch("DICPoints", ReportUtils.map(clientsWithDICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("DICPoints AND testedforHIV");
        return cd;
    }

    public CohortDefinition individualsWithDICEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with DIC HCT Entry point and Tested Positive");
        cd.addSearch("DICPoints", ReportUtils.map(clientsWithDICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("DICPoints AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithDICEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with DIC HCT Entry point and are linked to care");
        cd.addSearch("DICPoints", ReportUtils.map(clientsWithDICasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("DICPoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithHotSpotEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HotSpot HCT Entry point and Tested for HIV");
        cd.addSearch("HotSpotPoints", ReportUtils.map(clientsWithHotSpotasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HotSpotPoints AND testedforHIV");
        return cd;
    }

    public CohortDefinition individualsWithHotSpotEntryandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HotSpot HCT Entry point and Tested Positive");
        cd.addSearch("HotSpotPoints", ReportUtils.map(clientsWithHotSpotasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HotSpotPoints AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithHotSpotEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with HotSpot HCT Entry point and are linked to care");
        cd.addSearch("HotSpotPoints", ReportUtils.map(clientsWithHotSpotasEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("HotSpotPoints AND linkedtoCare");
        return cd;
    }

    public CohortDefinition individualsWithOtherCommunityTestingPOintsEntryandTestedForHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested for HIV");
        cd.addSearch("OtherCommunityTestingPoints", ReportUtils.map(clientsWithOtherCommunityTestingAsEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherCommunityTestingPoints AND testedforHIV");
        return cd;
    }

    public CohortDefinition individualsWithOtherCommunityTestingPOintsEntryandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested Positive");
        cd.addSearch("OtherCommunityTestingPoints", ReportUtils.map(clientsWithOtherCommunityTestingAsEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherCommunityTestingPoints AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithOtherCommunityTestingPOintsEntryandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing HCT Entry point and are linked to care");
        cd.addSearch("OtherCommunityTestingPoints", ReportUtils.map(clientsWithOtherCommunityTestingAsEntryinHTC(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("OtherCommunityTestingPoints AND linkedtoCare");
        return cd;
    }
    /**
     * PITC Testing Appraoches
     */
    public CohortDefinition individualsWithHealthFacilityTestingAppraochandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested for HIV");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND testedforHIV AND FacilityBasedApproach ");
        return cd;
    }

    public CohortDefinition individualsWithHealthFacilityTestingAppraochandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested Positive");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firstTimeTesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND FacilityBasedApproach AND testedPositive AND firstTimeTesting");
        return cd;
    }
    public CohortDefinition individualsWithHealthFacilityTestingAppraochandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing HCT Entry point and are linked to care");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND FacilityBasedApproach AND linkedtoCare ");
        return cd;
    }
    public CohortDefinition individualsWithCommunityPITCApproachandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested for HIV");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND testedforHIV AND CommunityBasedApproach ");
        return cd;
    }

    public CohortDefinition individualsWithCommunityPITCApproachandPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested Positive");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND CommunityBasedApproach AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithCommunityPITCApproachandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing HCT Entry point and are linked to care");
        cd.addSearch("PITCTestingAppraoch", ReportUtils.map(clientsWithPITCTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PITCTestingAppraoch AND CommunityBasedApproach AND linkedtoCare ");
        return cd;
    }

    /**
     * CICT  Testing Appraoches
     */
    public CohortDefinition individualsWithFacilityBasedCICTTestingAppraochandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested for HIV");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND testedforHIV AND FacilityBasedApproach ");
        return cd;
    }

    public CohortDefinition individualsWithFacilityBasedCICTTestingAppraochandPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested Positive");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND FacilityBasedApproach AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithFacilityBasedCICTTestingAppraochandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing HCT Entry point and are linked to care");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("FacilityBasedApproach", ReportUtils.map(clientsWithFaciltyBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND FacilityBasedApproach AND linkedtoCare ");
        return cd;
    }
    public CohortDefinition individualsWithCommunityCICTApproachandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested for HIV");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND testedforHIV AND CommunityBasedApproach ");
        return cd;
    }

    public CohortDefinition individualsWithCommunityCICTApproachandPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing Points HCT Entry point and Tested Positive");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND CommunityBasedApproach AND testedPositive");
        return cd;
    }
    public CohortDefinition individualsWithCommunityCICTApproachandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals with Other Community Testing HCT Entry point and are linked to care");
        cd.addSearch("CICTTestingApproach", ReportUtils.map(clientsWithCICTTestingApproach(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("CommunityBasedApproach", ReportUtils.map(clientsWithCommunityBasedDeliveryModel(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("CICTTestingApproach AND CommunityBasedApproach AND linkedtoCare ");
        return cd;
    }

    /**
     * Special Categories
     */
    public CohortDefinition individualsCategorisedAsPrisonersandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Prisoners and Tested for HIV");
        cd.addSearch("Prisoners", ReportUtils.map(clientsCategorisedAsPrisoners(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Prisoners AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsPrisonersandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Prisoners and Tested Positive");
        cd.addSearch("Prisoners", ReportUtils.map(clientsCategorisedAsPrisoners(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Prisoners  AND testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsPrisonersandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Prisoners and are linked to care");
        cd.addSearch("Prisoners", ReportUtils.map(clientsCategorisedAsPrisoners(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Prisoners AND linkedtoCare ");
        return cd;
    }

     //PWIDs
     public CohortDefinition individualsCategorisedAsPWIDsandTestedforHIV() {
         CompositionCohortDefinition cd = new CompositionCohortDefinition();
         cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
         cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
         cd.setName("Number of individuals Categorised as PWIDs and Tested for HIV");
         cd.addSearch("PWIDs", ReportUtils.map(clientsCategorisedAsPWIDS(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
         cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
         cd.setCompositionString("PWIDs AND testedforHIV ");
         return cd;
     }

    public CohortDefinition individualsCategorisedAsPWIDsandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PWIDs and Tested Positive");
        cd.addSearch("PWIDs", ReportUtils.map(clientsCategorisedAsPWIDS(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PWIDs AND  testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsPWIDsandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PWIDs and are linked to care");
        cd.addSearch("PWIDs", ReportUtils.map(clientsCategorisedAsPWIDS(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PWIDs AND linkedtoCare ");
        return cd;
    }

    //Uniformed Men
    public CohortDefinition individualsCategorisedAsUniformedMenandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Uniformed Men and Tested for HIV");
        cd.addSearch("UniformedMen", ReportUtils.map(clientsCategorisedAsUniformedMen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("UniformedMen AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsUniformedMenandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Uniformed Men and Tested Positive");
        cd.addSearch("UniformedMen", ReportUtils.map(clientsCategorisedAsUniformedMen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("UniformedMen AND  testedPositive and firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsUniformedMenandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Uniformed Men and are linked to care");
        cd.addSearch("UniformedMen", ReportUtils.map(clientsCategorisedAsUniformedMen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("UniformedMen AND linkedtoCare ");
        return cd;
    }
    //Migrant Workers

    public CohortDefinition individualsCategorisedAsMigrantWorkersandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Migrant Workers and Tested for HIV");
        cd.addSearch("MigrantWorkers", ReportUtils.map(clientsCategorisedAsMigrantWorkers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));

        cd.setCompositionString("MigrantWorkers AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsMigrantWorkersandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Migrant Workers and Tested Positive");
        cd.addSearch("MigrantWorkers", ReportUtils.map(clientsCategorisedAsMigrantWorkers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("MigrantWorkers AND  testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsMigrantWorkersandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Migrant Workers and are linked to care");
        cd.addSearch("MigrantWorkers", ReportUtils.map(clientsCategorisedAsMigrantWorkers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("MigrantWorkers AND linkedtoCare ");
        return cd;
    }
    //Trucker Drivers
    public CohortDefinition individualsCategorisedAsTruckerDriversandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Trucker Drivers and Tested for HIV");
        cd.addSearch("TruckerDrivers", ReportUtils.map(clientsCategorisedAsTruckerDrivers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TruckerDrivers AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsTruckerDriversandNewlyPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Trucker Drivers and Tested Positive");
        cd.addSearch("TruckerDrivers", ReportUtils.map(clientsCategorisedAsTruckerDrivers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TruckerDrivers AND  testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsTruckerDriversandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Trucker Drivers and are linked to care");
        cd.addSearch("TruckerDrivers", ReportUtils.map(clientsCategorisedAsTruckerDrivers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("TruckerDrivers AND linkedtoCare ");
        return cd;
    }
    //Fisher Folks
    public CohortDefinition individualsCategorisedAsFisherFolksandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Fisher Folks and Tested for HIV");
        cd.addSearch("FisherFolks", ReportUtils.map(clientsCategorisedAsFisherFolks(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FisherFolks AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsFisherFolksandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Fisher Folks and Tested Positive");
        cd.addSearch("FisherFolks", ReportUtils.map(clientsCategorisedAsFisherFolks(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FisherFolks AND  testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsFisherFolksandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Fisher Folks and are linked to care");
        cd.addSearch("FisherFolks", ReportUtils.map(clientsCategorisedAsFisherFolks(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("FisherFolks AND linkedtoCare ");
        return cd;
    }

    //Refugees
    public CohortDefinition individualsCategorisedAsRefugeesandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Refugees and Tested for HIV");
        cd.addSearch("Refugees", ReportUtils.map(clientsCategorisedAsRefugees(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Refugees AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsRefugeesandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Refugees and Tested Positive");
        cd.addSearch("Refugees", ReportUtils.map(clientsCategorisedAsRefugees(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("firsttimetesting", ReportUtils.map(individualsTestingFortheFirstTime(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Refugees AND  testedPositive AND firsttimetesting");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsRefugeesandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Refugees and are linked to care");
        cd.addSearch("Refugees", ReportUtils.map(clientsCategorisedAsRefugees(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Refugees AND linkedtoCare ");
        return cd;
    }

    //Pregnant Women
    public CohortDefinition individualsCategorisedAsPregnantWomenandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PregnantWomen and Tested for HIV");
        cd.addSearch("PregnantWomen", ReportUtils.map(clientsCategorisedAsPregnantWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PregnantWomen AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsPregnantWomenandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PregnantWomen and Tested Positive");
        cd.addSearch("PregnantWomen", ReportUtils.map(clientsCategorisedAsPregnantWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PregnantWomen AND  testedPositive");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsPregnantWomenandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PregnantWomen and are linked to care");
        cd.addSearch("PregnantWomen", ReportUtils.map(clientsCategorisedAsPregnantWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PregnantWomen AND linkedtoCare ");
        return cd;
    }
    //Breast Feeding Women
    public CohortDefinition individualsCategorisedAsBreastFeedingWomenandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as BreastFeedingWomen and Tested for HIV");
        cd.addSearch("BreastFeedingWomen", ReportUtils.map(clientsCategorisedAsBreastFeedingWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("BreastFeedingWomen AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsBreastFeedingWomenandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as BreastFeedingWomen and Tested Positive");
        cd.addSearch("BreastFeedingWomen", ReportUtils.map(clientsCategorisedAsBreastFeedingWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("BreastFeedingWomen AND  testedPositive");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsBreastFeedingWomenandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as BreastFeedingWomen and are linked to care");
        cd.addSearch("BreastFeedingWomen", ReportUtils.map(clientsCategorisedAsBreastFeedingWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("BreastFeedingWomen AND linkedtoCare ");
        return cd;
    }
   //AGYW
   public CohortDefinition individualsCategorisedAsAGYWandTestedforHIV() {
       CompositionCohortDefinition cd = new CompositionCohortDefinition();
       cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
       cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
       cd.setName("Number of individuals Categorised as AGYW and Tested for HIV");
       cd.addSearch("AGYW", ReportUtils.map(clientsCategorisedAsAGYW(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
       cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
       cd.setCompositionString("AGYW AND testedforHIV ");
       return cd;
   }

    public CohortDefinition individualsCategorisedAsAGYWandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as AGYW and Tested Positive");
        cd.addSearch("AGYW", ReportUtils.map(clientsCategorisedAsAGYW(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("AGYW AND  testedPositive");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsAGYWandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as AGYW and are linked to care");
        cd.addSearch("AGYW", ReportUtils.map(clientsCategorisedAsAGYW(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("AGYW AND linkedtoCare ");
        return cd;
    }

    //PWDs

    public CohortDefinition individualsCategorisedAsPWDsandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PWDs and Tested for HIV");
        cd.addSearch("PWDs", ReportUtils.map(clientsCategorisedAsPWDs(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PWDs AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsPWDsandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PWDs and Tested Positive");
        cd.addSearch("PWDs", ReportUtils.map(clientsCategorisedAsPWDs(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PWDs AND  testedPositive");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsPWDsandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as PWDs and are linked to care");
        cd.addSearch("PWDs", ReportUtils.map(clientsCategorisedAsPWDs(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("PWDs AND linkedtoCare ");
        return cd;
    }
    //Other categories
    public CohortDefinition individualsCategorisedAsOthersandTestedforHIV() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Others and Tested for HIV");
        cd.addSearch("Others", ReportUtils.map(clientsCategorisedAsOthers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedforHIV", ReportUtils.map(individualsTested(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Others AND testedforHIV ");
        return cd;
    }

    public CohortDefinition individualsCategorisedAsOthersandTestedPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Others and Tested Positive");
        cd.addSearch("Others", ReportUtils.map(clientsCategorisedAsOthers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Others AND  testedPositive");
        return cd;
    }
    public CohortDefinition individualsCategorisedAsOthersandLinkedtoCare() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Number of individuals Categorised as Others and are linked to care");
        cd.addSearch("Others", ReportUtils.map(clientsCategorisedAsOthers(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("linkedtoCare", ReportUtils.map(clientsLinkedToCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("Others AND linkedtoCare ");
        return cd;
    }

    /**
	 * Tested as MARPS
	 * @return
	 */
	private CohortDefinition testedAsMarps() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.HCT_ENTRY_POINT), Dictionary.getConcept(Metadata.Concept.MARPS));
	}

	/**
	 * Linked to care
	 * @return
	 */
	public CohortDefinition clientsLinkedToCare() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.LINKED_TO_CARE), Dictionary.getConcept(Metadata.Concept.YES_CIEL));
	}

	/**
	 * Positive Individuals tested at an early stage
	 * @return CohortDefinition
	 */
	public CohortDefinition hivPositiveIndividualsTestedAtAnEarlyStage() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV Positive Individuals tested at an early stage");
        cd.addSearch("testedAtAnEarlyStage", ReportUtils.map(testedAtEarlyStage(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("testedHIVPositive", ReportUtils.map(testedHivPositive(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("counseledAsIndividuals", ReportUtils.map(counseledAsIndividuals(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("testedHIVPositive AND counseledAsIndividuals AND testedAtAnEarlyStage");
        return cd;
	}

	/**
	 * Tested at an early stage (CD4>500μ)
	 * @return CohortDefinition
	 */
	private CohortDefinition testedAtEarlyStage() {
    	return definitionLibrary.hasNumericObs(Dictionary.getConcept(Metadata.Concept.CD4_COUNT),RangeComparator.GREATER_THAN,(double) 500);
	}
	
	/**
	 * Couples with concordant Positive results
	 * @return CohortDefinition
	 */
//	public CohortDefinition couplesWithConcordantPostiveResults() {
//        CompositionCohortDefinition cd = new CompositionCohortDefinition();
//        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
//        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
//        cd.setName("Couples with concordant Positive results");
//        cd.addSearch("partnerTestedHivPositive", ReportUtils.map(haveHivTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
//        cd.addSearch("concordantPositive", ReportUtils.map(couplesWithConcordantPositiveResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
//        cd.setCompositionString("concordantPositive AND partnerTestedHivPositive");
//        return cd;
//	}

	/**
	 * Partner Tested HIV Positive
	 * @return
	 */
	public CohortDefinition partnerTestedHivPositive() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.PARTNER_HIV_TEST_RESULT), Dictionary.getConcept(Metadata.Concept.HIV_POSITIVE));
	}

	/**
	 * Partner Tested HIV Negative
	 * @return
	 */
	private CohortDefinition partnerTestedHiVNegative() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.PARTNER_HIV_TEST_RESULT), Dictionary.getConcept(Metadata.Concept.HIV_NEGATIVE));
	}
	
	/**
	 * Couples with discordant results
	 * @return
	 */

    public CohortDefinition couplesWithDiscordantResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUPLE_RESULTS), Dictionary.getConcept(Metadata.Concept.DISCORDANT_COUPLE));
    }

    public CohortDefinition couplesWithConcordantPositiveResults() {
        return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.COUPLE_RESULTS), Dictionary.getConcept(Metadata.Concept.CONCORDANT_POSITIVE));
    }
	//End HCT Section    

	/**
	 * Total outpatient attendance
	 * @return
	 */	
	public CohortDefinition totalOutPatientAttendance() {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(Arrays.asList(CoreUtils.getEncounterType(Metadata.EncounterType.OPD_ENCOUNTER)));
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        return cd;
	}

	/**
	 * New outpatient attendance
	 * @return
	 */	
	public CohortDefinition newOutPatientAttendance() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("OutPatient Attendance");
        cd.addSearch("outPatientEncounters", ReportUtils.map(totalOutPatientAttendance(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));        
        cd.addSearch("newEncounters", ReportUtils.map(newEncounters(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("outPatientEncounters AND newEncounters");
        return cd;
	}

	/**
	 * Repeat outpatient attendance
	 * @return
	 */	
	public CohortDefinition repeatOutPatientAttendance() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("OutPatient Attendance");
        cd.addSearch("outPatientEncounters", ReportUtils.map(totalOutPatientAttendance(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));        
        cd.addSearch("repeatEncounters", ReportUtils.map(repeatEncounters(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("outPatientEncounters AND repeatEncounters");
        return cd;
	}

	/**
	 * Repeat Encounters
	 * @return
	 */	
	public CohortDefinition repeatEncounters() {
		return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TYPE_OF_PATIENT), Dictionary.getConcept(Metadata.Concept.REPEAT_ENCOUNTER));
	}

	/**
	 * New Encounters
	 * @return
	 */	
	public CohortDefinition newEncounters() {
		return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TYPE_OF_PATIENT), Dictionary.getConcept(Metadata.Concept.NEW_ENCOUNTER));
	}

	/**
	 * Referrals To Unit
	 * @return
	 */	
	public CohortDefinition referralsToUnit() {
		return definitionLibrary.hasTextObs(Dictionary.getConcept(Metadata.Concept.TRANSFER_IN_NUMBER));
	}

	/**
	 * Referrals From Unit
	 * @return
	 */	
	public CohortDefinition referralsFromUnit() {
		return definitionLibrary.hasTextObs(Dictionary.getConcept(Metadata.Concept.REFERRAL_NUMBER));
	}
	
	/**
	 * Referrals To OPD Unit
	 * @return
	 */	
	public CohortDefinition referralsToOPDUnit() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Referrals To OPD Unit");
        cd.addSearch("outPatientEncounters", ReportUtils.map(totalOutPatientAttendance(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));        
        cd.addSearch("referralsToUnit", ReportUtils.map(referralsToUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("outPatientEncounters AND referralsToUnit");
        return cd;
	}

	/**
	 * Referrals From OPD Unit
	 * @return
	 */	
	public CohortDefinition referralsFromOPDUnit() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Referrals From OPD Unit");
        cd.addSearch("outPatientEncounters", ReportUtils.map(totalOutPatientAttendance(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));        
        cd.addSearch("referralsFromUnit", ReportUtils.map(referralsFromUnit(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("outPatientEncounters AND referralsFromUnit");
        return cd;
	}

	/**
	 * Total OPD Malaria Diagnosis
	 * 
	 * @return
	 */
	public CohortDefinition totalOpdMalariaDiagnoses() {
		return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConceptList(Metadata.Concept.CLINICAL_MALARIA + "," + Metadata.Concept.CONFIRMED_MALARIA + ","
		            + Metadata.Concept.CIEL_MALARIA + "," + Metadata.Concept.MALARIA_IN_PREGNANCY));
	}
	
	/**
	 * Total Microscopic & RDT Malaria Tests Done
	 * @return
	 */		
	public CohortDefinition microscopicAndRdtTestsDone() {
		return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TYPE_OF_MALARIA_TEST),Dictionary.getConceptList(Metadata.Concept.MALARIAL_SMEAR + ","  + Metadata.Concept.RAPID_TEST_FOR_MALARIA));
	}

	/**
	 * Total Positive Malaria Tests Done
	 * @return
	 */		
	public CohortDefinition positiveMalariaTestResults() {
		return definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.MALARIA_TEST_RESULT),Dictionary.getConcept(Metadata.Concept.POSITIVE));
	}		
	
	/**
	 * Total Confirmed OPD Malaria Diagnosis
	 * @return
	 */		
	public CohortDefinition totalConfirmedOpdMalariaDiagnoses() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Total Confirmed OPD Malaria Diagnosis");
        cd.addSearch("outPatientEncounters", ReportUtils.map(totalOutPatientAttendance(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));        
        cd.addSearch("microscopicAndRdtTestsDone", ReportUtils.map(microscopicAndRdtTestsDone(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("positiveMalariaTestResults", ReportUtils.map(positiveMalariaTestResults(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("outPatientEncounters AND microscopicAndRdtTestsDone AND positiveMalariaTestResults");
        return cd;
	}		

	 /** Patients With BMI count Between @minValue and @maxValue 
	  * 
	  * @return CohortDefinition
	  */
	 public CohortDefinition bmiCount(Double minValue, Double maxValue) {
			return definitionLibrary.hasNumericObs(Dictionary.getConcept(Metadata.Concept.BMI), RangeComparator.GREATER_EQUAL, minValue, RangeComparator.LESS_EQUAL, maxValue);
	 }
	 	
    /**
     * Live Births 
     * @return Cohort Definition
     */
	public CohortDefinition liveBirths() {
		return definitionLibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"),Dictionary.getConceptList("eb7041a0-02e6-4e9a-9b96-ff65dd09a416,23ac7575-f0ea-49a5-855e-b3348ad1da01"));
	}    
    
    /**
     * Live Birth Deliveries to HIV+ women
     * @return CohortDefinition
     */
    public CohortDefinition liveBirthDeliveriesToHIVPositiveWomen() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("HIV+ Women Deliveries");
        cd.addSearch("hivPositive", ReportUtils.map(hivPositiveWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("deliveries", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.PREGNANCY_OUTCOME)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("liveBirths", ReportUtils.map(liveBirths(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("hivPositive AND deliveries AND liveBirths");
        return cd;
    }

    /**
     * No. of mothers who initiated breastfeeding within the 1st hour after delivery - Total
     * @return CohortDefinition
     */
    public CohortDefinition initiatedBreastfeedingWithinFirstHourAfterDelivery() {
        return definitionLibrary.hasObs(Dictionary.getConcept("a4063d62-a936-4a26-9c1c-a0fb279a71b1"),Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"));
    }

    /**
     * No. of mothers who initiated breastfeeding within the 1st hour after delivery - HIV+
     * @return CohortDefinition
     */
    public CohortDefinition initiatedBreastfeedingWithinFirstHourAfterDeliveryAndHIVPositive() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setName("Initiated breastfeeding within 1 hour after delivery and HIV+");
        cd.addSearch("hivPositive", ReportUtils.map(hivPositiveWomen(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("initiatedBreastFeedingWithin1HourDelivery", ReportUtils.map(initiatedBreastfeedingWithinFirstHourAfterDelivery(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
        cd.setCompositionString("hivPositive AND initiatedBreastFeedingWithin1HourDelivery");
        return cd;
    }

    /**
     * Babies born with low birth weight
     * @return CohortDefinition
     */
	public CohortDefinition babiesBornWithLowBirthWeight() {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Babies born with low birth weight");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(Dictionary.getConcept("dcce847a-30ab-102d-86b0-7a5022ba4115"));
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setOperator1(RangeComparator.LESS_THAN);
        cd.setValue1(2.5);
        return cd;
	}
        
    /**
     * Maternal Deaths
     * @return CohortDefinition
     */
    public CohortDefinition maternalDeaths() {
        return definitionLibrary.hasObs(Dictionary.getConcept("e87431db-b49e-4ab6-93ee-a3bd6c616a94"),Dictionary.getConcept("17fcfd67-a1a2-4361-9915-ad4e81a7a61d"));
    }
        
	/**
	 * Number of HIV+ infants from EID Enrolled in care
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition hivPositiveInfantsFromEidEnrolledInCare() {
		CompositionCohortDefinition cd = new CompositionCohortDefinition();
		cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
		cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
		cd.setName("Number of HIV+ infants from EID enrolled in care");
		cd.addSearch("hivPositiveInfantsFromEid",
		    ReportUtils.map(hivPositiveInfantsFromEid(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.addSearch("infantsFromEidEnrolledInCare",
		    ReportUtils.map(infantsFromEidEnrolledInCare(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.setCompositionString("hivPositiveInfantsFromEid AND infantsFromEidEnrolledInCare");
		return cd;
	}
	
	/**
	 * Number of infants from EID Enrolled in care
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition infantsFromEidEnrolledInCare() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.ENROLLED_IN_HIV_CARE_PROGRAM),
		    Dictionary.getConcept(Metadata.Concept.YES_CIEL));
	}
	
	/**
	 * Number of HIV+ infants from EID
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition hivPositiveInfantsFromEid() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.FINAL_EID_PCR_TEST_RESULT),
		    Dictionary.getConcept(Metadata.Concept.POSITIVE));
	}
	
	/**
	 * Number of DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition dnaPcrResultsReturnedFromTheLab() {
		CompositionCohortDefinition cd = new CompositionCohortDefinition();
		cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
		cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
		cd.setName("Number of DNA PCR results returned from the lab");
		cd.addSearch("firstDnaPCRResultsReturnedFromTheLab",
		    ReportUtils.map(firstDnaPCRResultsReturnedFromTheLab(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.addSearch("secondDnaPCRResultsReturnedFromTheLab",
		    ReportUtils.map(secondDnaPCRResultsReturnedFromTheLab(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.setCompositionString("firstDnaPCRResultsReturnedFromTheLab AND secondDnaPCRResultsReturnedFromTheLab");
		return cd;
	}
	
	/**
	 * Number of DNA PCR results returned from the lab - given to care giver
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition dnaPcrResultsReturnedFromTheLabGivenToCareGiver() {
		CompositionCohortDefinition cd = new CompositionCohortDefinition();
		cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
		cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
		cd.setName("Number of DNA PCR results returned from the lab - given to care giver");
		cd.addSearch("firstDnaPCRResultsReturnedFromTheLabGivenToCareGiver", ReportUtils.map(
		    firstDnaPCRResultsReturnedFromTheLabGivenToCareGiver(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.addSearch("secondDnaPCRResultsReturnedFromTheLabGivenToCareGiver", ReportUtils.map(
		    secondDnaPCRResultsReturnedFromTheLabGivenToCareGiver(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
		cd.setCompositionString(
		    "firstDnaPCRResultsReturnedFromTheLabGivenToCareGiver AND secondDnaPCRResultsReturnedFromTheLabGivenToCareGiver");
		return cd;
	}
	
	/**
	 * Number of 1st DNA PCR results returned from the lab given to care giver
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition firstDnaPCRResultsReturnedFromTheLabGivenToCareGiver() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.DATE_FIRST_EID_PCR_TEST_RESULT_GIVEN_TO_CARE_PROVIDER));
	}
	
	/**
	 * Number of 2nd DNA PCR results returned from the lab given to care giver
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition secondDnaPCRResultsReturnedFromTheLabGivenToCareGiver() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.DATE_SECOND_EID_PCR_TEST_RESULT_GIVEN_TO_CARE_PROVIDER));
	}
	
	/**
	 * Number of 1st DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition firstDnaPCRResultsReturnedFromTheLab() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.FIRST_EID_PCR_TEST_RESULT));
	}
	
	/**
	 * Number of 2nd DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition secondDnaPCRResultsReturnedFromTheLab() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.SECOND_EID_PCR_TEST_RESULT));
	}
	
	/**
	 * Number of HIV+ 1st DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition firstDnaPCRResultsReturnedFromTheLabHivPositive() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.FIRST_EID_PCR_TEST_RESULT),
		    Dictionary.getConcept(Metadata.Concept.POSITIVE));
	}
	
	/**
	 * Number of HIV+ 2nd DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition secondDnaPCRResultsReturnedFromTheLabHivPositive() {
		return hasObsAndEncounter(Metadata.EncounterType.EID_ENCOUNTER_PAGE,
		    Dictionary.getConcept(Metadata.Concept.SECOND_EID_PCR_TEST_RESULT),
		    Dictionary.getConcept(Metadata.Concept.POSITIVE));
	}

	public CohortDefinition referralsToMaternityUnit() {
    	CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("maternityAdmissions", ReportUtils.map(maternityAdmissions(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("hasObs", ReportUtils.map(definitionLibrary.hasTextObs(Dictionary.getConcept(Metadata.Concept.REFERRAL_NUMBER), "REF"), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("maternityAdmissions AND hasObs");
        return cd;

	}

	public CohortDefinition maternityReferralsOut() {
    	CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("maternityAdmissions", ReportUtils.map(maternityAdmissions(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("hasObs", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("e87431db-b49e-4ab6-93ee-a3bd6c616a94"), Dictionary.getConcept("6e4f1db1-1534-43ca-b2a8-5c01bc62e7ef")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("maternityAdmissions AND hasObs");
        return cd;

	}

  /**
	 * Number of Tetanus Immunizations done
	 * 
	 * @return CohortIndicator
	 */
	public CohortDefinition tetanusImmunizationsDone(int doseNumber, Boolean pregnant ) {
		Concept doseNumberConcept = null;
		switch (doseNumber) {
			case 1:
				doseNumberConcept = Dictionary.getConcept(Metadata.Concept.FIRST_DOSE);
				break;
			case 2:
				doseNumberConcept = Dictionary.getConcept(Metadata.Concept.SECOND_DOSE);
				break;
			case 3:
				doseNumberConcept = Dictionary.getConcept(Metadata.Concept.THIRD_DOSE);
				break;
			case 4:
				doseNumberConcept = Dictionary.getConcept(Metadata.Concept.FOURTH_DOSE);
				break;
			case 5:
				doseNumberConcept = Dictionary.getConcept(Metadata.Concept.FIFTH_DOSE);
				break;
			
			default:
				break;
		}
		if (pregnant) {
			//Fetch a cohort of pregnant persons given the tetanus dose i.e those with ANC encounters
			CohortDefinition cd = null;
			if (doseNumberConcept != null) {
				cd = hasObsAndEncounter(Metadata.EncounterType.ANC_ENCOUNTER,
				    Dictionary.getConcept(Metadata.Concept.TETANUS_DOSE_GIVEN), doseNumberConcept);
			} else {
				cd = hasObsAndEncounter(Metadata.EncounterType.ANC_ENCOUNTER,
				    Dictionary.getConcept(Metadata.Concept.TETANUS_DOSE_GIVEN));
				
			}
			return cd;
			
		} else {
			//Fetch a cohort of non-pregnant persons given the tetanus dose i.e those without ANC encounters
			CompositionCohortDefinition cd = new CompositionCohortDefinition();
	        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
	        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
	        cd.addSearch("ancEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        if (doseNumberConcept != null) {
	        	cd.addSearch("hasObs", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TETANUS_DOSE_GIVEN), doseNumberConcept), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        } else {
	        	cd.addSearch("hasObs", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TETANUS_DOSE_GIVEN)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        }
	        cd.setCompositionString("hasObs AND NOT ancEncounter");

	        return cd;
		}
	} 
//coding for empty site type to facility
	public CohortDefinition emptySiteTypeToMappedToFaciity() {
		CalculationCohortDefinition cd = new CalculationCohortDefinition("emptySiteType", new EmptySiteType());
		cd.addParameter(new Parameter("onDate", "On Date", Date.class));
		return cd;
	}
	
	public CohortDefinition emptyProcedureMethodMappedToSurgical() {
		CalculationCohortDefinition cd = new CalculationCohortDefinition("emptyProcedureMethods", new EmptyProcedureMethods());
		cd.addParameter(new Parameter("onDate", "On Date", Date.class));
		return cd;
	}
	
	//combining all that constitute to facility site type
	public CohortDefinition facilitySiteType() {
		CompositionCohortDefinition cd = new CompositionCohortDefinition();
		cd.setName("Facility site type");
		cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("facilityObs", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("ac44b5f2-cf57-43ca-bea0-8b392fe21802"), Dictionary.getConcept("f2aa1852-fcfe-484b-a6ef-1613bd3a1a7f")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("emptyObs", ReportUtils.map(emptySiteTypeToMappedToFaciity(), "onDate=${onOrBefore}"));
        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("(facilityObs OR emptyObs) AND smcEncounter");
        return cd;
	}
	
	//combine all that constitutes the outreach site type
		public CohortDefinition outreachSiteType() {
			CompositionCohortDefinition cd = new CompositionCohortDefinition();
			cd.setName("Outreach site type");
			cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
	        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
	        cd.addSearch("outreach", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("ac44b5f2-cf57-43ca-bea0-8b392fe21802"), Dictionary.getConcept("03596df2-09bc-4d1f-94fd-484411ac9012"), Dictionary.getConcept("63e5387f-74f6-4a92-a71f-7b5dd3ed8432")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        cd.setCompositionString("outreach AND smcEncounter");
	        return cd;
		}
	//combining all that constitutes the surgical procedure methods
	public CohortDefinition surgicalProcedureMethod() {
		CompositionCohortDefinition cd = new CompositionCohortDefinition();
		Concept dorsal = Dictionary.getConcept("e63ac8e3-5027-43c3-9421-ce995ea039cf");
        Concept sleeve = Dictionary.getConcept("0ee1b2ae-2961-41d6-9fe0-7d9f876232ae");
		cd.setName("procedure method - surgical");
		cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("procedureMethod", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("bd66b11f-04d9-46ed-a367-2c27c15d5c71"), dorsal, sleeve), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("emptyProcedureObs", ReportUtils.map(emptyProcedureMethodMappedToSurgical(), "onDate=${onOrBefore}"));
        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("(procedureMethod OR emptyProcedureObs) AND smcEncounter");
        return cd;
	}
	
	//combining all that constitutes the surgical procedure methods
		public CohortDefinition deviceProcedureMethod() {
			CompositionCohortDefinition cd = new CompositionCohortDefinition();
			Concept forceps = Dictionary.getConcept("0308bd0a-0e28-4c62-acbd-5ea969c296db");
			cd.setName("procedure method - device");
			cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
	        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
	        cd.addSearch("device", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("bd66b11f-04d9-46ed-a367-2c27c15d5c71"), forceps), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
	        cd.setCompositionString("device AND smcEncounter");
	        return cd;
		}
		
     /**
     *@param answer
     * @return CohortDefinition
     */
    public CohortDefinition counseledTestedForHivResults(Concept answer) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Counseled and Tested for HIV and have results");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("counseled", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("cd8a8a72-4046-4595-94d0-52138534272a"), Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("results", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f"), answer), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("counseled AND results AND smcEncounter");
        return cd;
    }

    /**
     *
     *
     * @return CohortDefinition
     */
    public CohortDefinition counseledTestedForHiv() {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.setName("Counseled and Tested for HIV");
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.addSearch("counseled", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("cd8a8a72-4046-4595-94d0-52138534272a"), Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("tested", ReportUtils.map(definitionLibrary.hasObs(Dictionary.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f")), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("counseled AND tested AND smcEncounter");
        return cd;
    }

    /**
     * Number of clients circumcised who returned for a follow up within 6 weeks
     * @return CohortDefinition
     */
    public CohortDefinition clientsCircumcisedAndReturnedWithin6Weeks(Integer visit){
        CalculationCohortDefinition cd = new CalculationCohortDefinition("returned", new SmcReturnFollowUpCalculation());
        cd.setName("clients returned for visit");
        cd.addParameter(new Parameter("onDate", "End Date", Date.class ));
        cd.addCalculationParameter("visit", visit);
        return cd;
    }
    /**
     * 
     */
    public CohortDefinition clientsCircumcisedAndReturnedWithin6WeeksAndHaveSmcEncounter(int visit) {
    	CompositionCohortDefinition cd = new CompositionCohortDefinition();
    	cd.setName("Returned for visit and has SMC encounter within period");
    	cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        
        cd.addSearch("visit", ReportUtils.map(clientsCircumcisedAndReturnedWithin6Weeks(visit), "onDate=${onOrBefore}"));
        cd.addSearch("smcEncounter", ReportUtils.map(definitionLibrary.hasEncounter(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.SMC_ENCOUNTER)), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        cd.setCompositionString("visit AND smcEncounter");
    return cd;
    }


}
