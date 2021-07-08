/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 * <p>
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * <p>
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */

package org.openmrs.module.ugandaemrreports.reporting.library.dimension;

import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.indicator.dimension.CohortDefinitionDimension;
import org.openmrs.module.ugandaemrreports.library.Moh105CohortLibrary;
import org.openmrs.module.ugandaemrreports.reporting.library.cohort.CommonCohortLibrary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Date;

import static org.openmrs.module.ugandaemrreports.reporting.utils.ReportUtils.map;


/**
 * Library of common dimension definitions
 */
@Component
public class CommonReportDimensionLibrary {

    @Autowired
    private CommonCohortLibrary commonCohortLibrary;
    
    @Autowired
    private Moh105CohortLibrary moh105CohortLibrary;

    /**
     * Gender dimension
     * @return the dimension
     */
    public CohortDefinitionDimension gender() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("gender");
        dim.addCohortDefinition("M", map(commonCohortLibrary.males()));
        dim.addCohortDefinition("F", map(commonCohortLibrary.females()));
        return dim;
    }

    /**
     * Dimension of age using the 4 standard age groups
     * @return the dimension
     */
    public CohortDefinitionDimension get106AgeGroups() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (<2, 2-4, 5-14,15+)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("<2", map(commonCohortLibrary.agedAtMost(1), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("2-<5", map(commonCohortLibrary.agedAtLeastAgedAtMost(2, 4), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("5-14", map(commonCohortLibrary.agedAtLeastAgedAtMost(5,14), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("15+", map(commonCohortLibrary.agedAtLeast(15), "effectiveDate=${endDate}"));
        return dim;
    }
    
    /**
     * MoH definiton of auult and children
     * @return
     */
	public CohortDefinitionDimension getMOHDefinedChildrenAndAdultAgeGroups() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (<15, 15+)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("<15", map(commonCohortLibrary.MoHChildren(), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("15+", map(commonCohortLibrary.MoHAdult(), "effectiveDate=${endDate}"));
        return dim;
	}

    /**
     * Dimension of age using the 3 standard age groups for anc
     * @return the dimension
     */
    public CohortDefinitionDimension standardAgeGroupsForAnc() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (10-19, 20-24, 25+)");
        dim.addParameter(new Parameter("onDate", "On Date", Date.class));
        dim.addCohortDefinition("10-19", map(commonCohortLibrary.agedAtLeastAgedAtMost(10, 19), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("20-24", map(commonCohortLibrary.agedAtLeastAgedAtMost(20, 24), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("25+", map(commonCohortLibrary.agedAtLeast(25), "effectiveDate=${onDate}"));
        return dim;
    }
        
    /**
     * Dimension of age using the 3 standard age groups for Maternity
     * @return the dimension
     */
	public CohortDefinitionDimension standardAgeGroupsForMaternity() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (10-19, 20-24, >=25)");
        dim.addParameter(new Parameter("onDate", "On Date", Date.class));
        dim.addCohortDefinition("10-19", map(commonCohortLibrary.agedAtLeastAgedAtMost(10,19), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("20-24", map(commonCohortLibrary.agedAtLeastAgedAtMost(20,24), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("25+", map(commonCohortLibrary.agedAtLeast(25), "effectiveDate=${endDate}"));
        return dim;
	}

	public CohortDefinitionDimension standardAgeGroupsForOutPatient() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (0-28Days, 29Days-4Yrs, 5-59Yrs, >=60)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("Between0And28Days", map(commonCohortLibrary.agedAtLeastDaysAgedAtMostDays(0,28), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between29DaysAnd4Yrs", map(commonCohortLibrary.agedAtLeastDaysAgedAtMostYears(29,4), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between5And59Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(5, 59), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("GreaterOrEqualTo60Yrs", map(commonCohortLibrary.agedAtLeast(60), "effectiveDate=${endDate}"));
        return dim;
	}

	public CohortDefinitionDimension drugUseAgeGroups() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (10-19Yrs, 20-24Yrs, >=25)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("Between10And19Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(10, 19), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between20And24Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(20, 24), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("GreaterOrEqualTo25Yrs", map(commonCohortLibrary.agedAtLeast(25), "effectiveDate=${endDate}"));
        return dim;
	}

	public CohortDefinitionDimension htcAgeGroups() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (18Months-4Years, 5-9Yrs, 10-14Yrs, 15-18Yrs, 19-49Yrs, >49Yrs)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("Between18MonthsAnd4Years", map(commonCohortLibrary.agedAtLeastMonthsAgedAtMostYears(18,4), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between5And9Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(5,9), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between10And14Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(10, 14), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between15And18Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(15, 18), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between19And49Yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(19, 49), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("GreaterThan49Yrs", map(commonCohortLibrary.agedAtLeast(50), "effectiveDate=${endDate}"));
        return dim;
	}

    public CohortDefinitionDimension HTCAgeGroups() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (Below 1 Yrs,1-4yrs,5-9yrs, 10-14yrs, 15-19yrs,20-24yrs,25-29yrs,30-34yrs,35-39yrs,40-44yrs,45-49yrs,>50yrs)");
        dim.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        dim.addCohortDefinition("Below1yr", map(commonCohortLibrary.agedAtLeastMonthsAgedAtMostYears(0,1), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between1And4yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(1,4), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between5And9yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(5,9), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between10And14yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(10, 14), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between15And19yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(15, 19), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between20And24yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(20, 24), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between25And29yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(25, 29), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between30And34yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(30, 34), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between35And39yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(35, 39), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between40And44yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(40, 44), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("Between45And49yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(45, 49), "effectiveDate=${endDate}"));
        dim.addCohortDefinition("GreaterThan50yrs", map(commonCohortLibrary.agedAtLeast(50), "effectiveDate=${endDate}"));
        return dim;
    }

    public CohortDefinitionDimension MCHAgeGroups() {
        CohortDefinitionDimension ageDisaggregation = new CohortDefinitionDimension();
        ageDisaggregation.setName("age groups (15-19yrs,20-24yrs,25-29yrs,30-34yrs,35-39yrs,40-44yrs,45-49yrs,>50yrs)");
        ageDisaggregation.addCohortDefinition("Between15And19yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(15, 19), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between20And24yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(20, 24), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between25And29yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(25, 29), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between30And34yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(30, 34), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between35And39yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(35, 39), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between40And44yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(40, 44), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between45And49yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(45, 49), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("GreaterThan50yrs", map(commonCohortLibrary.agedAtLeast(50), "effectiveDate=${endDate}"));
        return ageDisaggregation;
    }

    public CohortDefinitionDimension ANCAgeGroups() {
        CohortDefinitionDimension ageDisaggregation = new CohortDefinitionDimension();
        ageDisaggregation.addParameter(new Parameter("effectiveDate", "Effective Date", Date.class));
        ageDisaggregation.setName("age groups (Below15,15-19years,20-24yrs,25-49yrs,>50yrs)");
        ageDisaggregation.addCohortDefinition("Below15", map(commonCohortLibrary.agedAtLeastAgedAtMost(0, 14), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between15And19yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(15, 19), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between20And24yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(20, 24), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("Between25And49yrs", map(commonCohortLibrary.agedAtLeastAgedAtMost(25, 49), "effectiveDate=${endDate}"));
        ageDisaggregation.addCohortDefinition("GreaterThan50yrs", map(commonCohortLibrary.agedAtLeast(50), "effectiveDate=${endDate}"));
        return ageDisaggregation;
    }
	
	/**
     * Dimension for age using 5 age group for smc
     * @return a dimension
     */
    public CohortDefinitionDimension standardAgeGroupsForSmc() {
        CohortDefinitionDimension dim = new CohortDefinitionDimension();
        dim.setName("age groups (<2, 2<5, 5<15, 15-49, >49)");
        dim.addParameter(new Parameter("onDate", "On Date", Date.class));
        dim.addCohortDefinition("<2", map(commonCohortLibrary.agedAtMost(2), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("2<5", map(commonCohortLibrary.agedAtLeastAgedAtMost(3, 4), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("5<15", map(commonCohortLibrary.agedAtLeastAgedAtMost(6, 14), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("15-49", map(commonCohortLibrary.agedAtLeastAgedAtMost(15, 49), "effectiveDate=${onDate}"));
        dim.addCohortDefinition("49+", map(commonCohortLibrary.agedAtLeast(49), "effectiveDate=${onDate}"));
        return dim;
    }
    /**
     * Dimension for site type
     * @return {@link CohortDefinitionDimension}
     */
    public CohortDefinitionDimension siteType() {
    	CohortDefinitionDimension dim = new CohortDefinitionDimension();
    	dim.setName("Site Type");
    	dim.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        dim.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        dim.addCohortDefinition("F", map(moh105CohortLibrary.facilitySiteType(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        dim.addCohortDefinition("O", map(moh105CohortLibrary.outreachSiteType(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
    	return dim;
    }
    
    /**
     * Dimension for procedure methods used
     * @return {@link CohortDefinitionDimension}
     */
    public CohortDefinitionDimension procedureMethod() {
    	CohortDefinitionDimension dim = new CohortDefinitionDimension();
    	dim.setName("Procedure Method");
    	dim.addParameter(new Parameter("onOrAfter", "Start Date", Date.class));
        dim.addParameter(new Parameter("onOrBefore", "End Date", Date.class));
        dim.addCohortDefinition("S", map(moh105CohortLibrary.surgicalProcedureMethod(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
        dim.addCohortDefinition("D", map(moh105CohortLibrary.deviceProcedureMethod(), "onOrAfter=${onOrAfter},onOrBefore=${onOrBefore}"));
    	return dim;
    }
}