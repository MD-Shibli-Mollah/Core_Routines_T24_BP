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
* <Rating>3060</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.14.2
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
$INSERT I_F.ACCOUNT
$INSERT I_F.SC.DEF.ACCOUNT
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
      TEXT = ''
      ETEXT = ''
      CLS = ''                           ; * Clear Screen
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      YFILE = "F.SEC.ACC.MASTER"         ; * File to be converted
      COMPANY.CODE.POS = "77"            ; * Position of new XX.CO.CODE in the file
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

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
      F.SC.DEF.ACCOUNT = ''
      CALL OPF('F.SC.DEF.ACCOUNT',F.SC.DEF.ACCOUNT)
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
      CANCEL.FIELD = ""
**      CANCEL.FIELD<1,1> = ""            ;* Position to cancel from.
**      CANCEL.FIELD<2,1> = ""            ;* Number of fields to cancel.
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
      R.SC.DEF.ACCOUNT = ''
      CALL F.READ('F.SC.DEF.ACCOUNT','SYSTEM',R.SC.DEF.ACCOUNT,F.SC.DEF.ACCOUNT,ETEXT)
      IF ETEXT THEN
         R.SC.DEF.ACCOUNT<1> = 'SC'
      END
      IF TEXT EQ "Y" THEN
         SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()      ; * Summary of files & number of records converted.
         IF MULTI.COMPANY.FILE THEN
            SEL.CMD = 'SSELECT F.COMPANY'
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
            FILE.NAME=YFILE ; GOSUB MODIFY.FILE
         END
*
         IF NOT(ABORT.FLAG) THEN
* This subroutine will maintain the correct field numbers in any
* ENQUIRYs, REPGENs, STATIC.TEXT, and VERSIONs
*            CALL MODIFY.DATA(YFILE,ADD.FIELD,CANCEL.FIELD,SUMMARY.REPORT)
         END
*
         GOSUB PRINT.SUMMARY
         PRINT
         TEXT = 'CONVERSION COMPLETE'
         CALL REM
      END                                ; * OK to run Conversion.

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
         IF INDEX(YREC<15>,VM,1) THEN
            TEXT = "CONVERSION ALREADY DONE... ABORT ?"
            CALL OVE
            IF TEXT EQ "Y" THEN
               END.OF.FILE = TRUE
               ABORT.FLAG = TRUE
            END
         END ELSE
            IF YREC<35> ELSE             ; * Not Dealer Books
               V$COUNT += 1              ; * Count sucessful conversions.
*
** Delete the fields specified here
*
               X = 0
               LOOP X += 1 UNTIL CANCEL.FIELD<1,X> = ""
                  POS = CANCEL.FIELD<1,X>
                  NOF = CANCEL.FIELD<2,X>
                  FOR Y = 1 TO NOF
                     DEL YREC<POS>
                  NEXT Y
               REPEAT
*
** Add the fields specified here
*
               X = 0
               LOOP X += 1 UNTIL ADD.FIELD<1,X> = ''
                  POS = ADD.FIELD<1,X>
                  NOF = ADD.FIELD<2,X>
                  FOR Y = 1 TO NOF
                     INS "" BEFORE YREC<POS>
                  NEXT Y
               REPEAT
*
               PURCHASE.ACCOUNT = YREC<14>
               PURCHASE.CCY = YREC<15>
               SALES.ACCOUNT = YREC<16>
               SALES.CCY = YREC<17>
               DIV.ACC.LIST = YREC<18>
               DIV.CCY.LIST = YREC<19>
               DIV.ACC.COUNT = DCOUNT(DIV.ACC.LIST,VM)
*
               ACC.COUNT = DCOUNT(YREC<13>,VM)
               FOR CT = 1 TO ACC.COUNT
                  ACC.CCY = ''
                  CALL DBR("ACCOUNT":FM:AC.CURRENCY:FM:".A",YREC<13,CT>,ACC.CCY)
                  YREC<14,CT> = ACC.CCY
               NEXT CT
*
               YREC<15> = ''
               YREC<16> = ''
               YREC<17> = ''
               YREC<18> = ''
               YREC<19> = ''
*
               IF PURCHASE.ACCOUNT THEN
                  PURCHASE.COUNT = DCOUNT(R.SC.DEF.ACCOUNT<SC.DEF.PURCHASE.TRANS>,VM)
                  FOR CT = 1 TO PURCHASE.COUNT
                     APPLIC = ''
                     LOCATE R.SC.DEF.ACCOUNT<SC.DEF.PURCHASE.TRANS,CT> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                        APPLIC = 1
                     END
                     BEGIN CASE
                        CASE R.SC.DEF.ACCOUNT<SC.DEF.PURCHASE.TRANS,CT> = 'ALL'
                           YREC<15,CT> = 'ALL'
                           YREC<17,CT> = PURCHASE.CCY
                           YREC<18,CT> = PURCHASE.ACCOUNT
                           YREC<19,CT> = PURCHASE.ACCOUNT
                        CASE APPLIC
                           YREC<15,CT> = R.SC.DEF.ACCOUNT<SC.DEF.PURCHASE.TRANS,CT>
                           YREC<17,CT> = PURCHASE.CCY
                           YREC<18,CT> = PURCHASE.ACCOUNT
                           YREC<19,CT> = PURCHASE.ACCOUNT
                        CASE 1
                           YREC<15,CT> = "SC-":R.SC.DEF.ACCOUNT<SC.DEF.PURCHASE.TRANS,CT>
                           YREC<17,CT> = PURCHASE.CCY
                           YREC<18,CT> = PURCHASE.ACCOUNT
                           YREC<19,CT> = PURCHASE.ACCOUNT
                     END CASE
                     GOSUB OTHER.ACCOUNTS
                  NEXT CT
               END ELSE
                  PURCHASE.COUNT = 0
               END
