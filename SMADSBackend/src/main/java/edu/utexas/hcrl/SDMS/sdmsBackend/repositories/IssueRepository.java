package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Issue;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface IssueRepository extends CrudRepository<Issue, Integer> {

    @Query("SELECT i from Issue i where i.issue = ?1")
    Optional<Issue> findByIssue(String issue);

}
