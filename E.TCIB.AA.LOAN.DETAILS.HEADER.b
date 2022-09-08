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
*-----------------------------------------------------------------------------
* <Rating>-99</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE E.TCIB.AA.LOAN.DETAILS.HEADER
*--------------------------------------------------------------------------------------------------------------
* Description : 
* This Enquiry(Conversion) routine is to provide a loan related details (Interest Rate , Approved Amount , Next PAyment Date ,Next Payment Amount and Amount Paid)
*--------------------------------------------------------------------------------------------------------------
*             M O D I F I C A T I O N S
*
* 22/12/09  -  GLOBUS_BG_100026325
*
*              Got compilation warning message when compiled in 200912 TAFJ, as there was
*              missing quotes in FMT operation, Hence added quotes to fix this.
*              Refer TTS0911268
* 19/09/14 - Defect : 1113481 / Task : 1118326
*            Interest rate displyed directly from EFFECTIVE.DATE in AA.ARR.INTEREST table.
* 04/03/15 - Defecet 997517 / Task 1262800
*            Next payment date, Next Payment Amount and Interest rate is wrongly showing the Payment schedules for Loans.
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 13/01/16 -   Defect 1606311 / Task 1628941
*              TCIB-Performance tuning
*
* 21/04/16 - Defect 1698882 / Task 1705744
*            To find next payment amount alone from Payment Schedule Projector to avoid performance issue
*
*-----------------------------------------------------------------------------

    $USING AA.Account
    $USING AA.ModelBank
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Interest
    $USING AA.TermAmount
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Utility
    $USING EB.Template
*

    GOSUB INITIALISE
    GOSUB GET.BAL.AMOUNT.AND.INTEREST.RATE
    GOSUB GET.OUTSTANDING.AMT
    GOSUB GET.AMOUNT.PAIDOUT
*
    FINAL.ARR = INT.RATE:'*':APPROVED.AMT:'*':AMT.OUTSTAND:'*':NEXT.PAY.AMT:'*':NEXT.PAY.DATE:'*':AMT.PAID
    EB.Reports.setOData(FINAL.ARR)
    RETURN
*-------------------------------------------------------
INITIALISE:
*Initialise required variables

    SAVE.O.DATA=EB.Reports.getOData()        ;* Save O.DATA values
    ACCOUNT.ID=FIELD(SAVE.O.DATA,'*',1) ;* Get Account Id from O.DATA
    ARRANGEMENT.ID=FIELD(SAVE.O.DATA,'*',2)       ;* Get Arrangement Id from O.DATA
    ARR.IDS=FIELD(SAVE.O.DATA,'*',2)    ;* Reassigning Arrangement Id from O.DATA
    RET.ARR=''      ;* Initialise Record Error
    REQUEST.DATE='' ;* Initialise Request Date
    BALANCE.AMOUNT=''         ;* Initialise Balance Amount
    ECB.ERROR=''    ;* Initialise ECB error
    BILL.STATUS = 'SETTLED'   ;* Initialise Bill Status
    AMT.PAID = ''   ;* Initialise paid Amount
    ARR.ID = ARR.IDS:'//AUTH' ;*Take the authorised arrangement of the active channel
    PROPERTY.CLASS = 'INTEREST'         ;* Initialise INTEREST property class
    PROPERTY.RECORD=''        ;* Initialise property record
    NO.RESET=''     ;* Initialise NO.RESET
    NEXT.PAY.AMT='' ;* Initialise Next Payment Amount
*
    RETURN
