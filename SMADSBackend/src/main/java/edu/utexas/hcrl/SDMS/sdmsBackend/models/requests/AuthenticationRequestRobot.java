package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

public class AuthenticationRequestRobot {

    private int manufacturerID;
    private String password;

    public AuthenticationRequestRobot() {
    }

    public int getManufacturerID() {
        return manufacturerID;
    }

    public void setManufacturerID(int manufacturerID) {
        this.manufacturerID = manufacturerID;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
