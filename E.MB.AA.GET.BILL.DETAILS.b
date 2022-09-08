* @ValidationCode : MjoxNTI3NTQ1Njg5OkNwMTI1MjoxNjE2NzY4OTI3MTgxOm1hcmNoYW5hOjE1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzA1LTA2MzY6NTk3OjQ0NQ==
* @ValidationInfo : Timestamp         : 26 Mar 2021 19:58:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 15
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 445/597 (74.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210305-0636
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>483</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.AA.GET.BILL.DETAILS(BILL.DETAILS)

*** <region name= Synopsis of the Routine>
***
** NOFILE enquiry routine to return the bill details for the arrangement.
** This routine returns the details in the same layout as AA.BILL.DETAILS
** Additionally the routine also returns some calculated values, appended from position 201
*
** When requested for sim, if the record is not there in the sim, SIM.READ will get it from
** live, so no need for any special processing
*
* Mandatory Input : Arrangement ID
* Return Parameter : Bill details in the same layout as AA.BILL.DETAILS
*
*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @author ramkeshav@temenos.com
*-----------------------------------------------------------------------------
*
* TODO -
*
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
***
**
* 13/11/14 Task 1131074
*          Ref : Defect 1105150
*          New enquiry routine to return Bill Details record
**
* 28/02/16 - 1640269
*            Ref: EN_1631634
*            If sim only option is passed then get bills only from simulation.
*
* 20/12/16 - Task 1961977
*            Defect 1941926
*            Wrong calculation on redeem on maturity date
*
* 03/03/17 - Defect 2034077
*            Task  2038748
*            System should not consider adjustment amount when the bills are resumed from suspension.
*
* 15/03/17 - Defect 2040084
*            Task  2056137
*            Waived bills are displayed in bills enqiury.
*
* 28/09/17 - Defect 2282268
*            Task  2288808
*            Results output in the enquiry window is displaying wrong value.
*
* 13/08/18 - Defect 2708396
*            Task  2717430
*            Settled on- field within bills tab not populating the date
*
* 01/08/18 - Defect 2683527
*            Task  2709089
*            Remaining value in the enquiry window displaying wrong value due to tax addition twice
*
* 25/10/18 - Defect 2819899
*            Task  2828097
*            Consider DelinOsAmt amount only when there is balance in that field.
*
* 08/02/19 - Task   : 2982681
*            Enhan  : 2947685
*            Stop returning bills which have Bill type with Sys Bill type as 'EXTERNAL'
*
* 07/03/19 - Task   : 3020742
*            Enhan  : 2947685
*            Display External Bills only for Consolidated Bills enquiry
*
* 16/08/19 - Task   : 3289543
*            Defect  : 3288475
*            Adjustment Amount/Repayment Amount should be added for ABB properties.
*
* 19/03/2020 - Enhancement  :  3634982
*              Task :  3634985
*              Changes are to differentiate TAX property from SKIM property
*
* 18/05/20 - Task   : 3753421
*            Defect  : 3751358
*            When holiday payment amount is input using update payment holiday activity based on the amount
*            Bill is adjusted and Adjustment ref as PaymentHolidayActivityID-HOLIDAY-Activitydate hence this
*            Adjustment ref should be ignored to display the Billed column properly.
*
* 11/08/20 - Enhancement: 3904088
*            Task       : 3904091
*            Process Participant bill details
*
* 03/16/21  Enh  : 4263098
*           Task : 4263098
*           Changes made to display the accrued tax amount for the AccrueByBill Property.
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
**

    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING AA.ProductFramework
    $USING AA.Tax
    $USING AA.PaymentRules
    $USING AF.Framework
    $USING AA.Framework
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------

*
*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise local variables

    GOSUB GET.BILL.IDS        ;* Get all Bill Ids from AA.ACCOUNT.DETAILS for the arrangement contract

    GOSUB PROCESS.BILL.DETAILS          ;* For each of the Bill Id, get the details from AA.BILL.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Initialise local variables>
***
INITIALISE:

    ARR.ID = "" ;* Arrangement Id, mandatory information
    SIM.REF = "" ;* Simulation reference, if the details are to be picked from a simulation
    PAYMENT.DATE = "" ;* Due date of the bill
    PAYMENT.DATE.SELECTION = "" ;* Due date condition type, like, equals, greater, less, etc
    DEFER.DATE = "" ;* Defered date of the bill
    DEFER.DATE.SELECTION = ""
    OR.TOTAL.AMOUNT = "" ;* Original total bill amount
    OR.TOTAL.AMOUNT.SELECTION  = ""
    DELIN.OS.AMT = "" ;* Delinquent OS amount
    DELIN.OS.AMT.SELECTION = ""
    OS.TOTAL.AMOUNT = "" ; * Current total bill amount
    OS.TOTAL.AMOUNT.SELECTION = ""
    PROPERTY = "" ; * Property linked to the bill
    PROPERTY.SELECTION = ""
    BILL.STATUS = "" ; * Bill status like Issued, Due, Aging
    BILL.STATUS.SELECTION = ""
    SETTLE.STATUS = "" ; * Settlement status for the bill, unsettled/settled
    SETTLE.STATUS.SELECTION = ""
    AGING.STATUS = "" ;* Aging status for the bill, specific overdue status
    AGING.STATUS.SELECTION = ""
    PAYMENT.TYPE = "" ;* Payment type linked to the bill
    PAYMENT.TYPE.SELECTION = ""
    BILL.DATE = ""
    BILL.DATE.SELECTION = "" ;* Date on which bill is created
    BILL.TYPE = ""
    BILL.TYPE.SELECTION = ""
    PAYMENT.METHOD = "" ;* Payment method of the bill, DUE, PAY, CAPITALISE
    PAYMENT.METHOD.SELECTION = ""
    INFO.PAY.TYPE = ""
    INFO.PAY.TYPE.SELECTION = ""
    ADVANCE.PAYMENT = "" ;* Flag to indicate if the bill is issued for advance payment
    ADVANCE.PAYMENT.SELECTION = ""
    PAYMENT.INDICATOR = ""
    PAYMENT.INDICATOR.SELECTION = ""
    SETTLED = ""    ;* To indicate if the Bill is settled either from delinquency point of view or outstanding
    SETTLED.SELECTION = ""
    SETTLED.DATE = ""    ;* Enquiry field to indicate Bill settlement date
    SETTLED.DATE.SELECTION = ""
    HISTORY = ""    ;* Enquiry field to indicate if the Bill is from history or live
    HISTORY.SELECTION = ""
    PARTICIPANT.ID = ''     ;* Enquiry field to indicate if Participant bill need to be processed
    
    LOCATE 'ARR.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Arrangement Id
    END

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Simulation Reference
    END

    LOCATE 'PAYMENT.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING PAYMENT.DATE.POS THEN
        PAYMENT.DATE = EB.Reports.getEnqSelection()<4,PAYMENT.DATE.POS>
        PAYMENT.DATE.SELECTION = EB.Reports.getEnqSelection()<3,PAYMENT.DATE.POS>
    END

    LOCATE 'DEFER.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING DEFER.DATE.POS THEN
        DEFER.DATE = EB.Reports.getEnqSelection()<4,DEFER.DATE.POS>
        DEFER.DATE.SELECTION = EB.Reports.getEnqSelection()<3,DEFER.DATE.POS>
    END

    LOCATE 'OR.TOTAL.AMOUNT' IN EB.Reports.getEnqSelection()<2,1> SETTING OR.AMT.POS THEN
        OR.TOTAL.AMOUNT = EB.Reports.getEnqSelection()<4,OR.AMT.POS>
        OR.TOTAL.AMOUNT.SELECTION = EB.Reports.getEnqSelection()<3,OR.AMT.POS>
    END

    LOCATE 'DELIN.OS.AMT' IN EB.Reports.getEnqSelection()<2,1> SETTING DELIN.POS THEN
        DELIN.OS.AMT = EB.Reports.getEnqSelection()<4,DELIN.POS>
        DELIN.OS.AMT.SELECTION = EB.Reports.getEnqSelection()<3,DELIN.POS>
    END

    LOCATE 'OS.TOTAL.AMOUNT' IN EB.Reports.getEnqSelection()<2,1> SETTING OS.AMT.POS THEN
        OS.TOTAL.AMOUNT = EB.Reports.getEnqSelection()<4,OS.AMT.POS>
        OS.TOTAL.AMOUNT.SELECTION = EB.Reports.getEnqSelection()<3,OS.AMT.POS>
    END

    LOCATE 'PROPERTY' IN EB.Reports.getEnqSelection()<2,1> SETTING PROPERTY.POS THEN
        PROPERTY = EB.Reports.getEnqSelection()<4,PROPERTY.POS>
        PROPERTY.SELECTION = EB.Reports.getEnqSelection()<3,PROPERTY.POS>
    END

    LOCATE 'BILL.STATUS' IN EB.Reports.getEnqSelection()<2,1> SETTING BILL.STATUS.POS THEN
        BILL.STATUS = EB.Reports.getEnqSelection()<4,BILL.STATUS.POS>
        BILL.STATUS.SELECTION = EB.Reports.getEnqSelection()<3,BILL.STATUS.POS>
    END ELSE
        BILL.STATUS = "CANCELLED"
        BILL.STATUS.SELECTION = "NE"
    END

    LOCATE 'SETTLE.STATUS' IN EB.Reports.getEnqSelection()<2,1> SETTING SETTLE.STATUS.POS THEN
        SETTLE.STATUS = EB.Reports.getEnqSelection()<4,SETTLE.STATUS.POS>
        SETTLE.STATUS.SELECTION = EB.Reports.getEnqSelection()<3,SETTLE.STATUS.POS>
    END

    LOCATE 'AGING.STATUS' IN EB.Reports.getEnqSelection()<2,1> SETTING AGING.STATUS.POS THEN
        AGING.STATUS = EB.Reports.getEnqSelection()<4,AGING.STATUS.POS>
        AGING.STATUS.SELECTION = EB.Reports.getEnqSelection()<3,AGING.STATUS.POS>
    END

    LOCATE 'PAYMENT.TYPE' IN EB.Reports.getEnqSelection()<2,1> SETTING PAYMENT.TYPE.POS THEN
        PAYMENT.TYPE = EB.Reports.getEnqSelection()<4,PAYMENT.TYPE.POS>
        PAYMENT.TYPE.SELECTION = EB.Reports.getEnqSelection()<3,PAYMENT.TYPE.POS>
    END

    LOCATE 'BILL.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING BILL.DATE.POS THEN
        BILL.DATE = EB.Reports.getEnqSelection()<4,BILL.DATE.POS>
        BILL.DATE.SELECTION = EB.Reports.getEnqSelection()<3,BILL.DATE.POS>
    END

    LOCATE 'BILL.TYPE' IN EB.Reports.getEnqSelection()<2,1> SETTING BILL.TYPE.POS THEN
        BILL.TYPE = EB.Reports.getEnqSelection()<4,BILL.TYPE.POS>
        BILL.TYPE.SELECTION = EB.Reports.getEnqSelection()<3,BILL.TYPE.POS>
    END

    LOCATE 'PAYMENT.METHOD' IN EB.Reports.getEnqSelection()<2,1> SETTING PAYMENT.METHOD.POS THEN
        PAYMENT.METHOD = EB.Reports.getEnqSelection()<4,PAYMENT.METHOD.POS>
        PAYMENT.METHOD.SELECTION = EB.Reports.getEnqSelection()<3,PAYMENT.METHOD.POS>
    END

    LOCATE 'INFO.PAY.TYPE' IN EB.Reports.getEnqSelection()<2,1> SETTING INFO.PAY.TYPE.POS THEN
        INFO.PAY.TYPE = EB.Reports.getEnqSelection()<4,INFO.PAY.TYPE.POS>
        INFO.PAY.TYPE.SELECTION = EB.Reports.getEnqSelection()<3,INFO.PAY.TYPE.POS>
    END

    LOCATE 'ADVANCE.PAYMENT' IN EB.Reports.getEnqSelection()<2,1> SETTING ADVANCE.PAYMENT.POS THEN
        ADVANCE.PAYMENT = EB.Reports.getEnqSelection()<4,ADVANCE.PAYMENT.POS>
        ADVANCE.PAYMENT.SELECTION = EB.Reports.getEnqSelection()<3,ADVANCE.PAYMENT.POS>
    END

    LOCATE 'PAYMENT.INDICATOR' IN EB.Reports.getEnqSelection()<2,1> SETTING PAYMENT.INDICATOR.POS THEN
        PAYMENT.INDICATOR = EB.Reports.getEnqSelection()<4,PAYMENT.INDICATOR.POS>
        PAYMENT.INDICATOR.SELECTION = EB.Reports.getEnqSelection()<3,PAYMENT.INDICATOR.POS>
    END

    LOCATE 'SETTLED' IN EB.Reports.getEnqSelection()<2,1> SETTING SETTLED.POS THEN
        SETTLED = EB.Reports.getEnqSelection()<4,SETTLED.POS>    ;* Enquiry field to indicate if the Bill is settled either from delinquency point of view or outstanding
        SETTLED.SELECTION = EB.Reports.getEnqSelection()<3,SETTLED.POS>
    END

    LOCATE 'SETTLED.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING SETTLED.DATE.POS THEN
        SETTLED.DATE = EB.Reports.getEnqSelection()<4,SETTLED.DATE.POS>    ;* Enquiry field to indicate Bill settlement date
        SETTLED.DATE.SELECTION = EB.Reports.getEnqSelection()<3,SETTLED.DATE.POS>
    END

    LOCATE 'HISTORY' IN EB.Reports.getEnqSelection()<2,1> SETTING HISTORY.POS THEN
        HISTORY = EB.Reports.getEnqSelection()<4,HISTORY.POS>    ;* Enquiry field to indicate if the Bill is from history or live
        HISTORY.SELECTION = EB.Reports.getEnqSelection()<3,HISTORY.POS>
    END

    SIM.ONLY = ""
    LOCATE 'SIM.ONLY' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.ONLY.POS THEN
        SIM.ONLY = EB.Reports.getEnqSelection()<4,SIM.ONLY.POS>          ;* Arrangement Id
    END

    LOCATE 'WAIVE.PR.AMT' IN EB.Reports.getEnqSelection()<2,1> SETTING WAIVE.POS THEN
        WAIVE.AMOUNT =  EB.Reports.getEnqSelection()<4,WAIVE.POS>    ;* Enquiry field to indicate if the Bill is waived or not
        WAIVE.AMOUNT.SELECTION = EB.Reports.getEnqSelection()<3,WAIVE.POS>
    END
    
    LOCATE 'PARTICIPANT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING PARTICIPANT.POS THEN
        PARTICIPANT.ID = EB.Reports.getEnqSelection()<4, PARTICIPANT.POS>   ;* Enquiry field to indicate if Participant bill need to be processed
    END
    
    FIX.SEL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>    ;* Get the Fixed selection for the enquiry
    NO.SEL = DCOUNT(FIX.SEL, @VM)   ;* Count the number of fixed selections defined for the enquiry
    INCLUDE.EXTERNAL = ''
    
    FOR CNT.LOOP = 1 TO NO.SEL  ;* Loop the fixed selection
        SEL.COND = FIX.SEL<1,CNT.LOOP>
        
        IF SEL.COND[' ',1,1] EQ 'INCLUDE.EXTERNAL.FEES' THEN    ;* Check if the INCLUDE.EXTERNAL.FEES field exists in fixed selection
            INCLUDE.EXTERNAL = SEL.COND[' ',3,1]    ;* Read the selection value whether external bill can be included or excluded
        END
        
        IF SEL.COND[' ',1,1] EQ 'HISTORY' AND SEL.COND[' ',2,1] EQ 'EQ' THEN      ;* Check if the HISTORY field exists in fixed selection
            HISTORY = SEL.COND[' ',3,1]             ;* Read the selection value to check if HISTORY bills to be fetched
        END
        
        IF SEL.COND[' ',1,1] EQ 'HISTORY' AND SEL.COND[' ',2,1] EQ 'NE' AND SEL.COND[' ',3,1] EQ 'YES' THEN
            HISTORY = ''
        END
        
    NEXT CNT.LOOP
    
    F.AA.ACCOUNT.DETAILS = ""

    F.AA.ACCOUNT.DETAILS.HIST = ""

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS, F.AA.BILL.DETAILS)

    FN.AA.BILL.DETAILS.HIST = "F.AA.BILL.DETAILS.HIST"
    F.AA.BILL.DETAILS.HIST = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS.HIST, F.AA.BILL.DETAILS.HIST)

    BILL.DETAILS = ""         ;* Entire Bill details record for the arrangement
    PAYMENT.DATES = ""        ;* To sort by PaymentDate

    SELECTION.TYPE = ""       ;* Filter Type - either Single, Multi, SingleMulti
    SELECTION.FIELD = ""      ;* Field Name of the actual selection field
    SELECTION.VALUE = ""      ;* Value to be searched for
    SELECTION.CONDITION = ""  ;* Selections, GT, LT, GE, LE, NE, EQ

    EQU AA.BD.TR.PROPERTY TO 200
    EQU AA.BD.TOT.RPY.AMT TO 201
    EQU AA.BD.TOT.ADJ.AMT TO 202
    EQU AA.BD.TOT.WOF.AMT TO 203

    EQU AA.BD.SETTLED TO 204
    EQU AA.BD.SETTLED.DATE TO 205
    EQU AA.BD.HISTORY TO 206
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Ids>
***
GET.BILL.IDS:
*
** Ensure we read the live/sim record of AA.ACCOUNT.DETAILS which has the BillIds
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.ID, R.AA.ACCOUNT.DETAILS, SIM.ONLY, "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(ARR.ID, "")
    END
    
