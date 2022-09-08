* @ValidationCode : Mjo0Nzc1NzMwMTA6Y3AxMjUyOjE1NTg0MzYxNjc2NDQ6Y21hbml2YW5uYW46NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNS4wOjU4Njo0MDg=
* @ValidationInfo : Timestamp         : 21 May 2019 16:26:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : cmanivannan
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 408/586 (69.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201905.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-314</Rating>
$PACKAGE FT.Delivery
SUBROUTINE DE.I.MT101
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*                                                                       *
*   MODIFICATIONS                                                       *
*                                                                       *
* 10/07/02 -  EN_10000786                                              *
*            New Program                                                *
*                                                                       *
* 11/11/02 - BG_100002334
*            When there is an optional field in the repeating sequence
*            and if the optional field is present in the first sequence
*            and not present in subsequent ones, then the value of the
*            optional field gets carried over to the subsequent sequences.
*
* 25/11/02 - CI_10005070
*            Default credit ccy to debit ccy only if credit account
*            is not obtained.
* 20/12/02 - CI_10005680
*            IN2.ALLACCVAL routine is called to validate the inward
*            account number(it may be alternatic account or mnemonic)
*
* 26/12/02 - CI_10005670
*            Special characters enclosed in double quotes before
*            passing to R.OFS.DATA in the PROCESS.DEFAULT.FILEDS para
*
* 27/12/02 - CI-10005888
*            The incoming tag 32B should be mapped to Credit leg . Credit
*            currency is always mandatory and hence remove the changes
*            related to CI-10005070 .
*
* 22/01/03 - CI_10006340
*            Ordering Bank should be populated only from tag 52.

* 05/02/02  - CI_10006679
*            ACCT WITH BANK is not populated from ACCT.WITH.BK if the
*            repetitive seq 1 contains 57D & sequence 2 contains 57A.

* 17/02/03 - CI_10006857
*            Branch to CHECK.IF.AC.TYPE.FT only for Non OT transactions.

* 03/03/03 - EN_10001649
*              Map the sender of Incoming message to INW.SEND.BIC field of FT.
*              The sender is indentified from the FROM.ADDRESS of DE.I.HEADER.
*
* 20/03/03 - EN_10001661
*            101 message should be processed only if sender has an netting
*            agreement with us. Moreover all the Ordering customers /bank
*            of the incoming message should also have Netting agreement
*            with the Sender.
*
* 30/04/03 - CI_10008703
*            If tag 30 has back value date in the inward  MT101 message,
*            the same has to be updated in the FT fields DEBIT.VALUE.DATE,
*            CREDIT.VALUE.DATE and PROCESSING.DATE should be TODAY.
*
*
* 07/03/07 - BG_100013209
*            CODE.REVIEW changes.
*
* 5/01/10  - 13285
*            When there is an optional field say 23E in the repeating sequence
*            and if the optional field is present in the first sequence
*            and not present in subsequent ones, then the value of the
*            optional field should not carried over to the subsequent sequences.
*
* 03/06/10 - Task 51844
*            Ref : HD1009212/50460
*            Added quotes to the CUS.NAME, since if bank name contains comma at
*            the end and in addition system amends another comma as separator, the msg consists
*            of two consequent field markers. Hence while processing this thru OFS.REQUEST.MANAGER
*            system considers this null b/w two conseqent field markers as end of the msg and
*            fails to process the subsequent values.
*
* 17/05/10 - Task 27812 / Defect 25860
*            Added additional fields to DE.I.HEADER to store the header, trailer, inward transaction ref
*            and ofs request deatils id information.
*
* 29/06/10 - 61100
*            Ref : 60695
*            Inward swift message(IN.SWIFT.MSG) is not getting updated.
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 31/01/11 - Task 126521
*           Change the call to service operation exists to checkExists.
*
*
* 21/03/11 - CI_10072848
*            Ref : 171868
*            MT102 Inward  swift message  system does not generate multiple FTs.
*            It always create a FT with last set of details in the swift message.
*            Fix is OFS.GLOBUS.MANAGER replaced with OFS.POST.MESSAGE which processes
*            each transaction separately.
*
* 09/01/13 - Task 556879
*            In OFS Message comma(,) is considered as a delimiter between the field value , So if CUS.NAME
*            contains comma then it converted in to "?". Reverting the fix done in Task 51844.
*
* 14/08/14 - Task 1071228
*          - Enhancement 1045764
*          - The sender to check netting agreement should contain both customer number and BIC code to facilate
*          - checking netting agreement id with BIC code if customer is not present for sender
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 10/07/15 - Enhancement 1309269 / Task 1371288
*            SWIFT 2015 - Payment message changes
*            Changes to be included for TAG59F Changes.
*
* 17/08/15 - Enhancement 1265068/ Task 1387507
*          - Routine incorporated
*
* 07/02/18 - Enhancement 2449690 / Task 2449712
*            When TPS is defined in DE parameter, processing will be routed via TPH.
*
* 25/05/18 - Enhancement 2583024 / Task 2593417
*            1. Populate UETR reference to the field IN.HDR.3.UETR of FT
*            2. update concat file DE.UETR.REF.FILE
*
* 30/07/18 : Defect 2690742 / Task 2698874
*            Create FT ID only if FT is installed
*
* 06/12/18 - Defect 2879838 / Task 2890793
*            For multiple payment messages, FTs generated appropriately.
*
* 21/12/18 - Defect 2908507  / Task 2911319
*            Removed FT.GENERATE.ID call, inorder to avoid generate ID for OFS Message .Since FT configured for Auto generate ID.
*            Removed the DeGenerateUetr call, Since its try write DE.UETR.REF.FILE against FT id generated by FT.GENERATE.ID call.
*
* 14/05/19 - Enhancement 3112589 / Task 3112595
*            Pass the Delivery Reference value, update the reference in DE.UETR.CATALOG
*            for the respective transaction.
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING DE.Inward
    $USING EB.DataAccess
    $USING DE.API
    $USING EB.Interface
    $USING EB.API
    $USING AC.Config
    $USING DE.Outward
    $USING DE.ModelBank
    $USING DE.Messaging
    $USING EB.SystemTables
    $USING EB.Delivery

    $INSERT I_CustomerService_NameAddress
    $INSERT I_CustomerService_Exists

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE

* Message Header Processing

    GOSUB VALIDATE.MESSAGE.TYPE
    
* Check for the payment system in parameter
    GOSUB CHECK.FOR.TPH.TRIGGER
 
* If the company has PP installed, then route the processing via TPH
* Set Transref as Payment details received from TPH routine
* Set Disposition as OFS FORMATTED and no further processing done
    IF CompanyHasProduct AND CompiledOrNot THEN
        iQueueName = DE.Inward.getCarrierId()
        iHeadTrail = DE.Inward.getRHead(DE.Config.IHeader.HdrInwHeadTrail)
        iQueueMsg = R.DE.I.MSG
        oRecvMsgResponse = ''
        CALL PP.OFS.SWIFT.ACCEPT.MAP(iQueueName, iHeadTrail, iQueueMsg, oPaymentDetails, oRecvMsgResponse)
        DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef, oPaymentDetails)
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED')
        REC.ID = DE.Inward.getRKey()
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')
* Update the DE.UETR.REF.FILE and DE.UETR.CATALOG record.
        UETR.REF = ''
        UETR.REF = DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference)
        IF oPaymentDetails AND UETR.REF THEN
            DE.API.DeGenerateUetr(oPaymentDetails, "IN", '', UETR.REF, REC.ID, '')
        END
        RETURN
    END

    IF ERROR.COUNT GT 1 THEN
