* @ValidationCode : MjoxNTUxNjk5NDI0OkNwMTI1MjoxNTg0MDgxNzA3ODMxOnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Mar 2020 12:11:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>597</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.Delivery
SUBROUTINE DE.I.MT100
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*
*   MODIFICATIONS
*
* 31/01/2003 - EN_10001615
*            Initial Version
*
* 03/03/2003 - EN_10001649
*              Map the sender of Incoming message to INW.SEND.BIC field of FT.
*              The sender is indentified from the FROM.ADDRESS of DE.I.HEADER.
* 20/03/2003 - EN_10001661
*              If the Senders BIC Code is of 12 characters, then the ordering
*              bank should be only of 11 characters. Exclude the 9th character.
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
*           Change the call to service operation exists to checkExists.
*
* 09/01/13 - Task 556879
*            In OFS Message comma(,) is considered as a delimiter between the field value ,
*            So if CUS.NAME contains comma then it converted in to "?".
*            Reverting the fix done in Task 51844.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 17/08/15 - Enhancement 1265068/ Task 1387507
*          - Routine incorporated
*
* 03/02/20 - Enhancement 3265496  / Task 3568259
*            Removing reference that have been moved from ST to CG
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
    $USING ST.Customer
    $USING FT.Contract
    $USING FT.Config
    $USING DE.Inward
    $USING EB.DataAccess
    $USING DE.API
    $USING EB.Interface
    $USING EB.API
    $USING DE.ModelBank
    $USING DE.Messaging
    $USING EB.SystemTables

    $INSERT I_CustomerService_NameAddress
    $INSERT I_CustomerService_Exists

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE

* Message Header Processing

    GOSUB VALIDATE.MESSAGE.TYPE

    IF ERROR.COUNT GT 1 THEN
* If error, no further processing
        GOSUB STORE.THE.MESSAGE
        GOSUB CALL.OFS.GLOBUS.MANAGER
        GOTO STOP.THE.PROCESS
    END

    GOSUB IDENTIFY.THE.SENDER

* Generic Body Processing

    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)

* Method 1 - To generate one application record with repeat sequences (use this OR method 2)
*
    TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
    FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT
*
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
*
    IF MESSAGE.ERROR THEN
        GOSUB STORE.TAG.ERRORS
        R.OFS.DATA := TAG.ERROR.DATA
    END
*
    GOSUB CALL.OFS.GLOBUS.MANAGER

* End of Method 1

STOP.THE.PROCESS:

    DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
    DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, T24.TRANS.REF);* Inward T24 trans ref
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED')
    R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
    REC.ID = DE.Inward.getRKey()
    DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

    EB.SystemTables.setApplication(TEMP.APPLICATION)

RETURN          ;* From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

VALIDATE.MESSAGE.TYPE:

* Check if the message is valid type and retrieve message format information

    MESSAGE.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    IF MESSAGE.TYPE NE '100' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT100'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('100.1.1', READ.ERROR)

    IF READ.ERROR THEN
        MESSAGE.ERROR = 'Message not found in DE.FORMAT.SWIFT FILE'
        GOSUB HOLD.ON.ERROR
    END

RETURN

*************************************************************************
STORE.THE.MESSAGE:

* Store the inward message in the application.

    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'DELIVERY.INREF=':IN.DEL.KEY:','

    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'INWARD.PAY.TYPE=':IN.MSG.TYPE:','

    FOR X = 1 TO MSG.FIELD.COUNT-1
        R.OFS.DATA := 'IN.SWIFT.MSG:':X:':="':IN.STORE.MSG<X>:'",'
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
*SENDERS.BIC.CODE = SUBSTRINGS(R.HEAD(DE.HDR.FROM.ADDRESS),1,11)
    SENDERS.BIC.CODE = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)
*
* EN_10001649 E
    SAVE.SENDING.CUSTOMER = ''
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)

* EN_10001661 S

* Exclude the 9th char if the senders bic code is of 12 chars.

    IF LEN(SENDERS.BIC.CODE) = 12 THEN
        SENDERS.BIC.CODE = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
    END

