package org.openmrs.module.ugandaemrreports.api;

import org.openmrs.*;
import org.openmrs.Concept;
import org.openmrs.api.APIException;
import org.openmrs.api.OpenmrsService;
import org.openmrs.module.reporting.report.ReportData;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.model.*;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This service exposes module's core functionality. It is a Spring managed bean which is configured in
 * moduleApplicationContext.xml.
 * <p>
 * It can be accessed only via Context:<br>
 * <code>
 * Context.getService(UgandaEMRReportsService.class).someMethod();
 * </code>
 *
 * @see org.openmrs.api.context.Context
 */
@Transactional
public interface UgandaEMRReportsService extends OpenmrsService {

    /**
     * Getting all Report objects for dashboard
     *
     * @return List<DashboardReportObject> returns all report objects in a list
     * @throws APIException
     */
    List<DashboardReportObject> getAllDashboardReportObjects() throws APIException;

    /**
     * Get Report object  By uuid
     *
     * @param uuid the uuid of the report object  to return
     * @return Dashboard report object that matched the uuid parameter
     * @throws APIException
     */
    @Transactional
    DashboardReportObject getDashboardReportObjectByUUID(String uuid) throws APIException;

    /**
     * Saves the Dashboard Report Object
     *
     * @param dashboardReportObject to be saved.
     * @return DashboardReportObject saved
     * @throws APIException
     */
    @Transactional
    DashboardReportObject saveDashboardReportObject(DashboardReportObject dashboardReportObject) throws APIException;

    /**
     * @param id to get dashboardReportObject by id
     * @return DashboardReportObject
     * @throws APIException
     */
    @Transactional
    DashboardReportObject getDashboardReportObjectById(Integer id) throws APIException;


    /**
     * @param dashboard to save Dashboard
     * @return Dashboard
     */
    @Transactional
    Dashboard saveDashboard(Dashboard dashboard)  throws APIException;


    /**
     * @param uniqueId of Dashboard
     * @return Dashboard
     * @throws APIException
     */
    @Transactional
    Dashboard getDashboardByUUID(String uniqueId) throws APIException;


    /**
     * @param id for Dashboard id
     * @return Dashboard with id above
     * @throws APIException
     */
    @Transactional
    Dashboard getDashboardById(Integer id) throws APIException;


    /**
     * @return List of Dashboards in database
     * @throws APIException
     */
    @Transactional
    List<Dashboard> getAllDashboards() throws APIException;


    void executeFlatteningScript();

    List<ReportObjectWrapper> getPatientSearches(String type);

    PatientSearch getPatientSearchByUuid(String uuid);

