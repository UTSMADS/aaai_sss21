package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SimpleSuccessResponse {
    private boolean success;
}
