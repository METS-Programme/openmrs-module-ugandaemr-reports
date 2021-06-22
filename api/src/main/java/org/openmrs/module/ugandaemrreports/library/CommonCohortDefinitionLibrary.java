package org.openmrs.module.ugandaemrreports.library;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.openmrs.Concept;
import org.openmrs.EncounterType;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.reporting.cohort.definition.AgeCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CodedObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.EncounterCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.GenderCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.NumericObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.TextObsCohortDefinition;
import org.openmrs.module.reporting.common.DurationUnit;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.RangeComparator;
import org.openmrs.module.reporting.common.SetComparator;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.definition.library.BaseDefinitionLibrary;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Metadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Library of common Cohort definitions
 */
@Component
public class CommonCohortDefinitionLibrary extends BaseDefinitionLibrary<CohortDefinition> {

    @Autowired
    private DataFactory df;

    @Override
    public Class<? super CohortDefinition> getDefinitionType() {
        return CohortDefinition.class;
    }

    @Override
    public String getKeyPrefix() {
        return "ugemr.cohort.common.";
    }

    /**
     * Patients who are female
     *
     * @return the cohort definition
     */
    public CohortDefinition females() {
        GenderCohortDefinition cd = new GenderCohortDefinition();
        cd.setName("Females");
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        cd.setFemaleIncluded(true);
        return cd;
    }

    /**
     * Patients who are male
     *
     * @return the cohort definition
     */
    public CohortDefinition males() {
        GenderCohortDefinition cd = new GenderCohortDefinition();
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        cd.setName("Males");
        cd.setMaleIncluded(true);
        return cd;
    }

    /**
     * Patients who at most maxAge years old on ${effectiveDate}
     *
     * @return the cohort definition
     */
    public CohortDefinition agedAtMost(int maxAge) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.setName("aged at most " + maxAge);
        cd.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        cd.setMaxAge(maxAge);
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        return df.convert(cd, ObjectUtil.toMap("effectiveDate=endDate"));
    }

    public CohortDefinition agedAtMost(int maxAge, String olderThan) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.setName("aged at most " + maxAge);
        cd.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        cd.setMaxAge(maxAge);
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        return df.convert(cd, ObjectUtil.toMap("effectiveDate=endDate-"+olderThan));
    }

    public AgeCohortDefinition agedAtMost(int maxAge, Date effectiveDate) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.setEffectiveDate(effectiveDate);
        cd.setMaxAge(maxAge);
        return cd;
    }

    /**
     * Patients who are at least minAge years old on ${effectiveDate}
     *
     * @return the cohort definition
     */
    public CohortDefinition agedAtLeast(int minAge) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        cd.setMinAge(minAge);
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        return df.convert(cd, ObjectUtil.toMap("effectiveDate=endDate"));
    }


    public AgeCohortDefinition agedAtLeast(int minAge, Date effectiveDate) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.setEffectiveDate(effectiveDate);
        cd.setMinAge(Integer.valueOf(minAge));
        return cd;
    }

    /**
     * Patients who are at least minAge years old and are not more than maxAge on ${effectiveDate}
     *
     * @return the cohort definition
     */
    public CohortDefinition agedBetween(int minAge, int maxAge) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        cd.setMinAge(minAge);
        cd.setMaxAge(maxAge);
        return df.convert(cd, ObjectUtil.toMap("effectiveDate=endDate"));
    }
    public AgeCohortDefinition agedBetween(int minAge, int maxAge, Date effectiveDate) {
        AgeCohortDefinition cd = new AgeCohortDefinition();
        cd.setEffectiveDate(effectiveDate);
        cd.setMinAge(Integer.valueOf(minAge));
        cd.setMaxAge(Integer.valueOf(maxAge));
        return cd;
    }

    public CohortDefinition below6months() {
        AgeCohortDefinition cd = (AgeCohortDefinition) agedAtMost(6);
        cd.setMinAgeUnit(DurationUnit.MONTHS);
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        return cd;
    }

    public CohortDefinition below2Years() {
        return agedAtMost(1);
    }
    public CohortDefinition below5Years() {
        return agedAtMost(4);
    }

    public CohortDefinition between6And59months() {
        AgeCohortDefinition cd = (AgeCohortDefinition) agedBetween(6, 59);
        cd.setMinAgeUnit(DurationUnit.MONTHS);
        cd.setMaxAgeUnit(DurationUnit.MONTHS);
        UUID uuid = UUID.randomUUID();
        cd.setUuid(String.valueOf(uuid));
        return cd;
    }

    public CohortDefinition between0And4years() {
        return agedAtMost(4);
    }

    public CohortDefinition between2And5Years() {
        return agedBetween(2, 4);
    }

    public CohortDefinition between5And14Years() {
        return agedBetween(5, 14);
    }

    public CohortDefinition between15And49Years() {
        return agedBetween(14, 49);
    }

    public CohortDefinition above15Years() {
        return agedAtLeast(15);
    }

    public CohortDefinition above50Years() {
        return agedAtLeast(50);
    }

    public CohortDefinition between0And10years() {
        return agedAtMost(10);
    }

    public CohortDefinition below10Years() {
        return agedAtMost(9);
    }
    
    /**
     * MoH definition of children who is anybody 14 years and below
     * @return
     */
    public CohortDefinition MoHChildren(){
        return agedAtMost(14);
    }
    
    /**
     * MoH definition of adults who are 15 years and older
     * @return
     */
    public CohortDefinition MoHAdult(){
        return agedAtLeast(15);
    }

    public CohortDefinition above10years() {
        return agedAtLeast(11);
    }