*-------------------------------------------------------
GET.BAL.AMOUNT.AND.INTEREST.RATE:
* Process Balance Amount and Interest Rate
    DISP.TYPE = "TOTCOMMITMENT"         ;* Initialise Balance Type
    AA.Framework.GetEcbBalanceAmount(ACCOUNT.ID,DISP.TYPE,REQUEST.DATE,BALANCE.AMOUNT,ECB.ERROR)      ;* Get the Balance amount for the particular Balance type
    APPROVED.AMT=BALANCE.AMOUNT         ;* Get Approved Amount
    AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,PROPERTY.RECORD,RET.ERR)      ;* Get arrangement condition for Interest Property class
    PROPERTY.RECORD = RAISE(PROPERTY.RECORD)      ;* Get arrangement record
    INT.RATE=PROPERTY.RECORD<AA.Interest.Interest.IntEffectiveRate,1>       ;* Get Interest Rate
    INT.RATE = FMT(INT.RATE,'7R4')
*
    RETURN
*--------------------------------------------------------
GET.OUTSTANDING.AMT:

* Process outstanding amount
    BALANCE.TYPE = 'CURACCOUNT'         ;* Initialise Balance Type
    AA.Framework.GetEcbBalanceAmount(ACCOUNT.ID,BALANCE.TYPE,REQUEST.DATE,BALANCE.AMOUNT,ECB.ERROR)   ;* Get the Balance amount for the particular Balance type
    AMT.OUTSTAND = BALANCE.AMOUNT       ;* Get Outstanding amount
*Get Next Payment Amount/Next Payment Date
    CURRENT.SEL.CRITERIA=EB.Reports.getEnqSelection()   ;*Storing old enq selection values
    EB.Reports.setEnqSelection('')   ;*Clearing new enq selection values
    EB.Reports.setOData(ARR.IDS);*Passing arrangement id to enquiry selection
    AA.ModelBank.EAaGetArrNextPayment()      ;*Calling routine for getting next payment date.
    EB.Reports.setEnqSelection(CURRENT.SEL.CRITERIA)   ;*setting old enq selection values
    NEXT.PAY.DATE = EB.Reports.getOData()    ;*Get the Next payment date from the above routine
    NEXT.PAYMENT.DATE = NEXT.PAY.DATE
    FROM.DATE=EB.SystemTables.getToday() ;* Get today date
* To find next payment amount alone from Payment Schedule Projector by passing date range value from TODAY to NEXT.PAYMENT.DATE
    DATE.RANGE = FROM.DATE:@FM:NEXT.PAYMENT.DATE
    NO.RESET<2>=1
    AA.PaymentSchedule.ScheduleProjector(ARR.IDS,SIMULATION.REF,NO.RESET,DATE.RANGE,TOT.PAYMENT,DUE.DATES,"",DUE.TYPES,DUE.METHODS,DUE.TYPE.AMTS,DUE.PROPS,DUE.PROP.AMTS,DUE.OUTS)     ;* Get Next payment Amount from sehedule projector
    CHANGE @VM TO @FM IN TOT.PAYMENT
    LOCATE NEXT.PAYMENT.DATE IN DUE.DATES SETTING POS THEN  ;*Locating the position of next payment date
    NEXT.PAY.AMT = TOT.PAYMENT<POS> ;* Get the next payment amt based on the next payment date.
    END
*
    RETURN
*------------------------------------------------------------
GET.AMOUNT.PAIDOUT:
*Get the Bill Id which has SETTLED

    AA.PaymentSchedule.GetBill(ARR.IDS,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)
    CHANGE @VM TO @FM IN BILL.REFERENCES
    LOOP
        REMOVE BILL.ID.SEL FROM BILL.REFERENCES SETTING BILL.SEL.POS
    WHILE BILL.ID.SEL:BILL.SEL.POS
        BILL.REFERENCE = BILL.ID.SEL    ;* Get Bill Reference
        AA.PaymentSchedule.GetBillDetails(ARR.IDS,BILL.REFERENCE,BILL.DETAILS,RET.ERROR) ;* Get Bill Details
        IF BILL.DETAILS THEN
            AMT.REC.PAID = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>
            IF AMT.PAID EQ '' THEN
                AMT.PAID = AMT.REC.PAID
            END ELSE
                AMT.PAID = AMT.REC.PAID+AMT.PAID  ;* Get Paid Amount
            END
        END
    REPEAT
*
    RETURN
*------------------------------------------------------------------
    END
