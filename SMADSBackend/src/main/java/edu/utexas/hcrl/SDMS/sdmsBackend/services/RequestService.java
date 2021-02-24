package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import com.turo.pushy.apns.util.ApnsPayloadBuilder;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.RobotClient;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.SmadsApnsService;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.Location;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.NotificationType;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.TripStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.BadServiceLocationIdException;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.NoAvailableSpotForTripException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.*;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.ServiceLocationRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.TripRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.core.task.TaskExecutor;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@Service
public class RequestService {
    @Autowired
    private TripRepository tripRepo;
    @Autowired
    private SpotService spotService;
    @Autowired
    private ServiceLocationsService slService;
    @Autowired
    private ServiceLocationRepository slRepo;
    @Autowired
    private RobotClient robotClient;
    @Autowired
    private WaypointService waypointService;
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;
    @Autowired
    private SimpMessageSendingOperations sendingOperations;
    @Autowired
    @Qualifier("GPSSimulationExecutor")
    private TaskExecutor gpsTaskExecutor;
    @Autowired
    @Qualifier("TripAutoCloserExecutor")
    private TaskExecutor tripAutocloseTaskExecutor;
    @Autowired
    private ApplicationContext applicationContext;
    @Autowired
    private SmadsApnsService smadsApnsService;
    @Autowired
    private UserService userService;

    private boolean startedAutocloseThread = false;

    public Trip deleteTrip(Integer tripId) {
        Optional<Trip> tripToDelete = tripRepo.findById(tripId);
        if(tripToDelete.isPresent()) {
            Trip trip = tripToDelete.get();
            trip.setActive(false);
            trip.setTripStatus(TripStatus.cancelled);
            trip.setEndTime(ZonedDateTime.now());
            if (trip.getSpotManufacturerID() != null) {
                Optional<Spot> assignedSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                if(assignedSpot.isPresent()) {
                    assignedSpot.get().setStatus(SpotStatus.available);
                    spotService.saveSpot(assignedSpot.get());

                    if (environmentConfiguration.shouldCallRobot()) {
                        robotClient.updateSpotStatus(SpotStatus.available, assignedSpot.get());
                    }
                }
            }

            //trigger spot to service next trip in queue if there is one
            Trip nextTrip = getNextTripInQueue();
            if (nextTrip != null) {
                handleAssigningRobotToTrip(nextTrip);
            }
            return tripRepo.save(trip);
        } else {
            return null;
        }
    }

    public Spot getSpotForTrip(double pickupLat, double pickupLong, double dropoffLat, double dropoffLong) {
        List<Spot> allSpots = spotService.getAllActiveSpots();

        for(Spot spot : allSpots) {
            if (spot.getStatus() == SpotStatus.returninghome && environmentConfiguration.isAppleModeEnabled()) {
                Optional<Trip> currentTripForSpot = getCurrentTripForSpot(spot.getManufacturerID());
                if (currentTripForSpot.isPresent()) {
                    Trip currentTrip = currentTripForSpot.get();
                    currentTrip.setActive(false);
                    currentTrip.setTripStatus(TripStatus.cancelled);
                    tripRepo.save(currentTrip);
                }
            }
            if (spot.getStatus() == SpotStatus.returninghome && environmentConfiguration.isAppleModeEnabled()) {
                //Eventually logic here will check if the spot has enough charge to complete trip and choose closest capable Spot to pick up location
                spot.setStatus(SpotStatus.enroute);
                return spotService.saveSpot(spot);
            }else if (spot.getStatus() == SpotStatus.available){
                return spot;
            }
        }
        return null;
    }

    public Trip getTripById(int tripID) {
        Optional<Trip> trip = tripRepo.findById(tripID);
        if (trip.isPresent()) {
            Trip t = trip.get();
            if (t.getSpotManufacturerID() != null) {
                Optional<Spot> spotById = spotService.getSpotById(t.getSpotManufacturerID());
                t.setAssignedSpot(spotById.orElse(null));
            }
            return t;
        }
        return null;
    }