*
** Ensure we read Hist record as well, for both live/sim
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS.HIST", ARR.ID, R.AA.ACCOUNT.DETAILS.HIST, SIM.ONLY, "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS.HIST = AA.PaymentSchedule.AccountDetailsHist.Read(ARR.ID, "")
    END

    IF HISTORY EQ 'YES' THEN
        BILL.IDS.HIST = ""
        IF R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId,1> THEN      ;* There are some bill records that are archived
            BILL.IDS.HIST = RAISE(RAISE(R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId>))  ;* Raise it to FM marker
        END
    END ELSE
        BILL.IDS.LIVE = ""
        IF R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId,1> THEN ;* There are some bill records in live
            BILL.IDS.LIVE = RAISE(RAISE(R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId>))
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Process Bill Details>
***
PROCESS.BILL.DETAILS:

** Process both archived and live Bills

    HISTORY = ""    ;* Flag to indicate if bill is to be read from .HIST or from LIVE
    BILL.IDS = BILL.IDS.LIVE
    GOSUB PARSE.BILL.DETAILS

    HISTORY = 1
    BILL.IDS = BILL.IDS.HIST
    GOSUB PARSE.BILL.DETAILS

RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name= Parse Bill Details>
***
PARSE.BILL.DETAILS:
    
    LOOP
        REMOVE BILL.ID FROM BILL.IDS SETTING BILL.POS
    WHILE BILL.ID:BILL.POS
    
        GOSUB GET.BILL.RECORD ;* Read Bill record from simulation details/live - either archived or live
        
        GOSUB CHECK.SYSTEM.BILL.TYPE    ;* Read the Bill Type's System Bill Type
        
        IF NOT(EXTERNAL.BILL) OR INCLUDE.EXTERNAL EQ 'YES' THEN     ;* Stop Processing bills with EXTERNAL type System Bill Type, But display External bills only for Consolidated enquiry

            GOSUB FILTER.BILL.RECORD        ;* Apply selection filters

            IF INCLUDE.BILL.ID THEN
                GOSUB UPDATE.CALCULATED.VALUES        ;* Update calculations, such as repayments, adjustments, write-off total

                GOSUB UPDATE.BILL.RECORD    ;* Update the Bill record to be returned to the enquiry
            END
        
        END

    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Record>
