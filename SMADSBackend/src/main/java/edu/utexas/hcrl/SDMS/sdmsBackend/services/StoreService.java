package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.configuration.EnvironmentConfiguration;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Store;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.StoreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;


@Service
public class StoreService {
    @Autowired
    private EnvironmentConfiguration environmentConfiguration;
    @Autowired
    private StoreRepository storeRepository;

    @Transactional
    public Store updateStoreStatus(boolean open) {
        storeRepository.setStoreStatus(Store.LEMONADE_STORE_NUMER, open);
        return getStoreStatus();
    }

    public Store getStoreStatus() {
        if (environmentConfiguration.isAppleModeEnabled()) {
                 Store store = storeRepository.findById(Store.LEMONADE_STORE_NUMER).get();
                 store.setOpen(true);
                 return storeRepository.save(store);
        }
        return storeRepository.findById(Store.LEMONADE_STORE_NUMER).get();
    }

    @Transactional
    public Store updateStoreDescription(String description) {
        storeRepository.updateStoreDescription(Store.LEMONADE_STORE_NUMER, description);
        return getStoreStatus();
    }
}
