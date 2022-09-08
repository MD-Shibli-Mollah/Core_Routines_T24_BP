* @ValidationCode : MjoxMTEwMTgxODkyOkNwMTI1MjoxNjE1MzI0MzE4MzM1OnNpdmFjaGVsbGFwcGE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjEyMjo3OA==
* @ValidationInfo : Timestamp         : 10 Mar 2021 02:41:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 78/122 (63.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------------

$PACKAGE T2.ModelBank
SUBROUTINE E.NOFILE.API.HOLDINGS(holdingsArray)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To list the holdings of the external user
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > T2.API.NOF.HOLDINGS.1.0.0 using the Standard selection NOFILE.API.HOLDINGS
* IN Parameters      : Customer Id (CUSTOMER.NO)
* Out Parameters     : Array of holding array values such as
*                      productLineId, arrangementId, productGroupId, accountId, productDescription/preferredLabel, currency, sortCode,
*                      accountIBAN, workingBalance, preferredProduct and preferredPosition (holdingsArray)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
*
* 10/03/19 - Enhancement 2875480 / Task 3018257
*            IRIS-R18 T24 changes - Merging customer holdings
*
* 18/03/19  - Enhancement - 2867757 / Task 3039079
*               Routine call has been introduced for External Accounts
*
* 02/02/20 - Defect 3506908 / Task 3510252
*               A stub is included for checking PA component
*
* 06/04/20 - Enhancement 342896 / Task 3680076
*            US Saas Integration - Adding customerReference id in holdings
*
* 28/09/20 - Task 3873602
*            Holdings API to accpet multiple accounts.
*
* 10/03/21 - ADP-1716
*            Infinity Wealth - Portfolio Id field changes for Investment Accounts
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING EB.ARC
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.Reports
    $USING T2.ModelBank
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AC.AccountOpening
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
    
    GOSUB Initialise
    GOSUB Process
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise variables used in this routine</desc>
Initialise:
*----------
*
    fnT2HoldingsParameter = 'F.T2.HOLDINGS.PARAMETER'
    fT2HoldingsParameter = ''
    EB.DataAccess.Opf(fnT2HoldingsParameter, fT2HoldingsParameter)
*
    PA.isInstalled = ''
    holdingsTypeSel = ''
    productFilter = ''
    customerIdSel = ''
    LOCATE 'CUSTOMER.ID' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        customerIdSel = EB.Reports.getDRangeAndValue()<REC.POS>       ;* Get the customer value from enquiry selection.
    END
    LOCATE 'HOLDINGS.TYPE' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        holdingsTypeSel = EB.Reports.getDRangeAndValue()<REC.POS>    ;* Get the customer value from enquiry selection.
    END
    LOCATE 'HOLDINGS.ID' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        holdingsIdSel = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
    LOCATE 'PREFERRED.HOLDINGS' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        getPreferredHoldingsSel = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END
        
  
    CONVERT "|" TO @VM IN holdingsTypeSel
    CONVERT "|" TO @VM IN holdingsIdSel
    IF NOT(customerIdSel) AND NOT(holdingsTypeSel) AND holdingsIdSel THEN
        totalHoldings=DCOUNT(holdingsIdSel,@SM)
        holdingsList=holdingsIdSel
        holdingsIdSel=''
        FOR AC.COUNT=1 TO totalHoldings
    
            accountRecord = AC.AccountOpening.Account.Read(holdingsList<1,1,AC.COUNT>, accounrError)      ;* Try reading the Account record
            arrangementId      = accountRecord<AC.AccountOpening.Account.ArrangementId>
            arrangementRecord = AA.Framework.Arrangement.Read(arrangementId, arrangementError)
            productLineId     = arrangementRecord<AA.Framework.Arrangement.ArrProductLine>
            BEGIN CASE
    
                CASE productLineId = "ACCOUNTS"
    
                    LOCATE "Accounts" IN holdingsTypeSel<1,1> SETTING holdingsPOS THEN
                        holdingsIdSel<1,holdingsPOS,-1>=holdingsList<1,1,AC.COUNT>
                    END ELSE
                        holdingsTypeSel<1,-1>="Accounts"
                        holdingsTypeCount=DCOUNT(holdingsTypeSel,@VM)
                        holdingsIdSel<1,holdingsTypeCount,-1>=holdingsList<1,1,AC.COUNT>
                    END
    
                CASE productLineId = "DEPOSITS"
    
                    LOCATE "Deposits" IN holdingsTypeSel<1,1> SETTING holdingsPOS THEN
                        holdingsIdSel<1,holdingsPOS,-1>=holdingsList<1,1,AC.COUNT>
                    END ELSE
                        holdingsTypeSel<1,-1>="Deposits"
                        holdingsTypeCount=DCOUNT(holdingsTypeSel,@VM)
                        holdingsIdSel<1,holdingsTypeCount,-1>=holdingsList<1,1,AC.COUNT>
                    END
    
                CASE productLineId = "LENDING"
    
                    LOCATE "Loans" IN holdingsTypeSel<1,1> SETTING holdingsPOS THEN
                        holdingsIdSel<1,holdingsPOS,-1>=holdingsList<1,1,AC.COUNT>
                    END ELSE
                        holdingsTypeSel<1,-1>="Loans"
                        holdingsTypeCount=DCOUNT(holdingsTypeSel,@VM)
                        holdingsIdSel<1,holdingsTypeCount,-1>=holdingsList<1,1,AC.COUNT>
                    END
            END CASE
        NEXT AC.COUNT
    END
    IF customerIdSel THEN
        customerArrangementError = ''
        customerArrangementArray = AA.Framework.CustomerArrangement.Read(customerIdSel, customerArrangementError) ;*Fetch All Related Arrangements -AA.CUSTOMER.ARRANGEMENT
    END
    GOSUB readHoldingsConfig
    IF NOT(holdingsTypeSel) THEN
        holdingsTypeSel = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpHoldingsType>
    END
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Get holdings details for process</desc>
Process:
*--------
*
    IF NOT(holdingsConfigRecord) THEN RETURN
    currentProduct = ''
    currentFilter = ''
    consolidatedArray = ''
    FOR productCounter = 1 TO DCOUNT(holdingsTypeSel, @VM)
        currentProduct = holdingsTypeSel<1,productCounter>
        currentFilter = holdingsIdSel<1,productCounter>
        configPos = '' ; selectionArray = ''  ; configArray = ''  ; callRoutine = '' ; returnArray = ''
        LOCATE currentProduct IN holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpHoldingsType,1> SETTING configPos THEN
            configArray<T2.ModelBank.HoldingsParameter.HpHoldingsType>   = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpHoldingsType,configPos>
            configArray<T2.ModelBank.HoldingsParameter.HpProductLine>    = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpProductLine,configPos>
            configArray<T2.ModelBank.HoldingsParameter.HpProductGroup>   = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpProductGroup,configPos>
            configArray<T2.ModelBank.HoldingsParameter.HpProduct>        = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpProduct,configPos>
            configArray<T2.ModelBank.HoldingsParameter.HpSecurityFilter> = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpSecurityFilter,configPos>
            configArray<T2.ModelBank.HoldingsParameter.HpApiHookRoutine> = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpApiHookRoutine,configPos>
            callRoutine = holdingsConfigRecord<T2.ModelBank.HoldingsParameter.HpApiHookRoutine,configPos>
            routineExists = ''
            routineExistsReturnInfo = ''
            EB.API.CheckRoutineExist(callRoutine,routineExists,routineExistsReturnInfo)
            IF NOT(routineExists) THEN CONTINUE
            selectionArray = customerIdSel:"|":currentProduct:"|":currentFilter:"|":getPreferredHoldingsSel
            
            HoldingsType = ''
            HoldingsType = configArray<T2.ModelBank.HoldingsParameter.HpHoldingsType>
            BEGIN CASE
                CASE HoldingsType = 'Accounts'
                    T2.ModelBank.GetHoldingsAccounts(selectionArray,customerArrangementArray,configArray,returnArray,totalAccountBalances)
                    returnArray:="*":totalAccountBalances:"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*"
                CASE HoldingsType = 'Deposits'
                    T2.ModelBank.GetHoldingsDeposits(selectionArray,customerArrangementArray,configArray,returnArray,totalDepositBalances)
                    returnArray:="*":"*":"*":"*":"*":totalDepositBalances:"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*"
                CASE HoldingsType = 'Loans'
                    T2.ModelBank.GetHoldingsLoans(selectionArray,customerArrangementArray,configArray,returnArray,totalLoanBalances)
                    returnArray:="*":"*":"*":"*":"*":"*":totalLoanBalances:"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*":"*"
                CASE HoldingsType = 'ExternalAccounts'
                    EB.API.ProductIsInCompany("PA", PA.isInstalled) ;* check for AA product availability in company
                    IF PA.isInstalled THEN
                        T2.ModelBank.GetExternalAccounts(selectionArray,customerArrangementArray,configArray,returnArray,totalExtAccountBalances) ;* Get external accounts details
                        returnArray:="*":"*":"*":totalExtAccountBalances
                    END
            END CASE
          
            isReturnArray=FIELD(returnArray,"*",1)
            IF isReturnArray THEN
                consolidatedArray<-1> = returnArray
            END
        END
    NEXT productCounter
    holdingsArray = consolidatedArray
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = readHoldingsConfig>
readHoldingsConfig:
*------------------
*** <desc>Read Holdings Configuration Record</desc>
*
    holdingsConfigRecord = ''
    holdingsConfigError  = ''
*CALL F.READ(fnT2HoldingsParameter, 'SYSTEM', holdingsConfigRecord, fT2HoldingsParameter, holdingsConfigError)
    EB.DataAccess.FRead(fnT2HoldingsParameter,'SYSTEM', holdingsConfigRecord, fT2HoldingsParameter, holdingsConfigError)
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
END
