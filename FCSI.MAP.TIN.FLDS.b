* @ValidationCode : MjoxMDI2OTk0OTk2OmNwMTI1MjoxNjAzMTEwNjIzMDA1OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Oct 2020 18:00:23
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
SUBROUTINE FCSI.MAP.TIN.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN1, RES.IN2, MAPPED.FCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the TIN related fields in FCSI record
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
*            Sample API to map the TIN related fields in FCSI record
*-----------------------------------------------------------------------------
    $USING CD.CustomerIdentification
    $USING RT.BalanceAggregation
    $USING ST.CompanyCreation
    $USING ST.CustomerService
    $USING ST.Customer
    $USING CE.CrsReporting
    $USING EB.LocalReferences
    $USING EB.SystemTables
    $USING EB.API
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB MAP.FCSI
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.FCSI = CUST.SUPP.REC
    
    CRS.CODE = ''
    ADDR.TYPE = ''
    ADDR.CTRY = ''
    R.CUSTOMER = ''
    
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)

* Get local ref position of customer
    EB.API.GetStandardSelectionDets('CUSTOMER', SS.REC)
    LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN      ;* get local reference field position of the application
        LOC.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
    END
        
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry> = 'NULL'
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode> = 'NULL'
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinNotProvidedCode> = 'NULL'
    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinNotProvidedReason> = 'NULL'
    
RETURN
*-----------------------------------------------------------------------------
MAP.FCSI:
    
* Update the TIN field from the local fields in customer
        
    FIELD.NAME = 'TIN.CTRY'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END ELSE    ;* update residence as tax residence when local field not available
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry> = R.CUSTOMER<ST.Customer.Customer.EbCusResidence>
    END
        
    FIELD.NAME = 'TIN.NO'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END ELSE    ;* update Tax Id as TIN no when local field not available
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode> = R.CUSTOMER<ST.Customer.Customer.EbCusTaxId>
    END
        
    FIELD.NAME = 'TIN.NPC'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinNotProvidedCode> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END
        
    FIELD.NAME = 'TIN.NPR'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinNotProvidedReason> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END

RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.FIELD.POS:
    
    FLD.NO = ''
    EB.LocalReferences.GetLocRef('CUSTOMER', FIELD.NAME, FLD.NO)     ;* get local field position
    
RETURN
*-----------------------------------------------------------------------------
END