***
GET.BILL.RECORD:

    IF HISTORY THEN ;* Archived Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS.HIST
        F.BILL.DETAILS = F.AA.BILL.DETAILS.HIST
    END ELSE        ;* Live Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS
        F.BILL.DETAILS = F.AA.BILL.DETAILS
    END

    R.AA.BILL.DETAILS = ""
    IF PARTICIPANT.ID THEN  ;* If Participant ID is defined then fetch Participant bill
        BILL.ID = BILL.ID:"-":PARTICIPANT.ID
    END
    
    IF SIM.REF THEN ;* Get Bill details from simulation, if not, SIM.READ will get it from live
        EB.DatInterface.SimRead(SIM.REF, FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, SIM.ONLY, "", "")
    END ELSE        ;* Only live record is required
        EB.DataAccess.FRead(FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, F.BILL.DETAILS, "")
    END
    INCLUDE.BILL.ID = 0
    IF R.AA.BILL.DETAILS NE "" THEN
        INCLUDE.BILL.ID = 1       ;* Always include this Bill Id, filters will be applied bit later
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Filter Bill Record>
***
FILTER.BILL.RECORD:

** PaymentDate
    IF PAYMENT.DATE AND PAYMENT.DATE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdPaymentDate
        SELECTION.CONDITION = PAYMENT.DATE.SELECTION
        SELECTION.VALUE = PAYMENT.DATE
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Defer Date

    IF DEFER.DATE AND DEFER.DATE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdDeferDate
        SELECTION.CONDITION = DEFER.DATE.SELECTION
        SELECTION.VALUE = DEFER.DATE
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Original Total Amount

    IF OR.TOTAL.AMOUNT NE "" AND OR.TOTAL.AMOUNT.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdOrTotalAmount
        SELECTION.CONDITION = OR.TOTAL.AMOUNT.SELECTION
        SELECTION.VALUE = OR.TOTAL.AMOUNT
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Delinquency Amount

    IF DELIN.OS.AMT NE "" AND DELIN.OS.AMT.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdDelinOsAmt
        SELECTION.CONDITION = DELIN.OS.AMT.SELECTION
        SELECTION.VALUE = DELIN.OS.AMT
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Outstanding Total Amount

    IF OS.TOTAL.AMOUNT NE "" AND OS.TOTAL.AMOUNT.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdOsTotalAmount
        SELECTION.CONDITION = OS.TOTAL.AMOUNT.SELECTION
        SELECTION.VALUE = OS.TOTAL.AMOUNT
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Property

    IF PROPERTY AND PROPERTY.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdProperty
        SELECTION.CONDITION = PROPERTY.SELECTION
        SELECTION.VALUE = PROPERTY
        SELECTION.TYPE = "MULTI"
        GOSUB PROCESS.SELECTION
    END

