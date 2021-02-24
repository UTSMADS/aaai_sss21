package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DeleteManagerResponse {
    private boolean successfullyDeleted;
}
