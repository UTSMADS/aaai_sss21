package edu.utexas.hcrl.SDMS.sdmsBackend.configuration;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.LocationType;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.*;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import javax.transaction.Transactional;
import java.time.ZonedDateTime;
import java.util.*;

@Component
public class SetupDataLoader implements ApplicationListener<ContextRefreshedEvent> {

    boolean alreadySetup = false;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PrivilegeRepository privilegeRepository;

    @Autowired
    private ServiceLocationRepository slRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private IssueRepository issueRepository;

    @Autowired
    private StoreRepository storeRepository;

    @Autowired
    private ManagerRepository managerRepository;

    @Override
    @Transactional
    public void onApplicationEvent(ContextRefreshedEvent event) {

        if (alreadySetup)
            return;
        Privilege readPrivilege = createPrivilegeIfNotFound("READ_PRIVILEGE");
        Privilege writePrivilege = createPrivilegeIfNotFound("WRITE_PRIVILEGE");

        List<Privilege> managerPrivileges = Arrays.asList(readPrivilege, writePrivilege);
        createRoleIfNotFound(RoleTypes.MANAGER.toString(), managerPrivileges);
        createRoleIfNotFound(RoleTypes.CUSTOMER.toString(), Arrays.asList(readPrivilege));
        createRoleIfNotFound(RoleTypes.ROBOT.toString(), Arrays.asList(readPrivilege));

        Optional<User> optionalAdmin = userRepository.findByUsername("Admin");
        if (optionalAdmin.isEmpty()) {
            Role managerRole = roleRepository.findByName(RoleTypes.MANAGER.toString());
            User user = new User(managerRole);
            user.setUsername("Admin");
            user.setFirstName("Admin");
            user.setLastName("Admin");
            user.setPassword(passwordEncoder.encode("Admin"));
            userRepository.save(user);
        }

        List<Manager> authorizedManagersGmails = new ArrayList<>();
        authorizedManagersGmails.add(new Manager("smads.manager@gmail.com"));
        managerRepository.saveAll(authorizedManagersGmails);

       createServiceLocationIfNotFound("Anna Hiss", LocationType.officebuilding, "AHG", true, true, 30.2880730961, -97.7376866001);
        createServiceLocationIfNotFound("Main Tower", LocationType.library, "MAI", false, true, 30.2855760928, -97.7394486086);
//        createServiceLocationIfNotFound("Perry Casedena Library", LocationType.library, "PCL", false, true, 30.283489, -97.73938);
        createServiceLocationIfNotFound("Gates Dell Complex", LocationType.officebuilding, "GDC", false, true, 30.285929079536178, -97.73684269956657);
//        createServiceLocationIfNotFound("Goldsmith Hall", LocationType.officebuilding, "GOL", false, true, 30.28549, -97.74121);
//        createServiceLocationIfNotFound("Engineering Education and Research Center", LocationType.officebuilding, "EER", false, true, 30.288510, -97.735545);

        createDefaultStoreStatusIfNecessary();

        createIssueIfNeeded("Robot never arrived");
        createIssueIfNeeded("Robot arrived, but couldn't find it");
        createIssueIfNeeded("Lemonade was damaged or not sealed properly");

        alreadySetup = true;
    }

    private void createDefaultStoreStatusIfNecessary() {
        Optional<Store> storeById = storeRepository.findById(1);
        if (storeById.isEmpty()) {
            Store store = new Store(Store.LEMONADE_STORE_NUMER, "Lemonade Store", "Our store is open from 9am to 7pm, from Monday 10/26 to Friday 10/30.", false);
            storeRepository.save(store);
        }
    }

    private void createServiceLocationIfNotFound(String locationName, LocationType type, String acronym, boolean isHome, boolean isActive, double latitude, double longitude) {
        ServiceLocation sl = new ServiceLocation(type, locationName, latitude, longitude, isActive, isHome, 1, acronym);
        Optional<ServiceLocation> potentialSl = slRepo.findServiceLocationWithLocationName(locationName);
        if (potentialSl.isEmpty())
        {
            slRepo.save(sl);
        }
    }

    @Transactional
    Privilege createPrivilegeIfNotFound(String name) {
        Privilege privilege = privilegeRepository.findByName(name);
        if (privilege == null) {
            privilege = new Privilege(name);
            privilegeRepository.save(privilege);
        }
        return privilege;
    }

    @Transactional
    void createRoleIfNotFound(String name, Collection<Privilege> privileges) {
        Role role = roleRepository.findByName(name);
        if (role == null) {
            role = new Role(name);
            role.setPrivileges(privileges);
            roleRepository.save(role);
        }
    }

    @Transactional
    void createIssueIfNeeded(String issue) {
        Optional<Issue> existingIssue = issueRepository.findByIssue(issue);
        if (existingIssue.isEmpty()) {
            Issue i = new Issue();
            i.setIssue(issue);
            i.setUpdated(ZonedDateTime.now());
            issueRepository.save(i);
        }
    }
}