* If error, no further processing
        GOSUB STORE.THE.MESSAGE
        GOSUB CALL.OFS.GLOBUS.MANAGER
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED');*  BG_100013209  - S
        REC.ID = DE.Inward.getRKey()
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

        EB.SystemTables.setApplication(TEMP.APPLICATION)

        RETURN      ;* From main program;* BG_100013209 - E
    END

    GOSUB IDENTIFY.THE.SENDER


* Generic Body Processing



    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)

* EN_10001661 S

* Check for Netting.

    GOSUB CHECK.NETTING.AGREEMENT
    IF NET.ERROR THEN
        RETURN      ;* BG_100013209 - S
    END   ;* BG_100013209 - E

* EN_10001661 E





* Method 2 - To generate multiple application records with the same core data and changing sequence data (use this OR method 1)

    TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
    TAG.VAL.COUNT = MAXIMUM.REPEATS<1>

    FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT

        TAG.SUB.COUNT = 0

        FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT

            GOSUB PROCESS.REPITITIVE.FIELDS       ;* BG_100013209 - S / E

        NEXT TAG.FIELD.NO

        FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT

            FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT

                GOSUB PROCESS.CORE.DATA ;* BG_100013209 - S / E

            NEXT TAG.FIELD.NO

            GOSUB ADD.NON.TAG.FIELDS    ;* Specific Application Record Processing
            IF MESSAGE.ERROR THEN
                GOSUB STORE.TAG.ERRORS  ;* Store the errors
                R.OFS.DATA := TAG.ERROR.DATA
            END
        
* To generate appropriate no of FTs for multiple payment messages
            OFS.PREFIX = K.VERSION:"/I,,,"
    
            GOSUB CALL.OFS.GLOBUS.MANAGER
            R.OFS.DATA = ''
            MESSAGE.ERROR = ''
            TAG.ERROR.DATA = ''
            SEQ.B.DR.ACCT = ''          ;* will be obtained for tags in repetitive sequence
            SEQ.B.ORD.CUST.OFS.DATA = ''
            DEBIT.CURRENCY = ''
            CREDIT.CURRENCY = ''
        NEXT TAG.SUB.NO




    NEXT TAG.VAL.NO

* End of Method 2

* Further methods may be added here if a specific message-transaction scenarios require them

STOP.THE.PROCESS:

    DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
    DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, T24.TRANS.REF);* Inward T24 trans ref
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED')
    REC.ID = DE.Inward.getRKey()
    R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
    DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

    EB.SystemTables.setApplication(TEMP.APPLICATION)

RETURN          ;* From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

VALIDATE.MESSAGE.TYPE:

* Check if the message is valid type and retrieve message format information

    MESSAGE.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    IF MESSAGE.TYPE NE '101' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT101'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('101.1.1', READ.ERROR)

    IF READ.ERROR THEN
        MESSAGE.ERROR = 'Message not found in DE.FORMAT.SWIFT FILE'
        GOSUB HOLD.ON.ERROR
    END

RETURN

*************************************************************************
CHECK.FOR.TPH.TRIGGER:
*
* Check for the payment system in DE.PARM
  
    ParmErr = ''
    DeParmRec = ''
    DeParmRec = DE.Config.Parm.Read("SYSTEM.STATUS", ParmErr)
    PymtSys = DeParmRec<DE.Config.Parm.ParPaymentSystem>
    
    BEGIN CASE
        
        CASE PymtSys EQ "TPS"
            GOSUB CHECK.FOR.PP
                    
        CASE 1
            NULL
        
    END CASE
    
RETURN

*************************************************************************
CHECK.FOR.PP:
*
* If TPS is defined in DE.PARM then check for PP installation and
* route the processing via TPH

    ProductCode<1> = "PP"
    ProductCode<2> = DE.Inward.getRHead(DE.Config.IHeader.HdrCompanyCode)
    ValidProduct = ''
    ProductInstalled = ''
    CompanyHasProduct = ''
    ErrorText = ''
    PrgName = "PP.OFS.SWIFT.ACCEPT.MAP"
    CompiledOrNot = '0'
    ReturnInfo = ''
 
