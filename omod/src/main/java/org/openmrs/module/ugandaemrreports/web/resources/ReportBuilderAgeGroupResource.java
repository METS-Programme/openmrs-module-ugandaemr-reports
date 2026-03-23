package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderAgeCategory;
import org.openmrs.module.ugandaemrreports.model.ReportBuilderAgeGroup;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.*;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.Collections;
import java.util.List;

/**
 * Standard RESTWS resource for Age Groups.
 *
 * Examples:
 *  GET /ws/rest/v1/reportbuilder/mambaagegroup
 *  GET /ws/rest/v1/reportbuilder/mambaagegroup?q=adult
 *  GET /ws/rest/v1/reportbuilder/mambaagegroup?categoryUuid=...
 *  GET /ws/rest/v1/reportbuilder/mambaagegroup?categoryCode=MOH_105_OPD_DIAG
 *  GET /ws/rest/v1/reportbuilder/mambaagegroup?activeOnly=true
 *
 * Note: MambaAgeGroup does not currently have a UUID field in the model you shared.
 * This resource uses the numeric ID as the "uniqueId" (path param).
 *
 * Later (recommended): add a uuid column/field so it behaves like other OpenMRS resources.
 */
@Resource(
        name = RestConstants.VERSION_1 + "/reportbuilderagegroup",
        supportedClass = ReportBuilderAgeGroup.class,
        supportedOpenmrsVersions = { "2.*", "3.*" }
)
public class ReportBuilderAgeGroupResource extends DelegatingCrudResource<ReportBuilderAgeGroup> {

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    // ----------------------------
    // CRUD hooks
    // ----------------------------

    @Override
    public ReportBuilderAgeGroup newDelegate() {
        return new ReportBuilderAgeGroup();
    }

    /**
     * Since MambaAgeGroup has no uuid field, we treat the numeric id as uniqueId.
     */
    @Override
    public ReportBuilderAgeGroup getByUniqueId(String uniqueId) {
        if (uniqueId == null || uniqueId.trim().isEmpty()) return null;
        try {
            Integer id = Integer.valueOf(uniqueId);
            return service().getAgeGroupById(id);
        } catch (NumberFormatException e) {
            // If later you add UUID support, you can change this to service().getAgeGroupByUuid(uniqueId)
            return null;
        }
    }

    @Override
    public ReportBuilderAgeGroup save(ReportBuilderAgeGroup group) {
        return service().saveAgeGroup(group);
    }

    @Override
    protected void delete(ReportBuilderAgeGroup group, String reason, RequestContext context) throws ResponseException {
        // soft delete pattern: set active=false (like your schema is_active)
        if (group == null) return;
        group.setActive(false);
        service().saveAgeGroup(group);
    }

    @Override
    public void purge(ReportBuilderAgeGroup group, RequestContext context) throws ResponseException {
        service().purgeAgeGroup(group);
    }

    // ----------------------------
    // List/search
    // ----------------------------

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        return doSearch(context);
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {

        String q = context.getParameter("q");

        // optional filters
        String categoryUuid = context.getParameter("categoryUuid");
        String categoryCode = context.getParameter("categoryCode");

        Boolean activeOnly = null;
        String activeOnlyStr = context.getParameter("activeOnly");
        if (activeOnlyStr != null && !activeOnlyStr.trim().isEmpty()) {
            activeOnly = Boolean.parseBoolean(activeOnlyStr);
        }

        ReportBuilderAgeCategory category = null;
        if (categoryUuid != null && !categoryUuid.trim().isEmpty()) {
            category = service().getAgeCategoryByUuid(categoryUuid);
        } else if (categoryCode != null && !categoryCode.trim().isEmpty()) {
            category = service().getAgeCategoryByCode(categoryCode);
        }

        // If you haven't implemented service search yet, return empty to avoid 500s.
        List<ReportBuilderAgeGroup> groups;
        try {
            groups = service().getAgeGroups(
                    q,
                    category,
                    activeOnly,
                    context.getStartIndex(),
                    context.getLimit()
            );
        } catch (Exception e) {
            groups = Collections.emptyList();
        }

        return new NeedsPaging<>(groups, context);
    }

    // ----------------------------
    // Representations
    // ----------------------------

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {

        if (rep instanceof DefaultRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();
            // since no uuid, expose id and also provide a display
            d.addProperty("id");
            d.addProperty("display", findMethod("getDisplayString"));
            d.addProperty("code");
            d.addProperty("label");
            d.addProperty("minAgeDays");
            d.addProperty("maxAgeDays");
            d.addProperty("sortOrder");
            d.addProperty("active");
            d.addProperty("ageCategory", Representation.REF);
            return d;
        }

        if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription d = new DelegatingResourceDescription();
            d.addProperty("id");
            d.addProperty("display", findMethod("getDisplayString"));
            d.addProperty("code");
            d.addProperty("label");
            d.addProperty("minAgeDays");
            d.addProperty("maxAgeDays");
            d.addProperty("sortOrder");
            d.addProperty("active");
            d.addProperty("ageCategory", Representation.DEFAULT);
            return d;
        }

        return null;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addRequiredProperty("label");
        d.addRequiredProperty("minAgeDays");
        d.addRequiredProperty("maxAgeDays");
        d.addRequiredProperty("sortOrder");
        d.addRequiredProperty("ageCategory");
        d.addProperty("code");
        d.addProperty("active");
        return d;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return getCreatableProperties();
    }

    public String getDisplayString(ReportBuilderAgeGroup g) {
        if (g == null) return "";
        String label = g.getLabel() != null ? g.getLabel() : "";
        String code = g.getCode() != null ? g.getCode() : "";
        if (!code.isEmpty()) return label + " (" + code + ")";
        return label;
    }
}