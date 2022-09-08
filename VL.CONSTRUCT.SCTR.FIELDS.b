* @ValidationCode : MjoxNjY3ODA5MjY4OkNwMTI1MjoxNjA4MTQ2NDEyMDkwOnZlbG11cnVnYW46MjowOjA6MTp0cnVlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6MTc5OjE2OQ==
* @ValidationInfo : Timestamp         : 17 Dec 2020 00:50:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 169/179 (94.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-94</Rating>
*-----------------------------------------------------------------------------
$PACKAGE VL.Config
SUBROUTINE VL.CONSTRUCT.SCTR.FIELDS
*-----------------------------------------------------------------------------
*
* 17/04/14 - 974217
*            AML Nordea changes.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 21/03/18 - Defect 2271161 / Task 2516192 : DISPO.ITEM record is cleared before processing the FCM request during customer Amendment
*
* 27/11/2018 - Enhancement 2822509 / Task 2873287
*              Componentization - II - Payments - fix issues raised during strict compilation mode
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING SC.SctOffMarketTrades
    $USING EB.API
    $USING EB.OverrideProcessing
    $USING VL.Config
    $USING ST.CompanyCreation
    $USING EB.LocalReferences
*
    $INSERT I_AMLService_SctrTxnDetails
    $INSERT I_AMLService_SctrOtherDetails
    $INSERT I_AMLService_SctrOrderingDetails
    $INSERT I_AMLService_SctrIntermediaryDetails
    $INSERT I_AMLService_SctrCustomerAccountDetails
    $INSERT I_AMLService_SctrBeneficiaryDetails
*
    skipFlag = 0
    VL.Config.VlCheckParam(skipFlag)
    IF skipFlag THEN
        RETURN
    END
    
    GOSUB localInitialise
    
    IF EB.SystemTables.getVFunction() EQ 'D' AND NOT(STP.RESPONSE) THEN
        GOSUB READ.DISPO.ITEMS
        GOSUB DELETE.DISPO.ITEMS
        RETURN
    END
    
    IF EB.SystemTables.getVFunction() NE 'I' AND EB.SystemTables.getVFunction() NE 'C' THEN
        RETURN
    END
*
    GOSUB mapOrderingDetails
    GOSUB mapBeneficiaryDetails
    GOSUB mapIntermediaryDetails
    GOSUB mapTxnDetails
    GOSUB mapOtherDetails
    GOSUB mapCustomerAccountDetails
    IF NOT(STP.RESPONSE) THEN
        GOSUB READ.DISPO.ITEMS
        GOSUB DELETE.DISPO.ITEMS
    END
    GOSUB processScreening
*
RETURN
*
localInitialise:
*
    iSctrOrderingDetails = ''
    iSctrBeneficiaryDetails = ''
    iSctrIntermediaryDetails = ''
    iSctrTxnDetails = ''
    iSctrOtherDetails = ''
    iSctrCustomerAccountDetails = ''
    fieldValue = ''
    firstAppId = ''
    CURR.NO = ''
    
* Initiazing variables and call to OPF dispo items record
    R.DISPO.ITEMS = ''
    FN.DISPO.ITEMS = "F.DISPO.ITEMS"
    F.DISPO.ITEMS = ""
    CALL OPF(FN.DISPO.ITEMS,F.DISPO.ITEMS)

    FN.DISPO.ITEMS.NAU = "F.DISPO.ITEMS$NAU"
    F.DISPO.ITEMS.NAU = ""
    CALL OPF(FN.DISPO.ITEMS.NAU,F.DISPO.ITEMS.NAU)
    YERR = ''
*
    STP.RESPONSE = ''
    ERROR.REC = ''
    VL.PARAM.REC = VL.Config.VlParameter.Read("SYSTEM", ERROR.REC)
    STP.RESPONSE = VL.PARAM.REC<VL.Config.VlParameter.VlpStpResponse>
*
RETURN
*
mapOrderingDetails:
*
    jdesc = 'CUSTOMER>SHORT.NAME'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCustomerNo)
    GOSUB getJdescriptorField
    iSctrOrderingDetails<SctrOrderingDetails.customerShortName> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.1'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCustomerNo)
    GOSUB getJdescriptorField
    iSctrOrderingDetails<SctrOrderingDetails.customerName1> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.2'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCustomerNo)
    GOSUB getJdescriptorField
    iSctrOrderingDetails<SctrOrderingDetails.customerName2> = fieldValue
*
RETURN
*
mapBeneficiaryDetails:
*
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankId1> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
*
    jdesc = 'CUSTOMER>SHORT.NAME'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankShortName1> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.1'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.banBankNameOne1> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.2'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankNameTwo1> = fieldValue
*
    jdesc = 'CUSTOMER>STREET'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankStreet1> = fieldValue
*
    jdesc = 'CUSTOMER>ADDRESS'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankAddress1> = fieldValue
*
    jdesc = 'CUSTOMER>TOWN.COUNTRY'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankOne)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankTownCountry1> = fieldValue
*
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankId2> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
*
    jdesc = 'CUSTOMER>SHORT.NAME'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankShortName2> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.1'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.banBankNameOne2> = fieldValue
*
    jdesc = 'CUSTOMER>NAME.2'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankNameTwo2> = fieldValue
