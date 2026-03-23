package org.openmrs.module.ugandaemrreports.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.module.ugandaemrreports.definition.dataset.definition.AggregateReportDataSetDefinition;

import java.io.File;
import java.io.IOException;

public class ReportDesignFileUtil {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private ReportDesignFileUtil() {
    }

    public static File getReportDesignDirectory() {
        return AggregateReportDataSetDefinition.getReportDesignDirectory();
    }

    public static File resolveDesignFile(String fileName) {
        return AggregateReportDataSetDefinition.resolveReportDesignFile(fileName);
    }

    public static File writeJsonToDesignFile(String fileName, Object payload) throws IOException {
        File file = resolveDesignFile(fileName);
        ensureParentExists(file);
        OBJECT_MAPPER.writerWithDefaultPrettyPrinter().writeValue(file, payload);
        return file;
    }

    public static File writeJsonStringToDesignFile(String fileName, String json) throws IOException {
        File file = resolveDesignFile(fileName);
        ensureParentExists(file);
        java.nio.file.Files.write(file.toPath(), json.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        return file;
    }

    private static void ensureParentExists(File file) {
        File parent = file.getParentFile();
        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }
    }
}