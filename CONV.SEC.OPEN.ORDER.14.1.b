* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 7 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>1091</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderCapture
      SUBROUTINE CONV.SEC.OPEN.ORDER.14.1
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
*************************************************************************
INITIALISE:
*
      EQU TRUE TO 1, FALSE TO ''
      CLS = ''                           ; * Clear Screen
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      COMPANY.CODE.POS = 56
      YFILE = "F.SEC.OPEN.ORDER"         ; * File to be converted
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)
      F.SCM = ''
      CALL OPF("F.SECURITY.MASTER",F.SCM)
      ON.LOCKING = 1
      READU R.LOCK FROM F.LOCKING,APPLICATION ELSE ON.LOCKING = 0
      IF ON.LOCKING THEN
         TEXT = "PROGRAM ALREADY RUN... ABORT ?"
         CALL REM
         RELEASE F.LOCKING,APPLICATION
         RETURN                          ; * Premature exit from the program
      END

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

      ID = FIELD(YFILE,'.',2,99)
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
         YFILE = 'F.FILE.CONTROL'
         GOTO FATAL.ERROR
      END
      MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
*
** If any fields are to be removed from the file add these here
** If several sets of fields are to be removed these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be deleted starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
** Add the position where new fields start, plus the number of fields
** required.
** If several sets of fields are to be added these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be added starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
      ADD.FIELD = ''
*      ADD.FIELD<1,1> = ""               ;* Position to add from. (New field number)
*      ADD.FIELD<2,1> = ""               ;* Number of fields to add.
*
*************************************************************************
*
** Take description of what the program will do from the PGM.FILE file
** and give the user the opportunity to quit.
*
      PRINT @(5,4):"Reason:"
      LOOP
         REMOVE LINE FROM DESCRIPTION SETTING MORE
         PRINT SPACE(5):LINE
      WHILE MORE
      REPEAT
      PRINT
      TEXT = "DO YOU WANT TO RUN THIS CONVERSION"
      CALL OVE
      IF TEXT EQ "Y" THEN
         SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()      ; * Summary of files & number of records converted.
         IF MULTI.COMPANY.FILE THEN
            SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK = "N"'
            COM.LIST = ''
            YSEL = 0
            CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
            LOOP
               REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
            WHILE K.COMPANY:END.OF.COMPANIES
               READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
                  FILE.NAME = 'F':MNEMONIC:'.':FIELD(YFILE,'.',2,99)
                  GOSUB MODIFY.FILE
               END
            REPEAT
         END ELSE                        ; * Internal File.
            READV MNEMONIC FROM F.COMPANY,ID.COMPANY,EB.COM.MNEMONIC THEN
               FILE.NAME=YFILE ; GOSUB MODIFY.FILE
            END
         END
*
*
         GOSUB PRINT.SUMMARY
         PRINT
         TEXT = 'CONVERSION COMPLETE'
         CALL REM
         R.LOCK<1> = TODAY
         WRITE R.LOCK TO F.LOCKING,APPLICATION
      END ELSE                           ; * OK to run Conversion.
         RELEASE F.LOCKING,APPLICATION
      END

      RETURN                             ; * Exit Program.
*
*************************************************************************
*
MODIFY.FILE:
*
      CALL SF.CLEAR.STANDARD
      TEXT = ""
      FOR FILE.TYPE = 1 TO 3
         BEGIN CASE
            CASE FILE.TYPE EQ 1
               SUFFIX = ""
            CASE FILE.TYPE EQ 2
               SUFFIX = "$NAU"
            CASE FILE.TYPE EQ 3
               SUFFIX = "$HIS"
         END CASE
         YFILE = FILE.NAME:SUFFIX
         F.FILE = ""
         OPEN '',YFILE TO F.FILE THEN
            GOSUB MODIFY.FILE.START
         END
      NEXT FILE.TYPE
      YFILE = FIELD(YFILE,'$',1)

      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
      CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
      V$COUNT = 0                        ; * Initialise.
      SELECT F.FILE
      END.OF.FILE = FALSE
      ABORT.FLAG = FALSE
      LOOP
         IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE END.OF.FILE = TRUE
         END
      UNTIL END.OF.FILE
*
         READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
         CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
         IF YREC<COMPANY.CODE.POS> MATCHES "2A7N" THEN
            TEXT = "CONVERSION ALREADY DONE... ABORT ?"
            CALL OVE
            IF TEXT EQ "Y" THEN
               END.OF.FILE = TRUE
               ABORT.FLAG = TRUE
            END
         END ELSE
            V$COUNT += 1                 ; * Count sucessful conversions.
