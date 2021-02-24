package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Store;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StoreRepository  extends CrudRepository<Store, Integer> {
    @Modifying
    @Query("UPDATE Store s SET s.isOpen = ?2 WHERE s.id=?1")
    void setStoreStatus(int id, boolean open);

    @Query("SELECT s.isOpen FROM Store s WHERE s.id = ?1")
    boolean getStoreStatus(int id);

    @Modifying
    @Query("UPDATE Store s SET s.hoursDescription = ?2 WHERE s.id = ?1")
    void updateStoreDescription(int lemonadeStoreNumer, String description);
}
