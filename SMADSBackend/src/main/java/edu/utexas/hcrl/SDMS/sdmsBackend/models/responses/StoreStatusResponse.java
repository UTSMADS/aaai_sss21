package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Store;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StoreStatusResponse {
    private Store store;
}
