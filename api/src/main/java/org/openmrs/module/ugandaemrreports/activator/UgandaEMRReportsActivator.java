/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandaemrreports.activator;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.util.OpenmrsUtil;

/**
 * This class contains the logic that is run every time this module is either started or stopped.
 */
public class UgandaEMRReportsActivator extends BaseModuleActivator {

	protected Log log = LogFactory.getLog(getClass());

	File folder = FileUtils.toFile(UgandaEMRReportsActivator.class.getClassLoader().getResource("report_designs"));
	public List<Initializer> getInitializers() {
		List<Initializer> l = new ArrayList<Initializer>();
		l.add(new AppConfigInitializer());
		l.add(new ReportInitializer());
		return l;
	}

    @Override
    public void started() {
        log.info("UgandaEMR Reports module started - initializing...");

        try {
            addMambaetlProperties();
            Context.getService(FlattenDatabaseService.class).setupEtl();
            for (Initializer initializer : getInitializers()) {
                initializer.started();
            }
        } catch (Exception e) {
            log.error("Error starting UgandaEMR Reports module", e);
        }
    }

	@Override
	public void stopped() {
		Context.getService(FlattenDatabaseService.class).shutdownEtlThread();
		for (int i = getInitializers().size() - 1; i >= 0; i--) {
			getInitializers().get(i).stopped();
		}
		log.info("UgandaEMR Reports module stopped");
	}

	public static void addMambaetlProperties() {
		File appDataDir = FileUtils.getFile(OpenmrsUtil.getApplicationDataDirectory());
		File propertiesFile = new File(appDataDir, "openmrs-runtime.properties");
		Properties properties = new Properties();
		try (FileInputStream in = new FileInputStream(propertiesFile)) {
			properties.load(in);
		} catch (IOException e) {
			System.err.println("Failed to read properties file: " + e.getMessage());
			return;
		}
		// Extract DB name from connection.url
		String connectionUrl = properties.getProperty("connection.url");
		String dbName = null;
		if (connectionUrl != null && connectionUrl.contains("/")) {
			try {
				int lastSlash = connectionUrl.lastIndexOf('/');
				int questionMark = connectionUrl.indexOf('?', lastSlash);
				if (lastSlash != -1 && questionMark != -1) {
					dbName = connectionUrl.substring(lastSlash + 1, questionMark);
				} else if (lastSlash != -1) {
					dbName = connectionUrl.substring(lastSlash + 1);
				}
			} catch (Exception e) {
				System.err.println("Error parsing connection.url: " + e.getMessage());
			}
		}
		if (dbName == null || dbName.isEmpty()) {
			dbName = "openmrs";
			System.out.println("WARNING: Using fallback database name: " + dbName);
		}
		// Extract username
		String username = properties.getProperty("connection.username", "openmrs");
		if (username.isEmpty()) {
			username = "openmrs";
			System.out.println("WARNING: Using fallback username: " + username);
		}
		// Extract password
		String password = properties.getProperty("connection.password", "openmrs");
		if (password.isEmpty()) {
			password = "openmrs";
			System.out.println("WARNING: Using fallback password: " + password);
		}
		// Set MambaETL properties
		properties.setProperty("mambaetl.analysis.db.openmrs_database", dbName);
		properties.setProperty("mambaetl.analysis.db.etl_database", dbName);
		properties.setProperty("mambaetl.analysis.db.username", username);
		properties.setProperty("mambaetl.analysis.db.password", password);
		properties.setProperty("mambaetl.analysis.columns", "49");
		properties.setProperty("mambaetl.analysis.incremental_mode", "1");
		properties.setProperty("mambaetl.analysis.etl_interval", "3600");
		properties.setProperty("mambaetl.analysis.locale", "en");
		properties.setProperty("mambaetl.analysis.automated_flattening", "0");
		try (FileOutputStream out = new FileOutputStream(propertiesFile)) {
			properties.store(out, "Updated with MambaETL related properties");
			System.out.println("MambaETL properties updated successfully.");
		} catch (IOException e) {
			System.err.println("Failed to write properties file: " + e.getMessage());
		}
	}
}
