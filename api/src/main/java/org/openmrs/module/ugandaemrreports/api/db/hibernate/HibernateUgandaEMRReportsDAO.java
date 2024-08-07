package org.openmrs.module.ugandaemrreports.api.db.hibernate;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Restrictions;
import org.openmrs.api.db.hibernate.DbSession;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.Cohort;
import org.openmrs.module.ugandaemrreports.api.db.UgandaEMRReportsDAO;
import org.openmrs.module.ugandaemrreports.model.Dashboard;
import org.openmrs.module.ugandaemrreports.model.DashboardReportObject;
import org.openmrs.report.ReportConstants;
import org.openmrs.reporting.AbstractReportObject;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.PatientSearchReportObject;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 */

@Repository("ugandaemrreports.HibernateUgandaEMRReportsDAO")
public class HibernateUgandaEMRReportsDAO implements UgandaEMRReportsDAO {

	protected final Log log = LogFactory.getLog(this.getClass());

	@Autowired
	DbSessionFactory sessionFactory;

	/**
	 * @return the sessionFactory
	 */
	private DbSession getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * @param sessionFactory the sessionFactory to set
	 */
	public void setSessionFactory(DbSessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	public List<DashboardReportObject> getAllDashboardReportObjects() {
		return (List<DashboardReportObject>) getSession().createCriteria(DashboardReportObject.class).list();
	}

	/**
	 * @see org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService#saveDashboardReportObject(DashboardReportObject) (org.openmrs.module.ugandaemrreports.model.DashboardReportObject)
	 */
	public DashboardReportObject getDashboardReportObjectByUUID(String uuid) {
		return (DashboardReportObject) getSession().createCriteria(DashboardReportObject.class).add(Restrictions.eq("uuid", uuid))
				.uniqueResult();
	}

	/**
	 * @see org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService#saveDashboardReportObject(DashboardReportObject) (org.openmrs.module.ugandaemrrepots.model.DashboardReportObject)
	 */
	public DashboardReportObject saveDashboardReportObject(DashboardReportObject dashboardReportObject) {
		getSession().saveOrUpdate(dashboardReportObject);
		return dashboardReportObject;
	}

	public DashboardReportObject getDashboardReportObjectById(Integer id) {
		return (DashboardReportObject) getSession().createCriteria(DashboardReportObject.class).add(Restrictions.eq("dashboard_report_id", id))
				.uniqueResult();
	}



	public List<Dashboard> getAllDashboards() {
		return (List<Dashboard>) getSession().createCriteria(Dashboard.class).list();
	}

	/**
	 * @see org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService#saveDashboard(Dashboard) (org.openmrs.module.ugandaemrreports.model.Dashboard)
	 */
	public Dashboard getDashboardByUUID(String uuid) {
		return (Dashboard) getSession().createCriteria(Dashboard.class).add(Restrictions.eq("uuid", uuid))
				.uniqueResult();
	}

	/**
	 * @see org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService#saveDashboard(Dashboard) (org.openmrs.module.ugandaemrrepots.model.Dashboard)
	 */
	public Dashboard saveDashboard(Dashboard dashboard) {
		getSession().saveOrUpdate(dashboard);
		return dashboard;
	}

	public Dashboard getDashboardById(Integer id) {
		return (Dashboard) getSession().createCriteria(Dashboard.class).add(Restrictions.eq("dashboard_id", id))
				.uniqueResult();
	}


	@Override
	public void executeFlatteningScript() {
		sessionFactory.getCurrentSession().createSQLQuery("CALL sp_mamba_data_processing_etl()").executeUpdate();

	}

	@Override
	public List<ReportObjectWrapper> getReportObjects(String type) {
		Criteria criteria = sessionFactory.getCurrentSession().createCriteria(ReportObjectWrapper.class);
		criteria.add(Restrictions.eq("type", type));
		criteria.add(Restrictions.eq("voided", false));
        return (List<ReportObjectWrapper>) criteria.list();
	}

	@Override
	public PatientSearch getPatientSearchByUuid(String uuid) {
		Criteria criteria = sessionFactory.getCurrentSession().createCriteria(ReportObjectWrapper.class);
		criteria.add(Restrictions.eq("type", ReportConstants.REPORT_OBJECT_TYPE_PATIENTSEARCH));
		criteria.add(Restrictions.eq("uuid", uuid));
		criteria.add(Restrictions.eq("voided", false));
		ReportObjectWrapper wrapper =(ReportObjectWrapper) criteria.uniqueResult();
		AbstractReportObject abstractReportObject = wrapper.getReportObject();
		if (abstractReportObject.getReportObjectId() == null) {
			abstractReportObject.setReportObjectId(wrapper.getReportObjectId());
		}

        return ((PatientSearchReportObject) abstractReportObject).getPatientSearch();

	}

	@Override
	public Cohort getPatientCurrentlyInPrograms(String programUuid) {
		String sb =String.format("SELECT  p.patient_id\n" +
				"FROM patient p\n" +
				"         INNER JOIN patient_program pp ON p.patient_id = pp.patient_id\n" +
				"         INNER JOIN program prog ON pp.program_id = prog.program_id\n" +
				"WHERE prog.uuid = '%s'\n" +
				"  AND pp.date_completed IS NULL",programUuid);

		log.debug("query: " + sb);
		Query query = sessionFactory.getCurrentSession().createSQLQuery(sb.toString());
		return new Cohort(query.list());
	}
}
