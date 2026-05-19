-- ********************************************************************
-- SCRIPT NAME : 01_CREATE_TABLES.sql
-- PURPOSE     : Financial data model for validation, reconciliation,
--               traceability and downstream exploitation by COBOL and
--               Java programs.
--
-- DESCRIPTION :
-- - Defines master account data
-- - Stores definitive financial movements
-- - Stores staging records coming from FINVLD01
-- - Stores reconciliation control results
-- - Stores discrepancy details
-- - Stores audit / traceability events
-- ********************************************************************

-- --------------------------------------------------------------------
-- TABLE: FIN_ACCOUNT
-- Master data for bank accounts used by reconciliation and control.
-- --------------------------------------------------------------------
CREATE TABLE FIN_ACCOUNT (
    ACCOUNT_ID        BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY,
    ACCOUNT_NUMBER    VARCHAR(20)  NOT NULL,
    ACCOUNT_HOLDER    VARCHAR(100) NOT NULL,
    ACCOUNT_STATUS    CHAR(1)      NOT NULL,
    CURRENCY          CHAR(3)      NOT NULL,
    OPEN_DATE         DATE         NOT NULL,
    CONSTRAINT PK_FIN_ACCOUNT PRIMARY KEY (ACCOUNT_ID),
    CONSTRAINT UQ_FIN_ACCOUNT_NUMBER UNIQUE (ACCOUNT_NUMBER),
    CONSTRAINT CK_FIN_ACCOUNT_STATUS CHECK (ACCOUNT_STATUS IN ('A', 'B', 'C'))
);

COMMENT ON TABLE FIN_ACCOUNT IS 'Master data for bank accounts used by reconciliation and control processes.';
COMMENT ON COLUMN FIN_ACCOUNT.ACCOUNT_ID IS 'Surrogate identifier for the account.';
COMMENT ON COLUMN FIN_ACCOUNT.ACCOUNT_NUMBER IS 'Business account number used by source systems.';
COMMENT ON COLUMN FIN_ACCOUNT.ACCOUNT_HOLDER IS 'Account holder name.';
COMMENT ON COLUMN FIN_ACCOUNT.ACCOUNT_STATUS IS 'Account lifecycle status: A=Active, B=Blocked, C=Closed.';
COMMENT ON COLUMN FIN_ACCOUNT.CURRENCY IS 'Account currency code.';
COMMENT ON COLUMN FIN_ACCOUNT.OPEN_DATE IS 'Account opening date.';

-- --------------------------------------------------------------------
-- TABLE: FIN_MOVEMENT
-- Definitive movement table used as reconciliation target.
-- --------------------------------------------------------------------
CREATE TABLE FIN_MOVEMENT (
    MOVEMENT_ID       BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    TRANSACTION_ID    VARCHAR(20)   NOT NULL,
    ACCOUNT_ID        BIGINT        NOT NULL,
    MOVEMENT_DATE     DATE          NOT NULL,
    MOVEMENT_TYPE     CHAR(2)       NOT NULL,
    AMOUNT            DECIMAL(13,2) NOT NULL,
    CURRENCY          CHAR(3)       NOT NULL,
    REFERENCE         VARCHAR(35),
    CHANNEL           VARCHAR(10),
    SOURCE_SYSTEM     VARCHAR(20),
    LOAD_TIMESTAMP    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FIN_MOVEMENT PRIMARY KEY (MOVEMENT_ID),
    CONSTRAINT UQ_FIN_MOVEMENT_TRANS UNIQUE (TRANSACTION_ID),
    CONSTRAINT FK_FIN_MOVEMENT_ACCOUNT FOREIGN KEY (ACCOUNT_ID)
        REFERENCES FIN_ACCOUNT (ACCOUNT_ID),
    CONSTRAINT CK_FIN_MOVEMENT_TYPE CHECK (MOVEMENT_TYPE IN ('CR', 'DB', 'TR')),
    CONSTRAINT CK_FIN_MOVEMENT_AMOUNT CHECK (AMOUNT > 0)
);

