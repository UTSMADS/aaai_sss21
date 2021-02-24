package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.ServiceLocationRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.LocationType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class ServiceLocationsService {

    @Autowired
    private ServiceLocationRepository serviceLocationRepo;

    public List<ServiceLocation> getAvailableServiceLocations(LocationType type)
    {
        if(type == null)
        {
            Iterable<ServiceLocation> allLocs = serviceLocationRepo.findAll();
            List<ServiceLocation> sl = new ArrayList<>();
            allLocs.forEach(sl::add);
            return sl;
        }
        return serviceLocationRepo.getActiveServiceLocationsByType(type);
    }

    public List<ServiceLocation> getAvailableDropoffLocations(int slId)
    {
        return serviceLocationRepo.getActiveServiceLocationsExcludingPickupLocation(slId);
    }

    public ServiceLocation save(ServiceLocation serviceLocation){return serviceLocationRepo.save(serviceLocation);}

    public ServiceLocation deactivateServiceLocation(Integer databaseID) {
      return changeServiceLocationActivationState(databaseID, false);
    }

    public ServiceLocation reactivateServiceLocation(Integer databaseID) {
        return changeServiceLocationActivationState(databaseID, true);
    }

    private ServiceLocation changeServiceLocationActivationState(Integer databaseID, boolean isActive) {
        Optional<ServiceLocation> sl = serviceLocationRepo.findById(databaseID);
        if(sl.isPresent())
        {
            ServiceLocation loc = sl.get();
            loc.setActive(isActive);
            return serviceLocationRepo.save(loc);
        }
        return null;
    }

    public ServiceLocation getAvailableHomePoint() {
        Iterable <ServiceLocation> sl = serviceLocationRepo.getAvailableHome();
        List<ServiceLocation> slList = new ArrayList<>();
        slList.forEach(slList::add);

        if (slList.size() == 0)
        {
            return null;
        }
        return slList.get(0);

    }
    public ServiceLocation getServiceLocationWithLocationName(String locationName){
        Optional<ServiceLocation> sl = serviceLocationRepo.findServiceLocationWithLocationName(locationName);
        if (sl.isPresent()){
            return sl.get();
        }else{
            return null;
        }
    }
}
