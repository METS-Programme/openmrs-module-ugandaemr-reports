package org.openmrs.module.ugandaemrreports.web.controller.dto;

import java.util.ArrayList;
import java.util.List;

public class SqlPreviewResponse {

    private List<String> columns = new ArrayList<>();
    private List<List<Object>> rows = new ArrayList<>();
    private Integer rowCount = 0;
    private Boolean truncated = false;

    public SqlPreviewResponse() {
    }

    public SqlPreviewResponse(List<String> columns, List<List<Object>> rows, Integer rowCount, Boolean truncated) {
        this.columns = columns;
        this.rows = rows;
        this.rowCount = rowCount;
        this.truncated = truncated;
    }

    public List<String> getColumns() {
        return columns;
    }

    public void setColumns(List<String> columns) {
        this.columns = columns;
    }

    public List<List<Object>> getRows() {
        return rows;
    }

    public void setRows(List<List<Object>> rows) {
        this.rows = rows;
    }

    public Integer getRowCount() {
        return rowCount;
    }

    public void setRowCount(Integer rowCount) {
        this.rowCount = rowCount;
    }

    public Boolean getTruncated() {
        return truncated;
    }

    public void setTruncated(Boolean truncated) {
        this.truncated = truncated;
    }
}