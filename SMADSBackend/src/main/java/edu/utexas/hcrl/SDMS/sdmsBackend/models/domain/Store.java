package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Entity;
import javax.persistence.Id;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
public class Store {
    public static int LEMONADE_STORE_NUMER = 1;
    @Id
    private Integer id;
    private String name;
    private String hoursDescription;
    private boolean isOpen;
}
