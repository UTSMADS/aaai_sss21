package edu.utexas.hcrl.SDMS.sdmsBackend.models.requests;

import lombok.Data;

@Data
public class AddTokenRequest {
    private String token;
    private boolean manager;
}
