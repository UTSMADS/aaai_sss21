package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.Location;
import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.controllers.SpotController;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.StatusTimestamp;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.NewSpotConditionRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class RobotConditionUpdater implements Runnable {

    private static final double updateFrequency = .01; // Spot update frequency in seconds

    @Autowired
    private WaypointService waypointService;
    @Autowired
    private SpotController spotController;
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;

    private Trip trip;

    public void setup(Trip trip) {
        this.trip = trip;
    }

    @Override
    public void run() {
        int spotId = trip.getSpotManufacturerID();
        ServiceLocation pickupLocation = trip.getPickupLocation();
        ServiceLocation dropoffLocation = trip.getDropoffLocation();

        List<Location> locations = new ArrayList<>();

        // Make the simulation start and stop at the same locations as the trip
        locations.add(new Location(pickupLocation));
        locations.addAll(waypointService.getLocationsFromFile());
        locations.add(new Location(dropoffLocation));
        try {
            for(int i = 0; i < locations.size(); i+=10) {
                Thread.sleep((int)(updateFrequency * 1000));
                Location loc = locations.get(i);
                NewSpotConditionRequest request = new NewSpotConditionRequest();
                request.setChargeLevel(100);
                request.setHeading(i == 0 ? 0 : getHeading(locations.get(i-1), loc));
                request.setLatitude(loc.getLatitude());
                request.setLongitude(loc.getLongitude());
                request.setSpotStatus(SpotStatus.enroute);
                request.setTimestamp(new StatusTimestamp(i, 100));
                spotController.updateSpotStatus(spotId, request);
                System.out.println(request.getSpotStatus());
            }
            // Make sure to send the dropoff location.
            // Since the for loop goes 5 by 5, it skips the dropoff
            NewSpotConditionRequest request = new NewSpotConditionRequest();
            request.setChargeLevel(100);
            request.setHeading(0);
            request.setLatitude(locations.get(locations.size() - 1).getLatitude());
            request.setLongitude(locations.get(locations.size() - 1).getLongitude());
            request.setSpotStatus(SpotStatus.dropoff);
            request.setTimestamp(new StatusTimestamp(locations.size(), 100));
            spotController.updateSpotStatus(spotId, request);
            System.out.println(request.getSpotStatus());
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private double getHeading(Location previousLocation, Location loc) {
        double degToRad = Math.PI / 180.0;
        double phi1 = previousLocation.getLatitude() * degToRad;
        double phi2 = loc.getLatitude() * degToRad;
        double lam1 = previousLocation.getLongitude() * degToRad;
        double lam2 = loc.getLongitude() * degToRad;
        double rads = Math.atan2(Math.sin(lam2-lam1)*Math.cos(phi2), Math.cos(phi1)*Math.sin(phi2) - Math.sin(phi1)*Math.cos(phi2)*Math.cos(lam2-lam1));
        double result = rads;
        if (result < 0) {
            result = rads + 2 * Math.PI;
        } else if (result > 2 * Math.PI) {
            result = rads - 2 * Math.PI;
        }
        return result;
    }
}
