//COMPILE  JOB (ACCT),'COBOL COMPILE',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*---------------------------------------------------------------*
//* JOB NAME  : COMPILE
//* PURPOSE   : Compile and link-edit COBOL programs
//*---------------------------------------------------------------*
//COBCOMP  EXEC PGM=IGYWCL
//STEPLIB  DD  DISP=SHR,DSN=IGY.V6R3M0.SIGYCOMP
//SYSIN    DD  *
   //FINVLD01  CBL
   //FINREC02  CBL
   //FINRPT03  CBL
/*
//SYSLIB   DD  DISP=SHR,DSN=FIN.COPYLIB
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(5,5))
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//LKED.SYSLMOD DD DISP=SHR,DSN=FIN.LOADLIB
//