package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TripAutoCloser implements Runnable {

    public static final int numberOfSeconds = 10;

    @Autowired
    private RequestService requestService;

    public int tripId;
    @Override
    public void run() {
        try {
            System.out.println("Waiting for trip to be closed....");
            Thread.sleep(numberOfSeconds * 1000);
            if (!requestService.isComplete(tripId)) {
                requestService.closeTrip(tripId);
                System.out.println("Trip " + tripId + " has been auto closed");
                requestService.sendAutocloseTripMessageToCustomer(tripId);
            } else {
                System.out.println("Trip " + tripId + " was already closed by client.");
            }
        } catch (InterruptedException e) {
            System.out.println("Could not close trip in thread... was interrupted.");
        }
    }
}