* EN_10001661 E

    SAVE.SENDING.CUSTOMER = SENDING.CUSTOMER      ;* May use later

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
* Storing only first 65 chars of the error as the field length of IN.PROCESS.ERR is 65
        OFS.ERR = ERR.REASON<CNT>[1,65]
        R.OFS.DATA := 'IN.PROCESS.ERR:':VM.CNT:'="':OFS.ERR:'",'
    NEXT CNT

RETURN

*************************************************************************
CALL.OFS.GLOBUS.MANAGER:

    R.OFS.DATA = OFS.PREFIX:R.OFS.DATA

    EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)
    T24.TRANS.REF = FIELD(R.OFS.DATA,'/',1)       ;* Get the inward trans ref
    OFS.REQ.DET.ID = FIELD(R.OFS.DATA,'/',2)      ;* Get the ofs request detail id

    RETURN.INFO = R.OFS.DATA
    R.OFS.DATA = ''

    IF FIELD(RETURN.INFO,'/',3) < 0 THEN

        TXN.REF.GEN=FIELD(RETURN.INFO,'/',1)
        FAIL.CODE=FIELD(RETURN.INFO,'/',3)

        R.OFS.DATA = K.VERSION:"/I,,"
        R.OFS.DATA := TXN.REF.GEN:','

        GOSUB STORE.OFS.ERRORS

        EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)
    END

RETURN

*************************************************************************
INITIALISE:

* Initialise variables

    CRT "Starting DE.I.MT100 template program"

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

    CCY = ''
    IN.ACCT.FOUND = ''
    DR.ACCT.FOUND = ''
    DEBIT.CURRENCY.FOUND = ''
    DEBIT.CURRENCY = ''
    CREDIT.CURRENCY = ''
    ORD.CUS.FOUND = ''
    BEN.CUS.FOUND = ''
    ACCT.WITH.FOUND = ''
    THIRD.PARTY.FOUND = ''
    ACCT.WITH.DATA = ''
    ACCOUNT = ''

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
    MSG.ID = DE.Inward.getRKey()
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(MSG.ID, READ.ER)
    EB.SystemTables.setE(READ.ER)

    R.DE.MESSAGE = ''
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(MSG.ID, READ.ER)
    EB.SystemTables.setE(READ.ER)

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    OFS.PREFIX = K.VERSION:"/I,,,"

    IN.STORE.MSG = R.DE.I.MSG
    CRLF = CHARX(013):CHARX(010)
    CONVERT CRLF TO @FM IN IN.STORE.MSG
    MSG.FIELD.COUNT = DCOUNT(IN.STORE.MSG,@FM)

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:

* Complete any fields not directly populated from input Tags
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.

    OFS.DATA = ''   ;* Re-initialise
*-----------------------------
* Set Transaction type
*-----------------------------
    GOSUB DETERMINE.TXN.TYPE
*
*-----------------------------
* Set Standard fields
*-----------------------------
    GOSUB STORE.THE.MESSAGE
*
*-----------------------------
* Populate TELEX.FROM.CUST
*-----------------------------
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
*
*-----------------------------
* Set the credit currency to the debit currency
*-----------------------------
    DEBIT.CURRENCY.FOUND = INDEX( R.OFS.DATA, "DEBIT.CURRENCY", 1)
*     Save debit currency in CREDIT.CURRENCY .
    IF DEBIT.CURRENCY.FOUND GT 0 THEN
        DEBIT.CURRENCY = SUBSTRINGS( R.OFS.DATA, DEBIT.CURRENCY.FOUND+15, 3)
        CREDIT.CURRENCY = DEBIT.CURRENCY
    END
*
    IF FT.TXN.TYPE[1,1] = 'I' THEN
*-----------------------------
* Specific for Inward Type messages
*-----------------------------
        FIELD.TO.FIND.ALL = ''
        FIELD.TO.FIND.ALL = "IN.BEN.ACCT.NO":'*':'CREDIT.ACCT.NO'
        GOSUB DEFAULT.FIELDS
