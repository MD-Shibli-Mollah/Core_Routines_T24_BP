* @ValidationCode : MjotODg3MjA5OTgwOmNwMTI1MjoxNjE3MzMyMTA3MTY2OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Apr 2021 08:25:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.CustomerIdentification
SUBROUTINE QI.CHECK.IDENTITY.DOCUMENTS(CUSTOMER.ID, NON.EEA.DOCS, RES.IN1, RES.IN2, US.ADDR.CONFLICT, RES.OUT1, RES.OUT2, RES.OUT3)
*-----------------------------------------------------------------------------
* Sample API to check for Address Conflict in Identity Documents
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* NON.EEA.DOCS               (IN)    - Documents to be excluded when it is issued outside EEA
*
* RES.IN1, RES.IN2           (IN)    - Incoming Reserved Arguments
*
* US.ADDR.CONFLICT           (OUT)   - YES/NULL, US Address Conflict Result
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/12/20 - SI 3436249 / Task 4104932
*            Sample API to check for Address Conflict in Identity Documents
*
* 10/01/21 - SI 3436249 / Task 4159602
*            Check if LEGAL.ISS.CTRY field is found in customer table to process further
*
* 04/02/21 - SI 3436249 / Task 4212317
*            Expiry date retreived from correct mv position
*
* 10/03/21 - Defect 4275520 / Task 4276266
*            1. Return if LEGAL.ISS.CTRY field is not found in customer
*            2. Donot consider the document only when the exp date is crossed.
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING ST.CustomerService
    $USING ST.Customer
    $USING ST.Config
    $USING EB.SystemTables
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    US.ADDR.CONFLICT = ''
    TAX.RESIDENCE = ''
    EEA.COUNTRIES = ''
    LEGAL.EXP.DATE = ''
    LEGAL.ISS.CTRY = ''
    NO.CONFLICT = @FALSE

* Read the customer record to get Tax residence
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)
    TAX.RESIDENCE = R.CUSTOMER<ST.Customer.Customer.EbCusDomicile>

* Get the countries under EEA group
    R.COUNTRY.GRP = ''
    READ.ER = ''
    R.COUNTRY.GRP = ST.Config.CountryGroup.CacheRead('EEA', READ.ER)
    EEA.COUNTRIES = R.COUNTRY.GRP<ST.Config.CountryGroup.EbCgCountry>
    
    CHANGE ',' TO @FM IN NON.EEA.DOCS
    
    SS.REC = ''
    EB.API.GetStandardSelectionDets('CUSTOMER', SS.REC)
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    LEGAL.DOC = R.CUSTOMER<ST.Customer.Customer.EbCusLegalDocName>
    LEGAL.EXP.DATE = R.CUSTOMER<ST.Customer.Customer.EbCusLegalExpDate>

* Get issuing ctry from the field LEGAL.ISS.CTRY
    LOCATE 'LEGAL.ISS.CTRY' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        FLD.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
        LEGAL.ISS.CTRY = R.CUSTOMER<FLD.POS>
    END ELSE    ;* return if legal iss ctry field is not found in SS
        RETURN
    END
    
* Loop through each ID Document and check if issuing country matches tax residence
    TOT.DOC.CNT = DCOUNT(LEGAL.DOC,@VM)
    FOR CNT = 1 TO TOT.DOC.CNT
        COUNTRY.CODE = LEGAL.ISS.CTRY<1,CNT>
        GOSUB GET.FISCAL.JUR
        GOSUB CHECK.EXPIRY
        IF NO.CONFLICT THEN
            CNT = TOT.DOC.CNT + 1       ;* terminate the loop
        END
    NEXT CNT
    
    IF NOT(NO.CONFLICT) THEN
        US.ADDR.CONFLICT = 'YES*Conflict due to ID Documents'
    END
    
RETURN
*-----------------------------------------------------------------------------
CHECK.EXPIRY:

* Check if the document matches the list of Non EEA Docs, since docs issued outside EEA are not considered for Address conflict
    LOCATE LEGAL.DOC<1,CNT> IN NON.EEA.DOCS SETTING POS THEN
        LOCATE FISCAL.JUR IN EEA.COUNTRIES<1,1> SETTING EEA.POS ELSE
            RETURN
        END
    END
    
    IF TAX.RESIDENCE EQ FISCAL.JUR THEN ;* if tax residence matches issuing country
        IF NOT(LEGAL.EXP.DATE<1,CNT>) OR (LEGAL.EXP.DATE<1,CNT> GE EB.SystemTables.getToday()) THEN     ;* if it is not expired
            NO.CONFLICT = @TRUE
        END
    END

RETURN
*-----------------------------------------------------------------------------
GET.FISCAL.JUR:

* Call the API to get fiscal jurisdiction of the country
    FISCAL.JUR = ''
    IF COUNTRY.CODE THEN
        ST.Config.StGetFiscalJurisdiction(COUNTRY.CODE, FISCAL.JUR, '', '')
    END

RETURN
*-----------------------------------------------------------------------------
END
