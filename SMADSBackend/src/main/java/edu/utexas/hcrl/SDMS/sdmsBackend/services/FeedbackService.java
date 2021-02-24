package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Feedback;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Issue;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.FeedbackRepository;
import edu.utexas.hcrl.SDMS.sdmsBackend.repositories.IssueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class FeedbackService {

    @Autowired
    private FeedbackRepository feedbackRepository;

    @Autowired
    private IssueRepository issueRepository;

    public Feedback createFeedback(Feedback feedback) {
        return feedbackRepository.save(feedback);
    }

    public List<Issue> getAllIssues() {
        List<Issue> result = new ArrayList<>();
        issueRepository.findAll().forEach(result::add);
        return result;
    }
}
