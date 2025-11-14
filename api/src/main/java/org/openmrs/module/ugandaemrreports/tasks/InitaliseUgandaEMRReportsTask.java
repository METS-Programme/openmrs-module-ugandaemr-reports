package org.openmrs.module.ugandaemrreports.tasks;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandaemrreports.activator.AppConfigInitializer;
import org.openmrs.module.ugandaemrreports.activator.Initializer;
import org.openmrs.module.ugandaemrreports.activator.ReportInitializer;
import org.openmrs.scheduler.tasks.AbstractTask;

import java.util.ArrayList;
import java.util.List;

public class InitaliseUgandaEMRReportsTask extends AbstractTask {
    Log log = LogFactory.getLog(InitaliseUgandaEMRReportsTask.class);

    @Override
    public void execute() {

        log.info("UgandaEMR Reports module started - initializing...");

        try {
            Context.getService(FlattenDatabaseService.class).setupEtl();
            for (Initializer initializer : getInitializers()) {
                initializer.started();
            }
        } catch (Exception e) {
            log.error("Error starting UgandaEMR Reports module", e);
        }

    }

    public List<Initializer> getInitializers() {
        List<Initializer> l = new ArrayList<Initializer>();
        l.add(new AppConfigInitializer());
        l.add(new ReportInitializer());
        return l;
    }
}
