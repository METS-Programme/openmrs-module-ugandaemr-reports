package org.openmrs.module.ugandaemrreports.api.db.hibernate;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.CacheMode;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.criterion.*;
import org.hibernate.transform.AliasToEntityMapResultTransformer;
import org.hibernate.transform.Transformers;
import org.openmrs.Concept;
import org.openmrs.OrderType;
import org.openmrs.Cohort;
import org.openmrs.Condition;
import org.openmrs.EncounterType;
import org.openmrs.api.context.Context;
import org.openmrs.api.db.hibernate.DbSession;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.ugandaemrreports.api.db.UgandaEMRReportsDAO;
import org.openmrs.module.ugandaemrreports.definition.data.evaluator.SqlPreviewResult;
import org.openmrs.module.ugandaemrreports.model.*;
import org.openmrs.report.ReportConstants;
import org.openmrs.reporting.AbstractReportObject;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.PatientSearchReportObject;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.regex.Pattern;

import java.util.*;
import java.util.List;
import java.util.Set;

/**
 *
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
        ReportObjectWrapper wrapper = (ReportObjectWrapper) criteria.uniqueResult();
        AbstractReportObject abstractReportObject = wrapper.getReportObject();
        if (abstractReportObject.getReportObjectId() == null) {
            abstractReportObject.setReportObjectId(wrapper.getReportObjectId());
        }

        return ((PatientSearchReportObject) abstractReportObject).getPatientSearch();

    }

    @Override
    public Cohort getPatientCurrentlyInPrograms(String programUuid) {
        String sb = String.format("SELECT  p.patient_id\n" +
                "FROM patient p\n" +
                "         INNER JOIN patient_program pp ON p.patient_id = pp.patient_id\n" +
                "         INNER JOIN program prog ON pp.program_id = prog.program_id\n" +
                "WHERE prog.uuid = '%s'\n" +
                "  AND pp.date_completed IS NULL", programUuid);

        log.debug("query: " + sb);
        Query query = sessionFactory.getCurrentSession().createSQLQuery(sb.toString());
        return new Cohort(query.list());
    }

    @Override
    public Map<Integer, String> getPatientsConditionsStatus(org.openmrs.cohort.Cohort patients, Concept codedCondition) {
        Map<Integer, String> ret = new HashMap<Integer, String>();


        Criteria criteria = sessionFactory.getCurrentSession().createCriteria(Condition.class);
        criteria.setCacheMode(CacheMode.IGNORE);


        // only restrict on patient ids if some were passed in
        if (patients != null)
            criteria.add(Restrictions.in("patient.personId", patients.getMemberIds()));


        criteria.add(Expression.eq("condition.coded", codedCondition));
        criteria.add(Expression.eq("voided", false));

        criteria.addOrder(org.hibernate.criterion.Order.desc("onsetDate"));
        long start = System.currentTimeMillis();
        List<Condition> conditions = criteria.list();


        log.debug("Took: " + (System.currentTimeMillis() - start) + " ms to run the patient/obs query");

        // set up the return map
        for (Condition c : conditions) {
            int ptId = c.getPatient().getPatientId();

            String status = c.getClinicalStatus().toString();
            ret.put(ptId, status);
        }


        return ret;
    }

    @Override
    public Set<Concept> getAllConditions() {
        Set<Concept> ret = new HashSet<>();
        Criteria criteria = sessionFactory.getCurrentSession().createCriteria(Condition.class);
        criteria.setCacheMode(CacheMode.IGNORE);
        criteria.add(Expression.eq("voided", false));


        long start = System.currentTimeMillis();
        List<Condition> conditions = criteria.list();
        log.debug("Took: " + (System.currentTimeMillis() - start) + " ms to run the patient/obs query");

        // set up the return map
        for (Condition c : conditions) {
            Concept concept = c.getCondition().getCoded();

            if (concept != null) {
                ret.add(concept);
            }

        }
        return ret;
    }


    @Override
    public Map<Integer, Object> getLatestPatientAppointmentsScheduled(org.openmrs.cohort.Cohort patients, int limit) {
        Map<Integer, Object> ret = new HashMap<Integer, Object>();
        Query query = sessionFactory.getCurrentSession().createSQLQuery(
                "select patient_id, start_date_time from patient_appointment where voided = false and patient_id in (:patientIds) order by start_date_time DESC ");

        if (!patients.getMemberIds().isEmpty())
            query.setParameterList("patientIds", patients.getMemberIds());
        query.setCacheMode(CacheMode.IGNORE);

        List<Object[]> temp = query.list();

        long now = System.currentTimeMillis();
        for (Object[] results : temp) {
            Integer ptId = (Integer) results[0];
            Object apptDate = results[1];

            if (!ret.containsKey(ptId))
                ret.put(ptId, apptDate);
        }
        return ret;
    }

    @Override
    public List<Object> getNonCodedOrderReasons(OrderType orderType) {

        String sb = String.format("SELECT DISTINCT o.order_reason_non_coded\n" +
                "FROM orders o\n" +
                "         INNER JOIN order_type ot ON o.order_type_id = ot.order_type_id\n" +
                "WHERE ot.uuid = '%s' and o.order_reason_non_coded is not null ;", orderType.getUuid());
        log.debug("query: " + sb);
        Query query = sessionFactory.getCurrentSession().createSQLQuery(sb.toString());

        query.setCacheMode(CacheMode.IGNORE);
        List<Object> ret = query.list();

        return ret;
    }

    @Override
    public List<Concept> getCodedOrderReasons(OrderType orderType) {
        List<Concept> ret = new ArrayList<>();
        String sb = String.format("SELECT DISTINCT o.order_reason\n" +
                "FROM orders o\n" +
                "         INNER JOIN order_type ot ON o.order_type_id = ot.order_type_id\n" +
                "WHERE ot.uuid = '%s' and o.order_reason is not null;\n", orderType.getUuid());
        log.debug("query: " + sb);
        Query query = sessionFactory.getCurrentSession().createSQLQuery(sb.toString());

        query.setCacheMode(CacheMode.IGNORE);
        List<Object[]> temp = query.list();

        for (Object[] results : temp) {
            int conceptId = (int) results[0];
            Concept concept = Context.getConceptService().getConcept(conceptId);
            ret.add(concept);
        }
        return ret;
    }

    @Override
    public Map<Integer, Map<String, Object>> getDrugOrderByIndication(org.openmrs.cohort.Cohort patients, String drugIndication, OrderType orderType) {
        String hql = String.format("SELECT patient_id, cn.name as drug,DATE(date_activated),dose, quantity,cn1.name as quantity_unit , duration,cn2.name as duration_units\n" +
                "FROM orders o\n" +
                "         INNER JOIN order_type ot ON o.order_type_id = ot.order_type_id\n" +
                "         INNER JOIN drug_order d_o ON o.order_id = d_o.order_id\n" +
                "        INNER JOIN concept c on o.concept_id = c.concept_id\n" +
                "        LEFT JOIN concept_name cn on c.concept_id = cn.concept_id\n" +
                "        LEFT JOIN concept c1 on d_o.quantity_units = c1.concept_id\n" +
                "        LEFT JOIN concept_name cn1 on c1.concept_id = cn1.concept_id  and cn1.locale='en' and cn1.concept_name_type='FULLY_SPECIFIED'\n" +
                "        LEFT JOIN concept c2 on d_o.duration_units = c2.concept_id\n" +
                "        LEFT JOIN concept_name cn2 on c2.concept_id = cn2.concept_id  and cn2.locale='en' and cn2.concept_name_type='FULLY_SPECIFIED'\n" +
                "where  cn.locale='en' and cn.concept_name_type='FULLY_SPECIFIED' and ot.uuid='%s' and o.order_reason_non_coded='%s' and patient_id in (:patientIds)", orderType.getUuid(), drugIndication);

        Query query = sessionFactory.getCurrentSession().createSQLQuery(hql.toString());
        query.setParameter("patientIds", patients.getMemberIds());
        Map<Integer, Map<String, Object>> ret = new HashMap<>();
        List<Object[]> rows = query.list();

        for (Object[] rowArray : rows) {
            LinkedHashMap<String, Object> row = new LinkedHashMap<>();
            Integer ptId = (Integer) rowArray[0];

            Object drug = rowArray[1];
            row.put("drug", drug);
            Object encounter_date = rowArray[2];
            row.put("drug_date_ordered", String.valueOf(encounter_date));
            Object dose = rowArray[3];
            row.put("dose", dose);
            Object quantity = rowArray[4];
            row.put("quantity", quantity);
            Object quantity_unit = rowArray[5];
            row.put("quantity_unit", quantity_unit);
            Object duration = rowArray[6];
            row.put("duration", duration);
            Object duration_unit = rowArray[7];
            row.put("duration_unit", duration_unit);

            ret.put(ptId, row);
        }

        Set<Integer> patientWithNoRecords = new HashSet<>(patients.getMemberIds());
        patientWithNoRecords.removeAll(ret.keySet());

        for (Integer i : patientWithNoRecords) {
            LinkedHashMap<String, Object> row = new LinkedHashMap<>();
            row.put("drug", "");
            row.put("drug_date_ordered", "");
            row.put("dose", "");
            row.put("quantity", "");
            row.put("quantity_unit", "");
            row.put("duration", "");
            row.put("duration_unit", "");
            ret.put(i, row);
        }

        return ret;
    }

    @Override
    public List<Integer> getObsConceptsFromEncounters(EncounterType encounterType) {
        String hql = "SELECT DISTINCT o.concept.id " +
                "FROM Obs o " +
                "INNER JOIN o.encounter e " +
                "INNER JOIN e.encounterType et " +
                "WHERE et.uuid = :uuid";
        Query query = sessionFactory.getCurrentSession().createQuery(hql);
        query.setParameter("uuid", encounterType.getUuid());
        List<Integer> conceptIds = query.list();
        return conceptIds;
    }


    private String like(String q) {
        return "%" + q.trim().toLowerCase() + "%";
    }

    // =========================================================
    // ReportBuilderIndicator
    // =========================================================

    @Override
    public ReportBuilderIndicator saveReportBuilderIndicator(ReportBuilderIndicator indicator) {
        getSession().saveOrUpdate(indicator);
        return indicator;
    }

    @Override
    public ReportBuilderIndicator getReportBuilderIndicatorById(Integer id) {
        return (ReportBuilderIndicator) getSession().get(ReportBuilderIndicator.class, id);
    }

    @Override
    public ReportBuilderIndicator getReportBuilderIndicatorByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportBuilderIndicator.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportBuilderIndicator) c.uniqueResult();
    }

    @Override
    public ReportBuilderIndicator getReportBuilderIndicatorByCode(String code) {
        if (code == null) return null;
        Criteria c = getSession().createCriteria(ReportBuilderIndicator.class);
        c.add(Restrictions.eq("code", code));
        return (ReportBuilderIndicator) c.uniqueResult();
    }

    @Override
    public List<ReportBuilderIndicator> getReportBuilderIndicators(String qStr, ReportBuilderIndicator.Kind kind, boolean includeRetired,
                                                                   Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderIndicator.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (!includeRetired) c.add(Restrictions.eq("retired", false));
        if (kind != null) c.add(Restrictions.eq("kind", kind));

        if (qStr != null && qStr.trim().length() > 0) {
            String q = like(qStr);
            c.add(Restrictions.or(
                    Restrictions.ilike("name", q),
                    Restrictions.ilike("description", q),
                    Restrictions.ilike("code", q)
            ));
        }

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderIndicator>) c.list();
    }

    @Override
    public List<ReportBuilderIndicator> getAllReportBuilderaIndicator(Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderIndicator.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderIndicator>) c.list();
    }

    @Override
    public List<ReportBuilderAgeGroup> getAgeGroups(String q, ReportBuilderAgeCategory category, Boolean activeOnly, Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderAgeGroup.class);
        c.setCacheMode(CacheMode.IGNORE);

        // filters
        if (category != null) {
            c.add(Restrictions.eq("ageCategory", category));
        }

        if (activeOnly != null) {
            // activeOnly=true -> active=true
            // activeOnly=false -> active=false
            c.add(Restrictions.eq("active", activeOnly));
        }

        if (q != null && !q.trim().isEmpty()) {
            String like = "%" + q.trim() + "%";
            c.add(
                    Restrictions.or(
                            Restrictions.ilike("label", like),
                            Restrictions.ilike("code", like)
                    )
            );
        }

        // ordering: category then sort order then label
        c.createAlias("ageCategory", "ac"); // safe for ordering

        // paging
        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderAgeGroup>) c.list();
    }

    public List<ReportBuilderIndicator> getReportBuilderIndicators(ReportBuilderIndicator.Kind kind, boolean includeRetired,
                                                                   Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderIndicator.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (!includeRetired) c.add(Restrictions.eq("retired", false));
        if (kind != null) c.add(Restrictions.eq("kind", kind));

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderIndicator>) c.list();
    }

    @Override
    public long getReportBuilderIndicatorsCount(String qStr, ReportBuilderIndicator.Kind kind, boolean includeRetired) {
        // simplest: HQL count
        StringBuilder hql = new StringBuilder("select count(i) from ReportBuilderIndicator i where 1=1 ");
        if (!includeRetired) hql.append("and i.retired = false ");
        if (kind != null) hql.append("and i.kind = :kind ");
        if (qStr != null && qStr.trim().length() > 0) {
            hql.append("and (lower(i.name) like :q or lower(i.description) like :q or lower(i.code) like :q) ");
        }

        Query q = getSession().createQuery(hql.toString());
        if (kind != null) q.setParameter("kind", kind);
        if (qStr != null && qStr.trim().length() > 0) q.setString("q", like(qStr));

        Number n = (Number) q.uniqueResult();
        return n == null ? 0L : n.longValue();
    }

    @Override
    public void purgeReportBuilderIndicator(ReportBuilderIndicator indicator) {
        getSession().delete(indicator);
    }

    // =========================================================
    // ReportBuilderSection
    // =========================================================

    @Override
    public ReportBuilderSection saveReportBuilderSection(ReportBuilderSection section) {
        getSession().saveOrUpdate(section);
        return section;
    }

    @Override
    public ReportBuilderSection getReportBuilderSectionById(Integer id) {
        return (ReportBuilderSection) getSession().get(ReportBuilderSection.class, id);
    }

    @Override
    public ReportBuilderSection getReportBuilderSectionByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportBuilderSection.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportBuilderSection) c.uniqueResult();
    }

    @Override
    public ReportBuilderSection getReportBuilderSectionByCode(String code) {
        if (code == null) return null;
        Criteria c = getSession().createCriteria(ReportBuilderSection.class);
        c.add(Restrictions.eq("code", code));
        return (ReportBuilderSection) c.uniqueResult();
    }

    @Override
    public List<ReportBuilderSection> getReportBuilderSections(String qStr, boolean includeRetired,
                                                               Integer startIndex, Integer limit) {
        Criteria c = getSession().createCriteria(ReportBuilderSection.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (!includeRetired) c.add(Restrictions.eq("retired", false));

        if (qStr != null && qStr.trim().length() > 0) {
            String q = like(qStr);
            c.add(Restrictions.or(
                    Restrictions.ilike("name", q),
                    Restrictions.ilike("description", q),
                    Restrictions.ilike("code", q)
            ));
        }

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderSection>) c.list();
    }

    @Override
    public long getReportBuilderSectionsCount(String qStr, boolean includeRetired) {
        StringBuilder hql = new StringBuilder("select count(s) from ReportBuilderSection s where 1=1 ");
        if (!includeRetired) hql.append("and s.retired = false ");
        if (qStr != null && qStr.trim().length() > 0) {
            hql.append("and (lower(s.name) like :q or lower(s.description) like :q or lower(s.code) like :q) ");
        }

        Query q = getSession().createQuery(hql.toString());
        if (qStr != null && qStr.trim().length() > 0) q.setString("q", like(qStr));

        Number n = (Number) q.uniqueResult();
        return n == null ? 0L : n.longValue();
    }

    @Override
    public void purgeReportBuilderSection(ReportBuilderSection section) {
        getSession().delete(section);
    }

    // =========================================================
    // ReportBuilderDataTheme
    // =========================================================

    @Override
    public ReportBuilderDataTheme saveReportBuilderDataTheme(ReportBuilderDataTheme theme) {
        getSession().saveOrUpdate(theme);
        return theme;
    }

    @Override
    public ReportBuilderDataTheme getReportBuilderDataThemeById(Integer id) {
        return (ReportBuilderDataTheme) getSession().get(ReportBuilderDataTheme.class, id);
    }

    @Override
    public ReportBuilderDataTheme getReportBuilderDataThemeByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportBuilderDataTheme.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportBuilderDataTheme) c.uniqueResult();
    }

    @Override
    public ReportBuilderDataTheme getReportBuilderDataThemeByCode(String code) {
        if (code == null) return null;
        Criteria c = getSession().createCriteria(ReportBuilderDataTheme.class);
        c.add(Restrictions.eq("code", code));
        return (ReportBuilderDataTheme) c.uniqueResult();
    }

    @Override
    public List<ReportBuilderDataTheme> getReportBuilderDataThemes(String qStr, boolean includeRetired,
                                                                   Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderDataTheme.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (!includeRetired) c.add(Restrictions.eq("retired", false));

        if (qStr != null && qStr.trim().length() > 0) {
            String q = like(qStr);
            c.add(Restrictions.or(
                    Restrictions.ilike("name", q),
                    Restrictions.ilike("description", q),
                    Restrictions.ilike("code", q)
            ));
        }

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderDataTheme>) c.list();
    }

    @Override
    public long getReportBuilderThemesCount(String qStr, boolean includeRetired) {
        StringBuilder hql = new StringBuilder("select count(t) from ReportBuilderDataTheme t where 1=1 ");
        if (!includeRetired) hql.append("and t.retired = false ");
        if (qStr != null && qStr.trim().length() > 0) {
            hql.append("and (lower(t.name) like :q or lower(t.description) like :q or lower(t.code) like :q) ");
        }

        Query q = getSession().createQuery(hql.toString());
        if (qStr != null && qStr.trim().length() > 0) q.setString("q", like(qStr));

        Number n = (Number) q.uniqueResult();
        return n == null ? 0L : n.longValue();
    }

    @Override
    public void purgeReportBuilderDataTheme(ReportBuilderDataTheme theme) {
        getSession().delete(theme);
    }

    // =========================================================
    // Age Categories
    // =========================================================

    @Override
    public ReportBuilderAgeCategory saveAgeCategory(ReportBuilderAgeCategory category) {
        getSession().saveOrUpdate(category);
        return category;
    }

    @Override
    public ReportBuilderAgeCategory getAgeCategoryById(Integer id) {
        return (ReportBuilderAgeCategory) getSession().get(ReportBuilderAgeCategory.class, id);
    }

    @Override
    public ReportBuilderAgeCategory getAgeCategoryByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportBuilderAgeCategory.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportBuilderAgeCategory) c.uniqueResult();
    }

    @Override
    public ReportBuilderAgeCategory getAgeCategoryByCode(String code) {
        Criteria c = getSession().createCriteria(ReportBuilderAgeCategory.class);
        c.add(Restrictions.eq("code", code));
        return (ReportBuilderAgeCategory) c.uniqueResult();
    }

    @Override
    public List<ReportBuilderAgeCategory> getAgeCategories(String qStr, boolean includeRetired, Boolean activeOnly,
                                                           Integer startIndex, Integer limit) {

        Criteria c = getSession().createCriteria(ReportBuilderAgeCategory.class);
        c.setCacheMode(CacheMode.IGNORE);

        if (!includeRetired) c.add(Restrictions.eq("retired", false));
        if (activeOnly != null && activeOnly) c.add(Restrictions.eq("active", true));

        if (qStr != null && qStr.trim().length() > 0) {
            String q = like(qStr);
            c.add(Restrictions.or(
                    Restrictions.ilike("name", q),
                    Restrictions.ilike("description", q),
                    Restrictions.ilike("code", q)
            ));
        }

        if (startIndex != null) c.setFirstResult(Math.max(0, startIndex));
        if (limit != null) c.setMaxResults(Math.max(1, limit));

        return (List<ReportBuilderAgeCategory>) c.list();
    }

    @Override
    public long getAgeCategoriesCount(String qStr, boolean includeRetired, Boolean activeOnly) {
        StringBuilder hql = new StringBuilder("select count(c) from ReportBuilderAgeCategory c where 1=1 ");
        if (!includeRetired) hql.append("and c.retired = false ");
        if (activeOnly != null && activeOnly) hql.append("and c.active = true ");
        if (qStr != null && qStr.trim().length() > 0) {
            hql.append("and (lower(c.name) like :q or lower(c.description) like :q or lower(c.code) like :q) ");
        }

        Query q = getSession().createQuery(hql.toString());
        if (qStr != null && qStr.trim().length() > 0) q.setString("q", like(qStr));

        Number n = (Number) q.uniqueResult();
        return n == null ? 0L : n.longValue();
    }

    @Override
    public void purgeAgeCategory(ReportBuilderAgeCategory category) {
        getSession().delete(category);
    }

    // =========================================================
    // Age Groups
    // =========================================================

    @Override
    public ReportBuilderAgeGroup saveAgeGroup(ReportBuilderAgeGroup group) {
        getSession().saveOrUpdate(group);
        return group;
    }

    @Override
    public ReportBuilderAgeGroup getAgeGroupById(Integer id) {
        return (ReportBuilderAgeGroup) getSession().get(ReportBuilderAgeGroup.class, id);
    }

    @Override
    public List<ReportBuilderAgeGroup> getAgeGroupsByCategoryUuid(String categoryUuid, Boolean activeOnly) {
        StringBuilder hql = new StringBuilder(
                "select g from ReportBuilderAgeGroup g where g.ageCategory.uuid = :uuid "
        );
        if (activeOnly != null && activeOnly) hql.append("and g.active = true ");
        hql.append("order by g.sortOrder asc");

        Query q = getSession().createQuery(hql.toString());
        q.setString("uuid", categoryUuid);
        return (List<ReportBuilderAgeGroup>) q.list();
    }

    @Override
    public List<ReportBuilderAgeGroup> getAgeGroupsByCategoryCode(String categoryCode, Boolean activeOnly) {
        StringBuilder hql = new StringBuilder(
                "select g from ReportBuilderAgeGroup g where g.ageCategory.code = :code "
        );
        if (activeOnly != null && activeOnly) hql.append("and g.active = true ");
        hql.append("order by g.sortOrder asc");

        Query q = getSession().createQuery(hql.toString());
        q.setString("code", categoryCode);
        return (List<ReportBuilderAgeGroup>) q.list();
    }

    @Override
    public void purgeAgeGroup(ReportBuilderAgeGroup group) {
        getSession().delete(group);
    }

    // =========================================================
    // Utility: list mamba_* tables for Theme Builder UI
    // =========================================================

    @Override
    public List<String> getMambaTables() {
        // MySQL/MariaDB: list tables & views in current schema
        // escape '_' because it's a LIKE wildcard
        String sql =
                "select t.TABLE_NAME " +
                        "from INFORMATION_SCHEMA.TABLES t " +
                        "where t.TABLE_SCHEMA = database() " +
                        "and t.TABLE_NAME like 'mamba\\_%' escape '\\\\' " +
                        "and t.TABLE_TYPE in ('BASE TABLE','VIEW') " +
                        "order by t.TABLE_NAME asc";

        Query q = getSession().createSQLQuery(sql);
        return (List<String>) q.list();
    }

    @SuppressWarnings({"unchecked", "deprecation"})
    public List<Map> getMambaTableColumns(String tableName) {

        if (tableName == null || tableName.trim().isEmpty()) {
            return Collections.emptyList();
        }

        tableName = tableName.trim();

        // Optional: restrict to mamba_* tables only
        if (!tableName.startsWith("mamba_")) {
            throw new IllegalArgumentException("Only mamba_* tables are allowed: " + tableName);
        }

        String sql =
                "SELECT " +
                        "  c.COLUMN_NAME AS columnName, " +
                        "  c.DATA_TYPE   AS dataType " +
                        "FROM INFORMATION_SCHEMA.COLUMNS c " +
                        "WHERE c.TABLE_SCHEMA = DATABASE() " +
                        "  AND c.TABLE_NAME = :tableName " +
                        "ORDER BY c.ORDINAL_POSITION";

        Query q = getSession().createSQLQuery(sql);
        q.setString("tableName", tableName);

        // This makes q.list() return List<Map> instead of List<Object[]>
        q.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);

        return (List<Map>) q.list();
    }

    @Override
    public SqlPreviewResult previewSql(String rawSql, Map<String, Object> params, Integer maxRows) {

        if (rawSql == null || rawSql.trim().isEmpty()) {
            throw new IllegalArgumentException("sql is required");
        }

        int rowsLimit = maxRows != null ? maxRows : 200;
        rowsLimit = Math.max(1, Math.min(rowsLimit, 1000));

        String sql = normalizeSql(rawSql);
        validateSql(sql);

        // UI SQL uses quoted params like ':startDate' - convert to bindable named params
        sql = normalizeQuotedParams(sql);

        // Enforce row limit for both SELECT and WITH (MySQL/MariaDB)
        String limitedSql = wrapWithLimit(sql);

        // DbSession supports createSQLQuery
        SQLQuery q = getSession().createSQLQuery(limitedSql);
        q.setCacheMode(CacheMode.IGNORE);

        // bind request params
        Map<String, Object> safeParams = (params != null) ? params : Collections.emptyMap();
        for (Map.Entry<String, Object> e : safeParams.entrySet()) {
            q.setParameter(e.getKey(), e.getValue());
        }
        q.setParameter("__maxRows", rowsLimit);

        // result rows as Map<alias, value>
        @SuppressWarnings("deprecation")
        SQLQuery mapQuery = (SQLQuery) q.setResultTransformer(AliasToEntityMapResultTransformer.INSTANCE);

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> result = (List<Map<String, Object>>) mapQuery.list();

        List<String> columns = new ArrayList<>();
        if (!result.isEmpty()) {
            // Often LinkedHashMap - preserves column order from SQL
            columns.addAll(result.get(0).keySet());
        }

        List<List<Object>> rows = new ArrayList<>();
        for (Map<String, Object> rowMap : result) {
            List<Object> row = new ArrayList<>(columns.size());
            for (String c : columns) {
                row.add(rowMap.get(c));
            }
            rows.add(row);
        }

        boolean truncated = rows.size() >= rowsLimit;
        return new SqlPreviewResult(columns, rows, rows.size(), truncated);
    }

// -------------------- helpers --------------------

    private static final Pattern FORBIDDEN =
            Pattern.compile("\\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE)\\b", Pattern.CASE_INSENSITIVE);

    private static String normalizeSql(String sql) {
        String s = sql.trim();
        // remove one trailing semicolon only
        if (s.endsWith(";")) s = s.substring(0, s.length() - 1).trim();
        return s;
    }

    private static void validateSql(String sql) {
        String upper = sql.trim().toUpperCase(Locale.ROOT);

        if (!(upper.startsWith("SELECT") || upper.startsWith("WITH"))) {
            throw new IllegalArgumentException("Only SELECT/WITH queries are allowed");
        }

        // block multiple statements: any remaining ';' is suspicious
        if (sql.contains(";")) {
            throw new IllegalArgumentException("Multiple statements are not allowed");
        }

        if (FORBIDDEN.matcher(sql).find()) {
            throw new IllegalArgumentException("Only read-only queries are allowed");
        }
    }

    /**
     * Converts quoted params ':startDate' => :startDate so Hibernate can bind them.
     */
    private static String normalizeQuotedParams(String sql) {
        return sql
                .replace("':startDate'", ":startDate")
                .replace("':endDate'", ":endDate");
    }

    private static String wrapWithLimit(String sql) {
        return "SELECT * FROM (" + sql + ") _rb_preview LIMIT :__maxRows";
    }

    @Override
    public ReportBuilderReport saveReportBuilderReport(ReportBuilderReport report) {
        getSession().saveOrUpdate(report);
        return report;
    }

    @Override
    public ReportBuilderReport getReportBuilderReportByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportBuilderReport.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportBuilderReport) c.uniqueResult();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ReportBuilderReport> getReportBuilderReports(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        Criteria c = getSession().createCriteria(ReportBuilderReport.class);

        if (!includeRetired) {
            c.add(Restrictions.eq("retired", false));
        }

        if (q != null && !q.trim().isEmpty()) {
            c.add(
                    Restrictions.or(
                            Restrictions.ilike("name", q.trim(), MatchMode.ANYWHERE),
                            Restrictions.ilike("description", q.trim(), MatchMode.ANYWHERE),
                            Restrictions.ilike("code", q.trim(), MatchMode.ANYWHERE)
                    )
            );
        }

        c.addOrder(Order.asc("name"));

        if (startIndex != null) {
            c.setFirstResult(startIndex);
        }

        if (limit != null) {
            c.setMaxResults(limit);
        }

        return c.list();
    }

    @Override
    public void deleteReportBuilderReport(ReportBuilderReport report) {
        getSession().delete(report);
    }

    @Override
    public void retireReportBuilderReport(ReportBuilderReport report, String reason) {
        report.setRetired(true);
        report.setRetireReason(reason);
        report.setDateRetired(new Date());
        report.setRetiredBy(Context.getAuthenticatedUser());
        getSession().saveOrUpdate(report);
    }

    @Override
    public void purgeReportBuilderReport(ReportBuilderReport report) {
        getSession().delete(report);
    }

    @Override
    public ReportCategory saveReportCategory(ReportCategory category) {
        getSession().saveOrUpdate(category);
        return category;
    }

    @Override
    public ReportCategory getReportCategoryById(Integer id) {
        return (ReportCategory) getSession().get(ReportCategory.class, id);
    }

    @Override
    public ReportCategory getReportCategoryByUuid(String uuid) {
        Criteria criteria = getSession().createCriteria(ReportCategory.class);
        criteria.add(Restrictions.eq("uuid", uuid));
        return (ReportCategory) criteria.uniqueResult();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ReportCategory> getReportCategories(String q, boolean includeRetired, Integer startIndex, Integer limit) {

        Criteria criteria = getSession().createCriteria(ReportCategory.class);

        if (!includeRetired) {
            criteria.add(Restrictions.eq("retired", false));
        }

        if (q != null && !q.trim().isEmpty()) {
            String query = "%" + q.trim().toLowerCase() + "%";

            Disjunction or = Restrictions.disjunction();
            or.add(Restrictions.ilike("name", query));
            or.add(Restrictions.ilike("description", query));

            criteria.add(or);
        }

        criteria.addOrder(Order.asc("name"));

        if (startIndex != null) {
            criteria.setFirstResult(startIndex);
        }

        if (limit != null) {
            criteria.setMaxResults(limit);
        }

        return criteria.list();
    }

    @Override
    public long getReportCategoriesCount(String q, boolean includeRetired) {

        Criteria criteria = getSession().createCriteria(ReportCategory.class);

        if (!includeRetired) {
            criteria.add(Restrictions.eq("retired", false));
        }

        if (q != null && !q.trim().isEmpty()) {
            String query = "%" + q.trim().toLowerCase() + "%";

            Disjunction or = Restrictions.disjunction();
            or.add(Restrictions.ilike("name", query));
            or.add(Restrictions.ilike("description", query));

            criteria.add(or);
        }

        criteria.setProjection(Projections.rowCount());

        Number count = (Number) criteria.uniqueResult();
        return count == null ? 0 : count.longValue();
    }

    @Override
    public void purgeReportCategory(ReportCategory category) {
        getSession().delete(category);
    }


    // =========================
// ReportLibrary DAO
// =========================

    @Override
    public ReportLibrary saveReportLibrary(ReportLibrary reportLibrary) {
        getSession().saveOrUpdate(reportLibrary);
        return reportLibrary;
    }

    @Override
    public ReportLibrary getReportLibraryById(Integer id) {
        return (ReportLibrary) getSession().get(ReportLibrary.class, id);
    }

    @Override
    public ReportLibrary getReportLibraryByUuid(String uuid) {
        Criteria c = getSession().createCriteria(ReportLibrary.class);
        c.add(Restrictions.eq("uuid", uuid));
        return (ReportLibrary) c.uniqueResult();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ReportLibrary> getReportLibraries(String q, boolean includeRetired, Integer startIndex, Integer limit) {
        Criteria c = getSession().createCriteria(ReportLibrary.class);

        if (!includeRetired) {
            c.add(Restrictions.eq("retired", false));
        }

        if (q != null && !q.trim().isEmpty()) {
            String query = "%" + q.trim().toLowerCase() + "%";
            Disjunction or = Restrictions.disjunction();
            or.add(Restrictions.ilike("name", query));
            or.add(Restrictions.ilike("description", query));
            or.add(Restrictions.ilike("code", query));
            c.add(or);
        }

        c.addOrder(Order.asc("name"));

        if (startIndex != null) {
            c.setFirstResult(startIndex);
        }

        if (limit != null) {
            c.setMaxResults(limit);
        }

        return c.list();
    }

    @Override
    public long getReportLibrariesCount(String q, boolean includeRetired) {
        Criteria c = getSession().createCriteria(ReportLibrary.class);

        if (!includeRetired) {
            c.add(Restrictions.eq("retired", false));
        }

        if (q != null && !q.trim().isEmpty()) {
            String query = "%" + q.trim().toLowerCase() + "%";
            Disjunction or = Restrictions.disjunction();
            or.add(Restrictions.ilike("name", query));
            or.add(Restrictions.ilike("description", query));
            or.add(Restrictions.ilike("code", query));
            c.add(or);
        }

        c.setProjection(Projections.rowCount());

        Number count = (Number) c.uniqueResult();
        return count == null ? 0 : count.longValue();
    }

    @Override
    public void purgeReportLibrary(ReportLibrary reportLibrary) {
        getSession().delete(reportLibrary);
    }
}
