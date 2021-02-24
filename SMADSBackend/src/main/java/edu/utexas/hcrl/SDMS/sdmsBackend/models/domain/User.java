package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.RoleTypes;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Table(name = "users")
public class User {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(unique = true)
    private String username;
    private String firstName;
    private String lastName;
    @JsonIgnore
    private String password;
    private boolean isActive;

    @JsonIgnore
    @OneToMany(fetch = FetchType.EAGER, cascade = {CascadeType.ALL})
    private List<PushToken> pushTokens;

    @JsonIgnore
    @ManyToMany
    @JoinTable(name = "users_roles",
               joinColumns = @JoinColumn(name = "user_id", referencedColumnName = "id"),
               inverseJoinColumns = @JoinColumn(name = "role_id", referencedColumnName = "id"))
    private Collection<Role> roles;

    public User() {
        this.isActive = true;
    }

    public User(Role role) {
        this();
        this.roles = Collections.singletonList(role);
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String emailAddress) {
        this.username = emailAddress;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public List<PushToken> getPushTokens() {
        return pushTokens;
    }

    public void addToken(String tokenToAdd, boolean isManager) {
        if (pushTokens == null) {
            pushTokens = new ArrayList<>();
        }
        if (!tokenExists(tokenToAdd, isManager)) {
            PushToken t = new PushToken();
            t.setToken(tokenToAdd);
            t.setManagerToken(isManager);
            pushTokens.add(t);
        }
    }

    private boolean tokenExists(String tokenToAdd, boolean isManager) {
        if (pushTokens != null) {
            for (PushToken pt : pushTokens) {
                if (pt.isManagerToken() == isManager && pt.getToken().equals(tokenToAdd)) {
                    return true;
                }
            }
        }
        return false;
    }

    public void setPushTokens(List<PushToken> pushTokens) {
        this.pushTokens = pushTokens;
    }

    public boolean isManager() {
        return getRoles()
                .stream()
                .map(Role::getName)
                .collect(Collectors.toList())
                .contains(RoleTypes.MANAGER.toString());
    }

    public Collection<Role> getRoles() {
        return roles;
    }

    public void setRoles(Collection<Role> roles) {
        this.roles = roles;
    }


}
