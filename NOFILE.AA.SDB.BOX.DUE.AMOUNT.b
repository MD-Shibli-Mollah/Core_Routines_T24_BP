* @ValidationCode : MjoxNzI3NjE5MTA2OkNwMTI1MjoxNTY0NTU0MDIwNjI5OmpoYWxha3Zpajo2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MTI3OjY5
* @ValidationInfo : Timestamp         : 31 Jul 2019 11:50:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 69/127 (54.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE BX.ModelBank
SUBROUTINE NOFILE.AA.SDB.BOX.DUE.AMOUNT(lineOut)
*-----------------------------------------------------------------------------
**** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* This routine is linked to a NOFILE enquiry , it takes a Safe Deposit Box No as input and returns data to the enquiry
* The Layout for Data returned is Box Type Box No ~Box Type  ~ Box Status ~ Arrangement ID  ~Overdue Status ~ Overdue Amount
*
*-----------------------------------------------------------------------------
* @uses
* @package BX.ModelBank
* @stereotype subroutine
* @link
* @author empoyi@temenos.com
*-----------------------------------------------------------------------------
*** </region>
************************************************************************************
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*------
* @implied             - box no from enquiry selection screen

* Ouptut
*-------
* @param lineOut       - Box No ~Box Type  ~ Box Status ~ Arrangement ID  ~Overdue Status ~ Overdue Amount
*** </region>

************************************************************************************

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
*  31/03/2016 - Enhancement : 1629504
*               Task : 1629504
*               1.
*
* 02/08/2017 - Defect : 2213587
*              Task : 2219019
*              Select the current branch company AA.SDB.BOX alone when launchig the enquiry
*              If company select is set to ALL then select all SDB boxes.
*
* 22/05/2018 - Enhancement : 2583186
*              Task : 2583189
*              Adding functionality of searching based on branch of the box.
*
* 02/08/2018 - Defect : 2692354
*              Task : 2705231
*              Enquiry will display due amount of the boxes for the Safe deposit boxes even which
*               that are not linked with Branch.
*
* 08/05/2019 - Defect : 3080640
*              Task : 3119368
*              Enquiry AA.SDB.BOX.TOTAL (Nofile Enquiry) is not fetching the required output after passing the selection criteria for the branch in the enquiry during runtime
*
* 26/07/2019 - Defect : 3251319
*              Task : 3251578
*              Enquiry AA.SDB.BOX.TOTAL (Nofile Enquiry) should fetch the records properly.
*
*** </region>

*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>import required packages </desc>
    $USING BX.Framework  
    $USING EB.Reports
    $USING EB.SystemTables  
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AC.BalanceUpdates
    $USING AC.SoftAccounting

*---------------------------------------
*** <region name =  Main Flow>
*** <desc>Main Flow of program </desc>
    GOSUB Initialise
    GOSUB GetBranchSelectionCriteria
    GOSUB GetSelectionCriteria
    GOSUB Process

RETURN
*-----------------------------------------------------------------------------
*** <region name =  Initialise>
*** <desc>Initialise variables </desc>
Initialise:
*-----------------------------------------------------------------------------

**** Define layout of Outgoing enquiry Line
    EQU  boxNoField TO 1 , boxTypeField TO 2,    boxStatusField TO 3 ,    arragementIdField TO 4,    boxAgeStatusField TO 5,    boxDueAmountField   TO 6
    
****  Get COMMON variable from the enquiry system
    dFields = EB.Reports.getDFields()
    dRangeAndValue = EB.Reports.getDRangeAndValue()
    logicalOperands = EB.Reports.getDLogicalOperands()
    enqSelection = EB.Reports.getEnqSelection()
    EQU enqSelectionEnquiryName TO 1 , enqSelectionFields TO 2 , enqSelectionOperators TO 3 , enqSelectionCriterion TO 4

    CompanyForEnquiry  = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqCompanySelect>          ;* If user given ALL in this field select boxes for all companies
    
    CompanyCode = EB.SystemTables.getIdCompany()  ;* Get USER current company code
**** Set the File to be selected and Initialise select Statement
    FN.FILE.NAME = "F.AA.SDB.BOX"
    F.FILE.NAME = ""
    EB.DataAccess.Opf(FN.FILE.NAME, F.FILE.NAME) 

    IF CompanyForEnquiry EQ 'ALL' THEN  ;* Enquiry allowed to display the all company SDB boxes details
        SelectStatement = 'SELECT ':F.FILE.NAME
    END ELSE
        SelectStatement = 'SELECT ':F.FILE.NAME: ' WITH CO.CODE EQ ' :  CompanyCode ;* Only allowed current USER company SDB boxes
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name =  GetBranchSelectionCriteria>
*** <desc>Since BRANCH is not a real field in the table but only part of the ID we cannot just add it to the JQL selection.</desc>
GetBranchSelectionCriteria:
*-----------------------------------------------------------------------------
**** Loop through user provided selection Criteria and Append them to the JQL slect statement

    selectionField = "BRANCH"
    branchSearchLocation = ""
                
    LOCATE selectionField IN dFields SETTING branchPosition THEN;*If found, store the corresponding value from dRangeAndValue
        
        selectionFields = RAISE(enqSelection<enqSelectionFields>)
        LOCATE selectionField IN selectionFields SETTING enqPosition THEN
         
            branchField = enqSelection<enqSelectionFields, enqPosition>
            branchOperator = enqSelection<enqSelectionOperators, enqPosition>
            branchCriteria = enqSelection<enqSelectionCriterion, enqPosition>
        
            DEL enqSelection<enqSelectionFields, enqPosition>;*Now delete the branch criteria from the enquiry selection
            DEL enqSelection<enqSelectionOperators, enqPosition>
            DEL enqSelection<enqSelectionCriterion, enqPosition>
        END
    
        DEL dFields<branchPosition>
        DEL dRangeAndValue<branchPosition>
         
        BEGIN CASE
            CASE branchCriteria AND branchOperator EQ 'EQ';*If we have a branch criteria add it to the select statement. In all other cases leave the select statement unchanged.

                SelectStatement := " AND WITH @ID LIKE ...-":branchCriteria:"-..."

            CASE branchCriteria AND branchOperator EQ 'NE'

                SelectStatement := ' AND WITH @ID UNLIKE ...-':branchCriteria:'-...'
        END CASE
    END
    
RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name =  GetSelectionCriteria>
*** <desc>retrieve the box number entered by the user, format can be boxNo or CompanyCode-BoxNo </desc>
GetSelectionCriteria:
*-----------------------------------------------------------------------------
**** Loop through user provided selection Criteria and Append them to the JQL select statement
    noOfSelectionCriteria = DCOUNT(dRangeAndValue,@FM)
    IF noOfSelectionCriteria GE 1  THEN
        SelectStatement := ' WITH '
        FOR selectionFieldCount = 1 TO noOfSelectionCriteria
            IF LEN(dRangeAndValue<selectionFieldCount>) LT 1 THEN
                CONTINUE ;* skip any selection field where no selection criteria is not provided
            END
            IF selectionFieldCount GT 1   THEN
                SelectStatement := ' AND WITH '
            END
            selectionField = dFields<selectionFieldCount>
            selectionCriteria = dRangeAndValue<selectionFieldCount>
            LOCATE selectionField IN enqSelection<enqSelectionFields,1> SETTING itsPosition THEN
                selectionOperator = enqSelection<enqSelectionOperators,itsPosition>
            END

            SelectStatement :=  selectionField :' ':selectionOperator:' ':selectionCriteria
        NEXT selectionFieldCount
    END
    
RETURN
*-----------------------------------------------------------------------------

*** <region name =  Process>
*** <desc>Read the box record and Build enquiry Output Box No ~Box Type  ~ Box Status ~ Arrangement ID  ~Overdue Status ~ Overdue Amount  </desc>
Process:
*-----------------------------------------------------------------------------
    KeyList=''
    ListName=''
    Selected=''
    SystemReturnCode=''
    EB.DataAccess.Readlist(SelectStatement, KeyList, ListName, Selected, SystemReturnCode)
    boxLine = ''

    FOR boxCounter = 1 TO Selected
        boxId = KeyList<boxCounter>
        readError=''
        boxRecord   = BX.Framework.SdbBox.CacheRead(boxId,readError)
        IF (readError) THEN
            RETURN
        END
        boxType = boxRecord<BX.Framework.SdbBox.BxBoxType>
        boxStatus = boxRecord<BX.Framework.SdbBox.BxStatus>
        boxArrangementId = boxRecord<BX.Framework.SdbBox.BxArrangementId>
        
        boxBalDetails = 0
        
        IF boxArrangementId THEN
            GOSUB GetSdbDueAmounts
        END

        boxLine = ''
        GOSUB OutputTheLine

    NEXT boxCounter

RETURN
*-----------------------------------------------------------------------------

OutputTheLine:

    boxLine<boxNoField> = boxId
    boxLine<boxTypeField> = boxType
    boxLine<boxStatusField> = boxStatus
    boxLine<arragementIdField> = boxArrangementId
    boxLine<boxAgeStatusField> = boxAgeStatus
    boxLine<boxDueAmountField>   = boxBalDetails
    lineOut<-1>= CHANGE(boxLine,@FM,'*')

RETURN
*-----------------------------------------------------------------------------

GetSdbDueAmounts:

**** get Age Status for this Box
    readError=''
    accountDetailsRecord = AA.PaymentSchedule.AccountDetails.CacheRead(boxArrangementId,readError)
    boxAgeStatus = accountDetailsRecord<AA.PaymentSchedule.AccountDetails.AdArrAgeStatus>

**** get the Account No for this Box
    readError=''
    arrangementRecord = AA.Framework.Arrangement.CacheRead(boxArrangementId,readError)
    arrangementLinkedAppl = arrangementRecord<AA.Framework.Arrangement.ArrLinkedAppl>
    arrangementLinkedApplId = arrangementRecord<AA.Framework.Arrangement.ArrLinkedApplId>
    boxArrangementAccount = ''

    LOCATE 'ACCOUNT' IN arrangementLinkedAppl<1,1> SETTING itsPosition THEN
        boxArrangementAccount = arrangementLinkedApplId<1,itsPosition>
    END

**** Get balances for the account Linked to this Box
    
    GOSUB GetTotalDueAmount
    
RETURN
*-----------------------------------------------------------------------------

GetTotalDueAmount:

    BalanceToCheck = "TOTALSDBDUE"
    AcBalanceRec = AC.SoftAccounting.BalanceType.CacheRead(BalanceToCheck, "")
    IF AcBalanceRec<AC.SoftAccounting.BalanceType.BtVirtualBal> THEN
        BalanceToCheck = AcBalanceRec<AC.SoftAccounting.BalanceType.BtVirtualBal>
    END
    
    requestType<2> = "ALL"
    startDate = EB.SystemTables.getToday()
    endDate = EB.SystemTables.getToday()
    systemDate = ""
    
    BalanceAmount = 0
    
    FOR LOOP.CNT = 1 TO DCOUNT(BalanceToCheck,@VM)
        BalanceID = BalanceToCheck<1,LOOP.CNT>
        tmpBoxBalDetails = ''
        AA.Framework.GetPeriodBalances(boxArrangementAccount, BalanceID, RequestType, startDate, endDate, "", tmpBoxBalDetails, errorMessage)      ;* Get Property amount from EB.CONTRACT.BALANCES file.
        Balance = ABS(tmpBoxBalDetails<AC.BalanceUpdates.AcctActivity.IcActBalance>)
        BalanceAmount += Balance<1,DCOUNT(Balance,@VM)>
    NEXT LOOP.CNT
    
    boxBalDetails = BalanceAmount
            
RETURN
*-----------------------------------------------------------------------------

END
*-----------------------------------------------------------------------------

