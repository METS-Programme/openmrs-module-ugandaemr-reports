package org.openmrs.module.ugandaemrreports.metadata;

import org.openmrs.Concept;
import org.openmrs.EncounterType;
import org.openmrs.PatientIdentifierType;
import org.openmrs.Program;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.ugandaemrreports.library.CommonDimensionLibrary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Metadata definitions for the HIV related reporting
 */
@Component("hivMetadata")
public class HIVMetadata extends Metadata {

    @Autowired
    CommonDimensionLibrary commonDimensionLibrary;

    public Concept getReturnVisitDate() {
        return getConcept("dcac04cf-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getArtStartDate() {
        return getConcept("ab505422-26d9-41f1-a079-c3d222000440");
    }

    public Concept getViralLoadQualitative() {
        return getConcept("dca12261-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getArtRegimenTransferInDate() {
        return getConcept("f363f153-f659-438b-802f-9cc1828b5fa9");
    }

    public Concept getArtStartRegimen() {
        return getConcept("c3332e8d-2548-4ad6-931d-6855692694a3");
    }

    public Concept getOtherArtStartRegimen() {
        return getConcept("cc3d64df-61a5-4c5a-a755-6e95d6ef3295");
    }

    public Concept getArtTransferInRegimen() {
        return getConcept("9a9314ed-0756-45d0-b37c-ace720ca439c");
    }

    public Concept getOtherArtTransferInRegimen() {
        return getConcept("a5bfc18e-c6db-4d5d-81f5-18d61b1355a8");
    }

    public Concept getDateOfNVP() {
        return getConcept("4d667898-fc8d-4df5-add4-1b9ca84ca7ea");
    }

    public Concept getDateOfCPT() {
        return getConcept("e4ca65ac-dc1d-485d-bdb2-b73c2f892aca");
    }
    
    public Concept getExposedInfantMotherARTNumber() {
        return getConcept("85097a99-4126-4ad3-894e-25c1a7e91dee");
    }
    
    public Concept getFirstPCRTestDate() {
        return getConcept("51941f01-307f-44ca-9351-401bc008a208");
    }

    public Concept getSecondPCRTestDate() {
        return getConcept("1f627527-2f97-4f21-9b61-2b79d887950f");
    }

    public Concept getRepeatPCRTestDate() {
        return getConcept("4092ad52-3db3-47f5-b497-126e1202f1eb");
    }

    public Concept get18MonthsRapidPCRTestDate() {
        return getConcept("7065b181-abb0-4ad6-8082-62e99398f735");
    }

    public Concept getFirstPCRTestResultGivenToCareProviderDate() {
        return getConcept("f4d8932c-2b95-46c5-8aac-1fc345c3f01f");
    }

    public Concept getSecondPCRTestResultGivenToCareProviderDate() {
        return getConcept("358cbf29-0d6f-4be0-9af4-5844049d5f28");
    }

    public Concept getRepeatPCRTestResultGivenToCareProviderDate() {
        return getConcept("4f3b7c47-d931-4d65-b8a2-3486d083e919");
    }

    public Concept get18MonthsRapidPCRTestResultGivenToCareProviderDate() {
        return getConcept("852eb620-6705-4a15-b43e-ba1c384fe5ce");
    }

    public Concept getFirstPCRTestResults() {
        return getConcept("b6a6210b-ccdf-45fc-80dd-1567f65e2d98");
    }

    public Concept getSecondPCRTestResults() {
        return getConcept("e1b4efbf-0dff-4e9e-a2f2-34edcb02a5d0");
    }

    public Concept getRepeatPCRTestResults() {
        return getConcept("ee19527f-8b98-4345-b378-b963ea6dc4e0");
    }

    public Concept get18MonthsRapidPCRTestResults() {
        return getConcept("71e135e8-cf63-4031-adc7-09a0a9b61c33");
    }

    public Concept getPositiveResult() {
        return getConcept("dc866728-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getNegativeResult() {
        return getConcept("dc85aa72-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFinalStatus() {
        return getConcept("977b16f4-2d3e-40d2-ba51-54794c98f7ef");
    }

    public Concept getFinalOutcome() {
        return getConcept("2099355c-ceb2-482e-9a81-536890ab3d1c");
    }

    public Concept getFinalOutcomeDischargedNegative() {
        return getConcept("98a22314-f091-4661-96a6-45f1b4d56e10");
    }

    public Concept getFinalOutcomeReferredToArtClinic() {
        return getConcept("5d6caa50-7dc9-44c3-aa15-be14300f7045");
    }

    public Concept getFinalOutcomeLost() {
        return getConcept("dcb23465-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFinalOutcomeDied() {
        return getConcept("9d2ff8e6-c6e9-4d62-a103-1bda37cef8c8");
    }

    public PatientIdentifierType getPatientsWithEIDIdentifier() {
        return getPatientIdentifierType("2c5b695d-4bf3-452f-8a7c-fe3ee3432ffe");
    }

    public PatientIdentifierType getHIVIdentifier() {
        return getPatientIdentifierType("e1731641-30ab-102d-86b0-7a5022ba4115");
    }

    public List<EncounterType> getARTSummaryPageEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "8d5b27bc-c2cc-11de-8d13-0010c6dffd0f"));
        return l;
    }

    public List<EncounterType> getARTEncounterPageEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f"));
        return l;
    }

    public List<EncounterType> getMissedAppointmentRegisterEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "791faefd-36b8-482f-ab78-20c297b03851"));
        return l;
    }

    public List<EncounterType> getEIDSummaryPageEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "9fcfcc91-ad60-4d84-9710-11cc25258719"));
        return l;
    }
    
    public List<EncounterType> getEIDEncounterPageEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "4345dacb-909d-429c-99aa-045f2db77e2b"));
        return l;
    }

    public List<EncounterType> getHCTEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "264daIZd-f80e-48fe-nba9-P37f2W1905Pv"));
        return l;
    }

    public List<EncounterType> getMissedAppointmentEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "791faefd-36b8-482f-ab78-20c297b03851"));
        return l;
    }

    public List<Concept> getNoClinicalContactOutcomes(){
        return getConceptList("dca26b47-30ab-102d-86b0-7a5022ba4115,160034AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,f57b1500-7ff2-46b4-b183-fed5bce479a9,8b386488-9494-4bb6-9537-dcad6030fab0,1a467610-b640-4d9b-bc13-d2631fa57a45,b192a41c-f7e8-47a9-89c5-62e7a4bffddd,e063241f-5a50-4fea-9bce-d1bf8332f081");
    }

    public List<EncounterType> getArtEncounterTypes() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "8d5b27bc-c2cc-11de-8d13-0010c6dffd0f"));
        l.add(MetadataUtils.existing(EncounterType.class, "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f"));
        return l;
    }

    public List<EncounterType> getMedicationDispensingEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "22902411-19c1-4a02-b19a-bf1a9c24fd51"));
        return l;
    }

    public Concept getARVDuration() {
        return getConcept("7593ede6-6574-4326-a8a6-3d742e843659");
    }

    public Concept getCurrentRegimen() {
        return getConcept("dd2b0b4d-30ab-102d-86b0-7a5022ba4115");
    }
    public Concept getCurrentViralLoad() {
        return getConcept("dc8d83e3-30ab-102d-86b0-7a5022ba4115");
    }
    public Concept getTransferIn() {
        return getConcept("ea730d69-7eec-486a-aaf2-54f8bab5a44c");
    }
    public Concept getYes() {
        return getConcept("dcd695dc-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getEntryPoint() {
        return getConcept("dcdfe3ce-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getPCRAtEnrollment() {
        return getConcept("14924d56-8841-4d96-a9bb-8daaeaacea17");
    }

    public Concept getLactatingAtEnrollment() {
        return getConcept("9e5ac0a8-6041-4feb-8c07-fe522ef5f9ab");
    }

    public Concept getEMTCTAtEnrollment() {
        return getConcept("dcd7e8e5-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getPregnantAtEnrollment() {
        return getConcept("63d67ada-bb8a-4ba0-a2a0-c60c9b7a00ce");
    }

    public Concept getTransferInAtEnrollment() {
        return getConcept("ea730d69-7eec-486a-aaf2-54f8bab5a44c");
    }

    public Concept getCPTDosage() {
        return getConcept("38801143-01ac-4328-b0e1-a7b23c84c8a3");
    }

    public Concept getINHDosage() {
        return getConcept("be211d29-1507-4e2e-9906-4bfeae4ddc1f");
    }

    public Concept getDistrictTBNo() {
        return getConcept("67e9ec2f-4c72-408b-8122-3706909d77ec");
    }

    public Concept getTBStartDate() {
        return getConcept("dce02eca-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFluconazoleStartDate() {
        return getConcept("539a716b-4e1b-4a99-ad1d-f4e3a09a75ae");
    }

    public Concept getTBStopDate() {
        return getConcept("dd2adde2-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getWHOClinicalStage() {
        return getConcept("dcdff274-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getBaselineWHOClinicalStage() {
        return getConcept("39243cef-b375-44b1-9e79-cbf21bd10878");
    }

    public Concept getWHOClinicalStage1() {
        return getConcept("dcda2bc2-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getWHOClinicalStage2() {
        return getConcept("dcda3251-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getWHOClinicalStage3() {
        return getConcept("dcda3663-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getWHOClinicalStage4() {
        return getConcept("dcda3a80-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getDateEligibleForART() {
        return getConcept("dd26a79f-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getDateEligibleAndReadyForART() {
        return getConcept("dd26d94b-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getDateEligibilityWHOStage() {
        return getConcept("1ae5db56-256c-4a16-a0c0-1bb3e2dcaeed");
    }

    public Concept getDateEligibilityTB() {
        return getConcept("fe73fd9b-20bd-460c-bb46-1ed33f28ef47");
    }

    public Concept getCD4AtEnrollment() {
        return getConcept("6f10ef21-4bb2-4c84-856f-5b05264dcc99");
    }

    public Concept getBaselineCD4() {
        return getConcept("c17bd9df-23e6-4e65-ba42-eb6d9250ca3f");
    }  // CD4 at ART start

    public EncounterType getARTSummaryEncounter() {
        return getEncounterType("8d5b27bc-c2cc-11de-8d13-0010c6dffd0f");
    }

    public EncounterType getARTEncounterEncounterType() {
        return getEncounterType("8d5b2be0-c2cc-11de-8d13-0010c6dffd0f");
    }

    public Concept getTBStatus() {
        return getConcept("dce02aa1-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getTBStatusDiagnosed() {
        return getConcept("dcdac38b-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getTBStatusNoSignsOrSymptoms() {
        return getConcept("dcdaccc1-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getTBStatusRx() {
        return getConcept("dcdaa6b4-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getMalnutrition() {
        return getConcept("dc655734-30ab-102d-86b0-7a5022ba4115");
    }
    public Concept getNutritionStatus() {
        return getConcept("165050AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    }

    public Concept getMUAC() {
        return getConcept("5f86d19d-9546-4466-89c0-6f80c101191b");
    }

    public Concept getBodyWeight() {
        return getConcept("dce09e2f-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getBaselineBodyWeight() {
        return getConcept("900b8fd9-2039-4efc-897b-9b8ce37396f5");
    }

    public Concept getBodyHeight() {
        return getConcept("5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    }

    public Concept getOedema() {
        return getConcept("460AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    }

    public Concept getMUACRed() {
        return getConcept("de330d01-5586-4eed-a645-e04b6bd13701");
    }

    public Concept getMUACYellow() {
        return getConcept("a3b1734c-4743-4b9d-8e71-08d0459d29b9");
    }

    public Concept getPregnantAtArtStart() {
        return getConcept("b253be65-0155-4b43-ad15-88bc797322c9");
    }

    public Concept getLactatingAtArtStart() {
        return getConcept("ab7bb4db-1a54-4225-b71c-d8e138b471e9");
    }

    public Concept getAdherence() {
        return getConcept("dce03b2f-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getGoodAdherence() {
        return getConcept("dcdf1708-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFairAdherence() {
        return getConcept("dcdf1b36-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getPoorAdherence() {
        return getConcept("dcdf1f4a-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getMalnutritionYes() {
        return getConceptList("267a937a-f03c-487b-963c-1858f1382a5a,a4543170-8155-41c7-b618-da6962b81f45,e4d7bc04-14e6-4ed2-a0d8-1ad85314b071");
    }

    public List<Concept> getFirstLineDrugsChildren() {
        return getConceptList("012a1378-b005-4793-8ea0-d01fceea769d,dd2b361c-30ab-102d-86b0-7a5022ba4115,dd2b3eee-30ab-102d-86b0-7a5022ba4115,25b0b83c-a7b8-4663-b727-0c03c982bab2,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,6cdbfee8-87bf-406c-8dc3-3a22d95e952c,583a954b-0cd5-4b69-aef6-87c281e03a55,14c56659-3d4e-4b88-b3ff-e2d43dbfb865,a58d12c5-abc2-4575-8fdb-f30960f348fc,6cc36637-596a-4426-92cf-170f76ea437d,a779d984-9ccf-4424-a750-47506bf8212b");
    }

    public List<Concept> getFirstLineDrugsAdults() {
        return getConceptList("dd2b361c-30ab-102d-86b0-7a5022ba4115,dd2b3eee-30ab-102d-86b0-7a5022ba4115,012a1378-b005-4793-8ea0-d01fceea769d,25b0b83c-a7b8-4663-b727-0c03c982bab2,a58d12c5-abc2-4575-8fdb-f30960f348fc,6cc36637-596a-4426-92cf-170f76ea437d,a779d984-9ccf-4424-a750-47506bf8212b");
    }

    public List<Concept> getFirstLineDrugsAdult() {
        return getConceptList("dd2b361c-30ab-102d-86b0-7a5022ba4115,dd2b3eee-30ab-102d-86b0-7a5022ba4115,012a1378-b005-4793-8ea0-d01fceea769d,25b0b83c-a7b8-4663-b727-0c03c982bab2,b3bd1d21-aa40-4e8a-959f-2903b358069c,6cdbfee8-87bf-406c-8dc3-3a22d95e952c,583a954b-0cd5-4b69-aef6-87c281e03a55,dcd68a88-30ab-102d-86b0-7a5022ba4115,a58d12c5-abc2-4575-8fdb-f30960f348fc,6cc36637-596a-4426-92cf-170f76ea437d,a779d984-9ccf-4424-a750-47506bf8212b"); // Last Concept is Other Specify which includes any unknown drugs
    }

    public Concept getDirectionsToAddress()
    {
        return  getConcept("dce122f3-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getSecondLineDrugsChildren() {
        return getConceptList("4b9c639e-3d06-4f2a-9c34-dd07e44f4fa6,d4393bd0-3a9e-4716-8968-1057c58c32bc,25186d70-ed8f-486c-83e5-fc31cbe95630");
    }

    public List<Concept> getSecondLineDrugsAdults() {
        return getConceptList("4b9c639e-3d06-4f2a-9c34-dd07e44f4fa6,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,d4393bd0-3a9e-4716-8968-1057c58c32bc,fe78521e-eb7a-440f-912d-0eb9bf2d4b2c,25186d70-ed8f-486c-83e5-fc31cbe95630,14c56659-3d4e-4b88-b3ff-e2d43dbfb865");
    }

    public List<Concept> getSecondLineDrugsAdult() {
        return getConceptList("dd2b9181-30ab-102d-86b0-7a5022ba4115,dd2b97d3-30ab-102d-86b0-7a5022ba4115,dd2b9e11-30ab-102d-86b0-7a5022ba4115,4b9c639e-3d06-4f2a-9c34-dd07e44f4fa6,4a608d68-516f-44d2-9e0b-1783dc0d870e,f30e9dae-cc6a-4669-98d5-ad25b8a3ce9c,834625e9-3273-445e-be99-2beca081702c,f00e5ff7-73bb-4385-8ee1-ea7aa772ec3e,faf13d3c-7ca8-4995-ab29-749f3960b83d,d4393bd0-3a9e-4716-8968-1057c58c32bc,fe78521e-eb7a-440f-912d-0eb9bf2d4b2c,25186d70-ed8f-486c-83e5-fc31cbe95630");
    }

    public List<Concept> getThirdLineDrugs() {
        return getConceptList("607ffca4-6f15-4e85-b0a5-8226d4f25592,4c27fe52-98fd-4068-9e81-ea9caba4b583");
    }

    public Concept getTransferredOut() {
        return getConcept("dd27a783-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getTransferredOutDate() {
        return getConcept("fc1b1e96-4afb-423b-87e5-bb80d451c967");
    }

    public Concept getTransferredOutPlace() {
        return getConcept("dce015bb-30ab-102d-86b0-7a5022ba4115");
    }
    

    public Concept getArtInterruption() {
        return getConcept("4212962f-437a-4723-b4bd-3ce69fe0aac9");
    }

    public Concept getArtInterruptionStopped() {
        return getConcept("dca26b47-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getDead() {
        return getConcept("dce015bb-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getYesPregnant() {
        return getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    }

    public Concept getPregnant() {
        return getConcept("dcda5179-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getCD4() {
        return getConcept("dcbcba2c-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getTransferInPlace() {
        return getConcept("dcdffef2-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFunctionalStatusConcept() {
        return getConcept("dce09a15-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getViralLoad() {
        return getConcept("dc8d83e3-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getEDD() {
        return getConcept("dcc033e5-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getFirstLineSubstitutionDate() {
        return getConcept("f285db91-3204-40d1-93d9-83f4ec6cc2a6");
    }

    public Concept getSubstitutionReason() {
        return getConcept("dce0c977-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages() {
        return getConceptList("dc9b8cd1-30ab-102d-86b0-7a5022ba4115,dc9b9113-30ab-102d-86b0-7a5022ba4115,dc9b9549-30ab-102d-86b0-7a5022ba4115,dc9b999b-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages1() {
        return getConceptList("dc9b8cd1-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages2() {
        return getConceptList("dc9b9113-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages3() {
        return getConceptList("dc9b9549-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages4() {
        return getConceptList("dc9b999b-30ab-102d-86b0-7a5022ba4115");
    }

    public List<Concept> getBaselineClinicalStages12() {
        return getConceptList("dc9b8cd1-30ab-102d-86b0-7a5022ba4115,dc9b9113-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getViralLoadDate() {
        return getConcept("0b434cfa-b11c-4d14-aaa2-9aed6ca2da88");
    }

    public Concept getViralLoadDetection() {
        return getConcept("dca12261-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getViralLoadCopies() {
        return getConcept("dc8d83e3-30ab-102d-86b0-7a5022ba4115");
    }
	
	public Concept getBreastFeedingStatus() {
        return getConcept("151283c0-8ef7-442f-8b03-3d7382a9d9cd");
	}
	
	public Concept getBreastFeedingStatusNoLongerBreastFeeding() {
        return getConcept("0f46cbdc-54cb-40bd-8f75-72abcf6fc852");
    }

    public Concept getNumberOfDaysDispensed(){
        return getConcept("7593ede6-6574-4326-a8a6-3d742e843659");
    }

    public Concept getAdvancedDiseaseStatus(){
        return getConcept("17def5f6-d6b4-444b-99ed-40eb05d2c4f8");
    }

    public List<Concept> getConfirmedAdvancedDiseaseConcepts(){
        return Arrays.asList(getConfirmedAdvancedDiseaseCDLessThan200(),getConfirmedAdvancedDiseaseChildLessThan5Yrs(),getConfirmedAdvancedDiseasePosTB(),getConfirmedAdvancedDiseasePosCrag(),getConfirmedAdvancedDiseaseWHOStage3OR4());
    }
     public Concept getConfirmedAdvancedDiseaseCDLessThan200(){
         return getConcept("1615507f-54c6-4c18-b1ce-46a3d6d23154");
     }

    public Concept getConfirmedAdvancedDiseasePosCrag(){
        return getConcept("e48dcbe9-9c13-4526-95db-97223f3bf757");
    }

    public Concept getConfirmedAdvancedDiseasePosTB(){
        return getConcept("1f6fe5aa-29ba-4e84-8074-a7ea06eb8440");
    }
    public Concept getConfirmedAdvancedDiseaseWHOStage3OR4(){
        return getConcept("2050efe0-6a18-4028-a26e-16b90dfd853d");
    }

    public Concept getConfirmedAdvancedDiseaseChildLessThan5Yrs(){
        return getConcept("7cc40cbc-984f-40e0-aae3-50339dff8f4a");
    }

    public Concept getTPTInitiationDate() {
        return  getConcept("483939c7-79ba-4ca4-8c3e-346488c97fc7");
    }

    public Concept getTPTCompletionDate() {
        return getConcept("813e21e7-4ccb-4fe9-aaab-3c0e40b6e356");
    }

    public Concept getHepBScreeningDate() {
        return getConcept("53df33eb-4060-4300-8b7e-0f0784947767");
    }

    public Concept getHepCScreeningDate() {
        return getConcept("d8fcb0c7-6e6e-4efc-ac2b-3fae764fd198");
    }


    public Concept getHepCResults() {
        return getConcept("dca17ac9-30ab-102d-86b0-7a5022ba4115");
    }

    public Concept getHepBResults() {
        return getConcept("dca16e53-30ab-102d-86b0-7a5022ba4115");
    }


    public List<EncounterType> getSMCEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "244da86d-f80e-48fe-aba9-067f241905ee"));
        return l;
    }

    public List<EncounterType> getSMCFollowupEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "d0f9e0b7-f336-43bd-bf50-0a7243857fa6"));
        return l;
    }

    public List<EncounterType> getTBEnrollmentEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "334bf97e-28e2-4a27-8727-a5ce31c7cd66"));
        return l;
    }

    public List<EncounterType> getTBFollowupEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "455bad1f-5e97-4ee9-9558-ff1df8808732"));
        return l;
    }

    public List<EncounterType> getDRTBEnrollmentEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "0271ee3d-f274-49d1-b376-c842f075413f"));
        return l;
    }

    public List<EncounterType> getDRTBFollowupEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "41f8609d-e13b-4dff-8379-47ac5876512e"));
        return l;
    }

    public List<EncounterType> getANCEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "044daI6d-f80e-48fe-aba9-037f241905Pe"));
        return l;
    }

    public List<EncounterType> getMaternityEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "a9f11592-22e7-45fc-904d-dfe24cb1fc67"));
        return l;
    }

    public List<EncounterType> getPNCEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "fa6f3ff5-b784-43fb-ab35-a08ab7dbf074"));
        return l;
    }

    public List<EncounterType> getCovidInitiationEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "422ee220-9e83-451d-9b25-79a688a0413a"));
        return l;
    }

    public List<EncounterType> getCovidFollowupEncounterType() {
        List<EncounterType> l = new ArrayList<EncounterType>();
        l.add(MetadataUtils.existing(EncounterType.class, "95d334b0-c322-46ee-856a-4f503c8979ee"));
        return l;
    }

    public Program getFBIMProgram(){
        return commonDimensionLibrary.getProgramByUuid("de5d54ae-c304-11e8-9ad0-529269fb1459");
    }
    public Program getFTRProgram(){
        return commonDimensionLibrary.getProgramByUuid("de5d5896-c304-11e8-9ad0-529269fb1459");
    }
    public Program getFBGProgram(){
        return commonDimensionLibrary.getProgramByUuid("de5d5b34-c304-11e8-9ad0-529269fb1459");
    }
    public Program getCDDPProgram(){
        return commonDimensionLibrary.getProgramByUuid("de5d6034-c304-11e8-9ad0-529269fb1459");
    }
    public Program getCCLADProgram(){
        return commonDimensionLibrary.getProgramByUuid("de5d5da0-c304-11e8-9ad0-529269fb1459");
    }
}
