package edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import lombok.Data;

@Data
public class NewRequestResponse {
    private Trip trip;
    private boolean userHasTrip;
    private boolean goToActiveTripDirectly;

    public NewRequestResponse(Trip trip, boolean userHasTrip, boolean goToActiveTripDirectly) {
        this.trip = trip;
        this.userHasTrip = userHasTrip;
        this.goToActiveTripDirectly = goToActiveTripDirectly;
    }
}