* To check the routine exists or not
    EB.API.CheckRoutineExist(PrgName, CompiledOrNot, ReturnInfo)
    
    EB.Delivery.ValProduct(ProductCode, ValidProduct, ProductInstalled, CompanyHasProduct, ErrorText)
    
RETURN

*************************************************************************
STORE.THE.MESSAGE:

* Store the inward message in the application.

    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'IN.SWIFT.MSG=':IN.DEL.KEY:','  ;* Store delivery ref

    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'IN.SWIFT.MSG=':IN.MSG.TYPE:',' ;* Store the message type

    FOR X = 1 TO MSG.FIELD.COUNT-1
        R.OFS.DATA := 'IN.SWIFT.MSG:':X:':="':IN.STORE.MSG<X>:'",'
* Store the message
    NEXT X

* Update Telex  from customer .
    IF SAVE.SENDING.CUSTOMER THEN
        customerKey = SAVE.SENDING.CUSTOMER
        customerNameAddress = ''
        prefLang = EB.SystemTables.getLngg()
        
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        CUS.NAME = customerNameAddress<NameAddress.shortName>
* In OFS Message comma(,) is considered as a delimiter between the field value , So comma in
* the CUS.NAME converted in to "?".
        IF EB.SystemTables.getEtext() = "" THEN
            CONVERT ',' TO '?' IN CUS.NAME
            R.OFS.DATA := 'TELEX.FROM.CUST=':CUS.NAME:','
        END ELSE
            R.OFS.DATA := 'TELEX.FROM.CUST=':SAVE.SENDING.CUSTOMER:','
        END
    END

* EN_10001649 S

    R.OFS.DATA := 'INW.SEND.BIC=':DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress):','

* EN_10001649 E

RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer
* EN_10001649 S

* Entire full address should be mapped as SENDERS.BIC.CODE.
*  SENDERS.BIC.CODE = SUBSTRINGS(R.HEAD(DE.HDR.FROM.ADDRESS),1,11)
    SENDERS.BIC.CODE = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)
*
* EN_10001649 E



    SAVE.SENDING.CUSTOMER = ''
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)
    SAVE.SENDING.CUSTOMER = SENDING.CUSTOMER      ;* May use later

RETURN

*************************************************************************

***********************************************************
HOLD.ON.ERROR:

* Processing when an error is found in the message.

    R.OFS.DATA := 'IN.PROCESS.ERR:':ERROR.COUNT:'="':MESSAGE.ERROR:'",'

    ERROR.COUNT = ERROR.COUNT + 1

    MESSAGE.ERROR = ''

RETURN

*************************************************************************
STORE.TAG.ERRORS:

* Format all the tag errors captured in variable 'MESSAGE.ERROR' with the
* field name and VM and store in variable 'TAG.ERROR.DATA'.
*
* Note:  The contents of TAG.ERROR.DATA and NO.OF.TAG.ERRORS will be re-used
* when there are any erros from OFS.  So, do not reset the variables.

    NO.OF.TAG.ERRORS = DCOUNT(MESSAGE.ERROR, @FM)

    FOR CNT = 1 TO NO.OF.TAG.ERRORS
        TAG.ERROR.DATA := 'IN.PROCESS.ERR:':CNT:'="':MESSAGE.ERROR<CNT>:'",'
    NEXT CNT

RETURN
*************************************************************************
CALL.OFS.GLOBUS.MANAGER:

    R.OFS.DATA = OFS.PREFIX:R.OFS.DATA
    UETR.REF = DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference)
    IF UETR.REF THEN
        R.OFS.DATA := 'IN.HDR.3.UETR=':UETR.REF:','
    END
    
    EB.Interface.OfsPostMessage(R.OFS.DATA,'',K.OFS.SOURCE,'')    ;* Call ofs.post.message for processing multiple messages instead of BULK.MANAGER
    
    DE.I.ALL.FIELD.DATA = '' ; DE.I.FIELD.DATA = ''

RETURN
*************************************************************************
INITIALISE:

* Initialise variables
 
    FIELD.TO.FIND = ''
    FIELD.TO.DEFAULT = ''
    FIELD.TO.FIND.ALL = ''
    DE.I.ALL.FIELD.DATA = ''
    SWIFT.TAG.NO = ''
    SWIFT.TAG.DATA = ''
    MESSAGE.ERROR = ''
    TAG.ERROR.DATA = ''
    ERROR.COUNT = 1
    R.OFS.DATA = ''
    SEQ.A.DR.ACCT = ''
    SEQ.B.DR.ACCT = ''
    SEQ.A.ORD.CUST.OFS.DATA = ''
    SEQ.B.ORD.CUST.OFS.DATA = ''
    T24.TRANS.REF = ''
    OFS.REQ.DET.ID = ''

* Open Files

    FN.DE.I.MSG = "F.DE.I.MSG"
    DE.Inward.setFDeIMsg("")
    EB.DataAccess.Opf(FN.DE.I.MSG,F.DE.I.MSG.LOC)
    DE.Inward.setFDeIMsg(F.DE.I.MSG.LOC)

    FN.DE.MESSAGE = "F.DE.MESSAGE"
    DE.Inward.setFDeMessage("")
    EB.DataAccess.Opf(FN.DE.MESSAGE,F.DE.MESSAGE.LOC)
    DE.Inward.setFDeMessage(F.DE.MESSAGE.LOC)

    FN.DE.FORMAT.SWIFT = "F.DE.FORMAT.SWIFT"
    DE.Inward.setFDeFormatSwift("")
    EB.DataAccess.Opf(FN.DE.FORMAT.SWIFT,F.DE.FORMAT.SWIFT.LOC)
    DE.Inward.setFDeFormatSwift(F.DE.FORMAT.SWIFT.LOC)

    FN.DE.I.REPAIR = "F.DE.I.REPAIR"
    DE.Inward.setFDeIRepair('')
    EB.DataAccess.Opf(FN.DE.I.REPAIR,F.DE.I.REPAIR.LOC)
    DE.Inward.setFDeIRepair(F.DE.I.REPAIR.LOC)

    R.DE.I.MSG = ''
    MSG.ID = DE.Inward.getRKey()
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    R.DE.MESSAGE = ''
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    IN.STORE.MSG = R.DE.I.MSG
    CRLF = CHARX(013):CHARX(010)
    CONVERT CRLF TO @FM IN IN.STORE.MSG  ;* Convert CRLF to FM

    MSG.FIELD.COUNT = DCOUNT(IN.STORE.MSG,@FM)

    DEBIT.INFO = ''
    TXN.PROCESS.DATE = ''
    TXN.DEBIT.THEIR.REF = ''
RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:

* Lookup existing data from SWIFT Tags in the OFS record (e.g. Dr Currency)

* TRANSACTION TYPE FIELD (Specific to FT - determines the FT Txn Type)
*
    GOSUB DETERMINE.TXN.TYPE  ;* Determine the txn type. This is not final. This might be changed after finding the  accounts to be debited and credited.
*
    GOSUB STORE.THE.MESSAGE   ;* Store the inward message in  the appllication
*
    DEBIT.CURRENCY.FOUND = INDEX( R.OFS.DATA, "DEBIT.CURRENCY", 1)
    IF DEBIT.CURRENCY.FOUND THEN
        DEBIT.CURRENCY = SUBSTRINGS( R.OFS.DATA, DEBIT.CURRENCY.FOUND+15, 3)
        CREDIT.CURRENCY = DEBIT.CURRENCY

* CI_10005888 S
* The content of tag 32B should be populated to Credit leg and not debit leg
        R.OFS.DATA = CHANGE(R.OFS.DATA,'DEBIT.CURRENCY','CREDIT.CURRENCY')
        R.OFS.DATA = CHANGE(R.OFS.DATA,'DEBIT.AMOUNT' , 'CREDIT.AMOUNT')

* CI_10005888 E

    END
    DR.ACCT.FOUND = INDEX(R.OFS.DATA,"DEBIT.ACCT.NO",1)
*
* DEBIT ACCOUNT
*
    IF DR.ACCT.FOUND = 0 THEN
*
* If still the debit account no. is not populated, find out the orderimg
* customer's account specified in 50G / H. if not present, find the
* account for the ordering customer from the system.

        IF SEQ.B.DR.ACCT THEN
            R.OFS.DATA := "DEBIT.ACCT.NO=":SEQ.B.DR.ACCT:","
        END ELSE
            IF SEQ.A.DR.ACCT THEN
                R.OFS.DATA := "DEBIT.ACCT.NO=":SEQ.A.DR.ACCT:","
            END

        END

    END


* Complete any fields not directly populated from input Tags
*
    IF SENDING.CUSTOMER = '' THEN
        SENDING.CUSTOMER = 'SW-':SENDERS.BIC.CODE
    END

*   R.OFS.DATA := 'CREDIT.CURRENCY=':CCY:',' ; CI_10005070 S/E

*      R.OFS.DATA := 'ORDERING.BANK=':SENDING.CUSTOMER:',' ; CI_10006340 S/E

* Get the ordering customer
* If the ordering customer is found in Sequence B use it else take
* the ordering customer from sequence A.

    IF SEQ.B.ORD.CUST.OFS.DATA THEN
        R.OFS.DATA := SEQ.B.ORD.CUST.OFS.DATA:','
    END ELSE
        IF SEQ.A.ORD.CUST.OFS.DATA THEN
            R.OFS.DATA := SEQ.A.ORD.CUST.OFS.DATA: ','
        END
    END


    INTERMED.BANK.FOUND = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
    IN.INTERMED.ACC = INDEX(R.OFS.DATA,"IN.INTERMED.ACC",1)
    IF INTERMED.BANK.FOUND OR IN.INTERMED.ACC THEN
        FIELD.TO.FIND.ALL = 'ACCT.WITH.BK':'*':'ACCT.WITH.BANK'
        FIELD.TO.FIND.ALL<-1> = 'IN.ACCT.BANK.ACC':'*':'ACCT.WITH.BANK.ACC'
        GOSUB DEFAULT.FIELDS
    END


* For Outward transfers :
    IF FT.TXN.TYPE[1,2] EQ 'OT' THEN
        FIELD.TO.FIND.ALL = 'IN.ORDERING.BK':'*':'ORDERING.BANK'
        FIELD.TO.FIND.ALL<-1> ='IN.BEN.ACCT.NO':'*':'BEN.ACCT.NO'
        FIELD.TO.FIND.ALL<-1> = 'IN.BEN.CUSTOMER':'*':'BEN.CUSTOMER'
        FIELD.TO.FIND.ALL<-1> = 'IN.BEN.BANK':'*':'BEN.BANK'
* Changes for Tag 59F
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.NAME":'*':'BEN.NAME'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.ADDRESS":'*':'BEN.ADDRESS'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.COUNTRY":'*':'BEN.COUNTRY'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.TOWN":'*':'BEN.TOWN'

        GOSUB DEFAULT.FIELDS

