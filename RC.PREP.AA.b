* @ValidationCode : Mjo1MjA3OTM3ODpDcDEyNTI6MTYxNDI0NjIyMTI1ODpmaXlhZnJhbmNpczoxMzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkxOS0wNDU5OjEyMToxMjE=
* @ValidationInfo : Timestamp         : 25 Feb 2021 15:13:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : fiyafrancis
* @ValidationInfo : Nb tests success  : 13
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 121/121 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-78</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Settlement
SUBROUTINE RC.PREP.AA(RC.DETAIL.ID, RC.DETAIL.HANDOFF.IN, RC.DETAIL.HANDOFF.OUT, RETURN.STATUS)

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
* 10/07/13 - Task : 662714
*            Enhancement : 663005
*            This Routine will return the Outstanding bill amount if bill reference is passed.
*
* 31/12/13 - Enhancement - 694232 / Task - 709291
*            Hard coded RETURN.STATUS values are made as overrides
*
* 23/05/14 - Task : 1009784
*            Defect : 1000863
*            RC transaction needs to be rejected when bill is CANCELLED.
*
* 12/04/19  - Defect : 3057598
*             Task   : 3083997
*             RC credited the loan excess amount when payment schedule bill generated on holiday.
*
* 04/07/19  - Task : 3208564
*             Enhancement : 3126449
*             Return the outstanding bill amount for the PAY type Bills
*
* 25/06/19 - Enhancement : 3198084
*            Task        : 3198087
*            Return the Bill Aging status to RC Detail HandOff Record if the Bill has undergone the overdue status
*
* 28/07/20 - Enhancement : 3812824
*            Task        : 3871262
*            Return RC status for COMBINE.BILL settlement through RC
*
* 23/10/20 - Enhancement : 4039999
*            Task        : 4040002
*            When Prioirty Rank Type is set to Bill type, the Rank Info will be updated with the bill type.
*
* 12/02/20 - Task   : 4110593
*            Defect  : 4068679
*            Initialize common variables.
*
* 25/02/20 - Task   : 4250344
*            Defect  : 4240831
*            Get retry date from incoming RC.DETAIL.HANDOFF.IN
*** </region>
*------------------------------------------------------------------------------------------------------------

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING RC.TransactionCycler
    $USING RC.Interface
    $USING AA.Settlement
 
    GOSUB INITIALISE          ;* Initialise
    GOSUB GET.ARRANGEMENT.RECORD
    IF RETRY.DATE THEN
        GOSUB GET.OS.AMT          ;* Get bill outstanding amount
    END
RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>

INITIALISE:

    AA.Framework.ActivityInitialise()         ;* Initialise all common variables here

    BILL.REFERENCE = FIELD(RC.DETAIL.ID, '*', 6)
    ARRANGEMENT.ID  =  RC.DETAIL.HANDOFF.IN<RC.Interface.TransContId>         ;* Get arrangement reference
    RC.DETAIL.HANDOFF.OUT = RC.DETAIL.HANDOFF.IN

    RETURN.STATUS = ''

    RETRY.DATE = ''
    AGING.STATUS = ''   ;* Aging status of bill

    RETRY.DATE = RC.DETAIL.HANDOFF.IN<31>  ;*get Next Retry Date from Rc Record
    PAYMENT.INDICATOR = RC.DETAIL.HANDOFF.IN<RC.Interface.TransTxnSign> ;* Payment Indicator - Either "DEBIT" or "CREDIT"

RETURN

*** </region>
*-----------------------------------------------------------------------------------------------------------
*** <region name= Get os amount>
*** <desc> Get the outstanding bill amount</desc>

GET.OS.AMT:
    
    ARRANGEMENT.INFO<1> = ARRANGEMENT.ID
    ARRANGEMENT.INFO<2> = RETRY.DATE
        
    IF PAYMENT.INDICATOR EQ 'DEBIT' THEN
        
        AA.Settlement.GetOutstandingBillAmount(ARRANGEMENT.INFO, BILL.REFERENCE, BILL.DETAILS, TOT.OS.AMT, RET.ERROR)
        BILL.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1>
        LAST.STATUS.DATE = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStChgDt,1>
        AGING.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAgingStatus,1>      ;* Get the bill's Aging Status
        
        GOSUB RETURN.DATA         ;*  Return either os amt or status
        
    END ELSE
    
        AA.Settlement.BuildRcHandoffDetails('RECORD',PO.PROPERTIES, RC.DETAIL.HANDOFF.IN, BILL.REFERENCES) ;* Get the Bill references and payout properties.
    
        TOT.OS.AMT = 0

        BILL.ID.COUNT = DCOUNT(BILL.REFERENCES ,@VM)
        
        FOR CNT = 1 TO BILL.ID.COUNT
            AA.Settlement.GetOutstandingBillAmount(ARRANGEMENT.ID, BILL.REFERENCES<1,CNT> , BILL.DETAILS, '', RET.ERROR) ;* Get the Bill Details
            BILL.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1>
            LAST.STATUS.DATE = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStChgDt,1>
            PAYOUT.PROPERTIES = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
            
            PO.PROP.COUNT = DCOUNT(PO.PROPERTIES<1,CNT> ,@SM)
            
            FOR PROP.CNT = 1 TO PO.PROP.COUNT
                LOCATE PO.PROPERTIES<1,CNT,PROP.CNT> IN PAYOUT.PROPERTIES<1,1> SETTING POS THEN ;* Locate payout properties in Bill property
                    BEGIN CASE
                        
                        CASE BILL.STATUS EQ 'SETTLED'
                            
                        CASE BILL.STATUS EQ 'CANCELLED'
                            
                        CASE BILL.STATUS EQ 'WRITEOFF'
                        
                        CASE 1
                            TOT.OS.AMT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount, POS> + TOT.OS.AMT   ;* Outstanding amount
                        
                    END CASE
                END
            NEXT PROP.CNT
        
            GOSUB RETURN.DATA         ;*  Return either os amt or status
        
        NEXT CNT
    
        IF TOT.OS.AMT THEN   ;* If Outstanding amount is present, then return status must be NULL
            RETURN.STATUS = ''
        END

    END
    
