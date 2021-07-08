package org.openmrs.module.ugandaemrreports.reports2019;

import org.openmrs.module.reporting.dataset.definition.CohortIndicatorDataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.CohortIndicator;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.library.*;
import org.openmrs.module.ugandaemrreports.reporting.library.dimension.CommonReportDimensionLibrary;
import org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils;
import org.openmrs.module.ugandaemrreports.reports.UgandaEMRDataExportManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.period;
import static org.openmrs.module.ugandaemrreports.library.CommonDatasetLibrary.settings;


@Component

public class SetupMOH105ANC2019Report extends UgandaEMRDataExportManager {

    @Autowired
    private DataFactory df;


    @Autowired
    private CommonReportDimensionLibrary dimensionLibrary;

    @Autowired
    private Moh105IndicatorLibrary indicatorLibrary;

    private static final String PARAMS = "startDate=${startDate},endDate=${endDate}";


    /**
     * @return the uuid for the report design for exporting to Excel
     */
    @Override
    public String getExcelDesignUuid() {
        return "aa23c2b1-ca83-47fb-9846-b16294fc03d6";
    }


    @Override
    public String getUuid() {
        return "caec6908-72e1-4978-8007-13c551d23e5f";
    }

    @Override
    public String getName() {
        return "HMIS 105 Section 2: ANTENANTAL ";
    }

    @Override
    public String getDescription() {
        return "HMIS 105 Section 2: ANTENANTAL";
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
//        l.add(buildJSONReportDesign(reportDefinition));

        return l;
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
        ReportDesign rd = createExcelTemplateDesign(getExcelDesignUuid(), reportDefinition, "MOH105ANCSection_2019.xls");
        return rd;
    }




    @Override
    public ReportDefinition constructReportDefinition() {

        ReportDefinition rd = new ReportDefinition();

        rd.setUuid(getUuid());
        rd.setName(getName());
        rd.setDescription(getDescription());
        rd.setParameters(getParameters());

        rd.addDataSetDefinition("S", Mapped.mapStraightThrough(settings()));
        rd.addDataSetDefinition("105", Mapped.mapStraightThrough(antentalDataSetDefinition()));
        rd.addDataSetDefinition("P", Mapped.mapStraightThrough(period()));
        return rd;

    }

