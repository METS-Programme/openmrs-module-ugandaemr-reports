package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.Concept;
import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CodedObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.common.SetComparator;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.metadata.TBMetadata;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary.getConcept;

/**
 *  TX Current Report
 */
@Component
public class SetupHMIS106A3_2Report extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    SetupMERTxNew2019Report setupTxNewReport;

    @Autowired
    TBCohortDefinitionLibrary tbCohortDefinitionLibrary;

    @Autowired
    HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private TBMetadata tbMetadata;

    @Autowired
    private HIVMetadata hivMetadata;

    @Autowired
    private CommonCohortDefinitionLibrary cohortDefinitionLibrary;



    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "f3ce09ce-ddbd-4562-8445-c529710bfe03";
    }

    @Override
    public String getUuid() {
        return "f741060c-2eaf-49cb-b929-4a14b3fe9194";
    }

    @Override
    public String getName() {
        return "HMIS 1061a 3.2 Report";
    }

    @Override
    public String getDescription() {
        return "HMIS 1061a 3.2 Report ";
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "106A3_2.xls");
    }



    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd1 = new CohortIndicatorDataSetDefinition();
        CohortIndicatorDataSetDefinition dsd2 = new CohortIndicatorDataSetDefinition();


        dsd.addDimension("type", Mapped.mapStraightThrough(getDimension()));


        rd.addDataSetDefinition("A", Mapped.mapStraightThrough(dsd));
        rd.addDataSetDefinition("B", Mapped.mapStraightThrough(dsd1));
        rd.addDataSetDefinition("C", Mapped.mapStraightThrough(dsd2));


        CohortDefinition males = cohortDefinitionLibrary.males();
        CohortDefinition females = cohortDefinitionLibrary.females();

        CohortDefinition registerd9to12MonthsAgo = tbCohortDefinitionLibrary.getPatientsInDRTBState("9m");
        CohortDefinition registerdDuringPeriod = tbCohortDefinitionLibrary.getPatientsInDRTBState();

        CohortDefinition newCaseTypePatients9to12MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("b3c43c5e-1987-42c1-a7b3-2c71dc58c126")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition newCaseTypePatientsDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("b3c43c5e-1987-42c1-a7b3-2c71dc58c126")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition treatedPreviouslyCaseTypePatients9to12MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("8b00c885-edec-47bf-8700-69913741f71c"),getConcept("8ad53c8c-e136-41e3-aab8-eace935a3bbe"),getConcept("a37462b6-1f47-4efb-8df5-2bdc742efc17"),getConcept("ce983c0e-cdea-42e2-b93f-5ad26fe05fba"),getConcept("11522b1b-59d3-4c1f-8a9a-5d780127e84f")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition previouslyTreatedWithFirstLineDrugsDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("ce983c0e-cdea-42e2-b93f-5ad26fe05fba")), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition previouslyTreatedWithSecondLineDrugsDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("11522b1b-59d3-4c1f-8a9a-5d780127e84f")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition patientsWhoAreHealthWorkers9monthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("5619AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreTBContacts9monthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("b5171d08-77bf-40a8-a864-51caa6cd2480")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition HIVPositive9MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("dc866728-30ab-102d-86b0-7a5022ba4115")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition RifampicinResistant = tbCohortDefinitionLibrary.getPatientWithRifampicinResitance("9");
        CohortDefinition IsoniazidResistant =  tbCohortDefinitionLibrary.getPatientWithIsonaizidResistant("9");
        CohortDefinition IsonaizidSus_ceptibility =df.getPatientsInAll(RifampicinResistant,df.getPatientsInAny(tbCohortDefinitionLibrary.getPatientWithIsonaizidSus_ceptibility("9"),IsoniazidResistant));
        CohortDefinition MDRPatients = df.getPatientsInAll(RifampicinResistant,IsoniazidResistant);

        CohortDefinition FQpatientsSus_ceptibility = tbCohortDefinitionLibrary.getPatientWithFQSus_ceptibility("9");
        CohortDefinition SLInjectable_patientsSus_ceptibility = tbCohortDefinitionLibrary.getPatientWithSL_InjectableSus_ceptibility("9");
        CohortDefinition FQpatientsResistant = tbCohortDefinitionLibrary.getPatientWithFQResistant("9");
        CohortDefinition SLInjectable_patientsResistant = tbCohortDefinitionLibrary.getPatientWithSl_InjectableResistant("9");
        CohortDefinition RR_MDRPatients = df.getPatientsInAll(MDRPatients,df.getPatientsInAny(FQpatientsSus_ceptibility,FQpatientsResistant,SLInjectable_patientsResistant,SLInjectable_patientsSus_ceptibility));
        CohortDefinition RR_WithFQResistanceAndSL_InjectablePatients = df.getPatientsInAll(RifampicinResistant,FQpatientsResistant,SLInjectable_patientsResistant);
        CohortDefinition RR_WithFQResistancePatients = df.getPatientsInAll(RifampicinResistant,FQpatientsResistant);
        CohortDefinition RR_WithSL_InjectableResistancePatients = df.getPatientsInAll(RifampicinResistant,SLInjectable_patientsResistant);
        CohortDefinition MDR_WithFQResistance = df.getPatientsInAll(MDRPatients,FQpatientsResistant);
        CohortDefinition MDR_WithSLResistance = df.getPatientsInAll(MDRPatients,SLInjectable_patientsResistant);
        CohortDefinition MDR_WithFQResistanceAndSLResistance = df.getPatientsInAll(MDRPatients,SLInjectable_patientsResistant,FQpatientsResistant);


        CohortDefinition hivStatusInDRRegisterDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f"),tbMetadata.getDRTBEnrollmentEncounterType(), BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition hivStatusPositiveInDRRegisterDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("dc866728-30ab-102d-86b0-7a5022ba4115")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition startedonARTDuringPeriod = df.getPatientsWithCodedObsDuringPeriod(getConcept("6bd7bb95-343a-42ce-801f-d6876e263c57"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(tbMetadata.getConcept("1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.ANY);

        CohortDefinition bacteriologicallyXDRMDRConfirmed = tbCohortDefinitionLibrary.getPatientsWithBacteriallyConfirmedMDRXDRRRDuringPeriod();
        CohortDefinition presumptiveMDRXDRR = tbCohortDefinitionLibrary.getPatientsWithPresumptiveMDRXDRRRDuringPeriod();

        CohortDefinition bacteriologicallyConfirmedAndNew =df.getPatientsInAll(newCaseTypePatientsDuringPeriod,bacteriologicallyXDRMDRConfirmed);
        CohortDefinition bacteriologicallyConfirmedAndPreviousOnFirstLine =df.getPatientsInAll(previouslyTreatedWithFirstLineDrugsDuringPeriod,bacteriologicallyXDRMDRConfirmed);
        CohortDefinition bacteriologicallyConfirmedAndPreviousOnSecondLine =df.getPatientsInAll(previouslyTreatedWithSecondLineDrugsDuringPeriod,bacteriologicallyXDRMDRConfirmed);

        CohortDefinition presumptiveMDRXDRRAndNew =df.getPatientsInAll(newCaseTypePatientsDuringPeriod,presumptiveMDRXDRR);
        CohortDefinition presumptiveMDRXDRRAndPreviousOnFirstLine =df.getPatientsInAll(previouslyTreatedWithFirstLineDrugsDuringPeriod,presumptiveMDRXDRR);
        CohortDefinition presumptiveMDRXDRRAndPreviousOnSecondLine =df.getPatientsInAll(previouslyTreatedWithSecondLineDrugsDuringPeriod,presumptiveMDRXDRR);


        addIndicator(dsd1,"6a","6a",df.getPatientsInAll(bacteriologicallyConfirmedAndNew,females),"");
        addIndicator(dsd1,"6b","6b",df.getPatientsInAll(bacteriologicallyConfirmedAndNew,males),"");
        addIndicator(dsd1,"6c","6c",bacteriologicallyConfirmedAndNew,"");
        addIndicator(dsd1,"6d","6d",df.getPatientsInAll(bacteriologicallyConfirmedAndPreviousOnFirstLine,females),"");
        addIndicator(dsd1,"6e","6e",df.getPatientsInAll(bacteriologicallyConfirmedAndPreviousOnFirstLine,males),"");
        addIndicator(dsd1,"6f","6f",bacteriologicallyConfirmedAndPreviousOnFirstLine,"");
        addIndicator(dsd1,"6g","6g",df.getPatientsInAll(bacteriologicallyConfirmedAndPreviousOnSecondLine,females),"");
        addIndicator(dsd1,"6h","6h",df.getPatientsInAll(bacteriologicallyConfirmedAndPreviousOnSecondLine,males),"");
        addIndicator(dsd1,"6i","6i",bacteriologicallyConfirmedAndPreviousOnSecondLine,"");

        addIndicator(dsd1,"7a","7a",df.getPatientsInAll(presumptiveMDRXDRRAndNew,females),"");
        addIndicator(dsd1,"7b","7b",df.getPatientsInAll(presumptiveMDRXDRRAndNew,males),"");
        addIndicator(dsd1,"7c","7c",presumptiveMDRXDRRAndNew,"");
        addIndicator(dsd1,"7d","7d",df.getPatientsInAll(presumptiveMDRXDRRAndPreviousOnFirstLine,females),"");
        addIndicator(dsd1,"7e","7e",df.getPatientsInAll(presumptiveMDRXDRRAndPreviousOnFirstLine,males),"");
        addIndicator(dsd1,"7f","7f",presumptiveMDRXDRRAndPreviousOnFirstLine,"");
        addIndicator(dsd1,"7g","7g",df.getPatientsInAll(presumptiveMDRXDRRAndPreviousOnSecondLine,females),"");
        addIndicator(dsd1,"7h","7h",df.getPatientsInAll(presumptiveMDRXDRRAndPreviousOnSecondLine,males),"");
        addIndicator(dsd1,"7i","7i",presumptiveMDRXDRRAndPreviousOnSecondLine,"");

        addIndicator(dsd2,"8a","8a",df.getPatientsInAll(bacteriologicallyXDRMDRConfirmed,hivStatusInDRRegisterDuringPeriod),"");
        addIndicator(dsd2,"9a","9a",df.getPatientsInAll(presumptiveMDRXDRR,hivStatusInDRRegisterDuringPeriod),"");

        addIndicator(dsd2,"8b","8b",df.getPatientsInAll(bacteriologicallyXDRMDRConfirmed,hivStatusPositiveInDRRegisterDuringPeriod),"");
        addIndicator(dsd2,"9b","9b",df.getPatientsInAll(presumptiveMDRXDRR,hivStatusPositiveInDRRegisterDuringPeriod),"");

        addIndicator(dsd2,"8c","8c",df.getPatientsInAll(bacteriologicallyXDRMDRConfirmed,startedonARTDuringPeriod),"");
        addIndicator(dsd2,"9c","9c",df.getPatientsInAll(presumptiveMDRXDRR,startedonARTDuringPeriod),"");

        add1AIndicators(dsd,"a","DR 01 ",registerd9to12MonthsAgo);
        add1AIndicators(dsd,"b","DR 02",RifampicinResistant);
        add1AIndicators(dsd,"c","DR 03",IsonaizidSus_ceptibility);
        add1AIndicators(dsd,"d","DR04 ",MDRPatients);
        add1AIndicators(dsd,"e","DR05 ",RR_MDRPatients);
        add1AIndicators(dsd,"f","DR06 ",RR_WithFQResistanceAndSL_InjectablePatients);
        add1AIndicators(dsd,"g","DR07 ",RR_WithFQResistancePatients);
        add1AIndicators(dsd,"h","DR08 ",RR_WithSL_InjectableResistancePatients);
        add1AIndicators(dsd,"i","DR09 ",MDR_WithFQResistance);
        add1AIndicators(dsd,"j","DR10 ",MDR_WithSLResistance);
        add1AIndicators(dsd,"k","DR11 ",MDR_WithFQResistanceAndSLResistance);


        return rd;
    }



    public void add1AIndicators(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition) {
        addIndicator(dsd, "1"+key , label + " new ", cohortDefinition, "type=newPatients");
        addIndicator(dsd, "2"+key , label + " previouslyTreated", cohortDefinition, "type=previouslyTreated");
        addIndicator(dsd, "3"+key , label + " DRTBContacts", cohortDefinition, "type=DRTBContacts");
        addIndicator(dsd, "4"+key , label + " HealthWorker", cohortDefinition, "type=HealthWorker");
        addIndicator(dsd, "5"+key , label + " HIVPositive", cohortDefinition, "type=HIVPositive");
        }

    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition, String dimensionOptions) {
        CohortIndicator ci = new CohortIndicator();
        ci.addParameter(ReportingConstants.START_DATE_PARAMETER);
        ci.addParameter(ReportingConstants.END_DATE_PARAMETER);
        ci.setType(CohortIndicator.IndicatorType.COUNT);
        ci.setCohortDefinition(Mapped.mapStraightThrough(cohortDefinition));
        dsd.addColumn(key, label, Mapped.mapStraightThrough(ci), dimensionOptions);
    }

    public CohortDefinitionDimension getDimension(){
        CohortDefinitionDimension patientTypeDimension= new CohortDefinitionDimension();

        CohortDefinition newCaseTypePatients9to12MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("b3c43c5e-1987-42c1-a7b3-2c71dc58c126")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition treatedPreviouslyCaseTypePatients9to12MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(hivMetadata.getConcept("e077f196-c19a-417f-adc6-b175a3343bfd"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("8b00c885-edec-47bf-8700-69913741f71c"),getConcept("8ad53c8c-e136-41e3-aab8-eace935a3bbe"),getConcept("a37462b6-1f47-4efb-8df5-2bdc742efc17"),getConcept("ce983c0e-cdea-42e2-b93f-5ad26fe05fba"),getConcept("11522b1b-59d3-4c1f-8a9a-5d780127e84f")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreHealthWorkers9monthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("5619AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition patientsWhoAreTBContacts9monthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getRiskGroup(),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("b5171d08-77bf-40a8-a864-51caa6cd2480")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);
        CohortDefinition HIVPositive9MonthsAgo = df.getPatientsWithCodedObsDuringPeriod(tbMetadata.getConcept("29c47b5c-b27d-499c-b52c-7be676a0a78f"),tbMetadata.getDRTBEnrollmentEncounterType(),Arrays.asList(getConcept("dc866728-30ab-102d-86b0-7a5022ba4115")),"9m", BaseObsCohortDefinition.TimeModifier.ANY);

        patientTypeDimension.addParameter(ReportingConstants.START_DATE_PARAMETER);
        patientTypeDimension.addParameter(ReportingConstants.END_DATE_PARAMETER);

        patientTypeDimension.addCohortDefinition("newPatients", Mapped.mapStraightThrough(newCaseTypePatients9to12MonthsAgo));
        patientTypeDimension.addCohortDefinition("previouslyTreated", Mapped.mapStraightThrough(treatedPreviouslyCaseTypePatients9to12MonthsAgo));
        patientTypeDimension.addCohortDefinition("DRTBContacts", Mapped.mapStraightThrough(patientsWhoAreTBContacts9monthsAgo));
        patientTypeDimension.addCohortDefinition("HealthWorker", Mapped.mapStraightThrough(patientsWhoAreHealthWorkers9monthsAgo));
        patientTypeDimension.addCohortDefinition("HIVPositive", Mapped.mapStraightThrough(HIVPositive9MonthsAgo));

        return patientTypeDimension;
    }

        @Override
    public String getVersion() {
        return "0.1.4";
    }
}
