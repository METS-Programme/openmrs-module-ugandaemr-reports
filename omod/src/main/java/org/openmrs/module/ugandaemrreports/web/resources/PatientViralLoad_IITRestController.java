package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.APIAuthenticationException;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.querybuilder.SqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * End point will handle iit patient information
 */
@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + PatientViralLoad_IITRestController.UGANDAEMRREPORTS + PatientViralLoad_IITRestController.DATA_SET)
public class PatientViralLoad_IITRestController {
    public static final String UGANDAEMRREPORTS = "/ugandaemrreports";
    public static final String DATA_SET = "/iit";

    @Autowired
    EvaluationService evaluationService;

    @ExceptionHandler(APIAuthenticationException.class)
    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    public Object getPatientData(@RequestParam(required = true, value = "id") String id) {

        try {
            int patient_no = Integer.parseInt(id);
            return getPatientIITInformation(patient_no);
        } catch (NumberFormatException e) {
            return  getPatientIITInformation(id);
        }
    }

    private SimpleObject getPatientIITInformation(String patientId) {
        String query = "SELECT * from mamba_fact_patients_interruptions_details where case_id = '" + patientId + "'";
        EvaluationContext context = new EvaluationContext();
        Object[] data = getEtlData(query, context);
        if(data !=null)
           return convertObject(data);
        else return null;
    }

    private SimpleObject getPatientIITInformation(int patientId) {
        String query = "SELECT * from mamba_fact_patients_interruptions_details where client_id = " + patientId;
        EvaluationContext context = new EvaluationContext();
        Object[] data = getEtlData(query, context);
        if(data !=null)
            return convertObject(data);
        else return null;
    }

    private Object[] getEtlData(String q, EvaluationContext context) {
        SqlQueryBuilder query = new SqlQueryBuilder();
        query.append(q);
        List<Object[]> results = evaluationService.evaluateToList(query, context);
        return results.stream().findFirst().orElse(null);
    }

    public SimpleObject convertObject(Object[] result) {

       SimpleObject simpleObject = new SimpleObject();
       simpleObject.put("client_id", result[1]);
       simpleObject.put("case_id", result[2]);
       simpleObject.put("art_enrollment_date", result[3]);
       simpleObject.put("days_since_initiation", result[4]);
       simpleObject.put("last_dispense_date", result[5]);
       simpleObject.put("last_dispense_amount", result[6]);
       simpleObject.put("current_regimen_start_date", result[7]);
       simpleObject.put("last_vl_result", result[8]);
       simpleObject.put("vl_last_date", result[9]);
       simpleObject.put("last_dispense_description", result[10]);
       simpleObject.put("all_interruptions", result[11]);
       simpleObject.put("iit_in_last_12months", result[12]);
       simpleObject.put("longest_iit_ever", result[13]);
       simpleObject.put("last_iit_duration", result[14]);
       simpleObject.put("last_encounter_interruption_date", result[15]);


        return simpleObject;
    }
}