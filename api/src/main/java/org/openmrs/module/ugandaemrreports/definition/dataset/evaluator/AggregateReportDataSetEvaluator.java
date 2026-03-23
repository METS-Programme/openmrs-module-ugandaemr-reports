package org.openmrs.module.ugandaemrreports.definition.dataset.evaluator;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.annotation.Handler;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.dataset.SimpleDataSet;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.evaluator.DataSetEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.querybuilder.SqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.ugandaemrreports.common.PatientDataHelper;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;
import org.openmrs.module.ugandaemrreports.model.ValueHolder;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Handler(supports = { AggregateReportDataSetDefinition.class })
public class AggregateReportDataSetEvaluator implements DataSetEvaluator {

    @Autowired
    private EvaluationService evaluationService;

    @Autowired
    private DbSessionFactory sessionFactory;

    @Override
    public SimpleDataSet evaluate(DataSetDefinition dataSetDefinition, EvaluationContext evaluationContext) throws EvaluationException {
        AggregateReportDataSetDefinition definition = (AggregateReportDataSetDefinition) dataSetDefinition;

        SimpleDataSet dataSet = new SimpleDataSet(definition, evaluationContext);
        DataSetRow row = getReportQuery(definition, evaluationContext);
        dataSet.addRow(row);

        return dataSet;
    }

    private List<Object[]> getEtl(String q, EvaluationContext context) {
        SqlQueryBuilder query = new SqlQueryBuilder(q);
        return evaluationService.evaluateToList(query, context);
    }

    private DataSetRow getReportQuery(AggregateReportDataSetDefinition definition, EvaluationContext evaluationContext) {
        DataSetRow row = new DataSetRow();

        Date startDateValue = resolveDateParameter(evaluationContext, "startDate", definition.getStartDate());
        Date endDateValue = resolveDateParameter(evaluationContext, "endDate", definition.getEndDate());

        String startDate = formatDateYmd(startDateValue);
        String endDate = formatDateYmd(endDateValue);

        File file = definition.getReportDesign();

        if (file == null) {
            throw new RuntimeException("Report design file is not configured");
        }
        if (!file.exists()) {
            throw new RuntimeException("Report design file not found: " + file.getAbsolutePath());
        }

        ObjectMapper objectMapper = new ObjectMapper();

        try {
            JsonNode rootNode = objectMapper.readTree(file);

            if (rootNode.has("report_fields") && rootNode.path("report_fields").isArray()) {
                return evaluateLegacyReport(rootNode, evaluationContext, row, startDate, endDate);
            }

            if (rootNode.has("indicators") && rootNode.path("indicators").isArray()) {
                return evaluateSingleSection(rootNode, evaluationContext, row, startDate, endDate);
            }

            if (rootNode.has("sections") && rootNode.path("sections").isArray()) {
                return evaluateSectionBasedReport(rootNode, evaluationContext, row, startDate, endDate);
            }

            throw new RuntimeException("Unsupported report design format: " + file.getAbsolutePath());

        } catch (Exception e) {
            throw new RuntimeException("Failed to evaluate report design: " + file.getAbsolutePath(), e);
        }
    }

    private DataSetRow evaluateLegacyReport(JsonNode rootNode, EvaluationContext evaluationContext, DataSetRow row,
                                            String startDate, String endDate) {

        JsonNode reportFieldsArray = rootNode.path("report_fields");

        for (JsonNode reportField : reportFieldsArray) {
            String sqlQuery = cleanupSql(reportField.path("sqlQuery").asText());
            String query = applyDatePlaceholders(sqlQuery, startDate, endDate);

            List<Object[]> results = getEtl(query, evaluationContext);

            if (reportField.has("values")) {
                List<ValueHolder> convertedResults = convertToValueHolderList(results);
                row = placesValuesToDataSetRow(reportField, convertedResults, row);

            } else if (reportField.has("value_place_holder")) {
                ValueHolder convertedResult = null;
                if (results != null && !results.isEmpty()) {
                    convertedResult = convertSingleResultToValueHolder(results.get(0));
                }
                row = placesValueToDataSetRow(reportField, convertedResult, row);
            }
        }

        return row;
    }

