package com.company.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
public class DemoApplication {

    @GetMapping("/")
    public String home() {
        return "Hello from Spring Boot!";
    }

    @GetMapping("/health")
    public String health() {
        return "Application Healthy";
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}