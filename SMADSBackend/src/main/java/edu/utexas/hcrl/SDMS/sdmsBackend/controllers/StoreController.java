package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.StoreDescriptionRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.StoreStatusRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.StoreStatusResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.StoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/stores")
public class StoreController {

    @Autowired
    private StoreService storeService;

    @PostMapping("/status")
    public StoreStatusResponse updateStoreStatus(@RequestBody StoreStatusRequest request) {
        return new StoreStatusResponse(storeService.updateStoreStatus(request.isOpen()));
    }

    @GetMapping("/status")
    public StoreStatusResponse getStoreStatus() {

        return new StoreStatusResponse(storeService.getStoreStatus());
    }

    @PostMapping("/description")
    public StoreStatusResponse updateStoreDescription(@RequestBody StoreDescriptionRequest request) {
        return new StoreStatusResponse(storeService.updateStoreDescription(request.getDescription()));
    }
}
