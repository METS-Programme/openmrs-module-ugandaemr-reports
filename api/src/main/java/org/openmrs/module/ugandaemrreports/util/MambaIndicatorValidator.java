package org.openmrs.module.ugandaemrreports.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderIndicator;

public final class MambaIndicatorValidator {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private MambaIndicatorValidator() {}

    public static void validate(ReportBuilderIndicator ind) {
        if (ind == null) throw new IllegalArgumentException("Indicator is required");
        if (ind.getKind() == null) throw new IllegalArgumentException("Indicator.kind is required");
        if (isBlank(ind.getName())) throw new IllegalArgumentException("Indicator.name is required");
        if (isBlank(ind.getConfigJson())) throw new IllegalArgumentException("Indicator.configJson is required");

        final JsonNode root = parseJson(ind.getConfigJson(), "configJson");

        // metaJson is optional but if present must be valid JSON
        if (!isBlank(ind.getMetaJson())) {
            parseJson(ind.getMetaJson(), "metaJson");
        }
    }

    private static void validateBase(ReportBuilderIndicator ind) {
        // Allow sqlTemplate to be stored either in configJson.base.sqlTemplate OR in sqlTemplate column.
        // But require at least one.
        final String sql = !isBlank(ind.getSqlTemplate())
                ? ind.getSqlTemplate()
                : extractSqlTemplateFromConfig(ind.getConfigJson());

        if (isBlank(sql)) {
            throw new IllegalArgumentException("BASE indicators require sqlTemplate (either sqlTemplate column or configJson.base.sqlTemplate)");
        }

        // Required parameters used by your UI and runner
        requireContains(sql, ":startDate", "sqlTemplate must contain :startDate parameter");
        requireContains(sql, ":endDate", "sqlTemplate must contain :endDate parameter");

        // lightweight safety: block destructive statements (can be expanded later)
        final String lowered = sql.toLowerCase();
        if (lowered.contains(" drop ") || lowered.contains(" truncate ") || lowered.contains(" delete ") || lowered.contains(" update ")) {
            throw new IllegalArgumentException("sqlTemplate contains a potentially destructive statement");
        }

        // Optional denominator SQL should also have same params if present
        if (!isBlank(ind.getDenominatorSqlTemplate())) {
            requireContains(ind.getDenominatorSqlTemplate(), ":startDate", "denominatorSqlTemplate must contain :startDate parameter");
            requireContains(ind.getDenominatorSqlTemplate(), ":endDate", "denominatorSqlTemplate must contain :endDate parameter");
        }
    }

    private static String extractSqlTemplateFromConfig(String configJson) {
        try {
            JsonNode root = MAPPER.readTree(configJson);
            JsonNode base = root.get("base");
            if (base != null && base.isObject()) {
                JsonNode sql = base.get("sqlTemplate");
                if (sql != null && sql.isTextual()) return sql.asText();
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    private static JsonNode parseJson(String raw, String fieldName) {
        try {
            return MAPPER.readTree(raw);
        } catch (Exception e) {
            throw new IllegalArgumentException(fieldName + " must be valid JSON");
        }
    }

    private static void requireObject(JsonNode root, String key, String message) {
        JsonNode node = root.get(key);
        if (node == null || !node.isObject()) throw new IllegalArgumentException(message);
    }

    private static void requireContains(String haystack, String needle, String message) {
        if (haystack == null || !haystack.contains(needle)) throw new IllegalArgumentException(message);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}