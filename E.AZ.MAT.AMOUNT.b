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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
      SUBROUTINE E.AZ.MAT.AMOUNT
* This is the subroutine called from the AZ.DEP.SCH.NAU & AZ.DEPOSIT.SCHEDULES enquiry for calculating the maturity value.

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_ENQUIRY.COMMON
$INSERT I_F.AZ.SCHEDULES

* O.DATA has ACCOUNT NUMBER * MATURITY.DATE
* If called from AZ.DEP.SCH.NAU, REQ.FILE.NAME will be AZ.SCHEDULES.NAU.
* If called from AZ.DEPOSIT.SCHEDULES, REQ.FILE.NAME will be AZ.SCHEDULES.
      AC.ID = FIELD(O.DATA,'*',1)
      SCH.DATE = FIELD(O.DATA,'*',2)

      REQ.FILE.NAME = DATA.FILE.NAME
      CALL DBR(REQ.FILE.NAME:FM:AZ.SLS.DATE,AC.ID,ALL.DATES)
      LOCATE SCH.DATE IN ALL.DATES<1,1> SETTING DD.POS THEN
         CALL DBR(REQ.FILE.NAME:FM:AZ.SLS.TOT.REPAY.AMT,AC.ID,TOT.AMT)
         O.DATA = TOT.AMT<1,DD.POS>
      END
      RETURN
   END
