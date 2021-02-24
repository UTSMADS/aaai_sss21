package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.TripStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserAlreadyExistsException;
import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.*;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.RoleRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.TripRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

@Service
public class UserService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RequestService tripService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private ManagerService managerService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<User> userOptional = userRepository.findByUsername(username);
        if (userOptional.isEmpty()) throw new UsernameNotFoundException("No user with username " + username);
        User user = userOptional.get();
        return new org.springframework.security.core.userdetails.User(user.getId().toString(), user.getPassword(), user.isActive(), true, true, true, getAuthorities(user.getRoles()));
    }

    @Transactional
    public UserDetails loadUserById(int userId) throws UserNotFoundException {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) throw new UserNotFoundException("No user with username " + userId);
        User user = userOptional.get();
        org.springframework.security.core.userdetails.User user1 = new org.springframework.security.core.userdetails.User(user.getId().toString(), user.getPassword(), user.isActive(), true, true, true, getAuthorities(user.getRoles()));
        return user1;
    }

    public boolean deleteUser(String email){
        Optional<User> userOptional = userRepository.findByUsername(email);
        if(userOptional.isPresent()){
            User user = userOptional.get();
            user.setActive(false);
            userRepository.save(user);
            return true;
        } else {
            return false;
        }

    }
    public User createNewUser(String username, String clearPassword, String name, RoleTypes type) throws UserAlreadyExistsException {
        Role userRole = roleRepository.findByName(type.toString());
        User newUser = new User(userRole);
        User potentialExistingUser = getUserByUsername(username);
        if (potentialExistingUser == null) {
            newUser.setUsername(username);
            newUser.setPassword(passwordEncoder.encode(clearPassword));
            if(name != null) {
                List<String> names = Arrays.asList(name.split(" "));
                newUser.setFirstName(names.get(0));
                if (names.size() > 1)
                {
                    newUser.setLastName(names.get(1));
                }

            }
            return userRepository.save(newUser);
        }
        throw new UserAlreadyExistsException("User already exists in the database");
    }

    public User createNewUser(String username, String clearPassword, String givenName, String familyName, RoleTypes type) throws UserAlreadyExistsException {
        Role userRole = roleRepository.findByName(type.toString());
        User newUser = new User(userRole);
        User potentialExistingUser = getUserByUsername(username);
        if (potentialExistingUser == null) {
            newUser.setUsername(username);
            newUser.setPassword(passwordEncoder.encode(clearPassword));
            newUser.setFirstName(givenName);
            newUser.setLastName(familyName);
            return userRepository.save(newUser);
        }
        throw new UserAlreadyExistsException("User already exists in the database");
    }




    public User createNewRobot(String username, String clearPassword, String name){
        Role robotRole = roleRepository.findByName(RoleTypes.ROBOT.toString());
        User newUser = new User(robotRole);
        newUser.setUsername(username);
        newUser.setPassword(passwordEncoder.encode(clearPassword));
        List<String> names = Arrays.asList(name.split(" "));
        String firstname = names.get(0);
        String lastname;
        if (names.size() > 1)
        {
            lastname = names.get(1);
            newUser.setLastName(lastname);
        }
        newUser.setFirstName(firstname);
        return userRepository.save(newUser);
    }

    public User getUserByUsername(String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        return optionalUser.orElse(null);
    }

    public User getUserbyID(int userID){
        Optional<User> user =  userRepository.findById(userID);
        return user.orElse(null);
    }
    public List<User> getAllActiveCustomers( )
    {
        return userRepository.getAllActiveCustomers();
    }

    public List<Trip> getAllTripsForCustomer(int customerID){
        Optional<User> user = userRepository.findById(customerID);
        List<Trip> trips =  new ArrayList<>();
        if (user.isPresent()){
            trips = tripService.getAllTripsForCustomer(customerID);
        }
        return trips;
    }

    private List<String> getPrivileges(Collection<Role> roles) {

        List<String> privileges = new ArrayList<>();
        List<Privilege> collection = new ArrayList<>();
        for (Role role : roles) {
            collection.addAll(role.getPrivileges());
        }
        for (Privilege item : collection) {
            privileges.add(item.getName());
        }
        return privileges;
    }

    private Collection<? extends GrantedAuthority> getAuthorities(Collection<Role> roles) {
//        return getGrantedAuthorities(getPrivileges(roles));
        return getGrantedAuthorities(roles.stream().map(r -> "ROLE_" + r.getName()).collect(Collectors.toList()));
    }

    private List<GrantedAuthority> getGrantedAuthorities(List<String> roles) {
        List<GrantedAuthority> authorities = new ArrayList<>();
        for (String role : roles) {
            authorities.add(new SimpleGrantedAuthority(role));
        }
        return authorities;
    }
    public List<Trip> getActiveTripForCustomer (int userID) {
        List<Trip> tripList = new ArrayList<>();
        tripRepository.getActiveTripForCustomer(userID).forEach(tripList::add);
        return tripList;
    }

    public User saveUser(User newUser){
        return userRepository.save(newUser);
    }

    public boolean userHasTrip(int userId) {
        Iterable<Trip> allTripsForUser = tripRepository.getAllTripsForUser(userId);
        Stream<Trip> tripsStream = StreamSupport.stream(allTripsForUser.spliterator(), false);
        List<Trip> allTrips = tripsStream.collect(Collectors.toList());
        for (Trip t: allTrips) {
            if (t.getTripStatus() != TripStatus.cancelled) {
                return true;
            }
        }
        return false;
    }

    public boolean addTokenForUser(String token, int userId, boolean isManager) {
        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.addToken(token, isManager);
            userRepository.save(user);
            return true;
        } else {
            return false;
        }
    }

    public Set<String> getPushTokensForUser(int userId, boolean manager) {
        Set<String> tokens = new HashSet<>();

        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            if (user.getPushTokens() != null) {
                user.getPushTokens().stream().filter(t -> t.isManagerToken() == manager).forEach(t -> tokens.add(t.getToken()));
            }
        }
        return tokens;
    }

    public Set<String> getPushTokensForAllManagers() {
        List<Manager> allAuthorizedManagers = managerService.getAllAuthorizedManagers();
        List<User> managerUsers = new ArrayList<>();
        Set<String> managerPushTokens = new HashSet<>();
        for(Manager m: allAuthorizedManagers) {
            User u = getUserByUsername(m.getEmailAddress());
            if (u != null) {
                managerPushTokens.addAll(u.getPushTokens().stream().map(t -> t.getToken()).collect(Collectors.toList()));
            }
        }
        return managerPushTokens;
    }
}
