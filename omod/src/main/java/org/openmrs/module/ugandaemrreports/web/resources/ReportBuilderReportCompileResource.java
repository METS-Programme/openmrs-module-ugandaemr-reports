package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.web.controller.dto.ReportBuilderReportCompileResult;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.DefaultRepresentation;
import org.openmrs.module.webservices.rest.web.representation.FullRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

@Resource(
        name = RestConstants.VERSION_1 + "/reportbuilderreportcompile",
        supportedClass = ReportBuilderReportCompileResult.class,
        supportedOpenmrsVersions = { "1.8 - 9.0.*" }
)
public class ReportBuilderReportCompileResource extends DelegatingCrudResource<ReportBuilderReportCompileResult> {

    @Override
    public ReportBuilderReportCompileResult newDelegate() {
        return new ReportBuilderReportCompileResult();
    }

    /**
     * POST /ws/rest/v1/mambareportcompile
     *
     * Request body:
     * {
     *   "mambaReportUuid": "..."
     * }
     */
    @Override
    public ReportBuilderReportCompileResult save(ReportBuilderReportCompileResult delegate) {
        if (delegate == null
                || delegate.getMambaReportUuid() == null
                || delegate.getMambaReportUuid().trim().isEmpty()) {
            throw new IllegalArgumentException("mambaReportUuid is required");
        }

        UgandaEMRReportsService ugandaEMRReportsService = Context.getService(UgandaEMRReportsService.class);
        UgandaEMRReportsService.CompiledReportArtifacts result = ugandaEMRReportsService.compileReport(delegate.getMambaReportUuid());

        ReportDefinition rd = result.getReportDefinition();

        ReportBuilderReportCompileResult out = new ReportBuilderReportCompileResult();
        out.setMambaReportUuid(result.getReportBuilderReport() != null ? result.getReportBuilderReport().getUuid() : delegate.getMambaReportUuid());
        out.setReportDefinitionUuid(rd != null ? rd.getUuid() : null);
        out.setReportDefinitionName(rd != null ? rd.getName() : null);
        out.setReportDesignPath(result.getReportDesignFile() != null ? result.getReportDesignFile().getAbsolutePath() : null);
        out.setCompiled(Boolean.TRUE);

        return out;
    }

    @Override
    public ReportBuilderReportCompileResult getByUniqueId(String uniqueId) {
        return null;
    }

    @Override
    protected void delete(ReportBuilderReportCompileResult delegate, String reason, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("Delete is not supported for mambareportcompile");
    }

    @Override
    public void purge(ReportBuilderReportCompileResult delegate, RequestContext context) throws ResponseException {
        throw new UnsupportedOperationException("Purge is not supported for mambareportcompile");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        return null;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) throws ResponseException {
        return null;
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {
        DelegatingResourceDescription d = new DelegatingResourceDescription();

        if (rep instanceof DefaultRepresentation || rep instanceof FullRepresentation) {
            d.addProperty("mambaReportUuid");
            d.addProperty("reportDefinitionUuid");
            d.addProperty("reportDefinitionName");
            d.addProperty("reportDesignPath");
            d.addProperty("compiled");
        }

        return d;
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() {
        DelegatingResourceDescription d = new DelegatingResourceDescription();
        d.addRequiredProperty("mambaReportUuid");
        return d;
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() {
        return null;
    }
}