[![Java Quality Check](https://github.com/jcaballerod92/IFCT0610-SAP-Development-Artifacts/actions/workflows/java-check.yml/badge.svg)](https://github.com/jcaballerod92/IFCT0610-SAP-Development-Artifacts/actions/workflows/java-check.yml)

# Banking Batch Reconciliation System

Sistema de conciliación y control de movimientos financieros desarrollado en COBOL, Java, DB2 y JCL.

Este workspace simula un entorno bancario real orientado al procesamiento batch, validación de registros, almacenamiento en base de datos, generación de trazabilidad operacional y exposición de datos mediante una API Java. Está pensado para mostrar competencias técnicas en entornos mainframe, desarrollo de software crítico y tratamiento de datos financieros.

---

## Objetivo del workspace

- Procesar ficheros de movimientos financieros
- Validar registros de entrada
- Registrar movimientos en base de datos
- Generar ficheros de salida y errores
- Automatizar la ejecución mediante JCL
- Ofrecer una capa Java de consulta y apoyo operativo
- Documentar una arquitectura enterprise coherente

---

## Proyectos incluidos

### 1. `financial-db2-reconciliation`
Entorno principal orientado a COBOL, DB2 y JCL.

Contiene:
- Programas COBOL de validación, conciliación e informe
- Copybooks con layouts de entrada, staging, error y control
- Jobs JCL de compilación, ejecución y prueba
- Scripts SQL para tablas, índices, vistas y procedimientos
- Documentación funcional y técnica del flujo batch

### 2. `financial-batch-loader`
Aplicación Java batch que:
- Lee movimientos desde CSV
- Valida registros
- Persiste datos válidos en H2
- Genera resultados y trazabilidad
- Simula un proceso batch bancario de carga

### 3. `financial-inquiry-api`
API REST con Spring Boot que:
- Consulta cuentas y movimientos
- Expone datos financieros en JSON
- Usa H2 como base de datos local
- Simula una capa de consulta bancaria

### 4. `shared-documentation`
Documentación común del workspace:
- Arquitectura enterprise
- Patrones de integración
- Diferencias batch vs API
- Modernización desde legacy
- Perfil técnico
- Skills enterprise
- Resumen general del portfolio

---

## Tecnologías

- COBOL
- Java
- Spring Boot
- Maven
- JDBC
- H2
- DB2
- SQL
- JCL
- Mainframe
- CICS
- Control-M
- UNIX

---

## Estructura funcional

- Carga de movimientos
- Validación de datos
- Registro en base de datos
- Conciliación de importes
- Generación de informe de control
- Gestión de incidencias y errores
- Consulta de información por API

---

## Valor profesional

Este repositorio muestra experiencia en:
- procesamiento batch
- lógica bancaria
- integración con base de datos
- automatización de jobs
- arquitectura enterprise
- desarrollo en entornos financieros críticos
- modernización y convivencia entre legacy y Java

---

## Orden recomendado de lectura

1. `shared-documentation`
2. `financial-db2-reconciliation`
3. `financial-batch-loader`
4. `financial-inquiry-api`

---

## Estado del proyecto

Proyecto en evolución, con base funcional real y orientado a portfolio profesional para entornos COBOL + Java + DB2 + sistemas financieros.