-- ********************************************************************
-- SCRIPT NAME : 04_TEST_DATA.sql
-- PURPOSE     : Sample data for local testing, demos and validation of
--               FINVLD01 / FINREC02 / FINRPT03 / SP_FIN_RECONCILE.
-- ********************************************************************

-- --------------------------------------------------------------------
-- MASTER ACCOUNTS
-- --------------------------------------------------------------------
INSERT INTO FIN_ACCOUNT
    (ACCOUNT_NUMBER, ACCOUNT_HOLDER, ACCOUNT_STATUS, CURRENCY, OPEN_DATE)
VALUES
    ('1000000001', 'JANE DOE', 'A', 'EUR', DATE('2020-01-15'));

INSERT INTO FIN_ACCOUNT
    (ACCOUNT_NUMBER, ACCOUNT_HOLDER, ACCOUNT_STATUS, CURRENCY, OPEN_DATE)
VALUES
    ('1000000002', 'JOHN SMITH', 'A', 'EUR', DATE('2021-06-20'));

INSERT INTO FIN_ACCOUNT
    (ACCOUNT_NUMBER, ACCOUNT_HOLDER, ACCOUNT_STATUS, CURRENCY, OPEN_DATE)
VALUES
    ('1000000003', 'BLOCKED ACCOUNT', 'B', 'EUR', DATE('2022-05-10'));

-- --------------------------------------------------------------------
-- DEFINITIVE MOVEMENTS
-- These records represent the source of truth for reconciliation.
-- --------------------------------------------------------------------
INSERT INTO FIN_MOVEMENT
    (TRANSACTION_ID,
     ACCOUNT_ID,
     MOVEMENT_DATE,
     MOVEMENT_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL,
     SOURCE_SYSTEM)
SELECT
    'TXN0001',
    A.ACCOUNT_ID,
    DATE('2026-05-01'),
    'CR',
    150.00,
    'EUR',
    'PAYROLL-APR',
    'BATCH',
    'CORE_BANK'
FROM FIN_ACCOUNT A
WHERE A.ACCOUNT_NUMBER = '1000000001';

INSERT INTO FIN_MOVEMENT
    (TRANSACTION_ID,
     ACCOUNT_ID,
     MOVEMENT_DATE,
     MOVEMENT_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL,
     SOURCE_SYSTEM)
SELECT
    'TXN0002',
    A.ACCOUNT_ID,
    DATE('2026-05-02'),
    'DB',
    250.00,
    'EUR',
    'UTILITY-BILL',
    'BATCH',
    'CORE_BANK'
FROM FIN_ACCOUNT A
WHERE A.ACCOUNT_NUMBER = '1000000002';

-- --------------------------------------------------------------------
-- STAGING RECORDS
-- One correct record, one with amount mismatch and one with missing
-- account in order to exercise OK / DIF / ERR paths.
-- --------------------------------------------------------------------
INSERT INTO FIN_STG_MOVEMENT
    (TRANSACTION_ID,
     TRANSACTION_DATE,
     ACCOUNT_NUMBER,
     TRANSACTION_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL)
VALUES
    ('TXN0001', DATE('2026-05-01'), '1000000001', 'CR', 150.00, 'EUR', 'PAYROLL-APR', 'BATCH');

INSERT INTO FIN_STG_MOVEMENT
    (TRANSACTION_ID,
     TRANSACTION_DATE,
     ACCOUNT_NUMBER,
     TRANSACTION_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL)
VALUES
    ('TXN0002', DATE('2026-05-02'), '1000000002', 'DB', 255.00, 'EUR', 'UTILITY-BILL', 'BATCH');

INSERT INTO FIN_STG_MOVEMENT
    (TRANSACTION_ID,
     TRANSACTION_DATE,
     ACCOUNT_NUMBER,
     TRANSACTION_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL)
VALUES
    ('TXN0003', DATE('2026-05-03'), '9999999999', 'CR', 100.00, 'EUR', 'UNKNOWN-REF', 'BATCH');

INSERT INTO FIN_STG_MOVEMENT
    (TRANSACTION_ID,
     TRANSACTION_DATE,
     ACCOUNT_NUMBER,
     TRANSACTION_TYPE,
     AMOUNT,
     CURRENCY,
     REFERENCE,
     CHANNEL)
VALUES
    ('TXN0004', DATE('2026-05-04'), '1000000003', 'CR', 80.00, 'EUR', 'BLOCKED-ACC', 'BATCH');

-- --------------------------------------------------------------------
-- OPTIONAL AUDIT SAMPLE
-- --------------------------------------------------------------------
INSERT INTO FIN_AUDIT_LOG
    (PROCESS_NAME,
     STEP_NAME,
     ENTITY_NAME,
     ENTITY_ID,
     EVENT_TYPE,
     EVENT_STATUS,
     MESSAGE_TEXT,
     EVENT_TIMESTAMP)
VALUES
    ('SETUP', 'TEST_DATA', 'FIN_ACCOUNT', 'SAMPLE', 'INFO', 'OK', 'Sample test data loaded', CURRENT TIMESTAMP);