COMMENT ON TABLE FIN_MOVEMENT IS 'Definitive financial movements used as reconciliation reference.';
COMMENT ON COLUMN FIN_MOVEMENT.MOVEMENT_ID IS 'Surrogate identifier for the movement.';
COMMENT ON COLUMN FIN_MOVEMENT.TRANSACTION_ID IS 'Business transaction identifier.';
COMMENT ON COLUMN FIN_MOVEMENT.ACCOUNT_ID IS 'Reference to FIN_ACCOUNT.';
COMMENT ON COLUMN FIN_MOVEMENT.MOVEMENT_DATE IS 'Movement date.';
COMMENT ON COLUMN FIN_MOVEMENT.MOVEMENT_TYPE IS 'Movement type: CR, DB or TR.';
COMMENT ON COLUMN FIN_MOVEMENT.AMOUNT IS 'Movement amount.';
COMMENT ON COLUMN FIN_MOVEMENT.CURRENCY IS 'Currency code.';
COMMENT ON COLUMN FIN_MOVEMENT.REFERENCE IS 'External reference for traceability.';
COMMENT ON COLUMN FIN_MOVEMENT.CHANNEL IS 'Origin channel (office, web, batch, etc.).';
COMMENT ON COLUMN FIN_MOVEMENT.SOURCE_SYSTEM IS 'Source application or system.';
COMMENT ON COLUMN FIN_MOVEMENT.LOAD_TIMESTAMP IS 'Timestamp when the record was loaded.';

-- --------------------------------------------------------------------
-- TABLE: FIN_STG_MOVEMENT
-- Staging table for validated input records coming from FINVLD01.
-- --------------------------------------------------------------------
CREATE TABLE FIN_STG_MOVEMENT (
    STG_ID            BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    TRANSACTION_ID    VARCHAR(20)   NOT NULL,
    TRANSACTION_DATE  DATE          NOT NULL,
    ACCOUNT_NUMBER    VARCHAR(20)   NOT NULL,
    ACCOUNT_ID        BIGINT,
    TRANSACTION_TYPE  CHAR(2)       NOT NULL,
    AMOUNT            DECIMAL(13,2) NOT NULL,
    CURRENCY          CHAR(3)       NOT NULL,
    REFERENCE         VARCHAR(35),
    CHANNEL           VARCHAR(10),
    LOAD_TIMESTAMP    TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    PROCESS_STATUS    CHAR(1)       NOT NULL DEFAULT 'N',
    RECON_STATUS      VARCHAR(10)   NOT NULL DEFAULT 'PENDING',
    ERROR_CODE        VARCHAR(6),
    ERROR_DESCRIPTION VARCHAR(60),
    RECON_DATE        DATE,
    RECON_TIMESTAMP   TIMESTAMP,
    CONSTRAINT PK_FIN_STG_MOVEMENT PRIMARY KEY (STG_ID),
    CONSTRAINT UQ_FIN_STG_TRANS UNIQUE (TRANSACTION_ID),
    CONSTRAINT CK_FIN_STG_STATUS CHECK (PROCESS_STATUS IN ('N', 'P', 'E')),
    CONSTRAINT CK_FIN_STG_TYPE CHECK (TRANSACTION_TYPE IN ('CR', 'DB', 'TR')),
    CONSTRAINT CK_FIN_STG_RECON_STATUS CHECK (RECON_STATUS IN ('PENDING', 'RECONCILED', 'DIF', 'ERR'))
);

COMMENT ON TABLE FIN_STG_MOVEMENT IS 'Validated staging area used before reconciliation and final load.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.STG_ID IS 'Surrogate identifier for the staging record.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.TRANSACTION_ID IS 'Business transaction identifier.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.TRANSACTION_DATE IS 'Validated transaction date.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.ACCOUNT_NUMBER IS 'Account number from the source input.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.ACCOUNT_ID IS 'Resolved internal account identifier.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.TRANSACTION_TYPE IS 'Validated transaction type.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.AMOUNT IS 'Validated transaction amount.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.CURRENCY IS 'Currency code.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.REFERENCE IS 'External reference.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.CHANNEL IS 'Input channel.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.LOAD_TIMESTAMP IS 'Load timestamp.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.PROCESS_STATUS IS 'Processing status: N=New, P=Processed, E=Error.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.RECON_STATUS IS 'Reconciliation status: PENDING, RECONCILED, DIF or ERR.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.ERROR_CODE IS 'Business or technical error code.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.ERROR_DESCRIPTION IS 'Error description assigned during reconciliation.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.RECON_DATE IS 'Date when reconciliation was executed.';
COMMENT ON COLUMN FIN_STG_MOVEMENT.RECON_TIMESTAMP IS 'Timestamp when reconciliation was executed.';

