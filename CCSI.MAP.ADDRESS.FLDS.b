* @ValidationCode : MjoyMDcyMTkyODIxOmNwMTI1MjoxNjAzMTA5NTI0ODc2OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Oct 2020 17:42:04
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CD.CustomerIdentification
SUBROUTINE CCSI.MAP.ADDRESS.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN1, RES.IN2, MAPPED.CCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the address related fields in CCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming CCSI record
*
* RES.IN1, RES.IN2           (IN)    - Incoming Reserved Arguments
*
* MAPPED.CCSI                (OUT)   - CCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 20/09/20 - Enhancement 3803014 / Task 3952788
*			 Sample API to map the address related fields in CCSI record
*-----------------------------------------------------------------------------
    $USING CD.CustomerIdentification
    $USING RT.BalanceAggregation
    $USING ST.CompanyCreation
    $USING ST.CustomerService
    $USING ST.Customer
    $USING CE.CrsReporting
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB MAP.CCSI
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.CCSI = CUST.SUPP.REC
    
    CRS.CODE = ''
    ADDR.TYPE = ''
    ADDR.CTRY = ''
    R.CUSTOMER = ''
    
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)
    
    FN.CRS.REP.PARAM = 'F.CRS.REPORTING.PARAMETER'
    FV.CRS.REP.PARAM = ''
    R.CRS.REP.PARAM = ''
    PAR.ERR = ''
    ST.CompanyCreation.EbReadParameter(FN.CRS.REP.PARAM, 'N', '', R.CRS.REP.PARAM, '', FV.CRS.REP.PARAM, PAR.ERR)
    
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddressType> = 'NULL'
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddressCountry> = 'NULL'
    
RETURN
*-----------------------------------------------------------------------------
MAP.CCSI:
    
* Update the AddressType field based on CRS Reporting Parameter
            
    ADDR.TYPE = R.CUSTOMER<ST.Customer.Customer.EbCusAddressType>
    ADDR.CTRY = R.CUSTOMER<ST.Customer.Customer.EbCusAddressCountry>
    
    IF R.CRS.REP.PARAM<CE.CrsReporting.CrsReportingParameter.CrpDefaultAddress> EQ 'DE.ADDRESS' THEN ;* When Default Address is DE.ADDRESS
        CRS.CODE = 'OECD301'         ;* OECD301 - residentialOrBusiness
    END ELSE    ;* When Default Address is CUSTOMER
        BEGIN CASE
            CASE ADDR.TYPE EQ 'HOME'
                CRS.CODE = 'OECD302' ;* OECD302 - residential
            CASE ADDR.TYPE EQ 'BIZZ'
                CRS.CODE = 'OECD303' ;* OECD303 - Business
            CASE ADDR.TYPE EQ 'DLVY' OR ADDR.TYPE EQ 'MLTO' OR ADDR.TYPE EQ 'PBOX' OR ADDR.TYPE EQ 'ADDR'
                CRS.CODE = 'OECD301' ;* OECD301 - residentialOrBusiness
            CASE 1
                CRS.CODE = 'OECD305' ;* OECD305 - unspecified
        END CASE
    END
    
    IF CRS.CODE AND ADDR.CTRY THEN  ;* update the address type only if address country given, since its an associated set
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddressType> = CRS.CODE
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddressCountry> = ADDR.CTRY
    END

RETURN
*-----------------------------------------------------------------------------
END


