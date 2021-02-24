package edu.utexas.hcrl.SDMS.sdmsBackend.exceptions;

public class BadServiceLocationIdException extends Exception{
    public Integer badID;

    public BadServiceLocationIdException(Integer badID)
    {
        this.badID = badID;
    }
}
