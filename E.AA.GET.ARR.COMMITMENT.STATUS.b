* @ValidationCode : MjotNDkxNzg5NzUwOkNwMTI1MjoxNTc2NTcxNzcxMTQ4Om9odml5YWo6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjI1OjI1
* @ValidationInfo : Timestamp         : 17 Dec 2019 14:06:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ohviyaj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/25 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-------------------------------------------------------------------------
* <Rating>-4</Rating>
*-------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ARR.COMMITMENT.STATUS
**************************************************************
* This routine gets the Commitment status of the Arrangement
*
**************************************************************
*MODIFICATION HISTORY
*
* 16/12/19 - Task        : 3492403
*            Enhancement : 3457794
*            New routine to get the Commitment status in Overview screen
*
****************************************************************************

    $USING AA.PaymentSchedule
    $USING EB.DatInterface
    $USING EB.Reports

****************************************************************************
    ARR.ID = EB.Reports.getOData()
    R.AC.DETAILS = ''
    PROCESS.END = ''
    RET.ERR = ''

    LOCATE "SIM.REF" IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIM.POS>
    END ELSE
        SIM.REF = ''
    END

    IF ARR.ID ELSE
        LOCATE "ARRANGEMENT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
            ARR.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
        END ELSE
            PROCESS.END = 1
        END
    END

    IF PROCESS.END ELSE

        IF SIM.REF THEN
            EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.ID, R.AC.DETAILS,"", "", RET.ERR)
        END ELSE
            AA.PaymentSchedule.ProcessAccountDetails(ARR.ID, "INITIALISE", "", R.AC.DETAILS, RET.ERR)
        END
*
    END
*
    EB.Reports.setOData(R.AC.DETAILS<AA.PaymentSchedule.AccountDetails.AdCommitmentStatus>)
*
RETURN
