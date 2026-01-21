package org.openmrs.module.ugandaemrreports.api.impl;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.Concept;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.logic.op.In;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.ugandaemrreports.api.db.hibernate.HibernateUgandaEMRReportsDAO;
import org.openmrs.module.ugandaemrreports.model.Dashboard;
import org.openmrs.module.ugandaemrreports.model.DashboardReportObject;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.ReportObjectWrapper;
import org.openmrs.util.OpenmrsUtil;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;
import java.util.Set;

/**
 * It is a default implementation of {@link UgandaEMRReportsService}.
 */


public class UgandaEMRReportsServiceImpl extends BaseOpenmrsService implements UgandaEMRReportsService {

	protected final Log log = LogFactory.getLog(this.getClass());

	private HibernateUgandaEMRReportsDAO dao;

	/**
	 * @return the dao
	 */
	public HibernateUgandaEMRReportsDAO getDao() {
		return dao;
	}

	/**
	 * @param dao the dao to set
	 */
	public void setDao(HibernateUgandaEMRReportsDAO dao) {
		this.dao = dao;
	}


	@Override
	public List<DashboardReportObject> getAllDashboardReportObjects() throws APIException {
		return  dao.getAllDashboardReportObjects();
	}

	@Override
	public DashboardReportObject getDashboardReportObjectByUUID(String uuid) throws APIException {
		return dao.getDashboardReportObjectByUUID(uuid);
	}

	@Override
	public DashboardReportObject saveDashboardReportObject(DashboardReportObject dashboardReportObject) throws APIException {
		return dao.saveDashboardReportObject(dashboardReportObject);
	}

	@Override
	public DashboardReportObject getDashboardReportObjectById(Integer id) throws APIException {
		return  dao. getDashboardReportObjectById( id);
	}

	@Override
	public Dashboard saveDashboard(Dashboard dashboard) throws APIException {
		return  dao.saveDashboard(dashboard);
	}

	@Override
	public Dashboard getDashboardByUUID(String uniqueId) throws APIException {
		return dao.getDashboardByUUID(uniqueId);
	}

	@Override
	public Dashboard getDashboardById(Integer id) throws APIException {
		return dao.getDashboardById(id);
	}

	@Override
	public List<Dashboard> getAllDashboards() throws APIException {
		return dao.getAllDashboards();
	}

	@Override
	public void executeFlatteningScript() {
		dao.executeFlatteningScript();
	}

	@Override
	public List<ReportObjectWrapper> getPatientSearches(String type) {
		return dao.getReportObjects(type);
	}

	@Override
	public PatientSearch getPatientSearchByUuid(String uuid) {
		return dao.getPatientSearchByUuid(uuid);
	}

	@Override
	public Cohort getPatientCurrentlyInProgram(String programUuid) {
		return dao.getPatientCurrentlyInPrograms(programUuid);
	}

	@Override
	public Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition) {
		return dao.getPatientsConditionsStatus(patients, codedCondition);
	}

	@Override
	public Set<Concept> getConditionsConcepts() {
		return dao.getAllConditions();
	}

	@Override
	public Map<Integer,Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit){
		return dao.getLatestPatientAppointmentsScheduled(patients,limit);
	}

	@Override
	public List<Integer> getObsConceptsFromEncounters(EncounterType encounterType) {
        return dao.getObsConceptsFromEncounters(encounterType);
	}

	@Override
	public List<Object> getNonCodedOrderReasons(OrderType orderType) {
		return dao.getNonCodedOrderReasons(orderType);
	}

	@Override
	public List<Concept> getCodedOrderReasons(OrderType orderType) {
		return dao.getCodedOrderReasons(orderType);
	}

	@Override
	public Map<Integer, Map<String, Object>> getDrugOrderByIndicator(org.openmrs.cohort.Cohort patients, String drugIndication,OrderType orderType) {
		return dao.getDrugOrderByIndication(patients,drugIndication,orderType);
	}

    public void addMambaetlProperties() {
        File appDataDir = FileUtils.getFile(OpenmrsUtil.getApplicationDataDirectory());
        File propertiesFile = new File(appDataDir, "openmrs-runtime.properties");
        Properties properties = new Properties();

        try (FileInputStream in = new FileInputStream(propertiesFile)) {
            properties.load(in);
        } catch (IOException e) {
            System.err.println("Failed to read properties file: " + e.getMessage());
            return;
        }

        // Extract DB name from connection.url
        String connectionUrl = properties.getProperty("connection.url");
        String dbName = null;

        if (connectionUrl != null && connectionUrl.contains("/")) {
            try {
                int lastSlash = connectionUrl.lastIndexOf('/');
                int questionMark = connectionUrl.indexOf('?', lastSlash);
                if (lastSlash != -1 && questionMark != -1) {
                    dbName = connectionUrl.substring(lastSlash + 1, questionMark);
                } else if (lastSlash != -1) {
                    dbName = connectionUrl.substring(lastSlash + 1);
                }
            } catch (Exception e) {
                System.err.println("Error parsing connection.url: " + e.getMessage());
            }
        }

        if (dbName == null || dbName.isEmpty()) {
            dbName = "openmrs";
            System.out.println("WARNING: Using fallback database name: " + dbName);
        }

        // Extract username
        String username = properties.getProperty("connection.username", "openmrs");
        if (username.isEmpty()) {
            username = "openmrs";
            System.out.println("WARNING: Using fallback username: " + username);
        }

        // Extract password
        String password = properties.getProperty("connection.password", "openmrs");
        if (password.isEmpty()) {
            password = "openmrs";
            System.out.println("WARNING: Using fallback password: " + password);
        }

        // Helper: set only if missing
        setIfAbsent(properties, "mambaetl.analysis.db.openmrs_database", dbName);
        setIfAbsent(properties, "mambaetl.analysis.db.etl_database", dbName);
        setIfAbsent(properties, "mambaetl.analysis.db.username", username);
        setIfAbsent(properties, "mambaetl.analysis.db.password", password);
        setIfAbsent(properties, "mambaetl.analysis.columns", "49");
        setIfAbsent(properties, "mambaetl.analysis.incremental_mode", "1");
        setIfAbsent(properties, "mambaetl.analysis.etl_interval", "3600");
        setIfAbsent(properties, "mambaetl.analysis.locale", "en");
        setIfAbsent(properties, "mambaetl.analysis.automated_flattening", "0");

        try (FileOutputStream out = new FileOutputStream(propertiesFile)) {
            properties.store(out, "Updated with MambaETL related properties (added only if missing)");
            System.out.println("MambaETL properties checked and updated successfully.");
        } catch (IOException e) {
            System.err.println("Failed to write properties file: " + e.getMessage());
        }
    }

    @Override
    public void setupMambaETL() {
        Context.getService(FlattenDatabaseService.class).setupEtl();
    }

    private static void setIfAbsent(Properties properties, String key, String value) {
        if (!properties.containsKey(key)) {
            properties.setProperty(key, value);
            System.out.println("Added property: " + key);
        }
    }

}
