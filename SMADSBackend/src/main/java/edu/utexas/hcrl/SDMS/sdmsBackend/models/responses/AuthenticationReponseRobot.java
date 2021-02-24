package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonProperty;

public class AuthenticationReponseRobot {

    private String token;

    public AuthenticationReponseRobot() {
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }


}
