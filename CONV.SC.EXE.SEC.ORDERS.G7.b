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
* <Rating>813</Rating>
*-----------------------------------------------------------------------------
* Version 3 01/06/01  GLOBUS Release No. 200511 31/10/05
*
    $PACKAGE SC.SctOrderExecution
      SUBROUTINE CONV.SC.EXE.SEC.ORDERS.G7
*
*----------------------------------------------------------------
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SEC.OPEN.ORDER
$INSERT I_F.SC.EXE.SEC.ORDERS
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
*
      EQU TRUE TO 1, FALSE TO ''
      CLS = ''                           ; * Clear Screen
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      SEC.OPEN.ORDER.FILE = 'F.SEC.OPEN.ORDER'
      F.SEC.OPEN.ORDER = ''
      CALL OPF(SEC.OPEN.ORDER.FILE,F.SEC.OPEN.ORDER)
      F.SC.EXE.SEC.ORDERS = ''
      CALL OPF('F.SC.EXE.SEC.ORDERS',F.SC.EXE.SEC.ORDERS)
*
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)
      ID = FIELD('F.SEC.OPEN.ORDER','.',2,99)
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
         YFILE = 'F.FILE.CONTROL'
         GOTO FATAL.ERROR
      END
      MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
*
      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>
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
            SEL.CMD = 'SSELECT F.COMPANY'
            COM.LIST = ''
            YSEL = 0
            CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
            LOOP
               REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
            WHILE K.COMPANY:END.OF.COMPANIES
               READV APPLICATION.LIST FROM F.COMPANY,K.COMPANY,EB.COM.APPLICATIONS THEN
                  LOCATE 'SC' IN APPLICATION.LIST<1,1> SETTING DUMMY THEN
                     READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
                        GOSUB MODIFY.FILE
                     END
                  END
               END
            REPEAT
         END ELSE                        ; * Internal File.
            FILE.NAME=YFILE ; GOSUB MODIFY.FILE
         END
*
         GOSUB PRINT.SUMMARY
         PRINT
         TEXT = 'CONVERSION COMPLETE'
         CALL REM
      END                                ; * OK to run Conversion.

      RETURN                             ; * Exit Program.
