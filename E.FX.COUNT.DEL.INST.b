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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.FX.COUNT.DEL.INST
*
*          ENQUIRY ROUTINE USED BY FX.OPTION.LAST.DEL.REPORT
* Populates the information of the last delivery instruction for multirate option contracts,
* and where the system has forcefully introduced the last delivery instruction
*
* *************************************
*
* 21/03/07 - EN_10003186
*            New routine
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*
***************************************
    $USING FX.Contract
    $USING EB.Reports
    $USING FX.ModelBank
*
    DEL.INS = EB.Reports.getOData()
    RETURN.DATA = ''

    TOT.CNT = DCOUNT(DEL.INS,@VM)

    RETURN.DATA := TOT.CNT :"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelDateBuy,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelAmountBuy,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelDateSell,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelAmountSell,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelLcyAmt,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.DelRate,TOT.CNT>:"*"
    RETURN.DATA := EB.Reports.getRRecord()<FX.Contract.Forex.Status,TOT.CNT>


    EB.Reports.setOData(RETURN.DATA)

    RETURN
    END
