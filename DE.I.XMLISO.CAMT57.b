* @ValidationCode : MjotMTkzMTgxMTI4OkNwMTI1MjoxNjE2ODQ4MTI0MDE1OnNoYXNoaWRoYXJyZWRkeXM6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjIyMzoxOTY=
* @ValidationInfo : Timestamp         : 27 Mar 2021 17:58:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 196/223 (87.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE DE.API
SUBROUTINE DE.I.XMLISO.CAMT57
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*   15/02/21 - Enhancement 4230590 / Task 4230593
*              On receiving CAMT057 XMLISO message, parse and map the
*              tag values to fields of a new AC.EXPECTED.REC application record.
*
* 15/03/2021 -  Defect 4284351 / Task 4230598
*               Populating the Trans Ref filed in De i Hdr, all the business application errors are removed
*               Since those will be handled at the AC,EXPECTED.RECS template level
*
* 19/03/2021 - Defect 4293857 / Task 4296079
*              If Account number / IBAN is passed in AccountId tag, it is just mapped to ACER Account Id field
*              Validation to check if it is a valid Account / IBAN and the conversion from IBAN to account number
*              is already handled in AC.EXPECTED.RECS template validations.
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING AC.Config
    $USING EB.Foundation
    $USING EB.Interface
    $USING EB.SystemTables
    $USING EB.Template
    $USING ER.Config
    $USING ER.Contract
    $USING DE.Config
    $USING DE.Inward
    $USING DE.Outward
    $USING EB.Versions
    $USING EB.API
*
    GOSUB INITIALISE
    IF NOT(SET.REPAIR) THEN
        GOSUB PROCESS
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>INITIALISE the variables </desc>
INITIALISE:
    DeIHeaderKey = DE.Inward.getRKey()
    TransformedRec = ''
    OriginalMsg = ''
    ExitFlag = ''
    isInstalled = ''
    EB.API.ProductIsInCompany("ER", isInstalled)
    IF NOT(isInstalled) THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,"EB-PRODUCT.NOT.INSTALLED":@FM:"ER" )
        GOSUB WRITE.REPAIR
    END ELSE
*
* Read ER.FUNDS.TYPE.PARAM record for ER FUNDS.TYPE
        ErFundsTypeParamRec = ""
        Err = ""
        ErFundsTypeParamRec = ER.Config.ErfundsTypeParam.Read("ER", Err)
        ExcludeCurr = ErFundsTypeParamRec<ER.Config.ErfundsTypeParam.ErFPExcludeCurrencies>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>PROCESSing logic of the rec'd message </desc>
PROCESS:

    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    GOSUB VALIDATE.MESSAGE.TYPE                         ; *Check the Message Type is Valid
    
    TransformedRec = DE.Inward.DeIXmlIsoTransformedMsg.Read(DeIHeaderKey, Error)      ;*Get the transformed payload form DeIXmlIsoTransformedMsg concat file
    IF TransformedRec THEN
        GOSUB PARSE.TRANSFORM.PAYLOAD                ;*Parse message and create AC.EXPECTED.RECS record
    END ELSE
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,"Payload transformation did not happen" )
        GOSUB WRITE.REPAIR
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = PARSE.TRANSFORM.PAYLOAD>
*** <desc>Parse the rec'd meesage </desc>
PARSE.TRANSFORM.PAYLOAD:
    OriginalMsg = TransformedRec