* Credit Account default
        CR.ACCT.FOUND = INDEX(R.OFS.DATA,"CREDIT.ACCT.NO",1)

        IF CR.ACCT.FOUND = 0 THEN
            CCY = ''
            CHECK.ACCOUNT.CLASS = ''
            IN.INTERMED.ACC = INDEX(R.OFS.DATA,"IN.INTERMED.ACC",1)
            INTERMED.BANK = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
            IN.ACCT.BANK.ACC = INDEX(R.OFS.DATA,"IN.ACCT.BANK.ACC",1)
            ACCT.WITH.BK = INDEX(R.OFS.DATA,"ACCT.WITH.BK",1)


            BEGIN CASE

                CASE IN.INTERMED.ACC

                    FIELD.TO.FIND.ALL = 'IN.INTERMED.ACC':'*':'CREDIT.ACCT.NO'
                    GOSUB DEFAULT.FIELDS

                CASE INTERMED.BANK
                    FIELD.TO.FIND = 'IN.INTERMED.BK'
                    GOSUB PROCESS.SEARCH.FIELD
                    CCY = CREDIT.CURRENCY
                    CHECK.ACCOUNT.CLASS = "NOSTRO"
                    GOSUB CHECK.GLOBUS.CUSTOMER

                CASE IN.ACCT.BANK.ACC

                    FIELD.TO.FIND.ALL = 'IN.ACCT.BANK.ACC':'*':'CREDIT.ACCT.NO'
                    GOSUB DEFAULT.FIELDS

                CASE ACCT.WITH.BK

                    FIELD.TO.FIND = 'ACCT.WITH.BK'
                    GOSUB PROCESS.SEARCH.FIELD
                    CCY = CREDIT.CURRENCY
                    CHECK.ACCOUNT.CLASS = "NOSTRO"
                    GOSUB CHECK.GLOBUS.CUSTOMER

                CASE 1

            END CASE
        END

    END ELSE

* For inward transfers

        IF FT.TXN.TYPE[1,2] EQ 'IT' THEN
            FIELD.TO.FIND.ALL ='IN.BEN.ACCT.NO':'*':'CREDIT.ACCT.NO'
            FIELD.TO.FIND.ALL<-1>= 'IN.ORDERING.BK':'*':'ORDERING.BANK'
            GOSUB DEFAULT.FIELDS
* CI_10006857 S
* Check for IT or AC should be made only for Non OT transactions.
* Check if the FT raised is to be an 'AC' type. Meaning, both the
* ordering customer and beneficiary's accounts are with us.
* The txn type should be 'AC' in that case.

            GOSUB CHECK.IF.AC.TYPE.FT


        END
    END
* CI_10006857 E



* For AC transactions , BEN.OUR.CHARGES is not applicable.Hence
* suppress all the values of Ben our charges - BEN,SHA,OUR at present.

    IF FT.TXN.TYPE[1,2] = 'AC' THEN
        R.OFS.DATA = CHANGE(R.OFS.DATA,"BEN.OUR.CHARGES=BEN,",'')
        R.OFS.DATA = CHANGE(R.OFS.DATA,"BEN.OUR.CHARGES=SHA,",'')
        R.OFS.DATA = CHANGE(R.OFS.DATA,"BEN.OUR.CHARGES=OUR,",'')
    END

* Required fields for FT application
*
    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'DELIVERY.INREF=':IN.DEL.KEY:','
    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'INWARD.PAY.TYPE=':IN.MSG.TYPE:','


* Store the debit account number and the processing date which
* will not be repeated in the next sequence. These values will be
* populated into the next FT txns.


    IF TAG.VAL.NO = 1 THEN
        GOSUB STORE.MAIN.SEQ.INFO

    END
* CI_10005888 S
* Credit currency gets mapped from the incoming tag. Hence default debit
* currency only if requried.

    IF NOT(INDEX(R.OFS.DATA,'DEBIT.ACCT.NO',1)) AND DEBIT.CURRENCY THEN
        R.OFS.DATA := 'DEBIT.CURRENCY:1:1=':DEBIT.CURRENCY:','
    END
* CI_10005888 E

* Processing date should be updated in this position only.

* CI_10008703 - s
*      R.OFS.DATA := 'PROCESSING.DATE=':TXN.PROCESS.DATE:','

    IF TXN.PROCESS.DATE < EB.SystemTables.getToday() THEN
        R.OFS.DATA := 'DEBIT.VALUE.DATE=':TXN.PROCESS.DATE:','
        R.OFS.DATA := 'CREDIT.VALUE.DATE=':TXN.PROCESS.DATE:','
        NEW.DATE = EB.SystemTables.getToday()
        R.OFS.DATA := 'PROCESSING.DATE=':NEW.DATE:','
    END ELSE
        R.OFS.DATA := 'PROCESSING.DATE=':TXN.PROCESS.DATE:','
    END
* CI_10008703 - e

    R.OFS.DATA :='DEBIT.THEIR.REF=':TXN.DEBIT.THEIR.REF:','

RETURN

**************************************************************************
DEFAULT.FIELDS:
* Defaulting of fields are done here . DE.I.ALL.FIELD.DATA will have the
* field names and the corresponding Data separated by CHARX(251).
* CHARX(251) is used because it is possible that other markers may be
* used in the data itself.To be on safer side , use TM.

* Loop around for all possible default fields specified.
    LOOP
        REMOVE FIELD.FIND.DEFAULT FROM FIELD.TO.FIND.ALL SETTING FIELD.POS
    WHILE FIELD.FIND.DEFAULT:FIELD.POS
        GOSUB PROCESS.DEFAULT.FIELDS
    REPEAT

RETURN

**************************************************************************

PROCESS.DEFAULT.FIELDS:

* FIELD.TO.FIND should be in double quotes. This is because
* we use FINDSTR to find this field in the R.OFS.DATA. If this is
* not in double quotes, the field position may not be correct.
    FIELD.TO.FIND = '"': FIELD( FIELD.FIND.DEFAULT,'*',1):'"'
    FIELD.TO.DEFAULT = FIELD(FIELD.FIND.DEFAULT,'*',2)
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        IN.DEFAULT.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN IN.DEFAULT.DATA
        NO.REP = 1
        LOOP
            REMOVE DATA.TO.DEF FROM IN.DEFAULT.DATA SETTING DEF.POS
        WHILE DATA.TO.DEF:DEF.POS
            DATA.TO.DEF = QUOTE(DATA.TO.DEF)      ;* CI_10005670 S/E
            R.OFS.DATA :=FIELD.TO.DEFAULT:':':NO.REP:'=':DATA.TO.DEF:','

            NO.REP +=1
        REPEAT

    END
