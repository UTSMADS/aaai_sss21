package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;


import edu.utexas.hcrl.SDMS.sdmsBackend.enums.LocationType;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.ServiceLocation;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AvailableServiceLocationsResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.RequestService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.ServiceLocationsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.List;

@RestController
@RequestMapping("/serviceLocations")
public class ServiceLocationController {

    @Autowired
    private ServiceLocationsService serviceLocationsService;

    @Autowired
    private RequestService requestService;

    @ResponseBody
    @GetMapping("/")
    public AvailableServiceLocationsResponse getAllServiceLocations(@RequestParam(required = false) LocationType type, @RequestParam(required = false) Boolean shouldCalculateETA)
    {
        if(shouldCalculateETA == null){
            shouldCalculateETA = false;
        }
        AvailableServiceLocationsResponse response = new AvailableServiceLocationsResponse();
        List<ServiceLocation> locations = serviceLocationsService.getAvailableServiceLocations(type);
        //locations.remove(serviceLocationsService.getServiceLocationWithLocationName("Anna Hiss"));
        if (shouldCalculateETA)
        {
            double queueTime = requestService.calculateQueueTime();
            double tripTime=0;
            ServiceLocation start = getServiceLocationWithLocationName("Anna Hiss");
            for (ServiceLocation l : locations)
            {
                tripTime = requestService.calculateTimeToTravel(start, l) + 10;
                l.setEta((int) (queueTime + tripTime));
            }

        }
        response.setServiceLocationList(locations);
        return response;
    }
    @ResponseBody
    @GetMapping("/{locationName}")
    public ServiceLocation getServiceLocationWithLocationName(@PathVariable String locationName)
    {
       return serviceLocationsService.getServiceLocationWithLocationName(locationName);
    }

    @ResponseBody
    @PostMapping("/")
    public ServiceLocation saveServiceLocation(@RequestBody ServiceLocation serviceLocation)
    {
        serviceLocation.setActive(true);
        return serviceLocationsService.save(serviceLocation);
    }

    @ResponseBody
    @DeleteMapping("/{databaseID}")
    public ServiceLocation deactivateServiceLocation(@PathVariable Integer databaseID, HttpServletResponse response)
    {
        ServiceLocation sl = serviceLocationsService.deactivateServiceLocation(databaseID);
        if(sl==null)
        {
            response.setStatus(HttpStatus.NOT_FOUND.value());
        }
        return sl;
    }

    @ResponseBody
    @PutMapping("/{databaseID}")
    public ServiceLocation reactivateServiceLocation(@PathVariable Integer databaseID, HttpServletResponse response)
    {
        ServiceLocation sl = serviceLocationsService.reactivateServiceLocation(databaseID);
        if(sl==null)
        {
            response.setStatus(HttpStatus.NOT_FOUND.value());
        }
        return sl;
    }




}
