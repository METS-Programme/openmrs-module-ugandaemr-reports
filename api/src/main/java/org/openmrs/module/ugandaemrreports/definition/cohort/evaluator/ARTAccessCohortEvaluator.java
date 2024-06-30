package org.openmrs.module.ugandaemrreports.definition.cohort.evaluator;

import org.openmrs.Cohort;
import org.openmrs.annotation.Handler;
import org.openmrs.module.reporting.cohort.EvaluatedCohort;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.evaluator.CohortDefinitionEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.querybuilder.SqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.ARTAccessCohortDefinition;
import org.openmrs.module.ugandaemrreports.metadata.HIVMetadata;
import org.springframework.beans.factory.annotation.Autowired;


/**
 */
@Handler(supports = {ARTAccessCohortDefinition.class})
public class ARTAccessCohortEvaluator implements CohortDefinitionEvaluator {

    @Autowired
    EvaluationService evaluationService;

    @Autowired
    HIVMetadata hivMetadata;

    @Override
    public EvaluatedCohort evaluate(CohortDefinition cohortDefinition, EvaluationContext context)
            throws EvaluationException {

        ARTAccessCohortDefinition cd = (ARTAccessCohortDefinition) cohortDefinition;

        SqlQueryBuilder q = new SqlQueryBuilder();
        String query = "select patient_id from cohort_member cm inner join cohort c on cm.cohort_id = c.cohort_id inner join cohort_type ct on c.cohort_type_id=ct.cohort_type_id and ct.uuid='e50fa0af-df36-4a26-853f-feb05244e5ca' where cm.voided=0";
        q.append(query);
        Cohort c = new Cohort(evaluationService.evaluateToList(q, Integer.class, context));
        return new EvaluatedCohort(c, cd, context);

    }
}
