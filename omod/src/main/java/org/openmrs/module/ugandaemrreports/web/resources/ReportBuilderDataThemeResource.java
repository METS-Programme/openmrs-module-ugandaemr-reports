package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderDataTheme;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.DefaultRepresentation;
import org.openmrs.module.webservices.rest.web.representation.FullRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.List;

@Resource(
        name = RestConstants.VERSION_1 + "/reportbuilderdatatheme",
        supportedClass = ReportBuilderDataTheme.class,
        supportedOpenmrsVersions = {"1.8 - 9.0.*"}
)
public class ReportBuilderDataThemeResource extends DelegatingCrudResource<ReportBuilderDataTheme> {

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    @Override
    public ReportBuilderDataTheme getByUniqueId(String uuid) {
        return service().getReportBuilderDataThemeByUuid(uuid);
    }

    @Override
    public ReportBuilderDataTheme newDelegate() {
        return new ReportBuilderDataTheme();
    }

    @Override
    public ReportBuilderDataTheme save(ReportBuilderDataTheme theme) {
        if (theme.getConfigJson() == null || theme.getConfigJson().trim().isEmpty()) {
            throw new IllegalArgumentException("configJson is required");
        }
        return service().saveReportBuilderDataTheme(theme);
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {

        String q = context.getParameter("q");
        boolean includeRetired = Boolean.parseBoolean(
                context.getParameter("includeRetired") != null ? context.getParameter("includeRetired") : "false"
        );

        List<ReportBuilderDataTheme> results = service().getReportBuilderDataThemes(
                q, includeRetired, context.getStartIndex(), context.getLimit()
        );

        return new NeedsPaging<>(results, context);
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        return doGetAll(context);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {

        if (rep instanceof DefaultRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();
            d.addProperty("uuid");
            d.addProperty("name");
            d.addProperty("description");
            d.addProperty("code");
            d.addProperty("domain");
            d.addProperty("retired");
            return d;
        }

        if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();
            d.addProperty("uuid");
            d.addProperty("name");
            d.addProperty("description");
            d.addProperty("code");
            d.addProperty("domain");
            d.addProperty("configJson");
            d.addProperty("metaJson");
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
        d.addRequiredProperty("name");
        d.addProperty("description");
        d.addProperty("code");
        d.addProperty("domain");
        d.addRequiredProperty("configJson");
        d.addProperty("metaJson");
        return d;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return getCreatableProperties();
    }
    
    public String getDisplayString(ReportBuilderDataTheme theme) {
        if (theme.getName() != null && theme.getCode() != null) {
            return theme.getName() + " (" + theme.getCode() + ")";
        }
        return theme.getName() != null ? theme.getName() : theme.getUuid();
    }

    @Override
    protected void delete(ReportBuilderDataTheme theme, String reason, RequestContext context) throws ResponseException {
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Retired via REST";
        }
        service().retireReportBuilderDataTheme(theme, reason);
    }

    @Override
    public void purge(ReportBuilderDataTheme theme, RequestContext context) throws ResponseException {
        service().purgeReportBuilderDataTheme(theme);
    }
}