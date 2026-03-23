package org.openmrs.module.ugandaemrreports.api.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.common.MessageUtil;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.evaluation.EvaluationUtil;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportData;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.ReportDesignResource;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.definition.service.ReportDefinitionService;
import org.openmrs.module.reporting.report.renderer.RenderingException;
import org.openmrs.module.reporting.report.renderer.TextTemplateRenderer;
import org.openmrs.module.reporting.report.renderer.template.TemplateEngine;
import org.openmrs.module.reporting.report.renderer.template.TemplateEngineManager;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.module.ugandaemrreports.activator.AppConfigInitializer;
import org.openmrs.module.ugandaemrreports.activator.Initializer;
import org.openmrs.module.ugandaemrreports.activator.ReportInitializer;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.api.db.hibernate.HibernateUgandaEMRReportsDAO;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;
import org.openmrs.module.ugandaemrreports.model.*;
import org.openmrs.module.ugandaemrreports.util.MambaIndicatorSqlSync;
import org.openmrs.module.ugandaemrreports.util.MambaIndicatorValidator;
import org.openmrs.module.ugandaemrreports.util.ReportDesignFileUtil;
import org.openmrs.module.ugandaemrreports.util.ReportDesignHtmlRenderer;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.ReportObjectWrapper;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.transaction.annotation.Transactional;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Default implementation of {@link UgandaEMRReportsService}.
 */
public class UgandaEMRReportsServiceImpl extends BaseOpenmrsService implements UgandaEMRReportsService {

    protected final Log log = LogFactory.getLog(this.getClass());

    private final ObjectMapper objectMapper = new ObjectMapper();

    private HibernateUgandaEMRReportsDAO dao;

    private final ReportDesignHtmlRenderer reportDesignHtmlRenderer = new ReportDesignHtmlRenderer();

    public HibernateUgandaEMRReportsDAO getDao() {
        return dao;
    }

    public void setDao(HibernateUgandaEMRReportsDAO dao) {
        this.dao = dao;
    }

    @Override
    public List<DashboardReportObject> getAllDashboardReportObjects() throws APIException {
        return dao.getAllDashboardReportObjects();
    }

    @Override
    public DashboardReportObject getDashboardReportObjectByUUID(String uuid) throws APIException {
        return dao.getDashboardReportObjectByUUID(uuid);
    }

    @Override
    public DashboardReportObject saveDashboardReportObject(DashboardReportObject dashboardReportObject) throws APIException {
        return dao.saveDashboardReportObject(dashboardReportObject);
    }

    @Override
    public DashboardReportObject getDashboardReportObjectById(Integer id) throws APIException {
        return dao.getDashboardReportObjectById(id);
    }

    @Override
    public Dashboard saveDashboard(Dashboard dashboard) throws APIException {
        return dao.saveDashboard(dashboard);
    }

    @Override
    public Dashboard getDashboardByUUID(String uniqueId) throws APIException {
        return dao.getDashboardByUUID(uniqueId);
    }

    @Override
    public Dashboard getDashboardById(Integer id) throws APIException {
        return dao.getDashboardById(id);
    }

    @Override
    public List<Dashboard> getAllDashboards() throws APIException {
        return dao.getAllDashboards();
    }

    @Override
    public void executeFlatteningScript() {
        dao.executeFlatteningScript();
    }

    @Override
    public List<ReportObjectWrapper> getPatientSearches(String type) {
        return dao.getReportObjects(type);
    }

    @Override
    public PatientSearch getPatientSearchByUuid(String uuid) {
        return dao.getPatientSearchByUuid(uuid);
    }

    @Override
    public Cohort getPatientCurrentlyInProgram(String programUuid) {
        return dao.getPatientCurrentlyInPrograms(programUuid);
    }

