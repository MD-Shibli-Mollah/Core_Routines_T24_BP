* @ValidationCode : Mjo0MjY4NTQ1NTpDcDEyNTI6MTU2NjQwODAyMzQwNjpzbWl0aGFiaGF0OjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MjMtMDI1MToxMDk6OTc=
* @ValidationInfo : Timestamp         : 21 Aug 2019 22:50:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 97/109 (88.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-92</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.COLLECTOR.INPUT(ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* This Routine will build Collector Item's based on Collector Id.
*
*
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.COLLECTOR.INPUT
* @uses
* @package retaillending.CL
*
*** </doc>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* Output
*
* Return ENQ.LIST -List of Collection item details.
*
*** </region>
*** </region>

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>

* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection Process
*
* 10/07/19 -  ENHANCEMENT - 2886910/Task - 3221955
*          -  Changes made to get the Limit Id for Accounts Arrangement which is overdrawn
* ----------------------------------------------------------------------------
*** </region>

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
* ENQ.LIST = It return final result
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Insert Section>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework


*** </region>

*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>
*** <region name= INITIALISE>
*** <desc>Initialise local variables and file variables</desc>

*---------*
INITIALISE:
*---------*

    F.CL.COLLECTOR = ""

    F.CL.QUEUE = ""

    FN.CL.COLLECTOR.ITEM = "F.CL.COLLECTION.ITEM"
    F.CL.COLLECTOR.ITEM = ""
    EB.DataAccess.Opf(FN.CL.COLLECTOR.ITEM,F.CL.COLLECTOR.ITEM)
    R.CL.COLLECTION.ITEM = ''
    F.CL.COLLECTOR.USER = ''


    FN.AA.OVERDUE.STATS = 'F.AA.OVERDUE.STATS'
    F.AA.OVERDUE.STATS =''
    EB.DataAccess.Opf(FN.AA.OVERDUE.STATS,F.AA.OVERDUE.STATS)
    
    FN.LIMIT = 'F.LIMIT'
    F.LIMIT =''
    EB.DataAccess.Opf(FN.LIMIT,F.LIMIT)

    ENQ.LIST = ""
    PREV.SELECTED = ""
    NOW.PROCESSED = ""

    COLL.ID = ''    ;* Collector Id
    R.CL.COLLECTOR = ""       ;* To store the Collector Record
    COLL.READ.ERR = ""

    QUEUES.LIST = ''          ;* Assigend Queue List Like A1,A2 ...A6
    NO.OF.QUEUES = ''         ;* Total No of Queue Assigned to a Collector
    SEL.CMD = ''
    CURRENT.QUEUE = ''

    RA.FLAG = ''
    NO.OF.PDS = ''  ;* Due Reference Ex : PDLD... and AC.BALANCE.TYPE for AA
    CI.ARRAY = ''
    FORM.ARRAY = '' ;* Final Return Array

RETURN
*** </region>

*** <region name= PROCESS>
*** <desc>Main Selection Process</desc>


*------*
PROCESS:
*------*

* Get the collector ID from the Enquiry input.

    tmp.OPERATOR = EB.SystemTables.getOperator()
    R.CL.COLLECTOR.USER = CL.Contract.CollectorUser.Read(tmp.OPERATOR, ERR.CL.COLLECTOR)
    EB.SystemTables.setOperator(tmp.OPERATOR)
    IF R.CL.COLLECTOR.USER THEN
        COLL.ID = R.CL.COLLECTOR.USER
    END

    R.CL.COLLECTOR = CL.Contract.Collector.Read(COLL.ID, COLL.READ.ERR)
    IF COLL.READ.ERR NE '' AND COLL.ID THEN
        EB.Reports.setEnqError('Invalid Collector ID')
        RETURN
    END

* Get the all Queues assigned to this collector.

    GOSUB FORM.SELECTION.CRITERIA

    ENQ.LIST<-1> = FORM.ARRAY

RETURN

*** </region>
*** <region name= GET COLLECTION ITEM>
*** <desc>Get Collection Collection Record's based on Queue</desc>

*------------------------*
FORM.SELECTION.CRITERIA:
*------------------------*


* Sort Collection item record by using WEIGHT.

    SEL.CMD = "SELECT ":FN.CL.COLLECTOR.ITEM:" WITH COLLECTOR EQ ":SQUOTE(COLL.ID):" BY.DSND WEIGHT"

    SEL.LIST = ""
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.RECS,SEL.ERR)
    LOOP
        REMOVE COLL.ITEM.ID FROM SEL.LIST SETTING MORE
    WHILE COLL.ITEM.ID:MORE
        GOSUB FORM.ARRAY
    REPEAT
RETURN


*** </region>

*** <region name= FORM ARRAY TO GET ENQUIRY>
*** <desc>Read the Collection Item's and Form the Array Records</desc>

*---------*
FORM.ARRAY:
*---------*

    R.CL.COLLECTOR.ITEM = ""
    COLL.ITEM.READ.ERR = ""
    R.CL.COLLECTOR.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, COLL.ITEM.READ.ERR)