    public Trip createNewTrip(Integer pickupLocID, Integer dropoffLocID, String bookName, Integer userID, Integer eta) throws BadServiceLocationIdException, NoAvailableSpotForTripException {
        Optional<ServiceLocation> pickupLoc = slRepo.getActiveServiceLocationByID(pickupLocID);
        Optional<ServiceLocation> dropoffLoc = slRepo.getActiveServiceLocationByID(dropoffLocID);

        if(pickupLoc.isEmpty()) {
            throw new BadServiceLocationIdException(pickupLocID);
        }

        if(dropoffLoc.isEmpty()) {
            throw new BadServiceLocationIdException(dropoffLocID);
        }
        ZonedDateTime now = ZonedDateTime.now();
        Trip newTrip = new Trip();
        newTrip.setPayloadContent(bookName);
        newTrip.setPickupLocation(pickupLoc.get());
        newTrip.setDropoffLocation(dropoffLoc.get());
        newTrip.setStartTime(now);
        newTrip.setTripStatus(TripStatus.requested);
        newTrip.setActive(true);
        newTrip.setUserID(userID);
        newTrip.setEta(eta);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/dd/yy - HH:mm");
        String formattedNow = now.format(formatter);

        System.out.println("handleAssigningRobotToTrip from create new trip");

        // Notify the manager that there is a new trip
        Set<String> pushTokensForUser = userService.getPushTokensForAllManagers();
        String username = "One of our users";
        User user = userService.getUserbyID(userID);
        if (user != null) {
            username = user.getFirstName() + " " + user.getLastName();
        }
        ApnsPayloadBuilder builder = new ApnsPayloadBuilder();
        builder.setAlertBody(username + " just placed an order at " + formattedNow + ". Dropoff location: " + dropoffLoc.get().getAcronym() + ". Please open the SMADS Manager app and check the Orders tab to process their order. Thanks!");
        builder.setAlertTitle("New Order Placed!");
        builder.setSound("default");
        String payload = builder.buildWithDefaultMaximumLength();
        for (String token: pushTokensForUser) {
            smadsApnsService.sendManagerNotification(token, payload);
        }
        return handleAssigningRobotToTrip(newTrip);
    }

    public Trip handleAssigningRobotToTrip(Trip newTrip) {
        if (newTrip == null) { return null; }
        Trip tripToReturn;
        double pickupLat = newTrip.getPickupLocation().getLatitude();
        double pickupLong = newTrip.getPickupLocation().getLongitude();
        double dropoffLat = newTrip.getDropoffLocation().getLatitude();
        double dropoffLong = newTrip.getDropoffLocation().getLongitude();

        Spot assignedSpot = getSpotForTrip(pickupLat, pickupLong, dropoffLat, dropoffLong);
        if (assignedSpot != null) {
            assignedSpot.setStatus(SpotStatus.assignedTrip);
            System.out.println("Changing spot status (id: " + assignedSpot.getManufacturerID() + ") to " + assignedSpot.getStatus());
            spotService.saveSpot(assignedSpot);
            newTrip.setAssignedSpot(assignedSpot);
            newTrip.setTripStatus(TripStatus.processing);
            newTrip.setSpotManufacturerID(assignedSpot.getManufacturerID());

             if(!environmentConfiguration.shouldCallRobot()) {
                    Location startLocation = new Location(newTrip.getPickupLocation().getLatitude(), newTrip.getPickupLocation().getLongitude());
                    Location endLocation = new Location(newTrip.getDropoffLocation().getLatitude(), newTrip.getDropoffLocation().getLongitude());

                    List<Location> wp = new ArrayList<>();
                    wp.add(startLocation);
                    wp.addAll(waypointService.getDefaultTripWaypoints());
                    wp.add(endLocation);

                    if (environmentConfiguration.isAppleModeEnabled()) {
                        startSimulatingRobotSendingLocation(newTrip);
                    }

                    List<Waypoint> waypoints = waypointService.createWaypoints(wp, newTrip);
                    saveWaypointsToTrip(waypoints);
                    newTrip.setAssignedSpot(assignedSpot);
                    Trip savedTrip = tripRepo.save(newTrip);
                    sendTripUpdateToCustomer(savedTrip);
                    // start new thread to read in gps locations from bag file to update spot model in databas
                    tripToReturn = savedTrip;
            } else {
                 tripToReturn = tripRepo.save(newTrip);
                 robotClient.updateSpotStatus(SpotStatus.assignedTrip, assignedSpot);
             }
        } else {
            tripToReturn = tripRepo.save(newTrip);
        }

        if (environmentConfiguration.isAppleModeEnabled()) {
            sendRobotOnTrip(tripToReturn.getId());
        }
        pushTripToManagers();
        sendTripUpdateToCustomer(tripToReturn);
        return tripToReturn;
    }

