package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;

/**
 * Mamba Data Theme
 *
 * A "theme" is a user-friendly domain grouping used by the report builder
 * (e.g., "OPD Diagnoses", "Lab Tests", "Pharmacy Dispenses").
 *
 * It provides:
 *  - Natural language label & description (BaseOpenmrsMetadata fields)
 *  - A stable theme code
 *  - A persisted configuration describing the underlying data source
 *    (table/view, base alias, joins, default filters, selectable fields, etc.)
 *
 * This is independent of OpenMRS reporting module and aligns with Mamba warehouse usage.
 */
@Entity
@Table(
        name = "report_builder_data_theme",
        indexes = {
                @Index(name = "idx_report_builder_data_theme_uuid", columnList = "uuid"),
                @Index(name = "idx_report_builder_data_theme_code", columnList = "code")
        }
)
public class ReportBuilderDataTheme extends BaseOpenmrsMetadata {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_builder_data_theme_id")
    private Integer id;

    /**
     * Stable code (used by UI and APIs)
     * Example: OPD_DIAGNOSES, LAB_TESTS, PHARMACY_DISPENSES
     */
    @Column(name = "code", unique = true, length = 100)
    private String code;


    @Column(name = "domain", nullable = false)
    private String domain;

    /**
     * Theme configuration JSON.
     *
     * Suggested JSON shape:
     * {
     *   "source": {
     *     "schema": "mamba",
     *     "table": "mamba_fact_encounter_diagnosis",
     *     "alias": "d",
     *     "primaryKey": "id",
     *     "patientIdColumn": "patient_id",
     *     "dateColumn": "encounter_date",
     *     "locationColumn": "location_id"
     *   },
     *   "joins": [
     *     { "type": "LEFT", "table": "mamba_dim_location", "alias": "l", "on": "l.location_id = d.location_id" }
     *   ],
     *   "defaultFilters": [
     *     { "field": "d.voided", "op": "=", "value": 0 }
     *   ],
     *   "fields": [
     *     { "key": "diagnosis", "label": "Diagnosis", "expr": "d.diagnosis_name", "type": "string" },
     *     { "key": "icd10", "label": "ICD-10", "expr": "d.icd10_code", "type": "string" }
     *   ],
     *   "nlpHints": {
     *     "examples": ["malaria", "pneumonia", "diarrhoea"],
     *     "synonyms": { "OPD": ["outpatient", "clinic"] }
     *   }
     * }
     */
    @Lob
    @Column(name = "config_json", nullable = false)
    private String configJson;

    /**
     * Free-form metadata (tags, UI icon, ordering, etc.)
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

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }
}