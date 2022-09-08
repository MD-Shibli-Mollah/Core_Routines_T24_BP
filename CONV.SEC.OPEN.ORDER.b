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

* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>462</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderCapture
      SUBROUTINE CONV.SEC.OPEN.ORDER
* This program select all the SEC.OPEN.ORDER records on the Live
* and unauthorised fiels, if settlement ccy is present then this value
* is used to default the account otherwise Trade ccy is used .
*GB0000401
*
* 04/09/02 - CI_10003518
*            CONVERSION.DETAIL Program should have field numbers
*            instead of field names
*
* 10/12/08 - GLOBUS_CI_10059339
*            Conversion fails while running RUN.CONVERSION.PGMS
*
***********************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT
$INSERT I_F.SEC.OPEN.ORDER
*
      FN.SEC.OPEN = "F.SEC.OPEN.ORDER" ; F.SEC.OPEN.ORDER = ""
      CALL OPF(FN.SEC.OPEN, F.SEC.OPEN.ORDER)
*
      F.SEC.OPEN.NAU = 'F.SEC.OPEN.ORDER$NAU' ; F.SEC.OPEN.ORDER$NAU = ''
      CALL OPF(F.SEC.OPEN.NAU,F.SEC.OPEN.ORDER$NAU)
*
      EXECUTE ' SELECT ':FN.SEC.OPEN
      SOO.REC = '' ; REC.UPD = '' ; LIVE.FL = ''
      LOOP
         READNEXT SOO.ID ELSE SOO.ID = ''
      WHILE SOO.ID DO
         LIVE.FL = 'Y'
         READ SOO.REC FROM F.SEC.OPEN.ORDER, SOO.ID THEN GOSUB UPDATE.RECORDS
      REPEAT
*
      EXECUTE ' SELECT ':F.SEC.OPEN.NAU:' WITH RECORD.STATUS NE "IHLD" '
      SOO.REC = '' ; REC.UPD = ''
      LOOP
         READNEXT SOO.ID ELSE SOO.ID = ''
      WHILE SOO.ID DO
         LIVE.FL = 'N'
         READ SOO.REC FROM F.SEC.OPEN.ORDER$NAU, SOO.ID THEN GOSUB UPDATE.RECORDS
      REPEAT
*
      RETURN
*
UPDATE.RECORDS:
*--------------
* CI_10003518      CUST.NO = SOO.REC<SC.SOO.CUST.NUMBER>
      CUST.NO = SOO.REC<9>               ; * CI_10003518
      NO.CUST = DCOUNT(CUST.NO,VM)
      FOR XI = 1 TO NO.CUST
* CI_10003518         SETTL.CCY = SOO.REC<SC.SOO.SETTLEMENT.CCY><1,XI>
         SETTL.CCY = SOO.REC<15><1,XI>   ; * CI_10003518
* CI_10003518         TRAD.CCY = SOO.REC<SC.SOO.TRADE.CCY><1,XI>
         TRAD.CCY = SOO.REC<8><1,XI>     ; * CI_10003518
         YCUST = CUST.NO<1,XI>
         IF SETTL.CCY NE '' THEN
            YCCY = SETTL.CCY
         END ELSE YCCY = TRAD.CCY
* CI_10003518         YAPPLN = 'SC-':SOO.REC<SC.SOO.TRANSACTION.CODE>
         YAPPLN = 'SC-':SOO.REC<7>       ; * CI_10003518
* CI_10003518         YPORTFOLIO = FIELD(SOO.REC<SC.SOO.SECURITY.ACCNT,XI>,'-',2)
         YPORTFOLIO = FIELD(SOO.REC<10,XI>,'-',2)  ; * CI_10003518
         ACC.NUMBER = ''
         CALL GET.SETTLEMENT.DEFAULTS(YCUST,YCCY,'1',YAPPLN,YPORTFOLIO,'P',ACC.NUMBER,'','','')
         IF ACC.NUMBER THEN
* CI_10003518            SOO.REC<SC.SOO.CUST.ACC.NO,XI> = ACC.NUMBER
            SOO.REC<13,XI> = ACC.NUMBER  ; * CI_10003518
            ACC.CCY = ''
            CALL DBR("ACCOUNT":FM:AC.CURRENCY,ACC.NUMBER,ACC.CCY)
* CI_10003518     SOO.REC<SC.SOO.SETTLEMENT.CCY,XI> = ACC.CCY
            SOO.REC<15,XI> = ACC.CCY     ; * CI_10003518
            SOO.REC<SC.SOO.INPUTTER,-1> = TNO:'_G11.CONVERSION.DETAILS'
            REC.UPD = 'Y'
         END ELSE
* CI_10003518     SOO.REC<SC.SOO.CUST.ACC.NO,XI> = ''
            SOO.REC<13,XI> = ''          ; * CI_10003518
            REC.UPD = ''
         END
      NEXT XI
      IF LIVE.FL EQ 'Y' THEN
         IF REC.UPD THEN
            CALL F.WRITE(FN.SEC.OPEN,SOO.ID,SOO.REC)
            REC.UPD = ''
         END
      END ELSE
         IF REC.UPD THEN
            CALL F.WRITE(F.SEC.OPEN.NAU,SOO.ID,SOO.REC)
            REC.UPD = ''
         END
      END
      CALL JOURNAL.UPDATE(SOO.ID)
*
      RETURN
*
   END
