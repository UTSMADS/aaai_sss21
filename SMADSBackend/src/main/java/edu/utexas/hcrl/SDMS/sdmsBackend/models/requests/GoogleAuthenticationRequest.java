package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

public class GoogleAuthenticationRequest {
    private String idToken;

    public String getIdToken() {
        return idToken;
    }

    public void setIdToken(String idToken) {
        this.idToken = idToken;
    }
}
