package org.openmrs.module.ugandaemrreports.model;

import org.openmrs.BaseOpenmrsMetadata;

import javax.persistence.*;
import java.io.Serializable;

@Entity
@Table(
        name = "report_builder_report_category",
        indexes = {
                @Index(name = "idx_report_builder_report_category_uuid", columnList = "uuid"),
                @Index(name = "idx_report_builder_report_category_retired", columnList = "retired")
        }
)
public class ReportCategory extends BaseOpenmrsMetadata implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_builder_report_category_id")
    private Integer id;

    @Override
    public Integer getId() {
        return id;
    }

    @Override
    public void setId(Integer id) {
        this.id = id;
    }
}