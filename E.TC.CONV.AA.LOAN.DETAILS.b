* @ValidationCode : MjoxNTYxNDM2MzI5OkNwMTI1MjoxNjExMTE5ODc0MTAzOnJzdWRoYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDIzLTA1MDU6MTU4OjE0MQ==
* @ValidationInfo : Timestamp         : 20 Jan 2021 10:47:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 141/158 (89.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201023-0505
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-99</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Channels
SUBROUTINE E.TC.CONV.AA.LOAN.DETAILS
*-----------------------------------------------------------------------------------------------
* Description :
* -----------
* This Enquiry(Conversion) routine is to provide different amounts of loans
*------------------------------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : field ARR.BAL.DETAILS in enquiry > TC.AA.LOANS
* IN Parameters      : Arrangement Id, Linked application Id ( Account Id) from enquiry field
* Out Parameters     : Approved, paid out and outstadning amounts are returned to the same field
*
*--------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 13/07/16 - Enhancement 1657937 / Task 1797520
*            TCIB Componentization - Loan improvements
*
* 27/11/18 - Defect 2859578 / Task 2875192
*            Owed amount (Prinicipal) and amount paid out details
*
* 19/01/21 - Defect 4186596/ Task 4188050
*            Changes made to return correct outstanding balances and approved amount when Arrangement is moved to Expired.
*-----------------------------------------------------------------------------


    $USING AA.Account
    $USING AA.ModelBank
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.TermAmount
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Utility
    $USING EB.Template
    $USING AC.SoftAccounting
    $USING EB.DataAccess
    $USING BF.ConBalanceUpdates
*** This common varible is used to store all AC.BALANCE.TYPE details when we click the first time
*** subsequent process we will re-use this common.
    COMMON/AAFINSUM/AC$BALANCES.TYPE.DETAILS

    GOSUB INITIALISE
    GOSUB GET.AMOUNT.PAIDOUT
    GOSUB GET.OUTSTANDING.AMT
    GOSUB GET.BALANCE.TYPES
    GOSUB ADD.BALANCES

    FINAL.ARR = AMT.PAID:'*':BAL.ARRAY<1>:"*":AMT.OUTSTAND:"*":BAL.ARRAY<2> ;* Set return values
    EB.Reports.setOData(FINAL.ARR)
    AA.Framework.setAccountDetails(SAVE.AA.ACCOUNT.DETAILS)
RETURN
*-------------------------------------------------------
INITIALISE:
*---------
*Initialise required variables
    RET.ERR=''      ;* Initialise Record Error
    BALANCE.AMOUNT=''         ;* Initialise Balance Amount
    ECB.ERROR=''    ;* Initialise ECB error
    AMT.PAID = ''   ;* Initialise paid Amount
    BAL.ARRAY = ''
    SAVE.AA.ACCOUNT.DETAILS = AA.Framework.getAccountDetails()
    AA.Framework.setAccountDetails("") ;* Clear common details
    SAVE.O.DATA=EB.Reports.getOData()        ;* Save O.DATA values
    ACCT.NO=FIELD(SAVE.O.DATA,'*',1) ;* Get Account Id from O.DATA
    ARRANGEMENT.ID=FIELD(SAVE.O.DATA,'*',2)       ;* Get Arrangement Id from O.DATA
    AA.Framework.GetArrangement(ARRANGEMENT.ID, ARR.RECORD, RET.ERR)
    AA.PaymentSchedule.ProcessAccountDetails(ARRANGEMENT.ID, 'INITIALISE', '', R.ACCOUNT.DETAILS, ERRMSG)
    AA.Framework.setAccountDetails(R.ACCOUNT.DETAILS)
    ARR.START.DATE = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdValueDate>
    
    END.DT = EB.SystemTables.getToday()
    IF ARR.START.DATE GT END.DT THEN         ;* can be true for fwd dated arrangement
        END.DT = ARR.START.DATE
    END

    BALANCE.TYPE.POS = 50     ;* Balance type field in record
    BALANCE.BK.AMT.POS = 51   ;* Booking dated balance for balance type
    BALANCE.VD.AMT.POS = 52   ;* Value Dated balance for balance type

    
*** No need to load again & again.
    IF NOT(AC$BALANCES.TYPE.DETAILS<1>) THEN
        GOSUB BUILD.AC.BALANCES.LIST
    END
RETURN
*------------------------------------------------------------------
GET.AMOUNT.PAIDOUT:
*------------------
*Get the Bill Id which has SETTLED

    BILL.REFERENCES = ''
    BILL.TYPE = 'DISBURSEMENT'
    BILL.STATUS = 'SETTLED'   ;* Initialise Bill Status
    AA.PaymentSchedule.GetBill(ARRANGEMENT.ID,ACTIVITY.ID,PAYMENT.DATE,"",BILL.DATE,BILL.TYPE,PAYMENT.METHOD,BILL.STATUS,BILL.SETTLE.STATUS,BILL.AGE.STATUS,BILL.NEXT.AGE.DATE,REPAYMENT.REFERENCE,BILL.REFERENCES,RET.ERROR)
    CHANGE @VM TO @FM IN BILL.REFERENCES
    LOOP
        REMOVE BILL.ID.SEL FROM BILL.REFERENCES SETTING BILL.SEL.POS
    WHILE BILL.ID.SEL:BILL.SEL.POS
        BILL.REFERENCE = BILL.ID.SEL    ;* Get Bill Reference
        AA.PaymentSchedule.GetBillDetails(ARRANGEMENT.ID,BILL.REFERENCE,BILL.DETAILS,RET.ERROR) ;* Get Bill Details
        IF BILL.DETAILS AND  BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdArrangementId> EQ ARRANGEMENT.ID THEN
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
*-----------------------------------------------------------------------------
BUILD.AC.BALANCES.LIST:
*--------------------
** Get a list AC.BALANCE.TYPES and store a separate list of virtual balances
*
    F.AC.BALANCE.TYPE = ''
    EB.DataAccess.Opf("F.AC.BALANCE.TYPE", F.AC.BALANCE.TYPE)
*
    SelectCommand = "SELECT F.AC.BALANCE.TYPE"
    ListError = ''
    EB.DataAccess.Readlist(SelectCommand, BALANCE.LIST, "", "", ListError)
    BAL.IDX = ''
    LOOP
        REMOVE BALANCE.NAME FROM BALANCE.LIST SETTING BAL.POS
    WHILE BALANCE.NAME:BAL.POS
        BALANCE.TYPE.REC = ''
        BALANCE.TYPE.REC = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.NAME, "")
        BAL.IDX += 1
        AC$BALANCES.TYPE.DETAILS<1,BAL.IDX> = BALANCE.NAME
        AC$BALANCES.TYPE.DETAILS<2,BAL.IDX> = LOWER(BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtVirtualBal>)
        AC$BALANCES.TYPE.DETAILS<3,BAL.IDX> = BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtActivityUpdate>
    REPEAT