    private void startSimulatingRobotSendingLocation(Trip trip) {
        RobotConditionUpdater updater = applicationContext.getBean(RobotConditionUpdater.class);
        updater.setup(trip);
        gpsTaskExecutor.execute(updater);
    }

    private void sendTripUpdateToCustomer(Trip savedTrip) {
        Set<String> pushTokensForUser = userService.getPushTokensForUser(savedTrip.getUserID(), false);

        ApnsPayloadBuilder builder = new ApnsPayloadBuilder();
        builder.setAlertBody("Your order has been assigned a robot and is on its way.");
        builder.setAlertTitle("Order update");
        builder.setSound("default");
        String payload = builder.buildWithDefaultMaximumLength();
        for (String token: pushTokensForUser) {
            if(savedTrip.hasNotification(NotificationType.robotenroute) == false)
            {
                smadsApnsService.sendCustomerNotification(token, payload);
                savedTrip.addNotification(NotificationType.robotenroute);
                tripRepo.save(savedTrip);
            }
        }

    }

    public void sendAutocloseTripMessageToCustomer(int tripId) {
        System.out.println("Sent autoclose to customer");
        sendingOperations.convertAndSend("/topic/queuedTrip/" + tripId + "/autoclose", "");
    }

    public Optional<Trip> getCurrentTripForSpot(int manufacturerID) {
        // Always pass in TripStatus.complete to get trips that have not been completed (active trips)
        return tripRepo.getCurrentTripForSpot(manufacturerID);
    }

    public List<Trip> getAllTrips() {
        List<Trip> tripList = new ArrayList<>();
        tripRepo.findAll().forEach(tripList::add);
        return tripList;
    }

    public List<Trip> getAllTripsForSpot(int manufacturerID){
        List<Trip> tripList = new ArrayList<>();
        tripRepo.getAllTripsForSpot(manufacturerID).forEach(tripList::add);
        return tripList;
    }

    public List<Trip> getAllTripsForCustomer(int userID){
        List<Trip> tripList = new ArrayList<>();
        tripRepo.getAllTripsForUser(userID).forEach(tripList::add);
        return tripList;
    }

    public boolean updateTripStatus(int tripId, TripStatus status){
        Optional<Trip> trip = tripRepo.findById(tripId);
        if(trip.isPresent())
        {
            Trip activeTrip = trip.get();
            activeTrip.setTripStatus(status);
            tripRepo.save(activeTrip);
            return true;
        } else {
            return false;
        }
    }

    public boolean closeTrip(int tripId){
        Optional<Trip> trip = tripRepo.findById(tripId);
        if(trip.isPresent()) {
            Trip activeTrip = trip.get();
            activeTrip.setTripStatus(TripStatus.complete);
            //sendCompleteTripToCustomer(tripId);
            Optional<Spot> assignedSpot = spotService.getSpotById(activeTrip.getSpotManufacturerID());
            if (assignedSpot.isPresent()) {
                SpotStatus newStatus;
                Spot spot = assignedSpot.get();
                if (spot.getStatus() == SpotStatus.dropoff && activeTrip.getPayloadContent().equals("Returning Home")) {
                    newStatus = SpotStatus.available;
                } else {
                    newStatus = SpotStatus.returninghome;
                }
                spot.setStatus(newStatus);
                spotService.saveSpot(spot);
                if (environmentConfiguration.shouldCallRobot()){
                    robotClient.updateSpotStatus(SpotStatus.available, spot);
                }

            }
            activeTrip.setEndTime(ZonedDateTime.now());
            tripRepo.save(activeTrip);

            //trigger spot to service next trip in queue if there is one
            Trip nextTrip = getNextTripInQueue();
            if (nextTrip != null) {
                System.out.println("handleAssigningRobotToTrip from Close trip");
                handleAssigningRobotToTrip(nextTrip);
            }
            pushTripToManagers();
            startedAutocloseThread = false;
            return true;
        } else {
            return false;
        }
    }

