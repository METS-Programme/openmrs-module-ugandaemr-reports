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
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

import static org.openmrs.module.ugandaemrreports.UgandaEMRReportUtil.map;
import static org.openmrs.module.ugandaemrreports.reporting.utils.EmrReportingUtils.cohortIndicator;

/**
 *
 */
@Component
public class Moh105IndicatorLibrary {

    String ANC_UUID = Metadata.EncounterType.ANC_ENCOUNTER;
    String PNC_UUID = Metadata.EncounterType.PNC_ENCOUNTER;
    String EID_UUID = Metadata.EncounterType.EID_ENCOUNTER_PAGE;
    String MATERNITY_UUID = Metadata.EncounterType.MATERNITY_ENCOUNTER;
    @Autowired
    private Moh105CohortLibrary cohortLibrary;

    @Autowired
    private CommonCohortDefinitionLibrary cclibrary;

    /**
     * Number of female patients with ANC 1st visit
     */
    public CohortIndicator ANCFirstContact(){
        return cohortIndicator("Patients who have ANC 1st Visit", map(cohortLibrary.femaleAndHasAncVisit(0.0, 1.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Number of female patients with ANC 4th visit
     */
    public CohortIndicator ANCFourthVisit(){
        return cohortIndicator("Patients who have ANC 4th Visit", map(cohortLibrary.femaleAndHasAncVisit(2.0, 4.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Number of female patients with ANC 4th visit and above
     */
    public CohortIndicator ANCVisitFourthPlus(){
        return cohortIndicator("Patients who have ANC 4th Visit and above", map(cohortLibrary.femaleAndHasAncVisit(4.0, 7.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator ANCEighthVisit(){
        return cohortIndicator("Patients who have ANC 4th Visit and above", map(cohortLibrary.femaleAndHasAncVisit(8.0, 9.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Total number of patients with ANC visits
     * @return CohortIndicator
     */
    public CohortIndicator totalANCVisits() {
        return cohortIndicator("Patients who have ANC Visits", map(cohortLibrary.femaleAndHasAncVisit(0.0, 9.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator testedForAnaemiaAndFirstANCVisit() {
        return cohortIndicator("Pregnant Women tested for Anaemia", map(cohortLibrary.testedForAneamiaAndANCVisit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator testedPositiveForAnaemiaAndFirstANCVisit() {
        return cohortIndicator("Pregnant Women tested for Anaemia", map(cohortLibrary.testedPositiveAneamiaAndANCVisit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomengivenFreeLLIN() {
        return cohortIndicator("Pregnant Women recieved free LLIN", map(cohortLibrary.recievedFreeLLNonANCVisit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator testedForAnaemiaat36Weeks() {
        return cohortIndicator("Pregnant Women recieved free LLIN", map(cohortLibrary.pregnantWomenTestedForAneamiaat36(36.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator testedPositiveForAnaemiaAfter36Weeks() {
        return cohortIndicator("Pregnant Women recieved free LLIN", map(cohortLibrary.pregnantWomenTestedPositiveForAneamiaat36(36.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator recievingIronANDFollicAcidAtFirstVisit() {
        return cohortIndicator("Pregnant Women Iron and Follic Acid on first visit", map(cohortLibrary.pregnantAndRecievedIronandFollicAcidGreaterthan30(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator recievingIronANDFollicAcidAt36Weeks() {
        return cohortIndicator("Pregnant Women Iron and Follic Acid after 36 weeks", map(cohortLibrary.pregnantAndRecievedIronandFollicAcidGreaterthan30After36Weeks(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator numberOfUltraSoundScan() {
        return cohortIndicator("US Done", map(cohortLibrary.numericObservations("fbea6522-78f5-4d3d-a695-aaedfef7a76a",0.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator numberOfUltraSoundScanbefore24weeks() {
        return cohortIndicator("US Done", map(cohortLibrary.numericObservations("fbea6522-78f5-4d3d-a695-aaedfef7a76a",0.0,24.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenRecievingMabendazole() {
        return cohortIndicator("Pregnant women recieving mabendazole ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept("9d6abbc4-707a-4ec7-a32a-4090b1c3af87"),Dictionary.getConcept("a7a9d632-b266-4085-9a5e-57fc8dd56f0c")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenRecievingMabendazoleAfter28weeks() {
        return cohortIndicator("Pregnant women recieving mabendazole after 24 weeks", map(cohortLibrary.pregnantAndRecievedMabendazoleAfter28Weeks(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenAlreadyonARTTreatmentBeforeFirstANCVisit() {
        return cohortIndicator("Pregnant women recieving ART Treatment before first ANC Visit ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept("a615f932-26ee-449c-8e20-e50a15232763"),Dictionary.getConcept("2aa7d442-6cbb-4609-9dd3-bc2ad6f05016")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator viralLoadSamplesCollectedDuringMonth() {
        return cohortIndicator("Viral Load Samples Collected during the month", map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept("0b434cfa-b11c-4d14-aaa2-9aed6ca2da88")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator viralLoadResultsReturnedDuringMonth() {
        return cohortIndicator("Viral Load Samples returned during the month", map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept("dca12261-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator viralLoadSupressedDuringMonth() {
        return cohortIndicator("Viral Load suppressed durring this month", map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept("dca12261-30ab-102d-86b0-7a5022ba4115"),Dictionary.getConcept("2aa7d442-6cbb-4609-9dd3-bc2ad6f05016")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    public CohortIndicator gestationAge24() {
        return cohortIndicator("Pregnant Women recieved free LLIN", map(cohortLibrary.gestationAge(24.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Referral to ANC unit from community services
     * @return CohortIndicator
     */
    public CohortIndicator referalToAncUnitFromCommunityServices(){
        return cohortIndicator("Referral to ANC unit from community services", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("67ea4375-0f4f-4e67-b8b0-403942753a4d"), Dictionary.getConcept("1ca0db4a-c5c6-48ed-9e17-84905f4487eb")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * IPT Doses Given
     */

    public CohortIndicator iptFirstDosage(){
        return cohortIndicator("Pregnant Mothers given first IPT Dosage ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), Dictionary.getConcept("0192ca59-b647-4f88-b07e-8fda991ba6d6")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator iptSecondDosage(){
        return cohortIndicator("Pregnant Mothers given second IPT Dosage ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), Dictionary.getConcept("f1d5afce-8dfe-4d2d-b24b-051815d61848")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator iptThirdDosage(){
        return cohortIndicator("Pregnant Mothers given third IPT Dosage ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), Dictionary.getConcept("a5497b5a-7da1-42d2-9985-b5ec695b4199")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator iptFourthDosage(){
        return cohortIndicator("Pregnant Mothers given fourth IPT Dosage ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), Dictionary.getConcept("da40fa2a-074f-4d90-a875-5bb8316bc753")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }



    /**
     * Referral to ANC unit total
     * @return CohortIndicator
     */
    public CohortIndicator referalToAncUnitTotal(){
        return cohortIndicator("Referral to ANC unit totals", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("67ea4375-0f4f-4e67-b8b0-403942753a4d"), Dictionary.getConcept("03997d45-f6f7-4ee2-a6fe-b16985e3495d"), Dictionary.getConcept("14714862-6c78-49da-b65b-f249cccddfb6")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Referral from ANC unit total
     * @return CohortIndicator
     */
    public CohortIndicator referalFromAncUnitTotal(){
        return cohortIndicator("Referral from ANC unit totals", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("67ea4375-0f4f-4e67-b8b0-403942753a4d"), Dictionary.getConcept("6442c9f6-25e8-4c8e-af8a-e9f6845ceaed"), Dictionary.getConcept("3af0aae4-4ea7-489d-a5be-c5339f7c5a77")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    /**
     * Referral from ANC unit FSG
     * @return CohortIndicator
     */
    public CohortIndicator referalFromAncUnitFSG(){
        return cohortIndicator("Referral from ANC unit FSG", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("67ea4375-0f4f-4e67-b8b0-403942753a4d"), Dictionary.getConcept("3af0aae4-4ea7-489d-a5be-c5339f7c5a77")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * IPT(IPT1) Dose
     * @return CohortIndicator
     */
    public CohortIndicator iptDose(Concept answer){
        return cohortIndicator("Ipt dose on "+answer.getName().getName(), map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), answer), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * A9-Pregnant Women receiving Iron/Folic Acid on ANC 1 st Visit
     * @return CohortIndicator
     */
    public CohortIndicator pregnantAndReceivingIronOrFolicAcidAnc1stVisit() {
        return cohortIndicator("Pregnant Women receiving Iron/Folic Acid on ANC 1 st Visit", map(cohortLibrary.pregnantAndReceivingIronOrFolicAcidAnc1stVisit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Blood Groups
     * @return
     */
    public CohortIndicator totalBloodGroupO() {
        return cohortIndicator("Clients with Blood Group O", map(cclibrary.hasObs(Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConceptList("dc8627f6-30ab-102d-86b0-7a5022ba4115,dc8655aa-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
//    public CohortIndicator bloodGroupONegative(){
//        return cohortIndicator("Clients with blood group O", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc8627f6-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
//    }
    public CohortIndicator bloodGroupOPositive(){
        return cohortIndicator("Clients with blood group O", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc8655aa-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator totalBloodGroupA() {
        return cohortIndicator("Clients with Blood Group A", map(cclibrary.hasObs(Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConceptList("dc8627f6-30ab-102d-86b0-7a5022ba4115,dc863095-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator bloodGroupAPositive(){
        return cohortIndicator("Clients with blood group A+", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc8627f6-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
//    public CohortIndicator bloodGroupANegative(){
//        return cohortIndicator("Clients with blood group A+", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc863095-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
//    }

    public CohortIndicator totalBloodGroupB() {
        return cohortIndicator("Clients with Blood Group B", map(cclibrary.hasObs(Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConceptList("dc863929-30ab-102d-86b0-7a5022ba4115,dc86419b-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator bloodGroupBPositive(){
        return cohortIndicator("Clients with blood group B+", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc863929-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    public CohortIndicator totalBloodGroupAB() {
        return cohortIndicator("Clients with Blood Group AB", map(cclibrary.hasObs(Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConceptList("dc9f4cdf-30ab-102d-86b0-7a5022ba4115,dc9f4893-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator bloodGroupABPositive(){
        return cohortIndicator("Clients with blood group AB+", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dc747e86-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dc9f4893-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }



    /**
     * TB Presumptive
     * @return
     */

    public CohortIndicator tbPresumptive(){
        return cohortIndicator("Client3s Presumed to have TB ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115"), Dictionary.getConcept("dcdaaf0f-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator pregnantandDiagnisedWithTB() {
        return cohortIndicator("Pregnant Women diagonised with TB", map(cohortLibrary.pregnantAndDiagnisedWithTB(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    /**
     * Pregnant women having different obs
     * @return CohortIndicator
     */
    public CohortIndicator pregnantAndReceivingServices(Concept question, Concept answer) {
        return cohortIndicator("Receiving different servicess", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, question, answer), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant women tested for syphilis
     * @return CohortIndicator
     */
    public CohortIndicator pregnantAndTestedForSyphilis() {
        return cohortIndicator("Pregnant women tested for syphilis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantAndTestedForHEPB() {
        return cohortIndicator("Pregnant women tested for HEPB", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.HEPB_TEST)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantAndTestedPositiveforSyphillis() {
        return cohortIndicator("Pregnant Women tested Positive for Syphillis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST), Dictionary.getConcept("db3b19b2-e5f0-48c5-9ab4-dd9e4ad519dd"),Dictionary.getConcept("fe247560-8db6-4664-a6bc-e3b873b9b10a")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator pregnantAndTestedPositiveforHEPB() {
        return cohortIndicator("Pregnant Women tested Positive for Syphillis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.HEPB_TEST),  Dictionary.getConcept("f544bf93-327a-4483-b1ff-cf9d95d13a43"),Dictionary.getConcept("e378c65a-945a-4d2e-95bb-cc4b87e2d0b2")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator pregnantAndTestedPositiveforSyphillisAndStartedTreatment() {
        return cohortIndicator("Pregnant Women tested Positive for Syphillis and started treatment", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST),  Dictionary.getConcept("db3b19b2-e5f0-48c5-9ab4-dd9e4ad519dd")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator pregnantAndTestedPositiveforHEPBAndStartedTreatment() {
        return cohortIndicator("Pregnant Women tested Positive for HEPB and started treatment", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.HEPB_TEST),  Dictionary.getConcept("db3b19b2-e5f0-48c5-9ab4-dd9e4ad519dd")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator partnerTestedForSyphilis() {
        return cohortIndicator("Partner tested for syphilis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST_PARTNER)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator patnerTestedPositiveforSyphillis() {
        return cohortIndicator("Pregnant Women tested Positive for Syphillis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST_PARTNER),  Dictionary.getConcept("db3b19b2-e5f0-48c5-9ab4-dd9e4ad519dd"),Dictionary.getConcept("fe247560-8db6-4664-a6bc-e3b873b9b10a")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator partnerTestedPositiveforSyphillisAndStartedTreatment() {
        return cohortIndicator("Pregnant Women tested Positive for Syphillis and started treatment", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.SYPHILLS_TEST_PARTNER),  Dictionary.getConcept("db3b19b2-e5f0-48c5-9ab4-dd9e4ad519dd")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }


    public CohortIndicator pregnantAndTestedforTB() {
        return cohortIndicator("ANC Visit and tested for TB", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant Women newly tested for HIV this pregnancy (TR & TRR)
     * @return CohortIndicator
     */
    public CohortIndicator pregnantWomenNewlyTestedForHivThisPregnancyTRAndTRR() {
        return cohortIndicator("Pregnant Women newly tested for HIV this pregnancy (TR & TRR)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_T), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TR), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenwithKnownHIVStatus() {
        return cohortIndicator("Pregnant Women newly tested for HIV this pregnancy (TR & TRR)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRTICK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    /**
     * Pregnant Women newly tested for HIV this pregnancyand are negative (TR )
     * @return CohortIndicator
     */
    public CohortIndicator pregnantWomenNewlyTestedNegativeForHivThisPregnancyTRAt1stVisit() {
        return cohortIndicator("Pregnant Women tested HIV- for 1st time this pregnancy (TRR) at 1st visit", map(cohortLibrary.pregnantWomenNewlyTestedForHivThisPregnancyAt1stVisitTR(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at any visit
     * @return CohortIndicator
     */
    public CohortIndicator pregnantWomenNewlyTestedForHivThisPregnancyTRR() {
        return cohortIndicator("Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at any visit", map(cohortLibrary.pregnantWomenNewlyTestedForHivThisPregnancyTRRAnyVisit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator pregnantWomenNewlyTestedForHivThisPregnancyAndTestedHIVPositive() {
        return cohortIndicator("Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at any visit", map(cclibrary.hasANCObs(
		        Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),  Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * TRR at 1st ANC VISIT
     * @return cohortindicator
     */
    public CohortIndicator pregnantWomenNewlyTestedForHivThisPregnancyTRRAt1stVisit() {
        return cohortIndicator("Pregnant Women tested HIV+ for 1st time this pregnancy (TRR) at 1st visit", map(cohortLibrary.pregnantWomenNewlyTestedForHivThisPregnancyAt1stVisitTRR(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    /**
     * HIV+ Pregnant women assessed by CD4 or WHO clinical stage the 1 time
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveAndAccessedWithCd4WhoStage(Concept question) {
        return cohortIndicator("Pregnant women assessed by "+question.getName().getName(), map(cohortLibrary.hivPositiveAndAccessedWithCd4WhoStage(question), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**Pregnant women assessed by
     * HIV+ Pregnant Women initiated on ART for EMTCT (ART)
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveInitiatedART() {
        return cohortIndicator("Pregnant Women tested HIV+ and initiated on ART", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("a615f932-26ee-449c-8e20-e50a15232763"),  Dictionary.getConcept("026e31b7-4a26-44d0-8398-9a41c40ff7d3")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant women who knew status before 1st ANC total (TRK+TRRK)
     * @return CohortIndicator
     */
    public CohortIndicator pregnantWomenWithKnownHIVStatusBeforeFirstANCVisit() {
        return cohortIndicator("Pregnant women who knew status before 1st ANC total (TRK+TRRK)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator totalPregnantWomenTestedLater() {
        return cohortIndicator("Pregnant women who retested later in the pregancy total (TR+TRR+)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP),Dictionary.getConcept("a08d9331-b437-485c-8eff-1923f3d43630")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenTestedLater() {
        return cohortIndicator("Pregnant women who retested later in the pregancy total (TRR+)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator pregnantWomenHIVProhylaxis() {
        return cohortIndicator("Pregnant women given infant HIV Prophylaxis", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.HIV_PROHYLAXIS),Dictionary.getConcept(Metadata.Concept.NEVERAPINE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }



    public CohortIndicator pregnantWomenGivenSTKs() {
        return cohortIndicator("Pregnant women given STKs", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("609c9aee-92b3-4e17-828a-efc7933f2ecf"),Dictionary.getConcept(Metadata.Concept.YES_CIEL)), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator positiveSTKResult() {
        return cohortIndicator("Positive STK Results", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("e47d9ead-5b33-4315-9ea0-42669e4491b6"),Dictionary.getConcept("dc866728-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator negativeSTKResult() {
        return cohortIndicator("Negative STK Results", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("e47d9ead-5b33-4315-9ea0-42669e4491b6"),Dictionary.getConcept("dc85aa72-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    /**
     * Pregnant women who knew status before 1st ANC total TRRK
     * @return CohortIndicator
     */
    public CohortIndicator pregnantTrrk() {
        return cohortIndicator("Pregnant women who knew status before 1st ANC total TRRK", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator pregnantTrkAt1stANC() {
        return cohortIndicator("Pregnant women who knew status before 1st ANC total TRK", map(cohortLibrary.pregnantWomenThisPregnancyAt1stANCVisit(Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK),"trk"), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator pregnantTrrkAt1stANC() {
        return cohortIndicator("Pregnant women who knew status before 1st ANC total TRK", map(cohortLibrary.pregnantWomenThisPregnancyAt1stANCVisit(Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK),"trrk"), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    /**
     * Pregnant Women already on ART before 1 ANC (ART-K)
     * @return CohortIndicator
     */
    public CohortIndicator alreadyOnARTK(){
        return cohortIndicator("Pregnant Women already on ART before 1 ANC (ART-K)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("a615f932-26ee-449c-8e20-e50a15232763"), Dictionary.getConcept("2aa7d442-6cbb-4609-9dd3-bc2ad6f05016")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant Women re-tested later in pregnancy (TR+&TRR+)
     * @return CohortIndicator
     */
    public CohortIndicator retestedTrTrrPlus(){
        return cohortIndicator("Pregnant Women re-tested later in pregnancy (TR+&TRR+))", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator retestedTrrPlusAndNewlyTestedForHivThisPregnancy(){
        return cohortIndicator("(Trr And Trr+)",map(cohortLibrary.hasObsAndEncounter(ANC_UUID,Dictionary.getConcept(Metadata.Concept.EMTCT_CODES),Dictionary.getConcept("60155e4d-1d49-4e97-9689-758315967e0f"),Dictionary.getConcept("25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465")),"onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Pregnant Women testing HIV+ on a retest (TRR+)
     * @return CohortIndicator
     */
    public CohortIndicator retestedTrrPlus() {
        return cohortIndicator("Pregnant Women testing HIV+ on a retest (TRR+)", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept(Metadata.Concept.EMTCT_CODES), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRP)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * HIV+ Pregnant Women initiated on Cotrimoxazole
     * @return CohortIndicator
     */
    public CohortIndicator initiatedOnCtx() {
        return cohortIndicator("Pregnant Women initiated on Cotrimoxazole", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("1da3cb98-59d8-4bfd-b0bb-c9c1bcd058c6"), Dictionary.getConcept("fca28768-50dc-4d6b-a3d2-2aae3b376b27")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Male partiners received HIV test results in eMTCT total
     * @return CohortIndicator
     */
    public CohortIndicator malePatinersRecievedHivResultTotal() {
        return cohortIndicator("Male partners received HIV test results in eMTCT - Totals", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TR)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator malePatinersRecievedHivResult() {
        return cohortIndicator("Male partners received HIV test results in eMTCT ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator malePatinersWithKnownHivResultTotal() {
        return cohortIndicator("Male partners with known HIV status total", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator malePatinersWithKnownHivResult() {
        return cohortIndicator("Male partners with known HIV status ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator malePartnersInitiatedOnART() {
        return cohortIndicator("Male partners initiated on ART ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"),Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Male partiners received HIV test results in eMTCT HIV+
     * @return CohortIndicator
     */
    public CohortIndicator malePatinersRecievedHivResultHivPositive() {
        return cohortIndicator("Male partners received HIV test results in eMTCT - HIV+", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("62a37075-fc2a-4729-8950-b9fae9b22cfb"), Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Post natal attendances totals
     * @return CohortIndicator
     */
    public CohortIndicator pncAttendances() {
        return cohortIndicator("Total attendances", map(cclibrary.hasEncounter(Context.getEncounterService().getEncounterTypeByUuid(PNC_UUID)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Post natal attendances totals
     * @return CohortIndicator
     */
    public CohortIndicator pncAttendances(String ans) {
        return cohortIndicator("Total attendances Timing", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, Dictionary.getConcept("1732AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"), Dictionary.getConcept(ans)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * The observations ahs some answers collected
     */
    public CohortIndicator hasObs(String q, String ans) {
        return cohortIndicator("Has some obs", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, Dictionary.getConcept(q), Dictionary.getConcept(ans)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Total HIV+ mothers attending postnatal
     * @return CohortIndicator
     */
    public CohortIndicator totaHivPositiveMothers() {
        return cohortIndicator("Total HIV+ mothers attending postnatal", map(cohortLibrary.hivPositiveMothersInAnc(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Hiv+ women initiating ART in PNC
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveWomenInitiatingART() {
        Concept art = Dictionary.getConcept("a615f932-26ee-449c-8e20-e50a15232763");
        Concept ans = Dictionary.getConcept("026e31b7-4a26-44d0-8398-9a41c40ff7d3");

        return cohortIndicator("Hiv positive women initiating ART in PNC", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, art, ans), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Mother-baby pairs enrolled at Mother-Baby care point
     * @return CohortIndicator
     */
    public CohortIndicator enrolledAtMotherBabyCarePoint() {
        return cohortIndicator("Mother-baby pairs enrolled at Mother-Baby care point", map(cohortLibrary.motherBabyEnrolled(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Breastfeeding mothers tested for HIV 1st test during postnatal
     * @return CohortIndicator
     */
    public CohortIndicator breastFeedingMothersTestedForHIVFirstTestDuringPostnatal() {
        Concept t = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_T);
        Concept tr = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TR);
        Concept trr = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR);
        Concept trrTick = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK);
        Concept trTick = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRK);
        Concept question = Dictionary.getConcept(Metadata.Concept.EMTCT_CODES);
        return cohortIndicator("Breastfeeding mothers tested for HIV 1st test during postnatal", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, question, t, tr, trTick, trrTick, trr), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Breastfeeding mothers tested for HIV 1st test during postnatal
     * @return CohortIndicator
     */
    public CohortIndicator breastFeedingMothersTestedForHIVReTestDuringPostnatal() {
        Concept question = Dictionary.getConcept(Metadata.Concept.EMTCT_CODES);
        Concept trPlus = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRP);
        Concept trrPlus = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRP);

        return cohortIndicator("Breastfeeding mothers tested for HIV re test during postnatal", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, question, trPlus, trrPlus), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Breastfeeding mothers tested for HIV+ 1st test during postnatal
     * @return CohortIndicator
     */
    public CohortIndicator breastFeedingMothersTestedForHIVPositiveTestDuringPostnatal() {
        Concept question = Dictionary.getConcept(Metadata.Concept.EMTCT_CODES);
        Concept trPlus = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRR);
        Concept trrPlus = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRRK);

        return cohortIndicator("Breastfeeding mothers tested for HIV+  test during postnatal", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, question, trPlus, trrPlus), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Breastfeeding mothers tested for HIV+ retest test during postnatal
     * @return CohortIndicator
     */
    public CohortIndicator breastFeedingMothersTestedForHIVPositiveReTestDuringPostnatal() {
        Concept question = Dictionary.getConcept(Metadata.Concept.EMTCT_CODES);
        Concept trPlus = Dictionary.getConcept(Metadata.Concept.EMTCT_CODE_TRP);


        return cohortIndicator("Breastfeeding mothers tested for HIV+  test during postnatal", map(cohortLibrary.hasObsAndEncounter(PNC_UUID, question, trPlus), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * Missed appointment in the period
     * @return
     */
    public CohortIndicator missedANCAppointment() {
        return cohortIndicator("Patients who have ANC 1st Visit", map(cohortLibrary.missedANCAppointment(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Visit for women - No in 1st trimester
     * @return CohortIndicator
     */
    public CohortIndicator visitsForWomenInFirstTrimester(){
        Concept anc1 = Dictionary.getConcept("3a862ab6-7601-4412-b626-d373c1d4a51e");
        return cohortIndicator("Visit for women - No in 1st trimester", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, anc1, Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *Maternity Admissions
     * @return CohortIndicator
     */
    public CohortIndicator maternityAdmissions() {
        return cohortIndicator("Maternity admissions", map(cohortLibrary.maternityAdmissions(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *Referrals to Maternity Unit
     * @return CohortIndicator
     */
    public CohortIndicator referralsToMaternityUnit() {
        return cohortIndicator("Referrals to maternity unit", map(cclibrary.hasTextObs(Dictionary.getConcept(Metadata.Concept.REFERRAL_NUMBER), "REF"), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Referrals out of Maternity Unit
     * @return CohortIndicator
     */
    public CohortIndicator maternityReferralsOut() {
        return cohortIndicator("Maternity referrals Out", map(cclibrary.hasObs(Dictionary.getConcept("e87431db-b49e-4ab6-93ee-a3bd6c616a94"), Dictionary.getConcept("6e4f1db1-1534-43ca-b2a8-5c01bc62e7ef")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Deliveries in unit - Total
     * @return CohortIndicator
     */
    public CohortIndicator deliveriesInUnit() {
        return cohortIndicator("Deliveries in unit", map(cohortLibrary.deliveriesInUnit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *Fresh still birth deliveries
     * @return CohortIndicator
     */
    public CohortIndicator freshStillBirthDeliveries() {
        return cohortIndicator("Fresh still birth", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"), Dictionary.getConcept("7a15616a-c12a-44fc-9a11-553639128b69")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Macerated still birth deliveries
     * @return CohortIndicator
     */
    public CohortIndicator maceratedStillBirthDeliveries() {
        return cohortIndicator("Macerated still birth", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"), Dictionary.getConcept("fda5ad21-6ba4-4526-a0f3-ea1269d43422")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Live births
     * @return CohortIndicator
     */
    public CohortIndicator liveBirthDeliveries() {
        return cohortIndicator("Live births", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"), Dictionary.getConceptList("eb7041a0-02e6-4e9a-9b96-ff65dd09a416,23ac7575-f0ea-49a5-855e-b3348ad1da01")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *Pre-Term births
     * @return CohortIndicator
     */
    public CohortIndicator pretermBirthDeliveries() {
        return cohortIndicator("Pre-Term births", map(cclibrary.hasObs(Dictionary.getConcept("161033AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"), Dictionary.getConcept("129218AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *M5: Women tested for HIV in labour - 1st time this Pregnancy
     * @return CohortIndicator
     */
    public CohortIndicator womenTestedForHivInLabourFirstTimePregnancy() {
        return cohortIndicator("Women tested for HIV in labour - 1st time this Pregnancy", map(cclibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"), Dictionary.getConceptList("81bd3e58-9389-41e7-be1a-c6723f899e56,1f177240-85f6-4f10-964a-cfc7722408b3")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M5: Women tested for HIV in labour - Retest this Pregnancy
     * @return CohortIndicator
     */
    public CohortIndicator womenTestedForHivInLabourRetestThisPregnancy() {
        return cohortIndicator("Women tested for HIV in labour - Retest this Pregnancy", map(cclibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"), Dictionary.getConceptList("05f16fc5-1d82-4ce8-9b44-a3125fbbf2d7,86e394fd-8d85-4cb3-86d7-d4b9bfc3e43a,25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465,60155e4d-1d49-4e97-9689-758315967e0f")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M6: Women testing HIV+ in labour - 1st time this Pregnancy
     * @return CohortIndicator
     */
    public CohortIndicator womenTestingHivPositiveInLabourFirstTimePregnancy() {
        return cohortIndicator("M6: Women testing HIV+ in labour - 1st time this Pregnancy", map(cclibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"), Dictionary.getConcept("1f177240-85f6-4f10-964a-cfc7722408b3")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M6: Women testing HIV+ in labour - Retest this Pregnancy
     * @return CohortIndicator
     */
    public CohortIndicator womenTestingHivPositiveInLabourRetestThisPregnancy() {
        return cohortIndicator("M6: Women testing HIV+ in labour - Retest this Pregnancy", map(cclibrary.hasObs(Dictionary.getConcept("d5b0394c-424f-41db-bc2f-37180dcdbe74"), Dictionary.getConceptList("25c448ff-5fe4-4a3a-8c0a-b5aaea9d5465,60155e4d-1d49-4e97-9689-758315967e0f")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M7: HIV+ women initiating ART in maternity
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveWomenInitiatingArtInMaternity() {
        return cohortIndicator("HIV+ women initiating ART in maternity", map(cohortLibrary.hivPositiveWomenInitiatingArvInMaternity(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M8: Deliveries to HIV+ women in unit - Total
     * @return CohortIndicator
     */
    public CohortIndicator deliveriesTohivPositiveWomen() {
        return cohortIndicator("Deliveries to HIV+ women", map(cohortLibrary.deliveriesToHIVPositiveWomen(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M8: Deliveries to HIV+ women in unit - Live births
     * @return CohortIndicator
     */
    public CohortIndicator liveBirthDeliveriesTohivPositiveWomen() {
        return cohortIndicator("Live birth deliveries to HIV+ women", map(cohortLibrary.liveBirthDeliveriesToHIVPositiveWomen(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *M9: HIV Exposed babies given ARVs
     * @return CohortIndicator
     */
    public CohortIndicator hivExposedBabiesGivenArvs() {
        return cohortIndicator("HIV exposed babies given ARVs", map(cclibrary.hasObs(Dictionary.getConcept("9e825e42-be00-4d4d-8774-257ddb29581b")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M10: No. of mothers who initiated breastfeeding within the 1st hour after delivery - Total
     * @return CohortIndicator
     */
    public CohortIndicator initiatedBreastfeedingWithinFirstHourAfterDelivery() {
        return cohortIndicator("Initiated breastfeeding within the 1st hour after delivery", map(cohortLibrary.initiatedBreastfeedingWithinFirstHourAfterDelivery(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *M10: No. of mothers who initiated breastfeeding within the 1st hour after delivery - HIV+
     * @return CohortIndicator
     */
    public CohortIndicator initiatedBreastfeedingWithinFirstHourAfterDeliveryAndHivPositive() {
        return cohortIndicator("Initiated breastfeeding within the 1st hour after delivery and HIV+", map(cohortLibrary.initiatedBreastfeedingWithinFirstHourAfterDeliveryAndHIVPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M11: Babies born with low birth weight (<2.5kg)
     * @return CohortIndicator
     */
    public CohortIndicator babiesBornWithLowBirthWeight() {
        return cohortIndicator("Babies born with low birthweight", map(cohortLibrary.babiesBornWithLowBirthWeight(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M12: Live babies
     * @return CohortIndicator
     */
    public CohortIndicator liveBabies() {
        return cohortIndicator("Live babies", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"),Dictionary.getConceptList("eb7041a0-02e6-4e9a-9b96-ff65dd09a416,23ac7575-f0ea-49a5-855e-b3348ad1da01")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *M13: Babies born with defect
     * @return CohortIndicator
     */
    public CohortIndicator babiesBornWithDefect() {
        return cohortIndicator("Babies born with defect", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"),Dictionary.getConcept("23ac7575-f0ea-49a5-855e-b3348ad1da01")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *M15: Newborn deaths (0-7 days)
     * @return CohortIndicator
     */
    public CohortIndicator newBornDeaths() {
        return cohortIndicator("New born deaths", map(cclibrary.hasObs(Dictionary.getConcept("a5638850-0cb4-4ce8-8e87-96fc073de25d"),Dictionary.getConcept("ab3a7679-f5ee-48d6-b690-f55a1dfe95ea")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**

     *M16: Maternal deaths
     * @return CohortIndicator
     */
    public CohortIndicator maternalDeaths() {
        return cohortIndicator("Maternal deaths", map(cohortLibrary.maternalDeaths(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }    
    
    /**
     *M18: Birth asphyxia
     * @return CohortIndicator
     */
    public CohortIndicator birthAsphyxia() {
        return cohortIndicator("Birth asphyxia", map(cclibrary.hasObs(Dictionary.getConcept("121397AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"), Dictionary.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *M19: No. of babies who received PNC at 6 hours
     * @return CohortIndicator
     */
    public CohortIndicator babiesReceivedPncAt6Hours() {
        return cohortIndicator("Babies received PNC at 6 hours", map(cclibrary.hasObs(Dictionary.getConcept("93ca1215-5346-4fde-8905-84e930d9f1c1")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    // Begin Family planning section
    
    /**
     *F1-Oral : Lo-Femenal
     * @return CohortIndicator
     */
    public CohortIndicator oralLofemenalFamilyPlanningUsers() {
        return cohortIndicator("Oral : Lo-Femenal", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("38aa1dc0-1aaa-4bdd-b26f-28f960dfb16c")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F2-Oral: Microgynon
     * @return CohortIndicator
     */
    public CohortIndicator oralMicrogynonFamilyPlanningUsers() {
        return cohortIndicator("Oral: Microgynon", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("4b0899f2-395e-4e0f-8b58-d304b214615e")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F3-Oral: Ovrette or another POP
     * @return CohortIndicator
     */
    public CohortIndicator oralOvretteFamilyPlanningUsers() {
        return cohortIndicator("Oral: Ovrette", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("82624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F4-Oral: Others
     * @return CohortIndicator
     */
    public CohortIndicator oralOtherFamilyPlanningUsers() {
        return cohortIndicator("Oral: Others", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("670b7048-d71e-483a-b2ec-f10d2326dd84")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F5-Female condoms
     * @return CohortIndicator
     */
    public CohortIndicator femaleCondomsFamilyPlanningUsers() {
        return cohortIndicator("Oral: Female Condoms", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("dc882c84-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     *F6-Male condoms
     * @return CohortIndicator
     */
    public CohortIndicator maleCondomsFamilyPlanningUsers() {
        return cohortIndicator("Oral: Male Condoms", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("aeee4ccf-cbf8-473c-9d9f-846643afbf11")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F7-IUDs
     * @return CohortIndicator
     */
    public CohortIndicator iudFamilyPlanningUsers() {
        return cohortIndicator("Oral: IUDs", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConceptList("dcb2f595-30ab-102d-86b0-7a5022ba4115,fed07c37-7bb6-4baa-adf9-596ce4c4e93c,dd4c3016-13cf-458a-8e93-fe54460be667")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F8-Injectable
     * @return CohortIndicator
     */
    public CohortIndicator injectableFamilyPlanningUsers() {
        return cohortIndicator("Oral: Injectable", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("dcb30ba3-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F9-Natural
     * @return CohortIndicator
     */
    public CohortIndicator naturalFamilyPlanningUsers() {
        return cohortIndicator("Oral: Injectable", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),Dictionary.getConcept("dcb30381-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F10-Other methods
     * @return CohortIndicator
     */
    public CohortIndicator otherFamilyPlanningUsers() {
        return cohortIndicator("Oral: Other Method", map(cclibrary.hasObs(
        	Dictionary.getConcept(Metadata.Concept.FAMILY_PLANNING_METHOD),
        	Dictionary.getConceptList("5622AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,"
        		+ "dcb2fba9-30ab-102d-86b0-7a5022ba4115,"
        		+ "dcdd8d8d-30ab-102d-86b0-7a5022ba4115,"
        		+ "bb83fd9d-24c5-4d49-89c0-97e13c792aaf,"
        		+ "dcdd91a7-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *Total family planning users
     * @return CohortIndicator
     */
    public CohortIndicator allFamilyPlanningUsers() {
        return cohortIndicator("Total family planning users", map(cohortLibrary.allFamilyPlanningUsers(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     *F11: Number HIV+ FP users
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveFamilyPlanningUsers() {
        return cohortIndicator("Total family planning users", map(cohortLibrary.hivPositiveFamilyPlanningUsers(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    //End Family planning section
 
    //Begin HIV/AIDS counseling and testing (HCT)
    
    /**
     * H1-Number of Individuals counseled
     * @return CohortIndicator
     */
    public CohortIndicator individualsCounselled() {
        return cohortIndicator("Number of Individuals counseled", map(cohortLibrary.counseledAsIndividuals(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H2-Number of Individuals tested
     * @return CohortIndicator
     */
    public CohortIndicator individualsTested() {
        return cohortIndicator("Number of Individuals tested", map(cohortLibrary.individualsTested(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * H3-Number of Individuals who received HIV test results
     * @return CohortIndicator
     */
    public CohortIndicator individualsWhoReceivedHIVTestResults() {
        return cohortIndicator("Number of Individuals who received HIV test results", map(cohortLibrary.receivedHivTestResults(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H4- Number of individuals who received HIV results in the last 12months
     * @return CohortIndicator
     */
    public CohortIndicator individualsWhoReceivedHIVTestResultsInLast12Months() {
        return cohortIndicator("Number of Individuals who received HIV test results in last 12 Months", map(cohortLibrary.individualsWhoReceivedHIVTestResultsInLast12Months(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * H5 – Number of individuals tested for the first time
     * @return CohortIndicator
     */
    public CohortIndicator individualsTestedForTheFirstTime() {
        return cohortIndicator("Number of individuals tested for the first time", map(cohortLibrary.individualsTestingFortheFirstTime(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * H6-Number of Individuals who tested HIV positive
     * @return CohortIndicator
     */
    public CohortIndicator individualsWhoTestedHivPositive() {
        return cohortIndicator("Number of Individuals who tested HIV positive", map(cohortLibrary.testedHivPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H7-HIV positive individuals with presumptive TB
     * @return CohortIndicator
     */
    public CohortIndicator individualsWhoTestedHivPositiveAndWithPresumptiveTb() {
        return cohortIndicator("HIV positive individuals with presumptive TB", map(cohortLibrary.individualsWhoTestedHivPositiveAndWithPresumptiveTB(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * H8-Number of Individuals tested more than twice in the last 12 months
     * @return CohortIndicator
     */
    public CohortIndicator individualsTestedMoreThanTwiceInLast12Months() {
        return cohortIndicator("Number of Individuals tested more than twice in the last 12 months", map(cohortLibrary.testedMoreThanOnceInLast12Months(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H9-Number of individuals who were Counseled and Tested together as a Couple
     * @return CohortIndicator
     */
    public CohortIndicator individualsCounseledAndTestedAsCouple() {
        return cohortIndicator("Number of individuals who were Counseled and Tested together as a Couple", map(cohortLibrary.individualsCounseledAndTestedAsACouple(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H10-Number of individuals who were Tested and Received results together as a Couple
     * @return CohortIndicator
     */
    public CohortIndicator individualsTestedAndReceivedResultsAsACouple() {
        return cohortIndicator("Number of individuals who were Tested and Received results together as a Couple", map(cohortLibrary.individualsTestedAndReceivedResultsAsACouple(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H11-Number of couples with Concordant positive results
     * @return CohortIndicator
     */
    public CohortIndicator couplesWithConcordantPositiveResults() {
        return cohortIndicator("Number of couples with Concordant positive results", map(cohortLibrary.couplesWithConcordantPositiveResults(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }    

    /**
     * H12- Number of couples with Discordant results
     * @return CohortIndicator
     */
    public CohortIndicator couplesWithDiscordantResults() {
        return cohortIndicator("Number of couples with Disconcordant results", map(cohortLibrary.couplesWithDiscordantResults(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator discordantResults() {
        return cohortIndicator("Number of couples with Disconcordant results", map(cohortLibrary.discordantCouples(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator maternalNutrition() {
        return cohortIndicator("Pregnant women recieved Maternal nutrition counselling ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("af7dccfd-4692-4e16-bd74-5ac4045bb6bf"),Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator infantFeedingCounselling() {
        return cohortIndicator("Pregnant women who recieved Infant feeding and counselling ", map(cohortLibrary.hasObsAndEncounter(ANC_UUID, Dictionary.getConcept("5d993591-9334-43d9-a208-11b10adfad85"),Dictionary.getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115")), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator maternalNutritionAndHIVPositive() {
        return cohortIndicator("Maternal Nutrition and Counselling", map(cohortLibrary.marternalCounsellingandPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator infantFeedingCounsellingAndHIVPositive() {
        return cohortIndicator("Infant feeding and Counselling", map(cohortLibrary.infantCounsellingAndPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    /**
     * H13-Individuals counseled and tested for PEP
     * @return CohortIndicator
     */
    public CohortIndicator individualsCounselledAndTestedForPep() {
        return cohortIndicator("Individuals counseled and tested for PEP", map(cohortLibrary.individualsCounseledAndTestedForPep(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator testedAsSpecialCategory() {
        return cohortIndicator("Individuals counseled and tested as Special Cateogries", map(cohortLibrary.individualsCounseledAndTestedAsSpecial(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * H14-Number of individuals tested as MARPS
     * @return CohortIndicator
     */
    public CohortIndicator individualsCounselledAndTestedMarps() {
        return cohortIndicator("Individuals counseled and tested as MARPS", map(cohortLibrary.individualsCounseledAndTestedAsMarps(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }




    /**
     * HCT Entry Points
     * @return CohortIndicator
     */

    public CohortIndicator individualsWithANCareEntryPoint() {
        return cohortIndicator("Individuals With ANC as Entry Point and Tested Positive", map(cohortLibrary.clientsWithANCEntryPoint(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithFamilyPlanningDeptAsHCTEntryPoint() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.clientsWithFamilyPlanningDepartmentasEntryinHTC(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    public CohortIndicator individualsWithWorkPlaceAsHCTEntryPoint() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.clientsWithWorkPlaceasEntryinHTC(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithHBCTAsHCTEntryPoint() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.clientsWithHBHCTasEntryinHTC(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }


    public CohortIndicator individualsWithWardHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsAtWardEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithWardHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With Ward as Entry Point  And tested Postive", map(cohortLibrary.individualsAtWardEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithWardHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With Family Planning as Entry Point  And linked to care", map(cohortLibrary.individualsAWardEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithOPDHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With OPD as Entry Point  And linked to care", map(cohortLibrary.individualsWithOPDEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithOPDHCTEntryPointandnewlyPostive() {
        return cohortIndicator("Individuals With OPD as Entry Point  And Newly Positive", map(cohortLibrary.individualsWithOPDEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithOPDHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With OPD as Entry Point  And linked to care", map(cohortLibrary.individualsWithOPDEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }
    public CohortIndicator individualsWithART_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With ART_CLINIC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithART_CLINICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithART_CLINICHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With ART_CLINIC as Entry Point  And Newly Positive", map(cohortLibrary.individualsWithART_CLINICEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithART_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With ART_CLINIC as Entry Point  And linked to care", map(cohortLibrary.individualsWithART_CLINICEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithTB_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With TB_CLINIC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithTB_CLINICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithTB_CLINICHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With TB_CLINIC as Entry Point  And tested Positive", map(cohortLibrary.individualsWithTB_CLINICEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithTB_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With TB_CLINIC as Entry Point  And linked to care", map(cohortLibrary.individualsWithTB_CLINICEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }


    public CohortIndicator individualsWithNUTRITION_UNIT_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With NUTRITION_UNIT_CLINIC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithNUTRITION_UNIT_CLINICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithNUTRITION_UNIT_CLINICHCTEntryPointandTestedPostive() {
        return cohortIndicator("Individuals With NUTRITION_UNIT_CLINIC as Entry Point  And tested Positive", map(cohortLibrary.individualsWithNUTRITION_UNIT_CLINICEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithNUTRITION_UNIT_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With NUTRITION_UNIT_CLINIC as Entry Point  And linked to care", map(cohortLibrary.individualsWithNUTRITION_UNIT_CLINICEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithSTI_UNIT_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With STI_UNIT_CLINIC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithSTI_UNIT_CLINICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithSTI_UNIT_CLINICHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With STI_UNIT_CLINIC as Entry Point  And tested Positive", map(cohortLibrary.individualsWithSTI_UNIT_CLINICEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithSTI_UNIT_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With STI_UNIT_CLINIC as Entry Point  And linked to care", map(cohortLibrary.individualsWithSTI_UNIT_CLINICEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithYCC_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With YCC_CLINIC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithYCC_CLINICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithYCC_CLINICHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With YCC_CLINIC as Entry Point  And Newly Positive", map(cohortLibrary.individualsWithYCC_CLINICEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithYCC_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With YCC_CLINIC as Entry Point  And linked to care", map(cohortLibrary.individualsWithYCC_CLINICEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithANC_CLINICHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With ANC as Entry Point  And tested for HIV", map(cohortLibrary.individualsWithANCEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithANC_CLINICHCTEntryPointandNewlyPostive() {
        return cohortIndicator("Individuals With ANC as Entry Point  And Newly Positive", map(cohortLibrary.individualsWithANCEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithANC_CLINICHCTEntryPointandLinkedToCare() {
        return cohortIndicator("Individuals With ANC as Entry Point  And linked to care", map(cohortLibrary.individualsWithANCEntryandLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    public CohortIndicator individualsWithMaternityDeptAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Maternity as Entry Point ", map(cohortLibrary.individualsWithMaternityEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithMaternityDeptAsHCTEntryPointandNewlyPositive() {
        return cohortIndicator("Individuals With Maternity as Entry Point and Newly Positive ", map(cohortLibrary.individualsWithMaternityEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithMaternityDeptAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Maternity as Entry Point ", map(cohortLibrary.individualsWithMaternityEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithPNCAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With PNC as Entry Point ", map(cohortLibrary.individualsWithPNCEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithPNCAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With PNC as Entry Point and Newly Positive", map(cohortLibrary.individualsWithPNCEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithPNCAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With PNC as Entry Point and Linked To Care", map(cohortLibrary.individualsWithMaternityEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithFamilyPlanningAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsWithFamilyPlanningEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithFamilyPlanningAsHCTEntryPointandNewlyPositive() {
        return cohortIndicator("Individuals With Family Planning as Entry Point and Newly Positive ", map(cohortLibrary.individualsWithFamilyPlanningEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithFamilyPlanningAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsWithFamilyPlanningEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithSMCAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With SMC as Entry Point ", map(cohortLibrary.individualsWithSMCEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithSMCAsHCTEntryPointandNewlyPositive() {
        return cohortIndicator("Individuals With SMC as Entry Point ", map(cohortLibrary.individualsWithSMCEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithSMCAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With SMC as Entry Point ", map(cohortLibrary.individualsWithSMCEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithEIDAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsWithEIDEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithEIDAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsWithEIDEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithEIDAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Family Planning as Entry Point ", map(cohortLibrary.individualsWithEIDEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithOtherFacilityBasedEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Other Facility Based Points as Entry Point ", map(cohortLibrary.individualsWithOtherFacilityPointEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithOtherFacilityBasedEntryPointsAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With Other Facility Based Points as Entry Point ", map(cohortLibrary.individualsWithOtherFacilityPointEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithOtherFacilityBasedEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Other Facility Based Points as Entry Point ", map(cohortLibrary.individualsWithOtherFacilityPointEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Community Entry and Testing Points
     */

    public CohortIndicator individualsWithWorkPlaceEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Work Place Based Points as Entry Point ", map(cohortLibrary.individualsWithWorkPlaceEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithWorkPlaceEntryPointsAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With Work Place Based Points as Entry Point ", map(cohortLibrary.individualsWithWorkPlaceEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithWorkPlaceEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Work Place Based Points as Entry Point ", map(cohortLibrary.individualsWithWorkPlaceEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithHBCTEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With HBCT Based Points as Entry Point ", map(cohortLibrary.individualsWithHBCTEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithHBCTEntryPointsAsHCTEntryPointandNewlyPositive() {
        return cohortIndicator("Individuals With HBCT Based Points as Entry Point and Newly Positive ", map(cohortLibrary.individualsWithHBCTEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithHBCTEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With HBCT Based Points as Entry Point ", map(cohortLibrary.individualsWithHBCTEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithDICEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With DIC Based Points as Entry Point ", map(cohortLibrary.individualsWithDICEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithDICEntryPointsAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With DIC Based Points as Entry Point ", map(cohortLibrary.individualsWithDICEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithDICEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With DIC Based Points as Entry Point ", map(cohortLibrary.individualsWithDICEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithHotSpotsEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With HotSpots Based Points as Entry Point ", map(cohortLibrary.individualsWithHotSpotEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithHotSpotsEntryPointsAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With HotSpots Based Points as Entry Point ", map(cohortLibrary.individualsWithHotSpotEntryandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithHotSpotsEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With HotSpots Based Points as Entry Point ", map(cohortLibrary.individualsWithHotSpotEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithOtherCommunityestingPointsEntryPointsAsHCTEntryPointandTestedForHIV() {
        return cohortIndicator("Individuals With Other Community Testing Points as Entry Point ", map(cohortLibrary.individualsWithOtherCommunityTestingPOintsEntryandTestedForHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualsWithOtherCommunityestingPointsEntryPointsAsHCTEntryPointandTestedPositive() {
        return cohortIndicator("Individuals With Other Community Testing Points as Entry Point ", map(cohortLibrary.individualsWithOtherCommunityTestingPOintsEntryandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualsWithOtherCommunityestingPointsEntryPointsAsHCTEntryPointandLinkedtoCare() {
        return cohortIndicator("Individuals With Other Community Testing Points as Entry Point ", map(cohortLibrary.individualsWithOtherCommunityTestingPOintsEntryandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * PITC Health Facility Testing Appraoches
     */
    public CohortIndicator individualswithHealthFacilityAsPITCTestingApproachAndTestedForHIV() {
        return cohortIndicator("Individuals With Health Facility PITC Testing Appraoch ", map(cohortLibrary.individualsWithHealthFacilityTestingAppraochandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithHealthFacilityAsPITCTestingApproachAndNewlyPositive() {
        return cohortIndicator("Individuals With Health Facility PITC Testing Appraoch ", map(cohortLibrary.individualsWithHealthFacilityTestingAppraochandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualswithHealthFacilityAsPITCTestingApproachAndLinkedToCare() {
        return cohortIndicator("Individuals With Health Facility PITC Testing Appraoch ", map(cohortLibrary.individualsWithHealthFacilityTestingAppraochandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithCommunityAsPITCTestingApproachAndTestedForHIV() {
        return cohortIndicator("Individuals With Community  PITC Testing Appraoch ", map(cohortLibrary.individualsWithCommunityPITCApproachandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithCommunityAsPITCTestingApproachAndTestedPositive() {
        return cohortIndicator("Individuals With Community  PITC Testing Appraoch ", map(cohortLibrary.individualsWithCommunityPITCApproachandPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualswithCommunityAsPITCTestingApproachAndLinkedToCare() {
        return cohortIndicator("Individuals With Community  PITC Testing Appraoch ", map(cohortLibrary.individualsWithCommunityPITCApproachandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    /**
     * CICT/VICT Testing Approaches
     */
    public CohortIndicator individualswithFacilityBasedCICTTestingApproachAndTestedForHIV() {
        return cohortIndicator("Individuals With Health Facility CICT/VICT Testing Appraoch ", map(cohortLibrary.individualsWithFacilityBasedCICTTestingAppraochandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithFacilityBasedCICTTestingApproachAndTestedPositive() {
        return cohortIndicator("Individuals With Health Facility CICT/VICT Testing Appraoch ", map(cohortLibrary.individualsWithFacilityBasedCICTTestingAppraochandPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualswithFacilityBasedCICTTestingApproachAndLinkedToCare() {
        return cohortIndicator("Individuals With Health Facility CICT/VICT Testing Appraoch ", map(cohortLibrary.individualsWithFacilityBasedCICTTestingAppraochandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithCommunityCICTTestingApproachAndTestedForHIV() {
        return cohortIndicator("Individuals With Community  CICT Testing Appraoch ", map(cohortLibrary.individualsWithCommunityCICTApproachandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithCommunityCICTTestingApproachAndTestedPositive() {
        return cohortIndicator("Individuals With Community  CICT Testing Appraoch ", map(cohortLibrary.individualsWithCommunityCICTApproachandPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualswithCommunityCICTTestingApproachAndLinkedToCare() {
        return cohortIndicator("Individuals With Community  CICT Testing Appraoch ", map(cohortLibrary.individualsWithCommunityCICTApproachandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Individuals by Special Categories
     */
    public CohortIndicator indivudualsCategorisedAsPrisonersandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Prisoners ", map(cohortLibrary.individualsCategorisedAsPrisonersandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsPrisonersandNewlyPositive() {
        return cohortIndicator("Individuals Categorised As Prisoners ", map(cohortLibrary.individualsCategorisedAsPrisonersandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPrisonersandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Prisoners ", map(cohortLibrary.individualsCategorisedAsPrisonersandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPWIDsandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As PWIDs ", map(cohortLibrary.individualsCategorisedAsPWIDsandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsPWIDsandNewlyPositive() {
        return cohortIndicator("Individuals Categorised As PWIDs ", map(cohortLibrary.individualsCategorisedAsPWIDsandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPWIDsandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As PWIDs ", map(cohortLibrary.individualsCategorisedAsPWIDsandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsUniformedMenandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Uniformed Men ", map(cohortLibrary.individualsCategorisedAsUniformedMenandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsUniformedMenandNewlyPositive() {
        return cohortIndicator("Individuals Categorised As Uniformed Men And Newly Positive ", map(cohortLibrary.individualsCategorisedAsUniformedMenandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsUniformedMensandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Uniformed Men and Linked to Care ", map(cohortLibrary.individualsCategorisedAsUniformedMenandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsMigrantWorkersandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Migrant Workers and tested For HIV ", map(cohortLibrary.individualsCategorisedAsMigrantWorkersandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsMigrantWorkersandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Migrant Workers and Newly Positive ", map(cohortLibrary.individualsCategorisedAsMigrantWorkersandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsMigrantWorkerssandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Migrant Workers and Linked to Care ", map(cohortLibrary.individualsCategorisedAsMigrantWorkersandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsTruckerDriversandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Trucker Drivers ", map(cohortLibrary.individualsCategorisedAsTruckerDriversandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsTruckerDriversandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Trucker Drivers ", map(cohortLibrary.individualsCategorisedAsTruckerDriversandNewlyPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsTruckerDriverssandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Trucker Drivers ", map(cohortLibrary.individualsCategorisedAsTruckerDriversandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsFisherFolksandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Fisher Folks ", map(cohortLibrary.individualsCategorisedAsFisherFolksandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsFisherFolksandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Fisher Folks ", map(cohortLibrary.individualsCategorisedAsFisherFolksandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsFisherFolkssandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Fisher Folks ", map(cohortLibrary.individualsCategorisedAsFisherFolksandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsRefugeesandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Refugees ", map(cohortLibrary.individualsCategorisedAsRefugeesandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsRefugeesandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Refugees ", map(cohortLibrary.individualsCategorisedAsRefugeesandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsRefugeessandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Refugees ", map(cohortLibrary.individualsCategorisedAsRefugeesandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPregnantWomenandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Pregnant Women ", map(cohortLibrary.individualsCategorisedAsPregnantWomenandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsPregnantWomenandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Pregnant Women ", map(cohortLibrary.individualsCategorisedAsPregnantWomenandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPregnantWomenandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Pregnant Women ", map(cohortLibrary.individualsCategorisedAsPregnantWomenandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsBreastFeedingWomenandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Breast Feeding Women ", map(cohortLibrary.individualsCategorisedAsBreastFeedingWomenandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsBreastFeedingWomenandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Breast Feeding Women ", map(cohortLibrary.individualsCategorisedAsBreastFeedingWomenandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsBreastFeedingWomenandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Breast Feeding Women ", map(cohortLibrary.individualsCategorisedAsBreastFeedingWomenandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsAGYWandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As AGYW ", map(cohortLibrary.individualsCategorisedAsAGYWandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsAGYWandTestedPositive() {
        return cohortIndicator("Individuals Categorised As AGYW ", map(cohortLibrary.individualsCategorisedAsAGYWandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsAGYWandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As AGYW ", map(cohortLibrary.individualsCategorisedAsAGYWandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsPWDsandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As PWDs ", map(cohortLibrary.individualsCategorisedAsPWDsandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsPWDsandTestedPositive() {
        return cohortIndicator("Individuals Categorised As PWDs ", map(cohortLibrary.individualsCategorisedAsPWDsandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsPWDsandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As PWDs ", map(cohortLibrary.individualsCategorisedAsPWDsandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsOthersandTestedForHIV() {
        return cohortIndicator("Individuals Categorised As Others ", map(cohortLibrary.individualsCategorisedAsOthersandTestedforHIV(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator indivudualsCategorisedAsOthersandTestedPositive() {
        return cohortIndicator("Individuals Categorised As Others ", map(cohortLibrary.individualsCategorisedAsOthersandTestedPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator indivudualsCategorisedAsOthersandLinkedtoCare() {
        return cohortIndicator("Individuals Categorised As Others ", map(cohortLibrary.individualsCategorisedAsOthersandLinkedtoCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator individualswithRecentTestsResults() {
        return cohortIndicator("Individuals With Recent Test Results", map(cohortLibrary.clientsWithRecentTestResults(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    public CohortIndicator individualswithLongTermTestsResults() {
        return cohortIndicator("Individuals With Long Term Test Results", map(cohortLibrary.clientsWithLongTermTestResults(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator totalNumberofPartnersTested() {
        return cohortIndicator("Partners who tested", map(cohortLibrary.totalNumberofPartnersTested(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator partnersTestedHIVPositive() {
        return cohortIndicator("Partners who tested positive", map(cohortLibrary.partnerTestedHivPositive(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }




    /**
     * H15-Number of positive individuals who tested at an early stage (CD4>500μ)
     * @return CohortIndicator
     */
    public CohortIndicator hivPositiveIndividualsTestedAtAnEarlyStage() {
        return cohortIndicator("Number of positive individuals who tested at an early stage (CD4>500μ)", map(cohortLibrary.hivPositiveIndividualsTestedAtAnEarlyStage(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * H16-Number of clients who have been linked to care
     * @return CohortIndicator
     */
    public CohortIndicator clientsLinkedToCare() {
        return cohortIndicator("Number of clients who have been linked to care", map(cohortLibrary.clientsLinkedToCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator clientsTestedForHIV() {
        return cohortIndicator("Number of clients who have tested for HIV", map(cohortLibrary.individualsTested(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    public CohortIndicator clientsNewlyPositive() {
        return cohortIndicator("Number of clients who have tested Newly positive", map(cohortLibrary.newHIVpositiveClients(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    //End HIV/AIDS counseling and testing (HCT)        
    
    //Begin Outpatient attendance
    /**
     * 1.1 OUTPATIENT ATTENDANCE - Total Attendance
     * @return CohortIndicator
     */
	public CohortIndicator totalOutPatientAttendance() {
        return cohortIndicator("OUTPATIENT ATTENDANCE - Total Attendance", map(cohortLibrary.totalOutPatientAttendance(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}

    /**
     * 1.1 OUTPATIENT ATTENDANCE - New Attendance
     * @return CohortIndicator
     */
	public CohortIndicator newOutPatientAttendance() {
        return cohortIndicator("OUTPATIENT ATTENDANCE - New Attendance", map(cohortLibrary.newOutPatientAttendance(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}

    /**
     * 1.1 OUTPATIENT ATTENDANCE - Re-Attendance
     * @return CohortIndicator
     */
	public CohortIndicator repeatOutPatientAttendance() {
        return cohortIndicator("OUTPATIENT ATTENDANCE - Re-Attendance", map(cohortLibrary.repeatOutPatientAttendance(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	//End OUtpatient attendance
	
	//Begin Outpatient referrals
    /**
     * 1.2 OUTPATIENT REFERRALS - Referrals to unit
     * @return CohortIndicator
     */
	public CohortIndicator referralsToOPDUnit() {
        return cohortIndicator("OUTPATIENT REFERRALS - Referrals to unit", map(cohortLibrary.referralsToOPDUnit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));		
	}

    /**
     * 1.2 OUTPATIENT REFERRALS - Referrals from unit
     * @return CohortIndicator
     */
	public CohortIndicator referralFromOPDUnit() {
        return cohortIndicator("OUTPATIENT REFERRALS - Referrals from unit", map(cohortLibrary.referralsFromOPDUnit(), "onOrAfter=${startDate},onOrBefore=${endDate}"));		
	}
	//End Outpatient Referrals
	
	//Begin Outpatient Diagnosis
	/**
	 * 1.3.1.1 Acute Flaccid Paralysis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAcuteFlaccidParalysisDiagnosis() {
		return cohortIndicator("Acute Flaccid Paralysis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ACUTE_FLACCID_PARALYSIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.2. Animal Bites (suspected rabies)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnimalBitesDiagnosis() {
		return cohortIndicator("Animal Bites (suspected rabies)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ANIMAL_BITE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.3 Cholera
	 * 
	 * @return CohortIndicator
	 */
	
	public CohortIndicator opdCholeraDiagnosis() {
		return cohortIndicator("Cholera", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CHOLERA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.4 Dysentery
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDysenteryDiagnosis() {
		return cohortIndicator("Dysentery", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DYSENTERY)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.5 Guinea Worm
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdGuineaWormDiagnosis() {
		return cohortIndicator("Guinea Worm", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.GUINEA_WORM)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.6 Malaria -Total
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdMalariaTotalDiagnosis() {
		return cohortIndicator("Malaria -Total", map(cohortLibrary.totalOpdMalariaDiagnoses(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.6 Malaria -Confirmed
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdMalariaConfirmedDiagnosis() {
		return cohortIndicator("Malaria -Total", map(cohortLibrary.totalConfirmedOpdMalariaDiagnoses(), "onOrAfter=${startDate},onOrBefore=${endDate}"));		
	}
	
	/**
	 * 1.3.1.7 Measles
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdMeaslesDiagnosis() {
		return cohortIndicator("Measles", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.MEASLES)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.8 Bacterial Meningitis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdBacterialMeningitisDiagnosis() {
		return cohortIndicator("Bacterial Meningitis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.BACTERIAL_MENINGITIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.9 Neonatal tetanus
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalTetanusDiagnosis() {
		return cohortIndicator(
		    "Neonatal tetanus", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.NEONATAL_TETANUS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.10 Plague
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPlagueDiagnosis() {
		return cohortIndicator("Plague", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.PLAGUE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.11 Yellow Fever
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdYellowFeverDiagnosis() {
		return cohortIndicator("Yellow Fever", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.YELLOW_FEVER)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.12 Other Viral Hemorrhagic Fevers
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherViralHemorrhagicFeversDiagnosis() {
		return cohortIndicator("Other Viral Hemorrhagic Fevers",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_VIRAL_HEMORRHAGIC_FEVERS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.13 Severe Acute Respiratory Infection
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSevereAcuteRespiratoryInfectionDiagnosis() {
		return cohortIndicator("Severe Acute Respiratory Infection",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.SEVERE_ACUTE_RESPIRATORY_INFECTION)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.14 Adverse Events Following Immunization
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAdverseEventsFollowingImmunizationDiagnosis() {
		return cohortIndicator("Adverse Events Following Immunization",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ADVERSE_EVENTS_FOLLOWING_IMMUNIZATION)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.15 Typhoid Fever
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdTyphoidFeverDiagnosis() {
		return cohortIndicator("Typhoid Fever", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.TYPHOID_FEVER)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.16 Presumptive MDR TB cases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPresumptiveMdrTbCasesDiagnosis() {
		return cohortIndicator("Presumptive MDR TB cases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.PRESUMPTIVE_MDR_TB_CASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.1.17 Other Emerging infectious Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherEmergingInfectiousDiseasesDiagnosis() {
		return cohortIndicator("Other Emerging infectious Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_EMERGING_INFECTIOUS_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}

	/**
	 * 1.3.2.17 Acute Diarrhoea
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAcuteDiarrhoeaDiagnosis() {
		return cohortIndicator(
		    "Acute Diarrhoea ", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.ACUTE_DIARRHOEA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.18 Persistent Diarrhoea
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPersistentDiarrhoeaDiagnosis() {
		return cohortIndicator("Persistent Diarrhoea ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.PERSISTENT_DIARRHOEA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.19 Urethral discharges
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdUrethralDischargesDiagnosis() {
		return cohortIndicator("Urethral discharges ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.URETHRAL_DISCHARGES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.20 Genital ulcers
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdGenitalUlcersDiagnosis() {
		return cohortIndicator(
		    "Genital ulcers ", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.GENITAL_ULCERS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.21 Sexually Transmitted Infection due to Sexual Gender Based Violence
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSexuallyTransmittedInfectionDueToSexualGenderBasedViolenceDiagnosis() {
		return cohortIndicator(
		    "Sexually Transmitted Infection due to Sexual Gender Based Violence ", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(
		                Metadata.Concept.SEXUALLY_TRANSMITTED_INFECTION_DUE_TO_SEXUAL_GENDER_BASED_VIOLENCE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.22 Other Sexually Transmitted Infections
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherSexuallyTransmittedInfectionsDiagnosis() {
		return cohortIndicator("Other Sexually Transmitted Infections ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_SEXUALLY_TRANSMITTED_INFECTIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.23 Urinary Tract Infections
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdUrinaryTractInfectionsDiagnosis() {
		return cohortIndicator("Urinary Tract Infections ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.URINARY_TRACT_INFECTIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.24 Intestinal Worms
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdIntestinalWormsDiagnosis() {
		return cohortIndicator(
		    "Intestinal Worms ", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.INTESTINAL_WORMS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.25 Hematological Meningitis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHematologicalMeningitisDiagnosis() {
		return cohortIndicator("Hematological Meningitis ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.HEMATOLOGICAL_MENINGITIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.26 Other types of meningitis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherTypesOfMeningitisDiagnosis() {
		return cohortIndicator("Other types of meningitis ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_TYPES_OF_MENINGITIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.27 No pneumonia - Cough or cold
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNoPneumoniaCoughOrColdDiagnosis() {
		return cohortIndicator("No pneumonia - Cough or cold ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NO_PNEUMONIA__COUGH_OR_COLD)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.28 Pneumonia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPneumoniaDiagnosis() {
		return cohortIndicator("Pneumonia ", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.PNEUMONIA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.29 Skin Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSkinDiseasesDiagnosis() {
		return cohortIndicator(
		    "Skin Diseases ", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.SKIN_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.30 New TB cases diagnosed - Bacteriologically confirmed
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNewTbCasesDiagnosedBacteriologicallyConfirmedDiagnosis() {
		return cohortIndicator("New TB cases diagnosed - Bacteriologically confirmed ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEW_TB_CASES_DIAGNOSED__BACTERIOLOGICALLY_CONFIRMED)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.30 New TB cases diagnosed - Clinically Diagnosed
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNewTbCasesDiagnosedClinicallyDiagnosedDiagnosis() {
		return cohortIndicator("New TB cases diagnosed - Clinically Diagnosed ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEW_TB_CASES_DIAGNOSED__CLINICALLY_DIAGNOSED)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.30 New TB cases diagnosed - EPTB
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNewTbCasesDiagnosedEptbDiagnosis() {
		return cohortIndicator("New TB cases diagnosed - EPTB ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEW_TB_CASES_DIAGNOSED__EPTB)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.31 Leprosy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdLeprosyDiagnosis() {
		return cohortIndicator("Leprosy ", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.LEPROSY)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.32 Tuberculosis MDR/XDR cases started on treatment
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator tuberculosisMdrXdrCasesStartedOnTreatment() {
		return cohortIndicator("Tuberculosis MDR/XDR cases started on treatment ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TB_TREATMENT_OUTCOME),
		        Dictionary.getConcept(Metadata.Concept.TREATMENT_FAILURE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.33 Tetanus
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdTetanusDiagnosis() {
		return cohortIndicator("Tetanus ", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.TETANUS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.34 Sleeping sickness
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSleepingSicknessDiagnosis() {
		return cohortIndicator("Sleeping sickness ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.SLEEPING_SICKNESS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.35 Pelvic Inflammatory Disease
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPelvicInflammatoryDiseaseDiagnosis() {
		return cohortIndicator("Pelvic Inflammatory Disease ",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.PELVIC_INFLAMMATORY_DISEASE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.2.36 Brucellosis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdBrucellosisDiagnosis() {
		return cohortIndicator("Brucellosis ", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.BRUCELLOSIS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}

	/**
	 * 1.3.3.37 Neonatal Sepsis (0-7days)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalSepsis07DaysDiagnosis() {
		return cohortIndicator("Neonatal Sepsis (0-7days)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEONATAL_SEPSIS_07DAYS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.38 Neonatal Sepsis (8-28days)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalSepsis828DaysDiagnosis() {
		return cohortIndicator("Neonatal Sepsis (8-28days)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEONATAL_SEPSIS_828DAYS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.39 Neonatal Pneumonia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalPneumoniaDiagnosis() {
		return cohortIndicator("Neonatal Pneumonia",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEONATAL_PNEUMONIA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.40 Neonatal Meningitis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalMeningitisDiagnosis() {
		return cohortIndicator("Neonatal Meningitis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.NEONATAL_MENINGITIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.41 Neonatal Jaundice
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdNeonatalJaundiceDiagnosis() {
		return cohortIndicator(
		    "Neonatal Jaundice", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.NEONATAL_JAUNDICE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.42 Premature baby (as a condition for management)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPrematureBabyAsAConditionForManagementDiagnosis() {
		return cohortIndicator("Premature baby (as a condition for management)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.PREMATURE_BABY_AS_A_CONDITION_FOR_MANAGEMENT)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.3.43 Other Neonatal Conditions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherNeonatalConditionsDiagnosis() {
		return cohortIndicator("Other Neonatal Conditions",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_NEONATAL_CONDITIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.44 Sickle Cell Anaemia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSickleCellAnaemiaDiagnosis() {
		return cohortIndicator("Sickle Cell Anaemia",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.SICKLE_CELL_ANAEMIA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.45 Other types of Anaemia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherTypesOfAnaemiaDiagnosis() {
		return cohortIndicator("Other types of Anaemia",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_TYPES_OF_ANAEMIA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.46 Gastro-Intestinal Disorders (non-Infective)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdGastroIntestinalDisordersNonInfectiveDiagnosis() {
		return cohortIndicator("Gastro-Intestinal Disorders (non-Infective)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.GASTROINTESTINAL_DISORDERS_NONINFECTIVE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.47 Pain Requiring Palliative Care
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPainRequiringPalliativeCareDiagnosis() {
		return cohortIndicator("Pain Requiring Palliative Care",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.PAIN_REQUIRING_PALLIATIVE_CARE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.48 Dental Caries
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDentalCariesDiagnosis() {
		return cohortIndicator("Dental Caries", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DENTAL_CARIES)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.49 Gingivitis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdGingivitisDiagnosis() {
		return cohortIndicator("Gingivitis", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.GINGIVITIS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.50 HIV-Oral lesions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHivOralLesionsDiagnosis() {
		return cohortIndicator(
		    "HIV-Oral lesions", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConceptList(Metadata.Concept.ORAL_CANDIDIASIS + "," + Metadata.Concept.ORAL_HAIRY_LEUKOPLAKIA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.51 Oral Cancers
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOralCancersDiagnosis() {
		return cohortIndicator("Oral Cancers", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
	        Dictionary.getConceptList(Metadata.Concept.MALIGNANT_NEOPLASM_OF_ORAL_CAVITY + "," + Metadata.Concept.ORAL_NEOPLASM)),
	        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.52 Other Oral Conditions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherOralConditionsDiagnosis() {
		return cohortIndicator("Other Oral Conditions",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConceptList(Metadata.Concept.HERPETIFORM_APHTHOUS_STOMATITIS + "," + Metadata.Concept.APHTHOUS_ULCERATION + "," + Metadata.Concept.PERIADENITIS_MUCOSA_NECROTICA_RECURRENS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.53 Otitis media
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtitisMediaDiagnosis() {
		return cohortIndicator("Otitis media", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.OTITIS_MEDIA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.54 Hearing loss
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHearingLossDiagnosis() {
		return cohortIndicator("Hearing loss", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.HEARING_LOSS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.55 Other ENT conditions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherEntConditionsDiagnosis() {
		return cohortIndicator("Other ENT conditions",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_ENT_CONDITIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.56 Ophthalmia neonatorum
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOphthalmiaNeonatorumDiagnosis() {
		return cohortIndicator("Ophthalmia neonatorum",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OPHTHALMIA_NEONATORUM)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.57 Cataracts
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCataractsDiagnosis() {
		return cohortIndicator("Cataracts", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CATARACTS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.58 Refractive errors
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdRefractiveErrorsDiagnosis() {
		return cohortIndicator(
		    "Refractive errors", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.REFRACTIVE_ERRORS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.59 Glaucoma
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdGlaucomaDiagnosis() {
		return cohortIndicator("Glaucoma", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.GLAUCOMA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.60 Trachoma
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdTrachomaDiagnosis() {
		return cohortIndicator("Trachoma", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.TRACHOMA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.61 Tumors
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdTumorsDiagnosis() {
		return cohortIndicator("Tumors", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.TUMORS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.62 Blindness
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdBlindnessDiagnosis() {
		return cohortIndicator("Blindness", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.BLINDNESS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.63 Diabetic Retinopathy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDiabeticRetinopathyDiagnosis() {
		return cohortIndicator("Diabetic Retinopathy",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.DIABETIC_RETINOPATHY)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.64 Other eye conditions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherEyeConditionsDiagnosis() {
		return cohortIndicator("Other eye conditions",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_EYE_CONDITIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.65 Bipolar disorders
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdBipolarDisordersDiagnosis() {
		return cohortIndicator(
		    "Bipolar disorders", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.BIPOLAR_DISORDERS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.66 Depression
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDepressionDiagnosis() {
		return cohortIndicator("Depression", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DEPRESSION)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.67 Epilepsy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdEpilepsyDiagnosis() {
		return cohortIndicator("Epilepsy", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.EPILEPSY)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.68 Dementia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDementiaDiagnosis() {
		return cohortIndicator("Dementia", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DEMENTIA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.69 Childhood Mental Disorders
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdChildhoodMentalDisordersDiagnosis() {
		return cohortIndicator("Childhood Mental Disorders",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.CHILDHOOD_MENTAL_DISORDERS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.70 Schizophrenia
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSchizophreniaDiagnosis() {
		return cohortIndicator("Schizophrenia", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.SCHIZOPHRENIA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.71 HIV related psychosis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHivRelatedPsychosisDiagnosis() {
		return cohortIndicator("HIV related psychosis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.HIV_RELATED_PSYCHOSIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.72 Anxiety disorders
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnxietyDisordersDiagnosis() {
		return cohortIndicator(
		    "Anxiety disorders", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.ANXIETY_DISORDERS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.73 Alcohol abuse
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAlcoholAbuseDiagnosis() {
		return cohortIndicator("Alcohol abuse", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.ALCOHOL_ABUSE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.74 Drug abuse
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDrugAbuseDiagnosis() {
		return cohortIndicator("Drug abuse", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DRUG_ABUSE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.75 Other Mental Health Conditions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherMentalHealthConditionsDiagnosis() {
		return cohortIndicator("Other Mental Health Conditions",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_MENTAL_HEALTH_CONDITIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.76 Asthma
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAsthmaDiagnosis() {
		return cohortIndicator("Asthma", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.ASTHMA)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.77 Chronic Obstructive Pulmonary Disease (COPD)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdChronicObstructivePulmonaryDiseaseCopdDiagnosis() {
		return cohortIndicator("Chronic Obstructive Pulmonary Disease (COPD)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.CHRONIC_OBSTRUCTIVE_PULMONARY_DISEASE_COPD)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.78 Cancer Cervix
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerCervixDiagnosis() {
		return cohortIndicator("Cancer Cervix", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_CERVIX)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.79 Cancer Prostate
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerProstateDiagnosis() {
		return cohortIndicator(
		    "Cancer Prostate", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.CANCER_PROSTATE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.80 Cancer Breast
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerBreastDiagnosis() {
		return cohortIndicator("Cancer Breast", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_BREAST)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.81 Cancer Lung
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerLungDiagnosis() {
		return cohortIndicator("Cancer Lung", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_LUNG)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.82 Cancer Liver
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerLiverDiagnosis() {
		return cohortIndicator("Cancer Liver", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_LIVER)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.83 Cancer Colon
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerColonDiagnosis() {
		return cohortIndicator("Cancer Colon", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_COLON)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.84 Kaposis Sarcoma
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdKaposisSarcomaDiagnosis() {
		return cohortIndicator(
		    "Kaposis Sarcoma", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.KAPOSIS_SARCOMA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.85 Cancer Others
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCancerOthersDiagnosis() {
		return cohortIndicator("Cancer Others", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.CANCER_OTHERS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.86 Cardiovascular Accident
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdCardiovascularAccidentDiagnosis() {
		return cohortIndicator("Cardiovascular Accident",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.CARDIOVASCULAR_ACCIDENT)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.87 Hypertension
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHypertensionDiagnosis() {
		return cohortIndicator("Hypertension", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.HYPERTENSION)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.88 Heart failure
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHeartFailureDiagnosis() {
		return cohortIndicator("Heart failure", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.HEART_FAILURE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.89 Ischemic Heart Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdIschemicHeartDiseasesDiagnosis() {
		return cohortIndicator("Ischemic Heart Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ISCHEMIC_HEART_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.88 Rheumatic Heart Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdRheumaticHeartDiseasesDiagnosis() {
		return cohortIndicator("Rheumatic Heart Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.RHEUMATIC_HEART_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.90 Chronic Heart Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdChronicHeartDiseasesDiagnosis() {
		return cohortIndicator("Chronic Heart Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.CHRONIC_HEART_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.91 Other Cardiovascular Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherCardiovascularDiseasesDiagnosis() {
		return cohortIndicator("Other Cardiovascular Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_CARDIOVASCULAR_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.92 Diabetes mellitus
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDiabetesMellitusDiagnosis() {
		return cohortIndicator(
		    "Diabetes mellitus", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.DIABETES_MELLITUS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.93 Thyroid Disease
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdThyroidDiseaseDiagnosis() {
		return cohortIndicator(
		    "Thyroid Disease", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.THYROID_DISEASE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.94 Other Endocrine and Metabolic Diseases
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherEndocrineAndMetabolicDiseasesDiagnosis() {
		return cohortIndicator("Other Endocrine and Metabolic Diseases",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_ENDOCRINE_AND_METABOLIC_DISEASES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.95 Severe Acute Malnutrition with oedema
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSevereAcuteMalnutritionWithOedemaDiagnosis() {
		return cohortIndicator("Severe Acute Malnutrition with oedema",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.SEVERE_ACUTE_MALNUTRITION_WITH_OEDEMA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.95 Severe Acute Malnutrition Without oedema
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSevereAcuteMalnutritionWithoutOedemaDiagnosis() {
		return cohortIndicator("Severe Acute Malnutrition Without oedema",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.SEVERE_ACUTE_MALNUTRITION_WITHOUT_OEDEMA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.96 Mild Acute Malnutrition
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdMildAcuteMalnutritionDiagnosis() {
		return cohortIndicator("Mild Acute Malnutrition",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.MILD_ACUTE_MALNUTRITION)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.97 Jaw injuries
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdJawInjuriesDiagnosis() {
		return cohortIndicator("Jaw injuries", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.JAW_INJURIES)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.98 Injuries- Road traffic Accidents
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdInjuriesRoadTrafficAccidentsDiagnosis() {
		return cohortIndicator("Injuries- Road traffic Accidents",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.INJURIES_ROAD_TRAFFIC_ACCIDENTS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.99 Injuries due to motorcycle(boda-boda)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdInjuriesDueToMotorcyclebodaBodaDiagnosis() {
		return cohortIndicator("Injuries due to motorcycle(boda-boda)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.INJURIES_DUE_TO_MOTORCYCLEBODABODA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.100 Injuries due to Gender based violence
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdInjuriesDueToGenderBasedViolenceDiagnosis() {
		return cohortIndicator("Injuries due to Gender based violence",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.INJURIES_DUE_TO_GENDER_BASED_VIOLENCE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.101 Injuries (Trauma due to other causes)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdInjuriesTraumaDueToOtherCausesDiagnosis() {
		return cohortIndicator("Injuries (Trauma due to other causes)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.INJURIES_TRAUMA_DUE_TO_OTHER_CAUSES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.102 Animal bites Domestic
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnimalBitesDomesticDiagnosis() {
		return cohortIndicator("Animal bites Domestic",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ANIMAL_BITES_DOMESTIC)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.102 Animal bites Wild
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnimalBitesWildDiagnosis() {
		return cohortIndicator(
		    "Animal bites Wild", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.ANIMAL_BITES_WILD)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.102 Animal bites Insects
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnimalBitesInsectsDiagnosis() {
		return cohortIndicator("Animal bites Insects",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ANIMAL_BITES_INSECTS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	/**
	 * 1.3.4.102 Animal bites Insects
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAnimalBitesSuspectedRabiesDiagnosis() {
		return cohortIndicator("Animal bites Insects",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.DOG_BITE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.4.103 Snake bites
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdSnakeBitesDiagnosis() {
		return cohortIndicator("Snake bites", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.SNAKE_BITES)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.5.104 Tooth extractions
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdToothExtractionsDiagnosis() {
		return cohortIndicator(
		    "Tooth extractions", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.TOOTH_EXTRACTIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.5.105 Dental Fillings
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDentalFillingsDiagnosis() {
		return cohortIndicator(
		    "Dental Fillings", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.DENTAL_FILLINGS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.5.106 Other Minor Operations
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherMinorOperationsDiagnosis() {
		return cohortIndicator("Other Minor Operations",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.OTHER_MINOR_OPERATIONS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.107 Leishmaniasis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdLeishmaniasisDiagnosis() {
		return cohortIndicator("Leishmaniasis", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.LEISHMANIASIS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.108 Lymphatic Filariasis (hydrocele)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdLymphaticFilariasisHydroceleDiagnosis() {
		return cohortIndicator("Lymphatic Filariasis (hydrocele)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.LYMPHATIC_FILARIASIS_HYDROCELE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.109 Lymphatic Filariasis (Lympoedema)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdLymphaticFilariasisLympoedemaDiagnosis() {
		return cohortIndicator("Lymphatic Filariasis (Lympoedema)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.LYMPHATIC_FILARIASIS_LYMPOEDEMA)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.110 Urinary Schistosomiasis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdUrinarySchistosomiasisDiagnosis() {
		return cohortIndicator("Urinary Schistosomiasis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.URINARY_SCHISTOSOMIASIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.111 Intestinal Schistosomiasis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdIntestinalSchistosomiasisDiagnosis() {
		return cohortIndicator("Intestinal Schistosomiasis",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.INTESTINAL_SCHISTOSOMIASIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.6.112 Onchocerciasis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOnchocerciasisDiagnosis() {
		return cohortIndicator(
		    "Onchocerciasis", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.ONCHOCERCIASIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.113 Abortions due to Gender-Based Violence (GBV)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAbortionsDueToGenderBasedViolenceGbvDiagnosis() {
		return cohortIndicator("Abortions due to Gender-Based Violence (GBV)",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ABORTIONS_DUE_TO_GENDERBASED_VIOLENCE_GBV)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.114 Abortions due to other causes
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAbortionsDueToOtherCausesDiagnosis() {
		return cohortIndicator("Abortions due to other causes",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.ABORTIONS_DUE_TO_OTHER_CAUSES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.115 Malaria in pregnancy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdMalariaInPregnancyDiagnosis() {
		return cohortIndicator("Malaria in pregnancy",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.MALARIA_IN_PREGNANCY)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.116 High blood pressure in pregnancy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHighBloodPressureInPregnancyDiagnosis() {
		return cohortIndicator("High blood pressure in pregnancy",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConcept(Metadata.Concept.HIGH_BLOOD_PRESSURE_IN_PREGNANCY)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.117 Obstructed labour
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdObstructedLabourDiagnosis() {
		return cohortIndicator(
		    "Obstructed labour", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.OBSTRUCTED_LABOUR)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.118 Puerperal sepsis
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdPuerperalSepsisDiagnosis() {
		return cohortIndicator(
		    "Puerperal sepsis", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.PUERPERAL_SEPSIS)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.7.119 Haemorrhage related to pregnancy
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdHaemorrhageRelatedToPregnancyDiagnosis() {
		return cohortIndicator("Haemorrhage related to pregnancy",
		    map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		        Dictionary.getConceptList(Metadata.Concept.ANTEPARTUM_HAEMORRHAGE + "," + Metadata.Concept.POSTPARTUM_HAEMORRHAGE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.8.120 Other diagnoses
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdOtherDiagnosesDiagnosis() {
		return cohortIndicator(
		    "Other diagnoses", map(
		        cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		            Dictionary.getConcept(Metadata.Concept.OTHER_DIAGNOSES)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.8.121 Deaths in OPD
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdDeathsInOpdDiagnosis() {
		return cohortIndicator("Deaths in OPD", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConcept(Metadata.Concept.DEATHS_IN_OPD)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.8.122 All others
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator opdAllOthersDiagnosis() {
		return cohortIndicator("All others", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS),
		    Dictionary.getConceptList(Metadata.Concept.OTHERS_NON_CODED + "," + Metadata.Concept.OTHER_SPECIFY)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}

	/**
	 * All diagnoses
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator allDiagnoses() {
		return cohortIndicator("All diagnoses", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.OPD_DIAGNOSIS)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	//End Outpatient Diagnosis
	
	/**
	 * 1.3.9.R1 Alcohol use
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator alcoholUsers() {
		return cohortIndicator("Alcohol use", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.ALCOHOL_USE),
		    Dictionary.getConcept(Metadata.Concept.YES_CIEL)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.9.R2 Tobacco use
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator tobaccoUsers() {
		return cohortIndicator("Tobacco use", map(cclibrary.hasObs(Dictionary.getConcept(Metadata.Concept.TOBACCO_USE),
		    Dictionary.getConcept(Metadata.Concept.YES_CIEL)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.10.B1 Severely Underweight (BMI<16)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator severelyUnderweightBmi() {
		return cohortIndicator("Severely Underweight (BMI<16)",
		    map(cohortLibrary.bmiCount(0.0, 15.9), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.10.B2 Underweight (16<=BMI <18.5)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator underweightBmi() {
		return cohortIndicator("Underweight (16<=BMI <18.5)",
		    map(cohortLibrary.bmiCount(16.0, 18.4), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.10.B3 Normal (18.5<= BMI <=25)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator normalBmi() {
		return cohortIndicator("Normal (18.5<= BMI <=25)",
		    map(cohortLibrary.bmiCount(18.5, 25.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.10.B4 Over weight (25< BMI <=30
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator overweightBmi() {
		return cohortIndicator("Over weight (25< BMI <=30",
		    map(cohortLibrary.bmiCount(24.9, 30.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * 1.3.10.B5 Obese ( BMI>30)
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator obeseBmi() {
		return cohortIndicator("Obese ( BMI>30)",
		    map(cohortLibrary.bmiCount(30.1, 100.0), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
    
	/**
	 * HIV Exposed Infants - EID
	 */
	
	/**
	 * E1A Exposed infants tested for HIV below 18 months of age - 1st PCR
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator exposedInfantsTestedForHivBelow18MonthsOfAge1StPcr() {
		return cohortIndicator("Exposed infants tested for HIV below 18 months of age - 1st PCR",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID, Dictionary.getConcept(Metadata.Concept.DATE_OF_FIRST_PCR_TEST)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E1B Exposed infants tested for HIV below 18 months of age - 2nd PCR
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator exposedInfantsTestedForHivBelow18MonthsOfAge2NdPcr() {
		return cohortIndicator("Exposed infants tested for HIV below 18 months of age - 2nd PCR",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID, Dictionary.getConcept(Metadata.Concept.DATE_OF_SECOND_PCR_TEST)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E1C Exposed infants tested for HIV below 18 months of age - 18month rapid test
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator exposedInfantsTestedForHivBelow18MonthsOfAge18MonthRapidTest() {
		return cohortIndicator("Exposed infants tested for HIV below 18 months of age - 18month rapid test",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID,
		        Dictionary.getConcept(Metadata.Concept.DATE_OF_18_MONTH_RAPID_PCR_TEST)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E2A 1st DNA PCR result returned
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator firstDnaPcrResultReturned() {
		return cohortIndicator("1st DNA PCR result returned",
		    map(cohortLibrary.firstDnaPCRResultsReturnedFromTheLab(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E2B 1st DNA PCR result returned - HIV+
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator firstDnaPcrResultReturnedHivPositive() {
		return cohortIndicator("1st DNA PCR result returned - HIV+",
		    map(cohortLibrary.firstDnaPCRResultsReturnedFromTheLabHivPositive(),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E3A 2nd DNA PCR result returned
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator secondDnaPcrResultReturned() {
		return cohortIndicator("2nd DNA PCR result returned",
		    map(cohortLibrary.secondDnaPCRResultsReturnedFromTheLab(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E3B 2nd DNA PCR result returned - HIV+
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator secondDnaPcrResultReturnedHivPositive() {
		return cohortIndicator("2nd DNA PCR result returned - HIV+",
		    map(cohortLibrary.secondDnaPCRResultsReturnedFromTheLabHivPositive(),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E4A Number of DNA PCR results returned from the lab
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator numberOfDnaPcrResultsReturnedFromTheLab() {
		return cohortIndicator("Number of DNA PCR results returned from the lab",
		    map(cohortLibrary.dnaPcrResultsReturnedFromTheLab(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E4B Number of DNA PCR results returned from the lab - given to care giver
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator dnaPcrResultsReturnedFromTheLabGivenToCareGiver() {
		return cohortIndicator("Number of DNA PCR results returned from the lab - given to care giver",
		    map(cohortLibrary.dnaPcrResultsReturnedFromTheLabGivenToCareGiver(),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E5A Number of HIV Exposed infants tested by serology/rapidHIV test at 18 months
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator hivExposedInfantsTestedBySerologyRapidhivTestAt18Months() {
		return cohortIndicator("Number of HIV Exposed infants tested by serology/rapidHIV test at 18 months",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID,
		        Dictionary.getConcept(Metadata.Concept.RAPID_HIV_TEST_AT_18_MONTHS_DATE)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E5B Number of HIV Exposed infants tested by serology/rapidHIV test at 18 months - HIV+
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator hivExposedInfantsTestedBySerologyRapidhivTestAt18MonthsHivPositive() {
		return cohortIndicator("Number of HIV Exposed infants tested by serology/rapidHIV test at 18 months - HIV+",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID,
		        Dictionary.getConcept(Metadata.Concept.RAPID_HIV_TEST_AT_18_MONTHS_TEST_RESULT),
		        Dictionary.getConcept(Metadata.Concept.POSITIVE)), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E6A Number of HIV+ infants from EID enrolled in care
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator hivPositiveInfantsFromEidEnrolledInCare() {
		return cohortIndicator("Number of HIV+ infants from EID enrolled in care",
		    map(cohortLibrary.hivPositiveInfantsFromEidEnrolledInCare(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * E7 HIV exposed infants started on CPT
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator hivExposedInfantsStartedOnCpt() {
		return cohortIndicator("HIV exposed infants started on CPT",
		    map(cohortLibrary.hasObsAndEncounter(EID_UUID, Dictionary.getConcept(Metadata.Concept.STARTED_ON_CPT)),
		        "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	/**
	 * Tetanus Immunization dose
	 * 
	 * @return CohortIndicator
	 */
	public CohortIndicator tetanusImmunizationsDone(int doseNumber, boolean pregnant) {
		return cohortIndicator("Tetanus Immunization dose. Dose# " + doseNumber,
		    map(cohortLibrary.tetanusImmunizationsDone(doseNumber, pregnant), "onOrAfter=${startDate},onOrBefore=${endDate}"));
	}
	
	//indicators for the SMC section follow here

    /**
     * counselled and tested for HIV with results
     * @return CohortIndicator
     */
    public CohortIndicator counseledAndTestedWithResuls(Concept ans) {
        return cohortIndicator("Counseled and tested with results", map(cohortLibrary.counseledTestedForHivResults(ans), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * counselled and tested for HIV regardless of the results
     * @return CohortIndicator
     */
    public CohortIndicator counseledAndTested() {
        return cohortIndicator("Counseled and tested", map(cohortLibrary.counseledTestedForHiv(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * expected number of SMC performed(monthly targets)
     * @return cohort indicator
     */
    public CohortIndicator expectedNumberOfSmcPerfomed() {
        EncounterType smc = MetadataUtils.existing(EncounterType.class, "244da86d-f80e-48fe-aba9-067f241905ee");
        return cohortIndicator("expected number of SMC performed", map(cclibrary.hasEncounter(smc), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * Clients circumcised who experinced one or more adverse events
     * @return CohortIndicator
     */
    public CohortIndicator circumcisedAndExperiencedAdverseEvents(Concept ... ans){
        Concept adQuestion = Dictionary.getConcept("e34976b9-1aff-489d-b959-4da1f7272499");
        return cohortIndicator("circumcised and AE", map(cclibrary.hasObs(adQuestion, ans), "onOrAfter=${startDate},onOrBefore=${endDate}"));

    }

    /**
     * Clients circumcised by used Technique
     * @return CohortIndicator
     */
    public CohortIndicator clientsCircumcisedWithTechnique(Concept ... ans) {
        Concept techQuestion = Dictionary.getConcept("bd66b11f-04d9-46ed-a367-2c27c15d5c71");
        return cohortIndicator("circumcised and AE", map(cclibrary.hasObs(techQuestion, ans), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }
    
    /**
     * Clients circumcised by used surgical Technique
     * @return CohortIndicator
     */
    public CohortIndicator clientsCircumcisedWithSurgicalTechnique() {
        return cohortIndicator("circumcised and AE", map(cohortLibrary.surgicalProcedureMethod(), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }

    /**
     * follow up visits in SMC
     * @return CohortIndicator
     */
    public CohortIndicator smcFollowUps(int visit){
        return cohortIndicator("follow up visits", map(cohortLibrary.clientsCircumcisedAndReturnedWithin6WeeksAndHaveSmcEncounter(visit), "onOrAfter=${startDate},onOrBefore=${endDate}"));
    }



}
