package com.jcaballerod92.financialinquiry;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main entry point for the financial inquiry API.
 * Responsible for bootstrapping the Spring Boot application.
 */
@SpringBootApplication
public class FinancialInquiryApiApplication {

    /**
     * Starts the Spring Boot application.
     *
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        SpringApplication.run(FinancialInquiryApiApplication.class, args);
    }
}
