package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

public class TripRequest {

    private Integer pickupLocID;
    private Integer dropoffLocID;
    private String payloadContent;
    private Integer eta;

    public Integer getPickupLocID() {
        return pickupLocID;
    }

    public void setPickupLocID(Integer pickupLocID) {
        this.pickupLocID = pickupLocID;
    }

    public Integer getDropoffLocID() {
        return dropoffLocID;
    }

    public void setDropoffLocID(Integer dropoffLocID) {
        this.dropoffLocID = dropoffLocID;
    }

    public String getPayloadContent() {
        return payloadContent;
    }

    public void setPayloadContent(String payloadContent) {
        this.payloadContent = payloadContent;
    }

    public Integer getEta() {
        return eta;
    }

    public void setEta(Integer eta) {
        this.eta = eta;
    }
}