*
** Add the fields specified here
*
            IF MNEMONIC = "BDG" THEN
               INS "" BEFORE YREC<24>    ; * DELIVERY KEY
               INS "" BEFORE YREC<24>    ; * CONFIRMATION
               INS "" BEFORE YREC<24>    ; * BROK.CORRES
               INS "" BEFORE YREC<24>    ; * BANK.CORRES
*
               INS "" BEFORE YREC<39>    ; * PREMIUM PRICE (40)
               INS "" BEFORE YREC<39>    ; * LIQUIDATION PERIOD(39)
            END ELSE
               INS "" BEFORE YREC<34>    ; * CUST.NOM.CODES
               INS "" BEFORE YREC<34>    ; * CUST DEPOSITORY NOMINAL
               INS "" BEFORE YREC<34>    ; * CUSTOMER DEPOSITORY
*
               INS "" BEFORE YREC<33>    ; * VERIFY BY BROKER
               INS "" BEFORE YREC<33>    ; * VAL.IN.SETTL.CCY
               INS "" BEFORE YREC<33>    ; * DEAL NARRATIVE
               INS "" BEFORE YREC<33>    ; * DEAL STATUS
               INS "" BEFORE YREC<33>    ; * MARKET TYPE
*
               INS "" BEFORE YREC<24>    ; * SEC.ACC.NO
*
               INS "" BEFORE YREC<21>    ; * DELIVERY KEYS
               INS "" BEFORE YREC<21>    ; * CONFIRMATION
               INS "" BEFORE YREC<21>    ; * BROKER CORESS
               INS "" BEFORE YREC<21>    ; * BANK CORESS
*
               INS "" BEFORE YREC<17>    ; * ACCT. NARRATIVE
*
               INS "" BEFORE YREC<11>    ; * LIMIT TYPE
*
               INS "" BEFORE YREC<5>     ; * MATURITY.DATE
*
            END
            NEW.REC = ''
            NEW.REC = YREC
            NEW.REC<2> = YREC<4>
            NEW.REC<3> = YREC<5>
            IF NEW.REC<3> = '' THEN
               READ R.SCM FROM F.SCM,YREC<2> ELSE R.SCM = ''
               NEW.REC<3> = R.SCM<26>
            END
            NEW.REC<4> = YREC<6>
            NEW.REC<5> = YREC<7>
            NEW.REC<6> = YREC<8>
            NEW.REC<7> = YREC<9>
            NEW.REC<8> = YREC<2>
            NEW.REC<9> = YREC<3>
            NEW.REC<11> = YREC<14>
            NEW.REC<12> = YREC<38>
            NEW.REC<13> = YREC<11>
            NEW.REC<14> = YREC<12>
            NEW.REC<15> = YREC<13>
            NEW.REC<16> = YREC<15>
            NEW.REC<17> = YREC<16>
            NEW.REC<18> = YREC<17>
            NEW.REC<19> = YREC<18>
            NEW.REC<20> = YREC<19>
            NEW.REC<21> = YREC<20>
            NEW.REC<22> = YREC<21>
            NEW.REC<23> = YREC<22>
            NEW.REC<24> = YREC<23>
            NEW.REC<25> = YREC<24>
            NEW.REC<26> = YREC<25>
            NEW.REC<27> = YREC<26>
            NEW.REC<28> = YREC<27>
            NEW.REC<29> = YREC<28>
            NEW.REC<30> = YREC<29>
            NEW.REC<31> = YREC<30>
            NEW.REC<32> = YREC<31>
            NEW.REC<33> = YREC<32>
            NEW.REC<34> = YREC<33>
            NEW.REC<35> = YREC<34>
            NEW.REC<36> = YREC<35>
            NEW.REC<37> = YREC<36>
            NEW.REC<38> = YREC<37>
*
            WRITE NEW.REC TO F.FILE, YID
*
         END                             ; * Valid Record.
*
      REPEAT
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
      RETURN
*
*************************************************************************
*
PRINT.SUMMARY:
      LINE.NO = 0
      PRINT CLS:                         ; * Clear Screen
      LOOP
         REMOVE LINE FROM SUMMARY.REPORT SETTING MORE
         PRINT LINE
         LINE.NO += 1
         IF NOT(MOD(LINE.NO,16)) THEN    ; * One Screen EQ 16 lines.
            TEXT = 'CONTINUE'
            CALL OVE
            IF TEXT NE 'Y' THEN
               MORE = FALSE
            END ELSE
               PRINT CLS:                ; * Clear Screen
            END
         END
      WHILE MORE
      REPEAT

      R.PGM.FILE<EB.PGM.DESCRIPTION,-1> = TRIM(LOWER(SUMMARY.REPORT))
      WRITE R.PGM.FILE TO F.PGM.FILE,APPLICATION

      RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      CALL PGM.BREAK
*
*************************************************************************
   END
