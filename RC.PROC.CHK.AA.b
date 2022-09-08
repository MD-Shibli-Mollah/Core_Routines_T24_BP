* @ValidationCode : MjotMTk0MzEyMDQ4NTpDcDEyNTI6MTYwNDI5NzAzMDk3NDpmaXlhZnJhbmNpczo4OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE5LTA0NTk6NjI6NjI=
* @ValidationInfo : Timestamp         : 02 Nov 2020 11:33:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : fiyafrancis
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 62/62 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Settlement
SUBROUTINE RC.PROC.CHK.AA(RC.DETAIL.ID, RC.DETAIL.HANDOFF.IN, RC.DETAIL.HANDOFF.OUT, RETURN.STATUS)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
** This which should return the outstanding bill amount for the passed bill reference.
** This routine will be called from RC module as pre and post routine to get the outstanding amount for the passed bill reference.
**
**
** INCOMING.ARGUMENTS:
*
** RcDetailId     -  List of RC.DETAILS ids for a settlement account
** RcDetailHandoffIn -  RC DETAIL record
*
*** OUTGOING.ARGUMENTS:
*
** RcDetailHandoffOut - Will returns Outstanding bill amount.
** ReturnStatus     - If bill details record not found pass INVALID status
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History :
*
* 7/04/14 - Defect:934429 / Task : 947681
*            New routine introduced to check the existence of bill during
*            settlement process of RC.DETAIL record
*
* 04/07/19  - Task : 3208564
*             Enhancement : 3126449
*             Return the outstanding bill amount for the PAY type Bills
*
* 25/06/19 - Enhancement : 3198095
*            Task        : 3198098
*            Return the Bill Aging status to RC Detail HandOff Record if the Bill has undergone the overdue status
*
* 23/10/20 - Enhancement : 4039999
*            Task        : 4040002
*            When Prioirty Rank Type is set to Bill type, the Rank Info will be updated with the bill type.
*** </region>
*------------------------------------------------------------------------------------------------------------
    
    $USING AA.PaymentSchedule
    $USING AA.Settlement
    $USING RC.Interface



    GOSUB INITIALISE          ;* Initialise

    GOSUB GET.OS.AMT          ;* Get bill outstanding amount

    GOSUB RETURN.DATA         ;*  Return either os amt or status

RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>

INITIALISE:

    BILL.REFERENCE = FIELD(RC.DETAIL.ID, '*', 6)
    ARRANGEMENT.ID  =  RC.DETAIL.HANDOFF.IN<RC.Interface.TransContId>         ;* Get arrangement reference
    RC.DETAIL.HANDOFF.OUT = RC.DETAIL.HANDOFF.IN

    RETURN.STATUS = ''
    AGING.STATUS  = ''  ;* Aging status of bill
    PAYMENT.INDICATOR = RC.DETAIL.HANDOFF.IN<RC.Interface.TransTxnSign> ;* Payment Indicator - Either "DEBIT" or "CREDIT"

RETURN

*** </region>
*-----------------------------------------------------------------------------------------------------------
*** <region name= Get os amount>
*** <desc> Get the outstanding bill amount</desc>

GET.OS.AMT:

    IF PAYMENT.INDICATOR EQ 'DEBIT' THEN
        
        AA.Settlement.GetOutstandingBillAmount(ARRANGEMENT.ID, BILL.REFERENCE, BILL.DETAILS, TOT.OS.AMT, RET.ERROR)
        BILL.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1>
        AGING.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAgingStatus,1>  ;* Get the bill's Aging Status
    END ELSE
    
        AA.Settlement.BuildRcHandoffDetails('RECORD',PO.PROPERTIES, RC.DETAIL.HANDOFF.IN, BILL.REFERENCES) ;* Get the Bill references and payout properties.
        TOT.OS.AMT = 0

        BILL.ID.COUNT = DCOUNT(BILL.REFERENCES ,@VM)
        
        FOR CNT = 1 TO BILL.ID.COUNT
            AA.Settlement.GetOutstandingBillAmount(ARRANGEMENT.ID, BILL.REFERENCES<1,CNT> , BILL.DETAILS, '', RET.ERROR) ;* Get the Bill Details
            BILL.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1>
            IF BILL.STATUS NE 'SETTLED' THEN
                BILL.NOT.SETTLED = 1
            END
        
            PAYOUT.PROPERTIES = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
            PO.PROP.COUNT = DCOUNT(PO.PROPERTIES<1,CNT> ,@SM)
            FOR PROP.CNT = 1 TO PO.PROP.COUNT
                LOCATE PO.PROPERTIES<1,CNT,PROP.CNT> IN PAYOUT.PROPERTIES<1,1> SETTING POS THEN   ;* Locate payout properties in Bill property
                    TOT.OS.AMT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount, POS> + TOT.OS.AMT  ;* Outstanding amount
                END
            NEXT PROP.CNT
        NEXT CNT
    
*** When two or more bills passed, then if the bill status is not "SETTLED" for atleast one bill and outstanding amount is fetched
*** Then Bill status and Error is made NULL.

        IF BILL.NOT.SETTLED AND TOT.OS.AMT THEN
            BILL.STATUS = ''
            RET.ERROR = ''
        END
    END

RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= Form return data>
*** <desc> Pass either os amt / status message</desc>

RETURN.DATA:

    BEGIN CASE

        CASE RET.ERROR
            RETURN.STATUS = 'RC-BILL.REC.NOT.FOUND'
            RETURN.STATUS = "-1#":RETURN.STATUS         ;* RC would reject this bill reference

        CASE NOT(TOT.OS.AMT) AND BILL.STATUS EQ 'SETTLED'

            RC.DETAIL.HANDOFF.OUT<RC.Interface.TransTransAmt> = 0
            RETURN.STATUS = 'RC-BILL.SETTLED.ALREADY'
            RETURN.STATUS = "1#":RETURN.STATUS        ;* RC would mark this bill as completed

        CASE TOT.OS.AMT
            RC.DETAIL.HANDOFF.OUT<RC.Interface.TransTransAmt> = TOT.OS.AMT          ;* Pass the amount to RC for retry process
            RC.Interface.RcGetContractRankDetails(RC.DETAIL.ID, "", "", RankSetup, ErrorDetails, ReservedOut)
            BILL.TYPE = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillType,1>
            IF RankSetup EQ "BILL.TYPE" THEN
                RC.DETAIL.HANDOFF.OUT<RC.Interface.RcTransRankInfo> = BILL.TYPE
            END ELSE
                IF AGING.STATUS AND AGING.STATUS NE "SETTLED" THEN
                    RC.DETAIL.HANDOFF.OUT<RC.Interface.RcTransRankInfo> = AGING.STATUS  ;* Pass the aging status to RC for retry process when the bill has undergone Aging and it is not settled
                END ELSE
                    RC.DETAIL.HANDOFF.OUT<RC.Interface.RcTransRankInfo> = BILL.STATUS   ;* By default,the bill status is passed to TransRankInfo if there is no aging status for the bill
                END
            END
    END CASE


RETURN

*** </region>
*-----------------------------------------------------------------------------

END