    public void manageTripStatus(SpotStatus spotStatus, int tripId) {
        Trip trip = getTripById(tripId);
        if (spotStatus == SpotStatus.dropoff && trip.getPayloadContent().equals("Returning Home")) {
            closeTrip(tripId);
        } else if (spotStatus == SpotStatus.dropoff) {
            if (environmentConfiguration.isAppleModeEnabled()) {
                updateTripStatus(tripId, TripStatus.dropoff);
                TripAutoCloser autoCloser = applicationContext.getBean(TripAutoCloser.class);
                autoCloser.tripId = tripId;
                startedAutocloseThread = true;
                tripAutocloseTaskExecutor.execute(autoCloser);
            } else {
                updateTripStatus(tripId, TripStatus.dropoff);
            }
            if(trip.hasNotification(NotificationType.pickup) == false){
                sendCompleteTripToCustomer(trip);
            }
        } else if (spotStatus == SpotStatus.enroute || spotStatus == SpotStatus.pickup || spotStatus == SpotStatus.returninghome) {
            updateTripStatus(tripId, TripStatus.enroute);
        }
    }

    public void saveWaypointsToTrip(List<Waypoint> waypoints){
        if (waypoints.size() > 0){
            Trip newTrip = waypoints.get(0).getTrip();
            newTrip.setWaypoints(waypoints);
            tripRepo.save(newTrip);
        }
    }
    public Trip getNextTripInQueue(){
        List<Trip> queuedTrips = new ArrayList<>();
        tripRepo.getAllQueuedTrips(TripStatus.requested).forEach(queuedTrips::add);
        if (queuedTrips.size() >0){
            Trip nextTrip = queuedTrips.get(0);
            if (nextTrip != null){
                return nextTrip;
            }else{
                return null;
            }
        }else{
            return null;
        }

    }

    public double calculateQueueTime()
    {
        List<Trip> queuedTrips = new ArrayList<>();
        tripRepo.getAllQueuedTrips(TripStatus.requested).forEach(queuedTrips::add);
        double cumlativeTime = 0;
        for (Trip t : queuedTrips)
        {
            ServiceLocation home = slService.getServiceLocationWithLocationName("Anna Hiss");
            cumlativeTime += calculateTimeToTravel(t.getPickupLocation(), t.getDropoffLocation()) + calculateTimeToTravel(t.getDropoffLocation(), home) + 10;
        }
        return cumlativeTime;

    }
    public double calculateTimeToTravel(ServiceLocation start, ServiceLocation end)
    {
        System.out.println("Start"  + start.getLatitude() +  ":" + start.getLongitude());
        double averageSpeed = 1.2; // meters per sec of the robot
        double distanceInKM = calculateDistance(start.getLatitude(), start.getLongitude(), end.getLatitude(), end.getLongitude());
        return ((distanceInKM * 1000) / averageSpeed) / 60;
    }
    public double calculateDistance(double lat1, double long1, double lat2, double long2)
    {
        long1 = Math.toRadians(long1);
        long2 = Math.toRadians(long2);
        lat1 = Math.toRadians(lat1);
        lat2 = Math.toRadians(lat2);

        // Haversine formula
        double dlon = long2 - long1;
        double dlat = lat2 - lat1;
        double a = Math.pow(Math.sin(dlat / 2), 2)
                + Math.cos(lat1) * Math.cos(lat2)
                * Math.pow(Math.sin(dlon / 2),2);

        double c = 2 * Math.asin(Math.sqrt(a));

        // Radius of earth in kilometers. Use 3956
        // for miles
        double r = 6371;

        // calculate the result
        return(c * r);

    }

    public List<Trip> getTripsToBeCompleted() {
        List<Trip> tripsToSend = StreamSupport.stream(tripRepo.getTripsToBeSent().spliterator(), false).collect(Collectors.toList());
        for (Trip trip : tripsToSend) {
            if (trip.getSpotManufacturerID() != null) {
                Optional<Spot> optionalSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                optionalSpot.ifPresent(trip::setAssignedSpot);
            }
            User user = userService.getUserbyID(trip.getUserID());
            if(user != null) {
                trip.setUsername(user.getFirstName() + " " + user.getLastName());
            }
        }
        return tripsToSend;
    }

