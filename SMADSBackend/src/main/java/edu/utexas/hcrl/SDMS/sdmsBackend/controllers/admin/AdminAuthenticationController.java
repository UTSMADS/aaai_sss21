package edu.utexas.hcrl.SDMS.sdmsBackend.controllers.admin;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.AuthenticationRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AuthenticationResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.annotation.Secured;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@Secured("ROLE_MANAGER")
@RestController
@RequestMapping("/admin/auth")
public class AdminAuthenticationController {
    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private UserService userService;

    @ResponseBody
    @PostMapping("/signupManager")
    public AuthenticationResponse createManager(@RequestBody AuthenticationRequest authenticationRequest, HttpServletRequest request) throws Exception {
        AuthenticationResponse authenticationResponse = new AuthenticationResponse();
        User savedUser = userService.createNewUser(authenticationRequest.getUsername(), authenticationRequest.getPassword(), authenticationRequest.getName(), RoleTypes.MANAGER);

        String token = jwtUtil.generateToken(savedUser.getId());
        authenticationResponse.setToken(token);
        authenticationResponse.setManager(savedUser.isManager());

        return  authenticationResponse;
    }
}
