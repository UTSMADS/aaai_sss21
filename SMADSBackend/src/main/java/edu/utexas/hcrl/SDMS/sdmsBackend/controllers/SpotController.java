package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.RobotClient;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.SpotManufacturerIdAlreadyExistsException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.StatusTimestamp;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.NewSpotConditionRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.SpotCreationRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.UpdateSpotStatusRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllSpotResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllTripsResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.UpdatedSpotConditionResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/spots")
public class SpotController {
    @Autowired
    private SpotService spotService;
    @Autowired
    private RequestService requestService;
    @Autowired
    private UserService userService;
    @Autowired
    private TripService tripService;
    @Autowired
    private ServiceLocationsService serviceLocationsService;
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;
    @Autowired
    private RobotClient robotClient;

    private StatusTimestamp timestamp = new StatusTimestamp(-1,-1);
    private Map<Integer, StatusTimestamp> robotTimeStampMap = new HashMap<>();

    @ResponseBody
    @GetMapping("/{manufacturerID}")
    public Spot getSpotById(@PathVariable int manufacturerID, HttpServletResponse response) {

        Optional<Spot> optionalSpot = spotService.getSpotById(manufacturerID);
        if(optionalSpot.isPresent()) {
            return optionalSpot.get();
        }
        else{
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return null;
        }
    }

    @ResponseBody
    @PostMapping("/")
    public Spot createSpot(@RequestBody SpotCreationRequest newSpotRequest) throws SpotManufacturerIdAlreadyExistsException {
        Optional <Spot> potentialExistingSpot = spotService.getSpotById(newSpotRequest.getManufacturerID());
        if (potentialExistingSpot.isPresent()){
            throw new SpotManufacturerIdAlreadyExistsException();
        }

        ServiceLocation anna_hiss = serviceLocationsService.getServiceLocationWithLocationName("Anna Hiss");
        Spot newSpot = new Spot();
        newSpot.setStatus(SpotStatus.outofservice);
        newSpot.setActive(true);
        newSpot.setName(newSpotRequest.getName());
        newSpot.setManufacturerID(newSpotRequest.getManufacturerID());
        newSpot.setIpAddress(newSpotRequest.getIpAddress());
        newSpot.setCurrentLatitude(anna_hiss.getLatitude());
        newSpot.setCurrentLongitude(anna_hiss.getLongitude());

        //create new user for spot with the credentials provided
        userService.createNewRobot(newSpotRequest.getManufacturerID().toString(), newSpotRequest.getPassword(), newSpotRequest.getName());

        return spotService.saveSpot(newSpot);
    }

    @ResponseBody
    @DeleteMapping("/{manufacturerID}")
    public boolean deleteSpot(@PathVariable int manufacturerID, HttpServletResponse response)
    {
        boolean isDeleted = spotService.deleteSpot(manufacturerID);
        if(!isDeleted)
        {
            response.setStatus(HttpStatus.NOT_FOUND.value());
        }
        return isDeleted;
    }

    @ResponseBody
    @GetMapping("/")
    public AllSpotResponse getListOfSpots()
    {
        return new AllSpotResponse(spotService.getAllActiveSpots());
    }

    @ResponseBody
    @PutMapping("/{manufacturerID}/statusUpdate")
    public UpdatedSpotConditionResponse updateSpotStatus(@PathVariable int manufacturerID, @RequestBody NewSpotConditionRequest updatedSpotCondition) {
        System.out.println("Received update from robot " + manufacturerID + " - " + updatedSpotCondition.getSpotStatus());
        double latitude = updatedSpotCondition.getLatitude();
        double longitude = updatedSpotCondition.getLongitude();
        SpotStatus spotStatus = updatedSpotCondition.getSpotStatus();
        this.timestamp = updatedSpotCondition.getTimestamp();
        StatusTimestamp previous = robotTimeStampMap.get(manufacturerID);
        if(previous == null)
        {
            robotTimeStampMap.put(manufacturerID,  new StatusTimestamp(0,0));
            previous = robotTimeStampMap.get(manufacturerID);
        }

        robotTimeStampMap.put(manufacturerID, timestamp);

        UpdatedSpotConditionResponse updatedSpotConditionResponse = new UpdatedSpotConditionResponse(updatedSpotCondition, manufacturerID);

        Optional<Trip> trip = requestService.getCurrentTripForSpot(manufacturerID);
        if (trip.isPresent()) {
            if(spotStatus == SpotStatus.available && environmentConfiguration.shouldCallRobot()) {
                 robotClient.sendUserTripToSpot(trip.get());
                System.out.println("Sent trip to robot after it came back online");
            }
            System.out.println("Current trip for spot " + manufacturerID + " is not null");
            int tripId = trip.get().getId();
            if (previous == null || timestamp.isAfter(previous)) {
                //send updatedSpotConditionResponse to websocket
                boolean success = tripService.sendUpdatedSpotConditionToUser(updatedSpotConditionResponse, trip.get().getId());
                if (!success) {
                    System.out.println("Could not send robot updated condition to user for trip " + tripId);
                }
            }
            requestService.manageTripStatus(spotStatus, tripId);
        }
        spotService.updateSpotCondition(latitude, longitude, manufacturerID, updatedSpotCondition.getChargeLevel(), spotStatus, updatedSpotCondition.getHeading());

        return updatedSpotConditionResponse;
    }

    @ResponseBody
    @GetMapping("/{manufacturerID}/statusUpdate")
    public UpdatedSpotConditionResponse getUpdatedSpotCondition(@PathVariable int manufacturerID,HttpServletResponse response){
        UpdatedSpotConditionResponse condition = spotService.getCurrentSpotCondition(manufacturerID);
        if (condition != null) {
            condition.setTimestamp(this.timestamp);
            return condition;
        } else {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return null;
        }
    }

    @ResponseBody
    @GetMapping("/{manufacturerID}/trips")
    public AllTripsResponse getTripsForSpot(@PathVariable int manufacturerID) {
        return new AllTripsResponse(spotService.getAllTripsForSpot(manufacturerID));
    }

    @ResponseBody
    @PostMapping("/{manufacturerID}/returnHome")
    public boolean sendSpotHome(@PathVariable int manufacturerID)
    {
        return spotService.sendSpotHome(manufacturerID);
    }

    @ResponseBody
    @GetMapping("/{manufacturerID}/activeTrip")
    public Trip getActiveTripForSpot(@PathVariable int manufacturerID) {
        return requestService.getCurrentTripForSpot(manufacturerID).orElseGet(Trip::new);
    }

    @ResponseBody
    @PutMapping("/{manufacturerID}/updateSpotStatus")
    public Boolean updateSpotStatusVariable(@PathVariable int manufacturerID, @RequestBody UpdateSpotStatusRequest request) {
        return spotService.setSpotStatus(manufacturerID, request.getStatus());
    }
}