    public List<Trip> getActiveTrips() {
        List<Trip> tripsToSend = StreamSupport.stream(tripRepo.getAllActiveTrips().spliterator(), false).collect(Collectors.toList());
        for (Trip trip : tripsToSend) {
            if (trip.getSpotManufacturerID() != null) {
                Optional<Spot> optionalSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                optionalSpot.ifPresent(trip::setAssignedSpot);
            }
            User user = userService.getUserbyID(trip.getUserID());
            if(user != null) {
                trip.setUsername(user.getFirstName() + " " + user.getLastName());
            }
        }
        return tripsToSend;
    }

    public List<Trip> getReturningHomeTrips() {
        List<Trip> returningHomeTrips = StreamSupport.stream(tripRepo.getAllReturningHomeTrips().spliterator(), false).collect(Collectors.toList());
        for (Trip trip : returningHomeTrips) {
            if (trip.getSpotManufacturerID() != null) {
                Optional<Spot> optionalSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                optionalSpot.ifPresent(trip::setAssignedSpot);
            }
        }
        return returningHomeTrips;
    }

    private void pushTripToManagers() {
        sendingOperations.convertAndSend("/topic/queuedTrips/manager", "{}");
    }

    private void sendCompleteTripToCustomer(Trip activeTrip) {
        Set<String> pushTokensForUser = userService.getPushTokensForUser(activeTrip.getUserID(), false);

        ApnsPayloadBuilder builder = new ApnsPayloadBuilder();
        builder.setAlertBody("Your order has arrived at " + activeTrip.getDropoffLocation().getAcronym()  + ". Please come retrieve your order. Enjoy!");
        builder.setAlertTitle("It's pick up time!");
        builder.setSound("default");
        String payload = builder.buildWithDefaultMaximumLength();
        for (String token: pushTokensForUser) {
            smadsApnsService.sendCustomerNotification(token, payload);
        }
        activeTrip.addNotification(NotificationType.pickup);
        tripRepo.save(activeTrip);
    }

    public void sendRobotOnTrip(int tripId) {
        System.out.println("Sending robot on trip " + tripId);

        Optional<Trip> optionalTrip = tripRepo.findById(tripId);
        if(optionalTrip.isPresent()) {
            Trip trip = optionalTrip.get();
            if (trip.getSpotManufacturerID() != null) {
                trip.setTripStatus(TripStatus.enroute);
                tripRepo.save(trip);
                Optional<Spot> optionalSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                if(optionalSpot.isPresent()) {
                    Spot spot = optionalSpot.get();
                    trip.setAssignedSpot(spot);
                    spot.setStatus(SpotStatus.enroute);
                    spotService.saveSpot(spot);
                    if (environmentConfiguration.shouldCallRobot()) {
                        List<Location> robotResponse = robotClient.sendUserTripToSpot(trip);
                        System.out.println("Sent robot on trip " + tripId + ". Robot returned " + robotResponse.size() + " waypoints.");
                        if (robotResponse.isEmpty()) {
                            //trigger missing spot alert in frontend
                            spotService.missingSpotAlert(spot);
                            //add trip back to queue so that a different spot will service the trip
                            trip.setAssignedSpot(null);
                        } else {
                            List<Waypoint> waypoints = waypointService.createWaypoints(robotResponse, trip);
                            saveWaypointsToTrip(waypoints);

                        }
                        tripRepo.save(trip);
                    } else if (!environmentConfiguration.isAppleModeEnabled()) {
                        startSimulatingRobotSendingLocation(trip);
                    }
                    sendTripUpdateToCustomer(trip);
                }

            } else {
                System.out.println("Error: cannot send robot on trip " + trip.getId() + " because there is no robot");
            }
        } else {
            System.out.println("No trip with id " + tripId);
        }
    }

    public boolean isComplete(int tripId) {
        Optional<Trip> optionalTrip = tripRepo.findById(tripId);
        if (optionalTrip.isPresent()) {
            Trip trip = optionalTrip.get();
            return trip.getTripStatus() == TripStatus.complete;
        }
        return false;
    }

    public void notifyUserTripHasArrived(int tripId) {
        Optional<Trip> optionalTrip = tripRepo.findById(tripId);
        optionalTrip.ifPresent(this::sendCompleteTripToCustomer);
    }
}