*
    END ELSE
*-----------------------------
* Specific for Outward Type messages
*-----------------------------
        FIELD.TO.FIND.ALL = ''
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.ACCT.NO":'*':'BEN.ACCT.NO'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.CUSTOMER":'*':'BEN.CUSTOMER'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.BANK":'*':'BEN.BANK'
*-----------------------------
* If intermediary details are present, then we have to default the
* Acct with bank details to outward also.
*-----------------------------
        IN.INTERMED.ACC = INDEX(R.OFS.DATA,"IN.INTERMED.ACC",1)
        INTERMED.BANK = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
        IF IN.INTERMED.ACC OR INTERMED.BANK THEN
            FIELD.TO.FIND.ALL<-1> = 'IN.ACCT.BANK.ACC':'*':'ACCT.WITH.BANK.ACC'
            FIELD.TO.FIND.ALL<-1> = 'ACCT.WITH.BK':'*':'ACCT.WITH.BANK'
        END
*
        GOSUB DEFAULT.FIELDS
*
*-----------------------------
* Set Credit account no.
*-----------------------------
        IF NOT(INDEX(R.OFS.DATA,"CREDIT.ACCT.NO",1)) AND FT.TXN.TYPE[1,2] = "OT" THEN
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
*
                CASE INTERMED.BANK
                    FIELD.TO.FIND = 'IN.INTERMED.BK'
                    GOSUB PROCESS.SEARCH.FIELD
                    CCY = CREDIT.CURRENCY
                    CHECK.ACCOUNT.CLASS = "NOSTRO"
                    GOSUB CHECK.GLOBUS.CUSTOMER
*
                CASE IN.ACCT.BANK.ACC
                    FIELD.TO.FIND.ALL = 'IN.ACCT.BANK.ACC':'*':'CREDIT.ACCT.NO'
                    GOSUB DEFAULT.FIELDS
*
                CASE ACCT.WITH.BK
                    FIELD.TO.FIND = 'ACCT.WITH.BK'
                    GOSUB PROCESS.SEARCH.FIELD
                    CCY = CREDIT.CURRENCY
                    CHECK.ACCOUNT.CLASS = "NOSTRO"
                    GOSUB CHECK.GLOBUS.CUSTOMER
*
                CASE 1
            END CASE
        END
*
    END
*-----------------------------
* Set Ordering customer and Ordering bank
*-----------------------------
    FIELD.TO.FIND.ALL = ''
    FIELD.TO.FIND.ALL<-1> = "IN.ORDERING.CUS":'*':'ORDERING.CUST'
    FIELD.TO.FIND.ALL<-1> = "IN.ORDERING.BK":'*':'ORDERING.BANK'
    GOSUB DEFAULT.FIELDS
* If ORDERING.BANK is not found in the incoming transactions, then
* set the ordering bank as the Sender of the message.
    IF NOT(INDEX(R.OFS.DATA,"IN.ORDERING.BK",1)) THEN
        IF SAVE.SENDING.CUSTOMER = '' THEN SAVE.SENDING.CUSTOMER = 'SW-':SENDERS.BIC.CODE
        R.OFS.DATA := 'IN.ORDERING.BK:1:1=':SAVE.SENDING.CUSTOMER:','
        R.OFS.DATA := 'ORDERING.BANK:1:1=':SAVE.SENDING.CUSTOMER:','
    END
*
*-----------------------------
*  Set Default Debit Account
*-----------------------------
    IF NOT(INDEX(R.OFS.DATA,"DEBIT.ACCT.NO",1)) THEN
        CCY = ''
        CHECK.ACCOUNT.CLASS = ''

        IN.REC.CORR.ACC = INDEX(R.OFS.DATA,"IN.REC.CORR.ACC",1)
        IN.REC.CORR.BK = INDEX(R.OFS.DATA,"IN.REC.CORR.BK",1)
        ER = ''
        COMP.ID = EB.SystemTables.getIdCompany()
        R.APPL.DEFAULT = FT.Config.ApplDefault.Read(COMP.ID, ER)
        AWAITING.COVER = R.APPL.DEFAULT<FT.Config.ApplDefault.FtOneAwaitCover>

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
*
            CASE IN.REC.CORR.BK
                FIELD.TO.FIND = 'IN.REC.CORR.BK'
                GOSUB PROCESS.SEARCH.FIELD
                CCY = DEBIT.CURRENCY
                CHECK.ACCOUNT.CLASS = "VOSTRO"
                GOSUB CHECK.GLOBUS.CUSTOMER
