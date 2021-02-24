package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.responses.Location;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Waypoint;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.WaypointRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

@Service
public class WaypointService {

    @Autowired
    private WaypointRepo waypointRepo;

    public List<Waypoint> createWaypoints(List<Location> locations, Trip trip) {
        List<Waypoint> waypoints = new ArrayList<>();
        for (Location loc: locations) {
            Waypoint wp = new Waypoint();
            wp.setLatitude(loc.getLatitude());
            wp.setLongitude(loc.getLongitude());
            wp.setTrip(trip);
            waypoints.add(wp);
        }
        waypointRepo.saveAll(waypoints);
        return waypoints;
    }

    public List<Location> getDefaultTripWaypoints() {
        return getLocationsFromFile("waypoints.txt", 0, 1, false);
    }

    public List<Location> getLocationsFromFile() {
        return getLocationsFromFile("gpslocalization.txt", 4, 5, true);
    }

    private List<Location> getLocationsFromFile(String resourceName, int latIndex, int lngIndex, boolean fileHasHeader) {
        List<Location> result = new ArrayList<>();
        try {
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourceName);
            BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
            if (fileHasHeader) br.readLine();
            String line = null; // initialize
            while ((line = br.readLine()) != null) {
                String[] fields = line.split(",");
                double latit = Double.parseDouble(fields[latIndex]);
                double longit = Double.parseDouble(fields[lngIndex]);
                Location p = new Location(latit, longit);
                result.add(p);
            }
        } catch (IOException e){
            System.out.println("Error: File not found.");
        }
        return result;
    }
}
