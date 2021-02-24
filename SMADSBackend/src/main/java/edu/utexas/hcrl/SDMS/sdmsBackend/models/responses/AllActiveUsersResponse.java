package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.User;

import java.util.List;

@JsonInclude(Include.NON_NULL)
public class AllActiveUsersResponse {
    private List<User> userList;

    public List<User> getUserList() {
        return userList;
    }

    public void setUserList(List<User> userList) {
        this.userList = userList;
    }
}

