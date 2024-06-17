package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.Cohort;
import org.openmrs.Concept;
import org.openmrs.PatientIdentifierType;
import org.openmrs.PersonAttributeType;
import org.openmrs.api.APIAuthenticationException;
import org.openmrs.api.ConceptService;
import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.cohort.EvaluatedCohort;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.service.CohortDefinitionService;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.common.ReflectionUtil;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.dataset.SimpleDataSet;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.definition.service.ReportDefinitionService;
import org.openmrs.module.reportingcompatibility.reporting.export.DataExportUtil;
import org.openmrs.module.ugandaemrreports.web.resources.mapper.Column;
import org.openmrs.module.ugandaemrreports.web.resources.mapper.DataExportMapper;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.reporting.ReportObjectService;
import org.openmrs.reporting.export.DataExportReportObject;
import org.openmrs.util.ReportingcompatibilityUtil;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + DataExportRestController.UGANDAEMRREPORTS + DataExportRestController.DATA_DEFINITION)

public class DataExportRestController {
    public static final String UGANDAEMRREPORTS = "/ugandaemrreports";
    public static final String DATA_DEFINITION = "/dataExport";


    @ExceptionHandler(APIAuthenticationException.class)
    @RequestMapping(method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public Object evaluate(@RequestBody DataExportMapper payload, RequestContext requestContext) {

        org.openmrs.module.ugandaemrreports.web.resources.mapper.Cohort reportCohort = payload.getCohort();
        List<Column> columnList = payload.getColumns();

        EvaluationContext context = new EvaluationContext();
        SimpleDataSet dataSet = new SimpleDataSet(new PatientDataSetDefinition(), context);
        Cohort baseCohort = new Cohort();
        if (reportCohort.getUuid() != null && !columnList.isEmpty()) {
            try {
                ReportDefinitionService service = Context.getService(ReportDefinitionService.class);
                ReportDefinition rd = service.getDefinitionByUuid(reportCohort.getUuid());

                if (rd != null) {
                    Mapped<? extends CohortDefinition> cd = rd.getBaseCohortDefinition();

                    if (cd != null) {

                        List<Map<String, Object>> parameters = reportCohort.getParameters();

                        Map<String, Object> cohortParameters = getParameters(parameters);
                        ReflectionUtil.setPropertyValue(cd, "startDate", cohortParameters.get("startDate"));
                        ReflectionUtil.setPropertyValue(cd, "endDate", cohortParameters.get("endDate"));

                        context.setParameterValues(cohortParameters);

                        EvaluatedCohort evaluatedCohort = Context.getService(CohortDefinitionService.class).evaluate(cd, context);
                        baseCohort.setMemberIds(evaluatedCohort.getMemberIds());

                        DataExportReportObject exportReportObject = new DataExportReportObject();
                        List<Integer> patientIds = new ArrayList<Integer>();
                        patientIds.addAll(baseCohort.getMemberIds());
                        exportReportObject.setPatientIds(patientIds);
                        addColumnsToDataExportObject(columnList, exportReportObject);
                        exportReportObject.setName(reportCohort.getName());
                        context.setParameterValues(cohortParameters);

//                        exportReportObject.addSimpleColumn("Conditions", "$!{fn.getPatientConditionStatus('117399')}");


                        ReportObjectService rs = (ReportObjectService) Context.getService(ReportObjectService.class);
                        rs.saveReportObject(exportReportObject);
                        DataExportUtil.generateExport(exportReportObject, ReportingcompatibilityUtil.convert(baseCohort) , null);

                        File file = DataExportUtil.getGeneratedFile(exportReportObject);

                        String s = new SimpleDateFormat("yyyyMMdd_Hm").format(new Date(file.lastModified()));
                        String filename = exportReportObject.getName().replace(" ", "_") + "-" + s + ".xls";
//

                        return ResponseEntity.ok()
                                .header(HttpHeaders.CONTENT_TYPE, "application/vnd.ms-excel")
                                .header(HttpHeaders.PRAGMA, "no-cache")
                                .header(HttpHeaders.CONTENT_DISPOSITION,
                                        "attachment; filename="+ filename);

                    } else {
                        return new ResponseEntity<Object>(" No base cohort for this report", HttpStatus.INTERNAL_SERVER_ERROR);
                    }


                }

            } catch (Exception e) {
                return new ResponseEntity<Object>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);

            }
        }
        List<SimpleObject> traceReportData = new ArrayList<SimpleObject>();
        traceReportData.addAll(convertDataSetToSimpleObject(dataSet));
        return new ResponseEntity<>(traceReportData, HttpStatus.OK);

    }

