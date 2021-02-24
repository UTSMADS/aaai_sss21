package edu.utexas.hcrl.SDMS.sdmsBackend.exceptions;

public class UserAlreadyHasTripException extends Exception {
    public UserAlreadyHasTripException(int userID) {
        super("User with id " + userID + " already has a trip.");
    }
}
