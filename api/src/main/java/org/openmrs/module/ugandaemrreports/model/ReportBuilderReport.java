package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "report_builder_report")
public class ReportBuilderReport extends BaseOpenmrsMetadata implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_builder_report_id")
    private Integer id;

    @Column(name = "code", length = 100)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(name = "report_type", length = 30, nullable = false)
    private ReportType reportType = ReportType.AGGREGATE;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private ReportCategory category;

    @Lob
    @Column(name = "config_json")
    private String configJson;

    @Lob
    @Column(name = "meta_json")
    private String metaJson;

    @Column(name = "compiled_report_definition_uuid", length = 38)
    private String compiledReportDefinitionUuid;

    @Column(name = "compiled_report_design_uuid", length = 38)
    private String compiledReportDesignUuid;

    @Column(name = "last_compiled_at")
    private Date lastCompiledAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "compile_status", length = 30, nullable = false)
    private ReportCompileStatus compileStatus = ReportCompileStatus.DRAFT;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getIdAsObject() {
        return getId();
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public ReportType getReportType() {
        return reportType;
    }

    public void setReportType(ReportType reportType) {
        this.reportType = reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = ReportType.fromString(reportType);
    }

    public ReportCategory getCategory() {
        return category;
    }

    public void setCategory(ReportCategory category) {
        this.category = category;
    }

    public String getConfigJson() {
        return configJson;
    }

    public void setConfigJson(String configJson) {
        this.configJson = configJson;
    }

    public String getMetaJson() {
        return metaJson;
    }

    public void setMetaJson(String metaJson) {
        this.metaJson = metaJson;
    }

    public String getDisplay() {
        if (getName() != null && code != null && !code.trim().isEmpty()) {
            return getName() + " (" + code + ")";
        }
        return getName();
    }

    public String getCompiledReportDefinitionUuid() {
        return compiledReportDefinitionUuid;
    }

    public void setCompiledReportDefinitionUuid(String compiledReportDefinitionUuid) {
        this.compiledReportDefinitionUuid = compiledReportDefinitionUuid;
    }

    public String getCompiledReportDesignUuid() {
        return compiledReportDesignUuid;
    }

    public void setCompiledReportDesignUuid(String compiledReportDesignUuid) {
        this.compiledReportDesignUuid = compiledReportDesignUuid;
    }

    public Date getLastCompiledAt() {
        return lastCompiledAt;
    }

    public void setLastCompiledAt(Date lastCompiledAt) {
        this.lastCompiledAt = lastCompiledAt;
    }

    public ReportCompileStatus getCompileStatus() {
        return compileStatus;
    }

    public void setCompileStatus(ReportCompileStatus compileStatus) {
        this.compileStatus = compileStatus;
    }

    public enum ReportType {
        AGGREGATE,
        LINE_LIST;
        public static ReportType fromString(String value) {
            if (value == null || value.trim().isEmpty()) {
                return AGGREGATE;
            }
            try {
                return ReportType.valueOf(value.trim().toUpperCase());
            } catch (IllegalArgumentException ex) {
                return AGGREGATE;
            }
        }
    }

    public enum ReportCompileStatus {
        DRAFT,
        COMPILING,
        COMPILED,
        FAILED;

        public static ReportCompileStatus fromString(String value) {
            if (value == null || value.trim().isEmpty()) {
                return DRAFT;
            }

            try {
                return ReportCompileStatus.valueOf(value.trim().toUpperCase());
            } catch (IllegalArgumentException ex) {
                return DRAFT;
            }
        }
    }
}