package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AllTripsResponse {

    private List<Trip> allTrips;

    public AllTripsResponse(List<Trip> trips)
    {
        allTrips = trips;
    }
    public List<Trip> getAllTrips() {
        return allTrips;
    }

    public void setAllTrips(List<Trip> allTrips) {
        this.allTrips = allTrips;
    }
}