*
*-----------
MODIFY.FILE:
*-----------
*
      SEC.OPEN.ORDER.FILE = 'F':MNEMONIC:'.SEC.OPEN.ORDER'
      F.SEC.OPEN.ORDER = ''
      OPEN '',SEC.OPEN.ORDER.FILE TO F.SEC.OPEN.ORDER ELSE
         CRT 'CANNOT OPEN ':SEC.OPEN.ORDER.FILE
         CALL FATAL.ERROR('CONV.SC.EXE.SEC.ORDERS.G7')
      END
      SC.EXE.SEC.ORDERS.FILE = 'F':MNEMONIC:'.SC.EXE.SEC.ORDERS'
      F.SC.EXE.SEC.ORDERS = ''
      OPEN '',SC.EXE.SEC.ORDERS.FILE TO F.SC.EXE.SEC.ORDERS ELSE
         CRT 'CANNOT OPEN ':SC.EXE.SEC.ORDERS.FILE
         CALL FATAL.ERROR('CONV.SC.EXE.SEC.ORDERS.G7')
      END
      COMMAND = 'SELECT ':SEC.OPEN.ORDER.FILE:' WITH TYPE.OF.TRADE = "SEC.TRADE"'
      KEY.LIST = ''
      SELECTED = ''
      SYSTEM.RET.CODE = ''
      CALL EB.READLIST(COMMAND,KEY.LIST,'',SELECTED,SYSTEM.RET.CODE)
      EOF = ''
      V$COUNT = 0
      LOOP
         REMOVE ID FROM KEY.LIST SETTING MORE
      WHILE ID:MORE DO
         READ R.SEC.OPEN.ORDER FROM F.SEC.OPEN.ORDER,ID THEN
            ESO.REC = ''
            ESO.REC<SC.ESO.ORDER.NUMBER> = ID
            ESO.REC<SC.ESO.SECURITY.NO> = R.SEC.OPEN.ORDER<SC.SOO.SECURITY.NO>
            ESO.REC<SC.ESO.TRANSACTION.CODE>= R.SEC.OPEN.ORDER<SC.SOO.TRANSACTION.CODE>
            ESO.REC<SC.ESO.ORDER.TYPE> = R.SEC.OPEN.ORDER<SC.SOO.ORDER.TYPE>
            IF ESO.REC<SC.ESO.ORDER.TYPE> = 'M' THEN R.SEC.OPEN.ORDER<SC.ESO.ORDER.TYPE> = 'MARKET'
            IF ESO.REC<SC.ESO.ORDER.TYPE> = 'P' THEN R.SEC.OPEN.ORDER<SC.ESO.ORDER.TYPE> = 'PRICE'
            ESO.REC<SC.ESO.TRADE.CCY> = R.SEC.OPEN.ORDER<SC.SOO.TRADE.CCY>
            ESO.REC<SC.ESO.NOMINAL.BALANCE> = SUM(R.SEC.OPEN.ORDER<SC.SOO.NO.NOMINAL>)
            ESO.REC<SC.ESO.MARKET.TYPE> = R.SEC.OPEN.ORDER<SC.SOO.MARKET.TYPE>
            ESO.REC<SC.ESO.ORDER.BROKER> = R.SEC.OPEN.ORDER<SC.SOO.BROKER>
            ESO.REC<SC.ESO.AMT.TO.BROKER> = R.SEC.OPEN.ORDER<SC.SOO.AMT.TO.BROKER>
            ESO.REC<SC.ESO.EXE.BY.BROKER> = R.SEC.OPEN.ORDER<SC.SOO.EXE.BY.BROKER>
            ESO.REC<SC.ESO.NARRATIVE> = R.SEC.OPEN.ORDER<SC.SOO.NARRATIVE>
            ESO.REC<SC.ESO.NOMINAL.RECD> = SUM(R.SEC.OPEN.ORDER<SC.SOO.NO.NOMINAL>)
            ESO.REC<SC.ESO.ACCT.NARRATIVE> = R.SEC.OPEN.ORDER<SC.SOO.ACCT.NARRATIVE>
            IF R.SEC.OPEN.ORDER<SC.SOO.CUST.NUMBER> THEN
               ESO.REC<SC.ESO.CUSTOMER.NO> = R.SEC.OPEN.ORDER<SC.SOO.CUST.NUMBER>
            END
            IF R.SEC.OPEN.ORDER<SC.SOO.SECURITY.ACCNT> THEN
               ESO.REC<SC.ESO.SECURITY.ACCT> = R.SEC.OPEN.ORDER<SC.SOO.SECURITY.ACCNT>
               ESO.REC<SC.ESO.CUST.NOMINAL> = R.SEC.OPEN.ORDER<SC.SOO.NO.NOMINAL>
            END
            IF R.SEC.OPEN.ORDER<SC.SOO.BROKER> THEN
               CNT.BROKERS = COUNT(R.SEC.OPEN.ORDER<SC.SOO.BROKER>,VM) + (R.SEC.OPEN.ORDER<SC.SOO.BROKER> # '')
               IF CNT.BROKERS = 1 THEN
                  ESO.REC<SC.ESO.BROKER.NO> = R.SEC.OPEN.ORDER<SC.SOO.BROKER>
               END ELSE
                  ESO.REC<SC.ESO.BROKER.NO> = ''
                  IF CNT.BROKERS GT 1 THEN
                     ESO.REC<SC.ESO.NOMINAL.RECD> = ''
                  END
               END
            END
            IF R.SEC.OPEN.ORDER<SC.SOO.DEPOSITORY> THEN
               ESO.REC<SC.ESO.DEPOSITORY> = R.SEC.OPEN.ORDER<SC.SOO.DEPOSITORY>
            END
*
            WRITE ESO.REC ON F.SC.EXE.SEC.ORDERS,ID
            V$COUNT += 1
         END
      REPEAT
      SUMMARY.REPORT<-1> = FMT(SEC.OPEN.ORDER.FILE,'30L'):FMT(V$COUNT,'6R0,')
*
      RETURN
*
*-------------
PRINT.SUMMARY:
*-------------
*
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
*-----------
FATAL.ERROR:
*-----------
*
      CALL FATAL.ERROR('CONV.SC.EXE.SEC.ORDERS.G7')
      RETURN
*
   END
