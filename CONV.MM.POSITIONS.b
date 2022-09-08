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
* <Rating>25</Rating>
*-----------------------------------------------------------------------------
* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
* Version 7.45.1 released on 09/11/87
    $PACKAGE MM.Foundation
      SUBROUTINE CONV.MM.POSITIONS(CONVERT.COMPANY, R.COMP)
*
*=======================================================================
*
* This program is called by the conversion template . First call the
* load company program and then check to see if this application
* is setup in the Company Record.
*
*
*  SUBROUTINE TO UPDATE POSITIONS FOR MONEY MARKET DEALS
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.DATES
$INSERT I_F.CATEG.ENTRY
*



      POS = ''
      IF R.COMP<EB.COM.CONSOLIDATION.MARK> NE 'C' AND R.COMP<EB.COM.CONSOLIDATION.MARK> NE 'R' THEN
         LOCATE 'MM' IN R.COMP<EB.COM.APPLICATIONS,1> SETTING POS ELSE POS = ''
      END
      IF NOT(POS) THEN
         RETURN                          ; * application not installed
      END

      PRINT @(10,10):'UPDATING POSITIONS IN ':CONVERT.COMPANY
      CALL LOAD.COMPANY(CONVERT.COMPANY)
      POS = ''

*
*-----------------------------------------------------------------------
      CAT.ENT.TODAY.FILE = "F.CATEG.ENT.TODAY"
      F.CAT.ENT.TODAY = ""
      CALL OPF(CAT.ENT.TODAY.FILE,F.CAT.ENT.TODAY)
*
      CATEG.ENTRY.FILE = "F.CATEG.ENTRY"
      F.CATEG.ENTRY = ""
      CALL OPF(CATEG.ENTRY.FILE,F.CATEG.ENTRY)
*
*
      SELECT.COMMAND = "SELECT ":CAT.ENT.TODAY.FILE:" WITH SYSTEM.ID LIKE 'MM...' BY SEL.CCY"
      CAT.ENT.TODAY.KEYS = ""
      CALL EB.READLIST(SELECT.COMMAND, CAT.ENT.TODAY.KEYS, "MM.CATEG", "", "")
*
      IF CAT.ENT.TODAY.KEYS THEN
         GOSUB PROCESS.CAT.ENT.TODAY
      END
*
      RETURN
*-----------------------------------------------------------------------
*
*=====================
PROCESS.CAT.ENT.TODAY:
*=====================
*
      YLAST.CCY = ""
      YDEBIT.TOTAL = 0 ; YCREDIT.TOTAL = 0
      YLOCAL.DEBIT.TOT = 0 ; YLOCAL.CREDIT.TOT = 0
      LOOP
         REMOVE YID FROM CAT.ENT.TODAY.KEYS SETTING YID.DELIM
         YENT.ID = FIELD(YID,"-",4)
         YFCCY = FIELD(YID,"-",3)
         IF YENT.ID THEN
            GOSUB PROCESS.ENTRY
         END
      UNTIL YID.DELIM = 0
      REPEAT
      YFCCY = ""
      GOSUB CHECK.CCY
*
      RETURN
*
************************************************************************
PROCESS.ENTRY:
**************
*
      GOSUB CHECK.CCY
*
      IF NOT(YFCCY MATCHES "":VM:LCCY) THEN
*
         READ CATEG.ENTRY.REC FROM F.CATEG.ENTRY,YENT.ID ELSE
            FILE.IN.ERROR = CATEG.ENTRY.FILE
            KEY.IN.ERROR = YENT.ID
            MODULE.IN.ERROR = "MM.EOD.UPDATE.POSITIONS"
            ERROR.MESSAGE = "CANNOT READ RECORD FROM FILE ":FILE.IN.ERROR:" ":KEY.IN.ERROR
            GOSUB UPDATE.EXCEPTION.LOG:
            ALL.RED = 1                  ; * DO NOT PROCESS OTHER ENTRIES.
            RETURN
         END
*
* Dont update positions for brokerage category entry's as this is done
* on line.
*
         IF CATEG.ENTRY.REC<AC.CAT.TRANSACTION.CODE> NE '477' THEN
            YAMT.FCY = CATEG.ENTRY.REC<AC.CAT.AMOUNT.FCY>
            YAMT.LCY = CATEG.ENTRY.REC<AC.CAT.AMOUNT.LCY>
            IF YAMT.FCY LT 0 THEN
               YDEBIT.TOTAL += YAMT.FCY
               YLOCAL.DEBIT.TOT += YAMT.LCY
            END ELSE
               YCREDIT.TOTAL += YAMT.FCY
               YLOCAL.CREDIT.TOT += YAMT.LCY
            END
         END
*
      END
*
      RETURN
*
***********************************************************************
CHECK.CCY:
**********
*
      IF YLAST.CCY NE YFCCY THEN
         IF YDEBIT.TOTAL OR YLOCAL.DEBIT.TOT THEN
            YCALL.AMT1 = YDEBIT.TOTAL
            YCALL.AMT2 = YLOCAL.DEBIT.TOT
            GOSUB UPDATE.POSITIONS
         END
         IF YCREDIT.TOTAL OR YLOCAL.CREDIT.TOT THEN
            YCALL.AMT1 = YCREDIT.TOTAL
            YCALL.AMT2 = YLOCAL.CREDIT.TOT
            GOSUB UPDATE.POSITIONS
         END
         YDEBIT.TOTAL = 0 ; YCREDIT.TOTAL = 0
         YLOCAL.DEBIT.TOT = 0 ; YLOCAL.CREDIT.TOT = 0
         YLAST.CCY = YFCCY
      END
*
      RETURN
*
*================
UPDATE.POSITIONS:
*================
*
      CURRENCY.1 = YLAST.CCY
      AMOUNT.1 = YCALL.AMT1 * (-1)
      CURRENCY.2 = LCCY
      IF AMOUNT.1 LT "0" THEN
         AMOUNT.2 = ABS(YCALL.AMT2)
      END ELSE
         AMOUNT.2 = ABS(YCALL.AMT2) * (-1)
      END
      LOCAL.CCY.1 = AMOUNT.2 * (-1)
      LOCAL.CCY.2 = AMOUNT.2
*
      RETURN.CODE = ""
      CALL CURRENCY.POSITION ("","","",
         "",
         ID.COMPANY,
         "TR","TR","00","1",
         CURRENCY.1 , CURRENCY.2 ,
         AMOUNT.1 , AMOUNT.2 ,
         R.DATES (EB.DAT.TODAY),
         "",
         "",
         "",
         LOCAL.CCY.1,
         LOCAL.CCY.2,
         "","",
         RETURN.CODE)
*
      CALL JOURNAL.UPDATE("")
      RETURN
*
*====================
UPDATE.EXCEPTION.LOG:
*====================
*
      TEXT = ERROR.MESSAGE
      CALL FATAL.ERROR(MODULE.IN.ERROR)
      RETURN
*
   END
