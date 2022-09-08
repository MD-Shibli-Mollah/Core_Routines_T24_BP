* @ValidationCode : MjotMTEwNzM2MTc4MTpDcDEyNTI6MTYwODE0NjQxMjA4Mzp2ZWxtdXJ1Z2FuOjI6MDowOjE6dHJ1ZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOjE3ODoxNjg=
* @ValidationInfo : Timestamp         : 17 Dec 2020 00:50:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 168/178 (94.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>4</Rating>
*-----------------------------------------------------------------------------
$PACKAGE VL.Config
SUBROUTINE VL.CONSTRUCT.CUS.FIELDS
**********************************************************************
* Routine to fetch data from r.new and pass the same as input parameter to
* AMLService.doCustomerScreening which will push the event to outside environment.
*
*******************************************************************************************
* 01/07/13 - Task 718137
*            Validation changed to convert @VM and SM to space so that IF can recognize and
*            send the value to Aml engine.
*
* 10/07/13 - Task 724326
*            Data's will be sent to AML watch for screening only if the Fuction is Input.
*
* 28/03/14 - 974217
*            AML Nordea changes.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 07/07/15 - Enhancement 1265068
* 			 Routine incorporated
*
* 10/12/15 - Defect 1547836 / Task 1559520
*          - Multivalue of REL.CUSTOMER & EMPLOYERS.ADD fields from customer record are handled correctly.
*
* 06/01/16 - Defect 1590234 / Task 1590858
*          - Remove duplicate = symbol
*
* 21/03/18 - Defect 2271161 / Task 2516192 : DISPO.ITEM record is cleared before processing the FCM request during customer Amendment
*
* 27/11/2018 - Enhancement 2822509 / Task 2873287
*              Componentization - II - Payments - fix issues raised during strict compilation mode
*************************************************************************************************
    $USING EB.SystemTables
    $USING ST.Customer
    $USING EB.API
    $USING EB.OverrideProcessing
    $USING VL.Config
    $USING ST.CompanyCreation
    $USING EB.LocalReferences
    
    $INSERT I_AMLService_CusTxnDetails

****************************************************************************
    skipFlag = 0
    VL.Config.VlCheckParam(skipFlag)
    IF skipFlag THEN
        RETURN
    END
    
    GOSUB INITIALIZATION
    
    IF EB.SystemTables.getVFunction() EQ 'D' AND NOT(STP.RESPONSE) THEN
        GOSUB READ.DISPO.ITEMS
        GOSUB DELETE.DISPO.ITEMS
        RETURN
    END
    IF EB.SystemTables.getVFunction() NE 'I' AND EB.SystemTables.getVFunction() NE 'C' THEN
        RETURN
    END
  
    GOSUB PROCESS
    IF NOT(STP.RESPONSE) THEN
        GOSUB READ.DISPO.ITEMS
        GOSUB DELETE.DISPO.ITEMS
    END
    GOSUB CALL.SERVICE.RTN.OVERRIDE
    
RETURN
**********************************************************************
INITIALIZATION:
*
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
    
    iCusTxnDetails = ''
    
    STP.RESPONSE = ''
    ERROR.REC = ''
    VL.PARAM.REC = VL.Config.VlParameter.Read("SYSTEM", ERROR.REC)
    STP.RESPONSE = VL.PARAM.REC<VL.Config.VlParameter.VlpStpResponse>
    
RETURN
*
PROCESS:
*
    SHORT.NAME.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)
    CONVERT @VM TO " " IN SHORT.NAME.LIST
    iCusTxnDetails<CusTxnDetails.shortName> = SHORT.NAME.LIST
*
    NAME1.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameOne)
    CONVERT @VM TO " " IN NAME1.LIST
    iCusTxnDetails<CusTxnDetails.name1> = NAME1.LIST
*
    NAME2.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameTwo)
    CONVERT @VM TO " " IN NAME2.LIST
    iCusTxnDetails<CusTxnDetails.name2> = NAME2.LIST
*
    STREET.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusStreet)
    CONVERT @VM TO " " IN STREET.LIST
    iCusTxnDetails<CusTxnDetails.street> = STREET.LIST
*
    TOWN.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTownCountry)
    CONVERT @VM TO " " IN TOWN.LIST
    iCusTxnDetails<CusTxnDetails.townCountry> = TOWN.LIST
