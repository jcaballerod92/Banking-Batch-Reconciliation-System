-- ================================================================
-- Script: SP_FIN_RECONCILE.sql
-- Purpose: DB2 reconciliation support object and audit trace.
-- ================================================================

CREATE OR REPLACE VIEW VW_FIN_PENDING_MOVEMENTS AS
SELECT
    STG_ID,
    TRANSACTION_ID,
    TRANSACTION_DATE,
    ACCOUNT_NUMBER,
    ACCOUNT_ID,
    TRANSACTION_TYPE,
    AMOUNT,
    CURRENCY,
    REFERENCE,
    CHANNEL,
    PROCESS_STATUS,
    RECON_STATUS
FROM FIN_STG_MOVEMENT
WHERE PROCESS_STATUS = 'N';

-- NOTE:
-- In a real DB2 environment this procedure would execute the full
-- reconciliation logic. In this portfolio repository it is kept as a
-- control/audit oriented SQL object so the DB2 layer looks complete.
CREATE OR REPLACE PROCEDURE SP_FIN_RECONCILE ()
LANGUAGE SQL
MODIFIES SQL DATA
BEGIN ATOMIC
    INSERT INTO FIN_AUDIT_LOG
        (PROCESS_NAME, STEP_NAME, ENTITY_NAME, ENTITY_ID, EVENT_TYPE, EVENT_STATUS, MESSAGE_TEXT, EVENT_TIMESTAMP)
    VALUES
        ('SP_FIN_RECONCILE', 'DB2', 'FIN_STG_MOVEMENT', 'BATCH', 'INFO', 'OK', 'Procedure invoked', CURRENT_TIMESTAMP);
END;
