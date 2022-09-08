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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Contract
      SUBROUTINE CONV.MD.BALANCES.G12.1(MD.ID,MD.REC,MD.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*******************************************************************

      EQU MD.BAL.PRIN.BALANCE TO 1, MD.BAL.PRIN.PART.BAL TO 2,
         MD.BAL.PRIN.EFF.DATE TO 3, MD.BAL.CHARGE.DATE TO 4,
         MD.BAL.CHARGE.CURR TO 5, MD.BAL.CHARGE.ACCOUNT TO 6,
         MD.BAL.CHARGE.AMT TO 7, MD.BAL.CHARGE.CODE TO 8,
         MD.BAL.CHG.TAX.CODE TO 9, MD.BAL.CHRG.TAX.AMT TO 10,
         MD.BAL.TOT.CHARGE.CCY TO 11, MD.BAL.TOT.CHARGE.AMT TO 12,
         MD.BAL.TOT.CHRG.TAX TO 13, MD.BAL.CURRENCY TO 14,
         MD.BAL.START.CSN.PERIOD TO 15, MD.BAL.END.CSN.PERIOD TO 16,
         MD.BAL.COMM.BASE.AMT TO 17, MD.BAL.COMM.BASE.DATE TO 18,
         MD.BAL.COMMISSION.AMOUNT TO 19, MD.BAL.CSN.ACCRUED.TODATE TO 20,
         MD.BAL.ACCR.FROM.DATE TO 21, MD.BAL.ACCR.TO.DATE TO 22,
         MD.BAL.ACCR.DAYS TO 23, MD.BAL.ACCR.PRIN TO 24,
         MD.BAL.ACCR.RATE TO 25, MD.BAL.ACCR.AMT TO 26,
         MD.BAL.ACCR.ACT.AMT TO 27, MD.BAL.PAST.SCHED.DATE TO 28,
         MD.BAL.PAST.SCHED.AMT TO 29, MD.BAL.PAST.SCHED.TYPE TO 30,
         MD.BAL.COMM.ACCOUNT TO 31, MD.BAL.PAST.PART.COMM TO 32,
         MD.BAL.PAST.TAX.CODE TO 33, MD.BAL.PAST.TAX.AMT TO 34,
         MD.BAL.PAST.PART.TAX TO 35, MD.BAL.PAST.PROCESS.DT TO 36,
         MD.BAL.PART.COMM.AMT TO 37, MD.BAL.COMM.TAX.AMT TO 38,
         MD.BAL.PART.TAX.AMT TO 39, MD.BAL.RECALC.COMM.FLG TO 40,
         MD.BAL.NEW.CSN.RATE TO 41, MD.BAL.PART.AMT.CHG TO 42


      IF FILE.TYPE NE 1 THEN RETURN

      MD.REC<MD.BAL.PRIN.PART.BAL> = ''
      MD.REC<MD.BAL.CHARGE.ACCOUNT> = ''
      MD.REC<MD.BAL.COMM.BASE.AMT> = ''
      MD.REC<MD.BAL.COMM.BASE.DATE> = ''
      MD.REC<MD.BAL.COMM.ACCOUNT> = ''
      MD.REC<MD.BAL.PAST.PART.COMM> = ''
      MD.REC<MD.BAL.PAST.TAX.CODE> = ''
      MD.REC<MD.BAL.PAST.TAX.AMT> = ''
      MD.REC<MD.BAL.PAST.PART.TAX> = ''
      MD.REC<MD.BAL.PART.COMM.AMT> = ''
      MD.REC<MD.BAL.COMM.TAX.AMT> = ''
      MD.REC<MD.BAL.PART.TAX.AMT> = ''
      MD.REC<MD.BAL.RECALC.COMM.FLG> = ''
*
*
      RETURN
************************************************************************
   END
