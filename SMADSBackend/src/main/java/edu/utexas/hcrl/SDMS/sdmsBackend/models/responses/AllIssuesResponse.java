package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Issue;
import lombok.Data;

import java.util.List;

@Data
public class AllIssuesResponse {
    List<Issue> issues;
}
