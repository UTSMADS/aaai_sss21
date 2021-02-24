package edu.utexas.hcrl.SDMS.sdmsBackend.configuration;

import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.Message;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;
import org.springframework.web.socket.messaging.SessionUnsubscribeEvent;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class WebSocketEventListener {

    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private UserService userService;

    public static Map<Integer, String> websocketMapUsertoSession = new HashMap<>();
    public static Map<String, Integer> websocketMapSessiontoUser = new HashMap<>();

    @EventListener
    public void handleSessionConnected(SessionConnectEvent event) {
        System.out.println("Socket connected!");
        // Check for the authorization token and proceed to authentication. If the token is not valid, close the connection.
        Message msg = event.getMessage();
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(msg);
        String sessionId = null;
        List<String> sessionIdHeaderList = accessor.getNativeHeader("SessionId");
        if (sessionIdHeaderList != null && sessionIdHeaderList.size() > 0) {
            sessionId = sessionIdHeaderList.get(0);
        }
        List<String> authorizationHeaderList = accessor.getNativeHeader("Authorization");
        if (authorizationHeaderList != null && authorizationHeaderList.size() > 0) {
            String authorizationHeader = authorizationHeaderList.get(0);
            if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
                String token = authorizationHeader.substring(7);
                int userId = jwtUtil.extractId(token);
                UserDetails userDetails = null;
                boolean isValidToken = false;
                try {
                    userDetails = userService.loadUserById(userId);
                    if (jwtUtil.isTokenExpired(token)) {
                        isValidToken = false;
                    } else {
                        isValidToken = jwtUtil.validateToken(token, userDetails);
                    }
                } catch (UserNotFoundException e) {
                    e.printStackTrace();
                }
                if (isValidToken && sessionId != null) {
                    System.out.println("Adding user " + userId + " with session Id: " + sessionId);
                    websocketMapUsertoSession.put(userId, sessionId);
                    websocketMapSessiontoUser.put(sessionId, userId);
                }
            }
        }
    }

    @EventListener
    public void handleSessionDisconnect(SessionDisconnectEvent event) {
        Message msg = event.getMessage();
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(msg);
        String sessionId = accessor.getSessionId();
        if (websocketMapSessiontoUser.containsKey(sessionId))
        {
            int userID = websocketMapSessiontoUser.get(sessionId);
            websocketMapSessiontoUser.remove(sessionId);
            websocketMapUsertoSession.remove(userID);
        }
        System.out.println("Socket Disconnected");
    }

    @EventListener
    public void handleSubscription(SessionSubscribeEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = accessor.getDestination();
        System.out.println("Subscription to " + destination);
    }

    @EventListener
    public void handleUnsubscription(SessionUnsubscribeEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = accessor.getDestination();
        System.out.println("Unsubscription to " + destination);
    }
}
