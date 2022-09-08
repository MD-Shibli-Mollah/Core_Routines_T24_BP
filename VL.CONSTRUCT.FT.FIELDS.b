* @ValidationCode : MjoxOTUxMTMyMDA0OkNwMTI1MjoxNjA4MTQ2NDEyMDc2OnZlbG11cnVnYW46MjowOjA6MTp0cnVlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6Mjg0OjI3Mg==
* @ValidationInfo : Timestamp         : 17 Dec 2020 00:50:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 272/284 (95.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>364</Rating>
*-----------------------------------------------------------------------------
$PACKAGE VL.Config
SUBROUTINE VL.CONSTRUCT.FT.FIELDS
*
**********************************************************************
* Routine to fetch data from r.new and pass the same as input parameter to
* AMLService.doScreening which will push the event to outside environment..
*
**************************************************************************************
* 01/07/13 - Task 718137
*            Validation changed to convert @VM and SM to space so that IF can recognize and
*            send the value to Aml engine.
*
* 10/07/13 - Task 724326
*            Data's will be sent to AML watch for screening only if the Fuction is Input.
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
* 10/12/15 - Defect 1547839 / Task 1559047
*          - Multivalue of LEGAL.ID, ADDRESS fields from customer record and
*          - BK.TO.BK.OUT of FT are handled correctly.
*
* 21/03/18 - Defect 2271161 / Task 2516192 : DISPO.ITEM record is cleared before processing the FCM request during customer Amendment
*
* 27/11/2018 - Enhancement 2822509 / Task 2873287
*              Componentization - II - Payments - fix issues raised during strict compilation mode
******************************************************************************************
*
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.OverrideProcessing
    $USING EB.API
    $USING VL.Config
    $USING ST.CompanyCreation
    $USING EB.LocalReferences
    

    $INSERT I_AMLService_FtBeneficiaryDetails
    $INSERT I_AMLService_FtCustomerAccountDetails
    $INSERT I_AMLService_FtIntermediaryDetails
    $INSERT I_AMLService_FtOrderingDetails
    $INSERT I_AMLService_FtOtherDetails
    $INSERT I_AMLService_FtTxnDetails
*
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

*
INITIALIZATION:

    FIELD.VALUE = ''
    ORD.CUST.LIST = ''
    ORD.BANK.LIST = ''
    ACCT.LIST = ''
    BEN.CUST.LIST = ''
    BEN.BANK.LIST = ''
    INTERMED.BANK.LIST = ''
    SEND.TO.PARTY.LIST = ''
    BK.TO.BK.LIST = ''
    REC.CORR.LIST = ''
    CURR.NO = ''
*
    iFtBeneficiaryDetails = ''
    iFtCustomerAccountDetails = ''
    iFtIntermediaryDetails = ''
    iFtOrderingDetails = ''
    iFtOtherDetails = ''
    iFtTxnDetails = ''

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
    
RETURN
*
PROCESS:
*
    iFtOrderingDetails<FtOrderingDetails.debitAccountNo> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
*
    JDESC = "ACCOUNT>ACCOUNT.TITLE.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.debitAccountName> = FIELD.VALUE
*
    iFtBeneficiaryDetails<FtBeneficiaryDetails.creditAccountNo> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
*
    JDESC = "ACCOUNT>ACCOUNT.TITLE.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.creditAccountName> = FIELD.VALUE
*
    ORD.CUST.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust)
    CONVERT @VM TO " " IN ORD.CUST.LIST
    iFtOrderingDetails<FtOrderingDetails.orderingCustomer> = ORD.CUST.LIST
*
    JDESC = "CUSTOMER>NAME.ADDRESS"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtOrderingDetails<FtOrderingDetails.orderingCustomerName> = FIELD.VALUE
*
    ORD.BANK.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank)
    CONVERT @VM TO " " IN ORD.BANK.LIST
    iFtOrderingDetails<FtOrderingDetails.orderingBankNo> = ORD.BANK.LIST
*
    JDESC = "CUSTOMER>NAME.ADDRESS"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtOrderingDetails<FtOrderingDetails.orderingBankNames> = FIELD.VALUE
*
    ACCT.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
    CONVERT @VM TO " " IN ACCT.LIST
    iFtBeneficiaryDetails<FtBeneficiaryDetails.accountWithBank> = ACCT.LIST