    Cohort getPatientCurrentlyInProgram(String programUuid);

     Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition);

     Set<Concept> getConditionsConcepts();

    Map<Integer,Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit);

    List<Integer> getObsConceptsFromEncounters(EncounterType encounterType);

    List<Object> getNonCodedOrderReasons(OrderType orderType);

    List<Concept> getCodedOrderReasons(OrderType orderType);

    Map<Integer, Map<String, Object>> getDrugOrderByIndicator(org.openmrs.cohort.Cohort patients,String drugIndication,OrderType orderType);

    public  void addMambaetlProperties();

    public void setupMambaETL();

    public void setUpReports();

    /** Returns HTML as a string for preview/printing */
    public String renderHtmlFromJsonTemplate(ReportDesign reportDesign);

    /** Returns payload JSON as a string (no JsonNode leaks) */
    public String createPayloadJsonFromTemplate(ReportData reportData, ReportDesign reportDesign, String renderType, Map<String, Object> flatValues, String remapJsonOptional);

    public String buildPayloadJson(ReportData reportData, ReportDesign reportDesign, String renderType);

    public String buildFinalPayloadJson(ReportData reportData, ReportDesign reportDesign, String renderType, Date endDate);

    public String buildPreviewHtml(ReportData reportData, ReportDesign reportDesign);

    public String buildRenderedOutput(ReportData reportData, ReportDesign reportDesign, String remapJsonOptional);


    // =========================
    // MambaIndicator
    // =========================
    ReportBuilderIndicator saveReportBuilderIndicator(ReportBuilderIndicator indicator);

    ReportBuilderIndicator getReportBuilderIndicatorById(Integer id);

    ReportBuilderIndicator getReportBuilderIndicatorByUuid(String uuid);

    ReportBuilderIndicator getReportBuilderIndicatorByCode(String code);

    List<ReportBuilderIndicator> searchReportBuilderIndicators(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired, Integer startIndex, Integer limit);

    public List<ReportBuilderIndicator> getAllReportBuilderIndicator(Integer startIndex, Integer limit);

    public List<ReportBuilderIndicator> getReportBuilderIndicators(ReportBuilderIndicator.Kind kind, boolean includeRetired, Integer startIndex, Integer limit);

    long getReportBuilderIndicatorsCount(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired);

    void retireReportBuilderIndicator(ReportBuilderIndicator indicator, String reason);

    void unretireReportBuilderIndicator(ReportBuilderIndicator indicator);

    void purgeReportBuilderIndicator(ReportBuilderIndicator indicator);

    // =========================
    // MambaSection
    // =========================
    ReportBuilderSection saveReportBuilderSection(ReportBuilderSection section);

    ReportBuilderSection getReportBuilderSectionById(Integer id);

    ReportBuilderSection getReportBuilderSectionByUuid(String uuid);

    ReportBuilderSection getReportBuilderSectionByCode(String code);

    List<ReportBuilderSection> getReportBuilderSections(String q,
                                                        boolean includeRetired,
                                                        Integer startIndex,
                                                        Integer limit);

    long getReportBuilderSectionsCount(String q, boolean includeRetired);

    void retireReportBuilderSection(ReportBuilderSection section, String reason);

    void unretireReportBuilderSection(ReportBuilderSection section);

    void purgeReportBuilderSection(ReportBuilderSection section);

    // =========================
    // MambaDataTheme
    // =========================
    ReportBuilderDataTheme saveReportBuilderDataTheme(ReportBuilderDataTheme theme);

    ReportBuilderDataTheme getReportBuilderDataThemeById(Integer id);

    ReportBuilderDataTheme getReportBuilderDataThemeByUuid(String uuid);

    ReportBuilderDataTheme getReportBuilderDataThemeByCode(String code);

    List<ReportBuilderDataTheme> getReportBuilderDataThemes(String q,
                                                            boolean includeRetired,
                                                            Integer startIndex,
                                                            Integer limit);

    long getReportBuilderDataThemesCount(String q, boolean includeRetired);

    void retireReportBuilderDataTheme(ReportBuilderDataTheme theme, String reason);

    void unretireReportBuilderDataTheme(ReportBuilderDataTheme theme);

    void purgeReportBuilderDataTheme(ReportBuilderDataTheme theme);

    List<String> getMambaTables();

    public List<Map> getMambaTableColumns(String tableName);

    // Categories
    ReportBuilderAgeCategory saveAgeCategory(ReportBuilderAgeCategory category);

    ReportBuilderAgeCategory getAgeCategoryByUuid(String uuid);

    ReportBuilderAgeCategory getAgeCategoryByCode(String code);

    List<ReportBuilderAgeCategory> getAgeCategories(String q, boolean includeRetired, Boolean activeOnly,
                                                    Integer startIndex, Integer limit);

    long getAgeCategoriesCount(String q, boolean includeRetired, Boolean activeOnly);

    void retireAgeCategory(ReportBuilderAgeCategory category, String reason);

    void unretireAgeCategory(ReportBuilderAgeCategory category);

    void purgeAgeCategory(ReportBuilderAgeCategory category);

    // Groups
    ReportBuilderAgeGroup saveAgeGroup(ReportBuilderAgeGroup group);

    ReportBuilderAgeGroup getAgeGroupById(Integer id);

    List<ReportBuilderAgeGroup> getAgeGroupsByCategoryUuid(String categoryUuid, Boolean activeOnly);

    List<ReportBuilderAgeGroup> getAgeGroupsByCategoryCode(String categoryCode, Boolean activeOnly);

    void purgeAgeGroup(ReportBuilderAgeGroup group);

    List<ReportBuilderAgeGroup> getAgeGroups(String q, ReportBuilderAgeCategory category, Boolean activeOnly, Integer startIndex, Integer limit);

    SqlPreviewResult previewSql(String sql, Map<String, Object> params, Integer maxRows);

    @Transactional
    public ReportBuilderReport saveReportBuilderReport(ReportBuilderReport report);

    @Transactional(readOnly = true)
    public ReportBuilderReport getReportBuilderReportByUuid(String uuid);

    @Transactional(readOnly = true)
    public List<ReportBuilderReport> getReportBuilderReports(String q, boolean includeRetired, Integer startIndex, Integer limit);

    @Transactional
    public void retireReportBuilderReport(ReportBuilderReport report, String reason);

    @Transactional
    public void purgeReportBuilderReport(ReportBuilderReport report);

    @Transactional
    CompiledReportArtifacts compileReport(String reportBuilderReportUuid);


    @Transactional
    public ReportCategory saveReportCategory(ReportCategory category);

    @Transactional(readOnly = true)
    public ReportCategory getReportCategoryById(Integer id);

    @Transactional(readOnly = true)
    public ReportCategory getReportCategoryByUuid(String uuid);

    @Transactional(readOnly = true)
    public List<ReportCategory> getReportCategories(String q, boolean includeRetired, Integer startIndex, Integer limit);

    @Transactional(readOnly = true)
    public long getReportCategoriesCount(String q, boolean includeRetired);

    @Transactional
    public void retireReportCategory(ReportCategory category, String reason);

    @Transactional
    public void unretireReportCategory(ReportCategory category);

    @Transactional
    public void purgeReportCategory(ReportCategory category);

    @Transactional
    ReportLibrary saveReportLibrary(ReportLibrary reportLibrary);

    @Transactional(readOnly = true)
    ReportLibrary getReportLibraryById(Integer id);

    @Transactional(readOnly = true)
    ReportLibrary getReportLibraryByUuid(String uuid);

    @Transactional(readOnly = true)
    List<ReportLibrary> getReportLibraries(String q, boolean includeRetired, Integer startIndex, Integer limit);

    @Transactional(readOnly = true)
    long getReportLibrariesCount(String q, boolean includeRetired);

    @Transactional
    void retireReportLibrary(ReportLibrary reportLibrary, String reason);

    @Transactional
    void unretireReportLibrary(ReportLibrary reportLibrary);

    @Transactional
    void purgeReportLibrary(ReportLibrary reportLibrary);

    class CompiledReportArtifacts {
        private ReportBuilderReport reportBuilderReport;
        private ReportDefinition reportDefinition;
        private File reportDesignFile;
        private String compiledJson;

        public ReportBuilderReport getReportBuilderReport() {
            return reportBuilderReport;
        }

        public void setReportBuilderReport(ReportBuilderReport reportBuilderReport) {
            this.reportBuilderReport = reportBuilderReport;
        }

        public ReportDefinition getReportDefinition() {
            return reportDefinition;
        }

        public void setReportDefinition(ReportDefinition reportDefinition) {
            this.reportDefinition = reportDefinition;
        }

        public File getReportDesignFile() {
            return reportDesignFile;
        }

        public void setReportDesignFile(File reportDesignFile) {
            this.reportDesignFile = reportDesignFile;
        }

        public String getCompiledJson() {
            return compiledJson;
        }

        public void setCompiledJson(String compiledJson) {
            this.compiledJson = compiledJson;
        }
    }

}