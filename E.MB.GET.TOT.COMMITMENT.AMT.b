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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
* A new routine has been introduced to Show the commitment amount in Overview screen.
* This new routine is called from an existing enquiry (DEPOSITS.DETAILS.SCV)
* Input  - O.DATA Arrangement Id
* Output - O.DATA Amount
*--------------------------------------------------------------------------------
    $PACKAGE AD.ModelBank
    SUBROUTINE E.MB.GET.TOT.COMMITMENT.AMT

    $USING AA.TermAmount
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INIT
    GOSUB PROCESS
    RETURN
*-------------------------------------------------------------
INIT:
*--------------------------------------------------------------

    ARR.ID = '' ; TO.DATE = '';RET.ID = ''; RET.COND = ''; RET.ERR = ''
    ARR.ID = EB.Reports.getOData()
    TO.DATE= EB.SystemTables.getToday()
    RETURN

*-------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------

    AA.Framework.GetArrangementConditions(ARR.ID,"TERM.AMOUNT","",TO.DATE,RET.ID,RET.COND,RET.ERR)
    RET.COND = RAISE(RET.COND)
    EB.Reports.setOData(RET.COND<AA.TermAmount.TermAmount.AmtAmount>)
    RETURN
    END
