package edu.utexas.hcrl.SDMS.sdmsBackend.enums;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public enum TripStatus {
    requested, enroute, dropoff, returningHome, complete, cancelled, processing
}
