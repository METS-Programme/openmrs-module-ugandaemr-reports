package org.openmrs.module.ugandaemrreports.api;

import org.openmrs.*;
import org.openmrs.Concept;
import org.openmrs.api.APIException;
import org.openmrs.api.OpenmrsService;
import org.openmrs.module.ugandaemrreports.model.Dashboard;
import org.openmrs.module.ugandaemrreports.model.DashboardReportObject;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Set;

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

    PatientSearch getPatientSearchByUuid(String uuid);

    Cohort getPatientCurrentlyInProgram(String programUuid);

     Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition);

     Set<Concept> getConditionsConcepts();

    Map<Integer,Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit);

    List<Integer> getObsConceptsFromEncounters(EncounterType encounterType);

    List<Object> getNonCodedOrderReasons(OrderType orderType);

    List<Concept> getCodedOrderReasons(OrderType orderType);

    Map<Integer, Map<String, Object>> getDrugOrderByIndicator(org.openmrs.cohort.Cohort patients,String drugIndication,OrderType orderType);

    public  void addMambaetlProperties();

    public void setupMambaETL();
}