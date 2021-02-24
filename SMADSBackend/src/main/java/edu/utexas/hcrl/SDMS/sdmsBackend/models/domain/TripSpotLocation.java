package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import javax.persistence.*;
import java.time.ZonedDateTime;
import java.util.Date;


@Entity
@Table(name = "spot_locations")
public class TripSpotLocation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) //Automatic id generation increments by one
    private Integer id;
    @ManyToOne
    private Trip trip;
    private ZonedDateTime time;
    private double latitude;
    private double longitude;
    private Integer dbSpotID;

    public TripSpotLocation(Trip trip, double latitude, double longitude, Integer dbSpotID) {
        this.trip = trip;
        this.time = ZonedDateTime.now();
        this.latitude = latitude;
        this.longitude = longitude;
        this.dbSpotID = dbSpotID;
    }

    public TripSpotLocation(){}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Trip getTrip() {
        return trip;
    }

    public void setTrip(Trip trip) {
        this.trip = trip;
    }

    public ZonedDateTime getTime() {
        return time;
    }

    public void setTime(ZonedDateTime time) {
        this.time = time;
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

    public Integer getDbSpotID() {
        return dbSpotID;
    }

    public void setDbSpotID(Integer dbSpotID) {
        this.dbSpotID = dbSpotID;
    }
}

