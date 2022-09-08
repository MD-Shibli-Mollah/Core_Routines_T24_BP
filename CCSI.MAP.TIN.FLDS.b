* @ValidationCode : Mjo3MDA5NzMyODk6Y3AxMjUyOjE2MDc3MDAxMzA5Mzg6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Dec 2020 20:52:10
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CD.CustomerIdentification
SUBROUTINE CCSI.MAP.TIN.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN1, RES.IN2, MAPPED.CCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the TIN related fields in CCSI record
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
*            Sample API to map the TIN related fields in CCSI record
*
* 08/11/20 - Task 4059536
*            Correction in Tax Residence field mapping
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

* Get local ref position of customer
    EB.API.GetStandardSelectionDets('CUSTOMER', SS.REC)
    LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN      ;* get local reference field position of the application
        LOC.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
    END
        
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence> = 'NULL'
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxIdentityNo> = 'NULL'
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTinNotProvidedCode> = 'NULL'
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTinNotProvidedReason> = 'NULL'
    
RETURN
*-----------------------------------------------------------------------------
MAP.CCSI:
    
* Update the TIN field from the local fields in customer
            
    FIELD.NAME = 'TIN.CTRY'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END ELSE    ;* update residence as tax residence when local field not available
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence> = R.CUSTOMER<ST.Customer.Customer.EbCusResidence>
    END
        
    FIELD.NAME = 'TIN.NO'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxIdentityNo> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END ELSE    ;* update Tax Id as tax residence when local field not available
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxIdentityNo> = R.CUSTOMER<ST.Customer.Customer.EbCusTaxId>
    END
        
    FIELD.NAME = 'TIN.NPC'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTinNotProvidedCode> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END
        
    FIELD.NAME = 'TIN.NPR'
    GOSUB GET.LOCAL.FIELD.POS
    IF FLD.NO THEN
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTinNotProvidedReason> = R.CUSTOMER<LOC.REF.POS,FLD.NO>
    END

RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.FIELD.POS:
    
    FLD.NO = ''
    EB.LocalReferences.GetLocRef('CUSTOMER', FIELD.NAME, FLD.NO)     ;* get local field position
    
RETURN
*-----------------------------------------------------------------------------
END