RETURN

************************************************************************
PROCESS.SEARCH.FIELD:
*************************************************************************
    FIELD.TO.SEARCH.DATA = ''
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        FIELD.TO.SEARCH.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN FIELD.TO.SEARCH.DATA
    END
RETURN
***************************************************************************
CHECK.GLOBUS.CUSTOMER:
*************************************************************************
    CUSTOMER = ''
    IF DCOUNT(FIELD.TO.SEARCH.DATA,@FM) = 1 THEN
        customerKey = FIELD.TO.SEARCH.DATA
        exists = ''
        CALL CustomerService.checkExists(customerKey, exists)
        IF NOT(exists<Exists.valid>) THEN
* Error processing
            EB.SystemTables.setEtext('')
        END ELSE
            CUSTOMER = FIELD.TO.SEARCH.DATA
        END
    END
*
    IF CUSTOMER THEN
        GOSUB DE.I.GET.ACCOUNT.NO
    END
*
RETURN
*
**************************************************************************
DE.I.GET.ACCOUNT.NO:
*************************************************************************

    CUSTOMER.NO = CUSTOMER
    OFS.DATA = ''
    TXN.TYPE = ''
    ACCOUNT = ''
    ACCOUNT.CATEGORY = ''
    ACCOUNT.COUNT = ''
    ACCOUNT.CLASS = ''
    ACCOUNT.ERROR = ''
    ACCOUNT.IN = ''
    ACCOUNT.NO = ''
    FT.Delivery.DeIGetAcctNo( CUSTOMER.NO, CCY, TXN.TYPE, ACCOUNT.IN, ACCOUNT, ACCOUNT.CATEGORY, ACCOUNT.COUNT,ACCOUNT.CLASS, ACCOUNT.ERROR)

    LOCATE CHECK.ACCOUNT.CLASS IN ACCOUNT.CLASS<1> SETTING POS THEN
        IF ACCOUNT.COUNT<POS> GT 1 THEN
            TAG.ERR = 'ERROR - MORE THAN ONE ACCOUNT AVAILABLE'
            ACCOUNT.NO = ''
        END ELSE
            ACCOUNT.NO = ACCOUNT<POS,1>
        END
    END


    IF ACCOUNT.NO THEN
        OFS.DATA = OFS.DATA : "CREDIT.ACCT.NO" :'=' :ACCOUNT.NO
    END


    IF OFS.DATA THEN R.OFS.DATA := OFS.DATA:","

RETURN

*************************************************************************
DETERMINE.TXN.TYPE:
*************************************************************************

* For FT - Determine the transaction type option from the available combination of fields
*
    ACCT.WITH.FOUND = ''
    ACCT.WITH.FOUND = INDEX( R.OFS.DATA, "ACCT.WITH.BK", 1)
*
* If Acct with bank is found, then the transaction type is likely to be OT.
* Otherwise it can either be IT or AC, depending on the debit & credit customer.
* Hence the transaction type will be added later for IT,AC transactions to
* R.OFS.DATA.

    BEGIN CASE

        CASE ACCT.WITH.FOUND
            FT.TXN.OPTION.NO = 2
        CASE 1

            FT.TXN.OPTION.NO = 1
            FT.TXN.TYPE = 'IT'
            RETURN
    END CASE

    TRANS.TYPE = ''
    R.DE.I.FT.TXN.TYPES = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
    TRANS.TYPE = R.DE.I.FT.TXN.TYPES<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
    FT.TXN.TYPE = TRANS.TYPE<1,FT.TXN.OPTION.NO>
    R.OFS.DATA := 'TRANSACTION.TYPE=':FT.TXN.TYPE:','

RETURN
*
**************************************************************************
CALL.SUBROUTINE:
**************************************************************************
*
* Process each tag routine
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.
*
    IF DE.TAG.ID EQ '' THEN
        RETURN      ;* BG_100013209 - S
    END   ;* BG_100013209 - E

*
    R.DE.I.SUBROUTINE.TABLE = ''
    SET.ERROR = ''

    R.DE.I.SUBROUTINE.TABLE = DE.Messaging.ISubroutineTable.Read(DE.TAG.ID, TAG.ERR)

    IF TAG.ERR THEN
        SET.ERROR = "TAG ROUTINE FOR ":DE.TAG.ID:" - MISSING"
    END ELSE

        SUBROUTINE.ID = R.DE.I.SUBROUTINE.TABLE<DE.Messaging.ISubroutineTable.SrTbSubroutine>
        OFS.DATA = ''
        COMPILED.OR.NOT = ''
        DE.I.FIELD.DATA = ''
        EB.API.CheckRoutineExist(SUBROUTINE.ID, COMPILED.OR.NOT, R.ERR)

        IF NOT(COMPILED.OR.NOT) THEN
            SET.ERROR = "SUBROUTINE FOR TAG ":DE.TAG.ID:" NOT COMPILED"
        END ELSE