* Extract the necessary values to ENQUIRY from R.CL.COLLECTOR.ITEM

    CURRENT.QUEUE = R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitQueue>
    PREV.QUEUE = R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitPreviousQueue>
    IF CURRENT.QUEUE NE PREV.QUEUE AND PREV.QUEUE NE "" THEN
        RA.FLAG = "YES"
    END ELSE
        RA.FLAG = "NO" 
    END
    NO.OF.PDS = DCOUNT(R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitDueReference>,@VM)
    FOR PD.CNT = 1 TO NO.OF.PDS

        OVERDUE.ID = R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>
        IF OVERDUE.ID[1,2] EQ 'AA' THEN
            
            GOSUB GetArrangementDetails ;* Get the Arrangement Record of contract
            GOSUB GET.AA.OVERDUE.STATS.ID
            GOSUB GetLimitId ;* Get the Limit attached to Accounts Arrangement
            
        END ELSE
            OVERDUE.LIST = R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitDueReference,PD.CNT>
        END
        IF PD.CNT EQ 1 THEN
            CI.ARRAY = COLL.ITEM.ID:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt>:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitTotOutstdingAmt>:"*"
            CI.ARRAY := R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitActionCode>:"*"
            CI.ARRAY := R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitActionDate>:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitOutcomeCode>:"*"
            CI.ARRAY := R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitCollector>:"*":CURRENT.QUEUE:"*":RA.FLAG:"*":OVERDUE.LIST:"*":COLL.ID:"*":OVERDUE.ID:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitOdCurrency,PD.CNT>:"*":LimitId ;* Append the Limit Id of arrangement to array
        END ELSE
            CI.ARRAY = "**********":OVERDUE.LIST:"*":COLL.ID:"*":OVERDUE.ID:"*":R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitOdCurrency,PD.CNT>:"*":LimitId ;* Append the Limit Id of arrangement to array
        END  
        FORM.ARRAY<-1> = CI.ARRAY
    NEXT PD.CNT

RETURN

GET.AA.OVERDUE.STATS.ID:
************************
    OVERDUE.LIST = '' ;* Initialise OVERDUE.LIST
    IF RArrangement<AA.Framework.Arrangement.ArrProductLine> EQ 'LENDING' THEN ;* Arrangement should belong to Lending Product Line
        OVERDUE.ID.LIST = SQUOTE(OVERDUE.ID):"..."
        SEL.CMD.AA = "SELECT ":FN.AA.OVERDUE.STATS:" WITH @ID LIKE ":DQUOTE(OVERDUE.ID.LIST)
        EB.DataAccess.Readlist(SEL.CMD.AA,SEL.LIST.AA,'',NO.OF.REC,ERR.REC)
        OVERDUE.LIST = SEL.LIST.AA
        CHANGE @FM TO @VM IN OVERDUE.LIST
    END
 
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetArrangementDetails>
*** <desc>Get Arrangement Record of the contract</desc>
GetArrangementDetails:
    
    RArrangement = ''
    RetError = ''
    AA.Framework.GetArrangement(OVERDUE.ID, RArrangement, RetError) ;* Get the Arrangement Record
    
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetLimitId>
*** <desc>Get Limit Id for Accounts Arrangement</desc>
GetLimitId:
    
    LimitId = '' ;* Initialise Limit Id
    IF RArrangement<AA.Framework.Arrangement.ArrProductLine> EQ 'ACCOUNTS' THEN ;* Arrangement should belong to Accounts Product Line
        AccountNumber = R.CL.COLLECTOR.ITEM<CL.Contract.CollectionItem.CitAccountNumber,PD.CNT> ;* Get the Account Number of Contract
        SelCmdLI = "SELECT ":FN.LIMIT:" WITH ACCOUNT LIKE ":AccountNumber
        SelList = ''
        NoOfRec = ''
        SelErr = ''
        EB.DataAccess.Readlist(SelCmdLI,SelList,'',NoOfRec,SelErr)
        LimitId = SelList ;* Get the Limit Id
    END

RETURN
*** </region>
*--------------------------------------------------------------------------
END
