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
import org.openmrs.module.webservices.rest.web.response.ResourceDoesNotSupportOperationException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.*;

@Resource(
        name = RestConstants.VERSION_1 + "/mambatablecolumn",
        supportedClass = MambaTableColumnResource.MambaTableColumn.class,
        supportedOpenmrsVersions = {"1.8 - 9.0.*"}
)
public class MambaTableColumnResource extends DelegatingCrudResource<MambaTableColumnResource.MambaTableColumn> {

    public static class MambaTableColumn {
        private String uuid;   // synthetic
        private String table;
        private String columnName;
        private String dataType;

        public MambaTableColumn() {}

        public MambaTableColumn(String table, String columnName, String dataType) {
            this.table = table;
            this.columnName = columnName;
            this.dataType = dataType;
            this.uuid = UUID.nameUUIDFromBytes(
                    ("mamba-column:" + table + ":" + columnName).getBytes()
            ).toString();
        }

        public String getUuid() { return uuid; }
        public void setUuid(String uuid) { this.uuid = uuid; }

        public String getTable() { return table; }
        public void setTable(String table) { this.table = table; }

        public String getColumnName() { return columnName; }
        public void setColumnName(String columnName) { this.columnName = columnName; }

        public String getDataType() { return dataType; }
        public void setDataType(String dataType) { this.dataType = dataType; }
    }

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    @Override
    public MambaTableColumn newDelegate() {
        return new MambaTableColumn();
    }

    @Override
    public MambaTableColumn save(MambaTableColumn delegate) {
        throw new UnsupportedOperationException("mambatablecolumn is read-only");
    }

    @Override
    public MambaTableColumn getByUniqueId(String uniqueId) {
        return null; // not needed
    }

    @Override
    protected void delete(MambaTableColumn delegate, String reason, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("mambatablecolumn is read-only");
    }

    @Override
    public void purge(MambaTableColumn delegate, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("mambatablecolumn is read-only");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("mambatablecolumn is search-only. Use ?table=");
    }


    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        // optional: allow q filter on table name
        String tableName = context.getParameter("table");

        List<Map> columns = service().getMambaTableColumns(tableName);

        List<MambaTableColumn> rows = new ArrayList<>();
        for (Map row : columns) {
            String columnName = String.valueOf(row.get("columnName"));
            String dataType = String.valueOf(row.get("dataType"));

            rows.add(new MambaTableColumn(tableName, columnName, dataType));
        }

        return new NeedsPaging<>(rows, context);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {

        DelegatingResourceDescription d = new DelegatingResourceDescription();

        d.addProperty("uuid");
        d.addProperty("table");
        d.addProperty("columnName");
        d.addProperty("dataType");

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

    public String getDisplayString(MambaTableColumn obj) {
        return obj.getColumnName();
    }
}