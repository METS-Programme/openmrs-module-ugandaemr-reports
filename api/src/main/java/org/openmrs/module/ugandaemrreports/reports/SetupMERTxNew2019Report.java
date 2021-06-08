package org.openmrs.module.ugandaemrreports.reports;

import org.openmrs.module.reporting.ReportingConstants;
import org.openmrs.module.reporting.cohort.definition.BaseObsCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.openmrs.module.ugandaemrreports.reporting.library.cohort.ARTCohortLibrary;
import org.openmrs.module.ugandaemrreports.reporting.metadata.Dictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.Cohorts.transferIn;

/**
 *  TX Current Report
 */
@Component
public class SetupMERTxNew2019Report extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;

    @Autowired
    ARTClinicCohortDefinitionLibrary hivCohorts;
    @Autowired
    private HIVCohortDefinitionLibrary hivCohortDefinitionLibrary;

    @Autowired
    private CommonCohortDefinitionLibrary cohortDefinitionLibrary;

    @Autowired
    private CommonDimensionLibrary commonDimensionLibrary;

    @Autowired
    private ARTCohortLibrary artCohortLibrary;

    @Autowired
    private HIVMetadata hivMetadata;


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "df5cfe63-f5c0-4b95-bdc9-f5767dc1ba17";
    }

    public String getJSONDesignUuid() {
        return "bb0d79b3-1c85-4d27-8902-c4f901f85968";
    }

    @Override
    public String getUuid() {
        return "65fec0844-1970-43c5-bf77-b296415daa34";
    }

    @Override
    public String getName() {
        return "MER Indicator Report For Tx New 2019 ";
    }

    @Override
    public String getDescription() {
        return "Tx New Report 2019";
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
        return Arrays.asList(buildReportDesign(reportDefinition),buildJSONReportDesign(reportDefinition));
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
        return createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MER_TX_NEW_2019.xls");
    }

    public ReportDesign buildJSONReportDesign(ReportDefinition reportDefinition) {
        return createJSONTemplateDesign(getJSONDesignUuid(), reportDefinition, "MER_TX_NEW_2019.json");
    }

    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();

        dsd.setParameters(getParameters());
        rd.addDataSetDefinition("TX_NEW", Mapped.mapStraightThrough(dsd));

        CohortDefinitionDimension ageDimension = commonDimensionLibrary.getTxNewAgeGenderGroup();
        dsd.addDimension("age", Mapped.mapStraightThrough(ageDimension));

        CohortDefinition males = cohortDefinitionLibrary.males();
        CohortDefinition females = cohortDefinitionLibrary.females();

        CohortDefinition havingArtStartDateDuringQuarter = df.getPatientsNotIn(hivCohortDefinitionLibrary.getArtStartDateBetweenPeriod(),transferIn());
        CohortDefinition lactating = addParameters(artCohortLibrary.lactatingAtARTStart());


        CohortDefinition lactatingAtStartOfArt = df.getPatientsInAll(lactating, havingArtStartDateDuringQuarter);

        CohortDefinition PWIDS = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("927563c5-cb91-4536-b23c-563a72d3f829"),hivMetadata.getARTSummaryPageEncounterType(),
                Arrays.asList(Dictionary.getConcept("160666AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);

        CohortDefinition PIPS = df.getPatientsWithCodedObsDuringPeriod(Dictionary.getConcept("927563c5-cb91-4536-b23c-563a72d3f829"),hivMetadata.getARTSummaryPageEncounterType(),
                Arrays.asList(Dictionary.getConcept("162277AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")), BaseObsCohortDefinition.TimeModifier.LAST);

        addGender(dsd, "a", "All Newly started  on ART ", havingArtStartDateDuringQuarter);
        addGender(dsd, "b", "All Newly started  on ART ", havingArtStartDateDuringQuarter);


        addIndicator(dsd, "LAC", "Lactating At start on Art", lactatingAtStartOfArt, "");
        addIndicator(dsd, "TOTAL", "Total At start on Art", havingArtStartDateDuringQuarter, "");

        addIndicator(dsd,"PWIDSf","PWIDs TX Curr on ART female",df.getPatientsInAll(females,PWIDS,havingArtStartDateDuringQuarter),"");
        addIndicator(dsd,"PWIDSm","PWIDs TX Curr on ART male",df.getPatientsInAll(males,PWIDS,havingArtStartDateDuringQuarter),"");

       addIndicator(dsd,"PIPf","PIPs TX Curr on ART female",df.getPatientsInAll(females,PIPS,havingArtStartDateDuringQuarter),"");
       addIndicator(dsd,"PIPm","PIPs TX Curr on ART male",df.getPatientsInAll(males,PIPS,havingArtStartDateDuringQuarter),"");

        addIndicator(dsd,"PWIDS","PWIDs TX Curr on ART",df.getPatientsInAll(PWIDS,havingArtStartDateDuringQuarter),"");
        addIndicator(dsd,"PIPS","PIPs TX Curr on ART",df.getPatientsInAll(PIPS,havingArtStartDateDuringQuarter),"");
       addIndicator(dsd,"TOTAL_KP","TOTAL KP",df.getPatientsInAll(df.getPatientsInAny(PIPS,PWIDS),havingArtStartDateDuringQuarter),"");


        return rd;
    }

    public void addGender(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition) {
        if (key == "a") {
            addIndicator(dsd, "2" + key, label, cohortDefinition, "age=below1female");
            addIndicator(dsd, "3" + key, label, cohortDefinition, "age=between1and4female");
            addIndicator(dsd, "4" + key, label, cohortDefinition, "age=between5and9female");
            addIndicator(dsd, "5" + key, label, cohortDefinition, "age=between10and14female");
            addIndicator(dsd, "6" + key, label, cohortDefinition, "age=between15and19female");
            addIndicator(dsd, "7" + key, label, cohortDefinition, "age=between20and24female");
            addIndicator(dsd, "8" + key, label, cohortDefinition, "age=between25and29female");
            addIndicator(dsd, "9" + key, label, cohortDefinition, "age=between30and34female");
            addIndicator(dsd, "10" + key, label, cohortDefinition, "age=between35and39female");
            addIndicator(dsd, "11" + key, label, cohortDefinition, "age=between40and44female");
            addIndicator(dsd, "12" + key, label, cohortDefinition, "age=between45and49female");
            addIndicator(dsd, "13" + key, label, cohortDefinition, "age=above50female");
        } else if (key == "b") {
            addIndicator(dsd, "2" + key, label, cohortDefinition, "age=below1male");
            addIndicator(dsd, "3" + key, label, cohortDefinition, "age=between1and4male");
            addIndicator(dsd, "4" + key, label, cohortDefinition, "age=between5and9male");
            addIndicator(dsd, "5" + key, label, cohortDefinition, "age=between10and14male");
            addIndicator(dsd, "6" + key, label, cohortDefinition, "age=between15and19male");
            addIndicator(dsd, "7" + key, label, cohortDefinition, "age=between20and24male");
            addIndicator(dsd, "8" + key, label, cohortDefinition, "age=between25and29male");
            addIndicator(dsd, "9" + key, label, cohortDefinition, "age=between30and34male");
            addIndicator(dsd, "10" + key, label, cohortDefinition, "age=between35and39male");
            addIndicator(dsd, "11" + key, label, cohortDefinition, "age=between40and44male");
            addIndicator(dsd, "12" + key, label, cohortDefinition, "age=between45and49male");
            addIndicator(dsd, "13" + key, label, cohortDefinition, "age=above50male");
        }
    }


    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortDefinition cohortDefinition, String dimensionOptions) {
        CohortIndicator ci = new CohortIndicator();
        ci.addParameter(ReportingConstants.START_DATE_PARAMETER);
        ci.addParameter(ReportingConstants.END_DATE_PARAMETER);
        ci.setType(CohortIndicator.IndicatorType.COUNT);
        ci.setCohortDefinition(Mapped.mapStraightThrough(cohortDefinition));
        dsd.addColumn(key, label, Mapped.mapStraightThrough(ci), dimensionOptions);
    }


    public CohortDefinition addParameters(CohortDefinition cohortDefinition) {
        return df.convert(cohortDefinition, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate"));
    }

    @Override
    public String getVersion() {
        return "0.1.7";
    }
}