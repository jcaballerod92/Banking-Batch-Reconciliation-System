-- *********************************************************************
-- SCRIPT NAME : 03_SP_FIN_RECONCILE.sql
-- PURPOSE     : Reconciliation and control process for financial
--               movements pending in staging.
--
-- DESCRIPTION :
--   - Provides a pending-movements view
--   - Compares staging against definitive DB2 reference data
--   - Classifies each row as RECONCILED, DIF or ERR
--   - Persists control and discrepancy records
--   - Updates staging status and audit trail
-- *********************************************************************

-- =====================================================================
-- VIEW: VW_FIN_PENDING_MOVEMENTS
-- ---------------------------------------------------------------------
-- Functional purpose:
--   Provides the set of staging movements that still require
--   reconciliation and control processing.
-- =====================================================================
CREATE OR REPLACE VIEW VW_FIN_PENDING_MOVEMENTS AS
SELECT
    S.STG_ID,
    S.TRANSACTION_ID,
    S.TRANSACTION_DATE,
    S.ACCOUNT_NUMBER,
    S.ACCOUNT_ID,
    S.TRANSACTION_TYPE,
    S.AMOUNT,
    S.CURRENCY,
    S.REFERENCE,
    S.CHANNEL,
    S.PROCESS_STATUS,
    S.RECON_STATUS
FROM FIN_STG_MOVEMENT S
WHERE S.PROCESS_STATUS = 'N';