** Bill Status

    IF BILL.STATUS AND BILL.STATUS.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdBillStatus
        SELECTION.CONDITION = BILL.STATUS.SELECTION
        SELECTION.VALUE = BILL.STATUS
        SELECTION.TYPE = "SINGLE.MULTI"
        GOSUB PROCESS.SELECTION
    END

** Settle Status

    IF SETTLE.STATUS AND SETTLE.STATUS.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdSettleStatus
        SELECTION.CONDITION = SETTLE.STATUS.SELECTION
        SELECTION.VALUE = SETTLE.STATUS
        SELECTION.TYPE = "SINGLE.MULTI"
        GOSUB PROCESS.SELECTION
    END

** Aging Status

    IF AGING.STATUS AND AGING.STATUS.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdAgingStatus
        SELECTION.CONDITION = AGING.STATUS.SELECTION
        SELECTION.VALUE = AGING.STATUS
        SELECTION.TYPE = "SINGLE.MULTI"
        GOSUB PROCESS.SELECTION
    END

** Payment Type

    IF PAYMENT.TYPE AND PAYMENT.TYPE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdPaymentType
        SELECTION.CONDITION = PAYMENT.TYPE.SELECTION
        SELECTION.VALUE = PAYMENT.TYPE
        SELECTION.TYPE = "MULTI"
        GOSUB PROCESS.SELECTION
    END

