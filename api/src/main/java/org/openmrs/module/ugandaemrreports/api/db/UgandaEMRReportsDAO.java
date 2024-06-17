package org.openmrs.module.ugandaemrreports.api.db;

import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.reporting.AbstractReportObject;
import org.openmrs.reporting.PatientSearchReportObject;
import org.openmrs.reporting.ReportObjectWrapper;


import java.util.List;

/**
 * Database methods for {@link UgandaEMRReportsService}.
 */
public interface UgandaEMRReportsDAO {
    void executeFlatteningScript();

    List<ReportObjectWrapper> getReportObjects(String type);
	
}