*
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
*
        END CASE
    END
*
*-----------------------------
* Default Credit Currency
*-----------------------------
* If the credit account is not found, default credit currency from debit currency
    IF NOT(INDEX(R.OFS.DATA,'CREDIT.ACCT.NO',1)) AND CREDIT.CURRENCY THEN
        R.OFS.DATA := 'CREDIT.CURRENCY:1:1=':CREDIT.CURRENCY:','
    END
*-----------------------------
*
* Usage:3 To Default fields from existing fields (ie., replicate the data in one field to another)
* -------
*
*       FIELD.TO.FIND.ALL = 'field name to find':'*':'field name to default'
*       GOSUB DEFAULT.FIELDS
*
* The above variable FIELD.TO.FIND.ALL should contain 'field name to find' which will be
* searched in DE.I.ALL.FIELD.DATA and will be defaulted in 'field name to default'.  Note that
* both the field names should be separated by '*'.  Several values can be defaulted at the same
* time by separating FIELD.TO.FIND.ALL by field markers.
* For Eg:-
*       FIELD.TO.FIND.ALL = 'IN.ORDERING.BK':'*':'ORDERING.BANK'
*       FIELD.TO.FIND.ALL<-1> ='IN.BEN.ACCT.NO':'*':'BEN.ACCT.NO'
* In these examples, if IN.ORDERING.BK is found in DE.I.ALL.FIELD.DATA, then its contents
* will be defaulted to field ORDERING.BANK.  Also,  IN.BEN.ACCT.NO will be defaulted to BEN.ACCT.NO
*
* Usage:4 To search for a value alone in DE.I.ALL.FIELD.DATA but not default to other fields,
* -------
*
*       FIELD.TO.FIND = '"':'fieldname':'"'
*       GOSUB PROCESS.SEARCH.FIELD
*
* The field name specified in FIELD.TO.FIND will be searched in DE.I.ALL.FIELD.DATA and
* the contents will be returned in FIELD.TO.SEARCH.DATA variable
*
*
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

    FIELD.TO.FIND = QUOTE(FIELD( FIELD.FIND.DEFAULT,'*',1))
    FIELD.TO.DEFAULT = FIELD(FIELD.FIND.DEFAULT,'*',2)
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        IN.DEFAULT.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN IN.DEFAULT.DATA
        NO.REP = 1
        LOOP
            REMOVE DATA.TO.DEF FROM IN.DEFAULT.DATA SETTING DEF.POS
        WHILE DATA.TO.DEF:DEF.POS

            DATA.TO.DEF = QUOTE(DATA.TO.DEF)
            R.OFS.DATA :=FIELD.TO.DEFAULT:':':NO.REP:'=':DATA.TO.DEF:','

            NO.REP +=1
        REPEAT

    END
RETURN

************************************************************************
PROCESS.SEARCH.FIELD:
*************************************************************************
* Search for a field in DE.I.ALL.FIELD.DATA and return its contents

    FIELD.TO.SEARCH.DATA = ''
    FIELD.TO.FIND = QUOTE(FIELD.TO.FIND)
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        FIELD.TO.SEARCH.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN FIELD.TO.SEARCH.DATA
    END
*
RETURN
**************************************************************************
DETERMINE.TXN.TYPE:
*
* Determine the transaction type option from the available combination of fields
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.
*

* If there is data in ACCT.WITH.BK then it's an OT type of transaction
    ACCT.WITH.FOUND = INDEX( R.OFS.DATA, "ACCT.WITH.BK", 1)