-- --------------------------------------------------------------------
-- TABLE: FIN_RECON_CONTROL
-- Reconciliation control results produced by SP_FIN_RECONCILE.
-- --------------------------------------------------------------------
CREATE TABLE FIN_RECON_CONTROL (
    CTRL_ID           BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    STG_ID            BIGINT        NOT NULL,
    TRANSACTION_ID    VARCHAR(20)   NOT NULL,
    ACCOUNT_ID        BIGINT,
    ACCOUNT_NUMBER    VARCHAR(20)   NOT NULL,
    STATUS            VARCHAR(10)   NOT NULL,
    DIFFERENCE_AMOUNT DECIMAL(13,2) NOT NULL DEFAULT 0,
    RECON_DATE        DATE          NOT NULL,
    REMARKS           VARCHAR(60),
    CREATED_AT        TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FIN_RECON_CONTROL PRIMARY KEY (CTRL_ID),
    CONSTRAINT UQ_FIN_RECON_STG UNIQUE (STG_ID),
    CONSTRAINT FK_FIN_RECON_STG FOREIGN KEY (STG_ID)
        REFERENCES FIN_STG_MOVEMENT (STG_ID),
    CONSTRAINT CK_FIN_RECON_STATUS CHECK (STATUS IN ('RECONCILED', 'DIF', 'ERR'))
);

COMMENT ON TABLE FIN_RECON_CONTROL IS 'Control output generated after reconciliation against DB2 reference data.';
COMMENT ON COLUMN FIN_RECON_CONTROL.CTRL_ID IS 'Surrogate identifier for reconciliation control.';
COMMENT ON COLUMN FIN_RECON_CONTROL.STG_ID IS 'Reference to the staging row being processed.';
COMMENT ON COLUMN FIN_RECON_CONTROL.TRANSACTION_ID IS 'Transaction identifier.';
COMMENT ON COLUMN FIN_RECON_CONTROL.ACCOUNT_ID IS 'Internal account identifier.';
COMMENT ON COLUMN FIN_RECON_CONTROL.ACCOUNT_NUMBER IS 'Account number related to the control record.';
COMMENT ON COLUMN FIN_RECON_CONTROL.STATUS IS 'Reconciliation status.';
COMMENT ON COLUMN FIN_RECON_CONTROL.DIFFERENCE_AMOUNT IS 'Difference amount between expected and registered values.';
COMMENT ON COLUMN FIN_RECON_CONTROL.RECON_DATE IS 'Date of reconciliation.';
COMMENT ON COLUMN FIN_RECON_CONTROL.REMARKS IS 'Operational notes or comments.';
COMMENT ON COLUMN FIN_RECON_CONTROL.CREATED_AT IS 'Creation timestamp.';

-- --------------------------------------------------------------------
-- TABLE: FIN_DISCREPANCY
-- Exception and discrepancy detail generated by SP_FIN_RECONCILE.
-- --------------------------------------------------------------------
CREATE TABLE FIN_DISCREPANCY (
    DISC_ID             BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    STG_ID              BIGINT        NOT NULL,
    TRANSACTION_ID      VARCHAR(20)   NOT NULL,
    ACCOUNT_ID          BIGINT,
    ACCOUNT_NUMBER      VARCHAR(20)   NOT NULL,
    ERROR_CODE          VARCHAR(6)    NOT NULL,
    ERROR_DESCRIPTION   VARCHAR(60)   NOT NULL,
    EXPECTED_AMOUNT     DECIMAL(13,2) NOT NULL DEFAULT 0,
    REGISTERED_AMOUNT   DECIMAL(13,2) NOT NULL DEFAULT 0,
    DISC_DATE           DATE          NOT NULL,
    CREATED_AT          TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FIN_DISCREPANCY PRIMARY KEY (DISC_ID),
    CONSTRAINT UQ_FIN_DISC_STG UNIQUE (STG_ID),
    CONSTRAINT FK_FIN_DISCREPANCY_STG FOREIGN KEY (STG_ID)
        REFERENCES FIN_STG_MOVEMENT (STG_ID)
);

