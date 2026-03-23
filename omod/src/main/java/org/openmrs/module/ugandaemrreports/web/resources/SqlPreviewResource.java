package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.web.controller.dto.SqlPreviewRequest;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.*;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.Collections;

/**
 * Controller-less SQL preview endpoint using RESTWS resource pattern.
 * <p>
 * POST /ws/rest/v1/reportbuilder/sqlpreview
 * Body: { sql, params, maxRows }
 * Response: same object + { columns, rows, rowCount, truncated }
 */
@Resource(
        name = RestConstants.VERSION_1 + "/sqlpreview",
        supportedClass = SqlPreviewRequest.class,
        supportedOpenmrsVersions = {"2.*", "3.*"}
)
public class SqlPreviewResource extends DelegatingCrudResource<SqlPreviewRequest> {

    private UgandaEMRReportsService service() {
        return Context.getService(UgandaEMRReportsService.class);
    }

    @Override
    public SqlPreviewRequest newDelegate() {
        return new SqlPreviewRequest();
    }

    @Override
    public SqlPreviewRequest save(SqlPreviewRequest delegate) {
        // privilege gate here (recommended)
        Context.requirePrivilege("View Reports"); // replace with your module privilege if you have one

        SqlPreviewResult r = service().previewSql(
                decodeHtmlEntities(delegate.getSql()),
                delegate.getParams() != null ? delegate.getParams() : Collections.emptyMap(),
                delegate.getMaxRows()
        );

        // populate response fields on the same delegate
        delegate.setColumns(r.getColumns());
        delegate.setRows(r.getRows());
        delegate.setRowCount(r.getRowCount());
        delegate.setTruncated(r.isTruncated());

        return delegate;
    }

    @Override
    public SqlPreviewRequest getByUniqueId(String uniqueId) {
        // not a persistent resource
        return null;
    }

    @Override
    protected void delete(SqlPreviewRequest delegate, String reason, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("sqlpreview is not deletable");
    }

    @Override
    public void purge(SqlPreviewRequest delegate, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("sqlpreview is not purgeable");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        // No GET-all for this action resource
        return null;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        // Not used. We rely on POST -> save(delegate)
        return null;
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {

        // Return response fields
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addProperty("sql");
        d.addProperty("params");
        d.addProperty("maxRows");

        d.addProperty("columns");
        d.addProperty("rows");
        d.addProperty("rowCount");
        d.addProperty("truncated");

        return d;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addRequiredProperty("sql");
        d.addProperty("params");
        d.addProperty("maxRows");
        return d;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return null;
    }

    private static String decodeHtmlEntities(String s) {
        if (s == null) return null;

        // common HTML escaping
        String out = s
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&#39;", "'");

        // handle >= and <= that come as &gt;= / &lt;=
        out = out.replace("&gt;=", ">=").replace("&lt;=", "<=");

        // handle “greater-than-or-equal” HTML entity that becomes ≥
        // (some sanitisers use &gte; or &ge;)
        out = out.replace("&gte;", ">=").replace("&ge;", ">=");

        // same for ≤
        out = out.replace("&lte;", "<=").replace("&le;", "<=");

        return out;
    }
}