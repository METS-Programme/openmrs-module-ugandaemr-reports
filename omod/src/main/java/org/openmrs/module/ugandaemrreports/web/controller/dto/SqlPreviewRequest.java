package org.openmrs.module.ugandaemrreports.web.controller.dto;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Used as both request + response delegate for RESTWS.
 * Request fields: sql, params, maxRows
 * Response fields: columns, rows, rowCount, truncated
 */
public class SqlPreviewRequest {

    // request
    private String sql;
    private Map<String, Object> params = new HashMap<>();
    private Integer maxRows;

    // response
    private List<String> columns = new ArrayList<>();
    private List<List<Object>> rows = new ArrayList<>();
    private Integer rowCount = 0;
    private Boolean truncated = false;

    public SqlPreviewRequest() {}

    // ---- request getters/setters ----
    public String getSql() {
        return sql;
    }

    public void setSql(String sql) {
        this.sql = sql;
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

    // ---- response getters/setters ----
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