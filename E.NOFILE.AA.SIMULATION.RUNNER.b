* @ValidationCode : MjoxMzUzNTI4NTM1OkNwMTI1MjoxNjA0NDA3NzA4NDY5Om5tYXJ1bjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6MTUxOjE0OQ==
* @ValidationInfo : Timestamp         : 03 Nov 2020 18:18:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 149/151 (98.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.NOFILE.AA.SIMULATION.RUNNER(SIM.ARR)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 10/01/2020 -  Defect 3530275 / Task 3525544
*            -  Enquiry to fetch the siumulation runner details
*
* 08/10/2020 - Enhancement : 3930173
*              Task        : 3930176
*              MDAL party changes - Get customer record by calling CustomerProfile API
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $INSERT I_DAS.AA.ARRANGEMENT
    $INSERT I_DAS.AA.ARRANGEMENT.NOTES
    $USING EB.DataAccess
    $USING ST.Customer
    $USING EB.SystemTables
    $USING AA.Account
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING AA.Interest
    $USING AA.TermAmount
    $USING MDLPTY.Party
    
    
    $USING EB.Reports
    $USING AA.Framework
    
*-------------------------------------------------------------------------------------------------------------------------------
    GOSUB INITIALISE ;*Initialise the variables
    GOSUB GET.INPUTS ; *Get the selection fields and values from user
    GOSUB PROCESS ;*Get Arrangement Ids for customer and customer roles
*-----------------------------------------------------------------------------
RETURN
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise all the variables </desc>
    SIM.ARR = ''; CustomerId = ''; CustomerRole = ''; UserActivity = ''; R.SimulationRunner = ''; R.ArrangementSim = ''; R.Product = '';
    R.ProductGroup = ''; simAccountId = ''; simEffectiveIntRate=''; simCommitmentAmount = '';
RETURN
*** </region>
 

*-----------------------------------------------------------------------------

*** <region name= GET.INPUTS>
GET.INPUTS:
*** <desc>Get the selection fields and values from user </desc>
    LOCATE 'CUSTOMER' IN EB.Reports.getDFields()<1> SETTING CUS.POS THEN   ;*Check condition for getting account no
        CustomerId = EB.Reports.getDRangeAndValue()<CUS.POS>
    END

    LOCATE 'CUSTOMER.ROLE' IN EB.Reports.getDFields()<1> SETTING ROL.POS THEN    ;*Check condition for getting List type
        CustomerRole = EB.Reports.getDRangeAndValue()<ROL.POS>
    END

    LOCATE 'U.ACTIVITY' IN EB.Reports.getDFields()<1> SETTING ACT.POS THEN ;*Check condition for getting Transaction count
        UserActivity = EB.Reports.getDRangeAndValue()<ACT.POS>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Get Arrangement Ids for customer and customer roles </desc>
    TABLE.SUFFIX = "$SIM"
    THE.LIST = DAS.AA.ARRANGEMENT$CUSTOMER
    THE.ARGS = CustomerId
    EB.DataAccess.Das('AA.ARRANGEMENT', THE.LIST, THE.ARGS, TABLE.SUFFIX)
    arrangementSimList = THE.LIST
    arrangementSimCount = DCOUNT(arrangementSimList, @FM)
    
    FOR CNT=1 TO arrangementSimCount
        arrangementSimId = '';
        arrangementId = '';
        simulationRunnerId = '';
        simCusPos = '';
        arrSimCustomerRole = '';
        R.ArrangementSim = '';
        arrangementSimId = arrangementSimList<CNT>
        arrangementId = FIELD(arrangementSimId, "%", 1);
        simulationRunnerId = FIELD(arrangementSimId, "%", 2);
        R.ArrangementSim = AA.Framework.ArrangementSim.Read(arrangementId, ER)
        arrSimCustomers = R.ArrangementSim<AA.Framework.ArrangementSim.ArrCustomer>
        LOCATE CustomerId IN arrSimCustomers<1,1> SETTING simCusPos THEN
            arrSimCustomerRole = R.ArrangementSim<AA.Framework.ArrangementSim.ArrCustomerRole,simCusPos>
            IF arrSimCustomerRole EQ CustomerRole THEN
                GOSUB READ.SIMULATION.RUNNER ;*Process simulation runner details
            END
        END
        
    NEXT CNT
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= READ.SIMULATION.RUNNER>
*** <desc>Read simulation runner details </desc>
READ.SIMULATION.RUNNER:
    R.SimulationRunner = '';
    executeSimulation = '';
    runnerUserActivity = '';
    R.SimulationRunner = AA.Framework.SimulationRunner.Read(simulationRunnerId, ERR)
    executeSimulation = R.SimulationRunner<AA.Framework.SimulationRunner.SimExecuteSimulation>
    runnerUserActivity = R.SimulationRunner<AA.Framework.SimulationRunner.SimUActivity>
    IF executeSimulation NE "YES" AND (runnerUserActivity EQ UserActivity OR UserActivity EQ '') THEN
        GOSUB GET.SIMULATION.RUNNER.DETAILS ; *Get the values of simulation details
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SIMULATION.RUNNER.DETAILS>
*** <desc>Get simulation runner details </desc>
GET.SIMULATION.RUNNER.DETAILS:
    arrangementRef = '';
    simCaptureReference = '';
    R.SimCapture = '';
    arrangementRef = R.SimulationRunner<AA.Framework.SimulationRunner.SimArrangementRef>
    simCaptureReference = R.SimulationRunner<AA.Framework.SimulationRunner.SimSimCaptureRef>
    R.SimCapture = AA.Framework.SimulationCapture.Read(simCaptureReference, ER)

*Get Customer Details
    language = EB.SystemTables.getLngg()
    simCustomers = '';
    simCustomerRoles = '';
    simCustomerNames = '';
    simCustomerIds = '';
    simCustomers = R.SimCapture<AA.Framework.SimulationCapture.ArrActCustomer>
    simCustomerCount = DCOUNT(simCustomers, @VM)
    FOR CusCnt=1 TO simCustomerCount
        simCustomerId = simCustomers<1, CusCnt>
        simCustomerIds<1, -1> = simCustomerId
        IF simCustomerId NE '' THEN
            simCustomerName = ''; R.Customer = '';
            SaveEtext = ""
            SaveEtext = EB.SystemTables.getEtext()  ;* Before calling MDAL API, Save EText to restore it later
            EB.SystemTables.setEtext("")  ;* set Error text to Null
            R.Customer = MDLPTY.Party.getCustomerProfile(simCustomerId)
            EB.SystemTables.setEtext(SaveEtext)     ;* Restore the old EText Values
            simCustomerRoles<1, -1> = R.SimCapture<AA.Framework.SimulationCapture.ArrActCustomerRole, CusCnt>
            simCustomerName = R.Customer<MDLPTY.Party.CustomerProfile.customerNames.customerName, language>
            IF NOT(simCustomerName) THEN
                simCustomerNames<1, -1> = R.Customer<MDLPTY.Party.CustomerProfile.customerNames.customerName, 1>
            END ELSE
                simCustomerNames<1, -1> = simCustomerName
            END
        END
    NEXT CusCnt
    

*Read AA.SIM.ACCOUNT property and take alternate account
    
    simArrangementRef = arrangementRef:'///SIM'
    PropertyID = ""
    PropertyClass = "ACCOUNT"
    RAaAccount = ""
    simAccountId = '';
    AA.Framework.GetArrangementConditions(simArrangementRef, PropertyClass, PropertyID, simRunDate, "", RAaAccount, RetError) ;* Get the account record
    RAaAccount = RAISE(RAaAccount)
    simAccountId = RAaAccount<AA.Account.Account.AcAltId, 1>

*Read AA.SIM.INTEREST property and take Effective rate
    PropertyClass = "INTEREST";
    RAaInterest = "";
    simEffectiveIntRate = '';
    AA.Framework.GetArrangementConditions(simArrangementRef, PropertyClass, PropertyID, simRunDate, "", RAaInterest, RetError) ;* Get the account record
    RAaInterest = RAISE(RAaInterest)
    simEffectiveIntRate = RAaInterest<AA.Interest.Interest.IntEffectiveRate>
    
*Read AA.SIM.TERM.AMOUNT property and take amount  - COMMITMENT
    PropertyClass = "TERM.AMOUNT"
    RAaCommitment = ""
    simCommitmentAmount = '';
    AA.Framework.GetArrangementConditions(simArrangementRef, PropertyClass, PropertyID, simRunDate, "", RAaCommitment, RetError) ;* Get the account record
    RAaCommitment = RAISE(RAaCommitment)
    simCommitmentAmount = RAaCommitment<AA.TermAmount.TermAmount.AmtAmount>
    
*simulation capture details
    simDeliveryRef = '';
    simCurrency = '';
    simEffectiveDate = '';
    simDeliveryRef = R.SimCapture<AA.Framework.SimulationCapture.ArrActDeliveryRef>
    simCurrency = R.SimCapture<AA.Framework.SimulationCapture.ArrActCurrency>
    simEffectiveDate = R.SimCapture<AA.Framework.SimulationCapture.ArrActEffectiveDate>
    
*Get Product details
    todayDate = EB.SystemTables.getToday()
    simProductId = '';
    simProductId = R.ArrangementSim<AA.Framework.ArrangementSim.ArrActiveProduct>
    
    R.Product = '';
    simProductDescription = '';
    simProductGroup = '';
    simProductLine = '';
    simDescription = '';
    simEndDate = '';
    simRunDate = '';
    
    R.Product = AA.ProductManagement.Product.CacheRead(simProductId, ER)
    simProductDescription = R.Product<AA.ProductManagement.Product.PdtDescription, language>
    IF NOT(simProductDescription) THEN
        simProductDescription = R.Product<AA.ProductManagement.Product.PdtDescription, 1>
    END
    simProductGroup = R.Product<AA.ProductManagement.Product.PdtProductGroup>
    simProductLine = R.ArrangementSim<AA.Framework.ArrangementSim.ArrProductLine>
    
    simDescription = R.SimulationRunner<AA.Framework.SimulationRunner.SimDescription, language>
    IF NOT(simDescription) THEN
        simDescription = R.SimulationRunner<AA.Framework.SimulationRunner.SimDescription, 1>
    END
    simEndDate = R.SimulationRunner<AA.Framework.SimulationRunner.SimSimEndDate>
    simRunDate = R.SimulationRunner<AA.Framework.SimulationRunner.SimSimRunDate>
*simulation capture activity

    simCaptureActivity = '';
    R.Activity = '';
    simCaptureActivityDes = '';
    simStatus = '';
    simCaptureActivity = R.SimCapture<AA.Framework.SimulationCapture.ArrActActivity>
    R.Activity = AA.ProductFramework.Activity.Read(simCaptureActivity,ER) ;* Read the activity record
    simCaptureActivityDes = R.Activity<AA.ProductFramework.Activity.ActDescription, language>
    IF NOT(simCaptureActivityDes) THEN
        simCaptureActivityDes = R.Activity<AA.ProductFramework.Activity.ActDescription, 1>
    END
    simStatus = R.SimulationRunner<AA.Framework.SimulationRunner.SimStatus>
    
    GOSUB BUILD.FINAL.ARRAY ; *Build the simulation runner details array
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

 
*** <region name= BUILD.FINAL.ARRAY>
BUILD.FINAL.ARRAY:
*** <desc>Build the simulation runner details array </desc>
    SIM.ARR<-1> = simulationRunnerId:"*":arrangementRef:"*":simAccountId:"*":arrangementSimId:"*":simCustomerNames:"*":simCustomerIds:"*":simCustomerRoles:"*":simDeliveryRef:"*":simCurrency:"*":simEffectiveDate:"*":simEffectiveIntRate:"*":simCommitmentAmount:"*":simProductId:"*":simProductDescription:"*":simProductGroup:"*":simProductLine:"*":simDescription:"*":simRunDate:"*":simEndDate:"*":simCaptureActivity:"*":simCaptureActivityDes:"*":simStatus:"*":simCaptureReference
RETURN
*** </region>

*-----------------------------------------------------------------------------
END
