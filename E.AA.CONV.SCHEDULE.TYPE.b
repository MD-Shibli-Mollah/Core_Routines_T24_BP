* @ValidationCode : MjotMTg0MTUzNDU5MjpDcDEyNTI6MTYwOTI0NTMxOTMzMjptamViYXJhajo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTExLTEyMTA6MjM6MjM=
* @ValidationInfo : Timestamp         : 29 Dec 2020 18:05:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/23 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.SCHEDULE.TYPE
*------------------------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** This Enquiry(Conversion) routine is to return the payment schedule type such as paid, due and future
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : AA.PaymentSchedule.GetBill
* @access       : private
* @stereotype   : subroutine
* @author       : gayathrik@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 11/12/20 - Enhancement : 3930802
*            Task        : 3930805
*            Conversion routine to get the schedule type as paid or scheduled for future
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.API
    $USING EB.DatInterface
    $USING EB.Foundation
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>

    SAVE.O.DATA=EB.Reports.getOData()        ;* Save O.DATA values
    ARRANGEMENT = FIELD(SAVE.O.DATA,'-',1) ;* Get Arrangement Id from O.DATA
    AUTH.ARR.ID = ARRANGEMENT:'//AUTH'
    PAYMENT.DATE=FIELD(SAVE.O.DATA,'-',2)       ;* Get Payment date from O.DATA
    TODAY.DATE = EB.SystemTables.getToday() ;* The user is viewing the enquiry. It is relevant to show the current product as of today
    BILL.REFERENCES = '' ; BILL.STATUS = "AGING":@VM:"DUE":@VM:"DEFER";
    IF PAYMENT.DATE LE TODAY.DATE THEN
        AA.PaymentSchedule.GetBill(AUTH.ARR.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)
        IF BILL.REFERENCES THEN
            SCHD.TYPE = "DUE"
        END ELSE
            SCHD.TYPE = "PAID"
        END
    END ELSE
        BILL.STATUS = 'SETTLED'
        AA.PaymentSchedule.GetBill(AUTH.ARR.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)	;* Call routine to fetch bill details which is settled
        IF BILL.REFERENCES THEN
            SCHD.TYPE = "PAID"		;* Set type to PAID if bill is settled
        END ELSE
            SCHD.TYPE = "FUTURE"	;* Set type to FUTURE if bill is not settled
        END
    END
    EB.Reports.setOData(SCHD.TYPE)

*** </region>
*-----------------------------------------------------------------------------
END
