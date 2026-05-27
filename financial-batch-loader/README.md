# financial-batch-loader

Java batch processing application that simulates enterprise banking transaction ingestion.

The application validates financial CSV files, stores valid movements into an H2 database and generates reconciliation/audit outputs.

---

# Main Features

- CSV batch file processing
- Financial transaction validation
- H2 persistence layer
- Error handling and audit logging
- Reconciliation simulation
- Batch execution flow similar to banking nightly processes

---

# Technologies

- Java 17
- Maven
- JDBC
- H2 Database
- CSV processing
- Layered architecture

---

# Project Structure

```text
src/main/java/com/jcaballerod92/financialbatch/
│
├── model/
├── service/
├── repository/
├── database/
├── util/
├── exception/
└── constant/
```

---

# Batch Flow

```text
CSV File
   |
   v
Validation
   |
   +---- Invalid Records -> Error Log
   |
   v
Persistence
   |
   v
Reconciliation
   |
   v
Execution Report
```

---

# How To Run

## Compile

```bash
mvn clean compile
```

## Execute

```bash
mvn exec:java
```

---

# Sample Execution Output

```text
LoadResultDto{
 processedRecords=3,
 validRecords=3,
 rejectedRecords=0,
 loadStatus='SUCCESS'
}
```

---

# Banking Concepts Simulated

- Batch ingestion
- Financial movement validation
- Reconciliation controls
- Audit processes
- Error management
- Staging data processing

---

# Future Improvements

- Scheduler integration simulation
- Multi-threaded batch processing
- DB2 connectivity
- Spring Batch migration
- File checksum validation

---

# Author

Jorge Caballero
