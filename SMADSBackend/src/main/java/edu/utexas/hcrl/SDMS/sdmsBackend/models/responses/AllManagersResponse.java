package edu.utexas.hcrl.SDMS.sdmsBackend.models.responses;

import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Manager;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AllManagersResponse {
    private List<Manager> allManagers;
}