* CI_10006679 S
*            CALL @SUBROUTINE.ID (SEQUENCED.TAGS<TAG.FIELD.NO>,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','',DE.I.FIELD.DATA, SET.ERROR)
            CALL @SUBROUTINE.ID (SEQ.TAG.ID,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','',DE.I.FIELD.DATA, SET.ERROR)
* CI_10006679 E
            IF OFS.DATA NE '' THEN
                R.OFS.DATA := OFS.DATA:","
                DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA
            END
        END
    END

    GOSUB UPDATE.DEBIT.ACCT.NO.AND.ORD.CUST       ;* To store Sequence A & Sequence B debit acct no.

    IF SET.ERROR THEN
        MESSAGE.ERROR<-1> = SET.ERROR   ;* BG_100013209 - S
    END   ;* BG_100013209 - E


RETURN
*************************************************************************
CHECK.IF.AC.TYPE.FT:
*************************************************************************************

    FIELD.TO.FIND = 'CREDIT.ACCT.NO' ; FIELD.POS = INDEX(R.OFS.DATA,'CREDIT.ACCT.NO',1)
*
    ACCT.DATA = R.OFS.DATA[FIELD.POS,999]
    NEXT.COMMA.POS = INDEX(ACCT.DATA,',',1)
    EQUAL.TO.POS = INDEX(ACCT.DATA,'=',1)
    CR.ACCOUNT = ACCT.DATA[EQUAL.TO.POS + 1, NEXT.COMMA.POS - (EQUAL.TO.POS+1)]

    FIELD.TO.FIND = 'DEBIT.ACCT.NO' ; FIELD.POS = INDEX(R.OFS.DATA,'DEBIT.ACCT.NO',1)
    ACCT.DATA = R.OFS.DATA[FIELD.POS,999]
    NEXT.COMMA.POS = INDEX(ACCT.DATA,',',1)
    EQUAL.TO.POS = INDEX(ACCT.DATA,'=',1)
    DR.ACCOUNT = ACCT.DATA[EQUAL.TO.POS + 1, NEXT.COMMA.POS - (EQUAL.TO.POS+1)]
*
* CI_10005680 - S
*
    TMP.COMI = EB.SystemTables.getComi()
    EB.SystemTables.setComi(CR.ACCOUNT)
    FT.Contract.In2Allaccval("16.1","ALLACCVAL")
    IF EB.SystemTables.getEtext() = '' THEN
        CR.ACCOUNT = EB.SystemTables.getComi()     ;* BG_100013209 - S
    END   ;* BG_100013209 - E

*
    EB.SystemTables.setComi(DR.ACCOUNT)
    FT.Contract.In2Allaccval("16.1","ALLACCVAL")
    IF EB.SystemTables.getEtext() = '' THEN
        DR.ACCOUNT = EB.SystemTables.getComi()     ;* BG_100013209 - S
    END   ;* BG_100013209 - E

    EB.SystemTables.setComi(TMP.COMI)
*
* CI_10005680 - E
*
    R.ACC.REC = ''
    R.ACC.REC = AC.AccountOpening.Account.Read(CR.ACCOUNT, ER)
    CR.CUSTOMER = R.ACC.REC<AC.AccountOpening.Account.Customer>
    CR.ACCT.CAT = R.ACC.REC<AC.AccountOpening.Account.Category>

    R.ACC.REC = ''
    R.ACC.REC = AC.AccountOpening.Account.Read(DR.ACCOUNT, ER)
    DR.CUSTOMER = R.ACC.REC<AC.AccountOpening.Account.Customer>
    DR.ACCT.CAT = R.ACC.REC<AC.AccountOpening.Account.Category>
*
    AC.Config.CheckAccountClass('VOSTRO', CR.ACCT.CAT, CR.CUSTOMER, '', PRETURN)
    IF PRETURN EQ 'YES' THEN
        CR.CUST.Y.N = 0       ;* BG_100013209 - S
    END ELSE
        CR.CUST.Y.N = 1
    END   ;* BG_100013209 - E

    IF CR.CUST.Y.N EQ 1 THEN
        AC.Config.CheckAccountClass('NOSTRO', CR.ACCT.CAT, CR.CUSTOMER, '', PRETURN)
        IF PRETURN EQ 'YES' THEN
            CR.CUST.Y.N = 0   ;* BG_100013209 - S
        END ELSE
            CR.CUST.Y.N = 1
        END         ;* BG_100013209 - E
    END
*
    AC.Config.CheckAccountClass('VOSTRO', DR.ACCT.CAT, DR.CUSTOMER, '', PRETURN)
    IF PRETURN EQ 'YES' THEN
        DR.CUST.Y.N = 0       ;* BG_100013209 - S
    END ELSE
        DR.CUST.Y.N = 1
    END   ;* BG_100013209 - E

    IF DR.CUST.Y.N EQ 1 THEN
        AC.Config.CheckAccountClass('NOSTRO', DR.ACCT.CAT, DR.CUSTOMER, '', PRETURN)
        IF PRETURN EQ 'YES' THEN
            DR.CUST.Y.N = 0   ;* BG_100013209 - S
        END ELSE
            DR.CUST.Y.N = 1
        END         ;* BG_100013209 - E
    END
*
    IF CR.CUST.Y.N AND DR.CUST.Y.N THEN
        FT.TXN.OPTION.NO = 3
        R.DE.I.FT.TXN.TYPES = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
        TRANS.TYPE = R.DE.I.FT.TXN.TYPES<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
        R.OFS.DATA = 'TRANSACTION.TYPE=':FT.TXN.TYPE:',':R.OFS.DATA
*
    END ELSE
        FT.TXN.OPTION.NO = 1
        R.DE.I.FT.TXN.TYPES = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
        TRANS.TYPE = R.DE.I.FT.TXN.TYPES<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
        FT.TXN.TYPE = TRANS.TYPE<1,FT.TXN.OPTION.NO>
        R.OFS.DATA = 'TRANSACTION.TYPE=':FT.TXN.TYPE:',':R.OFS.DATA
    END
RETURN

*******************************************************************************
STORE.MAIN.SEQ.INFO:
*******************************************************************************
* Processing date is inputted only in the main sequence.
    FIELD.TO.FIND = 'PROCESSING.DATE'
    GOSUB PROCESS.SEARCH.FIELD
    TXN.PROCESS.DATE = FIELD.TO.SEARCH.DATA
* Store the debit their ref. This has to be passed on to all the
* FTs created.
    FIELD.TO.FIND = 'DEBIT.THEIR.REF'
    GOSUB PROCESS.SEARCH.FIELD
    TXN.DEBIT.THEIR.REF = FIELD.TO.SEARCH.DATA
RETURN

**************************************************************************
UPDATE.DEBIT.ACCT.NO.AND.ORD.CUST:
**************************************************************************
* Note that Sequence A indicates the general non repetitive tag info and
* sequence B - the repeating sequence structure.



    IF DE.TAG.ID = '50' THEN

* Get the debit account number.
* The SEQ.A.DR.ACCT will be obtained for the tag 50 G or 50H of the
* ordering bank. The SEQ.B.DR.ACCT will be obtained from the same tags
* Processing date tag 30 - is a mandatory tag and this differentiates
* the SEQ A & SEQ B. Hence if Account to debit  is obtained from the 50 tag
* routine and Processing date is found in R.OFS.DATA, it means that the
* new account is obtained for SEQ B other wise it is for SEQ A



        IF ( SEQUENCED.TAGS<TAG.FIELD.NO>[1,3] ='50G' OR SEQUENCED.TAGS<TAG.FIELD.NO>[1,3] = '50H' ) AND DE.TAG.SEQ.MSG<DE.TAG.ID> THEN
            IF TAG.VAL.NO = 1 AND NOT(INDEX(R.OFS.DATA,'PROCESSING.DATE',1)) THEN
                SEQ.A.DR.ACCT = DE.TAG.SEQ.MSG<DE.TAG.ID>
            END ELSE
                SEQ.B.DR.ACCT = DE.TAG.SEQ.MSG<DE.TAG.ID>
            END
        END

* Get the ordering customer.
* The ordering customer can be obtained from the Tags - 50 C,G,H,L.Hence

        IF INDEX(DE.I.FIELD.DATA,'"IN.ORDERING.CUS"',1) THEN
            IF TAG.VAL.NO = 1 AND NOT(INDEX(R.OFS.DATA,'PROCESSING.DATE',1)) THEN
                SEQ.A.ORD.CUST.OFS.DATA = CHANGE(OFS.DATA,"IN.ORDERING.CUS","ORDERING.CUST")
            END ELSE
                SEQ.B.ORD.CUST.OFS.DATA = CHANGE(OFS.DATA,"IN.ORDERING.CUS","ORDERING.CUST")
            END
        END



    END
RETURN

*=======================
CHECK.NETTING.AGREEMENT:
*=======================

* Check for Netting agreement. If net error is returned that either the
* sender or the ordering customers does not have netting agreement with
* us or each other. Hence set the DE.I.HEADER to repair and can be
* resubmitted once Netting Agreement is set.


    NET.ERROR = ''

* Sender is passed with both CUSTOMER ID and the BIC code to facilate checking netting
* agreement record with either the customer ID or the BIC code.
* EN_1045764

    IF SENDERS.BIC.CODE[10,3] = 'XXX' THEN
        BIC.CODE = SENDERS.BIC.CODE[1,8]          ;*if sender is with XXX only first 8 characters are taken else 9th character is removed and 11 character BIC code is taken
    END ELSE
        BIC.CODE = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
    END
    SENDER = ''
    SENDER<1> = SENDING.CUSTOMER
    SENDER<2> = BIC.CODE

    DE.API.CheckNettingAgreement(SENDER,MESSAGE.TYPE,SEQUENCED.TAGS,SEQUENCED.MESSAGE,NET.ERROR,RESERVED1,RESERVED2)

    IF NET.ERROR THEN


* Add key to repair file

        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, NET.ERROR)
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'REPAIR')

