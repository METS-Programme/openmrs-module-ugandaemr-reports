package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.common.DateUtil;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetRow;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportData;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.definition.service.ReportDefinitionService;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.convert.support.GenericConversionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + EvaluateReportDefinitionRestController.UGANDAEMRREPORTS + EvaluateReportDefinitionRestController.SET)
public class EvaluateReportDefinitionRestController {

    public static final String UGANDAEMRREPORTS = "/ugandaemrreports";
    public static final String SET = "/reportingDefinition";

    @Autowired
    public GenericConversionService conversionService;

    @Autowired
    public ReportService reportService;

    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    public Object getReportData(HttpServletRequest request, @RequestParam(value = "uuid") String reportDefinitionUuid, @RequestParam(required = false, value = "renderType") String renderType) {
        try {
            // Validate endDate if provided
            String endDateStr = request.getParameter("endDate");
            if (endDateStr != null && !endDateStr.trim().isEmpty() && !validateDateIsValidFormat(endDateStr)) {
                SimpleObject message = new SimpleObject();
                message.put("error", "given date " + endDateStr + " is not valid");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(message);
            }

            // 1) Evaluate report
            ReportDefinitionService reportDefinitionService = Context.getService(ReportDefinitionService.class);
            ReportDefinition reportDefinition = reportDefinitionService.getDefinitionByUuid(reportDefinitionUuid);

            if (reportDefinition == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).contentType(MediaType.APPLICATION_JSON).body("{\"error\":\"ReportDefinition not found\"}");
            }

            EvaluationContext evaluationContext = new EvaluationContext();

            evaluationContext.setParameterValues(resolveParameterValues(request, reportDefinition));

            ReportData reportData = reportDefinitionService.evaluate(reportDefinition, evaluationContext);

            // 2) If no renderType -> return datasets (old behavior)
            if (renderType == null || renderType.trim().isEmpty()) {
                Map<String, List<SimpleObject>> out = new HashMap<String, List<SimpleObject>>();
                for (Map.Entry<String, DataSet> e : reportData.getDataSets().entrySet()) {
                    out.put(e.getKey(), convertDataSetToSimpleObject(e.getValue()));
                }

                return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.APPLICATION_JSON).body(out);
            }

            // 3) Find JSON design (same logic you used)
            List<ReportDesign> designs = reportService.getReportDesigns(reportDefinition, null, false);
            ReportDesign jsonDesign = designs.stream().filter(d -> "JSON".equals(d.getName())).findFirst().orElse(null);

            if (jsonDesign == null) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).contentType(MediaType.APPLICATION_JSON).body("{\"error\":\"No JSON design found\"}");
            }

            UgandaEMRReportsService ugandaEMRReportsService = Context.getService(UgandaEMRReportsService.class);

            // 4) Render based on renderType
            if ("html".equalsIgnoreCase(renderType)) {
                String rendered = ugandaEMRReportsService.buildRenderedOutput(reportData, jsonDesign, null);
                return ResponseEntity.status(HttpStatus.OK)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(rendered);
            }

            if ("json".equalsIgnoreCase(renderType)) {
                Date endDate = null;
                if (endDateStr != null && !endDateStr.trim().isEmpty()) {
                    endDate = new SimpleDateFormat("yyyy-MM-dd").parse(endDateStr);
                }

                // if endDate provided -> final payload (with period), else preview payload
                String payload = (endDate != null) ? ugandaEMRReportsService.buildFinalPayloadJson(reportData, jsonDesign, "json", endDate) : ugandaEMRReportsService.buildPayloadJson(reportData, jsonDesign, "json");

                return ResponseEntity.status(HttpStatus.OK).contentType(MediaType.APPLICATION_JSON).body(payload);
            }

            // default
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body("{\"error\":\"Unsupported renderType. Use json or html\"}");

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).contentType(MediaType.APPLICATION_JSON).body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private Map<String, Object> resolveParameterValues(HttpServletRequest request, ReportDefinition rd) {
        Map<String, Object> vals = new HashMap<String, Object>();
        List<String> missing = new ArrayList<String>();

        for (Parameter p : rd.getParameters()) {
            String name = p.getName();
            String submitted = request.getParameter(name);

            // collection params not supported (same as your old code)
            if (p.getCollectionType() != null) {
                throw new IllegalStateException("Collection parameter not supported yet: " + name);
            }

            Object converted = null;
            boolean hasValue = submitted != null && !submitted.trim().isEmpty();

            if (!hasValue) {
                converted = p.getDefaultValue();
            } else {
                converted = convertParameterValue(submitted.trim(), p.getType());
            }

            // Required param handling
            if (converted == null && p.getDefaultValue() == null) {
                missing.add(name);
            }

            vals.put(name, converted);
        }

        if (!missing.isEmpty()) {
            throw new IllegalArgumentException("Missing required parameters: " + missing);
        }

        return vals;
    }

    private Object convertParameterValue(String submitted, Class<?> targetType) {
        if (submitted == null) return null;

        // Handle Date explicitly first (most common pain point)
        if (java.util.Date.class.isAssignableFrom(targetType)) {
            Date d = tryParseDate(submitted);
            if (d != null) return d;

            // last attempt: reporting DateUtil (expects yyyy-MM-dd)
            try {
                return DateUtil.parseYmd(submitted);
            } catch (Exception ignore) {
                return null;
            }
        }

        // Normal path: Spring conversionService
        try {
            Object converted = conversionService.convert(submitted, targetType);
            if (converted != null) return converted;
        } catch (Exception ignore) {
            // fall through
        }

        // Extra fallbacks for common primitives
        try {
            if (Integer.class.equals(targetType) || int.class.equals(targetType)) return Integer.valueOf(submitted);
            if (Long.class.equals(targetType) || long.class.equals(targetType)) return Long.valueOf(submitted);
            if (Double.class.equals(targetType) || double.class.equals(targetType)) return Double.valueOf(submitted);
            if (Boolean.class.equals(targetType) || boolean.class.equals(targetType)) return Boolean.valueOf(submitted);
            if (String.class.equals(targetType)) return submitted;
        } catch (Exception ignore) {
            return null;
        }

        return null;
    }

    private Date tryParseDate(String value) {
        // Prefer yyyy-MM-dd first (OpenMRS standard)
        List<String> patterns = Arrays.asList(
                "yyyy-MM-dd",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "dd/MM/yyyy",
                "MM/dd/yyyy"
        );

        for (String pattern : patterns) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat(pattern);
                sdf.setLenient(false);
                return sdf.parse(value);
            } catch (ParseException ignored) { }
        }
        return null;
    }

    private boolean validateDateIsValidFormat(String date) {
        try {
            DateUtil.parseYmd(date);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }

    private List<SimpleObject> convertDataSetToSimpleObject(DataSet d) {
        List<SimpleObject> rows = new ArrayList<SimpleObject>();
        if (d == null) return rows;

        Iterator it = d.iterator();
        while (it.hasNext()) {
            DataSetRow r = (DataSetRow) it.next();
            SimpleObject so = new SimpleObject();
            for (String key : r.getColumnValuesByKey().keySet()) {
                Object v = r.getColumnValue(key);
                so.add(key, v == null ? "" : v);
            }
            rows.add(so);
        }
        return rows;
    }
}