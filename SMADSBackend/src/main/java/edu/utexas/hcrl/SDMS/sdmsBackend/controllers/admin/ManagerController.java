package edu.utexas.hcrl.SDMS.sdmsBackend.controllers.admin;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Manager;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.DeleteManagerRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.NewManagerRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllManagersResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.DeleteManagerResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.ManagerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.annotation.Secured;
import org.springframework.web.bind.annotation.*;

@Secured("ROLE_MANAGER")
@RestController
@RequestMapping("/managers")
public class ManagerController {

    @Autowired
    private ManagerService managerService;

    @ResponseBody
    @GetMapping("/")
    public AllManagersResponse getAllManagers() {
        return new AllManagersResponse(managerService.getAllAuthorizedManagers());
    }

    @ResponseBody
    @PostMapping("/")
    public Manager createNewManager(@RequestBody NewManagerRequest newManagerRequest) {
        return managerService.addAuthorizedManager(newManagerRequest.getEmailAddress());
    }

    @ResponseBody
    @DeleteMapping("/")
    public DeleteManagerResponse deleteManager(@RequestBody DeleteManagerRequest request) {
        return new DeleteManagerResponse(managerService.deleteAuthorizedManager(request.getEmailAddress()));
    }

}
