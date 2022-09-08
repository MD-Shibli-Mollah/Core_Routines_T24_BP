* @ValidationCode : MjotMTc4NTg2NzY3MDpDcDEyNTI6MTU2NDU2OTc2ODcyNTpzcmF2aWt1bWFyOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDoyNzoyNQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/27 (92.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.Cards
SUBROUTINE CARD.BILL.CLOSE.REPAY.DATES.SELECT
*------------------------------------------------------
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*01/08/15 -  Enhancement 1265068
*         -  Task 1387479
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*-----------------------------------------------------
*
    $USING EB.Service
    $USING EB.DataAccess
    $USING CQ.Cards
    $INSERT I_DAS.CARD.BILL.CLOSE.DATE
    $INSERT I_DAS.CARD.REPAYMENT.DATE

* Main Para *
*-----------*

    END.OF.DAY.LIST = ''

* Processing of CARD.BILL.CLOSE.DATE

    THE.ARGS = ''
    THE.LIST = dasCardBillCloseDate$Date
    THE.ARGS<1> = "8N"
    EB.DataAccess.Das("CARD.BILL.CLOSE.DATE", THE.LIST , THE.ARGS, "")
    END.OF.DAY.LIST = THE.LIST

    IF END.OF.DAY.LIST THEN
        END.OF.DAY.LIST = SPLICE(END.OF.DAY.LIST,'*BILL.CLOSE','')
    END

* Processing of CARD.REPAYMENT.DATE

    THE.ARGS = ''
    THE.LIST = dasCardRepaymentDate$Date
    THE.ARGS<1> = "8N"
    EB.DataAccess.Das("CARD.REPAYMENT.DATE", THE.LIST , THE.ARGS, "")

    IF THE.LIST THEN
        THE.LIST = SPLICE(THE.LIST,'*REPAY.DATE','')

        IF END.OF.DAY.LIST THEN
            END.OF.DAY.LIST<-1> = THE.LIST
        END ELSE
            END.OF.DAY.LIST = THE.LIST
        END
    END


    IF END.OF.DAY.LIST THEN
        EB.Service.BatchBuildList("",END.OF.DAY.LIST)
    END

RETURN

END
