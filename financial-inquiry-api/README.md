# financial-inquiry-api

Spring Boot REST API exposing financial movement information stored in the database.

This project simulates the inquiry layer commonly used in banking systems to expose transactional data to channels and internal systems.

---

# Main Features

- REST API endpoints
- Financial movement queries
- Account inquiry operations
- JSON responses
- Embedded Tomcat server
- H2 database integration
- Health check endpoint

---

# Technologies

- Java 17
- Spring Boot 2.7
- Spring Web
- Spring JDBC
- Maven
- H2 Database

---

# API Architecture

```text
Controller Layer
       |
       v
Service Layer
       |
       v
Repository Layer
       |
       v
H2 Database
```

---

# How To Run

```bash
mvn spring-boot:run
```

Application URL:

```text
http://localhost:8080
```

H2 Console:

```text
http://localhost:8080/h2-console
```

---

# Example Endpoints

## Get all movements

```http
GET /api/movements
```

## Health Check

```http
GET /health
```

---

# Enterprise Concepts Simulated

- Banking inquiry services
- API-driven architecture
- Backend transactional access
- Service abstraction
- Repository pattern
- Financial movement exposure

---

# Typical Banking Use Cases

- Account movement consultation
- Internal operational APIs
- Digital banking integrations
- Backoffice inquiry services

---

# Future Improvements

- Swagger/OpenAPI
- Authentication
- Pagination
- Advanced filtering
- Dockerization
- DB2 integration

---

# Author

Jorge Caballero
