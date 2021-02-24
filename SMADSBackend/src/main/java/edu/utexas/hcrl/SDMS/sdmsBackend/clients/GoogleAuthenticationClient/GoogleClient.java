package edu.utexas.hcrl.SDMS.sdmsBackend.clients.GoogleAuthenticationClient;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserAlreadyExistsException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.ManagerService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Component
public class GoogleClient {
    @Autowired
    private UserService userService;
    @Autowired
    private ManagerService managerService;

    private static final String CLIENT_ID = "your_google_auth_client_id";

    public User validateGoogleIdToken(String idTokenString) throws GeneralSecurityException, IOException {
        HttpTransport transport = new NetHttpTransport();
        JsonFactory jsonFactory = new JacksonFactory();
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
                // Specify the CLIENT_ID of the app that accesses the backend:
                .setAudience(Collections.singletonList(CLIENT_ID))
                .build();

        // (Receive idTokenString by HTTPS POST)

        GoogleIdToken idToken = verifier.verify(idTokenString);
        if (idToken != null) {
            GoogleIdToken.Payload payload = idToken.getPayload();

            String email = payload.getEmail();
            String lastName = ((String) payload.get("family_name")).trim();
            String firstName = ((String) payload.get("given_name")).trim();
            List<String> authorizedEmails = new ArrayList<>();
            authorizedEmails.add("smads.customer@gmail.com");
            try {
                RoleTypes usertype;
                if (managerService.isAuthorizedManager(email)) {
                    usertype = RoleTypes.MANAGER;
                } else if (payload.getHostedDomain() != null && (payload.getHostedDomain().equals("utexas.edu")) || authorizedEmails.contains(email) ||  payload.getHostedDomain().equals("austin.utexas.edu")) {
                    usertype = RoleTypes.CUSTOMER;
                } else {
                    return null;
                }
               return userService.createNewUser(email, "", firstName, lastName, usertype);
            } catch (UserAlreadyExistsException e) {
                return userService.getUserByUsername(email);
            }
        } else {
            System.out.println("Invalid ID token.");
            return null;
        }
    }
}
