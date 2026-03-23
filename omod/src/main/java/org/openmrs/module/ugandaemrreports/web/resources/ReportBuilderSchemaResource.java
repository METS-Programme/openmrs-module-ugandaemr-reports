package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Listable schema resource restricted to mamba_* tables.
 *
 * GET /ws/rest/v1/schema
 * GET /ws/rest/v1/schema?q=dim
 */
@Resource(
        name = RestConstants.VERSION_1 + "/schema",
        supportedClass = ReportBuilderSchemaResource.MambaTable.class,
        supportedOpenmrsVersions = {"1.8 - 9.0.*"}
)
public class ReportBuilderSchemaResource extends DelegatingCrudResource<ReportBuilderSchemaResource.MambaTable> {

    /**
     * RESTWS likes delegates that have a uuid.
     * This is not persisted; it's a synthetic uuid derived from table name.
     */
    public static class MambaTable {
        private String uuid;
        private String name;

        public MambaTable() { }

        public MambaTable(String name) {
            this.name = name;
            this.uuid = UUID.nameUUIDFromBytes(("mamba-table:" + name).getBytes()).toString();
        }

        public String getUuid() { return uuid; }
        public void setUuid(String uuid) { this.uuid = uuid; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    @Override
    public MambaTable newDelegate() {
        return new MambaTable();
    }

    @Override
    public MambaTable save(MambaTable delegate) {
        throw new UnsupportedOperationException("Read-only resource");
    }

    @Override
    public MambaTable getByUniqueId(String uniqueId) {
        // Not needed for list usage; keep null or implement lookup by synthetic uuid if you want
        return null;
    }

    @Override
    protected void delete(MambaTable delegate, String reason, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("Read-only resource");
    }

    @Override
    public void purge(MambaTable delegate, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("Read-only resource");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {

        String q = context.getParameter("q"); // optional filter on table name
        List<String> tables = service().getMambaTables();

        List<MambaTable> results = new ArrayList<>();
        for (String t : tables) {
            if (q == null || q.trim().isEmpty() || t.toLowerCase().contains(q.toLowerCase())) {
                results.add(new MambaTable(t));
            }
        }

        return new NeedsPaging<>(results, context);
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        // same as doGetAll for this utility
        return doGetAll(context);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addProperty("uuid");
        d.addProperty("name");
        return d;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        return null;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return null;
    }

    public String getDisplayString(MambaTable obj) {
        return obj.getName();
    }
}