*
*Message Type
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpMessageType> = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
*
*Sender BIC
    SenderBic = FIELD(OriginalMsg,"<SenderBic>",2)
    SenderBic = FIELD(SenderBic,"</SenderBic>",1)
    GOSUB IDENTIFY.THE.SENDER
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpSenderBic> = SenderBic
*
*Reference
    Reference = FIELD(OriginalMsg,"<Reference>",2)
    Reference = FIELD(Reference,"</Reference>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpReference> = Reference
*
*Trans Reference
    TransReference = FIELD(OriginalMsg,"<TransReference>",2)
    TransReference = FIELD(TransReference,"</TransReference>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpTranReference> = TransReference
*
*Related Reference
    RelatedReference = FIELD(OriginalMsg,"<RelatedReference>",2)
    RelatedReference = FIELD(RelatedReference,"</RelatedReference>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpRelatedRef> = RelatedReference

*
*Currency
    Currency = FIELD(OriginalMsg,"<Currency>",2)
    Currency = FIELD(Currency,"</Currency>",1)
    IF Currency THEN
        GOSUB CHECK.CURRENCY.EXCLUSION
    END
    IF ExitFlag THEN
        RETURN
    END
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpCurrency> = Currency
*
*Beneficiary Account ID
    AccountId = FIELD(OriginalMsg,"<AccountID>",2)
    AccountId = FIELD(AccountId,"</AccountID>",1)
    GOSUB CHECK.ACCOUNT
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpAccountId> = AccountId
*
*Value Date
    ValueDate = FIELD(OriginalMsg,"<ValueDate>",2)
    ValueDate = FIELD(ValueDate,"</ValueDate>",1)
    IF ValueDate THEN
        CHANGE '-' TO '' IN ValueDate
    END
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpValueDate> = ValueDate
*
*Amount
    Amount = FIELD(OriginalMsg,"<Amount>",2)
    Amount = FIELD(Amount,"</Amount>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpAmount> = Amount
*
*<Optional fields>
*Ordering Customer
    OrderingCustomer = FIELD(OriginalMsg,"<OrderingCustomer>",2)
    OrderingCustomer = FIELD(OrderingCustomer,"</OrderingCustomer>",1)
    IF OrderingCustomer THEN
        AC.EXP.REC<ER.Contract.ExpectedRecs.ExpOrdCustomer> = OrderingCustomer
    END
*
*Ordering Institution
    OrderingInstitution = FIELD(OriginalMsg,"<OrderingInstitution>",2)
    OrderingInstitution = FIELD(OrderingInstitution,"</OrderingInstitution>",1)
    IF OrderingInstitution THEN
        AC.EXP.REC<ER.Contract.ExpectedRecs.ExpOrdInstitution> = OrderingInstitution
    END
*
*Intermediary
    Intermediary = FIELD(OriginalMsg,"<Intermediary>",2)
    Intermediary = FIELD(Intermediary,"</Intermediary>",1)
    IF Intermediary THEN
        AC.EXP.REC<ER.Contract.ExpectedRecs.ExpIntermediary> = Intermediary
    END
*</Optional Fields>
*
*Correspondent BIC
    CorresBic = FIELD(OriginalMsg,"<CorrespBic>",2)
    CorresBic = FIELD(CorresBic,"</CorrespBic>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpCorrespBic> = CorresBic
    
*Correspondent Account
    CorresAc = FIELD(OriginalMsg,"<CorrespAccount>",2)
    CorresAc = FIELD(CorresAc,"</CorrespAccount>",1)
    IF NOT(CorresAc) THEN            ;*Unable to identify Correspondent Account
        GOSUB GET.CORRESP.ACC
    END
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpCorrespAccount> = CorresAc
    
*End to end reference
    EndToEndReference = FIELD(OriginalMsg,"<EndToEndReference>",2)
    EndToEndReference = FIELD(EndToEndReference,"</EndToEndReference>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpEndToEndRef> = EndToEndReference
    
*Funds Type and Delivery InReference
    FundsType = FIELD(OriginalMsg, "<FundsType>",2)
    FundsType = FIELD(FundsType, "</FundsType>",1)
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpFundsType> = FundsType
    
    DelInRef = DE.Inward.getRKey()
    AC.EXP.REC<ER.Contract.ExpectedRecs.ExpDeliveryInRef> = DelInRef
*
    IF DE.Inward.getRHead(DE.Config.IHeader.HdrDisposition) NE 'REPAIR' THEN
        GOSUB WRITE.AC.EXPECTED.RECS ; *Write to AC.EXPECTED.RECS after parsing
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= WRITE.AC.EXPECTED.RECS>
WRITE.AC.EXPECTED.RECS:
*** <desc>Write to AC.EXPECTED.RECS after parsing </desc>
*
    OFS.RECORD = '';*To Initialize ofs record

    R.DE.MESSAGE = DE.Config.Message.Read(MSG.ID, ER)
    IF ER THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "DE.MESSAGE Record not found")
        GOSUB WRITE.REPAIR
        RETURN
    END
*
    OFS.ID = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource> ;* to Initialize ofs source
    IF OFS.ID = '' THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "OFS.SOURCE field on DE.MESSAGE blank")
        GOSUB WRITE.REPAIR
        RETURN
    END
    EB.Interface.setOfsSourceId(OFS.ID)
*
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(OFS.ID, ER)
    IF ER THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "OFS ID ":OFS.ID:" DOES NOT EXIST IN OFS.SOURCE")
        GOSUB WRITE.REPAIR
        RETURN
    END
    EB.Interface.setOfsSourceRec(R.OFS.SOURCE)
*
    VersionErr = ''
    rVersion = ''
    AC.OFS.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>;* to Initialize ofs version
    rVersion = EB.Versions.Version.CacheRead(AC.OFS.VERSION, VersionErr)
    SAVED.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(AC.OFS.VERSION,",",1))
    OFS.APPLICATION.NAME = FIELD(AC.OFS.VERSION,",",1)
    OFS.FUNCTION ='I';* to Initialize function
    OFS.PROCESS ='PROCESS';* to Initialize process
    OFS.GTS = rVersion<EB.Versions.Version.VerGtsControl>
    NO.OFAUTH ='0';* to Initialize no of auth
    AC.ID =''
    EB.Foundation.OfsBuildRecord(OFS.APPLICATION.NAME,OFS.FUNCTION, OFS.PROCESS, AC.OFS.VERSION, OFS.GTS, NO.OFAUTH, AC.ID, AC.EXP.REC, OFS.RECORD) ;*form the ofs message for TNBASE record
    CallInfo<1> = OFS.ID
    EB.Interface.OfsCallBulkManager(CallInfo, OFS.RECORD, OfsResponse, txncommitted)
    GOSUB GET.INFO ;*Get the trans ref, ofs req details id to update DE.I.HEADER
    IF txncommitted THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
        DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, T24.TRANS.REF);* Inward T24 trans ref
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED') ;* Set Disposition field to 'OFS FORMATTED'
        DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef, TransReference);* Inward trans ref in DE.I.HEADER
    END ELSE
        DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
        DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef, TransReference) ;* Set TRANSACTION REF field to TransReference tag value
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,FIELD(OfsResponse,'/',4))
        GOSUB WRITE.REPAIR
    END
    R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
    DE.Config.IHeaderWrite(deiheaderid,R.HEAD.REC,'')

    EB.SystemTables.setApplication(SAVED.APPLICATION)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = CHECK.ACCOUNT>
