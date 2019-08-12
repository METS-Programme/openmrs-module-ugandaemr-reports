package org.openmrs.module.ugandaemrreports.definition.cohort.evaluator;

import org.openmrs.Cohort;
import org.openmrs.PatientProgram;
import org.openmrs.annotation.Handler;
import org.openmrs.module.reporting.cohort.EvaluatedCohort;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.InProgramCohortDefinition;
import org.openmrs.module.reporting.cohort.definition.evaluator.CohortDefinitionEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.querybuilder.HqlQueryBuilder;
import org.openmrs.module.reporting.evaluation.service.EvaluationService;
import org.openmrs.module.ugandaemrreports.definition.cohort.definition.CurrentlyInProgramCohortDefinition;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;
import java.util.List;

/**
 *  The implementation in this class was copied from the the InProgramCohortEvaluator,
 *  to cater for DSDM where the patients complete a program on the same day that they start a new one,
 *  therefore during the changeover date they are in actually in 2 programs on the same day.
 *
 * The change is in the last filter from whereGreaterEqualOrNull to whereGreaterOrNull
 * so that the last program the patient was enrolled in is ignored
 */
@Handler(supports={CurrentlyInProgramCohortDefinition.class},order = 1)
public class CurrentlyInProgramCohortEvaluator implements CohortDefinitionEvaluator {

    @Autowired
    EvaluationService evaluationService;

    /**
     * @see org.openmrs.module.reporting.cohort.definition.evaluator.CohortDefinitionEvaluator#evaluate(org.openmrs.module.reporting.cohort.definition.CohortDefinition, org.openmrs.module.reporting.evaluation.EvaluationContext)
     * @should return patients enrolled in the given programs on or before the given date
     * @should return patients enrolled in the given programs on or after the given date
     * @should find patients in a program on the onOrBefore date if passed in time is at midnight
     */
    public EvaluatedCohort evaluate(CohortDefinition cohortDefinition, EvaluationContext context) {
        InProgramCohortDefinition cd = (InProgramCohortDefinition) cohortDefinition;

        Date onOrAfter = cd.getOnDate() != null ? cd.getOnDate() : cd.getOnOrAfter();
        Date onOrBefore = cd.getOnDate() != null ? cd.getOnDate() : cd.getOnOrBefore();

        // By default, return patients who are actively enrolled "now" if no other date constraints are given
        if (onOrAfter == null && onOrBefore == null) {
            onOrAfter = context.getEvaluationDate();
            onOrBefore = context.getEvaluationDate();
        }

        HqlQueryBuilder q = new HqlQueryBuilder();
        q.select("distinct pp.patient.patientId");
        q.from(PatientProgram.class, "pp");
        q.wherePatientIn("pp.patient.patientId", context);
        q.whereEqual("pp.patient.voided", false);
        q.whereIn("pp.program", cd.getPrograms());
        q.whereIn("pp.location", cd.getLocations());
        q.whereLessOrEqualTo("pp.dateEnrolled", onOrBefore);
        q.whereGreaterOrNull("pp.dateCompleted", onOrAfter);

        List<Integer> pIds = evaluationService.evaluateToList(q, Integer.class, context);
        return new EvaluatedCohort(new Cohort(pIds), cd, context);
    }

}
