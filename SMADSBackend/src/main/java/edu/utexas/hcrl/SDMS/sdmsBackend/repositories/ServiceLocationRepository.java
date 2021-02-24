package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.LocationType;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ServiceLocationRepository extends CrudRepository<ServiceLocation, Integer> {
    @Query("select sl from ServiceLocation sl where sl.isActive = true and sl.locationType = ?1 order by sl.id")
    List<ServiceLocation> getActiveServiceLocationsByType(LocationType type);

    @Query("select sl from ServiceLocation sl where sl.isActive = true and sl.id = ?1")
    Optional<ServiceLocation> getActiveServiceLocationByID(Integer id);

    @Query("select sl from ServiceLocation sl where sl.isActive = true and sl.isHome = true and sl.numAvailableChargers >0 order by sl.id")
    List<ServiceLocation> getAvailableHome();


    @Query("select sl from ServiceLocation  sl where sl.isActive = true and sl.id <> ?1 order by sl.id ")
    List<ServiceLocation> getActiveServiceLocationsExcludingPickupLocation(int slId);

    @Query("select sl from ServiceLocation sl where sl.locationName = ?1")
    Optional<ServiceLocation> findServiceLocationWithLocationName(String locationName);

}
