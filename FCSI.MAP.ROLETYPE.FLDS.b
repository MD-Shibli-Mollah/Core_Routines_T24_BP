* @ValidationCode : MjotMjA2NjcyMzY5NjpjcDEyNTI6MTYwMzExMDYyMjk1MzprcmFtYXNocmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjA6LTE6LTE=
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
SUBROUTINE FCSI.MAP.ROLETYPE.FLDS(CUSTOMER.ID, CUST.SUPP.REC, CP.RELATION, CP.ROLE, MAPPED.FCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the roletype related fields in FCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming FCSI record
*
* CP.RELATION                (IN)    - Controlling person Relation Code
*
* CP.ROLE                    (IN)    - Role type to be given
*
* MAPPED.FCSI                (OUT)   - FCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 20/09/20 - Enhancement 3803014 / Task 3952788
* 	         Sample API to map the roletype related fields in FCSI record
*-----------------------------------------------------------------------------
    $USING FA.CustomerIdentification
    $USING ST.CustomerService
    $USING ST.Customer
    $USING EB.LocalReferences
    $USING EB.API
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB MAP.FCSI
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.FCSI = CUST.SUPP.REC
    
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
MAP.FCSI:

* Loop through the Relation code and check if it the CP Relation before updating role type fields
    TOT.CNT = DCOUNT(R.CUSTOMER<ST.Customer.Customer.EbCusRelationCode>,@VM)
    FOR CNT = 1 TO TOT.CNT
        IF R.CUSTOMER<ST.Customer.Customer.EbCusRelationCode,CNT> EQ CP.RELATION THEN
            ROLE.CNT += 1
            CTRL.CUST = R.CUSTOMER<ST.Customer.Customer.EbCusRelCustomer,CNT>
            R.CTRL.CUST = ''
            ST.CustomerService.getRecord(CTRL.CUST, R.CTRL.CUST)
         
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType,ROLE.CNT> = CP.ROLE
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId,ROLE.CNT> = CTRL.CUST
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderRef,ROLE.CNT> = CUSTOMER.ID:'-':ROLE.CNT
            
* Fields in Commented lines are already updated in .PROCESS routine
*           MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderName,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusNameOne>
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiSurName,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusNameTwo>
*           MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAlias,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusNameAlias>
*           MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiNationality,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusNationality>
*           MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiResidence,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusResidence>
*           MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiDomicile,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusDomicile>

* Address Details
            ADDR.CNT = DCOUNT(R.CTRL.CUST<ST.Customer.Customer.EbCusAddress>,@VM)
            ADDRESS = ''
            FOR AD.CNT = 1 TO ADDR.CNT
                ADDRESS := R.CTRL.CUST<ST.Customer.Customer.EbCusAddress,AD.CNT>
            NEXT AD.CNT
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddress,ROLE.CNT> = ADDRESS
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHoldAddrCountry,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusAddressCountry>
            
* TIN Details
            FIELD.NAME = 'TIN.NO'
            GOSUB GET.LOCAL.FIELD.POS
            IF FLD.NO THEN
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderTin,ROLE.CNT> = R.CTRL.CUST<LOC.REF.POS,FLD.NO>
            END ELSE    ;* update Tax Id as tax residence of controlling person when local field not available
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderTin,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusTaxId>
            END
            
            FIELD.NAME = 'TIN.CTRY'
            GOSUB GET.LOCAL.FIELD.POS
            IF FLD.NO THEN
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHoldTinCountry,ROLE.CNT> = R.CTRL.CUST<LOC.REF.POS,FLD.NO>
            END ELSE    ;* update residence as tax residence of controlling person when local field not available
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHoldTinCountry,ROLE.CNT> = R.CTRL.CUST<ST.Customer.Customer.EbCusResidence>
            END

        END
    NEXT CNT
    
    EXISTNG.ROLE.CNT = DCOUNT(MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType>,@VM)
    ROLE.CNT = ROLE.CNT+1
    FOR CNT = ROLE.CNT TO EXISTNG.ROLE.CNT
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiEntTaxClass,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderRef,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderName,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiSurName,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAlias,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiNationality,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiResidence,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiDomicile,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiAddress,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiBirthIncoDate,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiPrcntOwnership,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderTin,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiJoBoStatus,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHoldAddrCountry,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHoldTinCountry,CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiLegalEntityType,CNT> = 'NULL'
    NEXT CNT
    
RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.FIELD.POS:
    
    FLD.NO = ''
    EB.LocalReferences.GetLocRef('CUSTOMER', FIELD.NAME, FLD.NO)     ;* get local field position
    
RETURN
*-----------------------------------------------------------------------------
END


