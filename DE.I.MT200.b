* @ValidationCode : MjoxNjA3NTcxODMwOkNwMTI1MjoxNjE2NjUxMjIxNTM1OmhhcnNoYXNhaXA6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjQzODoyNjQ=
* @ValidationInfo : Timestamp         : 25 Mar 2021 11:17:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harshasaip
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 264/438 (60.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>198</Rating>
*-----------------------------------------------------------------------------
* Version 1 25/06/02  GLOBUS Release No. G13.2.00 25/06/02
$PACKAGE FT.Delivery
SUBROUTINE DE.I.MT200
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*                                                                       *
*   MODIFICATIONS                                                       *
*                                                                       *
* 10/07/02 - EN_10000786                                                *
*            Initial Version for processing 200 message                 *
*                                                                       *
* 07/10/02 - EN_10001322                                                *
*            Account Fields for SWIFT 2002 Usage                        *
*                                                                       *
* 30/10/02 - BG_100002532                                               *
*            Error in reading Credit ccy correctly from R.OFS.DATA.     *
*
* 05/11/02 - BG_100002640
*            - Intermediary tag details (tag 56) are now stored in field
*            IN.INTERMED.BK and not INTERMED.BANK
*            - Populate TELEX.FROM.CUST field in R.OFS.DATA
* 29/11/02 - CI_10005070
*            Default credit currency to debit currency only if credit
*            account cannot be found.
* 26/12/02 - CI_10005670
*            Special characters enclosed in double quotes before
*            passing to R.OFS.DATA in the PROCESS.DEFAULT.FILEDS para
*
* 03/03/03 - EN_10001649
*              Map the sender of Incoming message to INW.SEND.BIC field of FT.
*              The sender is indentified from the FROM.ADDRESS of DE.I.HEADER.
*
* 20/03/03 - EN_10001661
*            If the senders bic code is of 12 characters, then exclude the
*            9th character,
*
* 24/09/03 - CI_10012844
*            Changes made to populate Debit Acct no with the
*            acct of Sender Correspondent.
*
* 19/04/08 - CI_10054834/Ref: HD0808225
*      Inward swift message (IN.SWIFT.MSG) is not getting updated
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
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 31/01/11 - Task 126521
*            Change the call to service operation exists to checkExists.
*
* 17/05/11 - Task 204050
*            Fix is done to check NOSTRO account once it complete the validation
*            of the vostro account for populating debit account for the cases like
*            sender correspond bank & receiver corr bank.
*
* 09/01/13 - Task 556879
*            In OFS Message comma(,) is considered as a delimiter between the field value , So if CUS.NAME
*            contains comma then it converted in to "?". Reverting the fix done in Task 51844.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
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
* 14/05/19 - Enhancement 3112589 / Task 3112595
*            Pass the Delivery Reference value, update the reference in DE.UETR.CATALOG
*            for the respective transaction.
*
* 18/03/21 - Defect 4279482 / Task 4292010
*            Replacing OFS.GLOBUS.MANAGER with OFS.BULK.MANAGER using CALL.OFS.BULK.MANAGER routine
*
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
    $USING FT.Contract
    $USING DE.Inward
    $USING EB.DataAccess
    $USING DE.API
    $USING EB.Interface
    $USING EB.API
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
        GOSUB CALL.OFS.BULK.MANAGER
        GOTO STOP.THE.PROCESS
    END

    GOSUB IDENTIFY.THE.SENDER

* Generic Body Processing

    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)

* Method 1 - To generate one application record with repeat sequences (use this OR method 2)

    TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
    FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT

* There is possiblity for single repetitive sequences. In such case the
* tag routine can decide how to handle it.
*
        DE.TAG.ID = '' ; DE.TAG.SEQ.MSG = ''
        MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>

        IF MULTIPLE.FIELD.NO[1,1] = 'R' THEN

            DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
            DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO>
            GOSUB CALL.SUBROUTINE

        END ELSE

            TAG.VAL.COUNT = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO>,@VM)
            FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT
                TAG.SUB.COUNT = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
                FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT
                    IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO,TAG.SUB.NO> NE '' THEN
                        DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
                        DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO,TAG.SUB.NO>
                        GOSUB CALL.SUBROUTINE
                    END
                NEXT TAG.SUB.NO
            NEXT TAG.VAL.NO

        END

    NEXT TAG.FIELD.NO
*

    GOSUB ADD.NON.TAG.FIELDS  ;* Specific Application Record Processing

    IF MESSAGE.ERROR THEN GOSUB STORE.TAG.ERRORS

    GOSUB CALL.OFS.BULK.MANAGER

