package org.openmrs.module.ugandaemrreports.definition.dataset.evaluator;

import com.google.common.base.Joiner;
import org.openmrs.annotation.Handler;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.dataset.SimpleDataSet;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.evaluator.DataSetEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.querybuilder.SqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.ugandaemrreports.common.PatientDataHelper;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.ARTAccessDatasetDefinition;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.*;
import java.util.stream.Collectors;


/**
 */
@Handler(supports = {ARTAccessDatasetDefinition.class})
public class ARTAccessDatasetDefinitionEvaluator implements DataSetEvaluator {

    @Autowired
    EvaluationService evaluationService;

    PatientDataHelper pdh = new PatientDataHelper();

    @Override
    public DataSet evaluate(DataSetDefinition dataSetDefinition, EvaluationContext context) throws EvaluationException {

        ARTAccessDatasetDefinition definition = (ARTAccessDatasetDefinition) dataSetDefinition;


        SimpleDataSet dataSet = new SimpleDataSet(dataSetDefinition, context);

        String startDate = DateUtil.formatDate(definition.getStartDate(), "yyyy-MM-dd");
        String endDate = DateUtil.formatDate(definition.getEndDate(), "yyyy-MM-dd");

        startDate = startDate+" 00:00:00";
        endDate = endDate+" 23:59:59";
        context = ObjectUtil.nvl(context, new EvaluationContext());

        String dataQuery = "Select encounter_id,pi.identifier,obs.concept_id,cn.name,value_datetime,value_numeric,value_text,obs_datetime,A.name as PharmacyName,A.start_date as Date_of_Enrollment from obs LEFT JOIN concept_name cn ON value_coded = cn.concept_id and cn.concept_name_type='FULLY_SPECIFIED'\n" +
                " INNER JOIN patient_identifier pi ON person_id = pi.patient_id inner join patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id and pit.uuid='e1731641-30ab-102d-86b0-7a5022ba4115' " +
                "INNER JOIN (SELECT patient_id,c.name,cm.start_date from cohort_member cm inner join cohort c on cm.cohort_id = c.cohort_id \n" +
                "    inner join cohort_type ct on c.cohort_type_id=ct.cohort_type_id and ct.uuid='e50fa0af-df36-4a26-853f-feb05244e5ca') A  on person_id = A.patient_id \n"+
                "where encounter_id in (select encounter_id from encounter inner join encounter_type et on encounter.encounter_type = et.encounter_type_id\n" +
                "   and et.uuid='8d5b2be0-c2cc-11de-8d13-0010c6dffd0f' inner join visit v on encounter.visit_id = v.visit_id inner join\n" +
                "    visit_type vt on v.visit_type_id = vt.visit_type_id and vt.uuid='2ce24f40-8f4c-4bfa-8fde-09d475783468' inner join\n" +
                "    location l on encounter.location_id = l.location_id and l.uuid='3ec8ff90-3ec1-408e-bf8c-22e4553d6e17'\n" +
                String.format("        where encounter.voided=0 and encounter_datetime between '%s' and '%s') and obs.voided=0 order by encounter_id,person_id;",startDate,endDate);

        SqlQueryBuilder q = new SqlQueryBuilder();
        q.append(dataQuery);
        List<Object[]> results = evaluationService.evaluateToList(q, context);

        if(results.size()>0 && !results.isEmpty()) {
            Set<Object> encounterSet = new HashSet<>();
            for (Object[] object : results) {
                if (String.valueOf(object[0]) != null) {
                    encounterSet.add(object[0]);
                }
            }

            for (Object encounterId:encounterSet) {
                List<Object[]> encounterObs = results.stream().filter(Object -> Object[0].equals(encounterId)).collect(Collectors.toList());
               dataSet.addRow(addObsDataForPatient(encounterObs));
            }

        }
        return dataSet;
    }

    private DataSetRow addObsDataForPatient(List<Object[]> objects){
        List<Integer> conceptsQuestionsInEncounter = objects.stream().map(Object->Integer.valueOf(String.valueOf(Object[2]))).collect(Collectors.toList());
        DataSetRow row = new DataSetRow();
        final int returnVisitDate =5096;
        final int pills =99038;
        final int days =99036;
        final int regimen =90315;
        final int complaints =90227;
        final int other_drugs =99035;
        final int adherence =90221;
        for(Object[] r : objects){
            int conceptId = Integer.valueOf(String.valueOf(r[2]));
            switch(conceptId) {
                case returnVisitDate:
                    pdh.addCol(row, "return_visit_date", r[4]); //return visit date
                    break;
                case pills:
                    pdh.addCol(row, "quantity", r[5]); //no of pills
                    break;
                case days:
                    pdh.addCol(row, "days", r[5]); //no of days
                    break;
                case regimen:
                    pdh.addCol(row, "drug", r[3]); //Regimen
                    break;
                case complaints:
                    pdh.addCol(row, "complaints", r[3]); // complaints
                    break;
                case other_drugs:
                    pdh.addCol(row, "other_drugs", r[6]); // other_drugs
                    break;
                case adherence:
                    pdh.addCol(row, "adherence", r[3]); // adherence
                    break;
            }
        }
        Object[] r = objects.get(0);
        pdh.addCol(row, "date", r[7]); //return visit date
        pdh.addCol(row, "Patient_ID", r[1]); //return visit date

        if(!conceptsQuestionsInEncounter.contains(returnVisitDate)){
            pdh.addCol(row, "return_visit_date", null); //return visit date
        }
        if(!conceptsQuestionsInEncounter.contains(pills)){
            pdh.addCol(row, "quantity", null); //no of pills
        }
        if(!conceptsQuestionsInEncounter.contains(days)){
            pdh.addCol(row, "days", null); //no of days
        }
        if(!conceptsQuestionsInEncounter.contains(regimen)){
            pdh.addCol(row, "drug", null); //Regimen
        }
        if(!conceptsQuestionsInEncounter.contains(complaints)){
            pdh.addCol(row, "complaints", null); // complaints
        }else{
            int frequency  =Collections.frequency(conceptsQuestionsInEncounter, complaints);
            if(frequency>1) {
                String complaintsStrings = Joiner.on(",").join(objects.stream().filter(Object -> Integer.valueOf(String.valueOf(Object[2])) == complaints)
                        .map(Object ->Object[3]).collect(Collectors.toList()));
                pdh.addCol(row, "complaints", complaintsStrings); // complaints
            }
        }
        if(!conceptsQuestionsInEncounter.contains(other_drugs)){
            pdh.addCol(row, "other_drugs", null); // other_drugs
        }
        if(!conceptsQuestionsInEncounter.contains(adherence)){
            pdh.addCol(row, "adherence", null); // adherence
        }

        pdh.addCol(row, "RefillPoint", r[8]);
        pdh.addCol(row, "Date of Enrollment", r[9]);
        return row;
    }
}
