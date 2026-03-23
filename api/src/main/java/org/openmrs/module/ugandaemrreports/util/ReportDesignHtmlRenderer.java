package org.openmrs.module.ugandaemrreports.util;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.util.*;

/**
 * Renders compiled report design JSON into:
 * 1) HTML preview/final document
 * 2) Payload JSON for downstream exchange
 * 3) Composite output wrapper:
 *    {
 *      "json": { ... },
 *      "html": "...",
 *      "dhis2": { ... }
 *    }
 *
 * Expected input format:
 * {
 *   "version": 1,
 *   "name": "...",
 *   "code": "...",
 *   "template": "section-tabular",
 *   "arrayName": "results",
 *   "defaultValue": 0,
 *   "groups": [ ... ],
 *   "dimensions": { ... },
 *   "dhis2": { ... }
 * }
 */
public class ReportDesignHtmlRenderer {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    public static class Result {
        public final String html;
        public final String payloadJson;
        public final String renderedOutputJson;

        public Result(String html, String payloadJson, String renderedOutputJson) {
            this.html = html;
            this.payloadJson = payloadJson;
            this.renderedOutputJson = renderedOutputJson;
        }
    }

    public Result convert(String templateJson,
                          Map<String, Object> flatValues,
                          String remapJsonOptional) {
        String html = renderHtmlFinal(templateJson, flatValues);
        String payload = buildPayloadOnly(templateJson, flatValues, remapJsonOptional);
        String rendered = buildRenderedOutputOnly(templateJson, flatValues, remapJsonOptional);
        return new Result(html, payload, rendered);
    }

    /* -------------------- FINAL HTML -------------------- */

    public String renderHtmlFinal(String templateJson, Map<String, Object> flatValues) {
        try {
            ReportDesignTemplate tpl = MAPPER.readValue(templateJson, ReportDesignTemplate.class);
            Map<String, Object> values = flatValues == null
                    ? Collections.<String, Object>emptyMap()
                    : flatValues;
            return renderFinalHtmlDocument(tpl, values);
        } catch (Exception e) {
            throw new RuntimeException("Failed to render FINAL HTML from report design", e);
        }
    }

    private String renderFinalHtmlDocument(ReportDesignTemplate tpl, Map<String, Object> values) {
        StringBuilder sb = new StringBuilder();
        sb.append("<!doctype html><html><head><meta charset='utf-8'/>");
        sb.append("<style>")
                .append("body{font-family:Arial,Helvetica,sans-serif;margin:12px;color:#222;}")
                .append(".reportTitle{font-size:16px;font-weight:bold;margin-bottom:10px;}")
                .append(".sectionTitle{margin:18px 0 8px 0;font-size:14px;font-weight:bold;}")
                .append("table{border-collapse:collapse;width:100%;margin-bottom:22px;}")
                .append("th,td{border:1px solid #ddd;padding:6px;font-size:12px;vertical-align:middle;}")
                .append("th{background:#f6f6f6;text-align:center;}")
                .append("td.label{text-align:left;white-space:nowrap;}")
                .append("td.val{text-align:right;}")
                .append("tr.sectionRow td{background:#f0f0f0;font-weight:bold;font-size:13px;}")
                .append("tr.groupRow td{background:#fafafa;font-weight:bold;}")
                .append("tr.labelRow td{background:#fcfcfc;font-weight:600;}")
                .append("tr.spacerRow td{background:#fff;height:10px;border-left:none;border-right:none;}")
                .append(".indent{display:inline-block;}")
                .append("</style></head><body>");

        if (tpl == null || tpl.groups == null || tpl.groups.isEmpty()) {
            sb.append("<div>No groups defined in template.</div>");
            sb.append("</body></html>");
            return sb.toString();
        }

        if (tpl.name != null && !tpl.name.trim().isEmpty()) {
            sb.append("<div class='reportTitle'>").append(esc(tpl.name)).append("</div>");
        }

        for (Group g : tpl.groups) {
            sb.append(renderGroupTable(tpl, g, values));
        }

        sb.append("</body></html>");
        return sb.toString();
    }