* End of Method 1

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
    IF MESSAGE.TYPE NE '200' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT200'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('200.1.1', READ.ERROR)

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
    R.OFS.DATA := 'DELIVERY.INREF=':IN.DEL.KEY:','

    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'INWARD.PAY.TYPE=':IN.MSG.TYPE:','

    FOR X = 1 TO MSG.FIELD.COUNT-1
        R.OFS.DATA := 'IN.SWIFT.MSG:':X:':="':IN.STORE.MSG<X>:'",'    ;* Store the message
    NEXT X

* EN_10001649 S

    R.OFS.DATA := 'INW.SEND.BIC=':DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress):','

* EN_10001649 E

RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer
* EN_10001649 S

* Entire full address should be mapped as SENDERS.BIC.CODE.
* SENDERS.BIC.CODE = SUBSTRINGS(R.HEAD(DE.HDR.FROM.ADDRESS),1,11)
    SENDERS.BIC.CODE = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)
*
* EN_10001649 E


    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)

* EN_10001661 S
* Exclude the 9th char if the senders bic code is of 12 chars.

    IF LEN(SENDERS.BIC.CODE) = 12 THEN
        SENDERS.BIC.CODE = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
    END

* EN_10001661 E


    SAVE.SENDING.CUSTOMER = SENDING.CUSTOMER
RETURN

*************************************************************************

HOLD.ON.ERROR:

* Processing when an error is found in the message

    R.OFS.DATA := 'IN.PROCESS.ERR:':ERROR.COUNT:'="':MESSAGE.ERROR:'",'

    ERROR.COUNT = ERROR.COUNT + 1

    MESSAGE.ERROR = ''

RETURN

*************************************************************************
STORE.TAG.ERRORS:

* Display all the error messages occured while processing each tag.

    NO.OF.TAG.ERRORS = DCOUNT(MESSAGE.ERROR, @FM)

    FOR CNT = 1 TO NO.OF.TAG.ERRORS

        TAG.ERROR.DATA := 'IN.PROCESS.ERR:':CNT:'="':MESSAGE.ERROR<CNT>:'",'

    NEXT CNT

RETURN
*************************************************************************
STORE.OFS.ERRORS:
* Capture OFS errors and store along with the tag erros

    VM.CNT = ''

* Write the tag errors
    IF TAG.ERROR.DATA THEN
        R.OFS.DATA := TAG.ERROR.DATA
        VM.CNT = NO.OF.TAG.ERRORS
    END

* Write the OFS erros
    ERR.REASON=FIELD(RETURN.INFO,',',2,9999)
    CONVERT "," TO @FM IN ERR.REASON
    CONVERT ":" TO "." IN ERR.REASON

    NO.OF.OFS.ERRORS = DCOUNT(ERR.REASON, @FM)
    FOR CNT = 1 TO NO.OF.OFS.ERRORS
        VM.CNT += 1
* Store only first ?? chars of the error as per the field length, otherwise OFS will reject
        OFS.ERR = ERR.REASON<CNT>[1,65]
        R.OFS.DATA := 'IN.PROCESS.ERR:':VM.CNT:'="':OFS.ERR:'",'
    NEXT CNT

RETURN

*************************************************************************
CALL.OFS.BULK.MANAGER:

    R.OFS.DATA = OFS.PREFIX:R.OFS.DATA
    UETR.REF = DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference)
    IF UETR.REF THEN
        R.OFS.DATA := 'IN.HDR.3.UETR=':UETR.REF:',' ;*assign UETR reference to IN.HD3.3.UETR in FT
    END
    
    EB.Interface.OfsCallBulkManager(K.OFS.SOURCE, R.OFS.DATA, RETURN.INFO,TXN.COMMITTED)
    
    CHANGE '<requests>' TO '' IN RETURN.INFO   ;* Remove the '<requests>' string of characters in the RETURN.INFO.
    CHANGE '<request>' TO '' IN RETURN.INFO    ;* Remove the '<request>' string of characters in the RETURN.INFO.
    
    T24.TRANS.REF = FIELD(RETURN.INFO,'/',1)       ;* Get the inward trans ref
    OFS.REQ.DET.ID = FIELD(RETURN.INFO,'/',2)      ;* Get the ofs request detail id

    R.OFS.DATA = ''

    IF FIELD(RETURN.INFO,'/',3) < 0 THEN

        TXN.REF.GEN=FIELD(RETURN.INFO,'/',1)
        FAIL.CODE=FIELD(RETURN.INFO,'/',3)

        R.OFS.DATA = K.VERSION:"/I,,"
        R.OFS.DATA := TXN.REF.GEN:','

        GOSUB STORE.OFS.ERRORS

        EB.Interface.OfsCallBulkManager(K.OFS.SOURCE,R.OFS.DATA, '', '')
    END
    
    IF UETR.REF THEN
