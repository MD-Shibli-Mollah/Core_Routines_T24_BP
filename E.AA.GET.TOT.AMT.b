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
*-------------------------
* Description
*
* This enquiry routine will accept the Info Pay Type and return the sum of its
* corresponding INFO.PR.AMT
*
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.TOT.AMT

    $USING AA.PaymentSchedule
    $USING EB.Reports


    PAY.TYPE = EB.Reports.getOData()
    IF PAY.TYPE NE 'PAYOFF$UNC' THEN
        LOCATE PAY.TYPE IN EB.Reports.getRRecord()<AA.PaymentSchedule.BillDetails.BdInfoPayType,1> SETTING PAY.POS THEN
        PAY.AMT = EB.Reports.getRRecord()<AA.PaymentSchedule.BillDetails.BdInfoPrAmt,PAY.POS>
        PAY.AMT = SUM(PAY.AMT)
    END
    EB.Reports.setOData(PAY.AMT)
    END

*
    RETURN
