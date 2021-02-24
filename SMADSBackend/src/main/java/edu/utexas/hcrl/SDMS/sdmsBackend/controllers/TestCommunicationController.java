package edu.utexas.hcrl.SDMS.sdmsBackend.controllers;

import edu.utexas.hcrl.SDMS.sdmsBackend.clients.RobotClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;

@RestController
@RequestMapping("/testComms")
public class TestCommunicationController {

    @Autowired
    private RobotClient robotClient;

    @ResponseBody
    @GetMapping("/ssl")
    public boolean testSSLCommunication(HttpServletResponse response) {
        return robotClient.testSSLCommunication();
    }
}