* Pass the delivery reference to update DE.UETR.CATALOG when UETR reference updated.
        DEL.REF = DE.Inward.getRKey()
        DE.API.DeGenerateUetr(T24.TRANS.REF, "IN", '', UETR.REF, DEL.REF, '') ;*update concat file DE.UETR.REF.FILE
    END

RETURN

*************************************************************************
INITIALISE:

* Initialise variables

    FIELD.TO.FIND = ''
    FIELD.TO.DEFAULT = ''
    FIELD.TO.FIND.ALL = ''
    SWIFT.TAG.NO = ''
    SWIFT.TAG.DATA = ''
    MESSAGE.ERROR = ''
    TAG.ERROR.DATA = ''
    ERROR.COUNT = 1
    R.OFS.DATA = ''
    CCY = ''
    DEBIT.CURRENCY = ''
    CREDIT.CURRENCY = ''
    DR.ACCT.FOUND = ''
    DEBIT.CURRENCY.FOUND = ''
    ORD.CUS.FOUND = ''
    BEN.CUS.FOUND = ''
    ACCT.WITH.FOUND = ''
    ACCT.WITH.DATA = ''

    DE.I.ALL.FIELD.DATA = ''
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

    R.DE.I.MSG = ''
    REC.ID = DE.Inward.getRKey()
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(REC.ID, ER)
    EB.SystemTables.setE(ER)
    R.DE.MESSAGE = ''
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    OFS.PREFIX = K.VERSION:"/I,,,"

    IN.STORE.MSG = R.DE.I.MSG
    CRLF = CHARX(013):CHARX(010)
    CONVERT CRLF TO @FM IN IN.STORE.MSG
    MSG.FIELD.COUNT = DCOUNT(IN.STORE.MSG,@FM)
        
    RETURN.INFO = ''
    TXN.COMMITTED = ''

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:

* Lookup existing data from SWIFT Tags in the OFS record (e.g. Dr Currency)

* TRANSACTION TYPE FIELD (Specific to FT - determines the FT Txn Type)
*
    GOSUB DETERMINE.TXN.TYPE
    GOSUB STORE.THE.MESSAGE   ;* Store the inward message in  the application
*
** BG_100002640 -S
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
** BG_100002640 -E

* Get the debit currency
    DEBIT.CURRENCY.FOUND = INDEX( R.OFS.DATA, "DEBIT.CURRENCY", 1)
    IF DEBIT.CURRENCY.FOUND THEN
        DEBIT.CURRENCY = SUBSTRINGS( R.OFS.DATA, DEBIT.CURRENCY.FOUND+15, 3)
        CREDIT.CURRENCY = DEBIT.CURRENCY          ;* CI_10005070 S/E
    END

* Get the debit account
*
* EN_10001322 - S
*
    IF NOT(INDEX(R.OFS.DATA,"DEBIT.ACCT.NO",1)) THEN

        CCY = ''
        CHECK.ACCOUNT.CLASS = ''
*
        IN.REC.CORR.ACC = INDEX(R.OFS.DATA,"IN.REC.CORR.ACC",1)
        IN.REC.CORR.BK = INDEX(R.OFS.DATA,"IN.REC.CORR.BK",1)
*
* CI_10012844 -s
* Get  Sender Corres account specified in tag 53, if any.
        FIELD.TO.FIND = 'IN.SEND.CORR.ACC'
        GOSUB PROCESS.SEARCH.FIELD
        IN.SEND.CORR.ACC = FIELD.TO.SEARCH.DATA

        IN.SEND.CORR.BK = INDEX(R.OFS.DATA,"IN.SEND.CORR.BK",1)
* CI_10012844 -e


        BEGIN CASE

            CASE IN.REC.CORR.ACC

                FIELD.TO.FIND.ALL = 'IN.REC.CORR.ACC':'*':'DEBIT.ACCT.NO'
                GOSUB DEFAULT.FIELDS

            CASE IN.REC.CORR.BK

                FIELD.TO.FIND = 'IN.REC.CORR.BK'
                GOSUB PROCESS.SEARCH.FIELD
                CCY = DEBIT.CURRENCY
                CHECK.ACCOUNT.CLASS = "VOSTRO"
                GOSUB CHECK.GLOBUS.CUSTOMER

