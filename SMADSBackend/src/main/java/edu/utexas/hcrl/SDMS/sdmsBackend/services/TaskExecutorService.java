package edu.utexas.hcrl.SDMS.sdmsBackend.services;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
public class TaskExecutorService {

    @Bean(name = "GPSSimulationExecutor")
    public TaskExecutor GPSSimulationExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(20);
        executor.setThreadNamePrefix("GPS_Simulation_Executor");
        executor.initialize();
        return executor;
    }

    @Bean(name = "TripAutoCloserExecutor")
    public TaskExecutor threadPoolTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(20);
        executor.setThreadNamePrefix("Trip_Auto_Closer_Executor");
        executor.initialize();
        return executor;
    }
}
