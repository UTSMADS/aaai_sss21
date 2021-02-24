package edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Waypoint;

import java.util.List;

public class NewTripResponse {
    private List<Location> locationPoints;

    public List<Location> getLocationPoints() {
        return locationPoints;
    }

    public void setLocationPoints(List<Location> locationPoints) {
        this.locationPoints = locationPoints;
    }
}
