package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;


import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Waypoint;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface WaypointRepo extends CrudRepository<Waypoint, Integer> {
    @Query("select w from Waypoint w where w.trip = ?1")
    Iterable<Waypoint> getAllWaypointsForTrip(Trip trip);
}