** Bill Date

    IF BILL.DATE AND BILL.DATE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdBillDate
        SELECTION.CONDITION = BILL.DATE.SELECTION
        SELECTION.VALUE = BILL.DATE
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Bill Type

    IF BILL.TYPE AND BILL.TYPE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdBillType
        SELECTION.CONDITION = BILL.TYPE.SELECTION
        SELECTION.VALUE = BILL.TYPE
        SELECTION.TYPE = "MULTI"
        GOSUB PROCESS.SELECTION
    END

** Payment Method

    IF PAYMENT.METHOD AND PAYMENT.METHOD.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdPaymentMethod
        SELECTION.CONDITION = PAYMENT.METHOD.SELECTION
        SELECTION.VALUE = PAYMENT.METHOD
        SELECTION.TYPE = "MULTI"
        GOSUB PROCESS.SELECTION
    END

** Info Payment Type

    IF INFO.PAY.TYPE AND INFO.PAY.TYPE.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdInfoPayType
        SELECTION.CONDITION = INFO.PAY.TYPE.SELECTION
        SELECTION.VALUE = INFO.PAY.TYPE
        SELECTION.TYPE = "MULTI"
        GOSUB PROCESS.SELECTION
    END

** Advance Payment

    IF ADVANCE.PAYMENT AND ADVANCE.PAYMENT.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdAdvancePayment
        SELECTION.CONDITION = ADVANCE.PAYMENT.SELECTION
        SELECTION.VALUE = ADVANCE.PAYMENT
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END

