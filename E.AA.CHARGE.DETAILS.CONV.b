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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.CHARGE.DETAILS.CONV
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 17/03/14 - Task : 944932
*            Defect : 938848
*            Bill Adjustment Narrative, Simulation Details, Adjustment Details were not shown in the charge details Overview Screen.
*
*-----------------------------------------------------------------------------
    $USING EB.Reports

    Q.DATA = EB.Reports.getOData()
    CHANGE "#" TO @VM IN Q.DATA
    EB.Reports.setVmCount(DCOUNT(Q.DATA,@VM))
    EB.Reports.setOData(Q.DATA<1,EB.Reports.getVc()>)

    RETURN
*-----------------------------------------------------------------------------
    END