    private String renderGroupTable(ReportDesignTemplate tpl, Group group, Map<String, Object> values) {
        if (group == null) {
            return "";
        }

        List<Row> rows = group.rows == null ? Collections.<Row>emptyList() : group.rows;

        Row firstIndicator = findFirstIndicator(rows);
        List<ResolvedDim> headerDims = firstIndicator == null
                ? Collections.<ResolvedDim>emptyList()
                : resolveDimsForRow(tpl, firstIndicator);

        List<DimCombo> headerCombos = buildCombos(headerDims);
        int defaultValue = tpl.defaultValue == null ? 0 : tpl.defaultValue;
        int totalColumnCount = 1 + (headerDims.isEmpty() ? 1 : headerCombos.size() + (hasAnyTotal(rows) ? 1 : 0));

        StringBuilder sb = new StringBuilder();
        sb.append("<div class='sectionTitle'>").append(esc(group.title)).append("</div>");
        sb.append("<table>");
        sb.append("<thead>");

        if (headerDims.isEmpty()) {
            sb.append("<tr>");
            sb.append("<th>Indicator</th>");
            sb.append("<th>Value</th>");
            sb.append("</tr>");
        } else {
            sb.append("<tr>");
            sb.append("<th rowspan='").append(headerDims.size()).append("'>Indicator</th>");
            appendHeaderCellsRecursive(sb, headerDims, 0);
            if (hasAnyTotal(rows)) {
                sb.append("<th rowspan='").append(headerDims.size()).append("'>Total</th>");
            }
            sb.append("</tr>");

            for (int row = 1; row < headerDims.size(); row++) {
                sb.append("<tr>");
                appendHeaderCellsRecursive(sb, headerDims, row);
                sb.append("</tr>");
            }
        }

        sb.append("</thead>");
        sb.append("<tbody>");

        for (Row row : rows) {
            if (row == null) {
                continue;
            }

            String type = safe(row.type);

            if ("section-label".equals(type)) {
                sb.append("<tr class='sectionRow'>");
                sb.append("<td colspan='").append(totalColumnCount).append("'>")
                        .append(indentSpan(row.indent))
                        .append(esc(displayLabel(row)))
                        .append("</td>");
                sb.append("</tr>");
                continue;
            }

            if ("group-label".equals(type)) {
                sb.append("<tr class='groupRow'>");
                sb.append("<td colspan='").append(totalColumnCount).append("'>")
                        .append(indentSpan(row.indent))
                        .append(esc(displayLabel(row)))
                        .append("</td>");
                sb.append("</tr>");
                continue;
            }

            if ("label".equals(type)) {
                sb.append("<tr class='labelRow'>");
                sb.append("<td colspan='").append(totalColumnCount).append("'>")
                        .append(indentSpan(row.indent))
                        .append(esc(displayLabel(row)))
                        .append("</td>");
                sb.append("</tr>");
                continue;
            }

            if ("spacer".equals(type)) {
                sb.append("<tr class='spacerRow'>");
                sb.append("<td colspan='").append(totalColumnCount).append("'></td>");
                sb.append("</tr>");
                continue;
            }

            if (!"indicator".equals(type)) {
                continue;
            }

            List<ResolvedDim> rowDims = resolveDimsForRow(tpl, row);
            List<DimCombo> rowCombos = buildCombos(rowDims);

            sb.append("<tr>");
            sb.append("<td class='label'>")
                    .append(indentSpan(row.indent))
                    .append(esc(displayLabel(row)))
                    .append("</td>");

            if (rowCombos.isEmpty() || !Boolean.TRUE.equals(row.showDisaggregation)) {
                Integer v = resolveSingleValue(values, row, defaultValue);
                sb.append("<td class='val'>").append(v).append("</td>");

                if (hasAnyTotal(rows)) {
                    if (Boolean.TRUE.equals(row.showTotal)) {
                        Integer total = resolveTotalValue(values, row, defaultValue);
                        sb.append("<td class='val'>").append(total).append("</td>");
                    } else {
                        sb.append("<td class='val'></td>");
                    }
                }
            } else {
                for (DimCombo combo : rowCombos) {
                    String key = buildKeyFlexible(
                            safe(row.keyPattern, "{code}_{age}_{sex}"),
                            safe(row.code),
                            combo.placeholders
                    );
                    Integer v = coerceToInt(values.get(key));
                    if (v == null) {
                        v = defaultValue;
                    }
                    sb.append("<td class='val'>").append(v).append("</td>");
                }

                if (hasAnyTotal(rows)) {
                    if (Boolean.TRUE.equals(row.showTotal)) {
                        Integer total = resolveTotalValue(values, row, defaultValue);
                        sb.append("<td class='val'>").append(total).append("</td>");
                    } else {
                        sb.append("<td class='val'></td>");
                    }
                }
            }

            sb.append("</tr>");
        }

        sb.append("</tbody>");
        sb.append("</table>");
        return sb.toString();
    }

