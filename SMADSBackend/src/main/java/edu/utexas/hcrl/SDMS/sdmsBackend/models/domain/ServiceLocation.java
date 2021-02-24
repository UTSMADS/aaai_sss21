package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.LocationType;

import javax.persistence.*;

@Entity
@Table(name = "ServiceLocations")
public class ServiceLocation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Enumerated(EnumType.STRING)
    private LocationType locationType;
    private String locationName;
    private double latitude;
    private double longitude;
    private boolean isActive;
    private boolean isHome = false;
    private int numAvailableChargers = 0;
    private String acronym;
    @Transient
    private int eta;

    public ServiceLocation() { }

    public ServiceLocation(LocationType locationType, String locationName, double latitude, double longitude, boolean isActive, boolean isHome, int numAvailableChargers, String acronym) {
        this.locationType = locationType;
        this.locationName = locationName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.isActive = isActive;
        this.isHome = isHome;
        this.numAvailableChargers = numAvailableChargers;
        this.acronym = acronym;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public LocationType getLocationType() {
        return locationType;
    }

    public void setLocationType(LocationType locationType) {
        this.locationType = locationType;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public boolean isHome() {
        return isHome;
    }

    public void setHome(boolean home) {
        isHome = home;
    }

    public int getNumAvailableChargers() {
        return numAvailableChargers;
    }

    public void setNumAvailableChargers(int numAvailableChargers) {
        this.numAvailableChargers = numAvailableChargers;
    }

    public String getAcronym() {
        return acronym;
    }

    public void setAcronym(String acronym) {
        this.acronym = acronym;
    }

    public int getEta() {
        return eta;
    }

    public void setEta(int eta) {
        this.eta = eta;
    }
}