-- =====================================================================
-- STORED PROCEDURE: SP_FIN_RECONCILE
-- ---------------------------------------------------------------------
-- Functional purpose:
--   Reconciles pending staging movements against definitive DB2 data.
--
-- Main steps:
--   1) Read pending movements from the view
--   2) Resolve account and validate its status
--   3) Compare amount, date, type, currency and reference
--   4) Classify as RECONCILED, DIF or ERR
--   5) Insert control and discrepancy rows
--   6) Update staging and audit information
-- =====================================================================
CREATE OR REPLACE PROCEDURE SP_FIN_RECONCILE ()
LANGUAGE SQL
MODIFIES SQL DATA
BEGIN ATOMIC

    -- -----------------------------------------------------------------
    -- DECLARATION SECTION
    -- Local variables used for reconciliation control, comparison logic
    -- and error handling.
    -- -----------------------------------------------------------------
    DECLARE V_STG_ID              BIGINT;
    DECLARE V_TRANSACTION_ID      VARCHAR(20);
    DECLARE V_TRANSACTION_DATE    DATE;
    DECLARE V_ACCOUNT_NUMBER      VARCHAR(20);
    DECLARE V_ACCOUNT_ID          BIGINT;
    DECLARE V_ACCOUNT_STATUS      CHAR(1);
    DECLARE V_TRANSACTION_TYPE    CHAR(2);
    DECLARE V_AMOUNT              DECIMAL(13,2);
    DECLARE V_CURRENCY            CHAR(3);
    DECLARE V_REFERENCE           VARCHAR(35);
    DECLARE V_CHANNEL             VARCHAR(10);

    DECLARE V_REGISTERED_AMOUNT   DECIMAL(13,2);
    DECLARE V_REGISTERED_DATE     DATE;
    DECLARE V_REGISTERED_TYPE     CHAR(2);
    DECLARE V_REGISTERED_CURRENCY CHAR(3);
    DECLARE V_REGISTERED_REF      VARCHAR(35);

    DECLARE V_ERROR_CODE          VARCHAR(6);
    DECLARE V_ERROR_DESCRIPTION   VARCHAR(60);
    DECLARE V_RECON_STATUS        VARCHAR(10);
    DECLARE V_REMARKS             VARCHAR(60);
    DECLARE V_DIFF_AMOUNT         DECIMAL(13,2);
    DECLARE V_NOT_FOUND           SMALLINT DEFAULT 0;
    DECLARE V_RECON_DATE          DATE;

    -- -----------------------------------------------------------------
    -- CURSOR DECLARATION
    -- Reads the pending movements to be processed by the reconciliation
    -- engine.
    -- -----------------------------------------------------------------
    DECLARE C_PENDING CURSOR FOR
        SELECT STG_ID,
               TRANSACTION_ID,
               TRANSACTION_DATE,
               ACCOUNT_NUMBER,
               TRANSACTION_TYPE,
               AMOUNT,
               CURRENCY,
               REFERENCE,
               CHANNEL
          FROM VW_FIN_PENDING_MOVEMENTS
         ORDER BY TRANSACTION_DATE, STG_ID;

    -- -----------------------------------------------------------------
    -- HANDLERS
    -- Manage expected DB2 conditions such as end of cursor and SQL
    -- exceptions during batch processing.
    -- -----------------------------------------------------------------
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET V_NOT_FOUND = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- In a production implementation this block would normally write
        -- a technical error record to the audit table before re-raising.
        RESIGNAL;
    END;

    -- -----------------------------------------------------------------
    -- INITIALIZATION
    -- Prepare the procedure state before starting the reconciliation loop.
    -- -----------------------------------------------------------------
    SET V_RECON_DATE = CURRENT DATE;

    -- -----------------------------------------------------------------
    -- OPEN CURSOR
    -- Starts the sequential processing of pending movement records.
    -- -----------------------------------------------------------------
    OPEN C_PENDING;

    -- -----------------------------------------------------------------
    -- MAIN RECONCILIATION LOOP
    -- Each pending movement is analysed against the reference account
    -- and movement tables.
    -- -----------------------------------------------------------------
    RECONCILE_LOOP:
    LOOP
        SET V_NOT_FOUND = 0;

        FETCH C_PENDING
            INTO V_STG_ID,
                 V_TRANSACTION_ID,
                 V_TRANSACTION_DATE,
                 V_ACCOUNT_NUMBER,
                 V_TRANSACTION_TYPE,
                 V_AMOUNT,
                 V_CURRENCY,
                 V_REFERENCE,
                 V_CHANNEL;

        IF V_NOT_FOUND = 1 THEN
            LEAVE RECONCILE_LOOP;
        END IF;

        -- Reset control values for current row.
        SET V_ACCOUNT_ID = NULL;
        SET V_ACCOUNT_STATUS = 'X';
        SET V_REGISTERED_AMOUNT = 0.00;
        SET V_REGISTERED_DATE = NULL;
        SET V_REGISTERED_TYPE = NULL;
        SET V_REGISTERED_CURRENCY = NULL;
        SET V_REGISTERED_REF = NULL;
        SET V_ERROR_CODE = NULL;
        SET V_ERROR_DESCRIPTION = NULL;
        SET V_RECON_STATUS = 'OK';
        SET V_REMARKS = 'MOVEMENT RECONCILED SUCCESSFULLY';
        SET V_DIFF_AMOUNT = 0.00;

        -- -------------------------------------------------------------
        -- STEP 1: VERIFY ACCOUNT EXISTENCE AND STATUS
        -- -------------------------------------------------------------
        SET V_NOT_FOUND = 0;

        SELECT A.ACCOUNT_ID,
               A.ACCOUNT_STATUS
          INTO V_ACCOUNT_ID,
               V_ACCOUNT_STATUS
          FROM FIN_ACCOUNT A
         WHERE A.ACCOUNT_NUMBER = V_ACCOUNT_NUMBER;

        IF V_NOT_FOUND = 1 THEN
            SET V_ERROR_CODE = 'E011';
            SET V_ERROR_DESCRIPTION = 'ACCOUNT NOT FOUND IN DB2';
            SET V_RECON_STATUS = 'ERR';
            SET V_REMARKS = V_ERROR_DESCRIPTION;
        ELSEIF V_ACCOUNT_STATUS <> 'A' THEN
            SET V_ERROR_CODE = 'E013';
            SET V_ERROR_DESCRIPTION = 'ACCOUNT NOT ACTIVE';
            SET V_RECON_STATUS = 'ERR';
            SET V_REMARKS = V_ERROR_DESCRIPTION;
        ELSE

            -- ---------------------------------------------------------
            -- STEP 2: SEARCH DEFINITIVE MOVEMENT AND COMPARE DATA
            -- ---------------------------------------------------------
            SET V_NOT_FOUND = 0;

            SELECT M.AMOUNT,
                   M.MOVEMENT_DATE,
                   M.MOVEMENT_TYPE,
                   M.CURRENCY,
                   M.REFERENCE
              INTO V_REGISTERED_AMOUNT,
                   V_REGISTERED_DATE,
                   V_REGISTERED_TYPE,
                   V_REGISTERED_CURRENCY,
                   V_REGISTERED_REF
              FROM FIN_MOVEMENT M
             WHERE M.TRANSACTION_ID = V_TRANSACTION_ID
               AND M.ACCOUNT_ID = V_ACCOUNT_ID;

            IF V_NOT_FOUND = 1 THEN
                SET V_ERROR_CODE = 'E014';
                SET V_ERROR_DESCRIPTION = 'MOVEMENT NOT FOUND IN DB2';
                SET V_RECON_STATUS = 'ERR';
                SET V_REMARKS = V_ERROR_DESCRIPTION;
            ELSE
                SET V_DIFF_AMOUNT = V_AMOUNT - V_REGISTERED_AMOUNT;

                IF V_AMOUNT = V_REGISTERED_AMOUNT
                   AND V_TRANSACTION_DATE = V_REGISTERED_DATE
                   AND V_TRANSACTION_TYPE = V_REGISTERED_TYPE
                   AND V_CURRENCY = V_REGISTERED_CURRENCY
                   AND COALESCE(V_REFERENCE, '') = COALESCE(V_REGISTERED_REF, '')
                THEN
                    SET V_RECON_STATUS = 'RECONCILED';
                    SET V_REMARKS = 'MOVEMENT RECONCILED SUCCESSFULLY';
                ELSE
                    SET V_ERROR_CODE = 'E015';
                    SET V_ERROR_DESCRIPTION = 'AMOUNT OR DATA DIFFERENCE';
                    SET V_RECON_STATUS = 'DIF';
                    SET V_REMARKS = V_ERROR_DESCRIPTION;
                END IF;
            END IF;
        END IF;

        -- -------------------------------------------------------------
        -- STEP 3: PERSIST CONTROL INFORMATION
        -- A control record is always written so that the batch keeps a
        -- full trace of the processed movement.
        -- -------------------------------------------------------------
        INSERT INTO FIN_RECON_CONTROL
            (STG_ID,
             TRANSACTION_ID,
             ACCOUNT_ID,
             ACCOUNT_NUMBER,
             STATUS,
             DIFFERENCE_AMOUNT,
             RECON_DATE,
             REMARKS)
        VALUES
            (V_STG_ID,
             V_TRANSACTION_ID,
             V_ACCOUNT_ID,
             V_ACCOUNT_NUMBER,
             V_RECON_STATUS,
             CASE
                 WHEN V_RECON_STATUS = 'RECONCILED' THEN 0.00
                 ELSE COALESCE(V_DIFF_AMOUNT, 0.00)
             END,
             V_RECON_DATE,
             V_REMARKS);

        -- -------------------------------------------------------------
        -- STEP 4: PERSIST DISCREPANCY INFORMATION WHEN REQUIRED
        -- -------------------------------------------------------------
        IF V_RECON_STATUS <> 'RECONCILED' THEN
            INSERT INTO FIN_DISCREPANCY
                (STG_ID,
                 TRANSACTION_ID,
                 ACCOUNT_ID,
                 ACCOUNT_NUMBER,
                 ERROR_CODE,
                 ERROR_DESCRIPTION,
                 EXPECTED_AMOUNT,
                 REGISTERED_AMOUNT,
                 DISC_DATE)
            VALUES
                (V_STG_ID,
                 V_TRANSACTION_ID,
                 V_ACCOUNT_ID,
                 V_ACCOUNT_NUMBER,
                 COALESCE(V_ERROR_CODE, 'E999'),
                 COALESCE(V_ERROR_DESCRIPTION, 'UNDEFINED RECONCILIATION ERROR'),
                 COALESCE(V_REGISTERED_AMOUNT, 0.00),
                 V_AMOUNT,
                 V_RECON_DATE);
        END IF;

        -- -------------------------------------------------------------
        -- STEP 5: UPDATE STAGING STATUS
        -- -------------------------------------------------------------
        UPDATE FIN_STG_MOVEMENT
           SET ACCOUNT_ID = V_ACCOUNT_ID,
               PROCESS_STATUS = CASE
                                  WHEN V_RECON_STATUS = 'ERR' THEN 'E'
                                  ELSE 'P'
                                END,
               RECON_STATUS = V_RECON_STATUS,
               ERROR_CODE = CASE
                               WHEN V_RECON_STATUS = 'RECONCILED' THEN NULL
                               ELSE COALESCE(V_ERROR_CODE, 'E999')
                            END,
               ERROR_DESCRIPTION = CASE
                                      WHEN V_RECON_STATUS = 'RECONCILED' THEN NULL
                                      ELSE COALESCE(V_ERROR_DESCRIPTION, 'UNDEFINED RECONCILIATION ERROR')
                                   END,
               RECON_DATE = V_RECON_DATE,
               RECON_TIMESTAMP = CURRENT TIMESTAMP
         WHERE STG_ID = V_STG_ID;

        -- -------------------------------------------------------------
        -- STEP 6: AUDIT / TRACEABILITY
        -- -------------------------------------------------------------
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
            ('SP_FIN_RECONCILE',
             'RECONCILIATION',
             'FIN_STG_MOVEMENT',
             VARCHAR(V_STG_ID),
             'RECONCILIATION',
             V_RECON_STATUS,
             COALESCE(V_REMARKS, 'PROCESS COMPLETED'),
             CURRENT TIMESTAMP);

    END LOOP;

    -- -----------------------------------------------------------------
    -- CLOSE CURSOR
    -- Releases cursor resources after all pending movements have been
    -- processed.
    -- -----------------------------------------------------------------
    CLOSE C_PENDING;

END;
