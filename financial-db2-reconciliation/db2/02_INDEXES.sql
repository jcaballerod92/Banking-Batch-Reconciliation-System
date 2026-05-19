-- ********************************************************************
-- SCRIPT NAME : 02_INDEXES.sql
-- PURPOSE     : Supporting indexes for access, reconciliation and
--               reporting in the financial data model.
-- ********************************************************************

-- Account lookup by business key.
CREATE UNIQUE INDEX IX_FIN_ACCOUNT_NUMBER
    ON FIN_ACCOUNT (ACCOUNT_NUMBER);

-- Movement access for reconciliation by account and date.
CREATE INDEX IX_FIN_MOVEMENT_ACCOUNT_DATE
    ON FIN_MOVEMENT (ACCOUNT_ID, MOVEMENT_DATE);

-- Movement access by transaction identifier.
CREATE UNIQUE INDEX IX_FIN_MOVEMENT_TRANS
    ON FIN_MOVEMENT (TRANSACTION_ID);

-- Staging access by processing status and date.
CREATE INDEX IX_FIN_STG_STATUS_DATE
    ON FIN_STG_MOVEMENT (PROCESS_STATUS, TRANSACTION_DATE);

-- Staging access by account and date.
CREATE INDEX IX_FIN_STG_ACCOUNT_DATE
    ON FIN_STG_MOVEMENT (ACCOUNT_NUMBER, TRANSACTION_DATE);

-- Reconciliation control access by account and status.
CREATE INDEX IX_FIN_RECON_ACCOUNT_STATUS
    ON FIN_RECON_CONTROL (ACCOUNT_NUMBER, STATUS);

-- Discrepancy access by transaction and error code.
CREATE INDEX IX_FIN_DISC_TRANS_ERROR
    ON FIN_DISCREPANCY (TRANSACTION_ID, ERROR_CODE);

-- Audit access by process and timestamp.
CREATE INDEX IX_FIN_AUDIT_PROCESS_TIMESTAMP
    ON FIN_AUDIT_LOG (PROCESS_NAME, EVENT_TIMESTAMP);
