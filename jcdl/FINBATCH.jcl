//FINBATCH JOB (ACCT),'FINANCIAL BATCH',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*---------------------------------------------------------------*
//* JOB NAME  : FINBATCH
//* PURPOSE   : Batch orchestration for financial movement flow
//*             validation -> reconciliation -> reporting
//*---------------------------------------------------------------*
//SETUP    EXEC PGM=IEFBR14
//
//*****************************************************************
//* STEP01 - VALIDATION AND STAGING LOAD
//* Runs FINVLD01 to validate the input movements file and write
//* valid records to staging and invalid records to error output.
//*****************************************************************
//STEP01   EXEC PGM=FINVLD01
//STEPLIB  DD  DISP=SHR,DSN=FIN.LOADLIB
//INFILE   DD  DISP=SHR,DSN=FIN.INPUT.MOVEMENTS
//STGFILE  DD  DISP=SHR,DSN=FIN.STAGE.MOVEMENTS
//ERRFILE  DD  DISP=SHR,DSN=FIN.ERROR.MOVEMENTS
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//
//*****************************************************************
//* STEP02 - RECONCILIATION
//* Runs FINREC02 to compare staged movements against DB2 data,
//* generate reconciliation control records and discrepancy detail.
//*****************************************************************
//STEP02   EXEC PGM=FINREC02
//STEPLIB  DD  DISP=SHR,DSN=FIN.LOADLIB
//STGFILE  DD  DISP=SHR,DSN=FIN.STAGE.MOVEMENTS
//CTRLFILE DD  DISP=SHR,DSN=FIN.RECON.CONTROL
//DISCFILE DD  DISP=SHR,DSN=FIN.DISCREPANCY
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//DBRMLIB  DD  DISP=SHR,DSN=FIN.DB2.DBRMLIB
//SYSIN    DD  *
/* If FINREC02 requires control parameters, they would be placed here */
/*
//
//*****************************************************************
//* STEP03 - SUMMARY AND EXCEPTIONS REPORT
//* Runs FINRPT03 to build summary output and detailed exception
//* report using reconciliation and discrepancy files.
//*****************************************************************
//STEP03   EXEC PGM=FINRPT03
//STEPLIB  DD  DISP=SHR,DSN=FIN.LOADLIB
//CTRLFILE DD  DISP=SHR,DSN=FIN.RECON.CONTROL
//DISCFILE DD  DISP=SHR,DSN=FIN.DISCREPANCY
//RPTFILE  DD  DISP=SHR,DSN=FIN.REPORT.SUMMARY
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//
//*---------------------------------------------------------------*
//* END OF JOB
//*---------------------------------------------------------------*
//