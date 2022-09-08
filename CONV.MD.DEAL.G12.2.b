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

* Version n dd/mm/yy  GLOBUS Release No. G12.1.01 05/12/01
*-----------------------------------------------------------------------------
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Contract
      SUBROUTINE CONV.MD.DEAL.G12.2(MD.ID,MD.REC,MD.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*******************************************************************


      EQU MD.DEA.CB.LIMIT.UPDATE TO 104,
         MD.DEA.INV.STATUS TO 105, MD.DEA.INV.AMOUNT TO 106,
         MD.DEA.INV.DR.ACCOUNT TO 107, MD.DEA.INV.DR.VALUE.DATE TO 108,
         MD.DEA.INV.PAYMENT.METHOD TO 109, MD.DEA.INV.SETTLE.ACCOUNT TO 110,
         MD.DEA.INV.EXCH.RATE TO 111, MD.DEA.INV.PAY.VALUE.DATE TO 112,
         MD.DEA.INV.BANK.OP.CODE TO 113, MD.DEA.OUR.CORRS.BNK TO 114,
         MD.DEA.RECV.CORRS.BNK TO 115, MD.DEA.INV.INTER.BANK TO 116,
         MD.DEA.RE.AC.WITH.BNK TO 117, MD.DEA.INV.CHRG.DETLS TO 118,
         MD.DEA.INV.RECV.BNK TO 119, MD.DEA.INV.BNK.TO.BNK TO 120,
         MD.DEA.INV.BENEFICIARY TO 121, MD.DEA.LAST.INV.NO TO 122,
         MD.DEA.EVENTS.PROCESSING TO 123

      IF FILE.TYPE NE 1 THEN RETURN
*
*
      MD.REC<MD.DEA.CB.LIMIT.UPDATE> = ''
      MD.REC<MD.DEA.INV.STATUS> = ''
      MD.REC<MD.DEA.INV.AMOUNT> = ''
      MD.REC<MD.DEA.INV.DR.ACCOUNT> = ''
      MD.REC<MD.DEA.INV.DR.VALUE.DATE> = ''
      MD.REC<MD.DEA.INV.PAYMENT.METHOD> = ''
      MD.REC<MD.DEA.INV.SETTLE.ACCOUNT> = ''
      MD.REC<MD.DEA.INV.EXCH.RATE> = ''
      MD.REC<MD.DEA.INV.PAY.VALUE.DATE> = ''
      MD.REC<MD.DEA.INV.BANK.OP.CODE> = ''
      MD.REC<MD.DEA.OUR.CORRS.BNK> = ''
      MD.REC<MD.DEA.RECV.CORRS.BNK> = ''
      MD.REC<MD.DEA.INV.INTER.BANK> = ''
      MD.REC<MD.DEA.RE.AC.WITH.BNK> = ''
      MD.REC<MD.DEA.INV.CHRG.DETLS> = ''
      MD.REC<MD.DEA.INV.RECV.BNK> = ''
      MD.REC<MD.DEA.INV.BNK.TO.BNK> = ''
      MD.REC<MD.DEA.INV.BENEFICIARY> = ''
      MD.REC<MD.DEA.LAST.INV.NO> = ''
      MD.REC<MD.DEA.EVENTS.PROCESSING> = 'END OF DAY'
      RETURN
************************************************************************
   END