** Payment Indicator

    IF PAYMENT.INDICATOR AND PAYMENT.INDICATOR.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdPaymentIndicator
        SELECTION.CONDITION = PAYMENT.INDICATOR.SELECTION
        SELECTION.VALUE = PAYMENT.INDICATOR
        SELECTION.TYPE = "SINGLE"
        GOSUB PROCESS.SELECTION
    END


    IF WAIVE.AMOUNT NE "" AND WAIVE.AMOUNT.SELECTION AND INCLUDE.BILL.ID THEN
        SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdWaivePrAmt
        SELECTION.CONDITION = WAIVE.AMOUNT.SELECTION
        SELECTION.VALUE = WAIVE.AMOUNT
        SELECTION.TYPE = "PROPERTY"
        GOSUB PROCESS.SELECTION  ;*to include or not include waived bills
    END

** Settled

    IF SETTLED AND SETTLED.SELECTION AND INCLUDE.BILL.ID THEN
        IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentMethod,1> = "CAPITALISE" THEN
            GOSUB CHECK.CAPITALISED.BILL.SETTLEMENT
        END ELSE
            IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdDelinOsAmt> THEN
                SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdDelinOsAmt
            END ELSE
                SELECTION.FIELD = AA.PaymentSchedule.BillDetails.BdOsTotalAmount
            END
            SELECTION.CONDITION = SETTLED.SELECTION
            SELECTION.VALUE = 0
            SELECTION.TYPE = "SINGLE"
            GOSUB PROCESS.SELECTION
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Apply filter condition>
***
PROCESS.SELECTION:

** Apply filters either on single valued, or multi-valued field. In some cases the multi-value
** first position needs to be checked, in which case it would be processed as single valued field

    BEGIN CASE

        CASE SELECTION.CONDITION = "EQ"

            BEGIN CASE
                CASE SELECTION.TYPE = "SINGLE"
                    IF SELECTION.VALUE EQ R.AA.BILL.DETAILS<SELECTION.FIELD> THEN
                        INCLUDE.BILL.ID = 1
                    END ELSE
                        INCLUDE.BILL.ID = ""
                    END

                CASE SELECTION.TYPE = "SINGLE.MULTI"
                    IF SELECTION.VALUE EQ R.AA.BILL.DETAILS<SELECTION.FIELD,1> THEN
                        INCLUDE.BILL.ID = 1
                    END ELSE
                        INCLUDE.BILL.ID = ""
                    END

                CASE SELECTION.TYPE = "MULTI"
                    LOCATE SELECTION.VALUE IN R.AA.BILL.DETAILS<SELECTION.FIELD,1> SETTING POS THEN
                        INCLUDE.BILL.ID = 1
                    END ELSE
                        INCLUDE.BILL.ID = ""
                    END

                CASE SELECTION.TYPE = "PROPERTY"
                    PAYMENT.TYPE.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType>,@VM)
                    WAIVE.COUNT = DCOUNT(R.AA.BILL.DETAILS<SELECTION.FIELD,PAY.CNT>,@SM)
                    FOR PAY.CNT = 1 TO PAYMENT.TYPE.COUNT
                        INCLUDE.BILL.ID.COUNT = ""
                        FOR WAIVE.CNT = 1 TO WAIVE.COUNT
                            BEGIN CASE
                                CASE SELECTION.VALUE EQ R.AA.BILL.DETAILS<SELECTION.FIELD,PAY.CNT,WAIVE.CNT>
                                    INCLUDE.BILL.ID = 1
                                    RETURN
                                CASE 1
                                    GOSUB FULL.OR.PARTIAL.WAIVED ; *To check if bill is waived fully or partially to include bill in enquiry
                            END CASE
                        NEXT WAIVE.CNT
                    NEXT PAY.CNT

            END CASE

        CASE SELECTION.CONDITION = "NE"

            BEGIN CASE
                CASE SELECTION.TYPE = "SINGLE"
                    IF SELECTION.VALUE NE R.AA.BILL.DETAILS<SELECTION.FIELD> THEN
                        INCLUDE.BILL.ID = 1
                    END ELSE
                        INCLUDE.BILL.ID = ""
                    END

                CASE SELECTION.TYPE = "SINGLE.MULTI"
                    IF SELECTION.VALUE NE R.AA.BILL.DETAILS<SELECTION.FIELD,1> THEN
                        INCLUDE.BILL.ID = 1
                    END ELSE
                        INCLUDE.BILL.ID = ""
                    END

                CASE SELECTION.TYPE = "MULTI"
                    LOCATE SELECTION.VALUE IN R.AA.BILL.DETAILS<SELECTION.FIELD,1> SETTING POS THEN
                        INCLUDE.BILL.ID = ""
                    END ELSE
                        INCLUDE.BILL.ID = 1
                    END
            END CASE

        CASE SELECTION.CONDITION = "GT"
            IF R.AA.BILL.DETAILS<SELECTION.FIELD> GT SELECTION.VALUE THEN
                INCLUDE.BILL.ID = 1
            END ELSE
                INCLUDE.BILL.ID = ""
            END

        CASE SELECTION.CONDITION = "LT"
            IF R.AA.BILL.DETAILS<SELECTION.FIELD> LT SELECTION.VALUE THEN
                INCLUDE.BILL.ID = 1
            END ELSE
                INCLUDE.BILL.ID = ""
            END

        CASE SELECTION.CONDITION = "GE"
            IF R.AA.BILL.DETAILS<SELECTION.FIELD> GE SELECTION.VALUE THEN
                INCLUDE.BILL.ID = 1
            END ELSE
                INCLUDE.BILL.ID = ""
            END

        CASE SELECTION.CONDITION = "LE"
            IF R.AA.BILL.DETAILS<SELECTION.FIELD> LE SELECTION.VALUE THEN
                INCLUDE.BILL.ID = 1
            END ELSE
                INCLUDE.BILL.ID = ""
            END

    END CASE

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check capitalised Bill settlements>
***
CHECK.CAPITALISED.BILL.SETTLEMENT:

    IF SETTLED.SELECTION = "EQ" THEN
        IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> EQ 0 OR R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> EQ "" THEN
            INCLUDE.BILL.ID = 1
        END ELSE
            INCLUDE.BIL.ID = ""
        END
    END

    IF SETTLED.SELECTION = "NE" THEN
        IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> EQ 0 OR R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> EQ "" THEN
            INCLUDE.BILL.ID = ""
        END ELSE
            INCLUDE.BIL.ID = 1
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update Calculated Values>
***
CHECK.TAX.INCLUSIVE:
    
    CALC.TAX = ''
    AA.PaymentRules.CheckTaxInclusiveMakedue(ARR.ID,'', EFF.DATE, TAX.INCLUSIVE, MAKE.DUE, "", "", RET.ERROR)
    IF TAX.INCLUSIVE THEN
        CALC.TAX =1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update Calculated Values>
