package edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;

public class Location {
    private double latitude;
    private double longitude;

    public Location(ServiceLocation serviceLocation) {
        latitude = serviceLocation.getLatitude();
        longitude = serviceLocation.getLongitude();
    }

    public Location(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }
}
