package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.GoogleAuthenticationClient.GoogleClient;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserAlreadyExistsException;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.AuthenticationRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.requests.GoogleAuthenticationRequest;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllActiveUsersResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AuthenticationResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.ValidTokenResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.SpotService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthenticationController {

    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private AuthenticationManager authenticationManager;
    @Autowired
    private UserService userService;
    @Autowired
    private SpotService spotService;
    @Autowired
    private GoogleClient googleClient;

    @ResponseBody
    @PostMapping("/registerGoogleUser")
    public AuthenticationResponse registerUser(@RequestBody GoogleAuthenticationRequest request, HttpServletResponse response )
    {
        AuthenticationResponse authenticationResponse = new AuthenticationResponse();
        //check that google id token in the request is valid by authenticating with google
        try {
            User potentialVerifiedUser = googleClient.validateGoogleIdToken(request.getIdToken());
            if (potentialVerifiedUser != null) {
                String token = jwtUtil.generateToken(potentialVerifiedUser.getId());
                authenticationResponse.setToken(token);
                authenticationResponse.setManager(potentialVerifiedUser.isManager());
                authenticationResponse.setCustomerTrip(null);

                if(potentialVerifiedUser.isManager()) {
                    authenticationResponse.setManager(true);
                }
                List<Trip> activeTrips = userService.getActiveTripForCustomer(potentialVerifiedUser.getId());
                if(activeTrips.size() > 0){
                    Trip activeTrip = activeTrips.get(0);
                    if(activeTrip.getSpotManufacturerID() != null){
                        Optional<Spot> assignedSpot = spotService.getSpotById(activeTrip.getSpotManufacturerID());
                        assignedSpot.ifPresent(activeTrip::setAssignedSpot);
                    }
                    authenticationResponse.setCustomerTrip(activeTrip);
                }
                return  authenticationResponse;
            } else {
                return null;
            }
        } catch (GeneralSecurityException | IOException e) {
            e.printStackTrace();
            System.out.println(request);
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
    }

    @ResponseBody
    @PostMapping("/login")
    public AuthenticationResponse login(@RequestBody AuthenticationRequest authenticationRequest, HttpServletResponse response) throws Exception {
        AuthenticationResponse authenticationResponse = new AuthenticationResponse();
        try {
            Authentication authenticate = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(authenticationRequest.getUsername(), authenticationRequest.getPassword()));
            UserDetails userDetails = (UserDetails)authenticate.getPrincipal();
            String token = jwtUtil.generateToken(userDetails.getUsername());
            //user details username is actually the db user id number not the username defined by the client
            User user = userService.getUserbyID(Integer.parseInt(userDetails.getUsername()));
            authenticationResponse.setToken(token);

            authenticationResponse.setManager(user.isManager());
            authenticationResponse.setCustomerTrip(null);

            if(!user.isManager()){
                List<Trip> activetrips = userService.getActiveTripForCustomer(user.getId());
                if(activetrips.size() >0){
                    Trip activeTrip = activetrips.get(0);
                    if(activeTrip.getSpotManufacturerID() != null){
                        Optional<Spot> assignedSpot = spotService.getSpotById(activeTrip.getSpotManufacturerID());
                        assignedSpot.ifPresent(activeTrip::setAssignedSpot);
                    }
                    authenticationResponse.setCustomerTrip(activeTrip);
                }
            }
            return  authenticationResponse;
        } catch (Exception e) {
            System.out.println(authenticationRequest);
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
    }

    @ResponseBody
    @PostMapping("/signup")
    public AuthenticationResponse createCustomer(@RequestBody AuthenticationRequest authenticationRequest) throws Exception {
        AuthenticationResponse authenticationResponse = new AuthenticationResponse();
        try {
            User savedUser = userService.createNewUser(authenticationRequest.getUsername(), authenticationRequest.getPassword(), authenticationRequest.getName(), RoleTypes.CUSTOMER);
            String token = jwtUtil.generateToken(savedUser.getId());

            authenticationResponse.setToken(token);
            authenticationResponse.setCustomerTrip(null);
            return  authenticationResponse;

        }catch(UserAlreadyExistsException e)
        {
            return authenticationResponse;
        }

    }

    @ResponseBody
    @DeleteMapping("/{username}")
    public boolean deleteUser(@PathVariable String username, HttpServletResponse response)
    {
        boolean isDeleted = userService.deleteUser(username);
        if(!isDeleted)
        {
            response.setStatus(HttpStatus.NOT_FOUND.value());
        }
        return isDeleted;
    }

    @ResponseBody
    @GetMapping("/")
    public AllActiveUsersResponse getAllUsers(){
        AllActiveUsersResponse response = new AllActiveUsersResponse();
        response.setUserList(userService.getAllActiveCustomers());
        return response;

    }

    @ResponseBody
    @PostMapping("/validateToken")
    public ValidTokenResponse isTokenValidForCustomerAndManager(HttpServletRequest request) {
        try {
            int userId = jwtUtil.getUserIDFromToken(request);
            User user = userService.getUserbyID(userId);
            List<Trip> trips = userService.getActiveTripForCustomer(userId);
            if(trips.size() > 0) {
                //user is a customer who has an active trip
                    Trip activeTrip = trips.get(0);
                    if(activeTrip.getSpotManufacturerID() != null) {
                        Optional<Spot> assignedSpot = spotService.getSpotById(activeTrip.getSpotManufacturerID());
                        if (assignedSpot.isPresent()) {
                            activeTrip.setAssignedSpot(assignedSpot.get());
                        }
                    }

                return new ValidTokenResponse(!user.isManager(), activeTrip);
            }else{
                //user is a customer who does not have an active trip
                return new ValidTokenResponse(!user.isManager(), null);
            }
        } catch (UserNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
}

