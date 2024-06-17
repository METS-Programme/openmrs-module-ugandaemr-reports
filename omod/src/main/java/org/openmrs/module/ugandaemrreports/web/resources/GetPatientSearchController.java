package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.APIAuthenticationException;
import org.openmrs.api.context.Context;
import org.openmrs.cohort.CohortDefinitionItemHolder;
import org.openmrs.cohort.impl.PatientSearchCohortDefinitionProvider;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reportingcompatibility.service.CohortService;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.reporting.AbstractReportObject;
import org.openmrs.reporting.PatientSearch;
import org.openmrs.reporting.PatientSearchReportObject;
import org.openmrs.reporting.ReportObjectWrapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.lang.reflect.Field;
import java.util.*;

/**
 * End point will handle dataSet evaluation passed
 */
@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + GetPatientSearchController.UGANDAEMRREPORTS + GetPatientSearchController.DATA_SET)
public class GetPatientSearchController {
    public static final String UGANDAEMRREPORTS = "/ugandaemrreports";
    public static final String DATA_SET = "/patientsearch";

    @ExceptionHandler(APIAuthenticationException.class)
    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Object> getAll() {
        List<ReportObjectWrapper> reports = Context.getService(UgandaEMRReportsService.class).getPatientSearches("Patient Search");

        List<SimpleObject> objects = convertDataSetToSimpleObject(reports);
        return new ResponseEntity<>(objects, HttpStatus.OK);
    }

    public List<SimpleObject> convertDataSetToSimpleObject(List<ReportObjectWrapper> list) {


        List<SimpleObject> dataList = new ArrayList<SimpleObject>();
        for (ReportObjectWrapper p : list) {
            String name= p.getName();
            String uuid = p.getUuid();
            int id =p.getId();
            String description = p.getDescription();
            SimpleObject details = new SimpleObject();

            details.add("name",name);
            details.add("uuid",uuid);
            details.add("id",id);
            details.add("description",description);

            dataList.add(details);

        }
        return dataList;
    }

}