*
    JDESC = "CUSTOMER>NAME.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtBeneficiaryDetails<FtBeneficiaryDetails.accountWithBankName> = FIELD.VALUE
*
    iFtBeneficiaryDetails<FtBeneficiaryDetails.benAccountNo> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
*
    JDESC = "ACCOUNT>ACCOUNT.TITLE.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtBeneficiaryDetails<FtBeneficiaryDetails.benAccountName> = FIELD.VALUE
*
    BEN.CUST.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)
    CONVERT @VM TO " " IN BEN.CUST.LIST
    iFtBeneficiaryDetails<FtBeneficiaryDetails.benCustomerNo> = BEN.CUST.LIST
*
    JDESC = "CUSTOMER>NAME.ADDRESS"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtBeneficiaryDetails<FtBeneficiaryDetails.benCustomerName> = FIELD.VALUE
*
    INTERMED.BANK.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.IntermedBank)
    CONVERT @VM TO " " IN INTERMED.BANK.LIST
    iFtIntermediaryDetails<FtIntermediaryDetails.intermediaryBank> = INTERMED.BANK.LIST
*
    JDESC = "CUSTOMER>NAME.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.IntermedBank)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtIntermediaryDetails<FtIntermediaryDetails.intermediaryBankName> = FIELD.VALUE
*
    iFtBeneficiaryDetails<FtBeneficiaryDetails.accountWithBankAcc> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBankAcc)
*
    JDESC = "CUSTOMER>NAME.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBankAcc)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtBeneficiaryDetails<FtBeneficiaryDetails.accounttWithBankName> = FIELD.VALUE
*
    iFtIntermediaryDetails<FtIntermediaryDetails.intermediaryBankAcc> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.IntermedBankAcc)
*
    JDESC = "CUSTOMER>NAME.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.IntermedBankAcc)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
    iFtIntermediaryDetails<FtIntermediaryDetails.intermdiaryBkAcName> = FIELD.VALUE
*
    iFtOrderingDetails<FtOrderingDetails.orderingCustAcct> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrdCustAcct)
*
    JDESC = "CUSTOMER>NAME.1"
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrdCustAcct)
    FIELD.VALUE = ''
    IF NUM(FIRST.APPLN.ID) THEN
        GOSUB JDESCRIPTOR.FIELD
    END
*
    iFtOrderingDetails<FtOrderingDetails.orderingCustAcName> = FIELD.VALUE
*
    iFtTxnDetails<FtTxnDetails.txnType> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType)
*
    iFtTxnDetails<FtTxnDetails.debitCcy> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCurrency)
*
    iFtTxnDetails<FtTxnDetails.dbtValueDate> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitValueDate)
*
    iFtTxnDetails<FtTxnDetails.creditCcy> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCurrency)
*
    iFtTxnDetails<FtTxnDetails.amtDebited> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AmountDebited)
*
    iFtTxnDetails<FtTxnDetails.amtCredited> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AmountCredited)
*
    iFtOrderingDetails<FtOrderingDetails.orderingCustCode> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrdCustCode)
*
    SEND.TO.PARTY.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.SendToParty)
    CONVERT @VM TO " " IN SEND.TO.PARTY.LIST
    iFtCustomerAccountDetails<FtCustomerAccountDetails.sendToPrty> = SEND.TO.PARTY.LIST
*
    BK.TO.BK.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BkToBkOut)
    CONVERT @VM TO " " IN BK.TO.BK.LIST
    CONVERT @SM TO " " IN BK.TO.BK.LIST
    iFtCustomerAccountDetails<FtCustomerAccountDetails.bankToBankOut> = BK.TO.BK.LIST
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC = "CUSTOMER>ADDRESS"
    GOSUB JDESCRIPTOR.FIELD
    CONVERT @VM TO " " IN FIELD.VALUE
    iFtOrderingDetails<FtOrderingDetails.dbtCustAddress> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC = "CUSTOMER>STREET"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCustStreet> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>TOWN.COUNTRY"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCusTownCon> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>POST.CODE"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCusPostCd> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>COUNTRY"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCusCountry> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>NAME.1"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCusName1> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>NAME.2"
    GOSUB JDESCRIPTOR.FIELD
    iFtOrderingDetails<FtOrderingDetails.dbtCusName2> = FIELD.VALUE

