package org.openmrs.module.ugandaemrreports.tasks;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemrreports.api.UgandaEMRReportsService;
import org.openmrs.scheduler.tasks.AbstractTask;


public class SetupMambaTask extends AbstractTask {
    Log log = LogFactory.getLog(SetupMambaTask.class);

    @Override
    public void execute() {
        try {
            log.info("Mamba Flatten Started");
            Context.getService(UgandaEMRReportsService.class).addMambaetlProperties();
            Context.getService(UgandaEMRReportsService.class).setupMambaETL();
            log.info("Mamba Setup Completed");
        }
        catch (Exception e) {
            log.error(e.fillInStackTrace());
        }
    }

}