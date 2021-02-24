package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.StatusTimestamp;

public class NewSpotConditionRequest {

    private double latitude;
    private double longitude;
    private SpotStatus spotStatus;
    private double chargeLevel;
    private double heading;
    private StatusTimestamp timestamp;

    public NewSpotConditionRequest(){}

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

    public SpotStatus getSpotStatus() {
        return spotStatus;
    }

    public void setSpotStatus(SpotStatus spotStatus) {
        this.spotStatus = spotStatus;
    }

    public double getChargeLevel() {
        return chargeLevel;
    }

    public void setChargeLevel(double chargeLevel) {
        this.chargeLevel = chargeLevel;
    }

    public double getHeading() {
        return heading;
    }

    public void setHeading(double heading) {
        this.heading = heading;
    }

    public StatusTimestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(StatusTimestamp timestamp) {
        this.timestamp = timestamp;
    }
}
