package com.agrovision.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class AgroVisionBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(AgroVisionBackendApplication.class, args);
	}

}
