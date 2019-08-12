<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("reportingui", "reportsapp/home.css")

    def appFrameworkService = context.getService(context.loadClass("org.openmrs.module.appframework.service.AppFrameworkService"))
    def overview = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.overview")
    def monthly = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.monthly2019")
    def registers = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.registers2019")
    def quarterly = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.reports.quarterly2019")
    def integration = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.integrationdataexports")
    def mer = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.ugandaemr.mer2019")
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
<h2>UgandaEMR Reports - HMIS Tools 2019 Version</h2>
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
            <div class="info-header"><h3>Mer Reports</h3></div>

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