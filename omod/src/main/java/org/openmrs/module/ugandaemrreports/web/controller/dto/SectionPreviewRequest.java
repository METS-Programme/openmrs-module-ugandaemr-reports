package org.openmrs.module.ugandaemrreports.web.controller.dto;

import java.util.HashMap;
import java.util.Map;

/**
 * Request DTO for section indicator preview.
 *
 * POST /ws/rest/v1/mambasection/{uuid}/preview
 * Body: { indicatorUuid, params, maxRows }
 */
public class SectionPreviewRequest {

    private String indicatorUuid;
    private Map<String, Object> params = new HashMap<>();
    private Integer maxRows;

    public SectionPreviewRequest() {
    }

    public String getIndicatorUuid() {
        return indicatorUuid;
    }

    public void setIndicatorUuid(String indicatorUuid) {
        this.indicatorUuid = indicatorUuid;
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public void setParams(Map<String, Object> params) {
        this.params = params;
    }

    public Integer getMaxRows() {
        return maxRows;
    }

    public void setMaxRows(Integer maxRows) {
        this.maxRows = maxRows;
    }
}
