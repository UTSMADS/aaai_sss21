package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Feedback;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.responses.AllIssuesResponse;
import edu.utexas.hcrl.SDMS.sdmsBackend.services.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    @ResponseBody
    @PostMapping
    public Feedback createFeedback(@RequestBody Feedback feedback) {
        return feedbackService.createFeedback(feedback);
    }

    @ResponseBody
    @GetMapping("/issues")
    public AllIssuesResponse getAllIssues() {
        AllIssuesResponse response = new AllIssuesResponse();
        response.setIssues(feedbackService.getAllIssues());
        return response;
    }
}
