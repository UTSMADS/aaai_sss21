package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.SpotStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.time.ZonedDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Spot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) //Automatic id generation increments by one
    private Integer id;
    private String name;
    private double chargeLevel;
    @Enumerated(EnumType.STRING)
    private SpotStatus status;
    private double currentLatitude;
    private double currentLongitude;
    private boolean isActive;
    private Integer manufacturerID;
    private String ipAddress;
    private double heading;
    private ZonedDateTime updatedAt;
}
