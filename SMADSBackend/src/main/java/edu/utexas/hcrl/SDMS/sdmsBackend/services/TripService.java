package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.UpdatedSpotConditionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Component;

@Component
public class TripService {

    @Autowired
    private SimpMessageSendingOperations sendingOperations;

    public boolean sendUpdatedSpotConditionToUser(UpdatedSpotConditionResponse conditionResponse, int tripId) {
        String topic = "/topic/spotCondition/" + conditionResponse.getManufacturerId() + "/trip/" + tripId;
        sendingOperations.convertAndSend(topic, conditionResponse);
        return true;
    }
}
