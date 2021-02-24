package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import lombok.Data;

import javax.persistence.*;
import java.time.ZonedDateTime;

@Data
@Entity
public class Issue {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String issue;
    private ZonedDateTime updated;

    @PreUpdate
    public void setLastUpdate() {  this.updated = ZonedDateTime.now(); }
}
