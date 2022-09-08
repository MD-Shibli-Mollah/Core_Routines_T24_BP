* @ValidationCode : MjotMTM1OTI5NTAwMDpDcDEyNTI6MTU3NjU5MTQ1OTQxMDpzaGFzaGlkaGFycmVkZHlzOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzoyMjoyMg==
* @ValidationInfo : Timestamp         : 17 Dec 2019 19:34:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/22 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.ModelBank
SUBROUTINE E.CREDIT.LOCK.AMT
*-----------------------------------------------------------------------------
* A new routine (E.CREDIT.LOCK.AMT) has been introduced to Show the cumulative of the cr locked
* amount if he has an multiple locked amount.
*
*******************************************************************************
*           MODIFICATION HISTORY
*******************************************************************************
*
* 16/12/2019 - Defect : 3413198
*              Task   : 3413199
*              New routine to return the credit locked amount for an account.


    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.CashFlow

    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------

INIT:
    ACC.NO = "" ;  AMT.CHK = "" ; ALL.DATE = "" ; R.ACC = "" ;
RETURN

PROCESS:

    ACC.NO = EB.Reports.getOData()
    LOCKED.DETAILS = ''
    RESPONSE.DETAILS = ''
    AC.CashFlow.GetLockedDetails(ACC.NO, LOCKED.DETAILS,RESPONSE.DETAILS)
    VAL = ""
    AMT.CHK = LOCKED.DETAILS<4>
    ALL.DATE = LOCKED.DETAILS<3>
    
    LOCATE EB.SystemTables.getToday() IN ALL.DATE<1,1> BY "AR" SETTING POS THEN
        VAL = AMT.CHK<1,POS>
    END ELSE
        IF NOT(POS EQ 1) THEN
            POS = POS-1
            VAL = AMT.CHK<1,POS>
        END
    END
    EB.Reports.setOData(VAL)
RETURN
*-----------------------------------------------------------------------------
END