    private Map<String, Object> getParameters(List<Map<String, Object>> list) {

        Map<String, Object> parameterValues = new HashMap<String, Object>();
        if (!list.isEmpty()) {
            for (Map<String, Object> objectMap : list) {
                Iterator<String> keys = objectMap.keySet().iterator();
                while (keys.hasNext()) {
                    String key = keys.next();
                    String mapValue = (String) objectMap.get(key);
                    parameterValues.put(key, DateUtil.parseYmd(mapValue));
                }
            }
        }

        return parameterValues;
    }





    private void addColumnsToDataExportObject(List<Column> columnList, DataExportReportObject dataExportReportObject) {

        for (Column column : columnList) {
            String expression = column.getExpression();
            String type = column.getType();
            String column_label = column.getLabel();

            if (isExpressionAConcept(expression)) {
                Concept concept = Context.getConceptService().getConceptByUuid(expression);
               dataExportReportObject.addConceptColumn(column_label,DataExportReportObject.MODIFIER_LAST,null,concept.getId().toString(),null);
            } else {
                if (type.equals("PatientIdentifier")) {
                    PatientIdentifierType patientIdentifierType = Context.getPatientService().getPatientIdentifierTypeByUuid(expression);
                    dataExportReportObject.addSimpleColumn(column_label, "$!{fn.getPatientIdentifier('"+patientIdentifierType.getId() +"')}");

                } else if (type.equals("PersonName")) {
                    dataExportReportObject.addSimpleColumn(column_label, "$!{fn.getPatientAttr('PersonName', '"+expression+"')}");

                } else if (type.equals("PersonAttribute")) {
                    PersonAttributeType personAttributeType = Context.getPersonService().getPersonAttributeTypeByUuid(expression);
                    dataExportReportObject.addSimpleColumn(column_label, "$!{fn.getPersonAttribute('"+personAttributeType.getName() +"')}");
                }else if (type.equals("Demographics")) {
                    if(expression.equals("Age")) {
                        dataExportReportObject.addSimpleColumn(column_label, "$!{fn.calculateAge($fn.getPatientAttr('Person', 'birthdate'))}");
                    }else {
                        dataExportReportObject.addSimpleColumn(column_label, "$!{fn.getPatientAttr('Person', '" + expression + "')}");
                    }
                } else if (type.equals("Address")) {
                    dataExportReportObject.addSimpleColumn(column_label, "$!{fn.getPatientAttr('PersonAddress', '" + expression + "')}");                }
            }

        }
    }

    public List<SimpleObject> convertDataSetToSimpleObject(DataSet d) {
        Iterator iterator = d.iterator();

        List<SimpleObject> dataList = new ArrayList<SimpleObject>();
        while (iterator.hasNext()) {
            DataSetRow r = (DataSetRow) iterator.next();
            Map<String, Object> columns = r.getColumnValuesByKey();
            Set<String> keys = columns.keySet();
            SimpleObject details = new SimpleObject();

            for (String key : keys) {
                details.add(key, r.getColumnValue(key));
            }
            dataList.add(details);

        }
        return dataList;
    }

    private boolean isExpressionAConcept(String conceptUuid) {
        boolean isConcept = false;
        ConceptService conceptService = Context.getConceptService();
        Concept concept = conceptService.getConceptByUuid(conceptUuid);
        if (concept != null) {
            isConcept = true;
        }
        return isConcept;
    }

}