* Identify if the Payment is from a third Party & not our correspondent
    THIRD.PARTY.FOUND = INDEX( R.OFS.DATA, "IN.REC.CORR.BK", 1)

* Determine Transaction types
    BEGIN CASE
        CASE THIRD.PARTY.FOUND AND NOT(ACCT.WITH.FOUND)
            FT.TXN.OPTION.NO = 4

        CASE NOT(THIRD.PARTY.FOUND) AND ACCT.WITH.FOUND
            FT.TXN.OPTION.NO = 3

        CASE THIRD.PARTY.FOUND AND ACCT.WITH.FOUND
            FT.TXN.OPTION.NO = 2

        CASE 1
            FT.TXN.OPTION.NO = 1

    END CASE

    TRANS.TYPE = ''
    ER = ''
    R.DE.I.FT.TXN.TYPES = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
    TRANS.TYPE = R.DE.I.FT.TXN.TYPES<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
    FT.TXN.TYPE = TRANS.TYPE<1,FT.TXN.OPTION.NO>

    IF FT.TXN.TYPE EQ '' THEN
        MESSAGE.ERROR<-1> = 'MISSING TRANSACTION TYPE - IN DE.I.FT.TXN.TYPES FILE'
    END ELSE
        R.OFS.DATA = 'TRANSACTION.TYPE:1:1=':FT.TXN.TYPE:',':R.OFS.DATA
    END

RETURN
*
**************************************************************************
CHECK.GLOBUS.CUSTOMER:
*
    CUSTOMER = ''
    IF DCOUNT(FIELD.TO.SEARCH.DATA,@FM) = 1 THEN
        customerKey = FIELD.TO.SEARCH.DATA
        exists = ''
        CALL CustomerService.checkExists(customerKey, exists)
        IF NOT(exists<Exists.valid>) THEN
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
*
DE.I.GET.ACCOUNT.NO:

    CUSTOMER.NO = CUSTOMER
    TXN.TYPE = ''
    OFS.DATA = ''
    ACCOUNT = ''
    ACCOUNT.NO = ''
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

    IF CHECK.ACCOUNT.CLASS = "VOSTRO" THEN
        IF ACCOUNT.NO THEN
            OFS.DATA = OFS.DATA : "DEBIT.ACCT.NO" :'=' :ACCOUNT.NO
        END
    END ELSE
        IF ACCOUNT.NO THEN
            OFS.DATA = OFS.DATA : "CREDIT.ACCT.NO" :'=' :ACCOUNT.NO
        END
    END

    IF OFS.DATA THEN R.OFS.DATA := OFS.DATA:","

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

    IF DE.TAG.ID EQ '' THEN RETURN

    R.DE.I.SUBROUTINE.TABLE = ''
    DE.I.FIELD.DATA = ''
    SET.ERROR = ''

    R.DE.I.SUBROUTINE.TABLE = DE.Messaging.ISubroutineTable.Read(DE.TAG.ID, TAG.ERR)

    IF TAG.ERR THEN
        SET.ERROR = "TAG ROUTINE FOR ":DE.TAG.ID:" - MISSING"
    END ELSE

        SUBROUTINE.ID = R.DE.I.SUBROUTINE.TABLE<DE.Messaging.ISubroutineTable.SrTbSubroutine>
        OFS.DATA = ''
        COMPILED.OR.NOT = ''

        EB.API.CheckRoutineExist(SUBROUTINE.ID, COMPILED.OR.NOT, R.ERR)

        IF NOT(COMPILED.OR.NOT) THEN
            SET.ERROR = "SUBROUTINE FOR TAG ":DE.TAG.ID:" NOT COMPILED"
        END ELSE
            CALL @SUBROUTINE.ID (SEQUENCED.TAGS<TAG.FIELD.NO>,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','', DE.I.FIELD.DATA, SET.ERROR)
            IF OFS.DATA NE '' THEN
                R.OFS.DATA := OFS.DATA:","
                DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA
            END
        END
    END

    IF SET.ERROR THEN MESSAGE.ERROR<-1> = SET.ERROR

RETURN

END