*
    IF AC$BALANCES.TYPE.DETAILS = '' THEN
        AC$BALANCES.TYPE.DETAILS = "NONE"       ;* Stop repeated selection
    END
*
RETURN
*
*-------------------------------------------------------
GET.BALANCE.TYPES:
*------------------
* Set balance type for which the balance amount is to be returned
    BAL.TYPES = 'TOTCOMMITMENT':@VM:'TOTALPRINCIPAL'
    BALANCE.LIST = CHANGE(BAL.TYPES,@VM,@FM)
    REQD.BAL.LIST = BAL.TYPES
    
RETURN
*-----------------------------------------------------------------------------
ADD.BALANCES:
*
** Now for each balance in the list call EB.GET.ACCT.BALANCE to retrieve
** the balance we want
*
    NEXT.BAL = 0
    IDX = 0
    REQUEST.TYPE<3> = 'ALL'
    REQUEST.TYPE<2> = 'ALL'
    BAL.DETAILS = ''
    LOOP
        IDX += 1
        BALANCE.TYPE = BALANCE.LIST<IDX>
    WHILE BALANCE.TYPE
        BD.BAL = ''
        LOCATE BALANCE.TYPE IN AC$BALANCES.TYPE.DETAILS<1,1> SETTING BAL.POS THEN
            VIRTUAL.BALANCES = AC$BALANCES.TYPE.DETAILS<2,BAL.POS>
            IF VIRTUAL.BALANCES THEN    ;* Get the balance from the values we've already calculated
                VIRTUAL.BAL = 'YES'
                SAVE.BALANCE.TYPE =  BALANCE.TYPE
                GOSUB CALCULATE.VIRTUAL.BALANCE
                BALANCE.TYPE = SAVE.BALANCE.TYPE
                BD.BAL = BAL.AMT
            END ELSE
                GOSUB GET.PERIOD.BALANCES
            END
            IF BALANCE.TYPE EQ "TOTCOMMITMENT" AND NOT(BD.BAL) THEN
               
                R.TERM.AMOUNT = ""
                AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "TERM.AMOUNT", "", "", "", R.TERM.AMOUNT, RETURN.ERROR) ;* Get the Term Amount condition record
                R.TERM.AMOUNT = RAISE(R.TERM.AMOUNT)
                BD.BAL = R.TERM.AMOUNT<AA.TermAmount.TermAmount.AmtAmount> ;* Get The commitment amount
       
            END
       
        END
    
        NEXT.BAL +=1
        BAL.ARRAY<NEXT.BAL> = BD.BAL
    REPEAT
    CONVERT @FM TO '*' IN BAL.ARRAY