    private DataSetRow evaluateSingleSection(JsonNode rootNode, EvaluationContext evaluationContext, DataSetRow row,
                                             String startDate, String endDate) {

        String sectionName = rootNode.path("name").asText("");
        JsonNode indicators = rootNode.path("indicators");

        for (JsonNode indicator : indicators) {
            row = evaluateNewIndicator(sectionName, indicator, evaluationContext, row, startDate, endDate);
        }

        return row;
    }

    private DataSetRow evaluateSectionBasedReport(JsonNode rootNode, EvaluationContext evaluationContext, DataSetRow row,
                                                  String startDate, String endDate) {

        JsonNode sections = rootNode.path("sections");

        for (JsonNode section : sections) {
            String sectionName = section.path("name").asText("");
            JsonNode indicators = section.path("indicators");

            if (indicators.isArray()) {
                for (JsonNode indicator : indicators) {
                    row = evaluateNewIndicator(sectionName, indicator, evaluationContext, row, startDate, endDate);
                }
            }
        }

        return row;
    }

    private DataSetRow evaluateNewIndicator(String sectionName, JsonNode indicator, EvaluationContext evaluationContext,
                                            DataSetRow row, String startDate, String endDate) {

        String indicatorCode = indicator.path("code").asText("");
        String indicatorName = indicator.path("name").asText("");
        String sqlQuery = cleanupSql(indicator.path("sql").path("compiled").asText(""));

        if (sqlQuery == null || sqlQuery.trim().isEmpty()) {
            return row;
        }

        String query = applyDatePlaceholders(sqlQuery, startDate, endDate);
        List<Object[]> results = getEtl(query, evaluationContext);

        String baseKey = buildBaseColumnKey(indicatorCode, indicatorName, sectionName);
        PatientDataHelper pdh = new PatientDataHelper();

        if (results == null || results.isEmpty()) {
            pdh.addCol(row, baseKey + "_TOTAL", 0);
            return row;
        }

        for (Object[] result : results) {
            if (result == null || result.length == 0) {
                continue;
            }

            if (result.length >= 3) {
                String disag1 = safeString(result[0]);
                String disag2 = safeString(result[1]);
                int value = safeInt(result[2]);

                String col = baseKey + "_" + sanitizeKey(disag1) + "_" + sanitizeKey(disag2);
                pdh.addCol(row, col, value);
                continue;
            }

            if (result.length == 2) {
                String maybeLabel = safeString(result[0]);
                int value = safeInt(result[1]);

                String col = baseKey + "_" + sanitizeKey(maybeLabel);
                pdh.addCol(row, col, value);
                continue;
            }

            if (result.length == 1) {
                int value = safeInt(result[0]);
                pdh.addCol(row, baseKey + "_TOTAL", value);
            }
        }

        return row;
    }

    private Date resolveDateParameter(EvaluationContext context, String name, Date fallback) {
        Object val = context.getParameterValue(name);
        if (val instanceof Date) {
            return (Date) val;
        }
        return fallback;
    }

    private String formatDateYmd(Date date) {
        return date != null ? DateUtil.formatDate(date, "yyyy-MM-dd") : null;
    }

    private static String cleanupSql(String sql) {
        if (sql == null) {
            return "";
        }

        return sql
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&#39;", "'")
                .trim();
    }

    private static String applyDatePlaceholders(String sql, String startDate, String endDate) {
        String out = sql;

        if (startDate != null) {
            out = out.replace(":startDate", "'" + startDate + "'");
        }

        if (endDate != null) {
            out = out.replace(":endDate", "'" + endDate + "'");
        }

        return out;
    }

