package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AvailableServiceLocationsResponse {
    private List<ServiceLocation> serviceLocationList;

    public List<ServiceLocation> getServiceLocationList() {
        return serviceLocationList;
    }

    public void setServiceLocationList(List<ServiceLocation> serviceLocationList) {
        this.serviceLocationList = serviceLocationList;
    }
}
