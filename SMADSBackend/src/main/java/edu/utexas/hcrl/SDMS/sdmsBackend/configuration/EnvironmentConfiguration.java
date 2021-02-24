package edu.utexas.hcrl.SDMS.sdmsBackend.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class EnvironmentConfiguration {
    @Value("${smads.callRobotClient.enabled}")
    private boolean callRobot;

    @Value("${smads.appleMode}")
    private boolean appleModeEnabled;

    @Value("${smads.missingSpotAlertEnabled}")
    private boolean missingSpotAlert;

    @Value("${apple.apns.production}")
    private boolean productionEnvironment;

    @Value("${apple.apns.customer.key.filename}")
    private String apnsCustomerKeyFilename;

    @Value("${apple.apns.customer.key.id}")
    private String apnsCustomerKeyId;

    @Value("${apple.apns.manager.key.id}")
    private String apnsManagerKeyId;

    @Value("${apple.apns.manager.key.filename}")
    private String apnsManagerKeyFilename;

    @Value("${apple.apns.team.id}")
    private String apnsTeamId;

    @Value("${smads.app.customer.bundleId}")
    private String customerAppBundleId;

    @Value("${smads.app.manager.bundleId}")
    private String managersAppBundleId;

    public boolean shouldCallRobot() {
        return callRobot;
    }

    public boolean isAppleModeEnabled() { return appleModeEnabled; }
    public boolean isMissingSpotAlertEnabled() { return missingSpotAlert; }
    public boolean isProductionEnvironment() { return productionEnvironment; }
    public String getApnsCustomerKeyFilename() { return apnsCustomerKeyFilename; }
    public String getApnsCustomerKeyId() { return apnsCustomerKeyId; }
    public String getApnsManagerKeyFilename() { return apnsManagerKeyFilename; }
    public String getApnsManagerKeyId() { return apnsManagerKeyId; }
    public String getApnsTeamId() { return apnsTeamId; }
    public String getCustomerAppBundleId() { return customerAppBundleId; }
    public String getManagersAppBundleId() { return managersAppBundleId; }
}
