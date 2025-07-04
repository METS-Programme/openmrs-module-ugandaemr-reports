package org.openmrs.module.ugandaemrreports.definition.data.evaluator;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Obs;
import org.openmrs.annotation.Handler;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.common.ListMap;
import org.openmrs.module.reporting.common.TimeQualifier;
import org.openmrs.module.reporting.data.patient.EvaluatedPatientData;
import org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition;
import org.openmrs.module.reporting.data.patient.evaluator.PatientDataEvaluator;
import org.openmrs.module.reporting.data.person.EvaluatedPersonData;
import org.openmrs.module.reporting.data.person.definition.PersonDataDefinition;
import org.openmrs.module.reporting.data.person.evaluator.PersonDataEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.querybuilder.SqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.ugandaemrreports.definition.data.definition.SMSTemplatePatientDataDefinition;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Handler(supports = {SMSTemplatePatientDataDefinition.class})
public class SMSTemplatePatientDataEvaluator implements PatientDataEvaluator {
    protected static final Log log = LogFactory.getLog(SMSTemplatePatientDataEvaluator.class);

    @Autowired
    EvaluationService evaluationService;

    public EvaluatedPatientData evaluate(PatientDataDefinition definition, EvaluationContext context) throws EvaluationException {

        SMSTemplatePatientDataDefinition def = (SMSTemplatePatientDataDefinition) definition;

        EvaluatedPatientData c = new EvaluatedPatientData(def, context);

        if (context.getBaseCohort() != null && context.getBaseCohort().isEmpty()) {
            return c;
        }

        String startDate = DateUtil.formatDate(def.getStartDate(), "yyyy-MM-dd");
        String endDate = DateUtil.formatDate(def.getEndDate(), "yyyy-MM-dd");

        //Get SMS Template from global property
        String gpQuery = "SELECT property_value FROM global_property WHERE property ='ugandaemr.SMSTemplate'";

        SqlQueryBuilder q1 = new SqlQueryBuilder();
        q1.append(gpQuery);
        List<String> queryResult = this.evaluationService.evaluateToList(q1,String.class, context);

        String template = queryResult.get(0);



        String query = String.format("SELECT o.person_id,pn.given_name, DATE(o.value_datetime) from obs o inner join encounter e on o.encounter_id = e.encounter_id\n" +
                "    inner  join encounter_type et on e.encounter_type = et.encounter_type_id inner join person_name pn on o.person_id=pn.person_id\n" +
                "where o.concept_id=5096 and et.uuid='8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' and o.value_datetime >='%s' and o.value_datetime<='%s' order by o.obs_datetime DESC", startDate, endDate);


        SqlQueryBuilder q = new SqlQueryBuilder(query);

        List<Object[]> results = evaluationService.evaluateToList(q, context);

        Map<Integer,Object> finalMap = new HashMap<Integer, Object>();

        for (Object[] row : results) {
            String name = (String) row[1];
            Date date = (Date)row[2];

            String person_template =template.replace("<name>",name);
            person_template =person_template.replace("<date>",DateUtil.formatDate(date, "yyyy-MM-dd"));
//            String person_template = String.format(template, name,date);
            finalMap.put((Integer) row[0],person_template);

        }
        if(finalMap.entrySet().size()>0){
            c.setData(finalMap);
        }



        return c;
    }

}