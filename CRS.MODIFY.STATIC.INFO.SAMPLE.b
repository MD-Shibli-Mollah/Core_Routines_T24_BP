* @ValidationCode : MjotNjQ0NDA2MzAwOkNwMTI1MjoxNTY0Mzg0ODMxMTc0OnN2YW1zaWtyaXNobmE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNjEyLTAzMjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Jul 2019 12:50:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CE.CrsReporting
SUBROUTINE CRS.MODIFY.STATIC.INFO.SAMPLE
*-----------------------------------------------------------------------------
*Sample routine to raise override in CUSTOMER and CRS.CUST.SUPP.INFO
*if the static details are getting changed
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 04/07/2019 - En 3220259 / Task 3220672
*              Sample routine to raise override in CUSTOMER and CRS.CUST.SUPP.INFO
*              if the static details are getting changed
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING ST.Customer
    $USING DE.Config
    $USING CD.CustomerIdentification
    $USING EB.OverrideProcessing
    $USING EB.DataAccess
    
    GOSUB Initialise ; *
    GOSUB SelectStaticInfoCopy ; *
    IF keyList ELSE RETURN  ;*If static info copy record doesn't exist, then RETURN
    GOSUB Process ; *

RETURN
*-----------------------------------------------------------------------------
*** <region name= RaiseOverride>
RaiseOverride:
*** <desc> </desc>
    EB.SystemTables.setText("CE-MODIFY.STATIC.INFO")
    EB.OverrideProcessing.StoreOverride('')
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    application = EB.SystemTables.getApplication()
    rOldRec = EB.SystemTables.getDynArrayFromROld()
    rNewRec = EB.SystemTables.getDynArrayFromRNew()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc> </desc>
*Raise override if any of the below mentioned static details are changed for CUSTOMER, DE.ADDRESS and CRS.CUST.SUPP.INFO
    prevYearEnd = EB.SystemTables.getToday()[1,4]-1:1231    ;*previous year ending date
    rdErr = ""
        
    BEGIN CASE
        CASE application EQ "CRS.CUST.SUPP.INFO"
            GOSUB CheckOverrForCCSI ; *
            
        CASE application EQ "CUSTOMER"
            GOSUB CheckOverrForCustomer ; *
            
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckOverrForCCSI>
CheckOverrForCCSI:
*** <desc> </desc>
    BEGIN CASE
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsCustomerType> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsCustomerType>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxIdentityNo> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxIdentityNo>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiIndicia> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiIndicia>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatus> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatus>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportableJurRes> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportableJurRes>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsStatus> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsStatus>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiDateOfBirth> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiDateOfBirth>
            GOSUB RaiseOverride ; *
        CASE rOldRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCtrlgPersonType> NE rNewRec<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCtrlgPersonType>
            GOSUB RaiseOverride ; *
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckOverrForCustomer>
CheckOverrForCustomer:
*** <desc> </desc>
    BEGIN CASE
        CASE rOldRec<ST.Customer.Customer.EbCusNameOne> NE rNewRec<ST.Customer.Customer.EbCusNameOne>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusNameTwo> NE rNewRec<ST.Customer.Customer.EbCusNameTwo>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusShortName> NE rNewRec<ST.Customer.Customer.EbCusShortName>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusStreet> NE rNewRec<ST.Customer.Customer.EbCusStreet>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusAddress> NE rNewRec<ST.Customer.Customer.EbCusAddress>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusTownCountry> NE rNewRec<ST.Customer.Customer.EbCusTownCountry>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusPostCode> NE rNewRec<ST.Customer.Customer.EbCusPostCode>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusCountry> NE rNewRec<ST.Customer.Customer.EbCusCountry>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusSector> NE rNewRec<ST.Customer.Customer.EbCusSector>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusAccountOfficer> NE rNewRec<ST.Customer.Customer.EbCusAccountOfficer>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusIndustry> NE rNewRec<ST.Customer.Customer.EbCusIndustry>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusCustomerStatus> NE rNewRec<ST.Customer.Customer.EbCusCustomerStatus>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusNationality> NE rNewRec<ST.Customer.Customer.EbCusNationality>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusResidence> NE rNewRec<ST.Customer.Customer.EbCusResidence>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusDomicile> NE rNewRec<ST.Customer.Customer.EbCusDomicile>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusCompanyBook> NE rNewRec<ST.Customer.Customer.EbCusCompanyBook>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusResidence> NE rNewRec<ST.Customer.Customer.EbCusResidence>
            GOSUB RaiseOverride ; *
        CASE rOldRec<ST.Customer.Customer.EbCusAddress> NE rNewRec<ST.Customer.Customer.EbCusAddress>
            GOSUB RaiseOverride ; *
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SelectStaticInfoCopy>
SelectStaticInfoCopy:
*** <desc> </desc>
    fnCrsStaticInfoCopy = "F.CRS.STATIC.INFO.COPY"
    fCrsStaticInfoCopy = ""
    EB.DataAccess.Opf(fnCrsStaticInfoCopy, fCrsStaticInfoCopy)  ;*OPF for CRS.STATIC.INFO.COPY    
    selectStatement = 'SELECT ':fnCrsStaticInfoCopy:' WITH @ID LIKE "':"'":EB.SystemTables.getIdNew():".'":'..."'
    selected = ""
    systemReturnCode = ""
    keyList = ""
    EB.DataAccess.Readlist(selectStatement, keyList, "", selected, systemReturnCode)    ;*To check static info copy records exists for the customer
RETURN
*** </region>

END

