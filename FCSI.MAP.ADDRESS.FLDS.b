* @ValidationCode : MjoxMjY1NjE4NjY0OmNwMTI1MjoxNjAzMTEwNjIyNzA3OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Oct 2020 18:00:22
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

$PACKAGE FA.CustomerIdentification
SUBROUTINE FCSI.MAP.ADDRESS.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN1, RES.IN2, MAPPED.FCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the address related fields in FCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming FCSI record
*
* RES.IN1, RES.IN2           (IN)    - Incoming Reserved Arguments
*
* MAPPED.FCSI                (OUT)   - FCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 20/09/20 - Enhancement 3803014 / Task 3952788
* 			 Sample API to map the address related fields in FCSI record
*
*-----------------------------------------------------------------------------
    $USING FA.CustomerIdentification
    $USING RT.BalanceAggregation
    $USING ST.CompanyCreation
    $USING ST.CustomerService
    $USING ST.Customer
    $USING FE.FatcaReporting
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB MAP.FCSI
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.FCSI = CUST.SUPP.REC
    
    ADDR.TYPE = ''
    ADDR.CTRY = ''
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)
    
    FN.FATCA.REP.PARAM = 'F.FATCA.REPORTING.PARAMETER'
    FV.FATCA.REP.PARAM = ''
    R.FATCA.REP.PARAM = ''
    PARAM.ER = ''
    ST.CompanyCreation.EbReadParameter(FN.FATCA.REP.PARAM, 'N', '', R.FATCA.REP.PARAM, '', FV.FATCA.REP.PARAM, PARAM.ER)
    
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddrType> = 'NULL'
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddrCountry> = 'NULL'
    
RETURN
*-----------------------------------------------------------------------------
MAP.FCSI:
    
* Update the AddressType field based on FATCA Reporting Parameter
        
    IF R.FATCA.REP.PARAM<FE.FatcaReporting.FatcaReportingParameter.FrpDefaultAddress> EQ 'DE.ADDRESS' THEN  ;* When Default Address is DE.ADDRESS
        LOCATE 'HOLD.MAIL.INDICIA' IN MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiIndiciaSummary,1> SETTING HmPos THEN  ;* if HOLD.MAIL indicia met
            ADDR.TYPE = 'HOLD.MAIL'  ;* update Address type as 'HOLD.MAIL'
        END ELSE
            ADDR.TYPE = 'PERMANENT'  ;* else update Address type as 'PERMANENT'
        END
        ADDR.CTRY = R.CUSTOMER<ST.Customer.Customer.EbCusAddressCountry>
    END ELSE    ;* When Default Address is CUSTOMER
        IF R.CUSTOMER<ST.Customer.Customer.EbCusAddressPurpose> EQ 'CTICOP' THEN  ;* if AddressPurpose defined in CUSTOMER is 'Communication to In Care Of Party'
            ADDR.TYPE<-1> = 'INCARE' ;* append Address type as 'IN.CARE'
            ADDR.CTRY<-1> = R.CUSTOMER<ST.Customer.Customer.EbCusAddressCountry>
        END
        BEGIN CASE
            CASE R.CUSTOMER<ST.Customer.Customer.EbCusAddressType> EQ 'PBOX'  ;* if Addresstype in CUSTOMER is 'PBOX', append Address type as 'PO.BOX'
                ADDR.TYPE<-1> = 'PO.BOX'
                ADDR.CTRY<-1> = R.CUSTOMER<ST.Customer.Customer.EbCusAddressCountry>
            CASE R.CUSTOMER<ST.Customer.Customer.EbCusAddressType> EQ 'MLTO'  ;* if Addresstype in CUSTOMER is 'MLTO', append Address type as 'MAIL'
                ADDR.TYPE<-1> = 'MAIL'
                ADDR.CTRY<-1> = R.CUSTOMER<ST.Customer.Customer.EbCusAddressCountry>
        END CASE
    END
    IF ADDR.TYPE AND ADDR.CTRY THEN
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddrType> = LOWER(ADDR.TYPE)
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddrCountry> = LOWER(ADDR.CTRY)
    END

RETURN
*-----------------------------------------------------------------------------
END