*
    jdesc = 'CUSTOMER>STREET'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankStreet2> = fieldValue
*
    jdesc = 'CUSTOMER>ADDRESS'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankAddress2> = fieldValue
*
    jdesc = 'CUSTOMER>TOWN.COUNTRY'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenBankTwo)
    GOSUB getJdescriptorField
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benBankTownCountry2> = fieldValue
*
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benAddress> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenAddress)
    iSctrBeneficiaryDetails<SctrBeneficiaryDetails.benAccount> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrBenAccount)
*
RETURN
*
mapIntermediaryDetails:
*
    iSctrIntermediaryDetails<SctrIntermediaryDetails.intermediaryDets> = ''
*
RETURN
*
mapTxnDetails:
*
    jdesc = 'SECURITY.MASTER>I.S.I.N.'
    firstAppId = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrSecurityNo)
    GOSUB getJdescriptorField
    iSctrTxnDetails<SctrTxnDetails.securityNumber> = fieldValue
*
    iSctrTxnDetails<SctrTxnDetails.noNominal> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrNoNominal)

    iSctrTxnDetails<SctrTxnDetails.grossAmtSecCcy> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrGrossAmtSecCcy)

    iSctrTxnDetails<SctrTxnDetails.charges> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCharges)

    iSctrTxnDetails<SctrTxnDetails.localTax> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrLocalTax)

    iSctrTxnDetails<SctrTxnDetails.cuCommission> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCuCommission)

    iSctrTxnDetails<SctrTxnDetails.cuAccountCcy> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCuAccountCcy)

    iSctrTxnDetails<SctrTxnDetails.custNetAmt> = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrCustNetAmt)

    iSctrTxnDetails<SctrTxnDetails.txnId> = EB.SystemTables.getIdNew()
    
  
*To fetch the local reference field AML.TIMESTAMP for SECURITY TRANSFER
    AML.POS = ''
    tmpLocRef = ''
    LocalRef = ''
    EB.LocalReferences.GetLocRef('SECURITY.TRANSFER','AML.TIMESTAMP',AML.POS)
*Setting R.NEW and sending the time stamp value to the request would be done only when AML.POS is set. If client does not setup for local reference then it will be having null or negative value.
    IF AML.POS NE '' THEN
        tmpLocRef = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrLocalRef)
        tmpLocRef<1,AML.POS> = TIMESTAMP()
        EB.SystemTables.setRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrLocalRef,tmpLocRef)
    
        LocalRef = EB.SystemTables.getRNew(SC.SctOffMarketTrades.SecurityTransfer.ScStrLocalRef)
        iSctrTxnDetails<SctrTxnDetails.dateTimeStamp> = LocalRef<1,AML.POS>
    END
    
*
RETURN
*
mapOtherDetails:
*
    iSctrOtherDetails<SctrOtherDetails.otherDets> = ''
*
RETURN
*
mapCustomerAccountDetails:
*
    iSctrCustomerAccountDetails<SctrCustomerAccountDetails.customerDetails> = ''
    iSctrCustomerAccountDetails<SctrCustomerAccountDetails.accountDetails> = ''
*
RETURN
*
********************************************************************
READ.DISPO.ITEMS:

    TRANSACTION.ID = EB.SystemTables.getIdNew():"*":EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    CALL F.READ(FN.DISPO.ITEMS.NAU, TRANSACTION.ID,R.DISPO.ITEMS,F.DISPO.ITEMS.NAU,YERR)

RETURN

********************************************************************
DELETE.DISPO.ITEMS:

    IF  R.DISPO.ITEMS<EB.OverrideProcessing.DispoItems.DispItmRecordStatus> = 'IHLD' THEN
        CALL F.DELETE(FN.DISPO.ITEMS.NAU,TRANSACTION.ID)    ;*remove the DISPO.ITEMS in IHLD
    END
    
RETURN

********************************************************************
processScreening:
*
    iSctrOrderingDetails = LOWER(iSctrOrderingDetails)
    iSctrBeneficiaryDetails = LOWER(iSctrBeneficiaryDetails)
    iSctrIntermediaryDetails = LOWER(iSctrIntermediaryDetails)
    iSctrTxnDetails = LOWER(iSctrTxnDetails)
    iSctrOtherDetails = LOWER(iSctrOtherDetails)
    iSctrCustomerAccountDetails = LOWER(iSctrCustomerAccountDetails)
*
    CALL AMLService.doSecurityTransferScreening(iSctrOrderingDetails, iSctrBeneficiaryDetails, iSctrIntermediaryDetails, iSctrTxnDetails, iSctrOtherDetails, iSctrCustomerAccountDetails)

    IF STP.RESPONSE THEN
        EB.SystemTables.setText("VL-VL.CONT.SENT.AML.STP")
        VL.Config.VlUpdateStpResponse()
    END ELSE
    
        EB.SystemTables.setText("VL-VL.CONT.SENT.AML")
    
    END

    EB.OverrideProcessing.StoreOverride(CURR.NO)
*
RETURN
*
getJdescriptorField:
*
    fieldValue = ''
    IF firstAppId THEN
        EB.API.GetJdescriptorValues(firstAppId, jdesc)
        fieldValue  = firstAppId
    END
*
RETURN
*
END