RETURN

*** </region>
*-----------------------------------------------------------------------------------------------------------
*** <region name= Get arrangement record>
*** <desc> Get arrangement record.</desc>

GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = ""
    F.AA.ARRANGEMENT = ""
    ERR.MSG = ""
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.MSG)
    ARR.STATUS = R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>

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
        CASE BILL.STATUS EQ 'WRITEOFF'

            RETURN.STATUS = "-1#Bill is already writeoff"       ;* RC would reject this bill reference

* Need to reject rc for all cancelled bills when the arrangement status moved to pending closure &  closure.
* If the status is cancelled and retry date is less then the cancelled date then we allowed to retry.
* The above case happen during logn holiday.
        CASE (BILL.STATUS EQ 'CANCELLED' AND ARR.STATUS MATCHES "PENDING.CLOSURE":@VM:"CLOSE") OR (BILL.STATUS EQ 'CANCELLED' AND RETRY.DATE GE LAST.STATUS.DATE)

            RETURN.STATUS = "-1#Bill is already cancelled"      ;* RC would reject this bill reference
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
            
        CASE NOT(TOT.OS.AMT) AND BILL.STATUS EQ 'ISSUED' AND BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdLinkedBillId>   ;* In case of COMBINE BILL and only for facility
            GOSUB GET.LINKED.BILLS.STATUS   ;* get statuses of linked bills
            BEGIN CASE
                CASE LINKED.BILL.STATUS EQ NO.OF.BILLS
                    RC.DETAIL.HANDOFF.OUT<RC.Interface.TransTransAmt> = 0
                    RETURN.STATUS = 'RC-BILL.SETTLED.ALREADY'
                    RETURN.STATUS = "1#":RETURN.STATUS        ;* RC would mark this bill as completed
           
                CASE WRITEOFF.BILL.STATUS EQ NO.OF.BILLS
                    RETURN.STATUS = "-1#Bill is already writeoff"       ;* RC would reject this bill reference
                       
                CASE CANCELLED.BILL.STATUS EQ NO.OF.BILLS
                    RETURN.STATUS = "-1#Bill is already cancelled"      ;* RC would reject this bill reference
                       
            END CASE
            
    END CASE


RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get the linked bill details statuses>
*** <desc>Get the linked bill details statuses</desc>
GET.LINKED.BILLS.STATUS:
** get the linked bill statuses when RC settlement is triggered for CMBINE.BILL.
** For each combine bill, find the count of SETTTLED/WRITTEN.OFF/CANCELLED drawing bills under the combine bill
** update the status according to that bill status

    BILL.REF.LIST =  BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdLinkedBillId> ;* get the bill references of the arrangement
    
    LINKED.BILL.STATUS = 0
    WRITEOFF.BILL.STATUS = 0
    CANCELLED.BILL.STATUS = 0
    NO.OF.BILLS = 0
    
    LOOP
        REMOVE LINKED.BILL.REFERENCE FROM BILL.REF.LIST SETTING BillRefPos
    WHILE LINKED.BILL.REFERENCE
        NO.OF.BILLS += 1
        GOSUB GET.BILL.DETAILS  ;* get bill details
        BEGIN CASE
            CASE LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1> EQ "SETTLED"
                LINKED.BILL.STATUS += 1
            
            CASE LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1> EQ "WRITEOFF"
                WRITEOFF.BILL.STATUS += 1
            
            CASE LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1> EQ "CANCELLED"
                CANCELLED.BILL.STATUS += 1
        END CASE
    REPEAT

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Get the bill details>
*** <desc>Get the details</desc>
GET.BILL.DETAILS:

    LINKED.BILL.DETAILS = ''
    RET.ERROR = ''
    AA.PaymentSchedule.GetBillDetails(ARRANGEMENT.ID,LINKED.BILL.REFERENCE,LINKED.BILL.DETAILS,RET.ERROR)

RETURN
*** </region>
*--------------------------------------------------------------------------
END