*
    POST.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPostCode)
    CONVERT @VM TO " " IN POST.LIST
    iCusTxnDetails<CusTxnDetails.postCode> = POST.LIST
*
    CNTRY.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusCountry)
    CONVERT @VM TO " " IN CNTRY.LIST
    iCusTxnDetails<CusTxnDetails.country> = CNTRY.LIST
*
    iCusTxnDetails<CusTxnDetails.accountOfficer> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusAccountOfficer)
*
    iCusTxnDetails<CusTxnDetails.industry> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusIndustry)
*
    iCusTxnDetails<CusTxnDetails.nationality> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNationality)
*
    iCusTxnDetails<CusTxnDetails.residence> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidence)
*
    iCusTxnDetails<CusTxnDetails.language> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLanguage)
*
    PHN.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPhoneOne)
    CONVERT @VM TO " " IN PHN.LIST
    iCusTxnDetails<CusTxnDetails.phone1> = PHN.LIST
*
    SMS.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusSmsOne)
    CONVERT @VM TO " " IN SMS.LIST
    iCusTxnDetails<CusTxnDetails.sms1> = SMS.LIST
*
    EMAIL.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusEmailOne)
    CONVERT @VM TO " " IN EMAIL.LIST
    iCusTxnDetails<CusTxnDetails.email1> = EMAIL.LIST
*
    iCusTxnDetails<CusTxnDetails.mnemonic> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusMnemonic)
*
    REL.CUST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusRelCustomer)
    CONVERT @VM TO " " IN REL.CUST
    iCusTxnDetails<CusTxnDetails.relCustomer> = REL.CUST
*
    iCusTxnDetails<CusTxnDetails.sector> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusSector)
*
    iCusTxnDetails<CusTxnDetails.target>  = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTarget)
*
    iCusTxnDetails<CusTxnDetails.customerStatus> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusCustomerStatus)
*
    CHNGE.DATE.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusChangeDate)
    CONVERT @VM TO " " IN CHNGE.DATE.LIST
    iCusTxnDetails<CusTxnDetails.changeDate> = CHNGE.DATE.LIST
*
    CHNGE.RSN.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusChangeReason)
    CONVERT @VM TO " " IN CHNGE.RSN.LIST
    iCusTxnDetails<CusTxnDetails.changeReason> = CHNGE.RSN.LIST
*
    iCusTxnDetails<CusTxnDetails.customerSince> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusCustomerSince)
*
    LEGAL.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalId)
    CONVERT @VM TO " " IN LEGAL.LIST
    iCusTxnDetails<CusTxnDetails.legalId> = LEGAL.LIST
*
    LEGAL.DOC.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalDocName)
    CONVERT @VM TO " " IN LEGAL.DOC.LIST
    iCusTxnDetails<CusTxnDetails.legalDocName> = LEGAL.DOC.LIST
*
    LEGAL.HOLDER.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalHolderName)
    CONVERT @VM TO " " IN LEGAL.HOLDER.LIST
    iCusTxnDetails<CusTxnDetails.legalHolderName> = LEGAL.HOLDER.LIST
*
    LEGAL.ISS.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalIssAuth)
    CONVERT @VM TO " " IN LEGAL.ISS.LIST
    iCusTxnDetails<CusTxnDetails.legalIssAuth> = LEGAL.ISS.LIST
*
    LEGAL.ISS.DATE.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalIssDate)
    CONVERT @VM TO " " IN LEGAL.ISS.DATE.LIST
    iCusTxnDetails<CusTxnDetails.legalIssDate> = LEGAL.ISS.DATE.LIST
*
    iCusTxnDetails<CusTxnDetails.noOfDependents> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNoOfDependents)
*
    SPOKEN.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusSpokenLanguage)
    CONVERT @VM TO " " IN SPOKEN.LIST
    iCusTxnDetails<CusTxnDetails.spokenLanguage> = SPOKEN.LIST
*
    JOB.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusJobTitle)
    CONVERT @VM TO " " IN JOB.LIST
    iCusTxnDetails<CusTxnDetails.jobTitle> = JOB.LIST
*
    iCusTxnDetails<CusTxnDetails.introducer> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusIntroducer)
