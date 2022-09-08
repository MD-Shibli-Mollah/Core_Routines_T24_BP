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

* Version 5 31/05/01  GLOBUS Release No. 200602 09/01/06
*-----------------------------------------------------------------------------
* <Rating>1252</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
      SUBROUTINE CONV.FORWARD.CRF.12.2
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
* 15/01/96 - GB9600049
*            Cater for forward prin increase in LD. Remove field no's
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
*
** The insert of the file being converted should be added here
*
$INSERT I_F.STMT.ENTRY
$INSERT I_F.MM.MONEY.MARKET
$INSERT I_F.LD.LOANS.AND.DEPOSITS
$INSERT I_F.MG.MORTGAGE
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
      DT = OCONV(DATE(),"D4E/")
      DT = DT[2]: DT[4,2]: DT[1,2]       ; * YYMMDD
      HOURS = OCONV(TIME(),"MT")
      DATE.TIME = DT: HOURS[1,2]: HOURS[4,2]
      TM = FMT(FIELD(TIME(),'.',1),'6"0"L')
      COMPANY.CODE.POS = ""              ; * Position of new XX.CO.CODE in the file
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

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
      ADD.FIELD = ''
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
         ORIGINAL.COMPANY = ID.COMPANY
         SELECT.COMMAND = "SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ 'N'"
         CALL EB.READLIST(SELECT.COMMAND,COMPANY.LIST,"","","")
         LOOP REMOVE K.COMPANY FROM COMPANY.LIST SETTING DX WHILE K.COMPANY:DX
            CALL LOAD.COMPANY(K.COMPANY)
            GOSUB MODIFY.FILE
         REPEAT
         CALL LOAD.COMPANY(ORIGINAL.COMPANY)
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
*
      CALL OPF("F.TRANS.FWD",F.TRANS.FWD)
      CALL OPF("F.STMT.ENTRY",F.STMT.ENTRY)
      CTR = 0
      FILE = "F.MG.MORTGAGE" ; GOSUB OPEN.FILE
      IF NOT(ETEXT) THEN
         GOSUB BUILD.FWD.MG
         SUMMARY.REPORT<-1> = FILE:" ":CTR:" forward entries raised"
      END

      CTR = 0
      FILE = "F.LD.LOANS.AND.DEPOSITS" ; GOSUB OPEN.FILE
      IF NOT(ETEXT) THEN
         GOSUB BUILD.FWD.LD
         SUMMARY.REPORT<-1> = FILE:" ":CTR:" forward entries raised"
      END

      CTR = 0
      FILE = "F.MM.MONEY.MARKET" ; GOSUB OPEN.FILE
      IF NOT(ETEXT) THEN
         GOSUB BUILD.FWD.MM
         SUMMARY.REPORT<-1> = FILE:" ":CTR:" forward entries raised"
      END
*

      RETURN
*
*************************************************************************
*
*
*=========================================================================
*
OPEN.FILE:
*
      FILE<2> = "NO.FATAL.ERROR"
      ETEXT = ""
      CALL OPF(FILE,F.FILE)
*
      IF NOT(ETEXT) THEN
         SELECT.COMMAND = "SELECT ":FILE
         CALL SF.CLEAR(1,5,"Adding forward crf entries for ":FILE)
         CALL EB.READLIST(SELECT.COMMAND,ID.LIST,"","","")
      END
*
      RETURN
*
*=========================================================================
*
BUILD.FWD.MG:
*
      LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