    private Row findFirstIndicator(List<Row> rows) {
        if (rows == null) {
            return null;
        }
        for (Row row : rows) {
            if (row != null && "indicator".equals(safe(row.type))) {
                return row;
            }
        }
        return null;
    }

    private boolean hasAnyTotal(List<Row> rows) {
        if (rows == null) {
            return false;
        }
        for (Row row : rows) {
            if (row != null && "indicator".equals(safe(row.type)) && Boolean.TRUE.equals(row.showTotal)) {
                return true;
            }
        }
        return false;
    }

    private Integer resolveSingleValue(Map<String, Object> values, Row row, int defaultValue) {
        String code = safe(row.code);
        Integer v = coerceToInt(values.get(code));
        if (v != null) {
            return v;
        }

        String totalKey = buildTotalKey(row);
        v = coerceToInt(values.get(totalKey));
        return v == null ? defaultValue : v;
    }

    private Integer resolveTotalValue(Map<String, Object> values, Row row, int defaultValue) {
        String totalKey = buildTotalKey(row);
        Integer v = coerceToInt(values.get(totalKey));
        return v == null ? defaultValue : v;
    }

    private String buildTotalKey(Row row) {
        String code = safe(row.code);
        String keyPattern = safe(row.keyPattern);

        if (keyPattern.contains("{code}") && !keyPattern.contains("{age}") && !keyPattern.contains("{sex}")) {
            return keyPattern.replace("{code}", code);
        }

        if (keyPattern.contains("{code}") && (keyPattern.contains("{age}") || keyPattern.contains("{sex}"))) {
            return code + "_TOTAL";
        }

        return code + "_TOTAL";
    }

    private void appendHeaderCellsRecursive(StringBuilder sb, List<ResolvedDim> dims, int headerRow) {
        int repeat = 1;
        for (int i = 0; i < headerRow; i++) {
            repeat *= dims.get(i).items.size();
        }

        int colspan = 1;
        for (int i = headerRow + 1; i < dims.size(); i++) {
            colspan *= dims.get(i).items.size();
        }

        for (int r = 0; r < repeat; r++) {
            for (DimItem item : dims.get(headerRow).items) {
                sb.append("<th");
                if (colspan > 1) {
                    sb.append(" colspan='").append(colspan).append("'");
                }
                sb.append(">").append(esc(item.label)).append("</th>");
            }
        }
    }

    private String indentSpan(Integer depth) {
        int d = depth == null ? 0 : depth.intValue();
        if (d <= 0) {
            return "";
        }
        return "<span class='indent' style='width:" + (d * 14) + "px'></span>";
    }

