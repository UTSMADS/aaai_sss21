package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Spot;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllTripsResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.SpotService;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.UserService;
import edu.utexas.hcrl.SDMS.sdmsBackend.utils.JWTUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;
    @Autowired
    private JWTUtil jwtUtil;
    @Autowired
    private SpotService spotService;

    @ResponseBody
    @GetMapping("/trips")
    public AllTripsResponse getAllTripsForCustomer(HttpServletRequest request, HttpServletResponse response){
        try {
            int userID = jwtUtil.getUserIDFromToken(request);
            List<Trip> trips = userService.getAllTripsForCustomer(userID);
            return new AllTripsResponse(trips);
        } catch (UserNotFoundException e) {
            e.printStackTrace();
            response.setStatus(405);
            return null;
        }
    }
    @ResponseBody
    @GetMapping("/activeTrip")
    public Trip getActiveTripForCustomer(HttpServletRequest request, HttpServletResponse response){
        try {
            int userID = jwtUtil.getUserIDFromToken(request);
             List<Trip> tripsForUser = userService.getActiveTripForCustomer(userID);
             if (!tripsForUser.isEmpty()){
                 Trip currentTrip = tripsForUser.get(0);
                 if (currentTrip.getSpotManufacturerID() != null)
                 {
                     Optional<Spot> assignedSpot = spotService.getSpotById(currentTrip.getSpotManufacturerID());
                     assignedSpot.ifPresent(currentTrip::setAssignedSpot);
                 }
                 return currentTrip;
             }else{
                 return null;
             }
        } catch (UserNotFoundException e){
            e.printStackTrace();
            response.setStatus(405);
            return null;
        }
    }

    @ResponseBody
    @GetMapping("/userInfo")
    public User getUserInfo(HttpServletRequest request, HttpServletResponse response){
        try{
            int userID = jwtUtil.getUserIDFromToken(request);
            return userService.getUserbyID(userID);
        }catch (UserNotFoundException e){
            e.printStackTrace();
            response.setStatus(405);
            return null;
        }
    }

    @ResponseBody
    @PutMapping("/updateUserInfo")
    public User updateUserInfo(@RequestBody User newUpdateUserInfo, HttpServletRequest request, HttpServletResponse response){
        try{
            int userID = jwtUtil.getUserIDFromToken(request);
            User userInfo = userService.getUserbyID(userID);
            String firstName = newUpdateUserInfo.getFirstName();
            String lastName = newUpdateUserInfo.getLastName();
            String previousUsername = userInfo.getUsername();
            if (userService.getUserByUsername(newUpdateUserInfo.getUsername()) == null || previousUsername.equals(newUpdateUserInfo.getUsername())){
                if (firstName != null && lastName != null && newUpdateUserInfo.getUsername() != null) {
                    userInfo.setFirstName(firstName);
                    userInfo.setLastName(lastName);
                    userInfo.setUsername(newUpdateUserInfo.getUsername());
                }
                return userService.saveUser(userInfo);
            }
            return null;
        }catch (UserNotFoundException e) {
            e.printStackTrace();
            response.setStatus(405);
            return null;
        }

    }
}
