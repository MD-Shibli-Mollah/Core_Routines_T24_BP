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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Reports
      SUBROUTINE CONV.SUB.REPORTS.DET(IN.FILES, IN.IDS, RET.IDS, RET.FILE)
$INSERT I_COMMON
$INSERT I_EQUATE
      FN.AM.SUB.REPORT = 'F.AM.SUB.REPORT'
      FV.AM.SUB.REPORT = ''
      CALL OPF(FN.AM.SUB.REPORT, FV.AM.SUB.REPORT)
      SEL.COM = 'SELECT ':FN.AM.SUB.REPORT
      RET.IDS = ''
      ERR1 = ''
      NO.SEL = ''
      CALL EB.READLIST(SEL.COM, RET.IDS, '',
         NO.SEL, ERR1)
      RET.FILE = 'AM.SUB.REPORT'
      RETURN
   END
