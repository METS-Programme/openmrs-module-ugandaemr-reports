package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

/**
 * Maps to: report_builder_dim_age_category
 */
@Entity
@Table(
        name = "report_builder_dim_age_category",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_rb_dim_age_category_code",
                columnNames = {"code"}
        ),
        indexes = {
                @Index(name = "idx_rb_dim_age_category_uuid", columnList = "uuid"),
                @Index(name = "idx_rb_dim_age_category_code", columnList = "code"),
                @Index(name = "idx_rb_dim_age_category_active", columnList = "is_active"),
                @Index(name = "idx_rb_dim_age_category_retired", columnList = "retired")
        }
)
public class ReportBuilderAgeCategory extends BaseOpenmrsMetadata {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "age_category_id")
    private Integer id;

    @Column(name = "code", length = 50, nullable = false, unique = true)
    private String code;

    @Column(name = "version", length = 20)
    private String version = "v1";

    @Column(name = "effective_from")
    private java.sql.Date effectiveFrom;

    @Column(name = "effective_to")
    private java.sql.Date effectiveTo;

    @Column(name = "is_active", nullable = false)
    private Boolean active = true;

    @OneToMany(mappedBy = "ageCategory", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("sortOrder asc")
    private Set<ReportBuilderAgeGroup> ageGroups = new HashSet<>();

    @Override
    public Integer getId() {
        return id;
    }

    @Override
    public void setId(Integer id) {
        this.id = id;
    }

    // Getters/Setters

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }


    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public java.sql.Date getEffectiveFrom() {
        return effectiveFrom;
    }

    public void setEffectiveFrom(java.sql.Date effectiveFrom) {
        this.effectiveFrom = effectiveFrom;
    }

    public java.sql.Date getEffectiveTo() {
        return effectiveTo;
    }

    public void setEffectiveTo(java.sql.Date effectiveTo) {
        this.effectiveTo = effectiveTo;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Set<ReportBuilderAgeGroup> getAgeGroups() {
        return ageGroups;
    }

    public void setAgeGroups(Set<ReportBuilderAgeGroup> ageGroups) {
        this.ageGroups = ageGroups;
    }
}