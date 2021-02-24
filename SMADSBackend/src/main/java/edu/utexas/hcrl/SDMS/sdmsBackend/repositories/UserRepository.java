package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends CrudRepository<User, Integer> {

    @Query("select u from User u where u.username = ?1")
    Optional<User> findByUsername(String username);

    @Query("select u from User u inner join u.roles r where u.isActive = true and u.roles in (select r from Role r where r.name = 'ROLE_CUSTOMER') order by u.id")
    List<User> getAllActiveCustomers();

}
