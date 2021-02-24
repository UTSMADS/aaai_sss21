package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.TripSpotLocation;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SpotLocationRepository extends CrudRepository<TripSpotLocation, Integer>  {
    @Query("select spotLoc from TripSpotLocation spotLoc where spotLoc.trip = ?1")
    List<TripSpotLocation> getSpotLocationsForTrip(Trip trip);
}
