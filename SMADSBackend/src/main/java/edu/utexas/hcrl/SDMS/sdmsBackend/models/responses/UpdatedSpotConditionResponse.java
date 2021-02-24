package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.StatusTimestamp;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.NewSpotConditionRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UpdatedSpotConditionResponse {

    private int manufacturerId;
    private double updatedSpotLatitude;
    private double updatedSpotLongitude;
    private SpotStatus spotStatus;
    private double chargeLevel;
    private double heading;
    private StatusTimestamp timestamp;

    public UpdatedSpotConditionResponse(NewSpotConditionRequest updatedCondition, int manufacturerId) {
        this.manufacturerId = manufacturerId;
        spotStatus = updatedCondition.getSpotStatus();
        chargeLevel = updatedCondition.getChargeLevel();
        updatedSpotLatitude = updatedCondition.getLatitude();
        updatedSpotLongitude = updatedCondition.getLongitude();
        heading = updatedCondition.getHeading();
        timestamp = updatedCondition.getTimestamp();
    }

    public UpdatedSpotConditionResponse(SpotStatus status, double charge, double latitude, double longitude, double heading, int manufacturerId) {
        this.manufacturerId = manufacturerId;
        this.spotStatus = status;
        this.updatedSpotLongitude = longitude;
        this.updatedSpotLatitude = latitude;
        this.chargeLevel = charge;
        this.heading = heading;
    }
}