*
    EMP.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusEmployersName)
    CONVERT @VM TO " " IN EMP.LIST
    iCusTxnDetails<CusTxnDetails.employersName> = EMP.LIST
*
    EMP.ADD.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusEmployersAdd)
    CONVERT @VM TO " " IN EMP.ADD.LIST
    CONVERT @SM TO " " IN EMP.ADD.LIST
    iCusTxnDetails<CusTxnDetails.employersAdd> = EMP.ADD.LIST
*
    EMP.BUSS.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusEmployersBuss)
    CONVERT @VM TO " " IN EMP.BUSS.LIST
    iCusTxnDetails<CusTxnDetails.employersBuss> = EMP.BUSS.LIST
*
    RES.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidenceStatus)
    CONVERT @VM TO " " IN RES.LIST
    iCusTxnDetails<CusTxnDetails.residenceStatus> = RES.LIST
*
    RES.TYPE = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidenceType)
    CONVERT @VM TO " " IN RES.TYPE
    iCusTxnDetails<CusTxnDetails.residenceType> = RES.TYPE
*
    RES.SINCE = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidenceSince)
    CONVERT @VM TO " " IN RES.SINCE
    iCusTxnDetails<CusTxnDetails.residenceSince> = RES.SINCE
*
    RES.VALUE = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidenceValue)
    CONVERT @VM TO " " IN RES.VALUE
    iCusTxnDetails<CusTxnDetails.residenceValue> = RES.VALUE
*
    iCusTxnDetails<CusTxnDetails.dateOfBirth> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDateOfBirth)
*
    OTH.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusOtherOfficer)
    CONVERT @VM TO " " IN OTH.LIST
    iCusTxnDetails<CusTxnDetails.otherOfficer> = OTH.LIST
*
    iCusTxnDetails<CusTxnDetails.title> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTitle)
*
    iCusTxnDetails<CusTxnDetails.givenNames> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusGivenNames)
*
    iCusTxnDetails<CusTxnDetails.familyName> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusFamilyName)
*
    iCusTxnDetails<CusTxnDetails.gender> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusGender)
*
    iCusTxnDetails<CusTxnDetails.maritalStatus> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusMaritalStatus)
*
    OCC.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusOccupation)
    CONVERT @VM TO " " IN OCC.LIST
    iCusTxnDetails<CusTxnDetails.occupation> = OCC.LIST
*
    iCusTxnDetails<CusTxnDetails.domicile> = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDomicile)
*
    RAT.LIST = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusCustomerRating)
    CONVERT @VM TO " " IN RAT.LIST
    iCusTxnDetails<CusTxnDetails.customerRating> = RAT.LIST
*
    iCusTxnDetails<CusTxnDetails.id> = EB.SystemTables.getIdNew()
*

    
*To fetch the local reference field AML.TIMESTAMP for Customer
    AML.POS = ''
    tmpLocRef = ''
    LocalRef = ''
    utcDateTime  = ''
    EB.LocalReferences.GetLocRef('CUSTOMER','AML.TIMESTAMP',AML.POS)
*Setting R.NEW and sending the time stamp value to the request would be done only when AML.POS is set. If client does not setup for local reference then it will be having null or negative value.
    IF AML.POS NE '' THEN
        tmpLocRef = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)
        tmpLocRef<1,AML.POS> = TIMESTAMP()
        EB.SystemTables.setRNew(ST.Customer.Customer.EbCusLocalRef,tmpLocRef)
    
        LocalRef = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)
        iCusTxnDetails<CusTxnDetails.dateTimeStamp> = LocalRef<1,AML.POS>
    END

   
    
*   iCusTxnDetails<CusTxnDetails.userDefinedFields> = R.NEW(Local ref field)
*
RETURN
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

CALL.SERVICE.RTN.OVERRIDE:
*
    iCusTxnDetails = LOWER(iCusTxnDetails)

    CALL AMLService.doCustomerScreening(iCusTxnDetails)
*
    IF STP.RESPONSE THEN
        EB.SystemTables.setText("VL-VL.CONT.SENT.AML.STP")
        VL.Config.VlUpdateStpResponse()
    END ELSE
    
        EB.SystemTables.setText("VL-VL.CONT.SENT.AML")
    
    END

    EB.OverrideProcessing.StoreOverride(CURR.NO)
*
RETURN
************************************************************************
END