* CI_10012844 -s
            CASE IN.SEND.CORR.ACC
                FIELD.TO.FIND.ALL = 'IN.SEND.CORR.ACC':'*':'DEBIT.ACCT.NO'
                GOSUB DEFAULT.FIELDS

            CASE IN.SEND.CORR.BK
                FIELD.TO.FIND = 'IN.SEND.CORR.BK'
                GOSUB PROCESS.SEARCH.FIELD
                CCY = DEBIT.CURRENCY
                CHECK.ACCOUNT.CLASS = "VOSTRO"
                GOSUB CHECK.GLOBUS.CUSTOMER
* CI_10012844 -e

            CASE SENDING.CUSTOMER

                CUSTOMER = SAVE.SENDING.CUSTOMER
                CCY = DEBIT.CURRENCY
                CHECK.ACCOUNT.CLASS = "VOSTRO"
                GOSUB DE.I.GET.ACCOUNT.NO

            CASE 1


        END CASE

    END
*
* EN_10001322 - E
*
* Complete any fields not directly populated from input Tags
*
    IF SENDING.CUSTOMER = '' THEN
        SENDING.CUSTOMER = 'SW-':SENDERS.BIC.CODE
    END



    R.OFS.DATA := 'ORDERING.BANK=':SENDING.CUSTOMER:','

    R.OFS.DATA := 'BEN.BANK=':SENDING.CUSTOMER:','

* BG_100002640 - s
* Locate for IN.INTERMED.BK and not INTERMED.BANK

*      INTERMED.BANK.FOUND = INDEX(R.OFS.DATA,"INTERMED.BANK",1)
    INTERMED.BANK.FOUND = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
    IN.INTERMED.ACC = INDEX(R.OFS.DATA,"IN.INTERMED.ACC",1)
* BG_100002640 - e

    IF IN.INTERMED.ACC OR INTERMED.BANK.FOUND THEN
        FIELD.TO.FIND.ALL = 'ACCT.WITH.BK':'*':'ACCT.WITH.BANK'
        FIELD.TO.FIND.ALL<-1> = 'IN.ACCT.BANK.ACC':'*':'ACCT.WITH.BANK.ACC'
        GOSUB DEFAULT.FIELDS
    END
*
* Credit Account default
*
* EN_10001322 - S
*
    IF NOT(INDEX(R.OFS.DATA,"CREDIT.ACCT.NO",1)) THEN

        CCY = ''
        CHECK.ACCOUNT.CLASS = ''

* BG_100002640 - s
* Locate for IN.INTERMED.BK and not INTERMED.BANK

*         INTERMED.BANK = INDEX(R.OFS.DATA,"INTERMED.BANK",1)
        INTERMED.BANK = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
* BG_100002640 - e

        IN.ACCT.BANK.ACC = INDEX(R.OFS.DATA,"IN.ACCT.BANK.ACC",1)
        ACCT.WITH.BK = INDEX(R.OFS.DATA,"ACCT.WITH.BK",1)


        BEGIN CASE

            CASE IN.INTERMED.ACC

                FIELD.TO.FIND.ALL = 'IN.INTERMED.ACC':'*':'CREDIT.ACCT.NO'
                GOSUB DEFAULT.FIELDS

            CASE INTERMED.BANK

* BG_100002640 - s
* Locate for IN.INTERMED.BK and not INTERMED.BANK

*              FIELD.TO.FIND = 'INTERMED.BANK'
                FIELD.TO.FIND = 'IN.INTERMED.BK'
* BG_100002640 - e

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
*
* EN_10001322 - E
*

* Get the default credit currency
* CI_10005070 S
* If the credit account is not found, default credit currency from debit currency
    IF NOT(INDEX(R.OFS.DATA,'CREDIT.ACCT.NO',1)) AND CREDIT.CURRENCY THEN
        R.OFS.DATA := 'CREDIT.CURRENCY:1:1=':CREDIT.CURRENCY:','
    END
* CI_10005070 E

* Required fields for FT application
*
    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'DELIVERY.INREF=':IN.DEL.KEY:','
    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'INWARD.PAY.TYPE=':IN.MSG.TYPE:','


RETURN

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
***********************************************************************
    FIELD.TO.FIND = QUOTE(FIELD( FIELD.FIND.DEFAULT,'*',1))
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
************************************************************************
    FIELD.TO.SEARCH.DATA = ''
    FIELD.TO.FIND = QUOTE(FIELD.TO.FIND)
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        FIELD.TO.SEARCH.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN FIELD.TO.SEARCH.DATA
    END
RETURN

