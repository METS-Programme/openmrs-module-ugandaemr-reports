package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.model.ReportCategory;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.DefaultRepresentation;
import org.openmrs.module.webservices.rest.web.representation.FullRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.AlreadyPaged;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;

import java.util.List;

@Resource(
        name = RestConstants.VERSION_1 + "/reportcategory",
        supportedClass = ReportCategory.class,
        supportedOpenmrsVersions = {"1.8 - 9.0.*"}
)
public class ReportCategoryResource extends DelegatingCrudResource<ReportCategory> {

    @Override
    public ReportCategory newDelegate() {
        return new ReportCategory();
    }

    @Override
    public ReportCategory save(ReportCategory delegate) {
        return Context.getService(UgandaEMRReportsService.class).saveReportCategory(delegate);
    }

    @Override
    public ReportCategory getByUniqueId(String uniqueId) {
        UgandaEMRReportsService service = Context.getService(UgandaEMRReportsService.class);

        ReportCategory byUuid = service.getReportCategoryByUuid(uniqueId);
        if (byUuid != null) {
            return byUuid;
        }

        try {
            return service.getReportCategoryById(Integer.valueOf(uniqueId));
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public void delete(ReportCategory delegate, String reason, RequestContext context) {
        Context.getService(UgandaEMRReportsService.class).retireReportCategory(delegate, reason);
    }

    @Override
    public void purge(ReportCategory delegate, RequestContext context) {
        Context.getService(UgandaEMRReportsService.class).purgeReportCategory(delegate);
    }

    public ReportCategory getById(String id) {
        try {
            return Context.getService(UgandaEMRReportsService.class)
                    .getReportCategoryById(Integer.valueOf(id));
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        UgandaEMRReportsService service = Context.getService(UgandaEMRReportsService.class);

        String q = context.getParameter("q");
        boolean includeAll = context.getIncludeAll();
        Integer startIndex = context.getStartIndex() != null ? context.getStartIndex() : 0;
        Integer limit = context.getLimit() != null ? context.getLimit() : 50;

        List<ReportCategory> results = service.getReportCategories(q, includeAll, startIndex, limit);
        long count = service.getReportCategoriesCount(q, includeAll);

        return new AlreadyPaged<ReportCategory>(context, results, false, count);
    }

    @Override
    public NeedsPaging<ReportCategory> doGetAll(RequestContext context) {
        UgandaEMRReportsService service = Context.getService(UgandaEMRReportsService.class);

        boolean includeAll = context.getIncludeAll();
        Integer startIndex = context.getStartIndex() != null ? context.getStartIndex() : 0;
        Integer limit = context.getLimit() != null ? context.getLimit() : 50;

        List<ReportCategory> results = service.getReportCategories(null, includeAll, startIndex, limit);
        return new NeedsPaging<ReportCategory>(results, context);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {
        DelegatingResourceDescription d = new DelegatingResourceDescription();

        if (rep instanceof DefaultRepresentation) {
            d.addProperty("uuid");
            d.addProperty("name");
            d.addProperty("description");
            d.addProperty("retired");
            d.addSelfLink();
            d.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return d;
        }

        if (rep instanceof FullRepresentation) {
            d.addProperty("uuid");
            d.addProperty("name");
            d.addProperty("description");
            d.addProperty("retired");
            d.addProperty("auditInfo");
            d.addSelfLink();
            return d;
        }

        return null;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addRequiredProperty("name");
        d.addProperty("description");
        return d;
    }
}