    protected DataSetDefinition antentalDataSetDefinition() {
        CohortIndicatorDataSetDefinition dsd = new CohortIndicatorDataSetDefinition();
        dsd.setParameters(getParameters());
        dsd.addDimension("age", ReportUtils.map(dimensionLibrary.ANCAgeGroups(), "effectiveDate=${endDate}"));
        dsd.addDimension("gender", ReportUtils.map(dimensionLibrary.gender()));

        dsd.addParameter(new Parameter("startDate", "Start Date", Date.class));
        dsd.addParameter(new Parameter("endDate", "End Date", Date.class));


        addRowWithColumns(dsd, "AN01","Number of females with a first ANC Visit ",indicatorLibrary.ANCFirstContact() );
        addRowWithColumns(dsd, "AN02","Number of females with a fourth contact  ANC Visit ",indicatorLibrary.ANCFourthVisit());
        addRowWithColumns(dsd, "AN03","Number of females with a fourth plus contact  ANC Visit ",indicatorLibrary.ANCVisitFourthPlus());
        addRowWithColumns(dsd, "AN04","Number of females with a fourth plus contact  ANC Visit ",indicatorLibrary.ANCEighthVisit());
        addRowWithColumns(dsd, "AN05","Total Number of Visits for both old and new ",indicatorLibrary.totalANCVisits());

        //Referals to ANC Unit
        addRowWithColumns(dsd, "AN06","Total Referals to ANC Unit ",indicatorLibrary.referalToAncUnitTotal());
        addRowWithColumns(dsd, "AN07","Total Referals to ANC Unit ",indicatorLibrary.referalToAncUnitFromCommunityServices());

        //Referals from ANC Unit
        addRowWithColumns(dsd, "AN08","Total Referals to ANC Unit ",indicatorLibrary.referalFromAncUnitTotal());
        addRowWithColumns(dsd, "AN09","Total Referals to ANC Unit ",indicatorLibrary.referalFromAncUnitFSG());

        //Pregnant Mothers on IPT treatement
        addRowWithColumns(dsd, "AN10","Pregnant Mothers on IPT First Dose",indicatorLibrary.iptFirstDosage());
        addRowWithColumns(dsd, "AN11","Pregnant Mothers on IPT Second Dose ",indicatorLibrary.iptSecondDosage());
        addRowWithColumns(dsd, "AN12","Pregnant Mothers on IPT third Dose ",indicatorLibrary.iptThirdDosage());
        addRowWithColumns(dsd, "AN13","Pregnant Mothers on IPT fourth Dose ",indicatorLibrary.iptFourthDosage());

        //Clients screened for TB
        addRowWithColumns(dsd, "AN14","Pregnant Mothers Screened for TB",indicatorLibrary.pregnantAndTestedforTB());
        addRowWithColumns(dsd, "AN15","Pregnant Mothers Diagonised  for TB",indicatorLibrary.tbPresumptive());
        addRowWithColumns(dsd, "AN16","Pregnant Mothers Diagonised  for TB",indicatorLibrary.pregnantandDiagnisedWithTB());

        //Clients Blood Group
        addRowWithColumns(dsd, "AN17","Pregnant Mothers with Blood Group O",indicatorLibrary.totalBloodGroupO());
        addRowWithColumns(dsd, "AN18","Pregnant Mothers with Blood Group O+",indicatorLibrary.bloodGroupOPositive());
        addRowWithColumns(dsd, "AN19","Pregnant Mothers with Blood Group A",indicatorLibrary.totalBloodGroupA());
        addRowWithColumns(dsd, "AN20","Pregnant Mothers with Blood Group A+",indicatorLibrary.bloodGroupAPositive());
        addRowWithColumns(dsd, "AN21","Pregnant Mothers with Blood Group B",indicatorLibrary.totalBloodGroupB());
        addRowWithColumns(dsd, "AN22","Pregnant Mothers with Blood Group B+",indicatorLibrary.bloodGroupBPositive());
        addRowWithColumns(dsd, "AN23","Pregnant Mothers with Blood Group AB",indicatorLibrary.totalBloodGroupAB());
        addRowWithColumns(dsd, "AN24","Pregnant Mothers with Blood Group AB+",indicatorLibrary.bloodGroupABPositive());
        addRowWithColumns(dsd, "AN25","Pregnant Women Tested for Aneamia",indicatorLibrary.testedForAnaemiaAndFirstANCVisit());
        addRowWithColumns(dsd, "AN26","Pregnant Women Tested Positive for Aneamia",indicatorLibrary.testedPositiveForAnaemiaAndFirstANCVisit());
        addRowWithColumns(dsd, "AN27","Pregnant women tested for anaemia at 36 Weeks",indicatorLibrary.testedForAnaemiaat36Weeks());
        addRowWithColumns(dsd, "AN28","Pregnant Mothers with Aneamia after 36 weeks",indicatorLibrary.testedPositiveForAnaemiaAfter36Weeks());
        addRowWithColumns(dsd, "AN29","Pregnant Mothers recieving Iron and Follic Acid on first ANC",indicatorLibrary.recievingIronANDFollicAcidAtFirstVisit());
        addRowWithColumns(dsd, "AN30","Pregnant Mothers recieving Iron and Follic Acid after 36 weeks",indicatorLibrary.recievingIronANDFollicAcidAt36Weeks());
        addRowWithColumns(dsd, "AN31","Pregnant Mothers recieved free LLIN",indicatorLibrary.pregnantWomengivenFreeLLIN());
        addRowWithColumns(dsd, "AN32","Ultra sound scan done",indicatorLibrary.numberOfUltraSoundScan());
        addRowWithColumns(dsd, "AN33","Ultra sound scan done before 24 weeks",indicatorLibrary.numberOfUltraSoundScanbefore24weeks());
        addRowWithColumns(dsd, "AN34"," Number of Pregnant Women Recieving Mabendazole",indicatorLibrary.pregnantWomenRecievingMabendazole());
        addRowWithColumns(dsd, "AN35"," Number of Pregnant Women Recieving Mabendazole at 24 weeks",indicatorLibrary.pregnantWomenRecievingMabendazoleAfter28weeks());
        //Tested for syphillis
        addRowWithColumns(dsd, "AN36","Pregnant Mothers with  Syphillis test",indicatorLibrary.pregnantAndTestedForSyphilis());
        addRowWithColumns(dsd, "AN37","Pregnant Mothers with Positive Syphillis test",indicatorLibrary.pregnantAndTestedPositiveforSyphillis());
        addRowWithColumns(dsd, "AN38","Pregnant Mothers with Positive Syphillis test and started treatment",indicatorLibrary.pregnantAndTestedPositiveforSyphillisAndStartedTreatment());
        addRowWithColumns(dsd, "AN39","Partner with  Syphillis test",indicatorLibrary.partnerTestedForSyphilis());
        addRowWithColumns(dsd, "AN40","Partner with Positive Syphillis test",indicatorLibrary.patnerTestedPositiveforSyphillis());
        addRowWithColumns(dsd, "AN41","Partner with Positive Syphillis test and started treatment",indicatorLibrary.partnerTestedPositiveforSyphillisAndStartedTreatment());

       //Tested for HEP B
        addRowWithColumns(dsd, "AN42","Pregant Women tested for HEP B",indicatorLibrary.pregnantAndTestedForHEPB());
        addRowWithColumns(dsd, "AN43","Pregant Women tested Positive for HEP B",indicatorLibrary.pregnantAndTestedPositiveforHEPB());
        addRowWithColumns(dsd, "AN44","Pregant Women tested Positive for HEP B and on treatment",indicatorLibrary.pregnantAndTestedPositiveforHEPB());


        //
        addRowWithColumns(dsd, "AN46","Pregnant women who tested ",indicatorLibrary.pregnantWomenNewlyTestedForHivThisPregnancyTRAndTRR());
        addRowWithColumns(dsd, "AN47","Pregnant women who testing for the first time  ",indicatorLibrary.pregnantWomenNewlyTestedForHivThisPregnancyTRR());
        addRowWithColumns(dsd, "AN48","Pregnant women assessed by CD4 ",indicatorLibrary.hivPositiveIndividualsTestedAtAnEarlyStage());

        addRowWithColumns(dsd, "AN49","Pregnant women with known HIV Status ",indicatorLibrary.pregnantWomenwithKnownHIVStatus());
        addRowWithColumns(dsd, "AN50","Pregnant women with known HIV Status before first ANC visit ",indicatorLibrary.pregnantWomenWithKnownHIVStatusBeforeFirstANCVisit());

        addRowWithColumns(dsd, "AN51","Pregnant women already on treatment before first ANC Visit ",indicatorLibrary.pregnantWomenAlreadyonARTTreatmentBeforeFirstANCVisit());
        addRowWithColumns(dsd, "AN52","Viral Load Samples Collected during month ",indicatorLibrary.viralLoadSamplesCollectedDuringMonth());
        addRowWithColumns(dsd, "AN53","Viral Load returned during this month ",indicatorLibrary.viralLoadResultsReturnedDuringMonth());
        addRowWithColumns(dsd, "AN54","Viral Load returned during this month ",indicatorLibrary.viralLoadSupressedDuringMonth());




        addRowWithColumns(dsd, "AN71","Pregnant women who retested laster in the pregancy total ",indicatorLibrary.totalPregnantWomenTestedLater());
        addRowWithColumns(dsd, "AN72","Pregnant women who retested laster in the pregancy ",indicatorLibrary.pregnantWomenTestedLater());
        addRowWithColumns(dsd, "AN73","Pregnant women given infant HIV Prophylaxis ",indicatorLibrary.pregnantWomenHIVProhylaxis());
        addRowWithColumns(dsd, "AN74","Pregnant women given STKs ",indicatorLibrary.pregnantWomenGivenSTKs());
        addRowWithColumns(dsd, "AN75","STK result is positive",indicatorLibrary.positiveSTKResult());
        addRowWithColumns(dsd, "AN76","STK result is negative ",indicatorLibrary.negativeSTKResult());


        addRowWithColumns(dsd, "AN77","Male partners received HIV test results in eMTCT - Totals",indicatorLibrary.malePatinersRecievedHivResultTotal());
        addRowWithColumns(dsd, "AN78","Male partners received HIV test results in eMTCT ",indicatorLibrary.malePatinersRecievedHivResult());
        addRowWithColumns(dsd, "AN79","Male partners with known HIV Status total ",indicatorLibrary.malePatinersWithKnownHivResultTotal());
        addRowWithColumns(dsd, "AN80","Male partners with known HIV Status  ",indicatorLibrary.malePatinersWithKnownHivResult());

        addRowWithColumns(dsd, "AN81","Male partners initiated on ART  ",indicatorLibrary.malePartnersInitiatedOnART());
        addRowWithColumns(dsd, "AN82","Discordant Couples",indicatorLibrary.discordantResults());
        addRowWithColumns(dsd, "AN83","Maternal Nutrition total  ",indicatorLibrary.maternalNutrition());
        addRowWithColumns(dsd, "AN84","Maternal Nutrition and Positive ",indicatorLibrary.maternalNutritionAndHIVPositive());
        addRowWithColumns(dsd, "AN85","Infant Counselling ",indicatorLibrary.infantFeedingCounselling());
        addRowWithColumns(dsd, "AN86","Infant Counselling and Positive ",indicatorLibrary.infantFeedingCounsellingAndHIVPositive());



        return dsd;
    }

    public void addRowWithColumns(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortIndicator cohortIndicator) {

        addIndicator(dsd, key + "aF", label + " (Below 15 Years) Female", cohortIndicator, "gender=F|age=Between15And19yrs");
        addIndicator(dsd, key + "bF", label + " (Between 15 and 19 Years) Female", cohortIndicator, "gender=F|age=Between15And19yrs");
        addIndicator(dsd, key + "cF", label + " (Between 20 and 24 Years) Female", cohortIndicator, "gender=F|age=Between20And24yrs");
        addIndicator(dsd, key + "dF", label + " (Between 25 and 49 Years) Female", cohortIndicator, "gender=F|age=Between25And49yrs");
        addIndicator(dsd, key + "eF", label + " (>50) Female", cohortIndicator, "gender=F|age=GreaterThan50yrs");
        addIndicator(dsd, key + "fF", label + " (Total) ", cohortIndicator, "");
    }

    public void addIndicator(CohortIndicatorDataSetDefinition dsd, String key, String label, CohortIndicator cohortIndicator, String dimensionOptions) {
        dsd.addColumn(key, label, ReportUtils.map(cohortIndicator, PARAMS), dimensionOptions);

    }

    @Override
    public String getVersion() {
        return "2.1.0.0";
    }
}
