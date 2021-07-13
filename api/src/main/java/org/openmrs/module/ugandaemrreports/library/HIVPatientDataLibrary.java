package org.openmrs.module.ugandaemrreports.library;

import org.openmrs.Concept;
import org.openmrs.EncounterType;
import org.openmrs.PatientIdentifier;
import org.openmrs.PatientIdentifierType;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.data.converter.*;
import org.openmrs.module.reporting.data.patient.definition.*;
import org.openmrs.module.reporting.data.person.definition.AgeDataDefinition;
import org.openmrs.module.reporting.data.person.definition.PersonDataDefinition;
import org.openmrs.module.reporting.definition.library.BaseDefinitionLibrary;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.evaluation.parameter.ParameterizableUtil;
import org.openmrs.module.ugandaemrreports.common.Enums;
import org.openmrs.module.ugandaemrreports.data.converter.CodedConceptUUIDValueConverter;
import org.openmrs.module.ugandaemrreports.definition.data.converter.*;
import org.openmrs.module.ugandaemrreports.definition.data.definition.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

//import org.openmrs.module.ugandaemr.metadata.core.PatientIdentifierTypes;

/**
 * Attributes of a person not defined within the core OpenMRS definition
 */
@Component
public class HIVPatientDataLibrary extends BaseDefinitionLibrary<PatientDataDefinition> {
    @Autowired
    private DataFactory df;

    @Autowired
    private HIVMetadata hivMetadata;

    @Override
    public Class<? super PatientDataDefinition> getDefinitionType() {
        return PatientDataDefinition.class;
    }

    @Override
    public String getKeyPrefix() {
        return "ugemr.patientdata.";
    }

    public PatientDataDefinition getClinicNumber() {
        PreferredIdentifierDataDefinition def = new PreferredIdentifierDataDefinition();
        def.setIdentifierType(MetadataUtils.existing(PatientIdentifierType.class, "e1731641-30ab-102d-86b0-7a5022ba4115"));
        return convert(def, new PropertyConverter(PatientIdentifier.class, "identifier"));
    }

    public PatientDataDefinition getEIDNumber() {
        PreferredIdentifierDataDefinition def = new PreferredIdentifierDataDefinition();
        def.setIdentifierType(MetadataUtils.existing(PatientIdentifierType.class, "2c5b695d-4bf3-452f-8a7c-fe3ee3432ffe"));
        return convert(def, new PropertyConverter(PatientIdentifier.class, "identifier"));
    }