    @Override
    public Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition) {
        return dao.getPatientsConditionsStatus(patients, codedCondition);
    }

    @Override
    public Set<Concept> getConditionsConcepts() {
        return dao.getAllConditions();
    }

    @Override
    public Map<Integer, Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit) {
        return dao.getLatestPatientAppointmentsScheduled(patients, limit);
    }

    @Override
    public List<Integer> getObsConceptsFromEncounters(EncounterType encounterType) {
        return dao.getObsConceptsFromEncounters(encounterType);
    }

    @Override
    public List<Object> getNonCodedOrderReasons(OrderType orderType) {
        return dao.getNonCodedOrderReasons(orderType);
    }

    @Override
    public List<Concept> getCodedOrderReasons(OrderType orderType) {
        return dao.getCodedOrderReasons(orderType);
    }

    @Override
    public Map<Integer, Map<String, Object>> getDrugOrderByIndicator(org.openmrs.cohort.Cohort patients, String drugIndication, OrderType orderType) {
        return dao.getDrugOrderByIndication(patients, drugIndication, orderType);
    }

    public void addMambaetlProperties() {
        File appDataDir = FileUtils.getFile(OpenmrsUtil.getApplicationDataDirectory());
        File propertiesFile = new File(appDataDir, "openmrs-runtime.properties");
        Properties properties = new Properties();

        try (FileInputStream in = new FileInputStream(propertiesFile)) {
            properties.load(in);
        } catch (IOException e) {
            System.err.println("Failed to read properties file: " + e.getMessage());
            return;
        }

        String connectionUrl = properties.getProperty("connection.url");
        String dbName = null;

        if (connectionUrl != null && connectionUrl.contains("/")) {
            try {
                int lastSlash = connectionUrl.lastIndexOf('/');
                int questionMark = connectionUrl.indexOf('?', lastSlash);
                if (lastSlash != -1 && questionMark != -1) {
                    dbName = connectionUrl.substring(lastSlash + 1, questionMark);
                } else if (lastSlash != -1) {
                    dbName = connectionUrl.substring(lastSlash + 1);
                }
            } catch (Exception e) {
                System.err.println("Error parsing connection.url: " + e.getMessage());
            }
        }

        if (dbName == null || dbName.isEmpty()) {
            dbName = "openmrs";
            System.out.println("WARNING: Using fallback database name: " + dbName);
        }

        String username = properties.getProperty("connection.username", "openmrs");
        if (username.isEmpty()) {
            username = "openmrs";
            System.out.println("WARNING: Using fallback username: " + username);
        }

        String password = properties.getProperty("connection.password", "openmrs");
        if (password.isEmpty()) {
            password = "openmrs";
            System.out.println("WARNING: Using fallback password: " + password);
        }

        setIfAbsent(properties, "mambaetl.analysis.db.openmrs_database", dbName);
        setIfAbsent(properties, "mambaetl.analysis.db.etl_database", dbName);
        setIfAbsent(properties, "mambaetl.analysis.db.username", username);
        setIfAbsent(properties, "mambaetl.analysis.db.password", password);
        setIfAbsent(properties, "mambaetl.analysis.columns", "49");
        setIfAbsent(properties, "mambaetl.analysis.incremental_mode", "1");
        setIfAbsent(properties, "mambaetl.analysis.etl_interval", "3600");
        setIfAbsent(properties, "mambaetl.analysis.locale", "en");
        setIfAbsent(properties, "mambaetl.analysis.automated_flattening", "0");

        try (FileOutputStream out = new FileOutputStream(propertiesFile)) {
            properties.store(out, "Updated with MambaETL related properties (added only if missing)");
            System.out.println("MambaETL properties checked and updated successfully.");
        } catch (IOException e) {
            System.err.println("Failed to write properties file: " + e.getMessage());
        }
    }

    @Override
    public void setupMambaETL() {
        Context.getService(FlattenDatabaseService.class).setupEtl();
    }

    @Override
    public void setUpReports() {
        try {
            for (Initializer initializer : getInitializers()) {
                initializer.started();
            }
        } catch (Exception e) {
            log.error("Error setting up reports: " + e.getMessage());
        }
    }

    private static void setIfAbsent(Properties properties, String key, String value) {
        if (!properties.containsKey(key)) {
            properties.setProperty(key, value);
        }
    }

    public List<Initializer> getInitializers() {
        List<Initializer> l = new ArrayList<Initializer>();
        l.add(new AppConfigInitializer());
        l.add(new ReportInitializer());
        return l;
    }

    public String renderHtmlFinalFromTemplate(ReportData reportData, ReportDesign reportDesign) {
        String templateJson = readDesignResource(reportDesign);
        Map<String, Object> values = extractFlatValues(reportData);
        return reportDesignHtmlRenderer.convert(templateJson, values, null).html;
    }

    @Override
    public String renderHtmlFromJsonTemplate(ReportDesign reportDesign) {
        String templateJson = readDesignResource(reportDesign);
        return reportDesignHtmlRenderer.convert(templateJson, Collections.<String, Object>emptyMap(), null).html;
    }

    @Override
    public String createPayloadJsonFromTemplate(ReportData reportData, ReportDesign reportDesign, String renderType, Map<String, Object> flatValues, String remapJsonOptional) {
        String templateJson = readDesignResource(reportDesign);
        Map<String, Object> values = flatValues == null
                ? Collections.<String, Object>emptyMap()
                : flatValues;

        return reportDesignHtmlRenderer.convert(templateJson, values, remapJsonOptional).payloadJson;
    }

    public Map<String, Object> extractFlatValues(ReportData reportData) {
        Map<String, Object> out = new HashMap<String, Object>();
        if (reportData == null || reportData.getDataSets() == null) {
            return out;
        }

        Map<String, DataSet> dataSets = reportData.getDataSets();
        for (String dsName : dataSets.keySet()) {
            DataSet ds = dataSets.get(dsName);
            if (ds == null) continue;

            Iterator it = ds.iterator();
            while (it.hasNext()) {
                DataSetRow row = (DataSetRow) it.next();
                Map<String, Object> cols = row.getColumnValuesByKey();
                if (cols == null || cols.isEmpty()) continue;

                String code = firstString(cols, "code", "dataelement", "dataElement", "data_element");
                String age = firstString(cols, "age", "agegroup", "age_group");
                String sex = firstString(cols, "sex", "gender");
                Object valObj = firstObject(cols, "value", "count", "total");

                if (!isBlank(code) && !isBlank(age) && !isBlank(sex) && valObj != null) {
                    out.put(code + "_" + age + "_" + sex, valObj);
                    continue;
                }

                for (Map.Entry<String, Object> e : cols.entrySet()) {
                    String k = e.getKey();
                    Object v = e.getValue();
                    if (k == null) continue;

                    if (looksLikeKey(k) && v != null && isNumeric(v)) {
                        out.put(k.trim(), v);
                    }
                }
            }
        }

        return out;
    }

    private boolean looksLikeKey(String k) {
        String s = k.trim();
        int a = s.indexOf('_');
        if (a <= 0) return false;
        int b = s.indexOf('_', a + 1);
        if (b <= a + 1) return false;
        int c = s.lastIndexOf('_');
        return c > b && c < s.length() - 1;
    }

    private boolean isNumeric(Object v) {
        if (v instanceof Number) return true;
        String s = String.valueOf(v).trim();
        if (s.length() == 0) return false;
        try {
            Double.parseDouble(s);
            return true;
        } catch (Exception ignore) {
            return false;
        }
    }

    private String firstString(Map<String, Object> cols, String... keys) {
        Object o = firstObject(cols, keys);
        return o == null ? null : String.valueOf(o).trim();
    }

    private Object firstObject(Map<String, Object> cols, String... keys) {
        for (String k : keys) {
            if (cols.containsKey(k)) {
                Object v = cols.get(k);
                if (v != null && String.valueOf(v).trim().length() > 0) {
                    return v;
                }
            }
        }
        return null;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public String createLegacyPayloadJson(ReportData reportData, ReportDesign reportDesign) {
        try {
            TextTemplateRenderer textTemplateRenderer = new TextTemplateRenderer();
            ReportDesignResource res = textTemplateRenderer.getTemplate(reportDesign);
            String templateContents = new String(res.getContents(), StandardCharsets.UTF_8);

            String rendered = fillTemplateWithReportData(templateContents, reportData, reportDesign);
            return removeQuotesFromValues(rendered);

        } catch (Exception e) {
            throw new RuntimeException("Failed legacy payload build", e);
        }
    }

    private String fillTemplateWithReportData(String templateContents,
                                              ReportData reportData,
                                              ReportDesign reportDesign) throws IOException, RenderingException {

        try {
            TextTemplateRenderer renderer = new TextTemplateRenderer();
            Map<String, Object> replacements = renderer.getBaseReplacementData(reportData, reportDesign);

            String templateEngineName = reportDesign.getPropertyValue("templateType", (String) null);
            TemplateEngine engine = TemplateEngineManager.getTemplateEngineByName(templateEngineName);

            if (engine != null) {
                Map<String, Object> bindings = new HashMap<String, Object>();
                bindings.put("reportData", reportData);
                bindings.put("reportDesign", reportDesign);
                bindings.put("data", replacements);
                bindings.put("util", new ObjectUtil());
                bindings.put("dateUtil", new DateUtil());
                bindings.put("msg", new MessageUtil());
                templateContents = engine.evaluate(templateContents, bindings);
            }

            String prefix = renderer.getExpressionPrefix(reportDesign);
            String suffix = renderer.getExpressionSuffix(reportDesign);

            Object evaluated = EvaluationUtil.evaluateExpression(templateContents, replacements, prefix, suffix);
            return evaluated == null ? "" : evaluated.toString();

        } catch (RenderingException re) {
            throw re;
        } catch (Throwable t) {
            throw new RenderingException("Unable to render results due to: " + t, t);
        }
    }

    public static String removeQuotesFromValues(String input) {
        Pattern pattern = Pattern.compile("\"value\":\"(\\d+)\"");
        Matcher matcher = pattern.matcher(input);

        StringBuffer result = new StringBuffer();
        while (matcher.find()) {
            matcher.appendReplacement(result, "\"value\":" + matcher.group(1));
        }
        matcher.appendTail(result);
        return result.toString();
    }

    private String readDesignResource(ReportDesign reportDesign) {
        try {
            TextTemplateRenderer renderer = new TextTemplateRenderer();
            ReportDesignResource res = renderer.getTemplate(reportDesign);
            return new String(res.getContents(), StandardCharsets.UTF_8).trim();
        } catch (Exception e) {
            throw new RuntimeException("Failed to read report design resource", e);
        }
    }

    @Override
    public String buildPayloadJson(ReportData reportData, ReportDesign reportDesign, String renderType) {
        if (renderType != null && "legacy".equalsIgnoreCase(renderType)) {
            return createLegacyPayloadJson(reportData, reportDesign);
        }

        Map<String, Object> values = extractFlatValues(reportData);
        return createPayloadJsonFromTemplate(reportData, reportDesign, "json", values, null);
    }

    @Override
    public String buildFinalPayloadJson(ReportData reportData, ReportDesign reportDesign, String renderType, Date endDate) {
        String payloadJson = buildPayloadJson(reportData, reportDesign, renderType);
        String period = getYearAndQuarter(endDate);
        return appendPeriod(payloadJson, period);
    }

    @Override
    public String buildPreviewHtml(ReportData reportData, ReportDesign reportDesign) {
        String templateJson = readDesignResource(reportDesign);
        Map<String, Object> values = extractFlatValues(reportData);
        return reportDesignHtmlRenderer.convert(templateJson, values, null).html;
    }

    public String buildRenderedOutput(ReportData reportData, ReportDesign reportDesign, String remapJsonOptional) {
        String templateJson = readDesignResource(reportDesign);
        Map<String, Object> values = extractFlatValues(reportData);
        return reportDesignHtmlRenderer.buildRenderedOutputOnly(templateJson, values, remapJsonOptional);
    }

    private String getYearAndQuarter(Date date) {
        if (date == null) return null;
        java.time.LocalDate localDate = date.toInstant()
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDate();
        int year = localDate.getYear();
        int month = localDate.getMonthValue();
        int quarter = (month - 1) / 3 + 1;
        return year + "Q" + quarter;
    }

    private String appendPeriod(String payloadJson, String period) {
        if (payloadJson == null) return null;
        try {
            ObjectMapper om = new ObjectMapper();
            ObjectNode root = (ObjectNode) om.readTree(payloadJson);

            ObjectNode json = (ObjectNode) root.get("json");
            if (json == null) {
                json = om.createObjectNode();
                root.set("json", json);
            }
            if (period != null) {
                json.put("period", period);
            }

            return om.writeValueAsString(root);
        } catch (Exception e) {
            return payloadJson;
        }
    }

    @Override
    public ReportBuilderIndicator saveReportBuilderIndicator(ReportBuilderIndicator indicator) {
        try {
            MambaIndicatorValidator.validate(indicator);

            if (indicator.getKind() == ReportBuilderIndicator.Kind.BASE) {
                MambaIndicatorSqlSync.normalizeBaseSql(indicator);
            }

            return dao.saveReportBuilderIndicator(indicator);
        } catch (IllegalArgumentException e) {
            throw new APIException(e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderIndicator getReportBuilderIndicatorById(Integer id) {
        return dao.getReportBuilderIndicatorById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderIndicator getReportBuilderIndicatorByUuid(String uuid) {
        return dao.getReportBuilderIndicatorByUuid(uuid);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderIndicator getReportBuilderIndicatorByCode(String code) {
        return dao.getReportBuilderIndicatorByCode(code);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderIndicator> searchReportBuilderIndicators(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired,
                                                                      Integer startIndex, Integer limit) {
        return dao.getReportBuilderIndicators(q, kind, includeRetired, startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderIndicator> getAllReportBuilderIndicator(Integer startIndex, Integer limit) {
        return dao.getAllReportBuilderaIndicator(startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderIndicator> getReportBuilderIndicators(ReportBuilderIndicator.Kind kind, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportBuilderIndicators(kind, includeRetired, startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public long getReportBuilderIndicatorsCount(String q, ReportBuilderIndicator.Kind kind, boolean includeRetired) {
        return dao.getReportBuilderIndicatorsCount(q, kind, includeRetired);
    }

    @Override
    public void retireReportBuilderIndicator(ReportBuilderIndicator indicator, String reason) {
        indicator.setRetired(true);
        indicator.setRetireReason(reason);
        dao.saveReportBuilderIndicator(indicator);
    }

    @Override
    public void unretireReportBuilderIndicator(ReportBuilderIndicator indicator) {
        indicator.setRetired(false);
        indicator.setRetireReason(null);
        dao.saveReportBuilderIndicator(indicator);
    }

    @Override
    public void purgeReportBuilderIndicator(ReportBuilderIndicator indicator) {
        dao.purgeReportBuilderIndicator(indicator);
    }

    @Override
    public ReportBuilderSection saveReportBuilderSection(ReportBuilderSection section) {
        return dao.saveReportBuilderSection(section);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderSection getReportBuilderSectionById(Integer id) {
        return dao.getReportBuilderSectionById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderSection getReportBuilderSectionByUuid(String uuid) {
        return dao.getReportBuilderSectionByUuid(uuid);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderSection getReportBuilderSectionByCode(String code) {
        return dao.getReportBuilderSectionByCode(code);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderSection> getReportBuilderSections(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportBuilderSections(q, includeRetired, startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public long getReportBuilderSectionsCount(String q, boolean includeRetired) {
        return dao.getReportBuilderSectionsCount(q, includeRetired);
    }

    @Override
    public void retireReportBuilderSection(ReportBuilderSection section, String reason) {
        section.setRetired(true);
        section.setRetireReason(reason);
        dao.saveReportBuilderSection(section);
    }

    @Override
    public void unretireReportBuilderSection(ReportBuilderSection section) {
        section.setRetired(false);
        section.setRetireReason(null);
        dao.saveReportBuilderSection(section);
    }

    @Override
    public void purgeReportBuilderSection(ReportBuilderSection section) {
        dao.purgeReportBuilderSection(section);
    }

    @Override
    public ReportBuilderDataTheme saveReportBuilderDataTheme(ReportBuilderDataTheme theme) {
        return dao.saveReportBuilderDataTheme(theme);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderDataTheme getReportBuilderDataThemeById(Integer id) {
        return dao.getReportBuilderDataThemeById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderDataTheme getReportBuilderDataThemeByUuid(String uuid) {
        return dao.getReportBuilderDataThemeByUuid(uuid);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderDataTheme getReportBuilderDataThemeByCode(String code) {
        return dao.getReportBuilderDataThemeByCode(code);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderDataTheme> getReportBuilderDataThemes(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportBuilderDataThemes(q, includeRetired, startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public long getReportBuilderDataThemesCount(String q, boolean includeRetired) {
        return dao.getReportBuilderThemesCount(q, includeRetired);
    }

    @Override
    public void retireReportBuilderDataTheme(ReportBuilderDataTheme theme, String reason) {
        theme.setRetired(true);
        theme.setRetireReason(reason);
        dao.saveReportBuilderDataTheme(theme);
    }

    @Override
    public void unretireReportBuilderDataTheme(ReportBuilderDataTheme theme) {
        theme.setRetired(false);
        theme.setRetireReason(null);
        dao.saveReportBuilderDataTheme(theme);
    }

    @Override
    public void purgeReportBuilderDataTheme(ReportBuilderDataTheme theme) {
        dao.purgeReportBuilderDataTheme(theme);
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getMambaTables() {
        return dao.getMambaTables();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map> getMambaTableColumns(String tableName) {
        return dao.getMambaTableColumns(tableName);
    }

    @Override
    public ReportBuilderAgeCategory saveAgeCategory(ReportBuilderAgeCategory category) {
        return dao.saveAgeCategory(category);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderAgeCategory getAgeCategoryByUuid(String uuid) {
        return dao.getAgeCategoryByUuid(uuid);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderAgeCategory getAgeCategoryByCode(String code) {
        return dao.getAgeCategoryByCode(code);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderAgeCategory> getAgeCategories(String q, boolean includeRetired, Boolean activeOnly,
                                                           Integer startIndex, Integer limit) {
        return dao.getAgeCategories(q, includeRetired, activeOnly, startIndex, limit);
    }

    @Override
    @Transactional(readOnly = true)
    public long getAgeCategoriesCount(String q, boolean includeRetired, Boolean activeOnly) {
        return dao.getAgeCategoriesCount(q, includeRetired, activeOnly);
    }

    @Override
    public void retireAgeCategory(ReportBuilderAgeCategory category, String reason) {
        category.setRetired(true);
        category.setRetireReason(reason);
        dao.saveAgeCategory(category);
    }

    @Override
    public void unretireAgeCategory(ReportBuilderAgeCategory category) {
        category.setRetired(false);
        category.setRetireReason(null);
        dao.saveAgeCategory(category);
    }

    @Override
    public void purgeAgeCategory(ReportBuilderAgeCategory category) {
        dao.purgeAgeCategory(category);
    }

    @Override
    public ReportBuilderAgeGroup saveAgeGroup(ReportBuilderAgeGroup group) {
        return dao.saveAgeGroup(group);
    }

    @Override
    @Transactional(readOnly = true)
    public ReportBuilderAgeGroup getAgeGroupById(Integer id) {
        return dao.getAgeGroupById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderAgeGroup> getAgeGroupsByCategoryUuid(String categoryUuid, Boolean activeOnly) {
        return dao.getAgeGroupsByCategoryUuid(categoryUuid, activeOnly);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportBuilderAgeGroup> getAgeGroupsByCategoryCode(String categoryCode, Boolean activeOnly) {
        return dao.getAgeGroupsByCategoryCode(categoryCode, activeOnly);
    }

    @Override
    public void purgeAgeGroup(ReportBuilderAgeGroup group) {
        dao.purgeAgeGroup(group);
    }

    @Override
    public List<ReportBuilderAgeGroup> getAgeGroups(String q, ReportBuilderAgeCategory category, Boolean activeOnly, Integer startIndex, Integer limit) {
        return dao.getAgeGroups(q, category, activeOnly, startIndex, limit);
    }

    @Override
    public SqlPreviewResult previewSql(String sql, Map<String, Object> params, Integer maxRows) {
        return dao.previewSql(sql, params, maxRows);
    }

    @Override
    public ReportBuilderReport saveReportBuilderReport(ReportBuilderReport report) {
        if (report.getUuid() == null) {
            report.setUuid(java.util.UUID.randomUUID().toString());
        }
        return dao.saveReportBuilderReport(report);
    }

    @Override
    public ReportBuilderReport getReportBuilderReportByUuid(String uuid) {
        return dao.getReportBuilderReportByUuid(uuid);
    }

    @Override
    public List<ReportBuilderReport> getReportBuilderReports(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportBuilderReports(q, includeRetired, startIndex, limit);
    }

    @Override
    public void retireReportBuilderReport(ReportBuilderReport report, String reason) {
        dao.retireReportBuilderReport(report, reason);
    }

    @Override
    public void purgeReportBuilderReport(ReportBuilderReport report) {
        dao.purgeReportBuilderReport(report);
    }

    @Override
    public CompiledReportArtifacts compileReport(String reportBuilderReportUuid) {
        ReportDefinitionService reportDefinitionService = Context.getService(ReportDefinitionService.class);

        ReportBuilderReport report = getReportBuilderReportByUuid(reportBuilderReportUuid);
        if (report == null) {
            throw new IllegalArgumentException("ReportBuilderReport not found: " + reportBuilderReportUuid);
        }

        report.setCompileStatus(ReportBuilderReport.ReportCompileStatus.COMPILING);
        saveReportBuilderReport(report);

        try {
            JsonNode reportConfig = parseJson(report.getConfigJson(), "Invalid ReportBuilderReport configJson");

            JsonNode definitionNode = reportConfig.path("definition");
            JsonNode designNode = reportConfig.path("design");

            JsonNode sections = definitionNode.path("sections");
            if (!sections.isArray()) {
                sections = reportConfig.path("sections");
            }

            ArrayNode compiledFields = objectMapper.createArrayNode();
            ArrayNode compiledDhis2Rows = objectMapper.createArrayNode();

            if (sections.isArray()) {
                List<JsonNode> sectionRefs = new ArrayList<JsonNode>();
                for (JsonNode s : sections) {
                    if (s.path("enabled").asBoolean(true)) {
                        sectionRefs.add(s);
                    }
                }

                sectionRefs.sort(Comparator.comparingInt(a -> a.path("sortOrder").asInt(9999)));

                for (JsonNode sectionRef : sectionRefs) {
                    String sectionUuid = sectionRef.path("sectionUuid").asText(null);
                    if (sectionUuid == null || sectionUuid.trim().isEmpty()) {
                        continue;
                    }

                    ReportBuilderSection section = getReportBuilderSectionByUuid(sectionUuid);
                    if (section == null) {
                        continue;
                    }

                    JsonNode sectionConfig = parseJson(section.getConfigJson(), "Invalid section configJson for " + sectionUuid);

                    String sectionName = sectionRef.path("titleOverride").asText(null);
                    if (sectionName == null || sectionName.trim().isEmpty()) {
                        sectionName = section.getName();
                    }

                    ArrayNode sectionFields = compileSectionToReportFields(sectionName, sectionConfig);
                    for (JsonNode f : sectionFields) {
                        compiledFields.add(f);
                    }

                    appendSectionDhis2Mappings(compiledDhis2Rows, sectionConfig);
                }
            }

            ObjectNode compiledDefinitionRoot = objectMapper.createObjectNode();
            compiledDefinitionRoot.put("version", 1);
            compiledDefinitionRoot.put("name", report.getName());
            compiledDefinitionRoot.put("code", report.getCode());
            compiledDefinitionRoot.set("report_fields", compiledFields);

            String compiledDefinitionJson;
            try {
                compiledDefinitionJson = objectMapper.writerWithDefaultPrettyPrinter()
                        .writeValueAsString(compiledDefinitionRoot);
            } catch (Exception e) {
                throw new RuntimeException("Failed to serialize compiled report definition JSON", e);
            }

            String definitionFileName = buildDefinitionFileName(report);
            File definitionFile;
            try {
                definitionFile = ReportDesignFileUtil.writeJsonStringToDesignFile(definitionFileName, compiledDefinitionJson);
            } catch (Exception e) {
                throw new RuntimeException("Failed to write compiled report definition file", e);
            }

            ArrayNode compiledDesignGroups;
            JsonNode authoredGroups = designNode.path("groups");
            if (authoredGroups.isArray() && authoredGroups.size() > 0) {
                compiledDesignGroups = compileAuthoredDesignGroups(authoredGroups, sections);
            } else {
                compiledDesignGroups = compileGeneratedDesignGroupsFromSections(sections, designNode);
            }

            ObjectNode compiledDesignRoot = objectMapper.createObjectNode();
            compiledDesignRoot.put("version", 1);
            compiledDesignRoot.put("name", report.getName());
            compiledDesignRoot.put("code", report.getCode());
            compiledDesignRoot.put("template", designNode.path("template").asText("section-tabular"));
            compiledDesignRoot.put("arrayName", designNode.path("arrayName").asText("results"));
            compiledDesignRoot.put("defaultValue", designNode.path("defaultValue").asInt(0));
            compiledDesignRoot.set("groups", compiledDesignGroups);
            compiledDesignRoot.set("dimensions", compileDimensionsFromDesignAndSections(designNode, sections));

            ObjectNode compiledDhis2 = objectMapper.createObjectNode();
            compiledDhis2.put("enabled", compiledDhis2Rows.size() > 0);
            compiledDhis2.set("rows", compiledDhis2Rows);
            compiledDesignRoot.set("dhis2", compiledDhis2);

            String compiledDesignJson;
            try {
                compiledDesignJson = objectMapper.writerWithDefaultPrettyPrinter()
                        .writeValueAsString(compiledDesignRoot);
            } catch (Exception e) {
                throw new RuntimeException("Failed to serialize compiled report design JSON", e);
            }

            ReportDefinition reportDefinition = findOrCreateReportDefinition(report, reportDefinitionService);

            AggregateReportDataSetDefinition dsd = new AggregateReportDataSetDefinition();
            dsd.setName(report.getName() + " Data Set");
            dsd.setDescription(report.getDescription());
            dsd.setReportDesign(definitionFile);
            dsd.addParameter(new Parameter("startDate", "Start Date", Date.class));
            dsd.addParameter(new Parameter("endDate", "End Date", Date.class));

            reportDefinition.setName(report.getName());
            reportDefinition.setDescription(report.getDescription());
            reportDefinition.getParameters().clear();
            reportDefinition.addParameter(new Parameter("startDate", "Start Date", Date.class));
            reportDefinition.addParameter(new Parameter("endDate", "End Date", Date.class));
            reportDefinition.getDataSetDefinitions().clear();

            Map<String, Object> parameterMappings = new HashMap<String, Object>();
            parameterMappings.put("startDate", "${startDate}");
            parameterMappings.put("endDate", "${endDate}");

            reportDefinition.addDataSetDefinition("defaultDataSet", dsd, parameterMappings);
            reportDefinition = reportDefinitionService.saveDefinition(reportDefinition);

            ReportDesign jsonDesign = saveOrUpdateJsonReportDesign(reportDefinition, compiledDesignJson, report);

            report.setCompiledReportDefinitionUuid(reportDefinition.getUuid());
            report.setCompiledReportDesignUuid(jsonDesign != null ? jsonDesign.getUuid() : null);
            report.setLastCompiledAt(new Date());
            report.setCompileStatus(ReportBuilderReport.ReportCompileStatus.COMPILED);
            report = saveReportBuilderReport(report);

            CompiledReportArtifacts out = new CompiledReportArtifacts();
            out.setReportBuilderReport(report);
            out.setReportDefinition(reportDefinition);
            out.setReportDesignFile(definitionFile);
            out.setCompiledJson(compiledDefinitionJson);
            return out;
        } catch (Exception e) {
            report.setLastCompiledAt(new Date());
            report.setCompileStatus(ReportBuilderReport.ReportCompileStatus.FAILED);
            saveReportBuilderReport(report);
            throw e;
        }
    }

    private ArrayNode compileAuthoredDesignGroups(JsonNode authoredGroups, JsonNode sections) {
        ArrayNode out = objectMapper.createArrayNode();
        Map<String, ObjectNode> sectionMeta = buildSectionDimensionMetadata(sections);

        for (JsonNode groupNode : authoredGroups) {
            ObjectNode group = objectMapper.createObjectNode();
            group.put("title", groupNode.path("title").asText(""));

            String groupId = groupNode.path("id").asText(null);
            ObjectNode meta = groupId != null ? sectionMeta.get(groupId) : null;

            boolean disaggregated = meta != null && meta.path("disaggregated").asBoolean(false);
            String ageCategoryCode = meta != null ? meta.path("ageCategoryCode").asText("") : "";

            ArrayNode rowsOut = objectMapper.createArrayNode();
            JsonNode rows = groupNode.path("rows");

            if (rows.isArray()) {
                for (JsonNode rowNode : rows) {
                    ObjectNode row = objectMapper.createObjectNode();

                    String type = rowNode.path("type").asText("indicator");
                    row.put("type", type);
                    row.put("label", rowNode.path("label").asText(""));
                    row.put("indent", rowNode.path("indent").asInt(0));

                    if (rowNode.hasNonNull("code")) {
                        row.put("code", rowNode.path("code").asText(""));
                    }
                    if (rowNode.hasNonNull("indicatorUuid")) {
                        row.put("indicatorUuid", rowNode.path("indicatorUuid").asText(""));
                    }
                    if (rowNode.hasNonNull("span")) {
                        row.put("span", rowNode.path("span").asText(""));
                    }
                    if (rowNode.hasNonNull("emphasis")) {
                        row.put("emphasis", rowNode.path("emphasis").asText(""));
                    }

                    if ("indicator".equals(type)) {
                        row.put("showTotal", rowNode.path("showTotal").asBoolean(true));
                        row.put("showDisaggregation", rowNode.path("showDisaggregation").asBoolean(disaggregated));

                        if (rowNode.hasNonNull("keyPattern")) {
                            row.put("keyPattern", rowNode.path("keyPattern").asText(""));
                        } else {
                            row.put("keyPattern", disaggregated ? "{code}_{age}_{sex}" : "{code}_TOTAL");
                        }

                        ObjectNode dims = objectMapper.createObjectNode();
                        JsonNode authoredDims = rowNode.path("dims");
                        if (authoredDims.isObject()) {
                            dims.setAll((ObjectNode) authoredDims);
                        }

                        if (disaggregated) {
                            if (!dims.has("age") && ageCategoryCode != null && !ageCategoryCode.trim().isEmpty()) {
                                dims.put("age", ageCategoryCode);
                            }
                            if (!dims.has("sex")) {
                                dims.put("sex", "sex");
                            }
                        }

                        row.set("dims", dims);
                    } else if ("section-label".equals(type)) {
                        row.put("showTotal", false);
                        row.put("showDisaggregation", false);
                        if (!row.has("span")) {
                            row.put("span", "all");
                        }
                        if (!row.has("emphasis")) {
                            row.put("emphasis", "section");
                        }
                    } else if ("group-label".equals(type)) {
                        row.put("showTotal", false);
                        row.put("showDisaggregation", false);
                        if (!row.has("span")) {
                            row.put("span", "label-only");
                        }
                        if (!row.has("emphasis")) {
                            row.put("emphasis", "group");
                        }
                    } else {
                        row.put("showTotal", false);
                        row.put("showDisaggregation", false);
                    }

                    rowsOut.add(row);
                }
            }

            group.set("rows", rowsOut);
            out.add(group);
        }

        return out;
    }

    private ArrayNode compileGeneratedDesignGroupsFromSections(JsonNode sections, JsonNode designNode) {
        ArrayNode out = objectMapper.createArrayNode();
        if (!sections.isArray()) {
            return out;
        }

        List<JsonNode> sectionRefs = new ArrayList<JsonNode>();
        for (JsonNode s : sections) {
            if (s.path("enabled").asBoolean(true)) {
                sectionRefs.add(s);
            }
        }
        sectionRefs.sort(Comparator.comparingInt(a -> a.path("sortOrder").asInt(9999)));

        for (JsonNode sectionRef : sectionRefs) {
            String sectionUuid = sectionRef.path("sectionUuid").asText(null);
            if (sectionUuid == null || sectionUuid.trim().isEmpty()) {
                continue;
            }

            ReportBuilderSection section = getReportBuilderSectionByUuid(sectionUuid);
            if (section == null) {
                continue;
            }

            JsonNode sectionConfig = parseJson(section.getConfigJson(), "Invalid section configJson for " + sectionUuid);

            String sectionName = sectionRef.path("titleOverride").asText(null);
            if (sectionName == null || sectionName.trim().isEmpty()) {
                sectionName = section.getName();
            }

            ObjectNode group = compileSectionToDesignGroup(sectionName, sectionConfig, designNode);
            if (group != null) {
                out.add(group);
            }
        }

        return out;
    }

    private ObjectNode compileDimensionsFromDesignAndSections(JsonNode designNode, JsonNode sections) {
        ObjectNode dimensions = objectMapper.createObjectNode();

        ArrayNode sex = objectMapper.createArrayNode();
        ObjectNode female = objectMapper.createObjectNode();
        female.put("id", "F");
        female.put("label", "Female");
        sex.add(female);

        ObjectNode male = objectMapper.createObjectNode();
        male.put("id", "M");
        male.put("label", "Male");
        sex.add(male);

        dimensions.set("sex", sex);

        JsonNode authoredDimensions = designNode.path("dimensions");
        if (authoredDimensions.isObject()) {
            Iterator<String> names = authoredDimensions.fieldNames();
            while (names.hasNext()) {
                String name = names.next();
                dimensions.set(name, authoredDimensions.get(name));
            }
        }

        if (sections.isArray()) {
            for (JsonNode sectionRef : sections) {
                String sectionUuid = sectionRef.path("sectionUuid").asText(null);
                if (sectionUuid == null || sectionUuid.trim().isEmpty()) {
                    continue;
                }

                ReportBuilderSection section = getReportBuilderSectionByUuid(sectionUuid);
                if (section == null) {
                    continue;
                }

                JsonNode sectionConfig = parseJson(section.getConfigJson(), "Invalid section configJson for " + sectionUuid);
                String ageCategoryCode = sectionConfig.path("disaggregation").path("ageCategoryCode").asText(null);

                if (ageCategoryCode != null && !ageCategoryCode.trim().isEmpty() && !dimensions.has(ageCategoryCode)) {
                    ArrayNode ageOptions = compileAgeDimension(ageCategoryCode);
                    if (ageOptions.size() > 0) {
                        dimensions.set(ageCategoryCode, ageOptions);
                    }
                }
            }
        }

        return dimensions;
    }

    private ArrayNode compileAgeDimension(String ageCategoryCode) {
        ArrayNode out = objectMapper.createArrayNode();

        ReportBuilderAgeCategory category = getAgeCategoryByCode(ageCategoryCode);
        if (category == null || category.getAgeGroups() == null) {
            return out;
        }

        List<ReportBuilderAgeGroup> groups = new ArrayList<ReportBuilderAgeGroup>(category.getAgeGroups());
        groups.sort(Comparator.comparingInt(g -> g.getSortOrder() == null ? Integer.MAX_VALUE : g.getSortOrder()));

        for (ReportBuilderAgeGroup g : groups) {
            if (g == null || !Boolean.TRUE.equals(g.getActive()) || g.getLabel() == null || g.getLabel().trim().isEmpty()) {
                continue;
            }

            ObjectNode one = objectMapper.createObjectNode();
            one.put("id", sanitize(g.getLabel()));
            one.put("label", g.getLabel());
            out.add(one);
        }

        return out;
    }

    private ObjectNode compileSectionToDesignGroup(String sectionName, JsonNode sectionConfig, JsonNode reportDesignNode) {
        ObjectNode group = objectMapper.createObjectNode();
        group.put("title", sectionName);

        ArrayNode rows = objectMapper.createArrayNode();

        ObjectNode sectionRow = objectMapper.createObjectNode();
        sectionRow.put("type", "section-label");
        sectionRow.put("label", sectionName);
        sectionRow.put("indent", 0);
        sectionRow.put("span", "all");
        sectionRow.put("emphasis", "section");
        sectionRow.put("showTotal", false);
        sectionRow.put("showDisaggregation", false);
        rows.add(sectionRow);

        JsonNode indicators = sectionConfig.path("indicators");
        if (indicators.isArray()) {
            List<JsonNode> sorted = new ArrayList<JsonNode>();
            for (JsonNode ind : indicators) {
                sorted.add(ind);
            }
            sorted.sort(Comparator.comparingInt(a -> a.path("sortOrder").asInt(9999)));

            for (JsonNode indicator : sorted) {
                ObjectNode row = objectMapper.createObjectNode();
                row.put("type", "indicator");
                row.put("indicatorUuid", indicator.path("indicatorUuid").asText(""));
                row.put("code", indicator.path("code").asText(""));
                row.put("label", indicator.path("name").asText(""));
                row.put("indent", 1);
                row.put("keyPattern", buildIndicatorKeyPattern(indicator, sectionConfig));
                row.put("showTotal", true);
                row.put("showDisaggregation", looksDisaggregated(indicator, sectionConfig));
                row.put("span", "label-only");
                row.put("emphasis", "normal");

                ObjectNode dims = objectMapper.createObjectNode();
                if (looksDisaggregated(indicator, sectionConfig)) {
                    dims.put("age", sectionConfig.path("disaggregation").path("ageCategoryCode").asText(""));
                    dims.put("sex", "sex");
                }
                row.set("dims", dims);

                rows.add(row);
            }
        }

        group.set("rows", rows);
        return group;
    }

    private String buildIndicatorKeyPattern(JsonNode indicator, JsonNode sectionConfig) {
        if (looksDisaggregated(indicator, sectionConfig)) {
            return "{code}_{age}_{sex}";
        }
        return "{code}_TOTAL";
    }

    private void appendSectionDhis2Mappings(ArrayNode targetRows, JsonNode sectionConfig) {
        JsonNode dhis2 = sectionConfig.path("exchangeMappings").path("dhis2");
        if (!dhis2.isObject() || !dhis2.path("enabled").asBoolean(false)) {
            return;
        }

        JsonNode mappings = dhis2.path("indicatorMappings");
        if (!mappings.isArray()) {
            return;
        }

        for (JsonNode m : mappings) {
            ObjectNode row = objectMapper.createObjectNode();
            row.put("indicatorUuid", m.path("indicatorUuid").asText(""));
            row.put("indicatorCode", m.path("indicatorCode").asText(""));
            row.put("dataElementId", m.path("dataElementId").asText(""));

            JsonNode coc = m.path("categoryOptionComboByDisagg");
            if (coc.isObject()) {
                row.set("categoryOptionComboByDisagg", coc);
            } else {
                row.set("categoryOptionComboByDisagg", objectMapper.createObjectNode());
            }

            targetRows.add(row);
        }
    }

    private ReportDesign saveOrUpdateJsonReportDesign(ReportDefinition reportDefinition, String compiledDesignJson, ReportBuilderReport report) {
        ReportService reportService = Context.getService(ReportService.class);

        ReportDesign design = null;

        String existingDesignUuid = report.getCompiledReportDesignUuid();
        if (existingDesignUuid != null && !existingDesignUuid.trim().isEmpty()) {
            design = reportService.getReportDesignByUuid(existingDesignUuid);
        }

        if (design == null) {
            List<ReportDesign> existing = reportService.getReportDesigns(reportDefinition, null, false);
            if (existing != null) {
                for (ReportDesign d : existing) {
                    if ("JSON".equalsIgnoreCase(d.getName())) {
                        design = d;
                        break;
                    }
                }
            }
        }

        if (design == null) {
            design = new ReportDesign();
            design.setUuid(UUID.randomUUID().toString());
            design.setName("JSON");
            design.setReportDefinition(reportDefinition);
            design.setRendererType(TextTemplateRenderer.class);
        } else {
            design.setName("JSON");
            design.setReportDefinition(reportDefinition);
            design.setRendererType(TextTemplateRenderer.class);
            if (design.getResources() != null) {
                design.getResources().clear();
            }
        }

        ReportDesignResource resource = new ReportDesignResource();
        resource.setName("template");
        resource.setExtension("json");
        resource.setContentType("application/json");
        resource.setContents(compiledDesignJson.getBytes(StandardCharsets.UTF_8));
        resource.setReportDesign(design);

        design.addResource(resource);

        return reportService.saveReportDesign(design);
    }

    private ArrayNode compileSectionToReportFields(String sectionName, JsonNode sectionConfig) {
        ArrayNode out = objectMapper.createArrayNode();
        JsonNode indicators = sectionConfig.path("indicators");

        if (!indicators.isArray()) {
            return out;
        }

        List<JsonNode> sorted = new ArrayList<JsonNode>();
        for (JsonNode ind : indicators) {
            sorted.add(ind);
        }
        sorted.sort(Comparator.comparingInt(a -> a.path("sortOrder").asInt(9999)));

        for (JsonNode indicator : sorted) {
            String sql = indicator.path("sql").path("compiled").asText(null);
            if (sql == null || sql.trim().isEmpty()) {
                continue;
            }

            ObjectNode field = objectMapper.createObjectNode();
            field.put("indicator_name", indicator.path("code").asText(""));
            field.put("indicator_label", indicator.path("name").asText(""));
            field.put("subsection", sectionName);
            field.put("sqlQuery", decodeHtml(sql));

            boolean isDisaggregated = looksDisaggregated(indicator, sectionConfig);

            if (isDisaggregated) {
                ArrayNode dissaggregations = objectMapper.createArrayNode();
                dissaggregations.add("age_group");
                dissaggregations.add("gender");
                field.set("dissaggregations", dissaggregations);

                ArrayNode values = buildDisaggregatedValues(indicator, sectionConfig);
                if (values.size() > 0) {
                    field.set("values", values);
                } else {
                    field.put("value_place_holder", buildSinglePlaceholder(indicator));
                }
            } else {
                field.put("value_place_holder", buildSinglePlaceholder(indicator));
            }

            out.add(field);
        }

        return out;
    }

    private boolean looksDisaggregated(JsonNode indicator, JsonNode sectionConfig) {
        JsonNode strategy = indicator.path("sql").path("strategy");
        if (strategy.isTextual() && strategy.asText("").contains("DISAGG")) {
            return true;
        }

        JsonNode dis = sectionConfig.path("disaggregation");
        return dis.isObject() && !dis.path("none").asBoolean(false);
    }

    private ArrayNode buildDisaggregatedValues(JsonNode indicator, JsonNode sectionConfig) {
        ArrayNode out = objectMapper.createArrayNode();

        String indicatorCode = indicator.path("code").asText("IND");
        JsonNode dis = sectionConfig.path("disaggregation");
        JsonNode genders = dis.path("genders");

        String ageCategoryCode = dis.path("ageCategoryCode").asText(null);
        List<String> ageLabels = resolveAgeGroupLabels(ageCategoryCode);

        if (!ageLabels.isEmpty() && genders.isArray()) {
            for (String ageLabel : ageLabels) {
                for (JsonNode g : genders) {
                    String gender = g.asText("");

                    ObjectNode one = objectMapper.createObjectNode();
                    one.put("dissaggregations1", ageLabel);
                    one.put("dissaggregations2", gender);
                    one.put("value_place_holder", buildDisaggregatedPlaceholder(indicatorCode, ageLabel, gender));
                    out.add(one);
                }
            }
        }

        return out;
    }

    private String buildSinglePlaceholder(JsonNode indicator) {
        String code = indicator.path("code").asText("IND");
        return sanitize(code) + "_TOTAL";
    }

    private String sanitize(String s) {
        return (s == null ? "" : s.trim())
                .replace("+", "plus")
                .replace("<", "lt")
                .replace(">", "gt")
                .replaceAll("[^A-Za-z0-9]+", "_")
                .replaceAll("_+", "_")
                .replaceAll("^_", "")
                .replaceAll("_$", "");
    }

    private String buildDefinitionFileName(ReportBuilderReport report) {
        String base = report.getCode();
        if (base == null || base.trim().isEmpty()) {
            base = report.getUuid();
        }
        base = sanitize(base);
        if (base == null || base.trim().isEmpty()) {
            base = "report_" + System.currentTimeMillis();
        }
        return base + ".json";
    }

    private ReportDefinition findOrCreateReportDefinition(ReportBuilderReport report,
                                                          ReportDefinitionService reportDefinitionService) {
        String existingUuid = report.getCompiledReportDefinitionUuid();

        if (existingUuid != null && !existingUuid.trim().isEmpty()) {
            ReportDefinition existing = reportDefinitionService.getDefinitionByUuid(existingUuid);
            if (existing != null) {
                return existing;
            }
        }

        ReportDefinition rd = new ReportDefinition();
        rd.setName(report.getName());
        rd.setDescription(report.getDescription());
        return rd;
    }

    private JsonNode parseJson(String raw, String message) {
        try {
            return objectMapper.readTree(raw == null ? "{}" : raw);
        } catch (Exception e) {
            throw new IllegalArgumentException(message, e);
        }
    }

    private String decodeHtml(String s) {
        if (s == null) return "";
        return s.replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&#39;", "'");
    }

    private List<String> resolveAgeGroupLabels(String ageCategoryCode) {
        if (ageCategoryCode == null || ageCategoryCode.trim().isEmpty()) {
            return Collections.emptyList();
        }

        ReportBuilderAgeCategory category = getAgeCategoryByCode(ageCategoryCode);
        if (category == null || category.getAgeGroups() == null || category.getAgeGroups().isEmpty()) {
            return Collections.emptyList();
        }

        return category.getAgeGroups().stream()
                .filter(g -> g != null && Boolean.TRUE.equals(g.getActive()) && g.getLabel() != null && !g.getLabel().trim().isEmpty())
                .sorted(Comparator.comparingInt(g -> g.getSortOrder() == null ? Integer.MAX_VALUE : g.getSortOrder()))
                .map(ReportBuilderAgeGroup::getLabel)
                .collect(Collectors.toList());
    }

    private String buildDisaggregatedPlaceholder(String indicatorCode, String ageLabel, String gender) {
        return sanitize(indicatorCode) + "_" + sanitize(ageLabel) + "_" + sanitize(gender);
    }

    private Map<String, ObjectNode> buildSectionDimensionMetadata(JsonNode sections) {
        Map<String, ObjectNode> out = new LinkedHashMap<String, ObjectNode>();

        if (!sections.isArray()) {
            return out;
        }

        for (JsonNode sectionRef : sections) {
            String sectionUuid = sectionRef.path("sectionUuid").asText(null);
            if (sectionUuid == null || sectionUuid.trim().isEmpty()) {
                continue;
            }

            ReportBuilderSection section = getReportBuilderSectionByUuid(sectionUuid);
            if (section == null) {
                continue;
            }

            JsonNode sectionConfig = parseJson(section.getConfigJson(), "Invalid section configJson for " + sectionUuid);

            ObjectNode meta = objectMapper.createObjectNode();
            boolean disaggregated = sectionConfig.path("disaggregation").isObject()
                    && !sectionConfig.path("disaggregation").path("none").asBoolean(false);

            meta.put("disaggregated", disaggregated);
            meta.put("ageCategoryCode", sectionConfig.path("disaggregation").path("ageCategoryCode").asText(""));

            out.put(sectionUuid, meta);
        }

        return out;
    }


    @Override
    public ReportCategory saveReportCategory(ReportCategory category) {
        if (category.getUuid() == null) {
            category.setUuid(UUID.randomUUID().toString());
        }
        return dao.saveReportCategory(category);
    }

    @Override
    public ReportCategory getReportCategoryById(Integer id) {
        return dao.getReportCategoryById(id);
    }

    @Override
    public ReportCategory getReportCategoryByUuid(String uuid) {
        return dao.getReportCategoryByUuid(uuid);
    }

    @Override
    public List<ReportCategory> getReportCategories(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportCategories(q, includeRetired, startIndex, limit);
    }

    @Override
    public long getReportCategoriesCount(String q, boolean includeRetired) {
        return dao.getReportCategoriesCount(q, includeRetired);
    }

    @Override
    public void retireReportCategory(ReportCategory category, String reason) {
        category.setRetired(true);
        category.setRetireReason(reason);
        dao.saveReportCategory(category);
    }

    @Override
    public void unretireReportCategory(ReportCategory category) {
        category.setRetired(false);
        category.setRetireReason(null);
        dao.saveReportCategory(category);
    }

    @Override
    public void purgeReportCategory(ReportCategory category) {
        dao.purgeReportCategory(category);
    }


    @Override
    public ReportLibrary saveReportLibrary(ReportLibrary reportLibrary) {
        if (reportLibrary.getUuid() == null) {
            reportLibrary.setUuid(UUID.randomUUID().toString());
        }
        return dao.saveReportLibrary(reportLibrary);
    }

    @Override
    public ReportLibrary getReportLibraryById(Integer id) {
        return dao.getReportLibraryById(id);
    }

    @Override
    public ReportLibrary getReportLibraryByUuid(String uuid) {
        return dao.getReportLibraryByUuid(uuid);
    }

    @Override
    public List<ReportLibrary> getReportLibraries(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        return dao.getReportLibraries(q, includeRetired, startIndex, limit);
    }

    @Override
    public long getReportLibrariesCount(String q, boolean includeRetired) {
        return dao.getReportLibrariesCount(q, includeRetired);
    }

    @Override
    public void retireReportLibrary(ReportLibrary reportLibrary, String reason) {
        reportLibrary.setRetired(true);
        reportLibrary.setRetireReason(reason);
        dao.saveReportLibrary(reportLibrary);
    }

    @Override
    public void unretireReportLibrary(ReportLibrary reportLibrary) {
        reportLibrary.setRetired(false);
        reportLibrary.setRetireReason(null);
        dao.saveReportLibrary(reportLibrary);
    }

    @Override
    public void purgeReportLibrary(ReportLibrary reportLibrary) {
        dao.purgeReportLibrary(reportLibrary);
    }
}