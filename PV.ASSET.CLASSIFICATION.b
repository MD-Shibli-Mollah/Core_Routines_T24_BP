* @ValidationCode : MjoyMTIxMDM1MzkyOkNwMTI1MjoxNTg0MzUxNjk0NDQ0OmJzYXVyYXZrdW1hcjo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA0LjIwMjAwMzEzLTA2NTE6MTQ3Ojgy
* @ValidationInfo : Timestamp         : 16 Mar 2020 15:11:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/147 (55.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200313-0651
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PV.Config
SUBROUTINE PV.ASSET.CLASSIFICATION (appName, contractId, contractRec, classificationReturned, classificationErr)

*** Routine to return classification of assets for provisioning
* @author jbalaji@temenos.com
* @stereotype fields
* @package PV.Config


* This is an generic API which can be attached to the PV.MANAGEMENT application
* to classify the ASSET for provisioning
*
* This API is an alternate for EB.RULES engine which takes care of asset classification
* for provisioning

* Parameter 1  - appName                - In parameter that should hold the application ID
* Parameter 2  - contractId             - In parameter that should hold the contract ID
* Parameter 3  - contractRec            - In parameter which would hold the contract record
* Parameter 4  - classificationReturned - Out parameter which would carry the contract classification value
* Parameter 5  - classificationErr      - Out parameter which would carry the error if any.
*
* Sample Rule implemented is as follows
*
* 1. STANDARD     classifiction --> If Customer sector = 1000-1999 range, residence = EU or US , MD.DEAL status = CUR
* 2. WATCHLIST    classifiction --> If Customer sector = 1000-1999 range, residence = OTHERS , MD.DEAL status = CUR
* 3. SUB-STANDARD classifiction --> If Customer sector = 1000-1999 range, MD.DEAL status = PDO

*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*  01/10/18 - Enhancement 2751042 / Task 2751058
*             A sample rule logic added for limit classifications.
*
*  04/10/18 - Enhancement 2640022 / Task 2796057
*             Code changes done to use the correct variable customerId
*
*  08/05/19 - Enhancement 3035813 / Task 3118656
*             Code changes to support validation limit provisioning
*
*  16/01/20 - Enhancement 3543337 / Task 3543340
*             BL standard provisioning classification
*
*  19/02/20 - Enhancement 3586254 / Task 3634212
*             Group limit suport for new limit key
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING MD.Contract
    $USING ST.CustomerService
    $USING ST.Customer
    $USING EB.DataAccess
    $USING LI.Config
    $USING BL.Foundation
    $USING EB.API
    
          
    GOSUB initialize ; *
    GOSUB process ; *
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialize>
initialize:
*** <desc> </desc>

    IF NOT(contractRec) THEN
        contractErr = ''
        fnApplication = 'F.':appName
        fApplication = ""
        EB.DataAccess.Opf(fnApplication,fApplication)
        EB.DataAccess.FRead(fnApplication,contractId,contractRec,fApplication,contractErr)
    END

    productID = appName[1,2]
    customerId = ''
    customerRec = ''
    customerSector = ''
    customerResidence = ''
    mdDealStatus = ''
    customerSectorInRange = ''
    mdDealStatus = ''
    mdDealOverDueStatus = ''
    default = 1;
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>

    BEGIN CASE
        CASE productID EQ 'AA'
            
        CASE productID EQ 'AC'
            
        CASE productID EQ 'BL'
            GOSUB CLASSIFY.BL.CONTRACTS
        CASE productID EQ 'LD'
            
        CASE productID EQ 'MM'
            
        CASE productID EQ 'PD'
            
        CASE productID EQ 'SL'
            
        CASE productID EQ 'MD'
            GOSUB CLASSIFY.MD.CONTRACTS ;*
        CASE productID EQ 'LI'
            GOSUB CLASSIFY.LIMITS ; *
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLASSIFY.MD.CONTRACTS>
CLASSIFY.MD.CONTRACTS:
*** <desc> This label will classify the MD contracts according to the rule for provisioning and return the classification</desc>
    customerId = contractRec<MD.Contract.Deal.DeaCustomer>
    IF NOT(customerId) THEN
        RETURN
    END
    mdDealStatus = contractRec<MD.Contract.Deal.DeaStatus>
    mdDealOverDueStatus =  contractRec<MD.Contract.Deal.DeaOverdueStatus>
    
    GOSUB GET.CUSTOMER.DETAILS ; *
    
    IF customerSector GE 1000 AND customerSector LE 1999 THEN
        customerSectorInRange = 'YES'
    END
    
    BEGIN CASE
        CASE customerSectorInRange = 'YES' AND mdDealOverDueStatus = 'PDO'
            classificationReturned = 'SUB-STANDARD'
            
        CASE customerSectorInRange = 'YES' AND (customerResidence = 'EU' OR customerResidence = 'US') AND mdDealStatus = 'CUR'
            classificationReturned = 'STANDARD'
        
        CASE customerSectorInRange = 'YES' AND mdDealStatus = 'CUR'
            classificationReturned = 'WATCHLIST'
       
        CASE default
            classificationReturned = 'STANDARD'
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUSTOMER.DETAILS>
GET.CUSTOMER.DETAILS:
*** <desc> </desc>
* CALL CustomerService.getRecord(customerId, customerRec)
    ST.CustomerService.getRecord(customerId, customerRec)
    IF NOT(customerRec) THEN
        RETURN
    END
    customerSector = customerRec<ST.Customer.Customer.EbCusSector>
    customerResidence = customerRec<ST.Customer.Customer.EbCusResidence>
    customerstatus = customerRec<ST.Customer.Customer.EbCusCustomerStatus>
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLASSIFY.LIMITS>
CLASSIFY.LIMITS:
*** <desc> </desc>

    customerId = contractRec<LI.Config.Limit.LiabilityNumber>
    LiCustomerList = contractRec<LI.Config.Limit.CustomerNumber>
    LiAvailableMrk = contractRec<LI.Config.Limit.AvailableMarker>
    LimitType = contractRec<LI.Config.Limit.LimitType>
    LimitNotes = contractRec<LI.Config.Limit.Notes>
   
    IF customerId EQ "" THEN
        customerId = LiCustomerList<1>
    END
  
    IF NOT(customerId) THEN   ;*
        RETURN
    END

* Read will fail for CUSTOMER.GROUP id which will be there in Liability Number field in limits. Get Liability Number from CUSTOMER.GROUP. For LIMIT.SHARING.GROUP
* customer won't be returned and for old liability structre already Liability Number holds valid customer id. So if limit is part of liability customer group, call
* LI.DETERMINE.LIABILITY.GROUP and get Liability Number from CUSTOMER.GROUP as returned by the API
    
    groupType = ''
    liabilityGroup = ''
    liabilityNumber = ''
    LI.Config.LiDetermineLiabilityGroupType(contractId, contractRec, 'GET.LIABILITY.CUSTOMER', '', '', groupType, liabilityGroup, liabilityNumber, '', '', '', errorDetails)
    IF groupType EQ 'LIABILITY.GROUP' AND liabilityGroup THEN
        customerId = liabilityNumber
    END

    IF customerId THEN
        GOSUB GET.CUSTOMER.DETAILS ; *read the customer details
    END
   
    IF customerSector GE 1000 AND customerSector LE 1999 THEN
        customerSectorInRange = 'YES'
    END
    
    IF contractId[1,2] EQ "LI" AND LimitType THEN ;* For validation limit
        GOSUB CLASSIFY.NEW.STRUCTURE
    END ELSE
        GOSUB CLASSIFY.OLD.STRUCTURE ; * for old structure
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLASSIFY.OLD.STRUCTURE>
CLASSIFY.NEW.STRUCTURE:
*** <desc> </desc>

    IF LimitNotes NE "PROVISION" THEN  ;* Do not classify for any other validation limits
        RETURN
    END
    
    BEGIN CASE
*if customer residence is Europe or america or high net worth client, then return class as standard.
        CASE customerSectorInRange = 'YES' AND ((customerResidence = 'EU' OR customerResidence = 'US') OR (customerstatus EQ "8"))
            classificationReturned = 'STANDARD'
*if status as bankrupt, then return class as doubtful
        CASE customerSectorInRange = 'YES' AND customerstatus EQ "14"
            classificationReturned = 'DOUBTFUL'
*if status as deceased, then return class as writeoff.
        CASE customerSectorInRange = 'YES' AND customerstatus EQ "15"
            classificationReturned = 'WRITEOFF'
*if customer range falls under 1000 to 1999 and residence other than europe or america, then return class as watchlist.
        CASE customerSectorInRange = 'YES'
            classificationReturned = 'WATCHLIST'
*default case
        CASE default
            classificationReturned = 'STANDARD'
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLASSIFY.NEW.STRUCTURE>
CLASSIFY.OLD.STRUCTURE:
*** <desc> </desc>

    BEGIN CASE
*if customer residence is Europe or america or high net worth client, then return class as standard.
        CASE customerSectorInRange = 'YES' AND LiAvailableMrk EQ "Y" AND ((customerResidence = 'EU' OR customerResidence = 'US') OR (customerstatus EQ "8"))
            classificationReturned = 'STANDARD'
*if status as bankrupt, then return class as doubtful
        CASE customerSectorInRange = 'YES' AND LiAvailableMrk EQ "Y" AND customerstatus EQ "14"
            classificationReturned = 'DOUBTFUL'
*if status as deceased, then return class as writeoff.
        CASE customerSectorInRange = 'YES' AND LiAvailableMrk EQ "Y" AND customerstatus EQ "15"
            classificationReturned = 'WRITEOFF'
*if customer range falls under 1000 to 1999 and residence other than europe or america, then return class as watchlist.
        CASE customerSectorInRange = 'YES' AND LiAvailableMrk EQ "Y"
            classificationReturned = 'WATCHLIST'
*default case
        CASE default
            classificationReturned = 'STANDARD'
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLASSIFY.BL.CONTRACTS>
CLASSIFY.BL.CONTRACTS:
*** <desc> This label will classify the BL contracts according to the rule for provisioning and return the classification</desc>
    customerId = contractRec<BL.Foundation.Register.RegLiabCust>
    IF NOT(customerId) THEN
        RETURN
    END
    blRegStatus = contractRec<BL.Foundation.Register.RegSysStatus>
    blRegOverDueStatus =  contractRec<BL.Foundation.Register.RegOverdueStatus>
    
    GOSUB GET.CUSTOMER.DETAILS ; *
    
    IF customerSector GE 1000 AND customerSector LE 1999 THEN
        customerSectorInRange = 'YES'
    END
    
*    startDate = contractRec<BL.Foundation.Register.RegStartDate>
*    currDate = EB.SystemTables.getToday()
*    days = "C"
*    EB.API.Cdd('', startDate, currDate, days)
    
    BEGIN CASE
        CASE customerSectorInRange = 'YES' AND (customerResidence = 'EU' OR customerResidence = 'US') AND blRegStatus = 'CUR' ;*days LT 3
            classificationReturned = 'STANDARD'
        
        CASE customerSectorInRange = 'YES' AND blRegStatus = 'CUR' ;* days LE 5 AND days GE 3
            classificationReturned = 'WATCHLIST'
       
        CASE customerSectorInRange = 'YES' AND blRegOverDueStatus = 'PD'  ;* days LE 8 AND days GT 5
            classificationReturned = 'DOUBTFUL'
       
        CASE customerSectorInRange NE 'YES' ;* AND days GT 8
            classificationReturned = 'LOSS'
        
        CASE default
            classificationReturned = 'STANDARD'
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END