COMMENT ON TABLE FIN_DISCREPANCY IS 'Detailed discrepancy register for failed or mismatched reconciliation records.';
COMMENT ON COLUMN FIN_DISCREPANCY.DISC_ID IS 'Surrogate identifier for the discrepancy.';
COMMENT ON COLUMN FIN_DISCREPANCY.STG_ID IS 'Reference to the staging row that caused the discrepancy.';
COMMENT ON COLUMN FIN_DISCREPANCY.TRANSACTION_ID IS 'Transaction identifier from source/staging.';
COMMENT ON COLUMN FIN_DISCREPANCY.ACCOUNT_ID IS 'Internal account identifier.';
COMMENT ON COLUMN FIN_DISCREPANCY.ACCOUNT_NUMBER IS 'Affected account number.';
COMMENT ON COLUMN FIN_DISCREPANCY.ERROR_CODE IS 'Business or technical error code.';
COMMENT ON COLUMN FIN_DISCREPANCY.ERROR_DESCRIPTION IS 'Description of the discrepancy.';
COMMENT ON COLUMN FIN_DISCREPANCY.EXPECTED_AMOUNT IS 'Expected amount from DB2/control data.';
COMMENT ON COLUMN FIN_DISCREPANCY.REGISTERED_AMOUNT IS 'Amount received from the staging/definitive comparison.';
COMMENT ON COLUMN FIN_DISCREPANCY.DISC_DATE IS 'Date when the discrepancy was generated.';
COMMENT ON COLUMN FIN_DISCREPANCY.CREATED_AT IS 'Creation timestamp.';

-- --------------------------------------------------------------------
-- TABLE: FIN_AUDIT_LOG
-- Generic audit table for batch execution traceability.
-- --------------------------------------------------------------------
CREATE TABLE FIN_AUDIT_LOG (
    AUDIT_ID          BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    PROCESS_NAME      VARCHAR(30)   NOT NULL,
    STEP_NAME         VARCHAR(30)   NOT NULL,
    ENTITY_NAME       VARCHAR(30),
    ENTITY_ID         VARCHAR(50),
    EVENT_TYPE        VARCHAR(20)   NOT NULL,
    EVENT_STATUS      VARCHAR(10)   NOT NULL,
    MESSAGE_TEXT      VARCHAR(200),
    EVENT_TIMESTAMP   TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FIN_AUDIT_LOG PRIMARY KEY (AUDIT_ID)
);

COMMENT ON TABLE FIN_AUDIT_LOG IS 'Audit trail for batch and online events supporting traceability and troubleshooting.';
COMMENT ON COLUMN FIN_AUDIT_LOG.AUDIT_ID IS 'Surrogate identifier for the audit event.';
COMMENT ON COLUMN FIN_AUDIT_LOG.PROCESS_NAME IS 'Name of the process or job.';
COMMENT ON COLUMN FIN_AUDIT_LOG.STEP_NAME IS 'Step or program name.';
COMMENT ON COLUMN FIN_AUDIT_LOG.ENTITY_NAME IS 'Affected entity name.';
COMMENT ON COLUMN FIN_AUDIT_LOG.ENTITY_ID IS 'Affected entity identifier.';
COMMENT ON COLUMN FIN_AUDIT_LOG.EVENT_TYPE IS 'Type of event (INSERT, UPDATE, ERROR, INFO, etc.).';
COMMENT ON COLUMN FIN_AUDIT_LOG.EVENT_STATUS IS 'Event status.';
COMMENT ON COLUMN FIN_AUDIT_LOG.MESSAGE_TEXT IS 'Operational message or detail.';
COMMENT ON COLUMN FIN_AUDIT_LOG.EVENT_TIMESTAMP IS 'Event timestamp.';
