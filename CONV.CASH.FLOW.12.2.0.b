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

* Version 2 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>862</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvCashAndFundFlow
      SUBROUTINE CONV.CASH.FLOW.12.2.0
*
**********************************************************************
* This program will recalculate the estimation values on the
* SC.CASH.FLOW files for all months 01-12, for LQ interface
* records only.
* The data have been corrupted by the program SC.EOM.PRICE.UPDATE
*
* Written by  : A. Kyriacou
* Date        : 28/09/93
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
**********************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
$INSERT I_F.SC.CASH.FLOW
$INSERT I_F.SUB.ASSET.TYPE
$INSERT I_F.SEC.ACC.MASTER
*
**************************************
      INTERFACE = 'LQ'
      CALL DBR('VAL.INTERFACE':FM:'1',INTERFACE,ASSET.TYPE.CODE)
      CUST.STAT.GROUP = ''
      CALL DBR('ASSET.BREAK':FM:'1',ASSET.TYPE.CODE,CUST.STAT.GROUP)
      K.ASSET.TYPE = ''
      CALL DBR('SUB.ASSET.TYPE':FM:SC.CSG.ASSET.TYPE.CODE,CUST.STAT.GROUP,K.ASSET.TYPE)
      F.SC.VAL.EXCH = ''
      CALL OPF('F.SC.VAL.EXCH.RATES',F.SC.VAL.EXCH)
*
      IF CUST.STAT.GROUP = '' THEN RETURN          ; * Premature exit
*
* Main program Loop.
*
      SAT.AST = CUST.STAT.GROUP:'.':K.ASSET.TYPE
      FOR MONTH.NO = 1 TO 12
         YMONTH = FMT(MONTH.NO,"2'0'R")
         F.SC.CASH.FLOW = ''
         CASH.FLOW.FILE = "F.SC.CASH.FLOW":YMONTH
         F.CASH.FLOW = "F.SC.CASH.FLOW":YMONTH
         CALL OPF(CASH.FLOW.FILE,F.SC.CASH.FLOW)
         SSEL = "SELECT ":CASH.FLOW.FILE:" WITH @ID LIKE '...":SAT.AST:"'"
         CALL HUSHIT(1)
         EXECUTE SSEL
         CALL HUSHIT(0)
*
         PRINT @(10,10):SPACE(60):@(10):"Converting file '":CASH.FLOW.FILE:"', Please wait.....":
*
         LOOP
            READNEXT K.CSF ELSE NULL
         WHILE K.CSF DO
            R.CSF = '' ; ER = ''
            CALL F.READU(F.CASH.FLOW,K.CSF,R.CSF,F.SC.CASH.FLOW,ER,'')
*
            GOSUB CONVERT.RECORD         ; * Convert the cash flow record
*
            CALL F.WRITE(F.CASH.FLOW,K.CSF,R.CSF)
            CALL JOURNAL.UPDATE(K.CSF)
         REPEAT
      NEXT MONTH.NO
*
      RETURN                             ; * Exit program
*
***************
CONVERT.RECORD:
***************
*
      REF.CCY = ''
      SEC.ACC.NO = FIELD(K.CSF,'.',1)
      CALL DBR('SEC.ACC.MASTER':FM:SC.SAM.REFERENCE.CURRENCY:FM:'.A',SEC.ACC.NO,REF.CCY)
      NO.SECS = COUNT(R.CSF<SC.CAF.SECURITY.NO>,@VM) + (R.CSF<SC.CAF.SECURITY.NO> NE "")
      FOR SEC = 1 TO NO.SECS
         SEC.CCY = R.CSF<SC.CAF.SECURITY.CCY,SEC>
         NOMINAL = R.CSF<SC.CAF.NO.NOMINAL,SEC>
         MARKET.PRICE = R.CSF<SC.CAF.MARKET.PRICE,SEC>
         COST.PRICE = R.CSF<SC.CAF.COST.PRICE,SEC>
         IF NOMINAL THEN
            ESTIMATION.SCY = (MARKET.PRICE - COST.PRICE) * NOMINAL
         END ELSE ESTIMATION.SCY = COST.PRICE
         CALL SC.FORMAT.CCY.AMT(SEC.CCY,ESTIMATION.SCY)
         R.CSF<SC.CAF.V.DT.ESTIMATION,SEC> = ESTIMATION.SCY
         IF ESTIMATION.SCY LT 0 THEN MARGIN.VALUE = ESTIMATION.SCY ELSE MARGIN.VALUE = 0
         R.CSF<SC.CAF.MARGIN.VALUE,SEC> = MARGIN.VALUE
         R.CSF<SC.CAF.V.DATE.MARGIN,SEC> = MARGIN.VALUE
         R.CSF<SC.CAF.ESTIMATION.SCY,SEC> = ESTIMATION.SCY
******
* CONVERT ESTIMATION AMOUNT FROM
* SECURITY CCY TO REFERENCE CCY .
******
         IF REF.CCY # SEC.CCY THEN
            ESTIMATION.RCY = ''
            RET.CODE = '' ; BASE.CCY = ''
            RATE = ''
*
* Get rate of exchange rate between the security and reference currencies.
*
            K.EXCH = YMONTH:SEC.CCY ; R.EXCH = '' ; ER = ''
            CALL F.READ("F.SC.VAL.EXCH.RATES",K.EXCH,R.EXCH,F.SC.VAL.EXCH,ER)
            IF NOT(ER) THEN
               LOCATE REF.CCY IN R.EXCH<1,1> SETTING POS ELSE POS = 0
               IF POS THEN RATE = R.EXCH<2,POS>
            END ELSE
               ER = ''
            END
*
            CALL EXCHRATE("1",SEC.CCY,ESTIMATION.SCY,REF.CCY,ESTIMATION.RCY,BASE.CCY,RATE,'','',RET.CODE)
            IF ETEXT OR RET.CODE<2> THEN
               ESTIMATION.RCY = 0
            END
            CALL SC.FORMAT.CCY.AMT(REF.CCY,ESTIMATION.RCY)
         END ELSE ESTIMATION.RCY = ESTIMATION.SCY
*
         R.CSF<SC.CAF.ESTIMATION,SEC> = ESTIMATION.RCY
         R.CSF<SC.CAF.V.DT.EST.REF,SEC> = ESTIMATION.RCY
      NEXT SEC
*
      RETURN
*
*****************
* END OF CODING.
*****************
*
   END