CHECK.ACCOUNT:
*** <desc>logic to check account</desc>

* If Account number / IBAN is passed in AccountId tag, it is just mapped to ACER Account Id field
* Validation to check if it is a valid Account / IBAN and the conversion from IBAN to account number
* is already handled in AC.EXPECTED.RECS template validations.

*If Account tag not passed (Account will be defaulted to senders bic from XSLT)or Account passed null, get vostro accuont from senders bic
    IF AccountId EQ '' THEN
*Get the Account
        CustId = SendingCust
        AccountClass = 'VOSTRO'
        GOSUB GET.CUSTOMER.ACCOUNT ;* Get the customer account based on ACCOUNT.CLASS and currency
        AccountId = RequiredAccount
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = VALIDATE.MESSAGE.TYPE>
VALIDATE.MESSAGE.TYPE:
*** <desc>Check the Message Type is Valid </desc>
    IF MSG.ID NE 'CAMT057' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MSG.ID:' in message template CAMT057'
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, MESSAGE.ERROR)
        GOSUB WRITE.REPAIR
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = WRITE.REPAIR>
WRITE.REPAIR:
*** <desc>Add key to repair file</desc>
*
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, "REPAIR")
    R.REPAIR = DE.Inward.getRKey()
    DE.Outward.UpdateIRepair(R.REPAIR,'')
    SET.REPAIR = '1'
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = GET.INFO>
GET.INFO:
*** <desc>Get the transaction ref and ofs.req detail id</desc>
*
    T24.TRANS.REF<1,-1> = FIELD(OfsResponse,'/',1) ;* Get the inward trans ref
    OFS.REQ.DET.ID<1,-1> = FIELD(OfsResponse,'/',2)          ;* Get the ofs request detail id
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = IDENTIFY.THE.SENDER>
IDENTIFY.THE.SENDER:
 
* Check if the sender is a customer
    SendingCust = ''
    CompId = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SenderBic,CompId,SendingCust)
 
* Exclude the 9th char if the senders bic code is of 12 chars.
    IF LEN(SenderBic) = 12 THEN
        SenderBic = SenderBic[1,8]:SenderBic[10,3]
    END
    
RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CURRENCY.EXCLUSION>
CHECK.CURRENCY.EXCLUSION:
*** <desc> Check if the currency is defined for exclusion in ER.FUNDS.TYPE.PARAM </desc>

* Do not form create AC.EXPECTED.RECS if the currency is defined for exclusion
* in ER.FUNDS.TYPE.PARAM
    ExcludedCcyPos = ""
    LOCATE Currency IN ExcludeCurr<1,1> SETTING ExcludedCcyPos THEN
        ExitFlag = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CORRESP.ACC>
GET.CORRESP.ACC:
*** <desc> Get the NOSTRO account defined for the customer </desc>
    IF CorresBic EQ '' THEN
        RETURN
    END
    CorresCust = ''
    DE.API.SwiftBic(CorresBic, CompId, CorresCust)
*Get the corresponding nostro account from correspondic bic
    CustId = CorresCust
    AccountClass = 'NOSTRO'
    GOSUB GET.CUSTOMER.ACCOUNT ;* Get the customer account based on ACCOUNT.CLASS and currency
    CorresAc = RequiredAccount
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUSTOMER.ACCOUNT>
GET.CUSTOMER.ACCOUNT:
*** <desc> Get the customer account based on ACCOUNT.CLASS and currency </desc>

    RequiredAccount = ''
    CustErr = ''
    CustAccounts = ''
    CustAccounts = AC.AccountOpening.CustomerAccount.Read(CustId, CustErr)
    CustAccountsCnt = DCOUNT(CustAccounts, @FM)

    FOR AcPos = 1 TO CustAccountsCnt
        CurrAc = CustAccounts<AcPos>
        AccErr = ''
        CustAcRec = ''
        CustAcRec = AC.AccountOpening.Account.Read(CurrAc, Error)
        CurrAcCurr = CustAcRec<AC.AccountOpening.Account.Currency>
    
        IF CurrAcCurr NE Currency THEN
            CONTINUE
        END
    
        CurrAcCateg = CustAcRec<AC.AccountOpening.Account.Category>
        ClassReturn = ''
        AC.Config.CheckAccountClass(AccountClass, CurrAcCateg, CustId, '', ClassReturn)
    
        IF ClassReturn NE 'YES' THEN
            CONTINUE
        END
    
        RequiredAccount = CurrAc
        AcPos = CustAccountsCnt
    
    NEXT AcPos
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

