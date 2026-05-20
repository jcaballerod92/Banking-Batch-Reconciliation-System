-- ================================================================
-- Script: VW_FIN_PENDING_MOVEMENTS.sql
-- Purpose: Pending staging movements view used by reconciliation.
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
