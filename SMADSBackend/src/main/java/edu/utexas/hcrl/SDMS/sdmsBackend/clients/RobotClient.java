package edu.utexas.hcrl.SDMS.sdmsBackend.clients;


import edu.utexas.hcrl.SDMS.sdmsBackend.clients.requests.UpdateSpotStatusRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.CancelledTripResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.Location;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.NewTripResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.SendSpotHomeResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.SpotService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Component
public class RobotClient<TripService> {
    //Get IP address from robot server team
    //private String baseurl = "http://" ; //"https://hypnotoad.csres.utexas.edu:8087" ;

    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private SpotService spotService;

    public List<Location> sendUserTripToSpot(Trip trip) {
        String baseurl = "";

        Optional<Spot> assignedSpot = spotService.getSpotById(trip.getSpotManufacturerID());
        if (assignedSpot.isPresent()) {
            baseurl = "http://" +  assignedSpot.get().getIpAddress();
            HttpHeaders headers = new HttpHeaders();
            headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
            HttpEntity<Trip> entity = new HttpEntity<>(trip, headers);

            String url = baseurl + "/newTrip";
            ResponseEntity<NewTripResponse> result;
            try {
                result = restTemplate.exchange(url, HttpMethod.POST, entity, NewTripResponse.class);
                if (result.getStatusCode() == HttpStatus.SERVICE_UNAVAILABLE){
                    //trigger missing spot connection in front end
                    spotService.missingSpotAlert(trip.getAssignedSpot());
                    return null;
                }
                if (result.getBody() != null) {
                    return result.getBody().getLocationPoints();
                } else {
                    return null;
                }
            } catch (ResourceAccessException e) {
                return null;
            }
        } else {
            return null;
        }
    }

    public boolean cancelTrip(Trip trip) {
        String baseurl = "";
        if (trip.getSpotManufacturerID() != null) {
            Optional<Spot> assignedSpot = spotService.getSpotById(trip.getSpotManufacturerID());
            if (assignedSpot.isPresent()) {
                baseurl = "http://" +  assignedSpot.get().getIpAddress();
                HttpHeaders headers = new HttpHeaders();
                headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
                HttpEntity<Trip> entity = new HttpEntity<>(trip, headers);
                String path = baseurl + "/cancelledTrip";

                ResponseEntity<CancelledTripResponse> result = restTemplate.exchange(path, HttpMethod.PUT, entity, CancelledTripResponse.class);
                if (result.getStatusCode() == HttpStatus.SERVICE_UNAVAILABLE){
                    // trigger missing spot connection in front end
                    spotService.missingSpotAlert(trip.getAssignedSpot());
                    return false;
                }

                return result.getBody().isSuccess();
            } else {
                return false;
            }
        }
        return true;
    }

    public boolean sendSpotHome(Trip trip)  {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        HttpEntity<Trip> entity = new HttpEntity<>(trip, headers);
        String baseurl = "";
        Optional<Spot> assignedSpot = spotService.getSpotById(trip.getSpotManufacturerID());
        if (assignedSpot.isPresent()) {
            baseurl = "http://" + assignedSpot.get().getIpAddress();
            String path = baseurl + "/sendSpotHome";

            ResponseEntity<SendSpotHomeResponse> result = restTemplate.exchange(path, HttpMethod.POST, entity, SendSpotHomeResponse.class);

            if (result.getStatusCode() == HttpStatus.SERVICE_UNAVAILABLE) {
                // trigger missing spot connection in front end
                spotService.missingSpotAlert(trip.getAssignedSpot());
                return false;
            }
            if (result.getBody() != null) {
                return result.getBody().isSuccess();
            }
        }
        return false;
    }

    public boolean testSSLCommunication() {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        HttpEntity<String> entity = new HttpEntity<String>("testSSLCommunication", headers);
        String baseurl = "http://10.0.0.33:9143/test/pingMe";
        ResponseEntity<SendSpotHomeResponse> result = restTemplate.exchange(baseurl, HttpMethod.POST, entity, SendSpotHomeResponse.class);

        if (result.getBody() != null) {
            return result.getBody().isSuccess();
        } else {
            return false;
        }
    }

    public boolean updateSpotStatus(SpotStatus status, Spot spot) {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        UpdateSpotStatusRequest request = new UpdateSpotStatusRequest();
        request.setStatus(status.toString());
        HttpEntity<UpdateSpotStatusRequest> entity = new HttpEntity<UpdateSpotStatusRequest>(request, headers);

        String baseurl = "http://" +  spot.getIpAddress() + "/spotStatus";
        System.out.println("Sending update spot status to " + spot.getName() + " - " + spot.getStatus());
        ResponseEntity<SendSpotHomeResponse> result = restTemplate.exchange(baseurl, HttpMethod.PUT, entity, SendSpotHomeResponse.class);
        if (result.getBody() != null) {
            System.out.println("Spot status update success - " + spot.getName() + " - " + spot.getStatus());
            return result.getBody().isSuccess();
        } else {
            System.out.println("Spot status update error - " + spot.getName() + " - " + spot.getStatus());
            return false;
        }
    }

    public boolean tripHasRobot(Trip trip) {
        return trip.getSpotManufacturerID() != null;
    }
}