    private static String buildBaseColumnKey(String indicatorCode, String indicatorName, String sectionName) {
        String primary = indicatorCode != null && !indicatorCode.trim().isEmpty() ? indicatorCode : indicatorName;

        if (primary == null || primary.trim().isEmpty()) {
            primary = sectionName;
        }
        if (primary == null || primary.trim().isEmpty()) {
            primary = "VALUE";
        }

        return sanitizeKey(primary);
    }

    private static String sanitizeKey(String s) {
        if (s == null || s.trim().isEmpty()) {
            return "NA";
        }

        String out = s.trim()
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">");

        out = out.replaceAll("[^A-Za-z0-9]+", "_");
        out = out.replaceAll("_+", "_");
        out = out.replaceAll("^_", "");
        out = out.replaceAll("_$", "");

        return out.isEmpty() ? "NA" : out;
    }

    private static String safeString(Object o) {
        return o == null ? "" : String.valueOf(o);
    }

    private static int safeInt(Object o) {
        if (o == null) {
            return 0;
        }

        try {
            if (o instanceof Number) {
                return ((Number) o).intValue();
            }
            return Integer.parseInt(String.valueOf(o));
        } catch (Exception e) {
            return 0;
        }
    }

    private static boolean safeEquals(String a, String b) {
        return (a == null ? "" : a).equals(b == null ? "" : b);
    }

    private static DataSetRow placesValuesToDataSetRow(JsonNode reportField, List<ValueHolder> values, DataSetRow row) {
        JsonNode valuesArray = reportField.path("values");
        PatientDataHelper pdh = new PatientDataHelper();

        for (JsonNode valueObject : valuesArray) {
            String dissaggregations1 = valueObject.path("dissaggregations1").asText();
            String dissaggregations2 = valueObject.path("dissaggregations2").asText();
            String valuePlaceHolder = valueObject.path("value_place_holder").asText();

            ValueHolder valueHolder;
            if (!values.isEmpty()) {
                valueHolder = values.stream()
                        .filter(v -> safeEquals(v.getDisag1(), dissaggregations1))
                        .filter(v -> safeEquals(v.getDisag2(), dissaggregations2))
                        .findFirst()
                        .orElse(null);
            } else {
                valueHolder = null;
            }

            int count = 0;
            if (valueHolder != null) {
                count = safeInt(valueHolder.getPlaceholder());
            }

            pdh.addCol(row, valuePlaceHolder, count);
        }

        return row;
    }

    private static DataSetRow placesValueToDataSetRow(JsonNode reportField, ValueHolder valueHolder, DataSetRow row) {
        String valuePlaceHolder = reportField.path("value_place_holder").asText();
        PatientDataHelper pdh = new PatientDataHelper();

        int count = 0;
        if (valueHolder != null) {
            count = safeInt(valueHolder.getPlaceholder());
        }

        pdh.addCol(row, valuePlaceHolder, count);
        return row;
    }

    public static List<ValueHolder> convertToValueHolderList(List<Object[]> results) {
        List<ValueHolder> valueHolderList = new ArrayList<ValueHolder>();

        if (results != null && !results.isEmpty()) {
            for (Object[] result : results) {
                if (result == null || result.length < 3) {
                    continue;
                }

                String disag1 = safeString(result[0]);
                String disag2 = safeString(result[1]);
                String placeholder = safeString(result[2]);

                valueHolderList.add(new ValueHolder(disag1, disag2, placeholder));
            }
        }

        return valueHolderList;
    }

    public static ValueHolder convertSingleResultToValueHolder(Object[] result) {
        if (result == null || result.length == 0) {
            return null;
        }

        if (result.length == 1) {
            return new ValueHolder("TOTAL", null, safeString(result[0]));
        }

        return new ValueHolder(safeString(result[0]), null, safeString(result[1]));
    }

    public DbSessionFactory getSessionFactory() {
        return sessionFactory;
    }

    public void setSessionFactory(DbSessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }
}