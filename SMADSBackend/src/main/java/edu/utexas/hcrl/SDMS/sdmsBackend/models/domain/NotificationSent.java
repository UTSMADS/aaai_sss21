package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.NotificationType;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
@Entity
@Data
@NoArgsConstructor
public class NotificationSent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private NotificationType type;

    public NotificationSent(NotificationType type)
    {
        this.type = type;
    }

}
