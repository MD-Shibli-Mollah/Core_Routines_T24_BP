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

*-----------------------------------------------------------------------------
* <Rating>1011</Rating>
*-----------------------------------------------------------------------------
* Version 3 07/09/00  GLOBUS Release No. 200602 09/01/06

    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.BALANCES.12.1.0
*   19 MAR 93
*    Convert existing MG.BALANCES records for new fields

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.MG.BALANCES

*************************************************************************

      GOSUB INITIALISE                   ; * Special Initialising

*************************************************************************

* Main Program Loop

      IF CONT THEN
         Y.END = ""
         LOOP
            Z += 1
            YSELFILE.NAME = FIELD(YFILE.LIST,":",Z)
            YFILE.NAME = 'F.':YSELFILE.NAME
         UNTIL YSELFILE.NAME = "" OR Y.END = "END" DO
            F.MG.BALANCES = ''
            CALL OPF(YFILE.NAME,F.MG.BALANCES)
            SELECT.STATEMENT = 'SELECT ':YFILE.NAME
            YSTO.ID.LIST = ""
            CALL EB.READLIST(SELECT.STATEMENT, YSTO.ID.LIST, "", "", "")
            PREVIOUS.REC = ""
            LOOP
               YSTO = YSTO.ID.LIST<1>
            UNTIL YSTO = "" OR Y.END = "END" DO
               DEL YSTO.ID.LIST<1>
               NEW.REC = ""
               PREVIOUS.REC = ""
               ETEXT = ''
               READU PREVIOUS.REC FROM F.MG.BALANCES,YSTO ELSE PREVIOUS.REC = ""
               YCOUNT.FM = DCOUNT(PREVIOUS.REC,FM)
               IF YCOUNT.FM LT START.FIELD THEN
                  Y.END = "END"
                  CRT CRT.KEY.POS:"CONV.MG.12.1.0 HAS NOT BEEN RUN"
               END ELSE
                  IF YCOUNT.FM < (START.FIELD+NO.OF.FIELDS) THEN
                     NEW.REC = PREVIOUS.REC
                     FOR X = START.FIELD TO EN.FIELD STEP - 1
                        NEW.REC = REPLACE(NEW.REC,X+NO.OF.FIELDS;PREVIOUS.REC<X>)
                        NEW.REC = REPLACE(NEW.REC,X;"")
                     NEXT X
                     NO.OF.EXIST.PMTS = DCOUNT(NEW.REC<MG.BAL.PAYMENT.DATE>,VM)
                     FOR X = 1 TO NO.OF.EXIST.PMTS
                        IF NEW.REC<MG.BAL.MG.PAYMENT.NO,X> THEN
                           NEW.REC = REPLACE(NEW.REC,MG.BAL.REPAY.TYPE,X;"REDEMPTION")
                        END ELSE
                           IF NEW.REC<MG.BAL.PRINCIPAL.RCVD,X> THEN
                              NEW.REC = REPLACE(NEW.REC,MG.BAL.REPAY.TYPE,X;"AUTO.REDEM")
                           END ELSE
                              NEW.REC = REPLACE(NEW.REC,MG.BAL.REPAY.TYPE,X;"AUTO.REPAY")
                           END
                        END
                     NEXT X
                     CRT CRT.KEY.POS:YSTO
                     WRITE NEW.REC TO F.MG.BALANCES,YSTO
                  END ELSE
                     RELEASE F.MG.BALANCES,YSTO
                     IF ETEXT THEN CALL EXCEPTION.LOG('S','ST','CONV.MG.BALANCES','','','','F.MG.BALANCES',YSTO,'','','')
                  END
               END
            REPEAT

MAIN.REPEAT:
         REPEAT
      END

V$EXIT:
      RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

INITIALISE:

*
      PRINT @(10,7):'This program will convert the BALANCES files and add'
      PRINT @(10,8):'redemption field. CONV.MG.12.1.0 must have been run'
      PRINT @(15,10):' Continue Y/N : ':
      INPUT CONT
      IF CONT EQ 'Y' THEN
         CONT = 1
      END ELSE
         CONT = ''
      END
*
      IF CONT THEN
         Z = 0
         NO.OF.FIELDS = 1
         START.FIELD = 39
         EN.FIELD = 30
         YFILE.LIST = 'MG.BALANCES:MG.BALANCES.HIST:MG.BALANCES.SAVE'
         CRT.DIS.MESS = "NOW UPDATING MG.BALANCES: "
         CRT.DIS.POS = @(10,12)
         CRT.KEY.POS = @(40,12)
         CRT CRT.DIS.POS:CRT.DIS.MESS
      END

      RETURN

*************************************************************************

   END
