package edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import lombok.Data;

import java.util.List;

@Data
public class TripsToCompleteResponse {
    List<Trip> tripsToBeCompleted;
    List<Trip> activeTrips;
    List<Trip> returningHomeTrips;

    public TripsToCompleteResponse(List<Trip> tripsToBeCompleted, List<Trip> activeTrips, List<Trip> returningHomeTrips) {
        this.tripsToBeCompleted = tripsToBeCompleted;
        this.activeTrips = activeTrips;
        this.returningHomeTrips = returningHomeTrips;
    }
}
