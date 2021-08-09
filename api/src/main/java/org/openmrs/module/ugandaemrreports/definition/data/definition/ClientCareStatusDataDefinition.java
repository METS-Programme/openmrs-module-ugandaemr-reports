/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandaemrreports.definition.data.definition;

/**
 */
import org.openmrs.calculation.patient.PatientCalculation;
import org.openmrs.calculation.result.CalculationResult;
import org.openmrs.module.reporting.data.BaseDataDefinition;
import org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition;
import org.openmrs.module.reporting.definition.configuration.ConfigurationProperty;
import org.openmrs.module.reporting.definition.configuration.ConfigurationPropertyCachingStrategy;
import org.openmrs.module.reporting.evaluation.caching.Caching;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Patient data definition based on a calculation
 */
@Caching(strategy=ConfigurationPropertyCachingStrategy.class)
public class ClientCareStatusDataDefinition extends BaseDataDefinition implements PatientDataDefinition {

    public static final long serialVersionUID = 1L;

    @ConfigurationProperty
    private Date startDate;

    @ConfigurationProperty
    private Date endDate;
    /**
     * Default Constructor
     */
    public ClientCareStatusDataDefinition() {
        super();
    }


    /**
     * @see org.openmrs.module.reporting.data.DataDefinition#getDataType()
     */
    @Override
    public Class<?> getDataType() {
        return CalculationResult.class;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

}
