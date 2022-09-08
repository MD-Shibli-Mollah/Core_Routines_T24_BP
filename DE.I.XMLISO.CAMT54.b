* @ValidationCode : Mjo3MzQxMDExMTE6Y3AxMjUyOjE2MTY0MjIzMzY3NTU6c3RhbnVzaHJlZToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6MTY3OjE0MA==
* @ValidationInfo : Timestamp         : 22 Mar 2021 19:42:16
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 140/167 (83.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE DE.API
SUBROUTINE DE.I.XMLISO.CAMT54
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 10/02/2021 - Enhancement 4231703 / Task 4231706
*              The CAMT54 XMLISO message is for AC.EXPECTED.RECS based
*              on the given mapping logic the tag values will split, and mapped to the
*              AC.EXPECTED.RECS application record
*
* 15/03/2021 - Enhancement 4231717 / Task 4231719
*              TRANSACTION.REF field in DE.I.HEADER should be populated, when Disposition set to OFS FORMATTED
*-----------------------------------------------------------------------------
    $USING EB.API
    $USING EB.SystemTables
    $USING ER.Contract
    $USING DE.Config
    $USING DE.Inward
    $USING DE.Outward
    $USING EB.Foundation
    $USING EB.Interface
    $USING EB.Versions
    GOSUB initialise ; *Initialise the variables
    IF NOT(SET.REPAIR) THEN
        GOSUB Process
    END
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise the variables </desc>
    TrsnmRec = ''
    TechHeadRec= ''
    BusHeadRec =''
    RawMsgRec = ''
    deiheaderid = DE.Inward.getRKey()
    OriginalMessage = ''
    TxnTag=''
    isInstalled = ''
    SET.REPAIR = ''
    EB.API.ProductIsInCompany("ER", isInstalled)
    IF NOT(isInstalled) THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,"EB-PRODUCT.NOT.INSTALLED":@FM:"ER" )
        GOSUB WRITE.REPAIR
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc> </desc>
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    GOSUB VALIDATE.MESSAGE.TYPE ; *Check the Message Type is Valid
*
    IF NOT(SET.REPAIR) THEN
        TransformedRec = DE.Inward.DeIXmlIsoTransformedMsg.Read(deiheaderid, Error)     ; * Read Concat file DE.I.XMLISO.TRANSFORMED.MSG
        IF TransformedRec THEN
            GOSUB WRITE.AC.EXP.RECS.WITH.TRANSFORM.PAYLOAD ; *
        END ELSE
            DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,"Payload transformation did not happen" )
            GOSUB WRITE.REPAIR
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= WRITE.AC.EXP.RECS.WITH.TRANSFORM.PAYLOAD>
WRITE.AC.EXP.RECS.WITH.TRANSFORM.PAYLOAD:
*** <desc> </desc>
    OriginalMessage=TransformedRec

    REC.EXP<ER.Contract.ExpectedRecs.ExpMessageType> = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    
    SenderBic = FIELD(OriginalMessage,"<SenderBic>",2)
    SenderBic = FIELD(SenderBic,"</SenderBic>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpSenderBic> = SenderBic
    
    TransReference = FIELD(OriginalMessage,"<TransReference>",2)
    TransReference = FIELD(TransReference,"</TransReference>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpTranReference> = TransReference
    
    Reference = FIELD(OriginalMessage,"<Reference>",2)
    Reference = FIELD(Reference,"</Reference>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpReference> = Reference
    
    RelatedReference = FIELD(OriginalMessage,"<RelatedReference>",2)
    RelatedReference = FIELD(RelatedReference,"</RelatedReference>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpRelatedRef> = RelatedReference
    
    AccountID = FIELD(OriginalMessage,"<AccountID>",2)
    AccountID = FIELD(AccountID,"</AccountID>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpAccountId> = AccountID
    
    ValueDate = FIELD(OriginalMessage,"<ValueDate>",2)
    ValueDate = FIELD(ValueDate,"</ValueDate>",1)
    IF ValueDate THEN
        CHANGE '-' TO '' IN ValueDate
    END
    REC.EXP<ER.Contract.ExpectedRecs.ExpValueDate> = ValueDate
    
    Currency = FIELD(OriginalMessage,"<Currency>",2)
    Currency = FIELD(Currency,"</Currency>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpCurrency> = Currency
    
    Amount = FIELD(OriginalMessage,"<Amount>",2)
    Amount = FIELD(Amount,"</Amount>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpAmount> = Amount
    
    CorrespAccount = FIELD(OriginalMessage,"<CorrespAccount>",2)
    CorrespAccount = FIELD(CorrespAccount,"</CorrespAccount>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpCorrespAccount> = CorrespAccount
    
    CurrencyAmount = FIELD(OriginalMessage,"<CurrencyAmount>",2)
    CurrencyAmount = FIELD(CurrencyAmount,"</CurrencyAmount>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpCcyAmount> = CurrencyAmount
    
    OrderingCustomer = FIELD(OriginalMessage,"<OrderingCustomer>",2)
    OrderingCustomer = FIELD(OrderingCustomer,"</OrderingCustomer>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpOrdCustomer> = OrderingCustomer
    
    OrderingInstitution = FIELD(OriginalMessage,"<OrderingInstitution>",2)
    OrderingInstitution = FIELD(OrderingInstitution,"</OrderingInstitution>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpOrdInstitution> = OrderingInstitution
    
    Intermediary = FIELD(OriginalMessage,"<Intermediary>",2)
    Intermediary = FIELD(Intermediary,"</Intermediary>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpIntermediary> = Intermediary
    
    EndToEndReference = FIELD(OriginalMessage,"<EndToEndReference>",2)
    EndToEndReference = FIELD(EndToEndReference,"</EndToEndReference>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpEndToEndRef> = EndToEndReference
    
    OrgCorrespBic = FIELD(OriginalMessage,"<OrgCorrespBic>",2)
    OrgCorrespBic = FIELD(OrgCorrespBic,"</OrgCorrespBic>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpOrgCorrespBic> = OrgCorrespBic
    
    CorrespBic = FIELD(OriginalMessage,"<CorrespBic>",2)
    CorrespBic = FIELD(CorrespBic,"</CorrespBic>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpCorrespBic> = CorrespBic

    FundsType = FIELD(OriginalMessage,"<FundsType>",2)
    FundsType = FIELD(FundsType,"</FundsType>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpFundsType> = FundsType
    
    Method = FIELD(OriginalMessage,"<Method>",2)
    Method = FIELD(Method,"</Method>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpMethod> = Method
    
    ProcessPayments = FIELD(OriginalMessage,"<ProcessPayments>",2)
    ProcessPayments = FIELD(ProcessPayments,"</ProcessPayments>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpProcessPayments> = ProcessPayments
    
    ProcessAvLimit = FIELD(OriginalMessage,"<ProcessAvLimit>",2)
    ProcessAvLimit = FIELD(ProcessAvLimit,"</ProcessAvLimit>",1)
    REC.EXP<ER.Contract.ExpectedRecs.ExpProcessAvLimit> = ProcessAvLimit
    
    DelInRef = DE.Inward.getRKey()
    REC.EXP<ER.Contract.ExpectedRecs.ExpDeliveryInRef> = DelInRef

    GOSUB WRITE.AC.EXPECTED.RECS ; *Write to AC.EXPECTED.RECS after parsing

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= WRITE.AC.EXPECTED.RECS>
WRITE.AC.EXPECTED.RECS:
*** <desc>Write to AC.EXPECTED.RECS after parsing </desc>
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
    OFS.FUNCTION= 'I';* to Initialize function
    OFS.PROCESS = 'PROCESS';* to Initialize process
    OFS.GTS = rVersion<EB.Versions.Version.VerGtsControl>
    NO.OFAUTH = '0';* to Initialize no of auth
    AC.ID = ''
    EB.Foundation.OfsBuildRecord(OFS.APPLICATION.NAME,OFS.FUNCTION, OFS.PROCESS, AC.OFS.VERSION, OFS.GTS, NO.OFAUTH, AC.ID, REC.EXP, OFS.RECORD) ;*form the ofs message for TNBASE record
    CallInfo<1> = OFS.ID
    EB.Interface.OfsCallBulkManager(CallInfo, OFS.RECORD, OfsResponse, txncommitted)
*Update DE.I.HEADER
    GOSUB GET.INFO ;*Get the trans ref, ofs req details id to update DE.I.HEADER
    IF txncommitted EQ 1 THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
        DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, T24.TRANS.REF);* Inward T24 trans ref
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED') ;* Set Disposition field to 'OFS FORMATTED'
        DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef, TransReference) ;* Set TRANSACTION REF field to TransReference tag value
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(deiheaderid,R.HEAD.REC,'')
        EB.SystemTables.setApplication(SAVED.APPLICATION)
    END ELSE
        DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
        DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef, TransReference) ;* Set TRANSACTION REF field to TransReference tag value
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode,FIELD(OfsResponse,'/',4))
        GOSUB WRITE.REPAIR
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
WRITE.REPAIR:
*
* Add key to repair file
*
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, "REPAIR")
    R.REPAIR=DE.Inward.getRKey()
    DE.Outward.UpdateIRepair(R.REPAIR,'')
    SET.REPAIR = '1'
*
RETURN
*-----------------------------------------------------------------------------

*** <region name= VALIDATE.MESSAGE.TYPE>
VALIDATE.MESSAGE.TYPE:
*** <desc>Check the Message Type is Valid </desc>
    IF MSG.ID NE 'CAMT054' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MSG.ID:' in message template CAMT054'
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, MESSAGE.ERROR)
        GOSUB WRITE.REPAIR
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
GET.INFO:
* Get the transaction ref and ofs.req detail id
    T24.TRANS.REF<1,-1> = FIELD(OfsResponse,'/',1) ;* Get the inward trans ref
    OFS.REQ.DET.ID<1,-1> = FIELD(OfsResponse,'/',2)          ;* Get the ofs request detail id

RETURN
*-----------------------------------------------------------------------------
END