*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCustomer)
    JDESC ="CUSTOMER>LEGAL.ID"
    GOSUB JDESCRIPTOR.FIELD
    CONVERT @VM TO " " IN FIELD.VALUE
    iFtOrderingDetails<FtOrderingDetails.dbtCusLegalId> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>ADDRESS"
    GOSUB JDESCRIPTOR.FIELD
    CONVERT @VM TO " " IN FIELD.VALUE
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerAddress> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC = "CUSTOMER>STREET"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerStreet> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>TOWN.COUNTRY"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerTownCon> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>POST.CODE"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerPosCode> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>COUNTRY"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerCountry> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>NAME.1"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerName1> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>NAME.2"
    GOSUB JDESCRIPTOR.FIELD
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerName2> = FIELD.VALUE
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCustomer)
    JDESC ="CUSTOMER>LEGAL.ID"
    GOSUB JDESCRIPTOR.FIELD
    CONVERT @VM TO " " IN FIELD.VALUE
    iFtBeneficiaryDetails<FtBeneficiaryDetails.credCustomerLegalId> = FIELD.VALUE
*
    iFtTxnDetails<FtTxnDetails.id> = EB.SystemTables.getIdNew()
*
    iFtTxnDetails<FtTxnDetails.inwardPaymentType> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InwardPayType)
*
    FIRST.APPLN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CoCode)
    JDESC ="COMPANY>MNEMONIC"
    GOSUB JDESCRIPTOR.FIELD
    iFtTxnDetails<FtTxnDetails.contCompMnemonic> = FIELD.VALUE
*
    BEN.BANK.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank)
    CONVERT @VM TO " " IN BEN.BANK.LIST
    iFtBeneficiaryDetails<FtBeneficiaryDetails.beneBank> = BEN.BANK.LIST
*
    REC.CORR.LIST = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.RecCorrBank)
    CONVERT @VM TO " " IN REC.CORR.LIST
    iFtIntermediaryDetails<FtIntermediaryDetails.recCorresBank> = REC.CORR.LIST
*
    iFtIntermediaryDetails<FtIntermediaryDetails.recCorresBankAcc> = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.RecCorrBankAcc)
*
*To fetch the local reference field AML.TIMESTAMP for FUND TRANSFER
    AML.POS = ''
    tmpLocRef = ''
    LocalRef = ''
    EB.LocalReferences.GetLocRef('FUNDS.TRANSFER','AML.TIMESTAMP',AML.POS)
*Setting R.NEW and sending the time stamp value to the request would be done only when AML.POS is set. If client does not setup for local reference then it will be having null or negative value.
    IF AML.POS NE '' THEN
        tmpLocRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        tmpLocRef<1,AML.POS> = TIMESTAMP()
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef,tmpLocRef)
    
        LocalRef = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
        iFtTxnDetails<FtTxnDetails.dateTimeStamp> = LocalRef<1,AML.POS>
    END


    
*   iFtOtherDetails<FtOtherDetails.userDefinedFields> = R.NEW(Local ref field)
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
CALL.SERVICE.RTN.OVERRIDE:
*
    iFtOrderingDetails = LOWER(iFtOrderingDetails)
    iFtBeneficiaryDetails = LOWER(iFtBeneficiaryDetails)
    iFtIntermediaryDetails = LOWER(iFtIntermediaryDetails)
    iFtTxnDetails = LOWER(iFtTxnDetails)
    iFtOtherDetails = LOWER(iFtOtherDetails)
    iFtCustomerAccountDetails = LOWER(iFtCustomerAccountDetails)
*
    CALL AMLService.doFundsTransferScreening(iFtOrderingDetails, iFtBeneficiaryDetails, iFtIntermediaryDetails, iFtTxnDetails, iFtOtherDetails, iFtCustomerAccountDetails)
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

JDESCRIPTOR.FIELD:
*
    FIELD.VALUE = ''
    IF FIRST.APPLN.ID THEN
        EB.API.GetJdescriptorValues(FIRST.APPLN.ID,JDESC)
        FIELD.VALUE  = FIRST.APPLN.ID
    END
*
RETURN
END
