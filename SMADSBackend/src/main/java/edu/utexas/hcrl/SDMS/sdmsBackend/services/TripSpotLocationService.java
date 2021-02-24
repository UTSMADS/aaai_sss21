package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.TripSpotLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.SpotLocationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TripSpotLocationService {

    @Autowired
    private SpotLocationRepository spotLocationRepository;

    public TripSpotLocation createTripSpotLocation(TripSpotLocation tripSpotLocation)
    {
        return spotLocationRepository.save(tripSpotLocation);
    }

    public List<TripSpotLocation> getSpotLocationsForTrip(Trip trip)
    {
        return spotLocationRepository.getSpotLocationsForTrip(trip);
    }


}
