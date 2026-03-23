package org.openmrs.module.ugandaemrreports.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderIndicator;

public final class MambaIndicatorSqlSync {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private MambaIndicatorSqlSync() {}

    public static void normalizeBaseSql(ReportBuilderIndicator ind) {
        if (ind == null || ind.getKind() != ReportBuilderIndicator.Kind.BASE) return;

        // If sqlTemplate already set, trust it.
        if (notBlank(ind.getSqlTemplate())) return;

        // Else attempt to read configJson.base.sqlTemplate
        try {
            JsonNode root = MAPPER.readTree(ind.getConfigJson());
            JsonNode base = root.get("base");
            if (base != null && base.isObject()) {
                JsonNode sql = base.get("sqlTemplate");
                if (sql != null && sql.isTextual() && notBlank(sql.asText())) {
                    ind.setSqlTemplate(sql.asText());
                }
                JsonNode denom = base.get("denominatorSqlTemplate");
                if (denom != null && denom.isTextual() && notBlank(denom.asText())) {
                    ind.setDenominatorSqlTemplate(denom.asText());
                }
            }
        } catch (Exception ignored) {
            // validator already ensures configJson is valid JSON; this is just a safe guard
        }
    }

    private static boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }
}