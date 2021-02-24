package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AllSpotResponse {

    private List<Spot> spots;

    public AllSpotResponse(List<Spot> spots) {
        this.spots = spots;
    }

    public List<Spot> getSpots() {
        return spots;
    }

    public void setSpots(List<Spot> spots) {
        this.spots = spots;
    }

    public AllSpotResponse() {
    }
}
