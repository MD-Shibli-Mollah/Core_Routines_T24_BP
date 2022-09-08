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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AL.ModelBank
    SUBROUTINE E.AA.GET.ARR.TERM.AMT
************************************
*
* This is a conversion routine for get TERM.AMOUNT property AMOUNT value
* an arrangement Id.
* 
************************************
*MODIFICATION HISTORY
*
* 01/01/16 - Task   : 1586878
*            Defect : 1580505
*            Change Product- Amount Missing 
*
************************************
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.TermAmount

************************************

    ARR.ID = EB.Reports.getOData()
    EFF.DATE = EB.SystemTables.getToday()          ;*For live arrangement, get the TERM.AMOUNT property Amount
    PROPERTY.ID = ''
    RETURN.ID = ''
    returnCondition = ''
    RET.ERR = ''

    AA.Framework.GetArrangementConditions(ARR.ID, "TERM.AMOUNT", "", EFF.DATE, RETURN.ID, returnCondition, RET.ERR)        ;* Get the arrangement current dated TERM.AMOUNT property record
    ARR.TERM.AMT.REC = RAISE(returnCondition)
    CURRENT.AMOUNT = ARR.TERM.AMT.REC<AA.TermAmount.TermAmount.AmtAmount>
    EB.Reports.setOData(CURRENT.AMOUNT)
*
    RETURN
END 
