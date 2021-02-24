package edu.utexas.hcrl.SDMS.sdmsBackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SdmsBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SdmsBackendApplication.class, args);
	}

}
