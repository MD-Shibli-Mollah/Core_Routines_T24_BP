* @ValidationCode : MjotMTU1NDM3MDAzMTpjcDEyNTI6MTU3MzExMTIwNzIzNzptc3NocnV0aGk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 07 Nov 2019 12:50:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : msshruthi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE FE.FatcaReporting
SUBROUTINE FATCA.MODIFY.STATIC.INFO.SAMPLE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 30/10/19 - SI 3184992 / Task 3377652
*            Sample routine to raise override in CUSTOMER and FCSI if the static details are getting
*            changed and update the latest static record of previous year if override approved
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.Customer
    $USING DE.Config
    $USING FA.CustomerIdentification
    $USING EB.OverrideProcessing
    $USING EB.DataAccess
    $USING EB.Interface
*-----------------------------------------------------------------------------
    
    GOSUB Initialise 
    GOSUB CheckStaticInfoCopy 
    IF staticCopyRec ELSE RETURN  ;*If static info copy record doesn't exist, then RETURN
    GOSUB Process ; *

RETURN
*-----------------------------------------------------------------------------
Initialise:

    application = EB.SystemTables.getApplication()
    rOldRec = EB.SystemTables.getDynArrayFromROld()
    rNewRec = EB.SystemTables.getDynArrayFromRNew()
    
RETURN
*-----------------------------------------------------------------------------
CheckStaticInfoCopy:
    
    prevYear = EB.SystemTables.getToday()[1,4]-1    ;* previous year
    staticCopyDateRecId = prevYear:'.STATIC.INFO.COPY' ;* record that maintains the dates on which the report generation is done in a particular year
    staticCopyDateRec = ''
    readEr = ''
    staticCopyDateRec = FE.FatcaReporting.FatcaStaticInfoCopy.CacheRead(staticCopyDateRecId, readEr)
    repDatesCnt = DCOUNT(staticCopyDateRec,'*') ;* to get the latest date on which the report generation is done
    
    staticCopyId = EB.SystemTables.getIdNew():'.':FIELD(staticCopyDateRec,'*',repDatesCnt)
    staticreadEr = ''
    staticCopyRec = ''
    staticCopyRec = FE.FatcaReporting.FatcaStaticInfoCopy.CacheRead(staticCopyId, staticreadEr) ;* get the latest static copy record of the customer in the previous year
    
    staticCopyRecOld = ''
    staticCopyRecOld = staticCopyRec
               
RETURN
*-----------------------------------------------------------------------------
Process:
* Raise override if any of the below mentioned static details are changed for CUSTOMER, DE.ADDRESS and FCSI

    BEGIN CASE
        CASE application EQ 'FATCA.CUSTOMER.SUPPLEMENTARY.INFO'
            GOSUB CheckOverrForFCSI ; *
        CASE application EQ 'CUSTOMER'
            GOSUB CheckOverrForCustomer ; *
    END CASE
    
    IF staticCopyRecOld NE staticCopyRec THEN
        GOSUB RaiseOverride ;* raise override if any of the static fields are amended
    END
    
RETURN
*-----------------------------------------------------------------------------
RaiseOverride:
    
    EB.SystemTables.setText('FE-MODIFY.STATIC.INFO')
    EB.OverrideProcessing.StoreOverride('')

;* Update the static copy record on amendment of CUSTOMER or FCSI only if the override is accepted by giving 'YES'    
    OvrRec = EB.OverrideProcessing.Override.CacheRead('FE-MODIFY.STATIC.INFO', OvrEr)
    Warnings = EB.Interface.getOfsWarnings()
    WarningsCnt = DCOUNT(Warnings<1>,@VM)
    FOR i = 1 TO WarningsCnt
        IF OvrRec<EB.OverrideProcessing.Override.OrMessage> MATCHES Warnings<1,i> THEN
            IF Warnings<2,i> EQ 'YES' THEN
                GOSUB UpdateStaticInfoCopy
            END
            i = WarningsCnt
        END
    NEXT i
            
RETURN
*-----------------------------------------------------------------------------
CheckOverrForFCSI:

    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiClientType> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiClientType> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.ClientType> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiClientType>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxResidence> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxResidence> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.TaxResidence> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxResidence>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.TinCode> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCode>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.TinCountry> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTinCountry>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFatcaStatus> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFatcaStatus> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.FatcaStatus> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFatcaStatus>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiStatusChangeDate> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiStatusChangeDate> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.StatusChangeDate> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiStatusChangeDate>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxDomicile> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxDomicile> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.TaxDomicile> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiTaxDomicile>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCitizenship> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCitizenship> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Citizenship> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCitizenship>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.RcRoleType> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRoleType>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiEntTaxClass> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiEntTaxClass> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.RcEntTaxClass> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiEntTaxClass>
    END
    IF rOldRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId> NE rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.RcCustomerId> = rNewRec<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId>
    END
    
