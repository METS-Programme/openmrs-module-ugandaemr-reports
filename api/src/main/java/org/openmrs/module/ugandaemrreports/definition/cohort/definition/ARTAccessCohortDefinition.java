package org.openmrs.module.ugandaemrreports.definition.cohort.definition;

import org.openmrs.module.reporting.cohort.definition.BaseCohortDefinition;
import org.openmrs.module.reporting.definition.configuration.ConfigurationProperty;
import org.openmrs.module.ugandaemrreports.common.Enums;

import java.util.Date;

/**
 */
public class ARTAccessCohortDefinition extends BaseCohortDefinition {

    @ConfigurationProperty
    private Date endDate;

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
}
