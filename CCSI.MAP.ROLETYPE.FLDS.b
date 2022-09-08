* @ValidationCode : MjoyNTc1NTg3MTE6Y3AxMjUyOjE2MDMxMDk1MjY0MDM6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Oct 2020 17:42:06
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
SUBROUTINE CCSI.MAP.ROLETYPE.FLDS(CUSTOMER.ID, CUST.SUPP.REC, CP.RELATION, CP.ROLE, MAPPED.CCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the roletype related fields in CCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming CCSI record
*
* CP.RELATION                (IN)    - Role type Customer's Relation Code
*
* CP.ROLE                    (IN)    - Role type to be given
*
* MAPPED.CCSI                (OUT)   - CCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 20/09/20 - Enhancement 3803014 / Task 3952788
*            Sample API to map the roletype related fields in CCSI record
*-----------------------------------------------------------------------------
    $USING CD.CustomerIdentification
    $USING ST.CustomerService
    $USING ST.Customer
    $USING EB.LocalReferences
    $USING EB.API
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB MAP.CCSI
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.CCSI = CUST.SUPP.REC

    FLD.NO = ''
    ROLE.CNT = 0

* Read main customer record
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)

* Get local ref position of customer
    EB.API.GetStandardSelectionDets('CUSTOMER', SS.REC)
    LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN      ;* get local reference field position of the application
        LOC.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
    END
    
RETURN
*-----------------------------------------------------------------------------
MAP.CCSI:

* Loop through the Relation code and check if it the CP Relation before updating role type fields
    TOT.CNT = DCOUNT(R.CUSTOMER<ST.Customer.Customer.EbCusRelationCode>,@VM)
    FOR CNT = 1 TO TOT.CNT
        IF R.CUSTOMER<ST.Customer.Customer.EbCusRelationCode,CNT> EQ CP.RELATION THEN     ;* update Role type fields only when the Relation is equal to the argument
            ROLE.CNT += 1
            CTRL.CUST = R.CUSTOMER<ST.Customer.Customer.EbCusRelCustomer,CNT>
            R.CTRL.CUST = ''
            ST.CustomerService.getRecord(CTRL.CUST, R.CTRL.CUST)    ;* read Controlling persn's record
         
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRoleType,ROLE.CNT> = CP.ROLE
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,ROLE.CNT> = CTRL.CUST
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerName,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusShortName>
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerReference,ROLE.CNT> = CUSTOMER.ID:'-':ROLE.CNT

* Birth details
            DOB = ''
            DOB = R.CTRL.CUST<ST.Customer.Customer.EbCusBirthIncorpDate>
            IF NOT(DOB) THEN
                DOB = R.CTRL.CUST<ST.Customer.Customer.EbCusDateOfBirth>
            END
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiDateOfBirth,ROLE.CNT> = DOB
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiPlaceOfBirth,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusResidence>

* TIN Details
            FIELD.NAME = 'TIN.CTRY'
            GOSUB GET.LOCAL.FIELD.POS
            IF FLD.NO THEN
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,ROLE.CNT> = R.CTRL.CUST<LOC.REF.POS,FLD.NO,1>  ;* taking first value alone since TIN is single vale field in CCSI
            END ELSE    ;* update residence as tax residence of controlling person when local field not available
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusResidence>
            END
        
            FIELD.NAME = 'TIN.NO'
            GOSUB GET.LOCAL.FIELD.POS
            IF FLD.NO THEN
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,ROLE.CNT> = R.CTRL.CUST<LOC.REF.POS,FLD.NO,1>
            END ELSE    ;* update Tax Id as tax residence of controlling person when local field not available
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusTaxId>
            END

* Address Details
            ADDR.CNT = DCOUNT(R.CTRL.CUST<ST.Customer.Customer.EbCusAddress>,@VM)
            ADDRESS = ''
            FOR AD.CNT = 1 TO ADDR.CNT
                ADDRESS := R.CTRL.CUST<ST.Customer.Customer.EbCusAddress,AD.CNT>
            NEXT AD.CNT
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddress,ROLE.CNT> = ADDRESS
        
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtAddressCountry,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusAddressCountry>
        END
    NEXT CNT
    
    EXISTNG.ROLE.CNT = DCOUNT(MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRoleType>,@VM)
    ROLE.CNT = ROLE.CNT+1
    FOR CNT = ROLE.CNT TO EXISTNG.ROLE.CNT
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRoleType,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerName,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerReference,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiDateOfBirth,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiPlaceOfBirth,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCtrlgPersonType,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddress,CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtAddressCountry,CNT> = 'NULL'
    NEXT CNT
    
RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.FIELD.POS:
    
    FLD.NO = ''
    EB.LocalReferences.GetLocRef('CUSTOMER', FIELD.NAME, FLD.NO)     ;* get local field position
    
RETURN
*-----------------------------------------------------------------------------
END