//    Finer Age Disaggregation
    public CohortDefinition between1And4years() {
        return agedBetween(1,4);
    }
    public CohortDefinition between5And9years() {
        return agedBetween(5,9);
    }
    public CohortDefinition between10And14years() {
        return agedBetween(10,14);
    }
    public CohortDefinition between15And19years() {
        return agedBetween(15,19);
    }
    public CohortDefinition between20And24years() {
        return agedBetween(20,24);
    }
    public CohortDefinition between25And29years() {
        return agedBetween(25,29);
    }
    public CohortDefinition between30And34years() {
        return agedBetween(30,34);
    }
    public CohortDefinition between35And39years() {
        return agedBetween(35,39);
    }
    public CohortDefinition between40And44years() { return agedBetween(40,44); }
    public CohortDefinition between45And49years() { return agedBetween(45,49); }
    public CohortDefinition between40And49years() { return agedBetween(40,49); }
    public CohortDefinition between25And49years() {
        return agedBetween(25,49);
    }

    public CohortDefinition between10And19years() {
        return agedBetween(10,19);
    }
    public CohortDefinition is25AndAboveyears() {
        return agedAtLeast(25);
    }



    public CohortDefinition below1Year() {
        return   agedBetween(0,0);
    }

    /**
     * Patients who have an obs between ${onOrAfter} and ${onOrBefore}
     * @param question the question concept
     * @param answers the answers to include
     * @return the cohort definition
     */
    public CohortDefinition hasObs(Concept question, Concept... answers) {       
		return hasObs(question, Arrays.asList(answers));
    }

    /**
     * Patients who have an obs between ${onOrAfter} and ${onOrBefore}
     * @param question the question concept
     * @param the answers to include as an ArrayList
     * @return the cohort definition
     */
	public CohortDefinition hasObs(Concept question, List<Concept> answers) {
        CodedObsCohortDefinition cd = new CodedObsCohortDefinition();
        cd.setName("has obs between dates");
        cd.setQuestion(question);
        cd.setOperator(SetComparator.IN);
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.addParameter(new Parameter("onOrBefore", "Before Date", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "After Date", Date.class));
        if (answers.size() > 0) {
            cd.setValueList(answers);
        }
        return cd;
	}    
    
    /**
     * Patients who have a text obs between ${onOrAfter} and ${onOrBefore}
     * @param question the question concept
     * @param answers the answers to include
     * @return the cohort definition
     */
    public CohortDefinition hasANCObs(Concept question, Concept... answers) {
        CodedObsCohortDefinition cd = (CodedObsCohortDefinition) hasObs(question, answers);
        cd.setEncounterTypeList(Arrays.asList(MetadataUtils.existing(EncounterType.class, Metadata.EncounterType.ANC_ENCOUNTER)));
        
        return cd;
    }

    /**
     * Patients who have an encounter between ${onOrAfter} and ${onOrBefore}
     * @param types the encounter types
     * @return the cohort definition
     */
    public CohortDefinition hasEncounter(EncounterType... types) {
        EncounterCohortDefinition cd = new EncounterCohortDefinition();
        cd.setName("has encounter between dates");
        cd.setTimeQualifier(TimeQualifier.ANY);
        cd.addParameter(new Parameter("onOrBefore", "Before Date", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "After Date", Date.class));
        if (types.length > 0) {
            cd.setEncounterTypeList(Arrays.asList(types));
        }
        return cd;
    }
    
    public CohortDefinition hasTextObs(Concept question, String... answers) {
        TextObsCohortDefinition cd = new TextObsCohortDefinition();
        cd.setName("has obs between dates");
        cd.setQuestion(question);
        cd.setOperator(SetComparator.IN);
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.addParameter(new Parameter("onOrBefore", "Before Date", Date.class));
        cd.addParameter(new Parameter("onOrAfter", "After Date", Date.class));
        if (answers.length > 0) {
            cd.setValueList(Arrays.asList(answers));
        }
        return cd;
    }
    
    /**
     * Patients who have a numeric obs between ${onOrAfter} and ${onOrBefore}
     * @param question the question concept
     * @param Operator 1
     * @param Value 1
     * @param Operator 2
     * @param Value 2
     * @return the cohort definition
     */
    public CohortDefinition hasNumericObs(Concept question, RangeComparator operator1, Double value1, RangeComparator operator2, Double value2) {
        NumericObsCohortDefinition cd = new NumericObsCohortDefinition();
        cd.setName("Has obs between dates");
        cd.setQuestion(question);
        cd.setOperator1(operator1);
        cd.setValue1(value1);
        if ( operator2 != null) {
        	cd.setOperator2(operator2);
        }
        if ( value2 != null) {
        	cd.setValue2(value2);
        }
        cd.setTimeModifier(BaseObsCohortDefinition.TimeModifier.ANY);
        cd.addParameter(new Parameter("onOrAfter", "On or After", Date.class));
        cd.addParameter(new Parameter("onOrBefore", "On or Before", Date.class));
        return cd;    	
    }
    
    /**
     * Patients who have a numeric obs between ${onOrAfter} and ${onOrBefore}
     * @param question the question concept
     * @param Operator 1
     * @param Value 1
     * @return the cohort definition
     */
    public CohortDefinition hasNumericObs(Concept question, RangeComparator operator1, Double value1) {
        return hasNumericObs(question, operator1, value1, null, null);
    }    
    
}