*
         READ R.MG.MORTGAGE FROM F.FILE, ID THEN
            GOSUB CHECK.FORWARD.CRF
            IF R.MG.MORTGAGE<3> = "FWD" THEN       ; * Contract Status
               IF R.MG.MORTGAGE<10> GE TODAY AND NOT(CRF.FORWARDS.EXIST) THEN
                  GOSUB BUILD.BASE.ENTRY
                  FWD.ENTRY = BASE.ENTRY
                  FWD.ENTRY<AC.STE.VALUE.DATE> = R.MG.MORTGAGE<10>
                  FWD.ENTRY<AC.STE.CURRENCY> = R.MG.MORTGAGE<4>
                  IF R.MG.MORTGAGE<4> # LCCY THEN
                     FWD.ENTRY<AC.STE.AMOUNT.FCY> = -R.MG.MORTGAGE<5>
                  END ELSE
                     FWD.ENTRY<AC.STE.AMOUNT.LCY> = -R.MG.MORTGAGE<5>
                  END
                  FWD.ENTRY<AC.STE.PRODUCT.CATEGORY> = R.MG.MORTGAGE<8>
                  FWD.ENTRY<AC.STE.CUSTOMER.ID> = R.MG.MORTGAGE<1>
                  FWD.ENTRY<AC.STE.SYSTEM.ID> = "MG"
                  FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDDB"
                  FWD.ENTRY<AC.STE.CRF.TXN.CODE> = "NEW"
                  GOSUB WRITE.FWD.ENTRY
               END
            END
         END
      REPEAT
*
      RETURN
*
*========================================================================
*
BUILD.FWD.LD:
*
      LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
*
         READ R.LD FROM F.FILE, ID THEN
            GOSUB CHECK.FORWARD.CRF
            IF NOT(CRF.FORWARDS.EXIST) THEN
               IF R.LD<83> = "FWD" THEN
                  IF R.LD<6> GE TODAY AND R.LD<11> GE 21001 AND R.LD<11> LE 21094 THEN
                     GOSUB BUILD.BASE.ENTRY
                     FWD.ENTRY = BASE.ENTRY
                     FWD.ENTRY<AC.STE.VALUE.DATE> = R.LD<6>
                     FWD.ENTRY<AC.STE.CURRENCY> = R.LD<2>
                     IF R.LD<11> GE 21050 AND R.LD<11> LE 21094 THEN
                        R.LD<4> = -R.LD<4>         ; * Correct crf sign
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDDB"
                     END ELSE
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDCR"
                     END
                     IF R.LD<2> # LCCY THEN
                        FWD.ENTRY<AC.STE.AMOUNT.FCY> = R.LD<4>
                     END ELSE
                        FWD.ENTRY<AC.STE.AMOUNT.LCY> = R.LD<4>
                     END
                     FWD.ENTRY<AC.STE.PRODUCT.CATEGORY> = R.LD<11>
                     FWD.ENTRY<AC.STE.CUSTOMER.ID> = R.LD<1>
                     FWD.ENTRY<AC.STE.SYSTEM.ID> = "LD"
                     FWD.ENTRY<AC.STE.CRF.TXN.CODE> = "FNW"
                     GOSUB WRITE.FWD.ENTRY
                  END
               END ELSE                  ; * Look for forward increase/decrease
                  IF R.LD<120> THEN
                     GOSUB BUILD.BASE.ENTRY
                     FWD.ENTRY = BASE.ENTRY
                     FWD.ENTRY<AC.STE.VALUE.DATE> = R.LD<121>
                     FWD.ENTRY<AC.STE.CURRENCY> = R.LD<2>
                     IF R.LD<11> GE 21050 AND R.LD<11> LE 21094 THEN
                        R.LD<120> = R.LD<LD.AMOUNT.INCREASE> * (-1)    ; * Correct crf sign
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDDB"
                     END ELSE
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDCR"
                     END
                     IF R.LD<2> # LCCY THEN
                        FWD.ENTRY<AC.STE.AMOUNT.FCY> = R.LD<120>
                     END ELSE
                        FWD.ENTRY<AC.STE.AMOUNT.LCY> = R.LD<120>
                     END
                     FWD.ENTRY<AC.STE.PRODUCT.CATEGORY> = R.LD<11>
                     FWD.ENTRY<AC.STE.CUSTOMER.ID> = R.LD<1>
                     FWD.ENTRY<AC.STE.SYSTEM.ID> = "LD"
                     FWD.ENTRY<AC.STE.CRF.TXN.CODE> = "FNW"
                     GOSUB WRITE.FWD.ENTRY
                  END
               END
            END
         END
*
      REPEAT
*
      RETURN
