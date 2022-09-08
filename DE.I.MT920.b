* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 1 25/06/02  GLOBUS Release No. G13.2.00 25/06/02
*-----------------------------------------------------------------------------
* <Rating>-213</Rating>
    $PACKAGE FT.Delivery
    SUBROUTINE DE.I.MT920
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*
*   MODIFICATIONS
*
* 06/02/04 -  BG_100006169
*             New Program
*
* 25/02/04 - BG_100006188
*            Bug fix for MT920 Enhancement
*
* 27/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 19/04/08 - CI_10054834/Ref: HD0808225
*            Inward swift message (IN.SWIFT.MSG) is not getting updated
*
* 17/05/10 - Task 27812 / Defect 25860
*            Added additional fields to DE.I.HEADER to store the header, trailer, inward transaction ref
*            and ofs request deatils id information.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 17/08/15 - Enhancement 1265068/ Task 1387507 
*          - Routine incorporated
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING DE.Inward
    $USING EB.DataAccess
    $USING DE.API
    $USING EB.Interface
    $USING EB.API
    $USING DE.ModelBank
    $USING DE.Messaging
    $USING EB.SystemTables

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE

* Message Header Processing

    GOSUB VALIDATE.MESSAGE.TYPE

    IF ERROR.COUNT GT 1 THEN
        * If error, no further processing
        GOSUB STORE.THE.MESSAGE
        GOSUB CALL.OFS.GLOBUS.MANAGER

        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED')
        REC.ID = DE.Inward.getRKey()
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')
        EB.SystemTables.setApplication(TEMP.APPLICATION)
        RETURN      ;* From main program
    END

    GOSUB IDENTIFY.THE.SENDER

* Generic Body Processing

    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)


* Method 2 - To generate multiple application records with the same core data and changing sequence data (use this OR method 1)

    TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
    TAG.VAL.COUNT = MAXIMUM.REPEATS<1>

    FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT

        GOSUB GET.TAG.SUB.COUNT         ;* BG_100013037 - S / E

        FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT

            GOSUB PROCESS.EACH.FIELD    ;* BG_100013037 - S / E


            GOSUB ADD.NON.TAG.FIELDS    ;* Specific Application Record Processing

            IF MESSAGE.ERROR THEN
                GOSUB STORE.TAG.ERRORS  ;* Store the errors
                R.OFS.DATA := TAG.ERROR.DATA
            END
            GOSUB CALL.OFS.GLOBUS.MANAGER

            R.OFS.DATA = ''
            MESSAGE.ERROR = ''
            TAG.ERROR.DATA = ''

        NEXT TAG.SUB.NO
    NEXT TAG.VAL.NO

* End of Method 2

* Further methods may be added here if a specific message-transaction scenarios require them

* STOP.THE.PROCESS:
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
    IF MESSAGE.TYPE NE '920' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT920'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('920.1.1', READ.ERROR)

    IF READ.ERROR THEN
        MESSAGE.ERROR = 'Message not found in DE.FORMAT.SWIFT FILE'
        GOSUB HOLD.ON.ERROR
    END

    RETURN

*************************************************************************

STORE.THE.MESSAGE:

* Store the inward message in the application.

    R.OFS.DATA := 'DIRECTION:1:1':'=':'INWARD':','
    R.OFS.DATA := 'IN.DELIVERY.REF:1:1=':DE.Inward.getRKey():','
    R.OFS.DATA := 'INSTITUTION:1:1=':SENDING.CUSTOMER:','

    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'IN.SWIFT.MSG=':IN.MSG.TYPE:',' ;* Store the message type

    FOR X = 1 TO MSG.FIELD.COUNT-1
        R.OFS.DATA := 'IN.SWIFT.MSG:':X:':="':IN.STORE.MSG<X>:'",'
        * Store the message
    NEXT X


    RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer

* Entire full address should be mapped as SENDERS.BIC.CODE.
*  SENDERS.BIC.CODE = SUBSTRINGS(R.HEAD(DE.HDR.FROM.ADDRESS),1,11)
    SENDERS.BIC.CODE = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)
*

    SAVE.SENDING.CUSTOMER = ''
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)
    SAVE.SENDING.CUSTOMER = SENDING.CUSTOMER      ;* May use later


* BG_100006188 - STARTS

* If SENDERS.BIC.CODE is not a valid BIC.CODE, then assign
* SENDING.CUSTOMER with the Incoming BIC.CODE to populate the
* INSTITUTION field in DE.STATEMENT.REQUEST.

    IF SENDING.CUSTOMER = '' THEN

        BEGIN CASE
            CASE LEN(SENDERS.BIC.CODE) = 12
                ADD.KEY = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
            CASE LEN(SENDERS.BIC.CODE) = 11 OR LEN(SENDERS.BIC.CODE) = 8
                ADD.KEY = SENDERS.BIC.CODE
            CASE LEN(SENDERS.BIC.CODE) = 9
                ADD.KEY = SENDERS.BIC.CODE[1,8]
        END CASE

        SENDING.CUSTOMER = "SW-":ADD.KEY

    END

