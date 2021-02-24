package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;

public class UpdateSpotStatusRequest {
    private SpotStatus status;

    public SpotStatus getStatus() {
        return status;
    }

    public void setStatus(SpotStatus status) {
        this.status = status;
    }
}
