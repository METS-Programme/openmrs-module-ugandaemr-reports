package org.openmrs.module.ugandaemrreports.library;

import org.openmrs.*;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.*;
import org.openmrs.module.reporting.common.*;
import org.openmrs.module.reporting.data.ConvertedDataDefinition;
import org.openmrs.module.reporting.data.DataDefinition;
import org.openmrs.module.reporting.data.converter.*;
import org.openmrs.module.reporting.data.encounter.definition.ConvertedEncounterDataDefinition;
import org.openmrs.module.reporting.data.encounter.definition.EncounterDataDefinition;
import org.openmrs.module.reporting.data.patient.definition.*;
import org.openmrs.module.reporting.data.person.definition.AgeDataDefinition;
import org.openmrs.module.reporting.data.person.definition.ObsForPersonDataDefinition;
import org.openmrs.module.reporting.data.person.definition.PersonDataDefinition;
import org.openmrs.module.reporting.data.person.definition.PreferredAddressDataDefinition;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.evaluation.parameter.ParameterizableUtil;
import org.openmrs.module.reporting.query.encounter.definition.EncounterQuery;
import org.openmrs.module.reporting.query.encounter.definition.MappedParametersEncounterQuery;
import org.openmrs.module.reportingcompatibility.service.ReportService.TimeModifier;
import org.openmrs.module.ugandaemrreports.common.CD4;
import org.openmrs.module.ugandaemrreports.common.DSDMModel;
import org.openmrs.module.ugandaemrreports.common.DeathDate;
import org.openmrs.module.ugandaemrreports.common.Enums;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.*;
import org.openmrs.module.ugandaemrreports.definition.data.converter.PatientIdentifierConverter;
import org.openmrs.module.ugandaemrreports.definition.data.definition.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class DataFactory {

    @Autowired
    HIVMetadata hivMetadata;

    public Parameter getStartDateParameter() {
        return ReportingConstants.START_DATE_PARAMETER;
    }

    public Parameter getEndDateParameter() {
        return ReportingConstants.END_DATE_PARAMETER;
    }

    public Parameter getOnDateParameter() {
        return new Parameter("startDate", "Start Date", Date.class);
    }

    // Data Converters
    public DataConverter getIdentifierConverter() {
        return new PropertyConverter(PatientIdentifier.class, "identifier");
    }

    public DataConverter getEncounterDatetimeConverter() {
        return new PropertyConverter(Encounter.class, "encounterDatetime");
    }

    public DataConverter getEncounterUuidConverter() {
        return new PropertyConverter(Encounter.class, "uuid");
    }

    public DataConverter getEncounterLocationNameConverter() {
        return new ChainedConverter(new PropertyConverter(Encounter.class, "location"), new ObjectFormatter());
    }

    public DataConverter getEncounterTypeNameConverter() {
        return new ChainedConverter(new PropertyConverter(Encounter.class, "encounterType"), new ObjectFormatter());
    }

    public DataConverter getObsDatetimeConverter() {
        return new PropertyConverter(Obs.class, "obsDatetime");
    }

    public DataConverter getObsValueNumericConverter() {
        return new PropertyConverter(Obs.class, "valueNumeric");
    }

    public DataConverter getObsValueDatetimeConverter() {
        return new PropertyConverter(Obs.class, "valueDatetime");
    }


    public DataConverter getObsValueDatetimeCollectionConverter() {
        ChainedConverter itemConverter = new ChainedConverter(getObsValueDatetimeConverter(), getObjectFormatter());
        CollectionConverter collectionConverter = new CollectionConverter(itemConverter, true, null);
        return new ChainedConverter(collectionConverter, new ObjectFormatter(" "));
    }

    public DataConverter getObsValueCodedConverter() {
        return new PropertyConverter(Obs.class, "valueCoded");
    }

    public DataConverter getCD4Converter() {
        return new PropertyConverter(CD4.class, "cd4");
    }

    public DataConverter getObsValueCodedNameConverter() {
        return new ChainedConverter(getObsValueCodedConverter(), new ObjectFormatter());
    }

    public DataConverter getObsValueTextConverter() {
        return new PropertyConverter(Obs.class, "valueText");
    }

    public DataConverter getObsValueCodedPresentConverter(Concept valueCoded) {
        ChainedConverter converter = new ChainedConverter();
        converter.addConverter(new CollectionConverter(getObsValueCodedConverter(), false, null));
        converter.addConverter(new CollectionElementConverter(valueCoded, "true", ""));
        return converter;
    }

    public DataConverter getObjectFormatter() {
        return new ObjectFormatter();
    }

    public DataConverter getListItemConverter(Integer index, DataConverter... converters) {
        ChainedConverter ret = new ChainedConverter();
        ret.addConverter(new ListConverter(index, Object.class));
        for (DataConverter converter : converters) {
            ret.addConverter(converter);
        }
        return ret;
    }

    public DataConverter getLastListItemConverter(DataConverter... converters) {
        ChainedConverter ret = new ChainedConverter();
        ret.addConverter(new ListConverter(TimeQualifier.LAST, 1, Object.class));
        for (DataConverter converter : converters) {
            ret.addConverter(converter);
        }
        return ret;
    }

    public DataConverter getDataSetItemConverter(Integer index, String columnName, Object nullReplacement) {
        ChainedConverter ret = new ChainedConverter();
        ret.addConverter(new ListConverter(index, DataSetRow.class));
        ret.addConverter(new DataSetRowConverter(columnName));
        if (nullReplacement != null) {
            ret.addConverter(new NullValueConverter(nullReplacement));
        }
        return ret;
    }

    public DataConverter getLastDataSetItemConverter(String columnName, Object nullReplacement) {
        ChainedConverter ret = new ChainedConverter();
        ret.addConverter(new ListConverter(TimeQualifier.LAST, 1, DataSetRow.class));
        ret.addConverter(new DataSetRowConverter(columnName));
        if (nullReplacement != null) {
            ret.addConverter(new NullValueConverter(nullReplacement));
        }
        return ret;
    }

    public DataConverter getDeathDateConverter() {
        return new PropertyConverter(DeathDate.class, "deathDate");
    }

    public DataConverter getDateEnrolledConverter() {
         return new PropertyConverter(DSDMModel.class, "dateOfEnrollment");

    }


    public DataConverter getDSDMProgramConverter() {
        return new PropertyConverter(DSDMModel.class, "progId");
    }

    public DataConverter getWorkflowStateName() {
        return new ChainedConverter(new PropertyConverter(PatientState.class, "state"), new ObjectFormatter());
    }

    public DataConverter getWorkflowStateStartDate() {
        return new PropertyConverter(PatientState.class, "startDate");
    }

    public DataConverter getPatientUUIDConverter() {
        return new PropertyConverter(Person.class, "uuid");
    }
    public DataConverter getDeathCourseConverter() {
        return new PropertyConverter(DeathDate.class, "caseOfDeath");
    }

    public DataConverter getAgeAtDeathConverter() {
        return new PropertyConverter(DeathDate.class, "ageAtDeath");
    }

    // Convenience converter methods

    public DataConverter getIdentifierCollectionConverter() {
        CollectionConverter collectionConverter = new CollectionConverter(new PatientIdentifierConverter(), true, null);
        return new ChainedConverter(collectionConverter, new ObjectFormatter(" "));
    }

    public CohortDefinition convert(CohortDefinition cd, Map<String, String> renamedParameters) {
        return new MappedParametersCohortDefinition(cd, renamedParameters);
    }

    public EncounterQuery convert(EncounterQuery query, Map<String, String> renamedParameters) {
        return new MappedParametersEncounterQuery(query, renamedParameters);
    }

    public PatientDataDefinition convert(PatientDataDefinition pdd, Map<String, String> renamedParameters, DataConverter converter) {
        ConvertedPatientDataDefinition convertedDefinition = new ConvertedPatientDataDefinition();
        addAndConvertMappings(pdd, convertedDefinition, renamedParameters, converter);
        return convertedDefinition;
    }


    public PatientDataDefinition convert(PatientDataDefinition pdd, DataConverter converter) {
        return convert(pdd, null, converter);
    }

    public PatientDataDefinition convert(PersonDataDefinition pdd, Map<String, String> renamedParameters, DataConverter converter) {
        return convert(new PersonToPatientDataDefinition(pdd), renamedParameters, converter);
    }

    public PatientDataDefinition convert(PersonDataDefinition pdd, DataConverter converter) {
        return convert(pdd, null, converter);
    }

    public EncounterDataDefinition convert(EncounterDataDefinition edd, Map<String, String> renamedParameters, DataConverter converter) {
        ConvertedEncounterDataDefinition convertedDefinition = new ConvertedEncounterDataDefinition();
        addAndConvertMappings(edd, convertedDefinition, renamedParameters, converter);
        return convertedDefinition;
    }

    public EncounterDataDefinition convert(EncounterDataDefinition pdd, DataConverter converter) {
        return convert(pdd, null, converter);
    }

    protected <T extends DataDefinition> void addAndConvertMappings(T copyFrom, ConvertedDataDefinition<T> copyTo, Map<String, String> renamedParameters, DataConverter converter) {
        copyTo.setDefinitionToConvert(ParameterizableUtil.copyAndMap(copyFrom, copyTo, renamedParameters));
        if (converter != null) {
            copyTo.setConverters(Arrays.asList(converter));
        }
    }


    // Composition Cohorts

    public CompositionCohortDefinition getPatientsInAny(CohortDefinition... elements) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.initializeFromQueries(BooleanOperator.OR, elements);
        return cd;
    }

    public CompositionCohortDefinition getPatientsNotIn(CohortDefinition... elements) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.initializeFromQueries(BooleanOperator.NOT, elements);
        return cd;
    }

    public CompositionCohortDefinition createPatientComposition(Object... elements) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.initializeFromElements(elements);
        return cd;
    }


    // Patient Data Definitions

    public PatientDataDefinition getObs(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, timeQualifier);
        return createPatientDataDefinition(def, converter);
    }

    public PatientDataDefinition getObsByEndDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_BEFORE_END_DATE);
    }

    public PatientDataDefinition getSMSTelephoneNumber(){
        SqlPatientDataDefinition def = new SqlPatientDataDefinition();
        def.setQuery("SELECT o.person_id,o.value_text from obs o inner join (SELECT person_id,max(obs_datetime)latest_date from obs where concept_id=166561 and voided=0 group by person_id)A on o.person_id = A.person_id\n" +
                "where o.concept_id=166561 and obs_datetime =A.latest_date and o.voided=0");
        return def;
    }

    public PatientDataDefinition getObsByEndDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String olderThan, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.createParameterBeforeDuration("onOrBefore", "endDate", olderThan));
    }

    public PatientDataDefinition getObsByEndDatePlusMonths(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String plusMonths, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.createParameterAfterDuration("onOrBefore", "endDate", plusMonths));
    }

    public PatientDataDefinition getObsAfterDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrAfter", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_AFTER_START_DATE);
    }

    public PatientDataDefinition getObsAfterDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String olderThan, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.createParameterBeforeDuration("onOrBefore", "startDate", olderThan));
    }

    public PatientDataDefinition getObsBeforeDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        // ensure that the period used does not overlap with the current period so remove one day
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_BEFORE_START_DATE + "-1d");
    }

    public PatientDataDefinition getObsBeforeDate(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String olderThan, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, "onOrBefore", timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.createParameterBeforeDuration("onOrBefore", "startDate", olderThan));
    }


    public PatientDataDefinition getObsByEndOfPeriod(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String olderThan, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, Arrays.asList("onOrBefore", "onOrAfter"), timeQualifier);
        String startDate = Parameters.createParameterBeforeDuration("onOrAfter", "startDate", olderThan);
        return createPatientDataDefinition(def, converter, Parameters.combineParameters(startDate, Parameters.ON_OR_BEFORE_END_DATE));
    }

    public PatientDataDefinition getObsDuringPeriod(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, Arrays.asList("onOrBefore", "onOrAfter"), timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.combineParameters(Parameters.ON_OR_AFTER_START_DATE, Parameters.ON_OR_BEFORE_END_DATE));

    }

    public PatientDataDefinition getValueDatetimeObsDuringPeriod(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, Arrays.asList("valueDatetimeOrAfter", "valueDatetimeOnOrBefore"), timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.combineParameters(Parameters.VALUE_DATETIME_OR_AFTER_START_DATE, Parameters.VALUE_DATETIME_ON_OR_BEFORE_END_DATE));

    }

    public PatientDataDefinition getExpectedReturnDateAtLocation(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ReturnVisitDatePatientDataDefinition def = new ReturnVisitDatePatientDataDefinition();
        def.setEncounterTypeList(encounterTypes);
        def.setQuestion(question);
        def.setWhich(timeQualifier);
        def.addParameter(new Parameter("location","location",Location.class));
        def.addParameter(new Parameter("valueDatetimeOrAfter","valueDatetimeOrAfter",Date.class));
        def.addParameter(new Parameter("valueDatetimeOnOrBefore","valueDatetimeOnOrBefore",Date.class));
        return createPatientDataDefinition( def, converter, Parameters.combineParameters(Parameters.VALUE_DATETIME_OR_AFTER_START_DATE, Parameters.VALUE_DATETIME_ON_OR_BEFORE_END_DATE));

    }

    public PatientDataDefinition getLatestARTVisitDate(Location location) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(Dictionary.getEncounterType("8d5b2be0-c2cc-11de-8d13-0010c6dffd0f")), "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        def.setLocationList(Arrays.asList(location));
        def.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return createPatientDataDefinition(def, getEncounterDatetimeConverter(), "onOrBefore=endDate");
    }

    public PatientDataDefinition getObsDuringPeriod(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, String olderThan, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, Arrays.asList("onOrBefore", "onOrAfter"), timeQualifier);
        String startDate = Parameters.createParameterBeforeDuration("onOrAfter", "startDate", olderThan);
        String endDate = Parameters.createParameterBeforeDuration("onOrBefore", "endDate", olderThan);
        return createPatientDataDefinition(def, converter, Parameters.combineParameters(startDate, endDate));
    }

    public PatientDataDefinition getFirstObsByEndDate(Concept question, List<EncounterType> encounterTypes, DataConverter converter) {
        return getObsByEndDate(question, encounterTypes, TimeQualifier.FIRST, converter);
    }

    public PatientDataDefinition getFirstObBetweenDates(Concept question, List<EncounterType> encounterTypes, DataConverter converter) {
        return getObsDuringPeriod(question, encounterTypes, TimeQualifier.FIRST, converter);
    }

    public PatientDataDefinition getMostRecentObsByEndDate(Concept question, List<EncounterType> encounterTypes, DataConverter converter) {
        return getObsByEndDate(question, encounterTypes, TimeQualifier.LAST, converter);

    }

    public PatientDataDefinition getAllObsByEndDate(Concept question, List<EncounterType> encounterTypes, DataConverter converter) {
        return getObsByEndDate(question, encounterTypes, null, converter);

    }

    public PatientDataDefinition getCodedObsPresentByEndDate(Concept question, Concept answer, List<EncounterType> encounterTypes) {
        return getObsByEndDate(question, encounterTypes, null, getObsValueCodedPresentConverter(answer));
    }

    public PatientDataDefinition getCodedObsDuringPeriod(Concept question, List<EncounterType> encounterTypes,List<Concept> codedValues,TimeQualifier timeQualifier) {

        ObsForPersonDataDefinition cd = new ObsForPersonDataDefinition();
        cd.setWhich(timeQualifier);
        cd.setValueCodedList(codedValues);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"),getObsValueCodedConverter());
    }


    public PatientDataDefinition getAllIdentifiersOfType(PatientIdentifierType pit, DataConverter converter) {
        PatientIdentifierDataDefinition def = new PatientIdentifierDataDefinition();
        def.setTypes(Arrays.asList(pit));
        return new ConvertedPatientDataDefinition(def, converter);
    }

    public PatientDataDefinition getFirstEncounterOfTypeByEndDate(EncounterType type, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(type), "onOrBefore");
        def.setWhich(TimeQualifier.FIRST);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_BEFORE_END_DATE);
    }

    public PatientDataDefinition getLastEncounterOfTypeByEndDate(List<EncounterType> types, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(types, "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_BEFORE_END_DATE);
    }

    public PatientDataDefinition getLastEncounterOfTypeByEndOfPreviousPeriod(List<EncounterType> types, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(types, "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        return createPatientDataDefinition(def, converter, "onOrBefore=startDate-1d");
    }

    public PatientDataDefinition getLastEncounterOfTypeBeforeDate(EncounterType type, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(type), "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_BEFORE_END_DATE);
    }

    public PatientDataDefinition getLastEncounterOfTypeAfterDate(List<EncounterType> types, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(types, "onOrAfter");
        def.setWhich(TimeQualifier.LAST);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_AFTER_START_DATE);
    }

    public PatientDataDefinition getPreferredAddress(String property) {
        PreferredAddressDataDefinition d = new PreferredAddressDataDefinition();
        PropertyConverter converter = new PropertyConverter(PersonAddress.class, property);
        return convert(d, converter);
    }

    public PatientDataDefinition getPersonUUID(String property) {
        PersonUUIDDataDefinition d = new PersonUUIDDataDefinition();
        PropertyConverter converter = new PropertyConverter(Person.class, property);
        return convert(d, converter);
    }

    public PatientDataDefinition getObsValue(Concept question, List<EncounterType> encounterTypes, DataConverter converter) {
        ObsForPersonInPeriodDataDefinition def = new ObsForPersonInPeriodDataDefinition();
        def.setQuestion(question);
        def.setEncounterTypes(encounterTypes);
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }


    public PatientDataDefinition getObsValue(Concept question, List<EncounterType> encounterTypes, List<Concept> answers, DataConverter converter) {
        ObsForPersonInPeriodDataDefinition def = new ObsForPersonInPeriodDataDefinition();
        def.setAnswers(answers);
        def.setQuestion(question);
        def.setEncounterTypes(encounterTypes);
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition hasVisitDuringPeriod(Enums.Period period, Integer periodToAdd, DataConverter converter) {
        ObsForPersonInPeriodDataDefinition def = new ObsForPersonInPeriodDataDefinition();
        def.setEncounterTypes(hivMetadata.getArtEncounterTypes());
        def.setPeriod(period);
        def.setWhichEncounter(TimeQualifier.LAST);
        def.setPeriodToAdd(periodToAdd);
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition hasEncounterDuringPeriod(EncounterType encounterType, DataConverter converter) {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(encounterType), "onOrAfter");
        def.setWhich(TimeQualifier.ANY);
        return createPatientDataDefinition(def, converter, Parameters.ON_OR_AFTER_START_DATE);
    }

    public PatientDataDefinition havingEncounterDuringPeriod(Enums.Period period, Integer periodToAdd, DataConverter converter) {
        FUStatusPatientDataDefinition def = new FUStatusPatientDataDefinition();
        def.setPeriod(period);
        def.setPeriodToAdd(periodToAdd);
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition getFirstLineSwitch(Concept what, Integer which, DataConverter converter) {
        FirstLineSubstitutionPatientDataDefinition def = new FirstLineSubstitutionPatientDataDefinition();
        def.setWhat(what);
        def.setSubstitutionOrSwitchNo(which);
        return convert(def, converter);
    }

    public PatientDataDefinition getObsValueDuringPeriod(Concept question, Integer periodToAdd, Map<String, Object> args, DataConverter converter) {
        ObsForPersonInPeriodDataDefinition def = new ObsForPersonInPeriodDataDefinition();
        def.setQuestion(question);
        Enums.Period period = null;
        TimeQualifier whichEncounter = null;

        Set<String> keys = args.keySet();

        if (keys.contains("period")) {
            period = (Enums.Period) args.get("period");
        }

        if (keys.contains("whichEncounter")) {
            whichEncounter = (TimeQualifier) args.get("whichEncounter");
        }
        def.setWhichEncounter(whichEncounter);
        def.setPeriod(period);
        def.setPeriodToAdd(periodToAdd);
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition getAgeOnEffectiveDate(DataConverter converter) {
        AgeDataDefinition def = new AgeDataDefinition();
        def.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(def, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition getEDDDate(int pregnancyNo, DataConverter converter) {
        EMTCTPatientDataDefinition def = new EMTCTPatientDataDefinition();
        def.setPregnancyNo(pregnancyNo);
        def.addParameter(new Parameter("onDate", "On Date", Date.class));
        return convert(def, ObjectUtil.toMap("onDate=startDate"), converter);
    }

    public PatientDataDefinition getHTSVisitDate() {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(Dictionary.getEncounterType("264daIZd-f80e-48fe-nba9-P37f2W1905Pv")), "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        def.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        def.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return createPatientDataDefinition(def, getEncounterDatetimeConverter(), "onOrAfter=startDate, onOrBefore=endDate");
    }
    public PatientDataDefinition getHTSEncounterUuid() {
        EncountersForPatientDataDefinition def = PatientColumns.createEncountersForPatientDataDefinition(Arrays.asList(Dictionary.getEncounterType("264daIZd-f80e-48fe-nba9-P37f2W1905Pv")), "onOrBefore");
        def.setWhich(TimeQualifier.LAST);
        def.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        def.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return createPatientDataDefinition(def, getEncounterUuidConverter(), "onOrAfter=startDate, onOrBefore=endDate");
    }

    public PatientDataDefinition getPatientsOnArtWithBaseCD4DuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference, DataConverter converter) {
        CD4PatientDataDefinition cd = new CD4PatientDataDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"), converter);
    }

    public PatientDataDefinition getPatientEncounters(DataConverter converter) {
        EncountersForPatientDataDefinition cd = new EncountersForPatientDataDefinition();
        cd.setWhich(TimeQualifier.LAST);
//        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
//        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"), converter);
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"), converter);
    }

    public PatientDataDefinition getPatientArtSummaryEncounter(DataConverter converter) {
        EncountersForPatientDataDefinition cd = new EncountersForPatientDataDefinition();
        cd.setWhich(TimeQualifier.FIRST);
        cd.addType(hivMetadata.getARTSummaryEncounter());
        return convert(cd, converter);
    }

    // Cohorts Definitions

    public CohortDefinition getPatientsWhoseObsValueDateIsOnSpecifiedDate(Concept dateConcept, List<EncounterType> types) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return cd;
    }

    public CohortDefinition getAnyEncounterOfTypesWithinMonthsByEndDate(List<EncounterType> types, int numMonths) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=endDate-" + numMonths + "m+1d"));
    }

    public CohortDefinition getEncountersOccuringMonthsBeforeStartDate(List<EncounterType> types, int numMonths) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-" + numMonths + "m"));
    }

    public CohortDefinition getAnyEncounterOfTypesByEndOfDate(List<EncounterType> types) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"));
    }

    public CohortDefinition getAnyEncounterOfTypesFromPastEndPeriodToEndDate(List<EncounterType> types,String olderThan) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=endDate-"+olderThan+",onOrBefore=endDate"));
    }

    public CohortDefinition getAnyEncounterOfTypesBetweenDates(List<EncounterType> types,List<Location> locations) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.setLocationList(locations);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getAnyEncounterOfTypesByStartDate(List<EncounterType> types) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-1d"));
    }

    public CohortDefinition getAnyEncounterOfTypesBetweenDates(List<EncounterType> types) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setEncounterTypeList(types);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CompositionCohortDefinition getPatientsInAll(CohortDefinition... elements) {
        CompositionCohortDefinition cd = new CompositionCohortDefinition();
        cd.initializeFromQueries(BooleanOperator.AND, elements);
        return cd;
    }

    public CohortDefinition getPatientsWhoStartedStateWhenInAgeRangeAtLocationByEndDate(Integer minAge, Age.Unit minAgeUnit, Integer maxAge, Age.Unit maxAgeUnit) {
        InAgeRangeAtCohortDefinition cd = new InAgeRangeAtCohortDefinition();
        cd.setMinAge(minAge);
        cd.setMinAgeUnit(minAgeUnit);
        cd.setMaxAge(maxAge);
        cd.setMaxAgeUnit(maxAgeUnit);
        return cd;
    }

    public CohortDefinition getAnyEncounterOfType(List<EncounterType> types) {
        InEncounterCohortDefinition cd = new InEncounterCohortDefinition();
        cd.setEncounterTypes(types);
        cd.addParameter(getStartDateParameter());
        cd.addParameter(getEndDateParameter());
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getObsWithEncounters(Concept question, List<EncounterType> types) {
        ObsWithEncountersCohortDefinition cd = new ObsWithEncountersCohortDefinition();
        cd.setEncounterTypes(types);
        cd.setQuestion(question);
        cd.setWhichEncounter(TimeQualifier.FIRST);
        cd.addParameter(getStartDateParameter());
        cd.addParameter(getEndDateParameter());
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getObsWithEncounters(Concept question, List<EncounterType> types, List<Concept> answers) {
        ObsWithEncountersCohortDefinition cd = new ObsWithEncountersCohortDefinition();
        cd.setEncounterTypes(types);
        cd.setQuestion(question);
        cd.setWhichEncounter(TimeQualifier.FIRST);
        cd.setAnswers(answers);
        cd.addParameter(getStartDateParameter());
        cd.addParameter(getEndDateParameter());
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsInPeriod(List<EncounterType> types, Enums.Period period) {
        PatientsInPeriodCohortDefinition cd = new PatientsInPeriodCohortDefinition();
        cd.setEncounterTypes(types);
        cd.setWhichEncounter(TimeQualifier.FIRST);
        cd.setPeriod(period);
        cd.addParameter(getStartDateParameter());
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getPatientsInPeriod(List<EncounterType> types, Concept question, Enums.Period period) {
        PatientsInPeriodCohortDefinition cd = new PatientsInPeriodCohortDefinition();
        cd.setEncounterTypes(types);
        cd.setQuestion(question);
        cd.setIncludeObs(true);
        cd.setWhichEncounter(TimeQualifier.FIRST);
        cd.setPeriod(period);
        cd.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getPatientsInPeriod(List<EncounterType> types, Concept question, List<Concept> answers, Enums.Period period) {
        PatientsInPeriodCohortDefinition cd = new PatientsInPeriodCohortDefinition();
        cd.setEncounterTypes(types);
        cd.setQuestion(question);
        cd.setIncludeObs(true);
        cd.setWhichEncounter(TimeQualifier.FIRST);
        cd.setPeriod(period);
        cd.setAnswers(answers);
        cd.addParameter(new Parameter("startDate", "Start Date", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getPatientsWithIdentifierOfType(PatientIdentifierType... types) {
        PatientIdentifierCohortDefinition cd = new PatientIdentifierCohortDefinition();
        for (PatientIdentifierType type : types) {
            cd.addTypeToMatch(type);
        }
        return cd;
    }

    public CohortDefinition getPatientsWithConcept(Concept question, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        return cd;
    }

    public CohortDefinition getPatientsWithCodedObs(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        return cd;
    }

    public CohortDefinition getPatientsWithCodedObs(Concept question, List<Concept> codedValues, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        return cd;
    }

    public CohortDefinition getPatientsWithCodedObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithCodedObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-" + olderThan + ",onOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithCodedObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getDeadPatientsDuringPeriod() {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrAfter=startDate,diedOnOrBefore=endDate"));
    }

    public CohortDefinition getDeadPatientsByEndDate() {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrBefore=endDate"));
    }

    public CohortDefinition getDeadPatientsByEndDate(String olderThan) {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getDeadPatientsByEndOfPreviousDate() {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrBefore=startDate"));
    }

    public CohortDefinition getDeadPatientsByEndOfPreviousDate(String olderThan) {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("diedOnOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrBefore=startDate-" + olderThan));
    }

    public CohortDefinition getDeadPatients() {
        BirthAndDeathCohortDefinition cd = new BirthAndDeathCohortDefinition();
        cd.addParameter(new Parameter("diedOnOrAfter", "On or After", Date.class));
        return convert(cd, ObjectUtil.toMap("diedOnOrAfter=startDate"));
    }

    public CohortDefinition getPatientsWithCodedObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-" + olderThan + ",onOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithCodedObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-1d"));
    }

    public CohortDefinition getPatientsWithCodedObsByEndDate(Concept question, List<EncounterType> restrictToTypes, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-" + olderThan + ",onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithCodedObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithCodedObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-1d"));
    }

    public CohortDefinition getPatientsWithCodedObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithCodedObsByEndDate(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithCodedObsByEndDate(Concept question, List<EncounterType> restrictToTypes, List<Concept> codedValues, BaseObsCohortDefinition.TimeModifier timeModifier) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(codedValues);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObs(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        return cd;
    }

    public CohortDefinition getPatientsWithNumericObs(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, RangeComparator operator2, Double value, Double value2, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.setOperator2(operator2);
        cd.setValue2(value2);
        return cd;
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, RangeComparator operator2, Double value2, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.setOperator2(operator2);
        cd.setValue2(value2);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPeriod(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, RangeComparator operator2, Double value2, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.setOperator2(operator2);
        cd.setValue2(value2);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes,String olderThan, RangeComparator operator, Double value, RangeComparator operator2, Double value2, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.setOperator2(operator2);
        cd.setValue2(value2);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-"+olderThan+",onOrBefore=endDate-"+olderThan));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes,String olderThan, RangeComparator operator, Double value, RangeComparator operator2, Double value2, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.setOperator2(operator2);
        cd.setValue2(value2);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate-"+olderThan));
    }

    public CohortDefinition getViralLoadDuringPeriod() {
        ViralLoadCohortDefinition cd = new ViralLoadCohortDefinition();
        cd.addParameter(new Parameter("startDate", "On or After", Date.class));
        cd.addParameter(new Parameter("endDate", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getViralLoadDuringPeriod(Boolean notDetected) {
        ViralLoadCohortDefinition cd = new ViralLoadCohortDefinition();
        cd.setNotDetected(notDetected);
        cd.addParameter(new Parameter("startDate", "On or After", Date.class));
        cd.addParameter(new Parameter("endDate", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getViralLoadDuringPeriod(Double from, Double to) {
        ViralLoadCohortDefinition cd = new ViralLoadCohortDefinition();
        cd.setDetected(Boolean.TRUE);
        cd.setCopiesFrom(from);
        cd.setCopiesTo(to);
        cd.addParameter(new Parameter("startDate", "On or After", Date.class));
        cd.addParameter(new Parameter("endDate", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getViralLoadDuringPeriod(Double from) {
        ViralLoadCohortDefinition cd = new ViralLoadCohortDefinition();
        cd.setDetected(Boolean.TRUE);
        cd.setCopiesFrom(from);
        cd.addParameter(new Parameter("startDate", "On or After", Date.class));
        cd.addParameter(new Parameter("endDate", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-" + olderThan + ",onOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsDuringPeriod(Concept question, List<EncounterType> restrictToTypes, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate-" + olderThan + ",onOrBefore=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-1d"));
    }

    public CohortDefinition getPatientsWithNumericObsByEndDate(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-" + olderThan));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-1d"));
    }

    public CohortDefinition getPatientsWithNumericObsByEndOfPreviousDate(Concept question, List<EncounterType> restrictToTypes, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=startDate-" + olderThan));
    }


    public CohortDefinition getPatientsWhoseMostRecentCodedObsInValuesByEndDate(Concept question, List<EncounterType> types, Concept... values) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.MAX);
        cd.setQuestion(question);
        cd.setEncounterTypeList(types);
        cd.setOperator(SetComparator.IN);
        cd.setValueList(Arrays.asList(values));
        cd.addParameter(new Parameter("onOrBefore", "onOrBefore", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrBefore=endDate"));
    }

    public CohortDefinition getPatientsWhoseObs(Concept dateConcept, List<EncounterType> types) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        return cd;
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate,value2=endDate"));
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDateAtLocation(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        AppointmentDateAtLocationCohortDefinition cd = new AppointmentDateAtLocationCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.addParameter(new Parameter("location", "Locations", Location.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate,value2=endDate"));
    }

    public CohortDefinition getPatientsWithObsDuringWeek(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        Date currentDate = new Date();
        Date startDate = DateUtil.getStartOfWeek(currentDate);
        Date endDate = DateUtil.getEndOfWeek(currentDate);
        cd.setValue1(startDate);
        cd.setValue2(endDate);
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        return cd;
    }

    public CohortDefinition getPatientsWithObsDuringDay(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        Date currentDate = new Date();
        Date startDate = DateUtil.getStartOfDay(currentDate);
        Date endDate = DateUtil.getEndOfDay(currentDate);
        cd.setValue1(startDate);
        cd.setValue2(endDate);
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        return cd;
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsByEndDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=endDate"));
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsByEndDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier,String olderThan) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWhoseObsValueAfterDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate"));
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDate(Concept dateConcept, List<EncounterType> types, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate-" + olderThan + ",value2=endDate-" + olderThan));
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsBetweenStartDateAndEndDatePlusMonths(Concept dateConcept, List<EncounterType> types, String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate+" + olderThan + ",value2=endDate+" + olderThan));
    }


    public CohortDefinition getPatientsWhoseMostRecentObsDateIsBetweenValuesByEndDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier, String olderThan, String onOrPriorTo) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        // cd.addParameter(new Parameter("onOrBefore", "onOrBefore", Date.class));
        Map<String, String> params = new HashMap<>();
        if (olderThan != null) {
            cd.setOperator1(RangeComparator.LESS_THAN);
            cd.addParameter(new Parameter("value1", "value1", Date.class));
            params.put("value1", "startDate-" + olderThan);
        }
        if (onOrPriorTo != null) {
            cd.setOperator2(RangeComparator.GREATER_EQUAL);
            cd.addParameter(new Parameter("value2", "value2", Date.class));
            params.put("value2", "startDate-" + onOrPriorTo);
        }
        return convert(cd, params);
    }

    public CohortDefinition getLostClients() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(30);
        cd.setMaximumDays(89);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }
    public CohortDefinition getPatientCurrentDSDMModel() {
        CurrentPatientDSDMModelCohortDefinition cd = new CurrentPatientDSDMModelCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getLastVisitInTheQuarter(Concept question, TimeModifier timeModifier) {
        HavingVisitCohortDefinition cd = new HavingVisitCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }




    public CohortDefinition getLostToFollowUp() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(90);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));

    }
    public CohortDefinition getEverLost() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(90);
        return cd;
    }

    public CohortDefinition getLost() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(7);
        cd.setMaximumDays(89);
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return convert(cd, ObjectUtil.toMap("endDate=endDate"));
    }

    /**
     * Cohort defines patients who have no had a appeared since their last
     * missed appoinment date for minimum days passed to the method
     * @param minimumDays
     * @return
     */
    public CohortDefinition getPatientsWhoHaveNotComeAfterTheirLastMissedAppointmentByMinimumDays(int minimumDays){
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(minimumDays);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }
    public CohortDefinition EarlyWarningIndicatorDataAbstractionCohort(Concept dateConcept,List<EncounterType> types,BaseObsCohortDefinition.TimeModifier timeModifier)
    {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=startDate,value2=endDate"));


    }

    public CohortDefinition getActiveInPeriodWithoutVisit() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMaximumDays(30);
        cd.addParameter(new Parameter("endDate", "Ending", Date.class));
        return convert(cd, ObjectUtil.toMap("endDate=endDate"));
    }

    public CohortDefinition getMissedAppointment() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(7);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getEnrolledOnDSDM() {
        DSDMCohortDefinition cd = new DSDMCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsWithGoodAdherenceForLast6Months() {
        DSDMAdherenceCohortDefinition cd = new DSDMAdherenceCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getOnClinicalStage1or2() {
        DSDMClinicalStage1or2CohortDefinition cd = new DSDMClinicalStage1or2CohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsVirallySupressedForLast12Months() {
        DSDMVirallySupressedCohortDefinition cd = new DSDMVirallySupressedCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getUnsupressedVLPatients() {
        DSDMUnsupressedVLCohortDefinition cd = new DSDMUnsupressedVLCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsOnArtForMoreThansMonths(Integer month) {
        ArtStartCohortDefinition cd = new ArtStartCohortDefinition();
        cd.setPeriodDifference(month);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getLostDuringPeriod() {
        PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition cd = new PatientsWhoDidntTurnupForScheduledAppointmentCohortDefinition();
        cd.setMinimumDays(7);
        cd.setMaximumDays(89);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getTextBasedObs(Concept question) {
        TextObsCohortDefinition cd = new TextObsCohortDefinition();
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.setQuestion(question);
        return cd;
    }

    public CohortDefinition getPatientsWhoNeverMissedAnyAppointment() {
        MissedAppointmentCohortDefinition cd = new MissedAppointmentCohortDefinition();
        return cd;
    }

    public CohortDefinition getWhoStartedArtDuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference) {
        ArtStartCohortDefinition cd = new ArtStartCohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getPregnantOrLactatingDuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference) {
        ArtPregnantCohortDefinition cd = new ArtPregnantCohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getStartedArtWithCD4DuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference, Boolean allBaseCD4) {
        ArtCD4CohortDefinition cd = new ArtCD4CohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.setAllBaseCD4(allBaseCD4);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getDeadPatientsOnArtBeforePeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference) {
        ArtFollowupDeadCohortDefinition cd = new ArtFollowupDeadCohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getStoppedPatientsOnArtDuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference) {
        ArtFollowupStoppedCohortDefinition cd = new ArtFollowupStoppedCohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getLostPatientsOnArtDuringPeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference, Boolean lostToFollowup) {
        ArtFollowupLostCohortDefinition cd = new ArtFollowupLostCohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.setLostToFollowup(lostToFollowup);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }

    public CohortDefinition getStartedArtWithCD4BeforePeriod(Enums.Period period, Enums.PeriodInterval periodInterval, Integer periodDifference, Boolean allBaseCD4) {
        ArtFollowupCD4CohortDefinition cd = new ArtFollowupCD4CohortDefinition();
        cd.setPeriodDifference(periodDifference);
        cd.setPeriod(period);
        cd.setPeriodInterval(periodInterval);
        cd.setAllBaseCD4(allBaseCD4);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate"));
    }




   /* public CohortDefinition getAtLeastOneMissedAfterArt() {
        return convert(Cohorts.getPatientsWithAtLeastOneMissedAppointmentAfterArtStartDate(), null);

    }

    public CohortDefinition getAtLeastOneScheduledAfterArt() {
        return convert(Cohorts.getPatientsWithAtLeastOneScheduledVisitAfterArtStartDate(), null);

    }*/

    public PatientDataDefinition createPatientDataDefinition(PersonDataDefinition personDataDefinition, DataConverter converter) {
        return convert(personDataDefinition, converter);
    }

    public PatientDataDefinition createPatientDataDefinition(PersonDataDefinition personDataDefinition, DataConverter converter, String parameters) {
        return convert(personDataDefinition, ObjectUtil.toMap(parameters), converter);
    }

    public PatientDataDefinition createPatientDataDefinition(PatientDataDefinition patientDataDefinition, DataConverter converter) {
        return convert(patientDataDefinition, converter);
    }

    public PatientDataDefinition createPatientDataDefinition(PatientDataDefinition patientDataDefinition, DataConverter converter, String parameters) {
        return convert(patientDataDefinition, ObjectUtil.toMap(parameters), converter);
    }

    public PatientDataDefinition createPatientDataDefinition(EncountersForPatientDataDefinition encountersForPatientDataDefinition, DataConverter converter) {
        return convert(encountersForPatientDataDefinition, converter);
    }

    public PatientDataDefinition createPatientDataDefinition(EncountersForPatientDataDefinition encountersForPatientDataDefinition, DataConverter converter, String parameters) {
        return convert(encountersForPatientDataDefinition, ObjectUtil.toMap(parameters), converter);
    }

    public CohortDefinition getPatientsWhoseObsValueDateIsAfterEndDate(Concept dateConcept, List<EncounterType> types, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=endDate"));
    }

    public CohortDefinition getPatientsWithLongRefills(){
        LongRefillsCohortDefinition cd = new LongRefillsCohortDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public CohortDefinition getPatientsWithNonSuppressedViralLoad(){
        NonSuppresssedViralLoadsDataDefinition cd = new NonSuppresssedViralLoadsDataDefinition();
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return convert(cd, ObjectUtil.toMap("startDate=startDate,endDate=endDate"));
    }

    public PatientDataDefinition getValueDatetimeObsOfEncounterDuringPeriod(Concept question, List<EncounterType> encounterTypes, TimeQualifier timeQualifier, DataConverter converter) {
        ObsForPersonDataDefinition def = PatientColumns.createObsForPersonData(question, encounterTypes, Arrays.asList("onOrBefore", "onOrAfter"), timeQualifier);
        return createPatientDataDefinition(def, converter, Parameters.combineParameters(Parameters.ON_OR_AFTER_START_DATE, Parameters.ON_OR_BEFORE_END_DATE));
    }

    public CohortDefinition getPatientsWithLastViralLoadDuringPeriodBetween(double lower, double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Viral Load Quantitative between "+lower+" and "+upper);
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(hivMetadata.getViralLoad());
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.LAST);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_THAN);
        cd.setValue2(upper);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ART_ENCOUNTER_PAGE)));
        return cd;
    }

    public CohortDefinition getPatientsWithLastViralLoadDuringPeriodByEndDate(double lower, double upper) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Viral Load Quantitative between "+lower+" and "+upper);
        cd.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        cd.setQuestion(hivMetadata.getViralLoadCopies());
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.LAST);
        cd.setOperator1(RangeComparator.GREATER_EQUAL);
        cd.setValue1(lower);
        cd.setOperator2(RangeComparator.LESS_THAN);
        cd.setValue2(upper);
        cd.setEncounterTypeList( Arrays.asList(hivMetadata.getARTEncounterEncounterType()));
        return convert(cd, ObjectUtil.toMap( ",onOrBefore=endDate" ));

    }

    public CohortDefinition getPatientsWhoseObsValueDateIsBetweenPastPeriodFromEndDate(Concept dateConcept, List<EncounterType> types,String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        DateObsCohortDefinition cd = new DateObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(dateConcept);
        cd.setEncounterTypeList(types);
        cd.setOperator1(RangeComparator.GREATER_THAN);
        cd.addParameter(new Parameter("value1", "value1", Date.class));
        cd.setOperator2(RangeComparator.LESS_EQUAL);
        cd.addParameter(new Parameter("value2", "value2", Date.class));
        return convert(cd, ObjectUtil.toMap("value1=endDate-"+olderThan +",value2=endDate"));
    }

    public CohortDefinition getPatientsWithNumericObsFromPastEndPeriodToEndDate(Concept question, List<EncounterType> restrictToTypes, RangeComparator operator, Double value,String olderThan, BaseObsCohortDefinition.TimeModifier timeModifier) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setTimeModifier(timeModifier);
        cd.setQuestion(question);
        cd.setEncounterTypeList(restrictToTypes);
        cd.setOperator1(operator);
        cd.setValue1(value);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(cd, ObjectUtil.toMap("onOrAfter=endDate-" + olderThan +",onOrBefore=endDate"));
    }

    public CohortDefinition getWorkFlowStateCohortDefinition(ProgramWorkflowState programWorkflowState) {
        InStateCohortDefinition icsd = new InStateCohortDefinition();
        icsd.addState(programWorkflowState);
        icsd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        icsd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return convert(icsd, ObjectUtil.toMap("onOrAfter=endDate,onOrBefore=endDate"));
    }

    public CohortDefinition getCohortDefinitionBySql(String sql) {
        SqlCohortDefinition cd = new SqlCohortDefinition(sql);
        cd.addParameter(new Parameter("startDate", "startDate", Date.class));
        cd.addParameter(new Parameter("endDate", "endDate", Date.class));
        return cd;
    }
}