* BG_100006188 - ENDS

    RETURN

*************************************************************************

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

STORE.OFS.ERRORS:

* Capture OFS errors and store along with the tag erros

    VM.CNT = ''

* MESSAGE.ERROR = ''
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

CALL.OFS.GLOBUS.MANAGER:

    R.OFS.DATA = OFS.PREFIX:R.OFS.DATA

    EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)
    T24.TRANS.REF<1,-1> = FIELD(R.OFS.DATA,'/',1) ;* Get the inward trans ref
    OFS.REQ.DET.ID<1,-1> = FIELD(R.OFS.DATA,'/',2)          ;* Get the ofs request detail id

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
    OFS.REQ.DET.ID = ''
    T24.TRANS.REF = ''

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

    OFS.PREFIX = K.VERSION:"/I,,,"

    IN.STORE.MSG = R.DE.I.MSG
    CRLF = CHARX(013):CHARX(010)
    CONVERT CRLF TO @FM IN IN.STORE.MSG
    MSG.FIELD.COUNT = DCOUNT(IN.STORE.MSG,@FM)

    TXN.REFERENCE = ''

    RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:

* Lookup existing data from SWIFT Tags in the OFS record (e.g. Dr Currency)
    IF TAG.VAL.NO = 1 THEN
        GOSUB STORE.MAIN.SEQ.INFO
    END ELSE
        IF TXN.REFERENCE THEN
            R.OFS.DATA := 'IN.TRANS.REF:1:1':'=':QUOTE(TXN.REFERENCE):','
        END
    END

*
    GOSUB STORE.THE.MESSAGE   ;* Store the inward message in  the appllication
*


    RETURN

**************************************************************************
PROCESS.SEARCH.FIELD:
*************************************************************************

    FIELD.TO.SEARCH.DATA = ''
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        FIELD.TO.SEARCH.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN FIELD.TO.SEARCH.DATA
    END
    RETURN

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
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037  - E
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
            CALL @SUBROUTINE.ID (DE.TAG.ID,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','',DE.I.FIELD.DATA, SET.ERROR)
            IF OFS.DATA NE '' THEN
                R.OFS.DATA := OFS.DATA:","
                DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA
            END
        END
    END

    IF SET.ERROR THEN
        MESSAGE.ERROR<-1> = SET.ERROR   ;* BG_100013037 - S
    END   ;* BG_100013037 - E

    RETURN

*************************************************************************
STORE.MAIN.SEQ.INFO:
*******************************************************************************

    FIELD.TO.FIND = 'IN.TRANS.REF'
    GOSUB PROCESS.SEARCH.FIELD
    TXN.REFERENCE = FIELD.TO.SEARCH.DATA

    RETURN

**************************************************************************
* BG_100013037 - E
*=================
GET.TAG.SUB.COUNT:
*=================
    FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT

        * Single repetitive fields should be handled only within the tag routine.
        * Hence don't consider the sub values single repetitive sequence field.
        MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
        IF MULTIPLE.FIELD.NO[1,1] NE 'R' THEN
            FIELD.SUB.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
            IF FIELD.SUB.VALS > TAG.SUB.COUNT THEN
                TAG.SUB.COUNT = FIELD.SUB.VALS
            END
        END
    NEXT TAG.FIELD.NO
    RETURN
**************************************************************************
*===================
PROCESS.EACH.FIELD:
*===================
    FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT

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

        BLANK.REPEAT.FIELD = 0
        IF MULTIPLE.TAG<TAG.FIELD.NO>[1,2] GT 0 THEN
            IF FIELD.VALS<TAG.VAL.NO OR FIELD.SUBS<TAG.SUB.NO THEN
                BLANK.REPEAT.FIELD = 1
            END
        END
        * The values of single repetitive sequcene field should be handled within
        * the tag routine and it should be separated by VM s.

        MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
        IF MULTIPLE.FIELD.NO[1,1] = 'R' AND SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.NO> THEN
            DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.IDX>[1,2]
            SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.IDX>
            DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX>
            CONVERT @SM TO @VM IN DE.TAG.SEQ.MSG

            GOSUB CALL.SUBROUTINE

        END ELSE

            IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' AND BLANK.REPEAT.FIELD = 0 THEN

                DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
                SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
                DE.TAG.ID = SEQ.TAG.ID[1,2]
                GOSUB CALL.SUBROUTINE
            END
        END


    NEXT TAG.FIELD.NO
    RETURN          ;* BG_100013037 - E
**************************************************************************
    END
