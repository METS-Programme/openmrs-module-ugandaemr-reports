package org.openmrs.module.ugandaemrreports.web.resources;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderSection;
import org.openmrs.module.ugandaemrreports.web.controller.dto.SectionPreviewRequest;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.annotation.SubResource;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingSubResource;
import org.openmrs.module.webservices.rest.web.response.ObjectNotFoundException;
import org.openmrs.module.webservices.rest.web.response.ResourceDoesNotSupportOperationException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.Collections;
import java.util.Map;

/**
 * POST /ws/rest/v1/reportbuildersection/{uuid}/preview
 * Body: { indicatorUuid, params, maxRows }
 */
@SubResource(
        parent = ReportBuilderSectionResource.class,
        path = "preview",
        supportedClass = SectionPreviewRequest.class,
        supportedOpenmrsVersions = {"2.*"}
)
public class ReportBuilderSectionPreviewSubResource
        extends DelegatingSubResource<SectionPreviewRequest, ReportBuilderSection, ReportBuilderSectionResource> {

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    /**
     * NOTE: This method is used by the framework when it needs to build a URI
     * from a "delegate instance". For an action endpoint like /preview, we don't
     * really have persisted delegates, so return null safely.
     */
    @Override
    public ReportBuilderSection getParent(SectionPreviewRequest delegate) {
        return null;
    }

    /**
     * For action resources, we don't persist a child object. But the framework may
     * call setParent during create(...) in base class if it uses that flow.
     * We do nothing safely.
     */
    @Override
    public void setParent(SectionPreviewRequest delegate, ReportBuilderSection parent) {
        // no-op
    }

    /**
     * We don't support listing preview "items"
     */
    @Override
    public PageableResult doGetAll(ReportBuilderSection parent, RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException();
    }

    @Override
    public SectionPreviewRequest newDelegate() {
        return new SectionPreviewRequest();
    }

    /**
     * Not supported — this subresource is action-like (POST only).
     */
    @Override
    public SectionPreviewRequest getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException();
    }

    /**
     * Not persisted.
     */
    @Override
    public SectionPreviewRequest save(SectionPreviewRequest delegate) {
        return delegate;
    }

    @Override
    protected void delete(SectionPreviewRequest delegate, String reason, RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException();
    }

    @Override
    public void purge(SectionPreviewRequest delegate, RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException();
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(
            org.openmrs.module.webservices.rest.web.representation.Representation rep
    ) {
        // This resource returns SimpleObject from create(). No representations needed.
        return null;
    }

    /**
     * ✅ The actual endpoint handler
     *
     * This matches the DelegatingSubResource signature you decompiled:
     * create(String parentUniqueId, SimpleObject post, RequestContext context)
     */
    @Override
    public Object create(String parentUniqueId, SimpleObject post, RequestContext context) throws ResponseException {
        Context.requirePrivilege("View Reports");

        String startDate = post.get("startDate") != null ? post.get("startDate").toString().trim() : null;
        String endDate = post.get("endDate") != null ? post.get("endDate").toString().trim() : null;

        if (startDate == null || startDate.isEmpty()) {
            throw new IllegalArgumentException("startDate is required (YYYY-MM-DD)");
        }
        if (endDate == null || endDate.isEmpty()) {
            throw new IllegalArgumentException("endDate is required (YYYY-MM-DD)");
        }

        // Params map (mutable)
        @SuppressWarnings("unchecked")
        Map<String, Object> params =
                post.get("params") instanceof Map ? new java.util.HashMap<>((Map<String, Object>) post.get("params")) : new java.util.HashMap<>();

        // Ensure dates are always present for SQL placeholders
        params.put("startDate", startDate);
        params.put("endDate", endDate);

        String indicatorUuid = post.get("indicatorUuid") != null ? post.get("indicatorUuid").toString().trim() : null;

        Integer maxRows = null;
        if (post.get("maxRows") != null) {
            try {
                maxRows = Integer.valueOf(post.get("maxRows").toString());
            } catch (Exception ignored) {
            }
        }

        ReportBuilderSection section = service().getReportBuilderSectionByUuid(parentUniqueId);
        if (section == null) {
            throw new ObjectNotFoundException();
        }

        String configJson = section.getConfigJson();
        if (configJson == null || configJson.trim().isEmpty()) {
            SimpleObject out = new SimpleObject();
            out.add("sectionUuid", parentUniqueId);
            out.add("results", Collections.emptyList());
            return out;
        }

        // Optional: single-indicator preview if indicatorUuid provided
        if (indicatorUuid != null && !indicatorUuid.isEmpty()) {
            String compiledSql;
            try {
                compiledSql = extractCompiledSql(configJson, indicatorUuid);
            } catch (Exception e) {
                throw new IllegalArgumentException("Failed to parse section configJson: " + e.getMessage());
            }

            if (compiledSql == null || compiledSql.trim().isEmpty()) {
                throw new IllegalArgumentException("Compiled SQL not found for indicator " + indicatorUuid);
            }

            SqlPreviewResult r = service().previewSql(decodeHtmlEntities(compiledSql), params, maxRows);

            SimpleObject single = new SimpleObject();
            single.add("indicatorUuid", indicatorUuid);
            single.add("columns", r.getColumns());
            single.add("rows", r.getRows());
            single.add("rowCount", r.getRowCount());
            single.add("truncated", r.isTruncated());
            single.add("error", null);

            SimpleObject out = new SimpleObject();
            out.add("sectionUuid", parentUniqueId);
            out.add("results", Collections.singletonList(single));
            return out;
        }

        // Preview ALL indicators in the section
        JsonNode root;
        JsonNode indicators;
        try {
            ObjectMapper mapper = new ObjectMapper();
            root = mapper.readTree(configJson);
            indicators = root.path("indicators");
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to parse section configJson: " + e.getMessage());
        }

        if (!indicators.isArray()) {
            SimpleObject out = new SimpleObject();
            out.add("sectionUuid", parentUniqueId);
            out.add("results", Collections.emptyList());
            return out;
        }

        java.util.List<SimpleObject> results = new java.util.ArrayList<>();

        for (JsonNode item : indicators) {
            String id = item.path("indicatorUuid").asText(null);
            String kind = item.path("kind").asText(null);
            String name = item.path("name").asText(null);
            String code = item.path("code").asText(null);
            String compiled = item.path("sql").path("compiled").asText(null);

            SimpleObject one = new SimpleObject();
            one.add("indicatorUuid", id);
            one.add("kind", kind);
            one.add("name", name);
            one.add("code", code);

            if (compiled == null || compiled.trim().isEmpty()) {
                one.add("columns", Collections.emptyList());
                one.add("rows", Collections.emptyList());
                one.add("rowCount", 0);
                one.add("truncated", false);
                one.add("error", "Missing compiled SQL in section configJson");
                results.add(one);
                continue;
            }

            try {
                SqlPreviewResult r = service().previewSql(decodeHtmlEntities(compiled), params, maxRows);
                one.add("columns", r.getColumns());
                one.add("rows", r.getRows());
                one.add("rowCount", r.getRowCount());
                one.add("truncated", r.isTruncated());
                one.add("error", null);
            } catch (Exception ex) {
                one.add("columns", Collections.emptyList());
                one.add("rows", Collections.emptyList());
                one.add("rowCount", 0);
                one.add("truncated", false);
                one.add("error", ex.getMessage());
            }

            results.add(one);
        }

        SimpleObject out = new SimpleObject();
        out.add("sectionUuid", parentUniqueId);
        out.add("results", results);
        return out;
    }

    private static String extractCompiledSql(String configJson, String indicatorUuid) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(configJson);
        JsonNode indicators = root.path("indicators");
        if (!indicators.isArray()) return null;

        for (JsonNode item : indicators) {
            String id = item.path("indicatorUuid").asText(null);
            if (indicatorUuid.equals(id)) {
                return item.path("sql").path("compiled").asText(null);
            }
        }
        return null;
    }

    private static String decodeHtmlEntities(String s) {
        if (s == null) return null;

        String out = s
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&#39;", "'");

        out = out.replace("&gt;=", ">=").replace("&lt;=", "<=");
        out = out.replace("&gte;", ">=").replace("&ge;", ">=");
        out = out.replace("&lte;", "<=").replace("&le;", "<=");

        return out;
    }
}