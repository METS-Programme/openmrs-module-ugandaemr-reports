package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "report_library")
public class ReportLibrary extends BaseOpenmrsMetadata implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_library_id")
    private Integer id;

    @Column(name = "code", length = 100)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", length = 30, nullable = false)
    private ReportSourceType sourceType = ReportSourceType.LEGACY;

    @Column(name = "report_definition_uuid", length = 38)
    private String reportDefinitionUuid;

    @Column(name = "report_builder_report_uuid", length = 38)
    private String reportBuilderReportUuid;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private ReportCategory category;

    @Enumerated(EnumType.STRING)
    @Column(name = "report_type", length = 30, nullable = false)
    private ReportBuilderReport.ReportType reportType = ReportBuilderReport.ReportType.AGGREGATE;

    @Column(name = "migrated", nullable = false)
    private Boolean migrated = Boolean.FALSE;


    @Override
    public Integer getId() {
        return id;
    }

    @Override
    public void setId(Integer id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public ReportSourceType getSourceType() {
        return sourceType;
    }

    public void setSourceType(ReportSourceType sourceType) {
        this.sourceType = sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = ReportSourceType.fromString(sourceType);
    }

    public String getReportDefinitionUuid() {
        return reportDefinitionUuid;
    }

    public void setReportDefinitionUuid(String reportDefinitionUuid) {
        this.reportDefinitionUuid = reportDefinitionUuid;
    }

    public String getReportBuilderReportUuid() {
        return reportBuilderReportUuid;
    }

    public void setReportBuilderReportUuid(String reportBuilderReportUuid) {
        this.reportBuilderReportUuid = reportBuilderReportUuid;
    }

    public ReportCategory getCategory() {
        return category;
    }

    public void setCategory(ReportCategory category) {
        this.category = category;
    }

    public ReportBuilderReport.ReportType getReportType() {
        return reportType;
    }

    public void setReportType(ReportBuilderReport.ReportType reportType) {
        this.reportType = reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = ReportBuilderReport.ReportType.fromString(reportType);
    }

    public Boolean getMigrated() {
        return migrated;
    }

    public void setMigrated(Boolean migrated) {
        this.migrated = migrated;
    }


    public String getDisplay() {
        if (getName() != null && code != null && !code.trim().isEmpty()) {
            return getName() + " (" + code + ")";
        }
        return getName();
    }

    public enum ReportSourceType {
        LEGACY,
        BUILDER;

        public static ReportSourceType fromString(String value) {
            if (value == null || value.trim().isEmpty()) {
                return LEGACY;
            }
            try {
                return ReportSourceType.valueOf(value.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                return LEGACY;
            }
        }
    }
}