*
               IF SALES.ACCOUNT THEN
                  SALES.COUNT = DCOUNT(R.SC.DEF.ACCOUNT<SC.DEF.SALES.TRANS>,VM)
                  SALES.START = PURCHASE.COUNT + 1
                  SALES.END = SALES.START + SALES.COUNT - 1
                  FOR CT = SALES.START TO SALES.END
                     PLACE = CT - SALES.START + 1
                     APPLIC = ''
                     LOCATE R.SC.DEF.ACCOUNT<SC.DEF.SALES.TRANS,CT> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                        APPLIC = 1
                     END
                     BEGIN CASE
                        CASE R.SC.DEF.ACCOUNT<SC.DEF.SALES.TRANS,PLACE> = 'ALL'
                           YREC<15,CT> = 'ALL'
                           YREC<17,CT> = SALES.CCY
                           YREC<18,CT> = SALES.ACCOUNT
                           YREC<19,CT> = SALES.ACCOUNT
                        CASE APPLIC
                           YREC<15,CT> = R.SC.DEF.ACCOUNT<SC.DEF.SALES.TRANS,PLACE>
                           YREC<17,CT> = SALES.CCY
                           YREC<18,CT> = SALES.ACCOUNT
                           YREC<19,CT> = SALES.ACCOUNT
                        CASE 1
                           YREC<15,CT> = "SC-":R.SC.DEF.ACCOUNT<SC.DEF.SALES.TRANS,PLACE>
                           YREC<17,CT> = SALES.CCY
                           YREC<18,CT> = SALES.ACCOUNT
                           YREC<19,CT> = SALES.ACCOUNT
                     END CASE
                     GOSUB OTHER.ACCOUNTS
                  NEXT CT
               END ELSE
                  SALES.END = PURCHASE.COUNT
               END
*
               DIV.COUNT = DCOUNT(R.SC.DEF.ACCOUNT<SC.DEF.DIVIDEND.TRANS>,VM)
               DIV.START = SALES.END + 1
               DIV.END = DIV.START + DIV.COUNT - 1
               IF DIV.ACC.LIST<1,1> THEN
                  FOR CT = DIV.START TO DIV.END
                     PLACE = CT - DIV.START + 1
                     BEGIN CASE
                        CASE R.SC.DEF.ACCOUNT<SC.DEF.DIVIDEND.TRANS,PLACE> = 'ALL'
                           YREC<15,CT> = 'ALL'
                           FOR CNT = 1 TO DIV.ACC.COUNT
                              YREC<17,CT,CNT> = DIV.CCY.LIST<1,CNT>
                              YREC<18,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              IF CNT = 1 THEN
                                 YREC<19,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              END
                           NEXT CNT
                        CASE APPLIC
                           YREC<15,CT> = R.SC.DEF.ACCOUNT<SC.DEF.DIVIDEND.TRANS,PLACE>
                           FOR CNT = 1 TO DIV.ACC.COUNT
                              YREC<17,CT,CNT> = DIV.CCY.LIST<1,CNT>
                              YREC<18,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              IF CNT = 1 THEN
                                 YREC<19,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              END
                           NEXT CNT
                        CASE 1
                           YREC<15,CT> = "SC-":R.SC.DEF.ACCOUNT<SC.DEF.DIVIDEND.TRANS,PLACE>
                           FOR CNT = 1 TO DIV.ACC.COUNT
                              YREC<17,CT,CNT> = DIV.CCY.LIST<1,CNT>
                              YREC<18,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              IF CNT = 1 THEN
                                 YREC<19,CT,CNT> = DIV.ACC.LIST<1,CNT>
                              END
                           NEXT CNT
                     END CASE
                     GOSUB OTHER.ACCOUNTS
                  NEXT CT
               END ELSE
                  DIV.END = SALES.END
               END
*
               IF YREC<13,1> THEN
                  IF YREC<15> ELSE
                     YREC<15> = 'SC'
                     IF PURCHASE.ACCOUNT THEN
                        YREC<19> = PURCHASE.ACCOUNT
                     END ELSE
                        YREC<19> = YREC<13,1>
                     END
                     GOSUB OTHER.ACCOUNTS
                  END
               END
*
               WRITE YREC TO F.FILE, YID
            END
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
*--------------
OTHER.ACCOUNTS:
*--------------
*
      FOR ACC.CT = 1 TO ACC.COUNT
         ACC.CCY = YREC<14,ACC.CT>
         LOCATE ACC.CCY IN YREC<17,CT,1> SETTING POSN ELSE
            YREC<17,CT,-1> = ACC.CCY
            YREC<18,CT,-1> = YREC<13,ACC.CT>
         END
      NEXT ACC.CT
*
      RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      ETEXT = "Why program aborted"      ; * Used to update F.CONVERSION.PGMS
      CALL PGM.BREAK
*
*************************************************************************
   END
