package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthenticationResponse {
    private String token;

    @JsonProperty("isManager")
    private boolean isManager;
    private Trip customerTrip;

    public AuthenticationResponse() {
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public boolean isManager() {
        return isManager;
    }

    public void setManager(boolean manager) {
        isManager = manager;
    }

    public Trip getCustomerTrip() {
        return customerTrip;
    }

    public void setCustomerTrip(Trip customerTrip) {
        this.customerTrip = customerTrip;
    }
}
