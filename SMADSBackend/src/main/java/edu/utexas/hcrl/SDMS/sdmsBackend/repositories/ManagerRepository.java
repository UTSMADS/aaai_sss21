package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Manager;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ManagerRepository extends CrudRepository<Manager, String> {
}
