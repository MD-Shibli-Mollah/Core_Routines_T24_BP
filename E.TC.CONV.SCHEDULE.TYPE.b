* @ValidationCode : MjotMTA3OTI4MDI5NTpDcDEyNTI6MTU3MzIxNTQ1OTcxODpnYW5nYW46NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjIzOjIz
* @ValidationInfo : Timestamp         : 08 Nov 2019 17:47:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gangan
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/23 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------
$PACKAGE AA.Channels
SUBROUTINE E.TC.CONV.SCHEDULE.TYPE
*--------------------------------------------------------------------------------------------------------------
* Description :
* -----------
* This Enquiry(Conversion) routine is to return the payment schedule type such as paid, due and future
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : field SCHEDULE.TYPE in the Enquiry > TC.NOF.AA.PAYMENT.SCHEDULE
* IN Parameters      : Arrangement id along with payment date
* Out Parameters     : Schedule type
*-----------------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 13/07/16 - Enhancement 1657937 / Task 1797520
*            TCIB Componentization - Loan improvements
*
* 30/10/18 - Enhancement 2816316 / Task 2816327
*            Paid and future schedule changes based on the repay amount
*
* 08/11/19 - Defect 3422323 / Task 3425985
*            AA Payment schedule enquiry displays schedule type as PAID for due bills.
*-----------------------------------------------------------------------------
*** <region name= Inserts>

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
