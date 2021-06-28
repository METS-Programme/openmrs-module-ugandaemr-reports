package org.openmrs.module.ugandaemrreports.definition.dataset.evaluator;

import org.apache.commons.lang.time.StopWatch;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Cohort;
import org.openmrs.annotation.Handler;
import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.cohort.CohortUtil;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.service.CohortDefinitionService;
import org.openmrs.module.reporting.common.ObjectUtil;
import org.openmrs.module.reporting.data.DataUtil;
import org.openmrs.module.reporting.data.MappedData;
import org.openmrs.module.reporting.data.patient.EvaluatedPatientData;
import org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition;
import org.openmrs.module.reporting.data.patient.service.PatientDataService;
import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.DataSetColumn;
import org.openmrs.module.reporting.dataset.SimpleDataSet;
import org.openmrs.module.reporting.dataset.column.definition.RowPerObjectColumnDefinition;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.evaluator.DataSetEvaluator;
import org.openmrs.module.reporting.definition.DefinitionUtil;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.CurrentlyInProgramCohortDefinition;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.UgandaEMRMobileDatasetDefinition;
import org.openmrs.module.ugandaemrreports.library.DataFactory;

import org.springframework.beans.factory.annotation.Autowired;



/**
 */
@Handler(supports = {UgandaEMRMobileDatasetDefinition.class},order = 1)
public class UgandaEMRMobileDatasetDefinitionEvaluator implements DataSetEvaluator {

    protected Log log = LogFactory.getLog(this.getClass());

    @Autowired
    private DataFactory df;


    /**
     * Public constructor
     */
    public UgandaEMRMobileDatasetDefinitionEvaluator() {
    }

    /**
     * @see DataSetEvaluator#evaluate(DataSetDefinition, EvaluationContext)
     */
    @SuppressWarnings("unchecked")
    public DataSet evaluate(DataSetDefinition dataSetDefinition, EvaluationContext context) throws EvaluationException {

        UgandaEMRMobileDatasetDefinition dsd = (UgandaEMRMobileDatasetDefinition) dataSetDefinition;
        context = ObjectUtil.nvl(context, new EvaluationContext());

        SimpleDataSet dataSet = new SimpleDataSet(dsd, context);
        dataSet.setSortCriteria(dsd.getSortCriteria());


        Cohort c = context.getBaseCohort();

        // getting cohorts based on the program passed
        if(dsd.getPrograms()!=null&& dsd!=null){
            CurrentlyInProgramCohortDefinition cd = new CurrentlyInProgramCohortDefinition();
            cd.setPrograms(dsd.getPrograms());

            c  = Context.getService(CohortDefinitionService.class).evaluate(df.convert(cd, ObjectUtil.toMap("onOrAfter=startDate,onOrBefore=endDate")), context);

        }
        // Construct a new EvaluationContext based on the passed filters

        if (dsd.getRowFilters() != null) {
            for (Mapped<? extends CohortDefinition> q : dsd.getRowFilters()) {
                Cohort s = Context.getService(CohortDefinitionService.class).evaluate(q, context);
                c = CohortUtil.intersectNonNull(c, s);
            }
        }


        EvaluationContext ec = context.shallowCopy();
        if (!CohortUtil.areEqual(ec.getBaseCohort(), c)) {
            ec.setBaseCohort(c);
        }

        // Evaluate each specified ColumnDefinition for all of the included rows and add these to the dataset
        for (RowPerObjectColumnDefinition cd : dsd.getColumnDefinitions()) {

            if (log.isDebugEnabled()) {
                log.debug("Evaluating column: " + cd.getName());
                log.debug("With Data Definition: " + DefinitionUtil.format(cd.getDataDefinition().getParameterizable()));
                log.debug("With Mappings: " + cd.getDataDefinition().getParameterMappings());
                log.debug("With Parameters: " + ec.getParameterValues());
            }
            StopWatch sw = new StopWatch();
            sw.start();

            MappedData<? extends PatientDataDefinition> dataDef = (MappedData<? extends PatientDataDefinition>) cd.getDataDefinition();
            EvaluatedPatientData data = Context.getService(PatientDataService.class).evaluate(dataDef, ec);

            for (Integer id : c.getMemberIds()) {
                for (DataSetColumn column : cd.getDataSetColumns()) {
                    Object val = data.getData().get(id);
                    val = DataUtil.convertData(val, dataDef.getConverters());
                    dataSet.addColumnValue(id, column, val);
                }
            }

            sw.stop();
            if (log.isDebugEnabled()) {
                log.debug("Evaluated column. Duration: " + sw.toString());
            }
        }




        return dataSet;
    }

}