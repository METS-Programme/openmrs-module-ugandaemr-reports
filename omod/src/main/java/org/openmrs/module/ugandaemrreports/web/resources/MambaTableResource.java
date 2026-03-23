package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.*;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Resource(
        name = RestConstants.VERSION_1 + "/mambatable",
        supportedClass = MambaTableResource.MambaTable.class,
        supportedOpenmrsVersions = { "2.*", "3.*" }
)
public class MambaTableResource extends DelegatingCrudResource<MambaTableResource.MambaTable> {

    public static class MambaTable {
        private String uuid;   // synthetic, not persisted
        private String name;

        public MambaTable() {}

        public MambaTable(String name) {
            this.name = name;
            // stable-enough synthetic uuid derived from name
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
        // Read-only resource
        throw new UnsupportedOperationException("mambatable is read-only");
    }

    @Override
    public MambaTable getByUniqueId(String uniqueId) {
        // optional: not needed for UI; return null for now
        return null;
    }

    @Override
    protected void delete(MambaTable delegate, String reason, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("mambatable is read-only");
    }

    @Override
    public void purge(MambaTable delegate, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("mambatable is read-only");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        List<String> names = service().getMambaTables(); // from DAO query INFORMATION_SCHEMA

        List<MambaTable> rows = new ArrayList<>();
        for (String n : names) {
            rows.add(new MambaTable(n));
        }

        // NeedsPaging will apply startIndex & limit automatically
        return new NeedsPaging<>(rows, context);
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        // optional: allow q filter on table name
        String q = context.getParameter("q");
        List<String> names = service().getMambaTables();

        List<MambaTable> rows = new ArrayList<>();
        for (String n : names) {
            if (q == null || q.trim().isEmpty() || n.toLowerCase().contains(q.toLowerCase())) {
                rows.add(new MambaTable(n));
            }
        }
        return new NeedsPaging<>(rows, context);
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
        return null; // read-only
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return null; // read-only
    }

    public String getDisplayString(MambaTable obj) {
        return obj.getName();
    }
}