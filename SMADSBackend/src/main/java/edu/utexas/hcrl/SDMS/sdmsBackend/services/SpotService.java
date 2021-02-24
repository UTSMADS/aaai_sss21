package edu.utexas.hcrl.SDMS.sdmsBackend.services;


import com.turo.pushy.apns.util.ApnsPayloadBuilder;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.RobotClient;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.SmadsApnsService;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.TripStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.UpdatedSpotConditionResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.SpotRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.TripRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class SpotService {

    private final Map<Integer, Boolean> spotStatusMap = new HashMap<>();

    @Autowired
    private SpotRepository spotRepo;
    @Autowired
    private RequestService requestService;
    @Autowired
    private ServiceLocationsService slService;
    @Autowired
    private TripRepository tripRepository;
    @Autowired
    private RobotClient robotClient;
    @Autowired
    private StoreService storeService;
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;
    @Autowired
    private SimpMessageSendingOperations sendingOperations;
    @Autowired
    private SmadsApnsService smadsApnsService;
    @Autowired
    private UserService userService;

    public Spot saveSpot(Spot newSpot)
    {
        return spotRepo.save(newSpot);
    }


    public Optional<Spot> getSpotById(int manufacturerID) {

        return spotRepo.getSpotByManufacturerID(manufacturerID);
    }

    public boolean deleteSpot(Integer spotManufacturerID) {
        Optional<Spot> tempSpot = spotRepo.getSpotByManufacturerID(spotManufacturerID);
        if(tempSpot.isPresent())
        {
            Spot spot = tempSpot.get();
            spot.setActive(false);
            saveSpot(spot);
            return true;
        }else{
            return false;
        }
    }

    public List<Spot> getAllActiveSpots()
    {
        List<Spot> spotList = new ArrayList<>();
        spotRepo.getAllActiveSpots().forEach(spotList::add);
        return spotList;
    }

    public Spot updateSpotCondition(double latitude, double longitude, int manufacturerID, double chargeLevel, SpotStatus status, double spotHeading) {
        Optional <Spot> optionalSpot = getSpotById(manufacturerID);
        if(optionalSpot.isPresent()) {
            Spot movingSpot = optionalSpot.get();

            // If the old status was true, i.e. has sent error, only send an error if the new spot status is available
            boolean oldStatus = false;
            if (spotStatusMap.containsKey(movingSpot.getManufacturerID())) {
                oldStatus = spotStatusMap.get(movingSpot.getManufacturerID());
            }

            if (status != SpotStatus.outofservice && status != SpotStatus.reconnectingToInternet && oldStatus) {
                // there's no problem now but there was a problem before, so send a notification to say the robot is back online
                sendingOperations.convertAndSend("/topic/spotAlert", movingSpot);
                spotStatusMap.put(movingSpot.getManufacturerID(), false);
            }

            movingSpot.setCurrentLatitude(latitude);
            movingSpot.setCurrentLongitude(longitude);
            movingSpot.setChargeLevel(chargeLevel);
            movingSpot.setStatus(status);
            movingSpot.setHeading(spotHeading);
            movingSpot.setUpdatedAt(ZonedDateTime.now());
            return saveSpot(movingSpot);
        }
        return null;
    }

    public UpdatedSpotConditionResponse getCurrentSpotCondition(int manufacturerID){
        Optional <Spot> optionalSpot = getSpotById(manufacturerID);
        if(optionalSpot.isPresent())
        {
            Spot movingSpot = optionalSpot.get();
            double latitude = movingSpot.getCurrentLatitude();
            double longitude = movingSpot.getCurrentLongitude();
            double chargeLevel = movingSpot.getChargeLevel();
            SpotStatus status = movingSpot.getStatus();
            double heading = movingSpot.getHeading();
            return new UpdatedSpotConditionResponse(status, chargeLevel, latitude, longitude, heading, movingSpot.getManufacturerID());
        }
        return null;
    }

    public List<Trip> getAllTripsForSpot(int manufacturerID){
        return requestService.getAllTripsForSpot(manufacturerID);
    }

    public boolean sendSpotHome(int manufacturerID) {
        Optional <Spot> homeboundSpot = getSpotById(manufacturerID);
        if(homeboundSpot.isPresent()) {
            Spot spot = homeboundSpot.get();
            if (isSpotReturningHome(spot)) { return true; }

            spot.setStatus(SpotStatus.returninghome);
            spotRepo.save(spot);

            //create a trip to send spot home
            Trip homeBoundTrip = new Trip();
            homeBoundTrip.setSpotManufacturerID(manufacturerID);
            homeBoundTrip.setTripStatus(TripStatus.returningHome);
            homeBoundTrip.setAssignedSpot(spot);
            homeBoundTrip.setUserID(-1);
            homeBoundTrip.setPayloadContent("Returning Home");

            ServiceLocation destination = slService.getAvailableHomePoint();
            if (destination != null) {
                homeBoundTrip.setDropoffLocation(destination);
                homeBoundTrip.setPickupLocation(destination);
                destination.setNumAvailableChargers(destination.getNumAvailableChargers() - 1);
            } else {
                ServiceLocation defaultHome = slService.getServiceLocationWithLocationName("Anna Hiss");
                homeBoundTrip.setDropoffLocation(defaultHome);
                homeBoundTrip.setPickupLocation(defaultHome);
            }

            homeBoundTrip.setStartTime(ZonedDateTime.now());
            tripRepository.save(homeBoundTrip);

            //send this trip to robot
            if (environmentConfiguration.shouldCallRobot()) {
                if (robotClient.sendSpotHome(homeBoundTrip)) {
                    return true;
                } else {
                    System.out.println("error in sending spot home");
                    return false;
                }
            } else {
                System.out.println("Shouldn't call robot. Sending spot home.");
                return true;
            }
        } else {
            return false;
        }
    }

    private boolean isSpotReturningHome(Spot spot) {
        Optional<Trip> optionalTrip = tripRepository.getCurrentTripForSpot(spot.getManufacturerID());
        if (optionalTrip.isPresent()) {
            Trip trip = optionalTrip.get();
            return trip.getTripStatus() == TripStatus.returningHome;
        } else {
            return false;
        }
    }

    public Spot missingSpotAlert(Spot spot) {
        spot.setStatus(SpotStatus.outofservice);
        //TODO- send information to the manager than this spot is MIA
        return spot;
    }


    public Boolean setSpotStatus(int manufacturerID, SpotStatus status) {
        Optional<Spot> spot = spotRepo.getSpotByManufacturerID(manufacturerID);
        System.out.println("In setSpotStatus");
        if (spot.isPresent()) {
            Spot validSpot = spot.get();
            validSpot.setStatus(status);
            validSpot.setUpdatedAt(ZonedDateTime.now());
            spotRepo.save(validSpot);
            Optional<Trip> trip = requestService.getCurrentTripForSpot(manufacturerID);
            if (status != SpotStatus.outofservice && status != SpotStatus.reconnectingToInternet) {
                spotStatusMap.put(validSpot.getManufacturerID(), false);
            }
            if(trip.isEmpty() && status == SpotStatus.available) {
                Trip queuedTrip = requestService.getNextTripInQueue();
                if(queuedTrip != null) {
                    System.out.println("handleAssigningRobotToTrip from setSpotStatus 1");

                    requestService.handleAssigningRobotToTrip(queuedTrip);
                }
            }else if(trip.isPresent() && status == SpotStatus.outofservice) {
                Trip deletedTrip = trip.get();
                ZonedDateTime startTime = deletedTrip.getStartTime();
                Trip newTrip = new Trip();
                newTrip.setPayloadContent(deletedTrip.getPayloadContent());
                newTrip.setPickupLocation(deletedTrip.getPickupLocation());
                newTrip.setDropoffLocation(deletedTrip.getDropoffLocation());
                newTrip.setStartTime(startTime);
                newTrip.setTripStatus(TripStatus.requested);
                newTrip.setActive(true);
                newTrip.setUserID(deletedTrip.getUserID());
                newTrip.setEta(deletedTrip.getEta());

                deletedTrip.setActive(false);
                deletedTrip.setTripStatus(TripStatus.cancelled);
                deletedTrip.setEndTime(ZonedDateTime.now());
                tripRepository.save(deletedTrip);
                tripRepository.save(newTrip);
                System.out.println("handleAssigningRobotToTrip from setSpotStatus 2");
                requestService.handleAssigningRobotToTrip(newTrip);
            }
            if(environmentConfiguration.shouldCallRobot() && status != SpotStatus.outofservice) {
                return robotClient.updateSpotStatus(status, validSpot);
            }else{
                return true;
            }
        } else{
            return false;
        }
    }

    @Scheduled(fixedRate = 10000)
    public void checkSpotIsStillConnected(){
        // Only check on that if the store is open
        if (storeService.getStoreStatus().isOpen() && environmentConfiguration.isMissingSpotAlertEnabled()) {
            List<Spot> spotlist = getAllActiveSpots();
            for(Spot spot : spotlist) {
                ZonedDateTime previousStatusUpdateTime = spot.getUpdatedAt();
                Optional<Trip> trip = requestService.getCurrentTripForSpot(spot.getManufacturerID());
                if(previousStatusUpdateTime != null && ZonedDateTime.now().minus(30, ChronoUnit.SECONDS).isAfter(previousStatusUpdateTime)) {
                    spot.setStatus(trip.isPresent() ? SpotStatus.reconnectingToInternet : SpotStatus.outofservice);
                    spotRepo.save(spot);
                    if (!spotStatusMap.containsKey(spot.getManufacturerID()) || !spotStatusMap.get(spot.getManufacturerID())) {
                        Set<String> pushTokensForUser = userService.getPushTokensForAllManagers();

                        ApnsPayloadBuilder builder = new ApnsPayloadBuilder();
                        builder.setAlertBody("Please check in on " + spot.getName() + "'s status.");
                        builder.setAlertTitle(spot.getName() + " may be offline.");
                        builder.setSound("default");
                        String payload = builder.buildWithDefaultMaximumLength();
                        for (String token: pushTokensForUser) {
                            smadsApnsService.sendManagerNotification(token, payload);
                        }

                        spotStatusMap.remove(spot.getManufacturerID());
                        spotStatusMap.put(spot.getManufacturerID(), true);
                        System.out.println("Sent notification to Managers for spot " + spot.getManufacturerID() + " - " + spot.getStatus());
                    }
                } else {
                    if(trip.isEmpty()) {
                        Trip queuedTrip = requestService.getNextTripInQueue();
                        System.out.println("handleAssigningRobotToTrip from checkSpotIsStillConnected");
                        requestService.handleAssigningRobotToTrip(queuedTrip);
                    }
                }
            }
        }
    }
}
