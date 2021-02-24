package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import javax.persistence.*;
import java.time.ZonedDateTime;
import java.util.Collection;

@Data
@Entity
public class Feedback {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @JsonIgnore
    private Long id;

    private String comment;

    @ManyToMany
    @JoinTable(
            name = "feedback_issue",
            joinColumns = @JoinColumn(name = "feedback_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name = "issue_id", referencedColumnName = "id"))
    private Collection<Issue> issues;
    @JsonIgnore
    private ZonedDateTime updated;
    private Integer tripID;
    private Integer rating;

    @PreUpdate
    public void setLastUpdate() {  this.updated = ZonedDateTime.now(); }

}
