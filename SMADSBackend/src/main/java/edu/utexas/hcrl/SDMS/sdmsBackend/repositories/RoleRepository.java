package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Role;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoleRepository extends CrudRepository<Role, Long> {

    @Query("select r from Role r where r.name = ?1")
    Role findByName(String name);

}