    private String displayLabel(Row row) {
        String code = safe(row.code);
        String label = safe(row.label);

        if (code.length() > 0 && label.length() > 0 && !label.startsWith(code)) {
            return code + " " + label;
        }
        return label.length() > 0 ? label : code;
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    /* -------------------- PAYLOAD JSON -------------------- */

    public String buildPayloadOnly(String templateJson,
                                   Map<String, Object> flatValues,
                                   String remapJsonOptional) {
        try {
            ReportDesignTemplate tpl = MAPPER.readValue(templateJson, ReportDesignTemplate.class);

            RemapConfig remap = null;
            if (remapJsonOptional != null && !remapJsonOptional.trim().isEmpty()) {
                remap = MAPPER.readValue(remapJsonOptional, RemapConfig.class);
            }

            ObjectNode payloadNode = buildPayloadNode(
                    tpl,
                    flatValues == null ? Collections.<String, Object>emptyMap() : flatValues,
                    remap
            );

            return MAPPER.writeValueAsString(payloadNode);

        } catch (Exception e) {
            throw new RuntimeException("Failed to build payload JSON from report design", e);
        }
    }

    public String buildRenderedOutputOnly(String templateJson,
                                          Map<String, Object> flatValues,
                                          String remapJsonOptional) {
        try {
            ReportDesignTemplate tpl = MAPPER.readValue(templateJson, ReportDesignTemplate.class);
            Map<String, Object> values = flatValues == null
                    ? Collections.<String, Object>emptyMap()
                    : flatValues;

            RemapConfig remap = null;
            if (remapJsonOptional != null && !remapJsonOptional.trim().isEmpty()) {
                remap = MAPPER.readValue(remapJsonOptional, RemapConfig.class);
            }

            ObjectNode payloadNode = buildPayloadNode(tpl, values, remap);
            String html = renderFinalHtmlDocument(tpl, values);

            ObjectNode root = MAPPER.createObjectNode();
            root.set("json", payloadNode.path("json").isObject()
                    ? (ObjectNode) payloadNode.path("json")
                    : MAPPER.createObjectNode());
            root.put("html", html);
            root.set("dhis2", buildDhis2Node(tpl));

            return MAPPER.writeValueAsString(root);
        } catch (Exception e) {
            throw new RuntimeException("Failed to build rendered output from report design", e);
        }
    }

    private ObjectNode buildPayloadNode(ReportDesignTemplate tpl, Map<String, Object> values, RemapConfig remap) {
        ObjectNode root = MAPPER.createObjectNode();
        ObjectNode json = MAPPER.createObjectNode();
        root.set("json", json);

        ArrayNode dataValues = MAPPER.createArrayNode();

        if (tpl == null || tpl.groups == null) {
            json.set(safe(tpl == null ? null : tpl.arrayName, "dataValues"), dataValues);
            return root;
        }

        int defaultValue = tpl.defaultValue == null ? 0 : tpl.defaultValue;

        for (Group group : tpl.groups) {
            if (group == null || group.rows == null) {
                continue;
            }

            for (Row row : group.rows) {
                if (row == null || !"indicator".equals(safe(row.type))) {
                    continue;
                }

                List<ResolvedDim> dims = resolveDimsForRow(tpl, row);
                List<DimCombo> combos = buildCombos(dims);

                if (!Boolean.TRUE.equals(row.showDisaggregation) || combos.isEmpty()) {
                    String key = buildTotalKey(row);
                    Integer v = coerceToInt(values.get(key));
                    if (v == null) {
                        v = coerceToInt(values.get(row.code));
                    }
                    if (v == null) {
                        v = defaultValue;
                    }

                    ObjectNode dv = MAPPER.createObjectNode();
                    dv.put("value", v);

                    Map<String, String> mapped = remap == null
                            ? Collections.<String, String>emptyMap()
                            : remap.apply(key);

                    dv.put("dataElement", mapped.containsKey("dataElement") ? mapped.get("dataElement") : key);

                    if (mapped.containsKey("categoryOptionCombo")) {
                        dv.put("categoryOptionCombo", mapped.get("categoryOptionCombo"));
                    }
                    if (mapped.containsKey("attributeOptionCombo")) {
                        dv.put("attributeOptionCombo", mapped.get("attributeOptionCombo"));
                    }

                    dataValues.add(dv);
                    continue;
                }

                for (DimCombo combo : combos) {
                    String computedKey = buildKeyFlexible(
                            safe(row.keyPattern, "{code}_{age}_{sex}"),
                            safe(row.code),
                            combo.placeholders
                    );

                    Integer v = coerceToInt(values.get(computedKey));
                    if (v == null) {
                        v = defaultValue;
                    }

                    ObjectNode dv = MAPPER.createObjectNode();
                    dv.put("value", v);

                    Map<String, String> mapped = remap == null
                            ? Collections.<String, String>emptyMap()
                            : remap.apply(computedKey);

                    dv.put("dataElement", mapped.containsKey("dataElement") ? mapped.get("dataElement") : computedKey);

                    if (mapped.containsKey("categoryOptionCombo")) {
                        dv.put("categoryOptionCombo", mapped.get("categoryOptionCombo"));
                    }
                    if (mapped.containsKey("attributeOptionCombo")) {
                        dv.put("attributeOptionCombo", mapped.get("attributeOptionCombo"));
                    }

                    dataValues.add(dv);
                }

                if (Boolean.TRUE.equals(row.showTotal)) {
                    String totalKey = buildTotalKey(row);
                    Integer total = coerceToInt(values.get(totalKey));
                    if (total == null) {
                        total = defaultValue;
                    }

                    ObjectNode dv = MAPPER.createObjectNode();
                    dv.put("value", total);

                    Map<String, String> mapped = remap == null
                            ? Collections.<String, String>emptyMap()
                            : remap.apply(totalKey);

                    dv.put("dataElement", mapped.containsKey("dataElement") ? mapped.get("dataElement") : totalKey);

                    if (mapped.containsKey("categoryOptionCombo")) {
                        dv.put("categoryOptionCombo", mapped.get("categoryOptionCombo"));
                    }
                    if (mapped.containsKey("attributeOptionCombo")) {
                        dv.put("attributeOptionCombo", mapped.get("attributeOptionCombo"));
                    }

                    dataValues.add(dv);
                }
            }
        }

        json.set(safe(tpl.arrayName, "dataValues"), dataValues);
        return root;
    }

    private ObjectNode buildDhis2Node(ReportDesignTemplate tpl) {
        ObjectNode dhis2Node = MAPPER.createObjectNode();

        if (tpl == null || tpl.dhis2 == null) {
            dhis2Node.put("enabled", false);
            dhis2Node.set("rows", MAPPER.createArrayNode());
            return dhis2Node;
        }

        dhis2Node.put("enabled", Boolean.TRUE.equals(tpl.dhis2.enabled));
        dhis2Node.set("rows", tpl.dhis2.rows == null
                ? MAPPER.createArrayNode()
                : MAPPER.valueToTree(tpl.dhis2.rows));

        return dhis2Node;
    }

    /* -------------------- DIMENSIONS -------------------- */

    private static class ResolvedDim {
        final String kind;
        final String dimName;
        final List<DimItem> items;

        ResolvedDim(String kind, String dimName, List<DimItem> items) {
            this.kind = kind;
            this.dimName = dimName;
            this.items = items;
        }
    }

    private List<ResolvedDim> resolveDimsForRow(ReportDesignTemplate tpl, Row row) {
        if (row == null || row.dims == null || row.dims.isEmpty()) {
            return Collections.emptyList();
        }

        LinkedHashMap<String, String> resolved = new LinkedHashMap<String, String>();
        for (Map.Entry<String, String> e : row.dims.entrySet()) {
            String kind = e.getKey();
            String dimName = valueOrDefault(e.getValue(), kind);
            if (kind == null || kind.trim().isEmpty()) {
                continue;
            }

            List<DimItem> items = safeDim(tpl, dimName);
            if (items != null && !items.isEmpty()) {
                resolved.put(kind, dimName);
            }
        }

        List<ResolvedDim> out = new ArrayList<ResolvedDim>();
        for (Map.Entry<String, String> e : resolved.entrySet()) {
            out.add(new ResolvedDim(e.getKey(), e.getValue(), safeDim(tpl, e.getValue())));
        }
        return out;
    }

    private String valueOrDefault(String v, String def) {
        if (v == null) return def;
        String t = v.trim();
        return t.length() == 0 ? def : t;
    }

    private List<DimItem> safeDim(ReportDesignTemplate tpl, String name) {
        if (tpl == null || tpl.dimensions == null || name == null) {
            return Collections.emptyList();
        }
        List<DimItem> d = tpl.dimensions.get(name);
        return d == null ? Collections.<DimItem>emptyList() : d;
    }

    private static class DimCombo {
        final Map<String, String> placeholders;

        DimCombo(Map<String, String> placeholders) {
            this.placeholders = placeholders;
        }
    }

    private List<DimCombo> buildCombos(List<ResolvedDim> dims) {
        if (dims == null || dims.isEmpty()) {
            return Collections.emptyList();
        }

        List<DimCombo> out = new ArrayList<DimCombo>();
        buildCombosRec(dims, 0, new LinkedHashMap<String, String>(), out);
        return out;
    }

    private void buildCombosRec(List<ResolvedDim> dims, int idx, Map<String, String> acc, List<DimCombo> out) {
        if (idx >= dims.size()) {
            out.add(new DimCombo(new LinkedHashMap<String, String>(acc)));
            return;
        }

        ResolvedDim d = dims.get(idx);
        for (DimItem it : d.items) {
            acc.put(d.kind, it == null ? "" : safe(it.id));
            buildCombosRec(dims, idx + 1, acc, out);
        }
        acc.remove(d.kind);
    }

    private String buildKeyFlexible(String pattern, String code, Map<String, String> placeholders) {
        String key = safe(pattern, "{code}");
        key = key.replace("{code}", safe(code));

        if (placeholders != null) {
            for (Map.Entry<String, String> e : placeholders.entrySet()) {
                String kind = e.getKey();
                String val = e.getValue();
                if (kind == null) {
                    continue;
                }
                key = key.replace("{" + kind + "}", val == null ? "" : val);
            }
        }

        return key;
    }

    private Integer coerceToInt(Object raw) {
        if (raw == null) return null;
        if (raw instanceof Number) return ((Number) raw).intValue();

        String s = String.valueOf(raw).trim();
        if (s.isEmpty()) return null;

        try {
            return (int) Math.round(Double.parseDouble(s));
        } catch (Exception ignore) {
            return null;
        }
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private String safe(String value, String defaultValue) {
        String s = safe(value);
        return s.length() == 0 ? defaultValue : s;
    }

    /* -------------------- POJOs -------------------- */

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ReportDesignTemplate {
        public Integer version;
        public String name;
        public String code;
        public String template;
        public String arrayName = "dataValues";
        public Integer defaultValue = 0;
        public List<Group> groups = new ArrayList<Group>();
        public Map<String, List<DimItem>> dimensions = new LinkedHashMap<String, List<DimItem>>();
        public Dhis2 dhis2;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Group {
        public String title;
        public List<Row> rows = new ArrayList<Row>();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Row {
        public String type;
        public String label;
        public Integer indent;
        public String code;
        public String indicatorUuid;
        public String span;
        public String emphasis;
        public Boolean showTotal;
        public Boolean showDisaggregation;
        public String keyPattern;
        public Map<String, String> dims = new LinkedHashMap<String, String>();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class DimItem {
        public String id;
        public String label;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Dhis2 {
        public Boolean enabled;
        public List<Object> rows = new ArrayList<Object>();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class RemapConfig {
        public int version;
        public List<Rule> rules = new ArrayList<Rule>();
        public Map<String, String> defaults = new HashMap<String, String>();

        public Map<String, String> apply(String computedKey) {
            Map<String, String> out = new HashMap<String, String>(defaults);
            for (Rule r : rules) {
                if (r == null || r.match == null) continue;

                boolean ok = false;
                if (r.match.key != null && r.match.key.equals(computedKey)) {
                    ok = true;
                } else if (r.match.prefix != null && computedKey.startsWith(r.match.prefix)) {
                    ok = true;
                }

                if (ok && r.set != null) {
                    out.putAll(r.set);
                }
            }
            return out;
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Rule {
        public Match match;
        public Map<String, String> set;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Match {
        public String key;
        public String prefix;
    }
}