package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Privilege;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PrivilegeRepository extends CrudRepository<Privilege, Long> {
    @Query("select p from Privilege p where p.name = ?1")
    Privilege findByName(String name);
}
