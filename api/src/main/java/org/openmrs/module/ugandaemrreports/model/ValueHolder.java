package org.openmrs.module.ugandaemrreports.model;

public class ValueHolder {
    String disag1;
    String disag2;

    String placeholder;

    public ValueHolder(String disag1, String disag2, String placeholder) {
        this.disag1 = disag1;
        this.disag2 = disag2;
        this.placeholder = placeholder;
    }

    public String getDisag1() {
        return disag1;
    }

    public void setDisag1(String disag1) {
        this.disag1 = disag1;
    }

    public String getDisag2() {
        return disag2;
    }

    public void setDisag2(String disag2) {
        this.disag2 = disag2;
    }

    public String getPlaceholder() {
        return placeholder;
    }

    public void setPlaceholder(String placeholder) {
        this.placeholder = placeholder;
    }
}