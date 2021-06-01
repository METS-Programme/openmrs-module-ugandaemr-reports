package org.openmrs.module.ugandaemrreports.definition.dataset.evaluator;

import org.joda.time.LocalDate;
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
import org.openmrs.module.ugandaemrreports.common.StubDate;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.TB009DatasetDefinition;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.List;

@Handler(supports = {TB009DatasetDefinition.class })
public class TB009DatasetDefinitionEvaluator implements DataSetEvaluator {

	@Autowired
	private EvaluationService evaluationService;
	
	@Override
	public DataSet evaluate(DataSetDefinition dataSetDefinition, EvaluationContext context) throws EvaluationException {
		SimpleDataSet dataSet = new SimpleDataSet(dataSetDefinition, context);
		TB009DatasetDefinition definition = (TB009DatasetDefinition) dataSetDefinition;
				
		String startDate = DateUtil.formatDate(definition.getStartDate(), "yyyy-MM-dd");
		String endDate = DateUtil.formatDate(definition.getEndDate(), "yyyy-MM-dd");


		
		context = ObjectUtil.nvl(context, new EvaluationContext());	

		String summarySql = "SELECT A.patient_id patient_id, A.encounter_datetime\tAS doa,\n" +
				"\t\t\t DISTRICT.value_text As District_No,\n" +
				"\t\t\t UNIT.value_text As Unit_No,\n" +
				"\t\t\t NIN.identifier\tAS NIN_no,\n" +
				"\t\t\t PN.family_name,\n" +
				"\t\t\t PN.given_name,\n" +
				"\t\t\t NEXT_OF_KIN.value_text AS NEXT_OF_KIN,\n" +
				"\t\t\t NEXT_OF_KIN_CONTACT.value_text AS NEXT_OF_KIN_CONTACT,\n" +
				"\t\t\t P.gender AS SEX,\n" +
				"\t\t\t YEAR(A.encounter_datetime) - YEAR(P.birthdate) - (RIGHT(A.encounter_datetime, 5) < RIGHT(P.birthdate, 5)) \tAS age,\n" +
				"             CATEGORY.value as Client_Category,\n" +
				"\t\t\t IFNULL(PA.address5,'')\tAS village,\n" +
				"\t\t\t IFNULL(PA.address4,'')\tAS Parish,\n" +
				"\t\t\t IFNULL(PA.address3,'')\tAS SubCounty,\n" +
				"\t\t\t IFNULL(PA.county_district,'')\tAS District,\n" +
				"             DISEASE_CLASS.name AS disease_classification,\n" +
				"             1stLineSatrtDate.value_datetime AS DATE_STARTED_1ST_LINE,\n" +
				"             1ST_REGIMEN.name AS DRUG_1ST_LINE,\n" +
				"             PATIENT_TYPE.name AS patient_type,\n" +
				"             RISK_GROUP.name AS Risk_Group,\n" +
				"             PRE_RX_SMEAR.value_datetime AS Smear_date_taken,\n" +
				"             PRE_RX_SMEAR.name AS Smear_Results,\n" +
				"             PRE_RX_GENE.value_datetime AS Genexpert_date_taken,\n" +
				"             PRE_RX_GENE.name AS Genexpert_Results,\n" +
				"             PRE_RX_OTHER.value_datetime AS Other_date_taken,\n" +
				"             PRE_RX_OTHER.value_text AS Other_Results,\n" +
				"             MONTH_2_TEST.value_coded AS Month_2_Results,\n" +
				"             MONTH_2_TEST.value_datetime AS Month_2_date,\n" +
				"             MONTH_5_TEST.value_coded AS Month_5_Results,\n" +
				"             MONTH_5_TEST.value_datetime AS Month_5_date,\n" +
				"             MONTH_6_TEST.value_coded AS Month_6_Results,\n" +
				"             MONTH_6_TEST.value_datetime AS Month_6_date,\n" +
				"             WEIGHT.weight as weight,\n" +
				"             HEIGHT.height as bmi,\n" +
				"             MUAC.muac ,\n" +
				"             MUACCODE.muac_code,\n" +
				"             ZSCORE.score,\n" +
				"             NUTRITION_STATUS.status,\n" +
				"             NUTRITION.support,\n" +
				"             INR.INRNo, \n" +
				"			  TRANSFER_IN.value_text AS transferred_in_from,\n" +
				"             TRANSFER_IN_TB_NO.value_text AS transfer_in_Unit_TB_No,\n" +
				"             REFFERAL_TYPE.name AS refferal,\n" +
				"             REFFERAL_DATE.value_datetime AS refferal_Date" +
				"             from (SELECT\t    e.encounter_id,\n" +
				"\t\t\t    e.patient_id,\n" +
				"\t\t\t    e.encounter_datetime\n" +
				"\t\t\t  FROM   encounter e\n" +
				"\t\t\t  INNER JOIN encounter_type et ON et.encounter_type_id = e.encounter_type AND et.uuid = '334bf97e-28e2-4a27-8727-a5ce31c7cd66'\n" +
	String.format(			"\t\t              WHERE e.encounter_datetime between '%s' and '%s') A\n",startDate,endDate) +
				"INNER JOIN person P\n" +
				"\t\t\t   ON (P.person_id = A.patient_id)\n" +
				"\t\t\t LEFT JOIN person_name PN ON (P.person_id = PN.person_id)\n" +
				"\t\t\t LEFT JOIN person_address PA ON (P.person_id = PA.person_id AND PA.preferred = 1 AND PA.voided = 0)\n" +
				"\t\t\t LEFT JOIN person_attribute PAT ON (P.person_id = PAT.person_id AND PAT.person_attribute_type_id = 8 AND PAT.voided = 0)\n" +
				"\t\t\t LEFT JOIN (select patient_id,identifier from patient_identifier PI inner join patient_identifier_type pit on\n" +
				"\t\t\t     PI.identifier_type = pit.patient_identifier_type_id where pit.uuid='f0c16a6d-dc5f-4118-a803-616d0075d282' and PI.voided=0)NIN  ON P.person_id = NIN.patient_id\n" +
				"             LEFT JOIN obs DISTRICT ON DISTRICT.encounter_id = A.encounter_id AND DISTRICT.concept_id = 99031 AND DISTRICT.voided = 0\n" +
				"             LEFT JOIN obs UNIT ON UNIT.encounter_id = A.encounter_id AND UNIT.concept_id = 165826 AND UNIT.voided = 0\n" +
				"             LEFT JOIN obs NEXT_OF_KIN ON NEXT_OF_KIN.encounter_id = A.encounter_id AND NEXT_OF_KIN.concept_id = 162729 AND NEXT_OF_KIN.voided = 0\n" +
				"             LEFT JOIN obs NEXT_OF_KIN_CONTACT ON NEXT_OF_KIN_CONTACT.encounter_id = A.encounter_id AND NEXT_OF_KIN_CONTACT.concept_id = 165052 AND NEXT_OF_KIN_CONTACT.voided = 0\n" +
				"             LEFT JOIN (select person_id,cn.name as value from  person_attribute PA inner join person_attribute_type PAT  on PA.person_attribute_type_id = PAT.person_attribute_type_id INNER JOIN\n" +
				"                 concept_name cn ON cn.concept_id=PA.value and PAT.uuid='dec484be-1c43-416a-9ad0-18bd9ef28929' and PA.voided=0) CATEGORY ON P.person_id = CATEGORY.person_id\n" +
				"             LEFT JOIN (SELECT\n" +
				"\t\t\t\to.encounter_id, cn.name\n" +
				"\t\t\t     FROM obs o\n" +
				"\t\t\t     INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 99379 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) DISEASE_CLASS ON DISEASE_CLASS.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN obs 1stLineSatrtDate ON 1stLineSatrtDate.encounter_id = A.encounter_id AND 1stLineSatrtDate.concept_id = 165838 AND 1stLineSatrtDate.voided = 0\n" +
				"             LEFT JOIN  (SELECT\n" +
				"\t\t\t\to.encounter_id, cn.name\n" +
				"\t\t\t     FROM obs o\n" +
				"\t\t\t     INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 159958 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) 1ST_REGIMEN ON 1ST_REGIMEN.encounter_id = A.encounter_id\n" +
				"\t\t\t LEFT JOIN  (SELECT\n" +
				"\t\t\t\to.encounter_id, cn.name\n" +
				"\t\t\t     FROM obs o\n" +
				"\t\t\t     INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 99386 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) PATIENT_TYPE ON PATIENT_TYPE.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN  (SELECT\n" +
				"\t\t\t\to.encounter_id, cn.name\n" +
				"\t\t\t     FROM obs o\n" +
				"\t\t\t     INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 165169 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) RISK_GROUP ON RISK_GROUP.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN  (SELECT p.encounter_id, date_taken.value_datetime,cn.name from obs p inner join obs results on p.encounter_id=results.encounter_id\n" +
				"                    INNER JOIN obs date_taken on p.obs_group_id= date_taken.obs_group_id\n" +
				"                    INNER JOIN concept_name cn\n" +
				"                        ON results.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                        where p.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165846  and o.voided=0)\n" +
				"                        and p.concept_id=165844 and p.value_coded=90225 and results.concept_id=90225\n" +
				"                          and date_taken.concept_id=164431 and date_taken.voided=0 and results.value_coded is not null group by p.encounter_id)PRE_RX_SMEAR on PRE_RX_SMEAR.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN  (SELECT p.encounter_id, date_taken.value_datetime,cn.name from obs p inner join obs results on p.encounter_id=results.encounter_id\n" +
				"                    INNER JOIN obs date_taken on p.obs_group_id= date_taken.obs_group_id\n" +
				"                    INNER JOIN concept_name cn\n" +
				"                        ON results.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                        where p.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165846  and o.voided=0)\n" +
				"                        and p.concept_id=165844 and p.value_coded=165413 and results.concept_id=162202\n" +
				"                          and date_taken.concept_id=164431 and date_taken.voided=0 and results.value_coded is not null group by p.encounter_id)PRE_RX_GENE on PRE_RX_GENE.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN  (SELECT p.encounter_id, date_taken.value_datetime,results.value_text from obs p inner join obs results on p.encounter_id=results.encounter_id\n" +
				"                    INNER JOIN obs date_taken on p.obs_group_id= date_taken.obs_group_id\n" +
				"                        where p.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165846  and o.voided=0)\n" +
				"                        and p.concept_id=165844 and p.value_coded=90002 and results.concept_id=99291\n" +
				"                          and date_taken.concept_id=164431 and date_taken.voided=0 and results.value_coded is not null group by p.encounter_id)PRE_RX_OTHER on PRE_RX_OTHER.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,date_taken.value_datetime,cn.name value_coded from obs o join obs test on o.encounter_id = test.encounter_id  INNER JOIN obs date_taken on o.obs_group_id= date_taken.obs_group_id\n" +
				"                 join encounter e2 on o.encounter_id = e2.encounter_id INNER JOIN concept_name cn ON test.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED'\n" +
				"                      AND cn.voided = 0 WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 99292  and o.voided=0)\n" +
	String.format(			"                    and date_taken.concept_id= 164431 and date_taken.voided=0 and test.concept_id=90225 and test.voided=0 AND e2.encounter_datetime between DATE_ADD('%s',INTERVAL 2 MONTH)\n",startDate) +
	String.format(			"                    AND DATE_ADD('%s',INTERVAL 2 MONTH) group by o.encounter_id order by encounter_datetime DESC) MONTH_2_TEST ON MONTH_2_TEST.person_id = A.patient_id\n",endDate) +
				"             LEFT JOIN (SELECT o.person_id,date_taken.value_datetime,cn.name value_coded from obs o join obs test on o.encounter_id = test.encounter_id  INNER JOIN obs date_taken on o.obs_group_id= date_taken.obs_group_id\n" +
				"                 join encounter e2 on o.encounter_id = e2.encounter_id INNER JOIN concept_name cn ON test.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED'\n" +
				"                      AND cn.voided = 0 WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 99292  and o.voided=0)\n" +
	String.format(			"                    and date_taken.concept_id= 164431 and date_taken.voided=0 and test.concept_id=90225 and test.voided=0 AND e2.encounter_datetime between DATE_ADD('%s',INTERVAL 5 MONTH)\n",startDate) +
	String.format(			"                    AND DATE_ADD('%s',INTERVAL 5 MONTH) group by o.encounter_id order by encounter_datetime DESC) MONTH_5_TEST ON MONTH_5_TEST.person_id = A.patient_id\n",endDate) +
				"\t\t\t LEFT JOIN (SELECT o.person_id,date_taken.value_datetime,cn.name value_coded from obs o join obs test on o.encounter_id = test.encounter_id  INNER JOIN obs date_taken on o.obs_group_id= date_taken.obs_group_id\n" +
				"                 join encounter e2 on o.encounter_id = e2.encounter_id INNER JOIN concept_name cn ON test.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED'\n" +
				"                      AND cn.voided = 0 WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 99292  and o.voided=0)\n" +
	String.format(			"                    and date_taken.concept_id= 164431 and date_taken.voided=0 and test.concept_id=90225 and test.voided=0 AND e2.encounter_datetime between DATE_ADD('%s',INTERVAL 6 MONTH)\n",startDate) +
	String.format(			"                    AND DATE_ADD('%s',INTERVAL 6 MONTH) group by o.encounter_id order by encounter_datetime DESC) MONTH_6_TEST ON MONTH_6_TEST.person_id = A.patient_id\n",endDate) +
				"             LEFT JOIN (SELECT o.person_id,value_numeric weight, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=5089\n" +
				"                 group by o.person_id order by encounter_datetime ASC  ) WEIGHT ON WEIGHT.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,value_numeric height, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=5090\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) HEIGHT ON HEIGHT.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,value_numeric muac, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=1343\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) MUAC ON MUAC.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,cn.name muac_code, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=99030\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) MUACCODE ON MUACCODE.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,cn.name score, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=99800\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) ZSCORE ON ZSCORE.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,cn.name status, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=165050\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) NUTRITION_STATUS ON NUTRITION_STATUS.person_id = A.patient_id\n" +
				"\t\t\t LEFT JOIN (SELECT o.person_id,cn.name support, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=99054\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) NUTRITION ON NUTRITION.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,value_numeric INRNo, min(encounter_datetime) from obs o join encounter e2 on o.encounter_id = e2.encounter_id\n" +
				"                 inner  join encounter_type t on e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' AND o.voided = 0 WHERE o.concept_id=99733\n" +
				"                 group by o.person_id order by encounter_datetime ASC ) INR ON INR.person_id = A.patient_id " +
                " LEFT JOIN (SELECT o.encounter_id,value_text FROM obs o  WHERE o.concept_id = 90211 AND o.voided = 0 GROUP BY o.encounter_id )TRANSFER_IN ON TRANSFER_IN.encounter_id = A.encounter_id\n" +
                "                            LEFT JOIN (SELECT o.encounter_id,value_text FROM obs o  WHERE o.concept_id = 165826 AND o.voided = 0 GROUP BY o.encounter_id )TRANSFER_IN_TB_NO ON TRANSFER_IN_TB_NO.encounter_id = A.encounter_id\n" +
                "                            LEFT JOIN (SELECT o.encounter_id, cn.name FROM obs o INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 165855 AND o.voided = 0\n" +
                "\t\t\t\t                 GROUP BY o.encounter_id ) REFFERAL_TYPE ON REFFERAL_TYPE.encounter_id = A.encounter_id\n" +
                "                            LEFT JOIN (SELECT o.encounter_id,value_datetime FROM obs o  WHERE o.concept_id = 166160 AND o.voided = 0 GROUP BY o.encounter_id ) REFFERAL_DATE ON REFFERAL_DATE.encounter_id = A.encounter_id\n"+
				"             INNER JOIN (SELECT patient_id,cn.name outcome, date_completed outcome_date from patient_program pp inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741'\n" +
				"               LEFT JOIN concept_name cn ON pp.outcome_concept_id = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 where pp.date_enrolled between\n" +
				String.format(		"\t\t\t    '%s' and '%s' group by patient_id ) PROGRAM on PROGRAM.patient_id = A.patient_id\n",startDate,endDate);

		String ecounterAndProgranQuery = "SELECT   A.patient_id patient_id,\n" +
				"             HIVSTATUS.status as  HIVSTATUS,\n" +
				"             HIVSTATUSDATE.value_datetime as HIVSTATUSDATE,\n" +
				"             CPTDATE.value_datetime as CPT_DATE,\n" +
				"             CPT.status as CPPT_STATUS,\n" +
				"             ART_STATUS.status as ART_STATUS,\n" +
				"             ARTSTARTDATE.value_datetime as ARTSTART_DATE,\n" +
				"             ARTNO.value_text as ART_NO,\n" +
				"             TREATMENTMODEL.status as TREATMENT_MODEL,\n" +
				"             WEEK1_2.encounter_datetime AS  WEEK1_2DATE,\n" +
				"             WEEK1_2.value_numeric AS  WEEK1_2DAYS,\n" +
				"             WEEK3_4.encounter_datetime AS  WEEK3_4DATE,\n" +
				"             WEEK3_4.value_numeric AS  WEEK3_4DAYS,\n" +
				"             WEEK5_6.encounter_datetime AS  WEEK5_6DATE,\n" +
				"             WEEK5_6.value_numeric AS  WEEK5_6DAYS,\n" +
				"             WEEK7_8.encounter_datetime AS  WEEK7_8DATE,\n" +
				"             WEEK7_8.value_numeric AS  WEEK7_8DAYS,\n" +
				"             MONTH_3.encounter_datetime AS  MONTH_3DATE,\n" +
				"             MONTH_3.value_numeric AS  MONTH_3DAYS,\n" +
				"             MONTH_4.encounter_datetime AS  MONTH_4DATE,\n" +
				"             MONTH_4.value_numeric AS  MONTH_4DAYS,\n" +
				"             MONTH_5.encounter_datetime AS  MONTH_5DATE,\n" +
				"             MONTH_5.value_numeric AS  MONTH_5DAYS,\n" +
				"             MONTH_6.encounter_datetime AS  MONTH_6DATE,\n" +
				"             MONTH_6.value_numeric AS  MONTH_6DAYS,\n" +
				"             MONTH_7.encounter_datetime AS  MONTH_7DATE,\n" +
				"             MONTH_7.value_numeric AS  MONTH_7DAYS,\n" +
				"             MONTH_8.encounter_datetime AS  MONTH_8DATE,\n" +
				"             MONTH_8.value_numeric AS  MONTH_8DAYS,\n" +
				"             MONTH_9.encounter_datetime AS  MONTH_9DATE,\n" +
				"             MONTH_9.value_numeric AS  MONTH_9DAYS,\n" +
				"             MONTH_10.encounter_datetime AS  MONTH_10DATE,\n" +
				"             MONTH_10.value_numeric AS  MONTH_10DAYS,\n" +
				"             MONTH_11.encounter_datetime AS  MONTH_11DATE,\n" +
				"             MONTH_11.value_numeric AS  MONTH_11DAYS,\n" +
				"             MONTH_12.encounter_datetime AS  MONTH_12DATE,\n" +
				"             MONTH_12.value_numeric AS  MONTH_12DAYS,\n" +
				"             T_OUT_DATE.value_datetime as Transfer_out_Date,\n" +
				"             T_OUT_HF.value_text as Transfer_out_Facility,\n" +
				"             T_OUT_DISTRICT.value_text as District,\n" +
				"             T_OUT_TEL.value_text as TO_TEL,\n" +
				"             PROGRAM.outcome as Outcome,\n" +
				"             PROGRAM.outcome_date as Outcome_Date,\n" +
				"\t\t\t DRTB.name AS diagnosed_with_DRTB,\n" +
				"             DRTB_DATE.value_datetime AS date_diagnosed_with_DRTB,\n" +
				"             STARTED_DRTB.value_coded as STARTED_ON_DR_TREATMENT,\n" +
				"             STARTED_DRTB_DATE.value_datetime as DATE_STARTED_ON_DR_TREATMENT,\n" +
				"             DRTB_no.value_text as DRTBNO\n" +
				"             from (SELECT\t    e.encounter_id,\n" +
				"\t\t\t    e.patient_id,\n" +
				"\t\t\t    e.encounter_datetime\n" +
				"\t\t\t  FROM   encounter e\n" +
				"\t\t\t  INNER JOIN encounter_type et ON et.encounter_type_id = e.encounter_type AND et.uuid = '334bf97e-28e2-4a27-8727-a5ce31c7cd66'\n" +
		String.format(			"\t\t              WHERE e.encounter_datetime between '%s' and '%s') A\n",startDate,endDate)+
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,cn.name status from obs o  INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id=165396\n" +
				"                 and o.voided=0 group by encounter_id ) HIVSTATUS ON HIVSTATUS.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,value_datetime from obs o WHERE o.concept_id=164431 and o.voided=0 group by encounter_id) HIVSTATUSDATE ON HIVSTATUSDATE.encounter_id= A.encounter_id\n" +
				"\t\t     LEFT JOIN (SELECT o.person_id,o.encounter_id,value_datetime from obs o WHERE o.concept_id=165881 and o.voided=0 group by encounter_id) CPTDATE ON CPTDATE.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,cn.name status from obs o INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                  WHERE o.concept_id=166070 AND o.voided = 0 group by encounter_id) CPT ON CPT.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,cn.name status from obs o INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0\n" +
				"                  WHERE o.concept_id=1358 AND o.voided = 0 group by encounter_id) ART_STATUS ON ART_STATUS.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,value_datetime from obs o WHERE o.concept_id=99161 and o.voided=0 group by encounter_id) ARTSTARTDATE ON ARTSTARTDATE.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,value_text from obs o WHERE o.concept_id=99431 and o.voided=0 group by encounter_id) ARTNO ON ARTNO.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,o.encounter_id,cn.name status from obs o  INNER  JOIN concept_name cn\n" +
				"                        ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id=165869\n" +
				"                 and o.voided=0 group by encounter_id ) TREATMENTMODEL ON TREATMENTMODEL.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                 inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 1 WEEK)\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 2 WEEK) group by o.obs_group_id order by encounter_datetime DESC limit 1) WEEK1_2 ON WEEK1_2.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                 inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 3 WEEK)\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 4 WEEK) group by o.obs_group_id order by encounter_datetime DESC limit 1) WEEK3_4 ON WEEK3_4.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                 inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 5 WEEK)\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 6 WEEK) group by o.obs_group_id order by encounter_datetime DESC limit 1) WEEK5_6 ON WEEK5_6.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                 inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 7 WEEK)\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 8 WEEK) group by o.obs_group_id order by encounter_datetime DESC limit 1) WEEK7_8 ON WEEK7_8.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 3 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 3 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_3 ON MONTH_3.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 4 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 4 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_4 ON MONTH_4.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 5 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 5 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_5 ON MONTH_5.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 6 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 6 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_6 ON MONTH_6.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 7 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 7 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_7 ON MONTH_7.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 8 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 8 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_8 ON MONTH_8.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 9 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 9 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_9 ON MONTH_9.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 10 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 10 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_10 ON MONTH_10.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 11 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 11 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_11 ON MONTH_11.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT o.person_id,encounter_datetime, days.value_numeric from encounter e2 INNER JOIN obs days on e2.encounter_id = days.encounter_id join obs o on o.encounter_id=e2.encounter_id\n" +
				"                    inner  join encounter_type t on  e2.encounter_type = t.encounter_type_id and t.uuid='455bad1f-5e97-4ee9-9558-ff1df8808732' inner join patient_program pp on e2.patient_id = pp.patient_id " +
				" 					 inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741' \n" +
				String.format("                    WHERE o.obs_group_id in (SELECT obs_id from obs o  where o.concept_id= 165305  and o.voided=0) and days.obs_group_id=o.obs_group_id and pp.date_enrolled between '%s' and '%s'\n",startDate,endDate) +
				"                    and days.concept_id= 159368 and days.voided=0 AND e2.encounter_datetime between DATE_ADD(pp.date_enrolled,INTERVAL 12 MONTH )\n" +
				"                    AND DATE_ADD(pp.date_enrolled,INTERVAL 12 MONTH) group by o.obs_group_id order by encounter_datetime DESC limit 1) MONTH_12 ON MONTH_12.person_id = A.patient_id\n" +
				"             LEFT JOIN (SELECT person_id, value_datetime,encounter_id from obs where concept_id=165854 and obs_group_id in (SELECT obs_group_id from obs groupid where concept_id=165855 and value_coded=160036 and voided=0) and voided=0  order by obs_group_id limit 1)T_OUT_DATE on T_OUT_DATE.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT person_id, value_text,encounter_id from obs where concept_id=90211 and obs_group_id in (SELECT obs_group_id from obs groupid where concept_id=165855 and value_coded=160036 and voided=0) and voided=0  order by obs_group_id limit 1)T_OUT_HF on T_OUT_HF.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT person_id, value_text,encounter_id from obs where concept_id=165853 and obs_group_id in (SELECT obs_group_id from obs groupid where concept_id=165855 and value_coded=160036 and voided=0) and voided=0  order by obs_group_id limit 1)T_OUT_DISTRICT on T_OUT_DISTRICT.encounter_id= A.encounter_id\n" +
				"             LEFT JOIN (SELECT person_id, value_text,encounter_id from obs where concept_id=159635 and obs_group_id in (SELECT obs_group_id from obs groupid where concept_id=165855 and value_coded=160036 and voided=0) and voided=0  order by obs_group_id limit 1)T_OUT_TEL on T_OUT_TEL.encounter_id= A.encounter_id\n" +
				"             INNER JOIN (SELECT patient_id,cn.name outcome, date_completed outcome_date from patient_program pp inner join program p on pp.program_id = p.program_id and p.uuid='9dc21a72-0971-11e7-8037-507b9dc4c741'\n" +
				"               LEFT JOIN concept_name cn ON pp.outcome_concept_id = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 where pp.date_enrolled between\n" +
		String.format(		"\t\t\t    '%s' and '%s' group by patient_id ) PROGRAM on PROGRAM.patient_id = A.patient_id\n",startDate,endDate) +
				"             LEFT JOIN (SELECT o.encounter_id, cn.name FROM obs o INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en' AND cn.concept_name_type = 'FULLY_SPECIFIED' AND cn.voided = 0 WHERE o.concept_id = 90216 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) DRTB ON DRTB.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.encounter_id,value_datetime FROM obs o  WHERE o.concept_id = 165840 AND o.voided = 0 GROUP BY o.encounter_id ) DRTB_DATE ON DRTB_DATE.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.encounter_id, o.value_coded FROM obs o  WHERE o.concept_id = 165842 AND o.voided = 0\n" +
				"\t\t\t     GROUP BY o.encounter_id ) STARTED_DRTB ON STARTED_DRTB.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.encounter_id,value_datetime FROM obs o  WHERE o.concept_id = 165841 AND o.voided = 0 GROUP BY o.encounter_id ) STARTED_DRTB_DATE ON STARTED_DRTB_DATE.encounter_id = A.encounter_id\n" +
				"             LEFT JOIN (SELECT o.encounter_id,value_text FROM obs o  WHERE o.concept_id = 165843 AND o.voided = 0 GROUP BY o.encounter_id ) DRTB_no ON DRTB_no.encounter_id = A.encounter_id\n";



		//Logger.getLogger(TBDatasetDefinition.class).info(summarySql);
		SqlQueryBuilder q = new SqlQueryBuilder(summarySql);
		SqlQueryBuilder encounterQuery = new SqlQueryBuilder(ecounterAndProgranQuery);

		List<Object[]> results = evaluationService.evaluateToList(q, context);
		List<Object[]> results1 = evaluationService.evaluateToList(encounterQuery, context);

		List<EncounterObject> encounterObjects = convert(results1);
		PatientDataHelper pdh = new PatientDataHelper();

		for (Object[] r : results) {
			DataSetRow row = new DataSetRow();

			pdh.addCol(row, "patientid",r[0]);
			pdh.addCol(row, "DOA", r[1]);
			pdh.addCol(row, "District No", r[2]);
			pdh.addCol(row, "Unit_No", r[3]);
			pdh.addCol(row, "NIN_no", r[4]);
			pdh.addCol(row, "Family_name", r[5]);
			pdh.addCol(row, "Given_name", r[6]);
			pdh.addCol(row, "Next_of_Kin", r[7]);
			pdh.addCol(row, "Next_of_kin_Contacts", r[8]);
			pdh.addCol(row, "Sex", r[9]);
			pdh.addCol(row, "Age", r[10]);
			pdh.addCol(row, "Client_category", r[11]);
			pdh.addCol(row, "Village", r[12]);
			pdh.addCol(row, "Parish", r[13]);
			pdh.addCol(row, "Sub county", r[14]);
			pdh.addCol(row, "District", r[15]);
			pdh.addCol(row, "Disease Classification", r[16]);
			pdh.addCol(row, "1st line start date", r[17]);
			pdh.addCol(row, "1st line drug", r[18]);
			pdh.addCol(row, "patient type", r[19]);
			pdh.addCol(row, "risk group", r[20]);
			pdh.addCol(row, "smear date taken", r[21]);
			pdh.addCol(row, "smear results", r[22]);
			pdh.addCol(row, "GeneXpert date taken", r[23]);
			pdh.addCol(row, "GeneXpert results", r[24]);
			pdh.addCol(row, "Other test date taken", r[25]);
			pdh.addCol(row, "Other test Results", r[26]);
			pdh.addCol(row, "Month 2 results", r[27]);
			pdh.addCol(row, "Month 2 date", r[28]);
			pdh.addCol(row, "Month 5 results", r[29]);
			pdh.addCol(row, "Month5date", r[30]);
			pdh.addCol(row, "Month 6 results", r[31]);
			pdh.addCol(row, "Month 6 date", r[32]);
			pdh.addCol(row, "weight", r[33]);
			pdh.addCol(row, "bmi", r[34]);
			pdh.addCol(row, "muac", r[35]);
			pdh.addCol(row, "muac code", r[36]);
			pdh.addCol(row, "z score", r[37]);
			pdh.addCol(row, "nutrition status", r[38]);
			pdh.addCol(row, "nutrition support", r[39]);
			pdh.addCol(row, "INR No", r[40]);
			pdh.addCol(row, "Transfer_From", r[41]);
			pdh.addCol(row, "Transfer_Tb_No", r[42]);
			pdh.addCol(row, "Referral_From", r[43]);
			pdh.addCol(row, "Referral_Date", r[44]);

			if(encounterObjects !=null){
			EncounterObject enc= encounterObjects.stream().filter(p->r[0].equals(p.var1)).findAny().orElse(null);
			if(enc!=null) {
				pdh.addCol(row, "hiv status", enc.var2);
				pdh.addCol(row, "hiv status date", enc.var3);
				pdh.addCol(row, "cpt date", enc.var4);
				pdh.addCol(row, "cpt status", enc.var5);
				pdh.addCol(row, "ART status", enc.var6);
				pdh.addCol(row, "ART start Date", enc.var7);
				pdh.addCol(row, "ART No", enc.var8);
				pdh.addCol(row, "Treatment Model", enc.var9);
				pdh.addCol(row, "Week 1 date",enc.var10);
				pdh.addCol(row, "Week 1 days", enc.var11);
				pdh.addCol(row, "Week 3 date", enc.var12);
				pdh.addCol(row, "Week 3 days", enc.var13);
				pdh.addCol(row, "Week 5 date", enc.var14);
				pdh.addCol(row, "Week 5 days", enc.var15);
				pdh.addCol(row, "Week 7 date", enc.var16);
				pdh.addCol(row, "Week 7 days", enc.var17);
				pdh.addCol(row, "Month 3 date", enc.var18);
				pdh.addCol(row, "Month 3 days", enc.var19);
				pdh.addCol(row, "Month 4 date", enc.var20);
				pdh.addCol(row, "Month 4 days", enc.var21);
				pdh.addCol(row, "Month 5 date", enc.var22);
				pdh.addCol(row, "Month 5 days", enc.var23);
				pdh.addCol(row, "Month 6 date", enc.var24);
				pdh.addCol(row, "Month 6 days", enc.var25);
				pdh.addCol(row, "Month 7 date", enc.var26);
				pdh.addCol(row, "Month 7 days", enc.var27);
				pdh.addCol(row, "Month 8 date", enc.var28);
				pdh.addCol(row, "Month 8 days", enc.var29);
				pdh.addCol(row, "Month 9 date", enc.var30);
				pdh.addCol(row, "Month 9 days", enc.var31);
				pdh.addCol(row, "Month 10 date", enc.var32);
				pdh.addCol(row, "Month 10 days", enc.var33);
				pdh.addCol(row, "Month 11 date", enc.var34);
				pdh.addCol(row, "Month 11 days", enc.var35);
				pdh.addCol(row, "Month 12 date", enc.var36);
				pdh.addCol(row, "Month 12 days", enc.var37);
				pdh.addCol(row, "Transfer out date", enc.var38);
				pdh.addCol(row, "Transfer out Facility", enc.var39);
				pdh.addCol(row, "Transfer out District", enc.var40);
				pdh.addCol(row, "Transfer out Tel", enc.var41);
				pdh.addCol(row, "outcome results", enc.var42);
				pdh.addCol(row, "outcome date", enc.var43);
				pdh.addCol(row, "DR diagnosed", enc.var44);
				pdh.addCol(row, "DR diagnosed date", enc.var45);
			if(enc.var46 !=null &&Integer.valueOf(String.valueOf(enc.var46))==1){
				pdh.addCol(row, "startedOn2ndLine", 'Y');
			}else{
				pdh.addCol(row, "startedOn2ndLine", "");
			}
				pdh.addCol(row, "startedOn2ndLine date", enc.var47);
				pdh.addCol(row, "DRTBNO", enc.var48);


			}
			}
			dataSet.addRow(row);
		}


		return dataSet;
		
	}

