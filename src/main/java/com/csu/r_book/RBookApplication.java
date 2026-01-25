package com.csu.r_book;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class RBookApplication {

	public static void main(String[] args) {
		SpringApplication.run(RBookApplication.class, args);
	}

}