*
RETURN
*
*-----------------------------------------------------------------------------
CALCULATE.VIRTUAL.BALANCE:
*
** We'll calculate this from the balances that we will have already extracted
** We do this as although EB.GET.ACCT.BALANCE handles virtual balances it only
** does so if the balance is in ACCT.ACTIVITY which may not always be the case
** for some balances
*
    BAL.AMT = ''
    LOOP
        REMOVE BAL.NAME FROM VIRTUAL.BALANCES SETTING YD
    WHILE BAL.NAME:YD
        LOCATE BAL.NAME IN ARR.RECORD<BALANCE.TYPE.POS,1> SETTING BAL.POS THEN
            BAL.AMT += ARR.RECORD<BALANCE.BK.AMT.POS, BAL.POS>
        END ELSE
            BALANCE.TYPE = BAL.NAME
            BD.BAL = 0.00
            GOSUB GET.PERIOD.BALANCES
            BAL.AMT + = BD.BAL
        END

    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
GET.PERIOD.BALANCES:
*-----------------
* Get balances for the selected balance type
    AA.Framework.GetPeriodBalances(ACCT.NO,BALANCE.TYPE,REQUEST.TYPE,ARR.START.DATE,END.DT,'',BAL.DETAILS,'')
    NO.OF.DT = DCOUNT(BAL.DETAILS<1>,@VM)
    BD.BAL = BAL.DETAILS<4,NO.OF.DT>

RETURN
*-----------------------------------------------------------------------------
GET.OUTSTANDING.AMT:
*------------------
* Process outstanding amount

    GOSUB GET.ACCOUNT.PROPERTY ;* Get The Account Property of the arrangement
    GOSUB GET.ACCOUNT.BALANCE.TYPES ;* Get the Account Balance Types

    TOT.ACC.BAL.TYPES = DCOUNT(ACC.BAL.TYPES, @FM) ;* Get the total account balance types
    AMT.OUTSTAND = ""
    FOR ACC.BAL.CNT = 1 TO TOT.ACC.BAL.TYPES
        BALANCE.AMOUNT = ""
        AA.Framework.GetEcbBalanceAmount(ACCOUNT.ID,ACC.BAL.TYPES<ACC.BAL.CNT>,REQUEST.DATE,BALANCE.AMOUNT,ECB.ERROR) ;* Get the balance amount for each account balance type
        AMT.OUTSTAND = AMT.OUTSTAND + BALANCE.AMOUNT ;* Get all the account balances including overdue balances
    NEXT ACC.BAL.CNT

RETURN
*------------------------------------------------------------
GET.ACCOUNT.PROPERTY:
*------------------
    PROP.LIST = ""
    AA.Framework.GetArrangementProperties(ARRANGEMENT.ID, '', "", PROP.LIST) ;* Get the Property List for arrangement
    PROP.CLASS.LIST = ""
    AA.ProductFramework.GetPropertyClass(PROP.LIST, PROP.CLASS.LIST) ;* Get corresponding property class
    
    LOCATE 'ACCOUNT' IN PROP.CLASS.LIST<1,1> SETTING PROP.POS THEN
        ACCOUNT.PROP = PROP.CLASS.LIST<1,PROP.POS> ;* Account Property of the arrangement
    END
    
RETURN
*------------------------------------------------------------
GET.ACCOUNT.BALANCE.TYPES:
*------------------
    ECB.RECORD = BF.ConBalanceUpdates.EbContractBalances.CacheRead(ACCOUNT.ID, "")   ;* Read the ECB directly
    
    BAL.COUNT = 0
    LOOP
        BAL.COUNT += 1 ;*Loop through each TypeSysDate
        BAL.TYPE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbBalType, BAL.COUNT>["-",1,1] ;*Extract the balances
    WHILE BAL.TYPE ;*Process when we have a valid balance type
        IF BAL.TYPE[4,99] EQ ACCOUNT.PROP THEN
            ACC.BAL.TYPES<-1> = BAL.TYPE ;* Get all the account balance types
        END
    REPEAT
RETURN
*------------------------------------------------------------------

END