	public List<EncounterObject> convert(List<Object[]> results){
		List<EncounterObject> list = new ArrayList<>();
		for (Object[] r:results) {
			EncounterObject encounterObject = new EncounterObject(r[0],r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],
					r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],
					r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],
					r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47]);
		list.add(encounterObject);
		}
		return list;
	}

	class EncounterObject{
		Object var1;
		Object var2;
		Object var3;
		Object var4;
		Object var5;
		Object var6;
		Object var7;
		Object var8;
		Object var9;
		Object var10;
		Object var11;
		Object var12;
		Object var13;
		Object var14;
		Object var15;
		Object var16;
		Object var17;
		Object var18;
		Object var19;
		Object var20;
		Object var21;
		Object var22;
		Object var23;
		Object var24;
		Object var25;
		Object var26;
		Object var27;
		Object var28;
		Object var29;
		Object var30;
		Object var31;
		Object var32;
		Object var33;
		Object var34;
		Object var35;
		Object var36;
		Object var37;
		Object var38;
		Object var39;
		Object var40;
		Object var41;
		Object var42;
		Object var43;
		Object var44;
		Object var45;
		Object var46;
		Object var47;
		Object var48;

		public EncounterObject() {
		}

		public EncounterObject(Object var1, Object var2, Object var3, Object var4, Object var5, Object var6, Object var7, Object var8, Object var9, Object var10, Object var11, Object var12, Object var13, Object var14, Object var15, Object var16, Object var17, Object var18, Object var19, Object var20, Object var21, Object var22, Object var23, Object var24, Object var25, Object var26, Object var27, Object var28, Object var29, Object var30, Object var31, Object var32, Object var33, Object var34, Object var35, Object var36, Object var37, Object var38, Object var39, Object var40, Object var41, Object var42, Object var43, Object var44, Object var45, Object var46, Object var47, Object var48) {
			this.var1 = var1;
			this.var2 = var2;
			this.var3 = var3;
			this.var4 = var4;
			this.var5 = var5;
			this.var6 = var6;
			this.var7 = var7;
			this.var8 = var8;
			this.var9 = var9;
			this.var10 = var10;
			this.var11 = var11;
			this.var12 = var12;
			this.var13 = var13;
			this.var14 = var14;
			this.var15 = var15;
			this.var16 = var16;
			this.var17 = var17;
			this.var18 = var18;
			this.var19 = var19;
			this.var20 = var20;
			this.var21 = var21;
			this.var22 = var22;
			this.var23 = var23;
			this.var24 = var24;
			this.var25 = var25;
			this.var26 = var26;
			this.var27 = var27;
			this.var28 = var28;
			this.var29 = var29;
			this.var30 = var30;
			this.var31 = var31;
			this.var32 = var32;
			this.var33 = var33;
			this.var34 = var34;
			this.var35 = var35;
			this.var36 = var36;
			this.var37 = var37;
			this.var38 = var38;
			this.var39 = var39;
			this.var40 = var40;
			this.var41 = var41;
			this.var42 = var42;
			this.var43 = var43;
			this.var44 = var44;
			this.var45 = var45;
			this.var46 = var46;
			this.var47 = var47;
			this.var48 = var48;
		}
	}
	
}
