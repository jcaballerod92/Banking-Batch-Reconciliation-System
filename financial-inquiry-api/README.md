# Financial Inquiry API

<!-- Overview -->
This project exposes a small banking-style REST API that allows inquiries over accounts and movements stored in H2.

<!-- Scope -->
The repository is intentionally kept small and focused so it can demonstrate a professional Java backend structure:
- Spring Boot application entry point
- REST controller
- service layer
- repository layer
- DTOs and error payloads
- H2 schema and demo data

<!-- Functional goal -->
The API is meant to simulate a financial inquiry service that could be used in a banking or enterprise context.

<!-- Execution -->
Run the application with Maven from the project root:

```bash
mvn spring-boot:run
```

<!-- Database -->
The project uses an embedded H2 database populated by `schema.sql` and `data.sql`.