***
UPDATE.CALCULATED.VALUES:

** Update repayment, adjustment, write-off amounts

    PROPERTY.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>, @VM)

    FOR PR.I = 1 TO PROPERTY.COUNT
        PROPERTY.ID = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I> ;* Get the property ID
    
        ABB.PROPERTY = "" ;* Flag to indicate the property type is accrue by bill
        TAX.AMT = 0
        OS.ABB.AMT = 0
        
        R.PROPERTY = AA.ProductFramework.Property.CacheRead(PROPERTY.ID, RET.ERROR)    ;* Read the Property record
       
        LOCATE 'ACCRUAL.BY.BILLS' IN R.PROPERTY<AA.ProductFramework.Property.PropPropertyType,1> SETTING PropPos THEN
            TAX.INCLUSIVE = ""
            MAKE.DUE = ""
            EFF.DATE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
            GOSUB CHECK.TAX.INCLUSIVE
            ABB.PROPERTY = "1"
            CUR.OR.AMT = TAX.AMT + R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I>
            IF CALC.TAX THEN
                GOSUB CALCULATE.TAX.AMOUNT
                
            END
            OS.ABB.AMT = OS.ABB.AMT + TAX.AMT + R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I>
        
        END
        REPAY.AMOUNT = 0
        ADJUST.AMOUNT = 0
        WRITEOFF.AMOUNT = 0

        REPAY.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayRef,PR.I>, @SM)
        ADJUST.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PR.I>, @SM)
        WRITEOFF.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.I>, @SM)

** Process repayments

        FOR RPY.I = 1 TO REPAY.COUNT
            SUSPEND.REFERENCE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayRef,PR.I,RPY.I>,"-",2) = "SUSPEND"        ;* We dont need repayment against suspension, it is just a split within the repayment amount
            IF FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I>,"-",2) NE 'SKIM' THEN
                TAX.PROPERTY = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I>,"-",2) ;* Fetches the property in the bill details record and checks if it has tax
            END
            REPAY.FLAG = 1
            IF TAX.PROPERTY THEN ;* If Property is Tax then no need to add to the Repay Amount
                REPAY.REF = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayRef,PR.I,RPY.I>,"-",1) ;* Fetches the repay reference ID
                IF REPAY.REF EQ R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdDueReference> THEN ;* Checks if RepaymentReference is equal to the DueReference
                    REPAY.FLAG = ""
                END
            END
            IF NOT(SUSPEND.REFERENCE) AND REPAY.FLAG AND NOT(ABB.PROPERTY) THEN ;* REPAY.FLAG checks decides if the addition has to be done or not based on above conditions
                REPAY.AMOUNT += R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayAmount,PR.I,RPY.I>
            END
        NEXT RPY.I

** Process adjustments

        FOR ADJ.I = 1 TO ADJUST.COUNT
            SUSPEND.REFERENCE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PR.I,ADJ.I>,"-",2) = "SUSPEND"       ;* We dont need adjustment against suspension
            RESUME.REFERENCE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PR.I,ADJ.I>,"-",2) = "RESUME"       ;* We dont need adjustment against resume
            HOLIDAY.REFERENCE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PR.I,ADJ.I>,"-",2) = "HOLIDAY"       ;* We dont need adjustment against Holiday activity
            
            IF NOT(SUSPEND.REFERENCE) AND NOT(RESUME.REFERENCE) AND NOT(ABB.PROPERTY) AND NOT(HOLIDAY.REFERENCE) THEN ;* Adjust amount should be ignored if it is due to payment holiday activity.
                ADJUST.AMOUNT += R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustAmt,PR.I,ADJ.I>
            END
        NEXT ADJ.I