* Repair record locked

        R.REPAIR = DE.Inward.getRKey()
        ADD.OR.DEL = 1
        DE.Outward.UpdateIRepair(R.REPAIR,ADD.OR.DEL)
        REC.ID = DE.Inward.getRKey()
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

        EB.SystemTables.setApplication(TEMP.APPLICATION)
    END
RETURN
*
*************************************************************************************************************
*
* BG_100013209 - S
*==========================
PROCESS.REPITITIVE.FIELDS:
*===========================

* Single repetitive fields should be handled only within the tag routine.
* Hence don't consider the sub values single repetitive sequence field.
    MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
    IF MULTIPLE.FIELD.NO[1,1] NE 'R' THEN
        FIELD.SUB.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
        IF FIELD.SUB.VALS > TAG.SUB.COUNT THEN
            TAG.SUB.COUNT = FIELD.SUB.VALS
        END
    END
RETURN
*
*************************************************************************************************************
*
*=================
PROCESS.CORE.DATA:
*=================

    FIELD.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO>,@VM)
    IF FIELD.VALS < TAG.VAL.NO THEN
        TAG.VAL.IDX = FIELD.VALS
    END ELSE
        TAG.VAL.IDX = TAG.VAL.NO
    END
    FIELD.SUBS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX>,@SM)
    IF FIELD.SUBS < TAG.SUB.NO THEN
        TAG.SUB.IDX = FIELD.SUBS
    END ELSE
        TAG.SUB.IDX = TAG.SUB.NO
    END
* BG_100002334 S
    BLANK.REPEAT.FIELD = 0
    IF MULTIPLE.TAG<TAG.FIELD.NO>[1,2] GT 0 THEN
        IF FIELD.VALS<TAG.VAL.NO OR FIELD.SUBS<TAG.SUB.NO THEN
            BLANK.REPEAT.FIELD = 1
        END
    END
* The values of single repetitive sequcene field should be handled within
* the tag routine and it should be separated by VM s.

    MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
    IF MULTIPLE.FIELD.NO[1,1] = 'R' AND BLANK.REPEAT.FIELD = 0 THEN
        DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
        SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO> ;* CI_10006679 S/E
        DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX>
        CONVERT @SM TO @VM IN DE.TAG.SEQ.MSG

        GOSUB CALL.SUBROUTINE

    END ELSE

        IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' AND BLANK.REPEAT.FIELD = 0 THEN
*               IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' THEN
* BG_100002334 E

            DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
            SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>   ;* CI_10006679 S/E
            DE.TAG.ID = SEQ.TAG.ID[1,2]
            GOSUB CALL.SUBROUTINE
        END
    END

RETURN          ;* BG_100013209 - E
*
*************************************************************************************************************
*
END
