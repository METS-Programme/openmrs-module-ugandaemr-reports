package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderIndicator;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.representation.*;
import org.openmrs.module.webservices.rest.web.response.ResponseException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.List;

@Resource(
        name = RestConstants.VERSION_1 + "/reportbuilderindicator",
        supportedClass = ReportBuilderIndicator.class,
        supportedOpenmrsVersions = {"1.8 - 9.0.*"}
)
public class ReportBuilderIndicatorResource extends DelegatingCrudResource<ReportBuilderIndicator> {

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    @Override
    public ReportBuilderIndicator getByUniqueId(String uuid) {
        return service().getReportBuilderIndicatorByUuid(uuid);
    }

    @Override
    public ReportBuilderIndicator newDelegate() {
        return new ReportBuilderIndicator();
    }

    @Override
    public ReportBuilderIndicator save(ReportBuilderIndicator indicator) {
        // validation should happen in service (as you already do)
        return service().saveReportBuilderIndicator(indicator);
    }

    @Override
    public void purge(ReportBuilderIndicator indicator, RequestContext context) {
        service().purgeReportBuilderIndicator(indicator);
    }

    @Override
    protected void delete(ReportBuilderIndicator indicator, String reason, RequestContext context) throws ResponseException {
        // DELETE defaults to retire unless purge=true
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Retired via REST";
        }
        service().retireReportBuilderIndicator(indicator, reason);
    }

    // ---------------------------
    // Querying / listing
    // ---------------------------

    @Override
    public PageableResult doGetAll(RequestContext context) {

        Integer startIndex = context.getStartIndex();
        Integer limit = context.getLimit();
        List<ReportBuilderIndicator> results = service().getAllReportBuilderIndicator(startIndex, limit);

        return new NeedsPaging<>(results, context);
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        String q = trimToNull(context.getParameter("q"));
        String kindStr = trimToNull(context.getParameter("kind"));
        String defaultValueTypeStr = trimToNull(context.getParameter("defaultValueType"));

        // prefer retired=false/true (explicit) but keep includeRetired for backwards compat
        Boolean retired = parseBooleanOrNull(context.getParameter("retired"));
        Boolean includeRetired = parseBooleanOrNull(context.getParameter("includeRetired"));

        // final includeRetired decision:
        // - if retired is provided, it wins
        // - else includeRetired defaults false
        boolean includeRetiredFinal;
        if (retired != null) {
            // if user asked retired=true => includeRetired=true and filter retired only in service,
            // but since service signature is includeRetired(boolean) we use:
            includeRetiredFinal = true;
        } else if (includeRetired != null) {
            includeRetiredFinal = includeRetired;
        } else {
            includeRetiredFinal = false;
        }

        ReportBuilderIndicator.Kind kind = parseEnumOrNull(kindStr, ReportBuilderIndicator.Kind.class, "kind");

        ReportBuilderIndicator.ValueType defaultValueType = parseEnumOrNull(defaultValueTypeStr, ReportBuilderIndicator.ValueType.class, "defaultValueType");

        Integer startIndex = context.getStartIndex();
        Integer limit = context.getLimit();

        // If you want "retired=true only" support, your service should allow it.
        // For now, we pass includeRetiredFinal and let service decide.

        List<ReportBuilderIndicator> results = new ArrayList<>();
        if (q != null) {
            results = service().searchReportBuilderIndicators(q, kind, includeRetiredFinal, startIndex, limit);
        } else {
            results = service().getReportBuilderIndicators(kind, includeRetiredFinal, startIndex, limit);
        }

        // Optional: if client requested retired=true/false explicitly, filter here if service doesn't support it.
        if (retired != null) {
            results.removeIf(ind -> ind == null || ind.isRetired() != retired);
        }

        // Optional: if requested defaultValueType, filter here if service doesn't support it
        if (defaultValueType != null) {
            results.removeIf(ind -> ind == null || ind.getDefaultValueType() != defaultValueType);
        }

        return new NeedsPaging<>(results, context);
    }

    private String trimToNull(String v) {
        if (v == null) return null;
        String t = v.trim();
        return t.isEmpty() ? null : t;
    }

    private Boolean parseBooleanOrNull(String v) {
        String t = trimToNull(v);
        if (t == null) return null;
        if ("true".equalsIgnoreCase(t)) return Boolean.TRUE;
        if ("false".equalsIgnoreCase(t)) return Boolean.FALSE;
        throw new IllegalArgumentException("Invalid boolean value: " + v);
    }

    private <E extends Enum<E>> E parseEnumOrNull(String raw, Class<E> enumClass, String paramName) {
        if (raw == null) return null;
        try {
            return Enum.valueOf(enumClass, raw.trim().toUpperCase());
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid value for " + paramName + ": " + raw, e);
        }
    }

    // ---------------------------
    // Representations
    // ---------------------------

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {

        if (rep instanceof DefaultRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();

            // --- Model fields ---
            d.addProperty("id");
            d.addProperty("uuid");
            d.addProperty("name");
            d.addProperty("description");
            d.addProperty("code");
            d.addProperty("kind");
            d.addProperty("defaultValueType");
            d.addProperty("themeUuid");

            // --- Metadata lifecycle (BaseOpenmrsMetadata) ---
            d.addProperty("retired");
            d.addProperty("retireReason");
            d.addProperty("auditInfo", findMethod("getAuditInfo"));

            return d;
        }

        if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();

            // --- Model fields ---
            d.addProperty("id");
            d.addProperty("uuid");

            d.addProperty("name");
            d.addProperty("description");

            d.addProperty("code");
            d.addProperty("kind");
            d.addProperty("defaultValueType");
            d.addProperty("themeUuid");

            d.addProperty("configJson");
            d.addProperty("metaJson");

            // --- Metadata lifecycle (BaseOpenmrsMetadata) ---
            d.addProperty("retired");
            d.addProperty("retireReason");
            d.addProperty("auditInfo", findMethod("getAuditInfo"));

            return d;
        }

        return null;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        DelegatingResourceDescription d = new DelegatingResourceDescription();

        // BaseOpenmrsMetadata
        d.addRequiredProperty("name");
        d.addProperty("description");

        // MambaIndicator
        d.addProperty("code");               // optional business code
        d.addRequiredProperty("kind");       // BASE | COMPOSITE | FINAL
        d.addProperty("defaultValueType");   // defaults to NUMBER if null
        d.addProperty("themeUuid");          // optional link to DataTheme uuid

        // "source of truth"
        d.addRequiredProperty("configJson");

        // executable SQL (optional depending on kind)
        d.addProperty("sqlTemplate");
        d.addProperty("denominatorSqlTemplate");

        // misc metadata
        d.addProperty("metaJson");

        // lifecycle (optional)
        d.addProperty("retired");
        d.addProperty("retireReason");

        // Optional: allow client-supplied uuid for sync/import
        d.addProperty("uuid");

        return d;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return getCreatableProperties();
    }

    // ---------------------------
    // Display
    // ---------------------------

    public String getDisplayPropertyName() {
        return "display";
    }

    public String getDisplayString(ReportBuilderIndicator indicator) {
        if (indicator == null) return "";
        if (indicator.getName() != null && indicator.getCode() != null) {
            return indicator.getName() + " (" + indicator.getCode() + ")";
        }
        return indicator.getName() != null ? indicator.getName() : indicator.getUuid();
    }
}