**************************************************************************
DETERMINE.TXN.TYPE:
*
* For FT - Determine the transaction type option from the available combination of fields
*
    BEGIN CASE

        CASE 1
            FT.TXN.OPTION.NO = 1
    END CASE

    TRANS.TYPE = ''
    R.DE.I.FT.TXN.TYPES = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
    TRANS.TYPE = R.DE.I.FT.TXN.TYPES<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
    FT.TXN.TYPE = TRANS.TYPE<1,FT.TXN.OPTION.NO>
    R.OFS.DATA = 'TRANSACTION.TYPE=':FT.TXN.TYPE:',':R.OFS.DATA

RETURN
*
**************************************************************************
*
* EN_10001322 - S
*
CHECK.GLOBUS.CUSTOMER:
*
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
*
    CUSTOMER.NO = CUSTOMER
    OFS.DATA = ''
    TXN.TYPE = ''
    ACCOUNT = ''
    ACCOUNT.CATEGORY = ''
    ACCOUNT.COUNT = ''
    ACCOUNT.CLASS = ''
    ACCOUNT.ERROR = ''
    ACCOUNT.IN = ''
    ACCOUNT.NO = '' ;* Initialise - BG_100002532 - s/e

    FT.Delivery.DeIGetAcctNo( CUSTOMER.NO, CCY, TXN.TYPE, ACCOUNT.IN, ACCOUNT, ACCOUNT.CATEGORY, ACCOUNT.COUNT,ACCOUNT.CLASS, ACCOUNT.ERROR)

    LOCATE CHECK.ACCOUNT.CLASS IN ACCOUNT.CLASS<1> SETTING POS THEN
        GOSUB CHECK.ACCT
    END

    IF CHECK.ACCOUNT.CLASS = "VOSTRO" THEN
        IF ACCOUNT.NO THEN
            OFS.DATA = OFS.DATA : "DEBIT.ACCT.NO" :'=' :ACCOUNT.NO
        END ELSE
            CHECK.ACCOUNT.CLASS = "NOSTRO"
            LOCATE CHECK.ACCOUNT.CLASS IN ACCOUNT.CLASS<1> SETTING POS THEN
                GOSUB CHECK.ACCT
            END
            IF ACCOUNT.NO THEN
                OFS.DATA = OFS.DATA : "DEBIT.ACCT.NO" :'=' :ACCOUNT.NO
            END
        END
    END ELSE
        IF ACCOUNT.NO THEN
            OFS.DATA = OFS.DATA : "CREDIT.ACCT.NO" :'=' :ACCOUNT.NO
        END
    END

    IF OFS.DATA THEN
        R.OFS.DATA := OFS.DATA:","
    END

RETURN
*
* EN_10001322 - E
************************************************************************
CHECK.ACCT:
*****************************************************************************
    IF ACCOUNT.COUNT<POS> GT 1 THEN
        TAG.ERR = 'ERROR - MORE THAN ONE ACCOUNT AVAILABLE'
        ACCOUNT.NO = ''
    END ELSE
        ACCOUNT.NO = ACCOUNT<POS,1>
    END
RETURN
**************************************************************************
CALL.SUBROUTINE:
**************************************************************************
*
    IF NOT(DE.TAG.ID) THEN RETURN

    R.DE.I.SUBROUTINE.TABLE = ''
    SET.ERROR = ''

    R.DE.I.SUBROUTINE.TABLE = DE.Messaging.ISubroutineTable.Read(DE.TAG.ID, TAG.ERR)

    IF TAG.ERR THEN
        SET.ERROR = "TAG ROUTINE FOR ":DE.TAG.ID:" - MISSING"
    END ELSE

        SUBROUTINE.ID = R.DE.I.SUBROUTINE.TABLE<DE.Messaging.ISubroutineTable.SrTbSubroutine>
        OFS.DATA = ''
        COMPILED.OR.NOT = ''
        DE.I.FIELD.DATA = ''  ;* GEETH S

        EB.API.CheckRoutineExist(SUBROUTINE.ID, COMPILED.OR.NOT, R.ERR)

        IF NOT(COMPILED.OR.NOT) THEN
            SET.ERROR = "SUBROUTINE FOR TAG ":DE.TAG.ID:" NOT COMPILED"
        END ELSE
            CALL @SUBROUTINE.ID (SEQUENCED.TAGS<TAG.FIELD.NO>,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,CCY,'','',DE.I.FIELD.DATA,SET.ERROR)
            IF OFS.DATA NE '' THEN
                R.OFS.DATA := OFS.DATA:","
                DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA
            END
        END
    END

    IF SET.ERROR THEN MESSAGE.ERROR<-1> = SET.ERROR

RETURN
END
