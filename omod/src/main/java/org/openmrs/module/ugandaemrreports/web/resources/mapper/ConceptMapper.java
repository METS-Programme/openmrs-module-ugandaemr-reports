package org.openmrs.module.ugandaemrreports.web.resources.mapper;

public class ConceptMapper {
    String conceptName;
    String uuid;
    String conceptId;

    String type;

    public String getConceptName() {
        return conceptName;
    }

    public String getUuid() {
        return uuid;
    }

    public String getConceptId() {
        return conceptId;
    }

    public void setConceptName(String conceptName) {
        this.conceptName = conceptName;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public void setConceptId(String conceptId) {
        this.conceptId = conceptId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