RETURN
*-----------------------------------------------------------------------------
CheckOverrForCustomer:

    IF rOldRec<ST.Customer.Customer.EbCusShortName> NE rNewRec<ST.Customer.Customer.EbCusShortName> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.ShortName> = rNewRec<ST.Customer.Customer.EbCusShortName>
    END
    IF rOldRec<ST.Customer.Customer.EbCusNameOne> NE rNewRec<ST.Customer.Customer.EbCusNameOne> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.NameOne> = rNewRec<ST.Customer.Customer.EbCusNameOne>
    END
    IF rOldRec<ST.Customer.Customer.EbCusNameTwo> NE rNewRec<ST.Customer.Customer.EbCusNameTwo>  THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.NameTwo> = rNewRec<ST.Customer.Customer.EbCusNameTwo>
    END
    IF rOldRec<ST.Customer.Customer.EbCusStreet> NE rNewRec<ST.Customer.Customer.EbCusStreet> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Street> = rNewRec<ST.Customer.Customer.EbCusStreet>
    END
    IF rOldRec<ST.Customer.Customer.EbCusAddress> NE rNewRec<ST.Customer.Customer.EbCusAddress> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Address> = rNewRec<ST.Customer.Customer.EbCusAddress>
    END
    IF rOldRec<ST.Customer.Customer.EbCusTownCountry> NE rNewRec<ST.Customer.Customer.EbCusTownCountry> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.TownCountry> = rNewRec<ST.Customer.Customer.EbCusTownCountry>
    END
    IF rOldRec<ST.Customer.Customer.EbCusPostCode> NE rNewRec<ST.Customer.Customer.EbCusPostCode> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.PostCode> = rNewRec<ST.Customer.Customer.EbCusPostCode>
    END
    IF rOldRec<ST.Customer.Customer.EbCusCountry> NE rNewRec<ST.Customer.Customer.EbCusCountry> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Country> = rNewRec<ST.Customer.Customer.EbCusCountry>
    END
    IF rOldRec<ST.Customer.Customer.EbCusSector> NE rNewRec<ST.Customer.Customer.EbCusSector> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Sector> = rNewRec<ST.Customer.Customer.EbCusSector>
    END
    IF rOldRec<ST.Customer.Customer.EbCusAccountOfficer> NE rNewRec<ST.Customer.Customer.EbCusAccountOfficer> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.AccountOfficer> = rNewRec<ST.Customer.Customer.EbCusAccountOfficer>
    END
    IF rOldRec<ST.Customer.Customer.EbCusIndustry> NE rNewRec<ST.Customer.Customer.EbCusIndustry> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Industry> = rNewRec<ST.Customer.Customer.EbCusIndustry>
    END
    IF rOldRec<ST.Customer.Customer.EbCusNationality> NE rNewRec<ST.Customer.Customer.EbCusNationality> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Nationality> = rNewRec<ST.Customer.Customer.EbCusNationality>
    END
    IF rOldRec<ST.Customer.Customer.EbCusCustomerStatus> NE rNewRec<ST.Customer.Customer.EbCusCustomerStatus> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.CustomerStatus> = rNewRec<ST.Customer.Customer.EbCusCustomerStatus>
    END
    IF rOldRec<ST.Customer.Customer.EbCusResidence> NE rNewRec<ST.Customer.Customer.EbCusResidence> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Residence> = rNewRec<ST.Customer.Customer.EbCusResidence>
    END
    IF rOldRec<ST.Customer.Customer.EbCusDomicile> NE rNewRec<ST.Customer.Customer.EbCusDomicile> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.Domicile> = rNewRec<ST.Customer.Customer.EbCusDomicile>
    END
    IF rOldRec<ST.Customer.Customer.EbCusCompanyBook> NE rNewRec<ST.Customer.Customer.EbCusCompanyBook> THEN
        staticCopyRec<FE.FatcaReporting.FatcaStaticInfoCopy.CompanyBook> = rNewRec<ST.Customer.Customer.EbCusCompanyBook>
    END
    
RETURN
*-----------------------------------------------------------------------------
UpdateStaticInfoCopy:

    FE.FatcaReporting.FatcaStaticInfoCopy.Write(staticCopyId, staticCopyRec)
        
RETURN
*-----------------------------------------------------------------------------
END
