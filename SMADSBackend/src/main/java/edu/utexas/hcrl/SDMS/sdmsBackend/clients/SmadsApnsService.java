package edu.utexas.hcrl.SDMS.sdmsBackend.clients;

import com.turo.pushy.apns.ApnsClient;
import com.turo.pushy.apns.PushNotificationResponse;
import com.turo.pushy.apns.util.SimpleApnsPushNotification;
import com.turo.pushy.apns.util.concurrent.PushNotificationFuture;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.util.concurrent.ExecutionException;

@Component
public class SmadsApnsService {

    @Autowired
    @Qualifier("customerApnsClient")
    private ApnsClient customerApnsClient;

    @Autowired
    @Qualifier("managerApnsClient")
    private ApnsClient managerApnsClient;

    @Autowired
    private EnvironmentConfiguration environmentConfiguration;

    public void sendManagerNotification(String token, String payload) {
        sendNotification(token, true, payload);
    }

    /*
    ApnsPayloadBuilder builder = new ApnsPayloadBuilder();
        builder.setAlertBody("This is the body");
        builder.setAlertTitle("This is the title 😃");
        builder.setSound("default");
        String payload = builder.buildWithDefaultMaximumLength();
     */

    public void sendCustomerNotification(String token, String payload) {
        sendNotification(token, false, payload);
    }

    public void sendNotification(String deviceToken, boolean isManager, String payload) {

        String bundle = isManager ? environmentConfiguration.getManagersAppBundleId() : environmentConfiguration.getCustomerAppBundleId();
        SimpleApnsPushNotification pushNotification = new SimpleApnsPushNotification(deviceToken, bundle, payload);

        ApnsClient client = isManager ? managerApnsClient : customerApnsClient;

        PushNotificationFuture<SimpleApnsPushNotification, PushNotificationResponse<SimpleApnsPushNotification>> sendNotificationFuture = client.sendNotification(pushNotification);
        PushNotificationResponse<SimpleApnsPushNotification> pushNotificationResponse = null;
        try {
            pushNotificationResponse = sendNotificationFuture.get();
            if (!pushNotificationResponse.isAccepted()) {
                System.err.println("Notification rejected by the APNs gateway: " + pushNotificationResponse.getRejectionReason());
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
    }
}
