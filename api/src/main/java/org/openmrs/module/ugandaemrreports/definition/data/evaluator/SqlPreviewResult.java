package org.openmrs.module.ugandaemrreports.definition.data.evaluator;

import java.util.ArrayList;
import java.util.List;

public class SqlPreviewResult {

    private List<String> columns = new ArrayList<>();
    private List<List<Object>> rows = new ArrayList<>();
    private int rowCount;
    private boolean truncated;

    public SqlPreviewResult() {
    }

    public SqlPreviewResult(List<String> columns, List<List<Object>> rows, int rowCount, boolean truncated) {
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

    public int getRowCount() {
        return rowCount;
    }

    public void setRowCount(int rowCount) {
        this.rowCount = rowCount;
    }

    public boolean isTruncated() {
        return truncated;
    }

    public void setTruncated(boolean truncated) {
        this.truncated = truncated;
    }
}