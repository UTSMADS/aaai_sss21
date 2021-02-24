package edu.utexas.hcrl.SDMS.sdmsBackend.configuration;

import com.turo.pushy.apns.ApnsClient;
import com.turo.pushy.apns.ApnsClientBuilder;
import com.turo.pushy.apns.auth.ApnsSigningKey;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

@Configuration
public class ClientConfiguration {

    private enum ApnsClientType {
        MANAGER, CUSTOMER
    }

    @Autowired
    private EnvironmentConfiguration environmentConfiguration;

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder)
    {
        return builder.build();
    }

    @Bean("customerApnsClient")
    public ApnsClient createCustomerApnsClient() {
        return createAPNSClient(ApnsClientType.CUSTOMER);
    }

    @Bean("managerApnsClient")
    public ApnsClient createManagerApnsClient() {
        return createAPNSClient(ApnsClientType.MANAGER);
    }

    private ApnsClient createAPNSClient(ApnsClientType type) {
        String apnsHost = /*environmentConfiguration.isProductionEnvironment() ? ApnsClientBuilder.PRODUCTION_APNS_HOST :*/ ApnsClientBuilder.DEVELOPMENT_APNS_HOST;
        String keyId = type == ApnsClientType.MANAGER ? environmentConfiguration.getApnsManagerKeyId() : environmentConfiguration.getApnsCustomerKeyId();
        String teamId = environmentConfiguration.getApnsTeamId();
        String fileName = type == ApnsClientType.MANAGER ? environmentConfiguration.getApnsManagerKeyFilename() : environmentConfiguration.getApnsCustomerKeyFilename();
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream(fileName);
        try {
            return new ApnsClientBuilder()
                    .setApnsServer(apnsHost)
                    .setSigningKey(ApnsSigningKey.loadFromInputStream(inputStream, teamId, keyId))
                    .build();
        } catch (IOException | NoSuchAlgorithmException | InvalidKeyException e) {
            e.printStackTrace();
            return null;
        }
    }
}
