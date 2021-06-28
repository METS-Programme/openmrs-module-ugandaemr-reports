package org.openmrs.module.ugandaemrreports.definition.dataset.definition;


import org.openmrs.Program;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.definition.configuration.ConfigurationProperty;

import java.util.List;

/**
 */
public class UgandaEMRMobileDatasetDefinition extends PatientDataSetDefinition {

    private static final long serialVersionUID = 6405683324151111487L;


    @ConfigurationProperty
    private List<Program> programs;

    public List<Program> getPrograms() {
        return programs;
    }

    public void setPrograms(List<Program> programs) {
        this.programs = programs;
    }
}