** Process write-offs

        FOR WOF.I = 1 TO WRITEOFF.COUNT
            SUSPEND.REFERENCE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.I,WOF.I>,"-",2) = "SUSPEND"     ;* We dont need writeoff against suspension

            IF NOT(SUSPEND.REFERENCE) AND NOT(ABB.PROPERTY) THEN
                WRITEOFF.AMOUNT += R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffAmt,PR.I,WOF.I>
            END
        NEXT WOF.I

** New "D" fields in the enquiry, if the positions are changed in AA.BILL.DETAILS, we need to change and move these again

**        R.AA.BILL.DETAILS<AA.BD.TR.PROPERTY,PR.I> = R.AA.BILL.DETAILS<AA.BD.PROPERTY,PR.I>
        R.AA.BILL.DETAILS<AA.BD.TOT.RPY.AMT> += REPAY.AMOUNT
        R.AA.BILL.DETAILS<AA.BD.TOT.ADJ.AMT> += ADJUST.AMOUNT
        R.AA.BILL.DETAILS<AA.BD.TOT.WOF.AMT> += WRITEOFF.AMOUNT
        
        IF TAX.AMT THEN
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I+1>     = PROPERTY.ID:'-':TAX.PROP
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I+1> = TAX.AMT
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount,PR.I+1> = TAX.AMT
            TAX.AMT = ''
        END

    NEXT PR.I

    IF HISTORY THEN
        R.AA.BILL.DETAILS<AA.BD.HISTORY> = "YES"
    END

** Settled Date

    IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdDelinOsAmt> = 0 OR R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> = 0 THEN
        IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdDelinOsAmt> # "" THEN
            R.AA.BILL.DETAILS<AA.BD.SETTLED.DATE> = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAgingStChgDt,1>
            IF R.AA.BILL.DETAILS<AA.BD.SETTLED.DATE> EQ "" THEN     ;* Check if the settled date is null when the record has delin os amt
                R.AA.BILL.DETAILS<AA.BD.SETTLED.DATE> = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdSetStChgDt,1>
            END
        END ELSE
            R.AA.BILL.DETAILS<AA.BD.SETTLED.DATE> = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdSetStChgDt,1>
        END
    END
    
    R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> += OS.ABB.AMT
            


RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name= Update Bill Record>
***
UPDATE.BILL.RECORD:

** Return Bill details record

    IF PAYMENT.DATES THEN
        LOCATE R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate> IN PAYMENT.DATES<1> BY "DR" SETTING NEXT.POS ELSE
            NULL
        END

        INS R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate> BEFORE PAYMENT.DATES<NEXT.POS>

    END ELSE
        PAYMENT.DATES = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
    END

    CONVERT @FM TO "*" IN R.AA.BILL.DETAILS
    
    IF BILL.DETAILS THEN ;* Avoid the null position in return array
        INS BILL.ID:"*":R.AA.BILL.DETAILS BEFORE BILL.DETAILS<NEXT.POS>
    END ELSE
        BILL.DETAILS = BILL.ID:"*":R.AA.BILL.DETAILS
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= FULL.OR.PARTIAL.WAIVED>
FULL.OR.PARTIAL.WAIVED:
*** <desc>To check if bill is waived fully or partially to include bill in enquiry </desc>
    IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWaivePrAmt,PAY.CNT,WAIVE.CNT> EQ R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPrAmt,PAY.CNT,WAIVE.CNT> THEN
        INCLUDE.BILL.ID.COUNT += 1
        IF INCLUDE.BILL.ID.COUNT EQ WAIVE.COUNT THEN
            INCLUDE.BILL.ID = ""
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.SYSTEM.BILL.TYPE>
*** <desc>Check Sys Bill Type /desc>
CHECK.SYSTEM.BILL.TYPE:

** Skip Enquiring Processing for EXTERNAL type of Bill Type
    
    BILL.TYPE.EXTERNAL = ''
    EXTERNAL.BILL = ''
    R.AA.BILL.TYPE = ''
    SYSTEM.BILL.TYPE = ''
    BILL.TYPE.EXTERNAL = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillType>    ;* Get the Bill Type from the Bill details
    R.AA.BILL.TYPE = AA.PaymentSchedule.BillType.CacheRead(BILL.TYPE.EXTERNAL, RET.ERROR)    ;* Read the Bill Type record
    SYSTEM.BILL.TYPE = R.AA.BILL.TYPE<AA.PaymentSchedule.BillType.BtSysBillType>    ;* Fetch the System Bill type
    IF SYSTEM.BILL.TYPE = 'EXTERNAL' THEN
        EXTERNAL.BILL = 1   ;* Set Flag if the Sys bill type is EXTERNAL
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
CALCULATE.TAX.AMOUNT:

    PAYMENT.PROP.AMT = CUR.OR.AMT

    ARRANGEMENT.ID<1> = ARR.ID
    ARRANGEMENT.ID<2> = 'ENQUIRY'
    AA.Tax.GetTaxCode(ARRANGEMENT.ID , PROPERTY.ID, EFF.DATE , TAX.PROP , TAX.CODE ,TAX.COND ,RET.ERROR)
    IF(TAX.CODE OR TAX.COND) THEN
        AA.Tax.CalculateTax(ARR.ID , EFF.DATE , PROPERTY.ID ,PAYMENT.PROP.AMT , TAX.PROP , '', TAX.AMT , TAX.AMT.LCY ,"", RET.ERROR)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
