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

*********************************************************************
*-----------------------------------------------------------------------------
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvCashAndFundFlow
      SUBROUTINE CONV.SC.CASH.FLOW.TRANS(SAM.ID,OLD.CCY,NEW.CCY)
*********************************************************************
* This routine is called from EOD.SC.CONV.REF.CCY used to convert
* the data file SC.CASH.FLOW.TRANS. When ever the reference currency of a
* Portfolio is changed from any of the euro in currencies to EUR, this
* program will convert all previous data to EUR.
***********************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.CASH.FLOW.TRANS
$INSERT I_F.SPF
      GOSUB INITIALISE
      IF R.SC.CASH.FLOW.TRANS.CONCAT THEN
         GOSUB PROCESS.SC.CASH.FLOW.TRANS
      END
      RETURN
*************
INITIALISE:
*************
      FN.SC.CASH.FLOW.TRANS = 'F.SC.CASH.FLOW.TRANS'
      FV.SC.CASH.FLOW.TRANS = ''
      CALL OPF(FN.SC.CASH.FLOW.TRANS,FV.SC.CASH.FLOW.TRANS)
      FN.SC.CASH.FLOW.TRANS.CONCAT = 'F.SC.CASH.FLOW.TRANS.CONCAT'
      FV.SC.CASH.FLOW.TRANS.CONCAT = ''
      CALL OPF(FN.SC.CASH.FLOW.TRANS.CONCAT,FV.SC.CASH.FLOW.TRANS.CONCAT)
      R.SC.CASH.FLOW.TRANS.CONCAT = ''
      ERR.CONCAT = ''
      CALL F.READ(FN.SC.CASH.FLOW.TRANS.CONCAT,
         SAM.ID,
         R.SC.CASH.FLOW.TRANS.CONCAT,
         FV.SC.CASH.FLOW.TRANS.CONCAT,
         ERR.CONCAT)
      SC.CASH.FLOW.TRANS.ID = ''
      CAC.SIZE = ''
      CALL DBR("SPF":FM:SPF.CACHE.SIZE,'SYSTEM',CAC.SIZE)
      CAC.SIZE = CAC.SIZE-10
      REC.NO = 0
      RETURN
****************************
PROCESS.SC.CASH.FLOW.TRANS:
****************************
      FOR COUNTER1 = 1 TO COUNT(R.SC.CASH.FLOW.TRANS.CONCAT,FM)+1
         SC.CASH.FLOW.TRANS.ID = R.SC.CASH.FLOW.TRANS.CONCAT<COUNTER1>
         R.SC.CASH.FLOW.TRANS = ''
         ERR.TRANS = ''
         CALL F.READ(FN.SC.CASH.FLOW.TRANS,
            SC.CASH.FLOW.TRANS.ID,
            R.SC.CASH.FLOW.TRANS,
            FV.SC.CASH.FLOW.TRANS,
            ERR.TRANS)
         IF R.SC.CASH.FLOW.TRANS THEN
            NO.TRANS.REF = COUNT(R.SC.CASH.FLOW.TRANS<SC.CFT.TRANS.REF>,VM)+1
            FOR COUNTER2 = 1 TO NO.TRANS.REF
               OLD.REF.AMT = R.SC.CASH.FLOW.TRANS<SC.CFT.REF.CCY.AMT,COUNTER2>
               NEW.REF.AMT = ''
               EX.RATE = ''
               GOSUB INV.EXCHRATE
               R.SC.CASH.FLOW.TRANS<SC.CFT.REF.CCY.AMT,COUNTER2> = NEW.REF.AMT
            NEXT COUNTER2
            GOSUB WRITE.SC.CASH.FLOW.TRANS
         END
      NEXT COUNTER1
      CALL JOURNAL.UPDATE("SC.CASH.FLOW.TRANS")
      RETURN
*******************
INV.EXCHRATE:
*******************
      ERR.CODE = ''
      CALL EXCHRATE("1",
         OLD.CCY,
         OLD.REF.AMT,
         NEW.CCY,
         NEW.REF.AMT,
         "",
         EX.RATE,
         "",
         "",
         ERR.CODE)
      RETURN
*****************************
WRITE.SC.CASH.FLOW.TRANS:
*****************************
      CALL F.WRITE(FN.SC.CASH.FLOW.TRANS,
         SC.CASH.FLOW.TRANS.ID,
         R.SC.CASH.FLOW.TRANS)
      REC.NO += 1
      IF REC.NO > CAC.SIZE THEN
         CALL JOURNAL.UPDATE("SC.CASH.FLOW.TRANS")
         REC.NO = 0
      END
      RETURN
   END
