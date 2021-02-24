package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.NotificationType;
import edu.utexas.hcrl.SDMS.sdmsBackend.enums.TripStatus;
import lombok.Data;

import javax.persistence.*;
import java.time.ZonedDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "trips")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Trip {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) //Automatic id generation increments by one
    private Integer id;
    @OneToOne
    private ServiceLocation pickupLocation;
    @OneToOne
    private ServiceLocation dropoffLocation;
    @Enumerated(EnumType.STRING)
    private TripStatus tripStatus;
    private ZonedDateTime startTime;
    private ZonedDateTime endTime;
    private String payloadContent;
    private Integer spotManufacturerID;
    private Integer userID;
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "trip", cascade = {CascadeType.ALL})
    private List<Waypoint> waypoints;
    @OneToMany(fetch = FetchType.EAGER, cascade = {CascadeType.ALL})
    private List<NotificationSent> sentNotifications;
    private int eta;

    @Transient
    private Spot assignedSpot;
    @Transient
    private String username;

    private boolean isActive = true;

    public void addNotification(NotificationType type) {
        if (sentNotifications != null)
        {
            if(hasNotification(type) == false) {
                sentNotifications.add(new NotificationSent(type));
            }
        }

    }

    public boolean hasNotification(NotificationType type)
    {
       for(NotificationSent ns : sentNotifications)
        {
            if(ns.getType().equals(type))
            {
                return true;
            }
        }
       return false;
    }
}
