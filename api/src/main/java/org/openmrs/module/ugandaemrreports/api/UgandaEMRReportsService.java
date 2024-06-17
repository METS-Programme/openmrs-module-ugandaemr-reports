package org.openmrs.module.ugandaemrreports.api;

import org.openmrs.api.APIException;
import org.openmrs.api.OpenmrsService;
import org.openmrs.module.ugandaemrreports.model.Dashboard;
import org.openmrs.module.ugandaemrreports.model.DashboardReportObject;
import org.openmrs.reporting.AbstractReportObject;
import org.openmrs.reporting.PatientSearchReportObject;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * This service exposes module's core functionality. It is a Spring managed bean which is configured in
 * moduleApplicationContext.xml.
 * <p>
 * It can be accessed only via Context:<br>
 * <code>
 * Context.getService(UgandaEMRReportsService.class).someMethod();
 * </code>
 *
 * @see org.openmrs.api.context.Context
 */
@Transactional
public interface UgandaEMRReportsService extends OpenmrsService {

    /**
     * Getting all Report objects for dashboard
     *
     * @return List<DashboardReportObject> returns all report objects in a list
     * @throws APIException
     */
    List<DashboardReportObject> getAllDashboardReportObjects() throws APIException;

    /**
     * Get Report object  By uuid
     *
     * @param uuid the uuid of the report object  to return
     * @return Dashboard report object that matched the uuid parameter
     * @throws APIException
     */
    @Transactional
    DashboardReportObject getDashboardReportObjectByUUID(String uuid) throws APIException;

    /**
     * Saves the Dashboard Report Object
     *
     * @param dashboardReportObject to be saved.
     * @return DashboardReportObject saved
     * @throws APIException
     */
    @Transactional
    DashboardReportObject saveDashboardReportObject(DashboardReportObject dashboardReportObject) throws APIException;

    /**
     * @param id to get dashboardReportObject by id
     * @return DashboardReportObject
     * @throws APIException
     */
    @Transactional
    DashboardReportObject getDashboardReportObjectById(Integer id) throws APIException;


    /**
     * @param dashboardReportObject to save Dashboard
     * @return Dashboard
     */
    @Transactional
    Dashboard saveDashboard(Dashboard dashboard)  throws APIException;


    /**
     * @param uniqueId of Dashboard
     * @return Dashboard
     * @throws APIException
     */
    @Transactional
    Dashboard getDashboardByUUID(String uniqueId) throws APIException;


    /**
     * @param id for Dashboard id
     * @return Dashboard with id above
     * @throws APIException
     */
    @Transactional
    Dashboard getDashboardById(Integer id) throws APIException;


    /**
     * @return List of Dashboards in database
     * @throws APIException
     */
    @Transactional
    List<Dashboard> getAllDashboards() throws APIException;


    void executeFlatteningScript();

    List<ReportObjectWrapper> getPatientSearches(String type);
}