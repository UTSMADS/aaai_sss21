package edu.utexas.hcrl.SDMS.sdmsBackend.controllers.notifications;

import com.turo.pushy.apns.util.ApnsPayloadBuilder;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.SmadsApnsService;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.AddTokenRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.SimpleSuccessResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private UserService userService;
    @Autowired
    private SmadsApnsService apnsClient;

    @PostMapping("/tokens")
    public SimpleSuccessResponse addTokenForUser(@RequestBody AddTokenRequest addTokenRequest, HttpServletRequest request, HttpServletResponse response) {
        try {
            int userID = jwtUtil.getUserIDFromToken(request);
            boolean success = userService.addTokenForUser(addTokenRequest.getToken(), userID, addTokenRequest.isManager());
            return new SimpleSuccessResponse(success);
        } catch (UserNotFoundException e) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }
    }

    @GetMapping("/tokens")
    public List<String> getTokensForUser(HttpServletRequest request, HttpServletResponse response) {
        List<String> tokens = new ArrayList<>();
        try {
            int userID = jwtUtil.getUserIDFromToken(request);
            tokens.addAll(userService.getPushTokensForUser(userID, true));
            tokens.addAll(userService.getPushTokensForUser(userID, false));
        } catch (UserNotFoundException e) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
        return tokens;
    }

    @PostMapping("/send")
    public void sendTestNotification() {
        Set<String> pushTokensForAllManagers = userService.getPushTokensForAllManagers();
        ApnsPayloadBuilder payloadBuilder = new ApnsPayloadBuilder()
                .setAlertTitle("Test Manager notification")
                .setAlertBody("This is a test notification for all managers");
        String s = payloadBuilder.buildWithDefaultMaximumLength();
        for(String t: pushTokensForAllManagers) {
            apnsClient.sendManagerNotification(t, s);
        }
    }
}
