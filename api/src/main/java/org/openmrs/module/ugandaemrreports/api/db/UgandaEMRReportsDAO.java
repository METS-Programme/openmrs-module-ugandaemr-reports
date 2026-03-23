package org.openmrs.module.ugandaemrreports.api.db;

import org.openmrs.*;
import org.openmrs.Concept;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.model.*;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.ReportObjectWrapper;


import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Database methods for {@link UgandaEMRReportsService}.
 */
public interface UgandaEMRReportsDAO {
    void executeFlatteningScript();

    List<ReportObjectWrapper> getReportObjects(String type);
    PatientSearch getPatientSearchByUuid(String uuid);

    Cohort getPatientCurrentlyInPrograms(String uuid);

    List<Integer> getObsConceptsFromEncounters(EncounterType encounterType);
    Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition);

    Set<Concept> getAllConditions();

    Map<Integer,Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit);

    List<Object> getNonCodedOrderReasons(OrderType orderType);

    List<Concept> getCodedOrderReasons(OrderType orderType);

    Map<Integer, Map<String, Object>> getDrugOrderByIndication(org.openmrs.cohort.Cohort patients,String drugIndication,OrderType orderType);


    // -------------------------
    // MambaIndicator
    // -------------------------
    ReportBuilderIndicator saveReportBuilderIndicator(ReportBuilderIndicator indicator);

    ReportBuilderIndicator getReportBuilderIndicatorById(Integer id);

    ReportBuilderIndicator getReportBuilderIndicatorByUuid(String uuid);

    ReportBuilderIndicator getReportBuilderIndicatorByCode(String code);

    List<ReportBuilderIndicator> getReportBuilderIndicators(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired,
                                                            Integer startIndex, Integer limit);

    long getReportBuilderIndicatorsCount(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired);

    void purgeReportBuilderIndicator(ReportBuilderIndicator indicator);

    // -------------------------
    // MambaSection
    // -------------------------
    ReportBuilderSection saveReportBuilderSection(ReportBuilderSection section);

    ReportBuilderSection getReportBuilderSectionById(Integer id);

    ReportBuilderSection getReportBuilderSectionByUuid(String uuid);

    ReportBuilderSection getReportBuilderSectionByCode(String code);

    List<ReportBuilderSection> getReportBuilderSections(String q, boolean includeRetired,
                                                        Integer startIndex, Integer limit);

    long getReportBuilderSectionsCount(String q, boolean includeRetired);

    void purgeReportBuilderSection(ReportBuilderSection section);

    // -------------------------
    // MambaDataTheme
    // -------------------------
    ReportBuilderDataTheme saveReportBuilderDataTheme(ReportBuilderDataTheme theme);

    ReportBuilderDataTheme getReportBuilderDataThemeById(Integer id);

    ReportBuilderDataTheme getReportBuilderDataThemeByUuid(String uuid);

    ReportBuilderDataTheme getReportBuilderDataThemeByCode(String code);

    List<ReportBuilderDataTheme> getReportBuilderDataThemes(String q, boolean includeRetired,
                                                            Integer startIndex, Integer limit);

    long getReportBuilderThemesCount(String q, boolean includeRetired);

    void purgeReportBuilderDataTheme(ReportBuilderDataTheme theme);

    // -------------------------
    // Age Category & Groups
    // -------------------------
    ReportBuilderAgeCategory saveAgeCategory(ReportBuilderAgeCategory category);

    ReportBuilderAgeCategory getAgeCategoryById(Integer id);

    ReportBuilderAgeCategory getAgeCategoryByUuid(String uuid);

    ReportBuilderAgeCategory getAgeCategoryByCode(String code);

    List<ReportBuilderAgeCategory> getAgeCategories(String q, boolean includeRetired, Boolean activeOnly,
                                                    Integer startIndex, Integer limit);

    long getAgeCategoriesCount(String q, boolean includeRetired, Boolean activeOnly);

    void purgeAgeCategory(ReportBuilderAgeCategory category);

    ReportBuilderAgeGroup saveAgeGroup(ReportBuilderAgeGroup group);

    ReportBuilderAgeGroup getAgeGroupById(Integer id);

    List<ReportBuilderAgeGroup> getAgeGroupsByCategoryUuid(String categoryUuid, Boolean activeOnly);

    List<ReportBuilderAgeGroup> getAgeGroupsByCategoryCode(String categoryCode, Boolean activeOnly);

    void purgeAgeGroup(ReportBuilderAgeGroup group);

    // -------------------------
    // Utility: list DB tables
    // -------------------------
    public List<String> getMambaTables();

    public List<Map> getMambaTableColumns(String tableName);

    List<ReportBuilderIndicator> getAllReportBuilderaIndicator(Integer startIndex, Integer limit);

    List<ReportBuilderAgeGroup> getAgeGroups(String q, ReportBuilderAgeCategory category, Boolean activeOnly, Integer startIndex, Integer limit);


    SqlPreviewResult previewSql(String sql, Map<String, Object> params, Integer maxRows);


    ReportBuilderReport saveReportBuilderReport(ReportBuilderReport report);

   ReportBuilderReport getReportBuilderReportByUuid(String uuid);

   List<ReportBuilderReport> getReportBuilderReports(String q, boolean includeRetired, Integer startIndex, Integer limit);

   void deleteReportBuilderReport(ReportBuilderReport report);

   void retireReportBuilderReport(ReportBuilderReport report, String reason);

    void purgeReportBuilderReport(ReportBuilderReport report);

    // ReportCategory
    ReportCategory saveReportCategory(ReportCategory category);

    ReportCategory getReportCategoryById(Integer id);

    ReportCategory getReportCategoryByUuid(String uuid);

    List<ReportCategory> getReportCategories(String q, boolean includeRetired, Integer startIndex, Integer limit);

    long getReportCategoriesCount(String q, boolean includeRetired);

    void purgeReportCategory(ReportCategory category);

    ReportLibrary saveReportLibrary(ReportLibrary reportLibrary);

    ReportLibrary getReportLibraryById(Integer id);

    ReportLibrary getReportLibraryByUuid(String uuid);

    List<ReportLibrary> getReportLibraries(String q, boolean includeRetired, Integer startIndex, Integer limit);

    long getReportLibrariesCount(String q, boolean includeRetired);

    void purgeReportLibrary(ReportLibrary reportLibrary);

}
