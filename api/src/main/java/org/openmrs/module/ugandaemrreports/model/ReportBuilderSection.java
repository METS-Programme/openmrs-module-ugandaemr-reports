package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;

/**
 * Mamba Section model.
 *
 * Represents a logical section within a report (e.g., "HMIS 105 - Section 1.1 OPD Attendance").
 * A section typically groups indicators (base/composite/final) in a report structure, but the
 * actual tree/ordering can be stored separately in a Report Definition JSON.
 *
 * This model is intentionally lightweight and internationally adoptable.
 */
@Entity
@Table(
        name = "report_builder_section",
        indexes = {
                @Index(name = "idx_report_builder_section_uuid", columnList = "uuid"),
                @Index(name = "idx_report_builder_section_code", columnList = "code")
        }
)
public class ReportBuilderSection extends BaseOpenmrsMetadata {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_builder_section_id")
    private Integer id;

    /**
     * Optional business code for the section.
     * Example: HMIS105_S1, HMIS105_S1_1, TB_02A
     */
    @Column(name = "code", unique = true, length = 100)
    private String code;

    /**
     * Optional JSON configuration for section-level metadata:
     * - rendering hints (table title, subtitles)
     * - default dimensions (age/sex)
     * - sorting rules
     * - tags / programme area
     * - facility level applicability, etc.
     */
    @Lob
    @Column(name = "config_json")
    private String configJson;

    /**
     * Free-form metadata (UI hints, external mappings, etc.)
     */
    @Lob
    @Column(name = "meta_json")
    private String metaJson;

    // -------------------------------------------------
    // BaseOpenmrsMetadata requires getId()/setId()
    // -------------------------------------------------

    @Override
    public Integer getId() {
        return id;
    }

    @Override
    public void setId(Integer id) {
        this.id = id;
    }

    // -------------------------------------------------
    // Getters and Setters
    // -------------------------------------------------

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
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
}