package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Manager;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Role;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.ManagerRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.RoleRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class ManagerService {

    @Autowired
    private ManagerRepository managerRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private RoleRepository roleRepository;

    public Manager addAuthorizedManager(String emailAddress) {
        Manager manager = new Manager(emailAddress);
        Optional<User> potentialuser = userRepository.findByUsername(emailAddress);
        if(potentialuser.isPresent())
        {
            User user = potentialuser.get();
            RoleTypes type = RoleTypes.MANAGER;
            Role userRole = roleRepository.findByName(type.toString());
            if (!user.getRoles().contains(userRole)) {
                user.getRoles().add(userRole);
            }
            userRepository.save(user);
        }
        return managerRepository.save(manager);
    }

    public Boolean isAuthorizedManager(String emailAddress) {
        Optional<Manager> optionalManager = managerRepository.findById(emailAddress);
        return optionalManager.isPresent();
    }

    public List<Manager> getAllAuthorizedManagers() {
        Iterable<Manager> allManagersIterable = managerRepository.findAll();
        List<Manager> allManagers = new ArrayList<>();
        allManagersIterable.forEach(allManagers::add);
        return allManagers;
    }

    public boolean deleteAuthorizedManager(String emailAddress) {
        Optional<Manager> optionalManager = managerRepository.findById(emailAddress);
        if (optionalManager.isEmpty()) {
            return false;
        } else {
            Manager manager = optionalManager.get();
            Optional<User> potentialuser = userRepository.findByUsername(emailAddress);
            if(potentialuser.isPresent())
            {
                User user = potentialuser.get();
                RoleTypes type = RoleTypes.MANAGER;
                Role managerRole = roleRepository.findByName(type.toString());
                user.getRoles().remove(managerRole);
                userRepository.save(user);
            }
            managerRepository.delete(manager);
            return true;
        }
    }
}
