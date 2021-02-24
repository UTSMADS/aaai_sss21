package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;

public class ValidTokenResponse {
    private boolean isCustomer;
    private Trip activeTrip;

    public ValidTokenResponse() {
    }

    public ValidTokenResponse(boolean isCustomer, Trip customerTrip) {
        this.isCustomer = isCustomer;
        this.activeTrip = customerTrip;
    }

    public boolean isCustomer() {
        return isCustomer;
    }

    public void setCustomer(boolean customer) {
        isCustomer = customer;
    }

    public Trip getActiveTrip() {
        return activeTrip;
    }

    public void setActiveTrip(Trip activeTrip) {
        this.activeTrip = activeTrip;
    }
}
