* @ValidationCode : MjoxMDgyMDc3MTgwOkNwMTI1MjoxNjEyNzc4OTg2MTcxOm1hbmlydWRoOjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo4MTo4MA==
* @ValidationInfo : Timestamp         : 08 Feb 2021 15:39:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manirudh
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 80/81 (98.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Settlement
SUBROUTINE RC.POST.AA(RC.DETAIL.ID, RC.DETAIL.HANDOFF.IN, RC.DETAIL.HANDOFF.OUT, RETURN.STATUS)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
** This which should return the outstanding bill amount for the passed bill reference and status of the bill.
** This routine will be called from RC module as post routine and returns the status to RC.DETAIL.
**
**
** INCOMING.ARGUMENTS:
*
** RcDetailId     - List of RC.DETAILS ids for a settlement account
** RcDetailHandoffIn  - RC DETAIL record
*
*** OUTGOING.ARGUMENTS:
*
** RcDetailHandoffOut   - Will returns Outstanding bill amount.
** ReturnStatus     - If bill details record not found pass -1#Bill record not found status.
**                  - If bill is already settled, Pass return status as 1#Bill is already settled.
**
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
* 31/12/13 - Enhancement - 694232 / Task - 709291
*            Hard coded RETURN.STATUS values are made as overrides
*
* 29/09/16 - Task   : 1874758
*            Defect : 1840131
*            Return the status of Bills containing CURRENT payment type also.
*
* 04/07/19  - Task : 3208564
*             Enhancement : 3126449
*             Return the outstanding bill amount for the PAY type Bills
*
* 28/07/20  - Task : 3871262
*             Defect : 3867937
*             Return the outstanding bill amount and RC status for the COMBINE.BILL settlement through RC.
*
* 12/02/20 - Task   : 4110593
*            Defect  : 4068679
*            Initialize common variables.
*
*** </region>
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.Settlement
    $USING RC.Interface
 

    GOSUB INITIALISE          ;* Initialise

    GOSUB GET.OS.AMT          ;* Get bill os amount

    GOSUB RETURN.DATA          ;* Return status

RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name=INITIALISE>
*** <desc>Initialise variables, constants here</desc>
INITIALISE:

    AA.Framework.ActivityInitialise()         ;* Initialise all common variables here

    BILL.REFERENCE = FIELD(RC.DETAIL.ID, '*', 6)
    ARRANGEMENT.ID  =  RC.DETAIL.HANDOFF.IN<RC.Interface.TransContId>         ;* Get arrangement reference
    RC.DETAIL.HANDOFF.OUT = RC.DETAIL.HANDOFF.IN
    RETURN.STATUS = ''
    PAYMENT.INDICATOR = RC.DETAIL.HANDOFF.IN<RC.Interface.TransTxnSign> ;* Payment Indicator - Either "DEBIT" or "CREDIT"

RETURN
*** </region>

*------------------------------------------------------------------------------------------------------------
*** <region name= Process>
*** <desc> Get the outstanding bill amount</desc>

GET.OS.AMT:

    IF PAYMENT.INDICATOR EQ 'DEBIT' THEN
        
        AA.Settlement.GetOutstandingBillAmount(ARRANGEMENT.ID, BILL.REFERENCE , BILL.DETAILS, TOT.OS.AMT, RET.ERROR)
        
* Calculate Total original amount by summing up each of the Property original amount.
* So that the Billed amount for CURRENT payment type is considered.

        TOT.OR.AMT = SUM(BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount>) ;* Sum of the properties original amount
        BILL.STATUS = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1>
        
        GOSUB GET.COMBINE.BILL.STATUS
       
    END ELSE
    
        AA.Settlement.BuildRcHandoffDetails('RECORD',PO.PROPERTIES, RC.DETAIL.HANDOFF.IN, BILL.REFERENCES) ;* Get the Bill references and payout properties.
    
        TOT.OS.AMT = 0
        TOT.OR.AMT = 0
        BILL.NOT.SETTLED = 0
         
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
                LOCATE PO.PROPERTIES<1,CNT,PROP.CNT> IN PAYOUT.PROPERTIES<1,1> SETTING POS THEN ;* Locate payout properties in Bill property
                    TOT.OS.AMT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount, POS> + TOT.OS.AMT  ;* Outstanding amount
                    TOT.OR.AMT = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount, POS> + TOT.OR.AMT  ;* Original amount
                END
            NEXT PROP.CNT
        NEXT CNT
    
*** When two or more bills passed, if the bill status is not "SETTLED" for atleast one bill
*** Then the Bill status is made NULL.

        IF BILL.NOT.SETTLED THEN
            BILL.STATUS = ''
        END
    
    END

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= Get Combine Bill Status>
*** <desc>Get Combine Bill Status</desc>
GET.COMBINE.BILL.STATUS:
** When RC setttlement is triggered for Combined bill in facility level, the status of the RC sould be updated depending on the bill status.
** As even after settlement, combine bill status doesnt change to SETTLED, we are looping through all the drawing bills to check if they are settled or not
** and setting the status depending on that.If not, RC status will be updated as PENDING and it will retried at a frequency set up in RC.CONDITION
** and will not move the status to SETTLED though they are fully settled.
    
    IF BILL.STATUS EQ 'ISSUED' AND BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdLinkedBillId> THEN
        BILL.REF.LIST = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdLinkedBillId> ;* get the drawing bill details
        COMBINE.BILL.STATUS = 1
        TOT.OS.AMT = 0
        TOT.OR.AMT = 0
            
        LOOP
            REMOVE LINKED.BILL.ID FROM BILL.REF.LIST SETTING billpos
        WHILE LINKED.BILL.ID
            GOSUB GET.BILL.DETAILS  ;* get drawing bill details
            IF LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,1> NE 'SETTLED' THEN ;* donot set the flag if status is not settled
                COMBINE.BILL.STATUS = 0
            END
            TOT.OS.AMT += SUM(LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount>)  ;* Outstanding amount
            TOT.OR.AMT += SUM(LINKED.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount>)   ;* Original amount
        REPEAT
        
        IF COMBINE.BILL.STATUS THEN ;* set BILL.STATUS to SETTLED when falg is set, to change RC STATUS to settled.
            BILL.STATUS = 'SETTLED'
        END
    END
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Get the bill details>
*** <desc>Get the details</desc>
GET.BILL.DETAILS:

    LINKED.BILL.DETAILS = ''
    RET.ERROR = ''
    AA.PaymentSchedule.GetBillDetails(ARRANGEMENT.ID,LINKED.BILL.ID,LINKED.BILL.DETAILS,RET.ERROR)

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Update RC status>
*** <desc> Update the status to RC.DETAIL record</desc>

RETURN.DATA:

    BEGIN CASE

        CASE TOT.OS.AMT AND TOT.OS.AMT EQ TOT.OR.AMT
            RETURN.STATUS = 'RC-TXN.NOT.SETTLED'
            RETURN.STATUS = '#':RETURN.STATUS
            RC.DETAIL.HANDOFF.OUT<RC.Interface.TransSettleStatus> = 'PENDING'

        CASE TOT.OS.AMT AND TOT.OS.AMT LT TOT.OR.AMT
            RETURN.STATUS = 'RC-TXN.SETTLED.PARIALLY'
            RETURN.STATUS = '#':RETURN.STATUS
            RC.DETAIL.HANDOFF.OUT<RC.Interface.TransSettleStatus> = 'PARTIAL'

        CASE NOT(TOT.OS.AMT) AND BILL.STATUS EQ 'SETTLED'
            RETURN.STATUS = 'RC-TXN.FULL.SETTLED'
            RETURN.STATUS = '#':RETURN.STATUS
            RC.DETAIL.HANDOFF.OUT<RC.Interface.TransSettleStatus> = 'SETTLED'

    END CASE

RETURN

*** </region>
*------------------------------------------------------------------------------------------------------------

END