*
*=========================================================================
*
BUILD.FWD.MM:
*
      LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
*
         READ R.MM FROM F.FILE, ID THEN
            GOSUB CHECK.FORWARD.CRF
            IF NOT(CRF.FORWARDS.EXIST) THEN
               IF R.MM<74> = "FWD" THEN
                  IF R.MM<5> GE TODAY AND R.MM<7> GE 21001 AND R.MM<7> LE 21094 THEN
                     GOSUB BUILD.BASE.ENTRY
                     FWD.ENTRY = BASE.ENTRY
                     FWD.ENTRY<AC.STE.VALUE.DATE> = R.MM<5>
                     FWD.ENTRY<AC.STE.CURRENCY> = R.MM<2>
                     IF R.MM<7> GE 21050 AND R.MM<7> LE 21094 THEN
                        R.MM<3> = -R.MM<3>         ; * Correct crf sign
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDDB"
                     END ELSE
                        FWD.ENTRY<AC.STE.CRF.TYPE> = "FORWARDCR"
                     END
                     IF R.MM<2> # LCCY THEN
                        FWD.ENTRY<AC.STE.AMOUNT.FCY> = R.MM<3>
                     END ELSE
                        FWD.ENTRY<AC.STE.AMOUNT.LCY> = R.MM<3>
                     END
                     FWD.ENTRY<AC.STE.PRODUCT.CATEGORY> = R.MM<7>
                     FWD.ENTRY<AC.STE.CUSTOMER.ID> = R.MM<1>
                     FWD.ENTRY<AC.STE.SYSTEM.ID> = "MM"
                     FWD.ENTRY<AC.STE.CRF.TXN.CODE> = "FNW"
                     GOSUB WRITE.FWD.ENTRY
                  END
               END
            END
         END
*
      REPEAT
*
      RETURN
*
*=========================================================================
*
BUILD.BASE.ENTRY:
*
      BASE.ENTRY = ""
      BASE.ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
      BASE.ENTRY<AC.STE.OUR.REFERENCE> = ID
      BASE.ENTRY<AC.STE.CURRENCY.MARKET> = 1
      BASE.ENTRY<AC.STE.TRANS.REFERENCE> = ID
      BASE.ENTRY<AC.STE.BOOKING.DATE> = TODAY
      BASE.ENTRY<AC.STE.CURR.NO> = 1
      BASE.ENTRY<AC.STE.INPUTTER> = "SY_12.2.0"
      BASE.ENTRY<AC.STE.DATE.TIME> = DATE.TIME
      BASE.ENTRY<AC.STE.AUTHORISER> = "SY_12.2.0"
*
      RETURN
*
*=========================================================================
*
WRITE.FWD.ENTRY:
*
      READU R.TRANS.FWD FROM F.TRANS.FWD, ID THEN
         ENTRY.ID = "F": FWD.ENTRY<AC.STE.VALUE.DATE>:"."
         TM +=1
         ENTRY.ID := FMT(TM,"6'0'R")
         WRITE FWD.ENTRY TO F.STMT.ENTRY, ENTRY.ID
         R.TRANS.FWD<-1> = ENTRY.ID:"\":R.COMPANY(EB.COM.MNEMONIC)
         WRITE R.TRANS.FWD TO F.TRANS.FWD, ID
         CTR +=1
      END ELSE
         RELEASE F.TRANS.FWD
      END
*
      RETURN
*
*************************************************************************
*
CHECK.FORWARD.CRF:
*
      CRF.FORWARDS.EXIST = 0
      READ R.TRANS.FWD FROM F.TRANS.FWD, ID THEN
         LOOP REMOVE STMT.ID FROM R.TRANS.FWD SETTING XX WHILE STMT.ID:XX AND NOT(CRF.FORWARDS.EXIST)
            READ R.STMT.ENTRY FROM F.STMT.ENTRY, STMT.ID["\",1,1] THEN
               IF R.STMT.ENTRY<AC.STE.CRF.TYPE> THEN
                  CRF.FORWARDS.EXIST = 1
               END
            END
         REPEAT
      END

      RETURN
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
