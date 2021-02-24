package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.RobotClient;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.NewRequestResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.TripsToCompleteResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.BadServiceLocationIdException;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.NoAvailableSpotForTripException;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.TripRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.RequestService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.ServiceLocationsService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.SpotService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Optional;

@RestController
@RequestMapping("/requests")
public class RequestController {
    @Autowired
    private RequestService requestService;
    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private RobotClient robotClient;
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;
    @Autowired
    private ServiceLocationsService slService;
    @Autowired
    private SpotService spotService;
    @Autowired
    private UserService userService;

    @ResponseBody
    @PostMapping("/")
    public NewRequestResponse createTrip(@RequestBody TripRequest tripRequest, HttpServletRequest request, HttpServletResponse response) {
        try {
            int userID = jwtUtil.getUserIDFromToken(request);
            int pickupLocationId = tripRequest.getPickupLocID();

            if (pickupLocationId == -1) {
                ServiceLocation home = slService.getAvailableHomePoint();
                if (home != null) {
                    pickupLocationId = home.getId();
                } else {
                    ServiceLocation annaHiss = slService.getServiceLocationWithLocationName("Anna Hiss");
                    pickupLocationId = annaHiss.getId();
                }
            }
            // Uncomment this if we want to limit the number of trips per user to 1.
//            if (!environmentConfiguration.isAppleModeEnabled() && userService.userHasTrip(userID)) {
//                return new NewRequestResponse(null,true, environmentConfiguration.isAppleModeEnabled());
//            }
            return new NewRequestResponse(requestService.createNewTrip(pickupLocationId, tripRequest.getDropoffLocID(), tripRequest.getPayloadContent(), userID, tripRequest.getEta()), false, environmentConfiguration.isAppleModeEnabled());
        } catch (BadServiceLocationIdException | UserNotFoundException | NoAvailableSpotForTripException e) {
            //In a later iteration, we will send information to the Client to indicate what error occurred and how the customer can handle it
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        return null;
    }

    @ResponseBody
    @DeleteMapping("/{tripId}")
    public boolean deleteTrip(@PathVariable Integer tripId, HttpServletResponse response)
    {
        Trip cancelledTrip = requestService.deleteTrip(tripId);
        if (environmentConfiguration.shouldCallRobot())
        {
            return robotClient.cancelTrip(cancelledTrip);
        }

        return true;



    }

    @ResponseBody
    @GetMapping("/{tripId}/status")
    public Trip getTripStatus(@PathVariable int tripId) {
        System.out.println("Getting trip status for trip " + tripId);
        return requestService.getTripById(tripId);
    }

    @ResponseBody
    @GetMapping("/{tripId}")
    public Spot getSpotAssignedToTrip(@PathVariable int tripId, HttpServletResponse response)
    {
        Trip assignedTrip = requestService.getTripById(tripId);
        if(assignedTrip != null) {
            return assignedTrip.getAssignedSpot();
        }
        else{
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return null;
        }

    }
    @ResponseBody
    @PutMapping("/{tripID}/complete")
    public boolean completeTrip(@PathVariable int tripID, HttpServletResponse response) {
        return requestService.closeTrip(tripID);
    }

    @ResponseBody
    @GetMapping("{tripID}/hasRobot")
    public Trip doesTripHaveRobot(@PathVariable int tripID)
    {
        Trip trip = requestService.getTripById(tripID);
        if (trip != null)
        {
            if (trip.getSpotManufacturerID() == null){
                return null;
            }else {
                Optional<Spot> assignedSpot = spotService.getSpotById(trip.getSpotManufacturerID());
                if (assignedSpot.isPresent()){
                    trip.setAssignedSpot(assignedSpot.get());
                }
                return trip;
            }
        }else{
            return null;
        }
    }

    @ResponseBody
    @GetMapping("/notcomplete")
    public TripsToCompleteResponse getAllTripsToComplete() {
        return new TripsToCompleteResponse(requestService.getTripsToBeCompleted(), requestService.getActiveTrips(), requestService.getReturningHomeTrips());
    }

    @ResponseBody
    @PostMapping("/{tripId}/send")
    public void sendRobotOnTrip(@PathVariable int tripId) {
        requestService.sendRobotOnTrip(tripId);
    }

    @ResponseBody
    @PostMapping("/{tripId}/arrived")
    public void notifyUserTripHasArrived(@PathVariable int tripId) { requestService.notifyUserTripHasArrived(tripId);}
}
