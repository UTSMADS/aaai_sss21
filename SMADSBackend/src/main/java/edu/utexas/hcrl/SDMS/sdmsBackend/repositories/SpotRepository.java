package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SpotRepository extends CrudRepository<Spot, Integer> {
    @Query("select s from Spot s where s.isActive = true")
    Iterable<Spot> getAllActiveSpots();

    @Query("select s from Spot s where s.manufacturerID = ?1")
    Optional<Spot> getSpotByManufacturerID(Integer id);

}
