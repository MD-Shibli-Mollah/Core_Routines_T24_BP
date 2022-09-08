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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.ARR.AGEING.STATUS
**********************************
* This routine gets the settlement status of the Arrangement
* It will get the status of the Oldest Bill that is not settled
*
**********************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
**********************************

    $USING AA.PaymentSchedule
    $USING EB.DatInterface
    $USING EB.Reports

**********************************
    ARR.ID = EB.Reports.getOData()
    R.AC.DETAILS = ''
    PROCESS.END = ''
    RET.ERR = ''
*
    LOCATE "SIM.REF" IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
    SIM.REF = EB.Reports.getEnqSelection()<4,SIM.POS>
    END ELSE
    SIM.REF = ''
    END
*
    IF ARR.ID ELSE
        LOCATE "ARRANGEMENT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
    END ELSE
        PROCESS.END = 1
    END
    END
*
    IF PROCESS.END ELSE
        IF SIM.REF THEN
            EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.ID, R.AC.DETAILS, "", "", RET.ERR)
        END ELSE
            AA.PaymentSchedule.ProcessAccountDetails(ARR.ID, "INITIALISE", "", R.AC.DETAILS, RET.ERR)
        END
        *
    END
*
    EB.Reports.setOData(R.AC.DETAILS<AA.PaymentSchedule.AccountDetails.AdArrAgeStatus>)
*
    RETURN
*************************************
