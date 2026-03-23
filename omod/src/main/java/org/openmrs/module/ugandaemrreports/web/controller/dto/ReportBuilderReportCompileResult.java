package org.openmrs.module.ugandaemrreports.web.controller.dto;

public class ReportBuilderReportCompileResult {

    private String mambaReportUuid;
    private String reportDefinitionUuid;
    private String reportDefinitionName;
    private String reportDesignPath;
    private Boolean compiled;

    public String getMambaReportUuid() {
        return mambaReportUuid;
    }

    public void setMambaReportUuid(String mambaReportUuid) {
        this.mambaReportUuid = mambaReportUuid;
    }

    public String getReportDefinitionUuid() {
        return reportDefinitionUuid;
    }

    public void setReportDefinitionUuid(String reportDefinitionUuid) {
        this.reportDefinitionUuid = reportDefinitionUuid;
    }

    public String getReportDefinitionName() {
        return reportDefinitionName;
    }

    public void setReportDefinitionName(String reportDefinitionName) {
        this.reportDefinitionName = reportDefinitionName;
    }

    public String getReportDesignPath() {
        return reportDesignPath;
    }

    public void setReportDesignPath(String reportDesignPath) {
        this.reportDesignPath = reportDesignPath;
    }

    public Boolean getCompiled() {
        return compiled;
    }

    public void setCompiled(Boolean compiled) {
        this.compiled = compiled;
    }
}