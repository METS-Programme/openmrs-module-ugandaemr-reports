<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("reportingui", "reportsapp/home.css")

    def appFrameworkService = context.getService(context.loadClass("org.openmrs.module.appframework.service.AppFrameworkService"))
    def overview = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.overview")
    def monthly = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.monthly")
    def registers = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.registers")
    def quarterly = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.quarterly")
    def integration = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.integrationdataexports")
    def mer = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.mer")
    def mer_patient_lists = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.mer_patient_lists")
    def ewi = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.ewi")
    def contextModel = [:]
%>

<script type="text/javascript">
    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {
            label: "${ ui.message("reportingui.reportsapp.home.title") }", link: "${ ui.pageLink("ugandaemrreports",
        "reportsHome")
}"
        }
    ];
</script>
<style>
.dashboard .info-container {
    width: 30%;
}
</style>
<h2>UgandaEMR Reports</h2>
<div class="dashboard clear">
    <div class="info-container column">
        <% if (overview) { %>
        <div class="info-section">
            <div class="info-header"><h3>Facility Reports</h3></div>

            <div class="info-body">
                <ul>
                    <% overview.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

        <% if (registers) { %>
        <div class="info-section">
            <div class="info-header"><h3>Registers</h3></div>

            <div class="info-body">
                <ul>
                    <% registers.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>
    </div>

    <div class="info-container column">
        <% if (monthly) { %>
        <div class="info-section">
            <div class="info-header"><h3>Monthly Reports</h3></div>

            <div class="info-body">
                <ul>
                    <% monthly.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

        <% if (quarterly) { %>
        <div class="info-section">
            <div class="info-header"><h3>Quarterly Reports</h3></div>

            <div class="info-section">
                <ul>
                    <% quarterly.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

    </div>
    <div class="info-container column">
        <% if (mer) { %>
        <div class="info-section">
            <div class="info-header"><h3>MER Indicator Reports</h3></div>

            <div class="info-body">
                <ul>
                    <% mer.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>
        <% if (mer_patient_lists) { %>
        <div class="info-section">
            <div class="info-header"><h3>Patient Lists for MER Indicator Reports</h3></div>

            <div class="info-body">
                <ul>
                    <% mer_patient_lists.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

        <% if (ewi) { %>
        <div class="info-section">
            <div class="info-header"><h3>Early Warning Indicators</h3></div>

            <div class="info-body">
                <ul>
                    <% ewi.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>

        <% if (integration) { %>
        <div class="info-section">
            <div class="info-header"><h3>Integration Data Exports</h3></div>

            <div class="info-body">
                <ul>
                    <% integration.each { %>
                    <li>
                        ${ui.includeFragment("uicommons", "extension", [extension: it, contextModel: contextModel])}
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <% } %>
    </div>
</div>