    public PatientDataDefinition getEnrollmentDate() {
        return getFirstArtInitialEncounterByEndDate(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getLastVisitDate() {
        return getLastARTVisitEncounterByEndDate(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getLastEncounterDateTime() {
        return getLastARTVisitEncounterByEndDate(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getLastARTEncounter() {
        return getFirstEncounterAfterDate(hivMetadata.getArtEncounterTypes(), df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getARTStartDate() {
        return df.getObs(hivMetadata.getArtStartDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getLastRegimenPickupDate() {
        return df.getObsByEndDate(hivMetadata.getCurrentRegimen(), null, TimeQualifier.LAST, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getCurrentViralLoad() {
        return df.getObs(hivMetadata.getCurrentViralLoad(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueNumericConverter());

    }

    public PatientDataDefinition getCurrentRegimen() {
        return df.getObsByEndDate(hivMetadata.getCurrentRegimen(), null, TimeQualifier.LAST, new ObsValueConverter());
    }

    public PatientDataDefinition getPreviousRegimen() {
        return df.getObsBeforeDate(hivMetadata.getCurrentRegimen(), null, TimeQualifier.LAST, new ObsValueConverter());
    }

    public PatientDataDefinition getCurrentRegimenUuid() {
        return df.getObsByEndDate(hivMetadata.getCurrentRegimen(), null, TimeQualifier.LAST, new CodedConceptUUIDValueConverter());
    }
    public PatientDataDefinition getCurrentRegimenDate() {
        return df.getObsByEndDate(hivMetadata.getCurrentRegimen(), null, TimeQualifier.LAST, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getARVDuration() {
        return df.getObsByEndDate(hivMetadata.getARVDuration(), null, TimeQualifier.LAST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getExpectedReturnDate() {
        return df.getObsByEndDate(hivMetadata.getReturnVisitDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getLatestExpectedReturnDateBeforeStartDate() {
        return df.getObsBeforeDate(hivMetadata.getReturnVisitDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getExpectedReturnDateDuringPeriod() {
        return df.getValueDatetimeObsDuringPeriod(hivMetadata.getReturnVisitDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getTODateDuringPeriod() {
        return df.getValueDatetimeObsDuringPeriod(hivMetadata.getTransferredOutDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getTransferredOutDateByEndDate() {
        return df.getObsByEndDate(hivMetadata.getTransferredOutDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getToPlaceDuringPeriod() {
        return df.getValueDatetimeObsDuringPeriod(hivMetadata.getTransferredOutPlace(), null, TimeQualifier.LAST, df.getObsValueTextConverter());
    }


    public PatientDataDefinition getExpectedReturnDateBetween() {
        return df.getValueDatetimeObsDuringPeriod(hivMetadata.getReturnVisitDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, new ObsValueDatetimeConverter());
    }

    public PatientDataDefinition getStartRegimen() {
        return df.getObsByEndDate(hivMetadata.getArtStartRegimen(), null, TimeQualifier.LAST, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getStartRegimenDate() {
        return df.getObsByEndDate(hivMetadata.getArtStartDate(), null, TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    protected PatientDataDefinition getFirstArtInitialEncounterByEndDate(DataConverter converter) {
        EncounterType arvInitial = hivMetadata.getARTSummaryPageEncounterType().get(0);
        return df.getFirstEncounterOfTypeByEndDate(arvInitial, converter);
    }

    protected PatientDataDefinition getLastARTVisitEncounterByEndDate(DataConverter converter) {
        EncounterType arvInitial = hivMetadata.getARTEncounterPageEncounterType().get(0);
        return df.getLastEncounterOfTypeByEndDate(Arrays.asList(arvInitial), converter);
    }

    public PatientDataDefinition getLastARTVisitEncounterByEndOfPreviousPeriod(DataConverter converter) {
        return df.getLastEncounterOfTypeByEndOfPreviousPeriod(hivMetadata.getARTEncounterPageEncounterType(), converter);
    }


    protected PatientDataDefinition getLastEncounter(List<EncounterType> encounterTypes, DataConverter converter) {
        return df.getLastEncounterOfTypeByEndDate(encounterTypes, converter);
    }

    protected PatientDataDefinition getFirstEncounterAfterDate(List<EncounterType> encounterTypes, DataConverter converter) {
        return df.getLastEncounterOfTypeAfterDate(encounterTypes, converter);
    }

    public PatientDataDefinition getAllArtNumbers() {
        PatientIdentifierType pit = hivMetadata.getHIVIdentifier();
        return df.getAllIdentifiersOfType(pit, df.getIdentifierCollectionConverter());
    }

    public PatientDataDefinition getEntryPoint() {
        return getSummaryPageObsValue(hivMetadata.getEntryPoint(), df.getObsValueCodedConverter());
    }
    public PatientDataDefinition getDirectionsToPatientAddress() {
        return df.getObs(hivMetadata.getDirectionsToAddress(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueTextConverter());

    }
    public PatientDataDefinition getFirstEID() {
        return getSummaryPageObsValue(hivMetadata.getPCRAtEnrollment(), df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getFirstLactating() {
        return getSummaryPageObsValue(hivMetadata.getLactatingAtEnrollment(), df.getObsValueNumericConverter());
    }
    public PatientDataDefinition getFirstRegimenPickupDate() {
        return df.getObsByEndDate(hivMetadata.getCurrentRegimen(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.FIRST, df.getObsDatetimeConverter());
    }
    public PatientDataDefinition getWHOClinicStage() {
        return df.getObs(hivMetadata.getWHOClinicalStage(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueCodedConverter());

    }
    public PatientDataDefinition getAdherence() {
        return df.getObs(hivMetadata.getAdherence(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueCodedConverter());

    }

    public PatientDataDefinition getAdherence(Integer number) {
        AdherencePatientDataDefinition def = new AdherencePatientDataDefinition();
        def.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(def, new AdherenceConverter(number));
    }

    public PatientDataDefinition getDSDMModel() {
        DSDMModelDataDefinition def = new DSDMModelDataDefinition();
        def.addParameter(new Parameter("startDate", "startDate", Date.class));
        def.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(def, df.getDSDMProgramConverter());
    }

    public PatientDataDefinition getPatientUUID() {
        PersonUUIDDataDefinition def = new PersonUUIDDataDefinition();
        return convert(def, df.getPatientUUIDConverter());
    }

    public PatientDataDefinition getDSDMEnrollmentDate() {
        DSDMModelDataDefinition def =  new DSDMModelDataDefinition();
        def.addParameter(new Parameter("startDate", "startDate", Date.class));
        def.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(def,df.getDateEnrolledConverter());
    }

    public PatientDataDefinition getFirstTB() {
        return getSummaryPageObsValue(hivMetadata.getDateEligibilityTB(), df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getFirstPregnant() {
        return getSummaryPageObsValue(hivMetadata.getPregnantAtEnrollment(), df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getFirstTransferIn() {
        return getSummaryPageObsValue(hivMetadata.getTransferInAtEnrollment(), new TIStatusConverter());
    }

    public PatientDataDefinition getCPTStartDate() {
        return getEncounterPageObsValue(hivMetadata.getCPTDosage(), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getCPTStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getCPTDosage(), num, new YesConverter());
    }

    public PatientDataDefinition getCPTStatusDuringMonth(Integer num) {
        return getLastObsValueDuringMonth(hivMetadata.getCPTDosage(), num, new YesConverter());
    }

    public PatientDataDefinition getINHStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getINHDosage(), num, new YesConverter());
    }

    public PatientDataDefinition getTBStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getTBStatus(), num, new TBStatusConverter());
    }

    public PatientDataDefinition getTBStatusDuringMonth(Integer num) {
        return getLastObsValueDuringMonth(hivMetadata.getTBStatus(), num, new TBStatusConverter());
    }

    public PatientDataDefinition getDeadStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getDead(), num, new DeadStatusConverter());
    }

    public PatientDataDefinition getTOStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getTransferredOut(), num, new TOStatusConverter());
    }

    public PatientDataDefinition getCD4DuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getCD4(), num, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getCD4DuringMonth(Integer num) {
        return getLastObsValueDuringMonth(hivMetadata.getCD4(), num, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getNutritionalStatusDuringQuarter(Integer num) {
        return getLastObsValueDuringQuarter(hivMetadata.getMalnutrition(), num, new NutritionalStatusConverter());
    }

    public PatientDataDefinition getARVRegimenDuringMonth(Integer num) {
        return getLastObsValueDuringMonth(hivMetadata.getCurrentRegimen(), num, new ARVConverter());
    }

    public PatientDataDefinition getARVADHDuringMonth(Integer num) {
        return getLastObsValueDuringMonth(hivMetadata.getAdherence(), num, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getINHStartDate() {
        return getEncounterPageObsValue(hivMetadata.getINHDosage(), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getTBStartDate() {
        return getEncounterPageObsValue(hivMetadata.getTBStartDate(), df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getTBStopDate() {
        return getEncounterPageObsValue(hivMetadata.getTBStopDate(), df.getObsValueDatetimeConverter());
    }


    public PatientDataDefinition getWHOStage1Date() {
        return getEncounterPageObsValue(hivMetadata.getWHOClinicalStage(), Arrays.asList(hivMetadata.getWHOClinicalStage1()), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getWHOStage2Date() {
        return getEncounterPageObsValue(hivMetadata.getWHOClinicalStage(), Arrays.asList(hivMetadata.getWHOClinicalStage2()), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getWHOStage3Date() {
        return getEncounterPageObsValue(hivMetadata.getWHOClinicalStage(), Arrays.asList(hivMetadata.getWHOClinicalStage3()), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getWHOStage4Date() {
        return getEncounterPageObsValue(hivMetadata.getWHOClinicalStage(), Arrays.asList(hivMetadata.getWHOClinicalStage4()), df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getARTEligibilityDate() {
        return getSummaryPageObsValue(hivMetadata.getDateEligibleForART(), df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getARTEligibilityAndReadyDate() {
        return getSummaryPageObsValue(hivMetadata.getDateEligibleAndReadyForART(), df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getARTEligibilityWHOStage() {
        return getSummaryPageObsValue(hivMetadata.getDateEligibilityWHOStage(), df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getARTEligibilityCD4() {
        return getSummaryPageObsValue(hivMetadata.getDateEligibilityWHOStage(), df.getObsValueNumericConverter());
    }
    public PatientDataDefinition getMostRecentViralLoadDate() {
        return df.getObs(hivMetadata.getViralLoadDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getStatusAtEnrollment() {
        StatusAtEnrollmentPatientDatasetDefinition def = new StatusAtEnrollmentPatientDatasetDefinition();
        MapConverter c = new MapConverter(": ", ", ", null, new ObjectFormatter());
        return df.convert(def, c);
    }

    public PatientDataDefinition getFUStatus(Integer periodToAdd) {
        FUStatusPatientDataDefinition def = new FUStatusPatientDataDefinition();
        def.setPeriodToAdd(periodToAdd);
        MapConverter c = new MapConverter(": ", ", ", null, new ObjectFormatter());
        return df.convert(def, c);
    }

    public PatientDataDefinition getWhyEligibleForART() {
        WhyEligibleForARTPatientDatasetDefinition def = new WhyEligibleForARTPatientDatasetDefinition();
        def.addParameter(new Parameter("onDate", "On Date", Date.class));
        MapConverter c = new MapConverter(": ", ", ", null, new ObjectFormatter());
        return df.convert(def, ObjectUtil.toMap("onDate=startDate"), c);
    }

    public PatientDataDefinition havingVisitDuringQuarter(Integer quarter) {
        return df.hasVisitDuringPeriod(Enums.Period.QUARTERLY, quarter, new LastSeenConverter());
    }

    public PatientDataDefinition havingEncounterDuringQuarter(Integer quarter) {
        return df.havingEncounterDuringPeriod(Enums.Period.QUARTERLY, quarter, new LastSeenConverter());
    }

    public PatientDataDefinition havingEncounterDuringMonth(Integer quarter) {
        return df.havingEncounterDuringPeriod(Enums.Period.MONTHLY, quarter, new LastSeenConverter());
    }

    public PatientDataDefinition getCD4AtEnrollment() {
        return df.getObsByEndDate(hivMetadata.getCD4AtEnrollment(), null, TimeQualifier.FIRST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getBaselineCD4() {
        return df.getObsByEndDate(hivMetadata.getBaselineCD4(), null, TimeQualifier.FIRST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getBaselineCD4(String olderThan) {
        return df.getObsByEndDate(hivMetadata.getBaselineCD4(), null, TimeQualifier.FIRST, olderThan, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getRecentCD4() {
        return df.getObsByEndDate(hivMetadata.getCD4(), null, TimeQualifier.LAST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getRecentCD4(String olderThan) {
        return df.getObsByEndOfPeriod(hivMetadata.getCD4(), null, TimeQualifier.LAST, olderThan, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getAgeDuringPeriod() {
        ConvertedPatientDataDefinition ageOnDate = new ConvertedPatientDataDefinition();
        ageOnDate.addParameter(new Parameter("startDate", "startDate", Date.class));
        ageOnDate.setDefinitionToConvert(Mapped.<PatientDataDefinition>map(getAgeOnEffectiveDate(), "effectiveDate=${startDate}"));
        return ageOnDate;
    }

    public PatientDataDefinition getCD4At6months() {
        return df.getObsByEndDate(hivMetadata.getBaselineCD4(), null, TimeQualifier.LAST, df.getObsValueNumericConverter());
    }

    // ***** CONVENIENCE METHODS

    public PatientDataDefinition convert(PatientDataDefinition pdd, DataConverter converter) {
        return convert(pdd, null, converter);
    }

    public PatientDataDefinition convert(PatientDataDefinition pdd, Map<String, String> renamedParameters, DataConverter converter) {
        ConvertedPatientDataDefinition convertedDefinition = new ConvertedPatientDataDefinition();
        convertedDefinition.setDefinitionToConvert(ParameterizableUtil.copyAndMap(pdd, convertedDefinition, renamedParameters));
        if (converter != null) {
            convertedDefinition.setConverters(Arrays.asList(converter));
        }
        return convertedDefinition;
    }

    protected PatientDataDefinition getObsOnArtInitialEncounter(Concept question, DataConverter converter) {
        EncounterType artSummary = hivMetadata.getARTSummaryEncounter();
        return df.getFirstObsByEndDate(question, Arrays.asList(artSummary), converter);
    }

    protected PatientDataDefinition convert(PersonDataDefinition pdd, DataConverter... converters) {
        return new ConvertedPatientDataDefinition(new PersonToPatientDataDefinition(pdd), converters);
    }

    protected PatientDataDefinition getSummaryPageObsValue(Concept question, DataConverter converter) {
        EncounterType arvInitial = hivMetadata.getARTSummaryEncounter();
        return df.getObsValue(question, Arrays.asList(arvInitial), converter);
    }

    protected PatientDataDefinition getEncounterPageObsValue(Concept question, DataConverter converter) {
        EncounterType arvInitial = hivMetadata.getARTEncounterEncounterType();
        return df.getObsValue(question, Arrays.asList(arvInitial), converter);
    }

    protected PatientDataDefinition getAgeOnEffectiveDate(DataConverter... converters) {
        AgeDataDefinition ageDataDefinition = new AgeDataDefinition();
        ageDataDefinition.addParameter(new Parameter("effectiveDate", "reporting.parameter.effectiveDate", Date.class));
        return convert(ageDataDefinition, converters);
    }

    protected PatientDataDefinition getEncounterPageObsValue(Concept question, List<Concept> answers, DataConverter converter) {
        EncounterType arvInitial = hivMetadata.getARTEncounterEncounterType();
        return df.getObsValue(question, Arrays.asList(arvInitial), answers, converter);
    }

    protected PatientDataDefinition getFirstObsValueDuringMonth(Concept question, Integer periodToAdd, DataConverter converter) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("whichEncounter", TimeQualifier.FIRST);
        map.put("period", Enums.Period.MONTHLY);
        return df.getObsValueDuringPeriod(question, periodToAdd, map, converter);
    }

    protected PatientDataDefinition getLastObsValueDuringQuarter(Concept question, Integer periodToAdd, DataConverter converter) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("whichEncounter", TimeQualifier.LAST);
        map.put("period", Enums.Period.QUARTERLY);
        return df.getObsValueDuringPeriod(question, periodToAdd, map, converter);
    }

    protected PatientDataDefinition getLastObsValueDuringMonth(Concept question, Integer periodToAdd, DataConverter converter) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("whichEncounter", TimeQualifier.LAST);
        map.put("period", Enums.Period.MONTHLY);
        return df.getObsValueDuringPeriod(question, periodToAdd, map, converter);
    }

    // ART Register Definitions

    public PatientDataDefinition getPatientARTStartDate() {
        return getFirstObsValueDuringMonth(hivMetadata.getArtStartDate(), 0, new TIStatusConverter());
    }

    public PatientDataDefinition getArtTransferIn() {
        return getFirstObsValueDuringMonth(hivMetadata.getArtRegimenTransferInDate(), 0, new TIStatusConverter());
    }

    public PatientDataDefinition getBaselineFunctionalStatus() {
        return getFirstObsValueDuringMonth(hivMetadata.getFunctionalStatusConcept(), 0, new FunctionalStatusConverter());
    }

    public PatientDataDefinition getBaselineWeight() {
        return getFirstObsValueDuringMonth(hivMetadata.getBaselineBodyWeight(), 0, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getArtBaselineCD4() {
        return getFirstObsValueDuringMonth(hivMetadata.getBaselineCD4(), 0, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getBaselineWHOStage() {
        return getFirstObsValueDuringMonth(hivMetadata.getBaselineWHOClinicalStage(), 0, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getViralLoad(Integer month) {
        return getFirstObsValueDuringMonth(hivMetadata.getViralLoad(), month, df.getObsValueCodedConverter());
    }
    public PatientDataDefinition getViralLoadQualitative() {
        return df.getObs(hivMetadata.getViralLoadQualitative(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueCodedConverter());

    }
    public PatientDataDefinition getViralLoad() {
        return df.getObs(hivMetadata.getCurrentViralLoad(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueNumericConverter());

    }

    public PatientDataDefinition getDistrictTBRxNo() {
        return df.getObs(hivMetadata.getDistrictTBNo(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueTextConverter());
    }
    public PatientDataDefinition getTransferInFacility() {
        return df.getObs(hivMetadata.getTransferInPlace(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueTextConverter());
    }

    public PatientDataDefinition getTransferInRegimen() {
        return df.getObs(hivMetadata.getArtTransferInRegimen(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getArtStartDate() {
        return df.getObs(hivMetadata.getArtStartDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, new ObsDatetimeConverter());
    }
    public PatientDataDefinition getViralLoadDate() {
        return df.getObs(hivMetadata.getViralLoadDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, new ObsValueDatetimeConverter());
    }


    public PatientDataDefinition getAnyBaselineCD4() {
        return df.getObs(hivMetadata.getBaselineCD4(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getBaselineRegimen() {
        return df.getObs(hivMetadata.getArtStartRegimen(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getBaseRegimen() {
        return getFirstObsValueDuringMonth(hivMetadata.getArtStartRegimen(), 0, new ARVConverter());
    }

    public PatientDataDefinition getEDDDate(int pregnancyNo) {
        return df.getEDDDate(pregnancyNo, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getFirstLineSubsDate(int which) {
        return df.getFirstLineSwitch(hivMetadata.getFirstLineSubstitutionDate(), which, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getFirstLineSubsReason(int which) {
        return df.getFirstLineSwitch(hivMetadata.getSubstitutionReason(), which, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getBaseCD4OnArtDuringQuarter(Integer quartersBack) {
        return df.getPatientsOnArtWithBaseCD4DuringPeriod(Enums.Period.QUARTERLY, Enums.PeriodInterval.BEFORE, quartersBack, df.getCD4Converter());
    }

    public PatientDataDefinition getDateOfLastEncounter() {
        return df.getPatientEncounters(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getEncounterTypeNameForLastEncounter() {
        return df.getPatientEncounters(df.getEncounterTypeNameConverter());
    }

    public PatientDataDefinition getLocationOfLastEncounter() {
        return df.getPatientEncounters(df.getEncounterLocationNameConverter());
    }

    public PatientDataDefinition getSummaryPageDate() {
        return df.getPatientArtSummaryEncounter(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getLastEncounterDuringPeriod() {
        EncountersForPatientDataDefinition cd = new EncountersForPatientDataDefinition();
        cd.setWhich(TimeQualifier.LAST);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"), df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getLastReturnDateByEndDate() {
        return  df.getObsByEndDate(hivMetadata.getReturnVisitDate(),Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, new ObsValueDatetimeConverter());
    }

    public PatientDataDefinition getLastViralLoadDateByEndDate() {
        return df.getObsByEndDate(hivMetadata.getViralLoadDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getLastViralLoadDateByEndDatePlusMonths(String plusMonths) {
        return df.getObsByEndDatePlusMonths(hivMetadata.getViralLoadDate(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST,plusMonths, df.getObsDatetimeConverter());
    }

    public PatientDataDefinition getViralLoadByEndDate(){
        return   df.getObsByEndDate(hivMetadata.getCurrentViralLoad(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getViralLoadByEndDatePlusMonths(String plusMonths){
        return   df.getObsByEndDatePlusMonths(hivMetadata.getCurrentViralLoad(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST,plusMonths, df.getObsValueNumericConverter());
    }

    public PatientDataDefinition getVLQualitativeByEndDate(){
        return   df.getObsByEndDate(hivMetadata.getViralLoadDetection(), Arrays.asList(hivMetadata.getARTEncounterEncounterType()), TimeQualifier.LAST, new ObsValueConverter());
    }

    public PatientDataDefinition getLastEncounterByEndDate(){
        return df.getPatientEncounters(df.getEncounterDatetimeConverter());
    }

    public PatientDataDefinition getDeathDateByEndDate() {
        DeathDateDataDefinition cd =  new DeathDateDataDefinition();
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return df.convert(cd, ObjectUtil.toMap("diedOnOrBefore=endDate"),df.getDeathDateConverter());
    }


    public PatientDataDefinition getTPTInitiationDate() {
        return df.getObsByEndDate(hivMetadata.getTPTInitiationDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getTPTCompletionDate() {
        return df.getObsByEndDate(hivMetadata.getTPTCompletionDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.LAST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getLastHepBScreeningDate() {
        return df.getObsByEndDate(hivMetadata.getHepBScreeningDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueDatetimeConverter());
    }

    public PatientDataDefinition getLastHepCScreeningDate() {
        return df.getObsByEndDate(hivMetadata.getHepCScreeningDate(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.FIRST, df.getObsValueDatetimeConverter());
    }


    public PatientDataDefinition getLastHepCScreeningResult() {
        return df.getObs(hivMetadata.getHepCResults(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.LAST, df.getObsValueCodedConverter());
    }

    public PatientDataDefinition getLastHepBScreeningResult() {
        return df.getObs(hivMetadata.getHepBResults(), Arrays.asList(hivMetadata.getARTSummaryEncounter()), TimeQualifier.LAST, df.getObsValueCodedConverter());
    }

}