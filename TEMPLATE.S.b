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

*-----------------------------------------------------------------------------
* <Rating>-265</Rating>
*-----------------------------------------------------------------------------
* Version 1 25/06/02  GLOBUS Release No. 200508 29/07/05
*
    $PACKAGE DE.API
    SUBROUTINE TEMPLATE.S
*
*************************************************************************
* Inward delivery template                                              *
*                                                                       *
* While usage of this template structure, the subroutine name should    *
* be in the format DE.I.MTXXX.                                          *
* For eg., DE.I.MT200 for processing all MT200 Inward messages and      *
* DE.I.MT103 to process MT103 inward messages                           *
*                                                                       *
*************************************************************************
*                                                                       *
*   MODIFICATIONS                                                       *
*                                                                       *
* 10/07/02 - EN_10000786                                                *
*            New Program                                                *
*                                                                       *
* 08/10/02 - BG_100002295
*            In Method 2, the Message should be obtained from TAG.VAL.IDX
*             and TAG.SUB.IDX & not TAG.VAL.NO and TAG.SUB.NO respectively.
*
* 20/08/15 - Enhancement 1265068/ Task 1464647
*          - Routine incorporated
*
*************************************************************************

    $USING EB.SystemTables
    $USING EB.API
    $USING DE.Config
    $USING DE.Inward
    $USING DE.Messaging
    $USING FT.Delivery
    $USING FT.Contract
    $USING DE.ModelBank
    $USING ST.Config
    $USING DE.API
    $USING EB.DataAccess
    $USING EB.Interface

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
*   TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
*   FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT
*
* There is possiblity for single repetitive sequences. In such case the
* tag routine can decide how to handle it.
*
*         DE.TAG.ID = '' ; DE.TAG.SEQ.MSG = ''
*         MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
*
*   IF MULTIPLE.FIELD.NO[1,1] = 'R' THEN
*
*         DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
*         DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO>
*         GOSUB CALL.SUBROUTINE
*
*   END ELSE
*
*       TAG.VAL.COUNT = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO>,@VM)
*       FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT
*           TAG.SUB.COUNT = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
*           FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT
*               IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO,TAG.SUB.NO> NE '' THEN
*              DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
*              DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO,TAG.SUB.NO>
*            GOSUB CALL.SUBROUTINE
*           NEXT TAG.SUB.NO
*       NEXT TAG.VAL.NO
*
*   END
*
*   NEXT TAG.FIELD.NO
*
*   GOSUB ADD.NON.TAG.FIELDS                                 ; * Specific Application Record Processing
*
*      IF MESSAGE.ERROR THEN
*         GOSUB STORE.TAG.ERRORS        ; * Store the errors
*         R.OFS.DATA := TAG.ERROR.DATA
*      END
*
*   GOSUB CALL.OFS.GLOBUS.MANAGER
*
* End of Method 1

* Method 2 - To generate multiple application records with the same core data and changing sequence data (use this OR method 1)
*
*   TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
*   TAG.VAL.COUNT   = MAXIMUM.REPEATS<1>
*
*   FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT
*
*       TAG.SUB.COUNT = 0
*
*       FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT
*           FIELD.SUB.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
*           IF FIELD.SUB.VALS > TAG.SUB.COUNT THEN
*               TAG.SUB.COUNT = FIELD.SUB.VALS
*           END
*       NEXT TAG.FIELD.NO
*
*       FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT
*
*           FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT
*
*               FIELD.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO>,@VM)
*               IF FIELD.VALS < TAG.VAL.NO THEN
*                   TAG.VAL.IDX = FIELD.VALS
*               END ELSE
*                   TAG.VAL.IDX = TAG.VAL.NO
*               END
*               FIELD.SUBS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX>,@SM)
*               IF FIELD.SUBS < TAG.SUB.NO THEN
*                   TAG.SUB.IDX = FIELD.SUBS
*               END ELSE
*                   TAG.SUB.IDX = TAG.SUB.NO
*               END
*
*               IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' THEN
*               DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
*               DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
*               GOSUB CALL.SUBROUTINE
*                  END
*
*           NEXT TAG.FIELD.NO
*
*           GOSUB ADD.NON.TAG.FIELDS                         ; * Specific Application Record Processing
*
*      IF MESSAGE.ERROR THEN
*         GOSUB STORE.TAG.ERRORS        ; * Store the errors
*         R.OFS.DATA := TAG.ERROR.DATA
*      END
*
*           GOSUB CALL.OFS.GLOBUS.MANAGER
*
*
*       NEXT TAG.SUB.NO
*
* Re-initialise the variables
*       R.OFS.DATA = ''
*       MESSAGE.ERROR = ''
*       TAG.ERROR.DATA = ''
*
*   NEXT TAG.VAL.NO

* End of Method 2

* Further methods may be added here if a specific message-transaction scenarios require them

STOP.THE.PROCESS:

    DE.Inward.setRHead(DE.Config.OHeader.HdrDisposition, 'OFS FORMATTED')
    REC.ID = DE.Inward.getRKey()
    R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
    DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

    EB.SystemTables.setApplication(TEMP.APPLICATION)

    RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

VALIDATE.MESSAGE.TYPE:

* Check if the message is valid type and retrieve message format information

    MESSAGE.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)

    IF MESSAGE.TYPE NE '???' THEN      ; * Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT???'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('???.1.1', READ.ERROR)

    IF READ.ERROR THEN
        MESSAGE.ERROR = 'Message not found in DE.FORMAT.SWIFT FILE'
        GOSUB HOLD.ON.ERROR
    END

    RETURN

*************************************************************************
STORE.THE.MESSAGE:

* Store the inward message in the application.

    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'field.name=':IN.DEL.KEY:','   ; * Store delivery ref

    IN.MSG.TYPE = 'MT':DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'field.name=':IN.MSG.TYPE:','  ; * Store the message type

    FOR X = 1 TO MSG.FIELD.COUNT-1
        R.OFS.DATA := 'field.name:':X:':="':IN.STORE.MSG<X>:'",'      ; * Store the message
    NEXT X

    RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer

    SENDERS.BIC.CODE = SUBSTRINGS(DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress),1,11)
    SAVE.SENDING.CUSTOMER = ''
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)
    SAVE.SENDING.CUSTOMER = SENDING.CUSTOMER     ; * May use later

    RETURN

*************************************************************************

HOLD.ON.ERROR:

* Processing when an error is found in the message.

    R.OFS.DATA := 'field.name:':ERROR.COUNT:'="':MESSAGE.ERROR:'",'

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
        TAG.ERROR.DATA := 'field.name:':CNT:'="':MESSAGE.ERROR<CNT>:'",'
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
        *         OFS.ERR = ERR.REASON<CNT>[1,??]
        *         R.OFS.DATA := 'field.name:':VM.CNT:'="':OFS.ERR:'",'
    NEXT CNT

    RETURN

*************************************************************************
CALL.OFS.GLOBUS.MANAGER:

    R.OFS.DATA = OFS.PREFIX:R.OFS.DATA

    EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)

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

* Open Files

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)

    FN.DE.I.MSG = "F.DE.I.MSG"
    F.DE.I.MSG.LOC = ""
    EB.DataAccess.Opf(FN.DE.I.MSG,F.DE.I.MSG.LOC)
    DE.Inward.setFDeIMsg(F.DE.I.MSG.LOC)

    FN.DE.MESSAGE = "F.DE.MESSAGE"
    F.DE.MESSAGE.LOC=""
    EB.DataAccess.Opf(FN.DE.MESSAGE,F.DE.MESSAGE.LOC)
    DE.Inward.setFDeMessage(F.DE.MESSAGE.LOC)

    FN.DE.FORMAT.SWIFT = "F.DE.FORMAT.SWIFT"
    F.DE.FORMAT.SWIFT.LOC=""
    EB.DataAccess.Opf(FN.DE.FORMAT.SWIFT,F.DE.FORMAT.SWIFT.LOC)
    DE.Inward.setFDeFormatSwift(F.DE.FORMAT.SWIFT.LOC)

    FN.DE.I.FT.TXN.TYPES = "F.DE.I.FT.TXN.TYPES"
    F.DE.I.FT.TXN.TYPES=""
    EB.DataAccess.Opf(FN.DE.I.FT.TXN.TYPES,F.DE.I.FT.TXN.TYPES)

    FN.DE.I.SUBROUTINE.TABLE = "F.DE.I.SUBROUTINE.TABLE"
    F.DE.I.SUBROUTINE.TABLE=""
    EB.DataAccess.Opf(FN.DE.I.SUBROUTINE.TABLE,F.DE.I.SUBROUTINE.TABLE)

    R.DE.I.MSG = ''
    REC.ID = DE.Inward.getRKey()
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(REC.ID, ER)
    EB.SystemTables.setE(ER)

    R.DE.MESSAGE = ''
    REC.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(REC.ID, ER)
    EB.SystemTables.setE(ER)

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    OFS.PREFIX = K.VERSION:"/I,,,"

    IN.STORE.MSG = R.DE.I.MSG
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

*       OFS.DATA = ''        ; * Re-initialise

* Set Transaction type
*   GOSUB DETERMINE.TXN.TYPE
*
* Store the inward message, delivery ref, msg type in the appllication
*   GOSUB STORE.THE.MESSAGE
*
* Usage:1 Lookup existing data from SWIFT Tags in the OFS record (e.g. Dr Currency)
* -------
*
*   DEBIT.CURRENCY.FOUND = INDEX( R.OFS.DATA, "DEBIT.CURRENCY", 1)
*   IF DEBIT.CURRENCY.FOUND THEN
*       CCY = SUBSTRINGS( R.OFS.DATA, DEBIT.CURRENCY.FOUND+15, 3)
*   END
*
* Usage:2 Example processing for FT CREDIT.ACCOUNT field - uses existing data and
* ------- calls a subroutine to determine the field
*
*   CR.ACCT.FOUND = INDEX(R.OFS.DATA,"CREDIT.ACCT.NO",1)
*
*   IF CR.ACCT.FOUND = 0 THEN
*       IN.CCY       =  CCY
*       IN.APP       =  'FT'
*       IN.ACCT      =  ''
*       IN.TXN       =  FT.TXN.TYPE
*       OUT.CCY      =  ''
*       OUT.COMP     =  ''
*       OUT.ACCT     =  ''
*       OUT.REGION   =  ''
*       OUT.TXN      =  ''
*       RETURN.CODE  =  ''
*       ABBR         =  ''
*       ST.Config.GetNostro(IN.CCY, IN.APP, IN.ACCT, IN.TXN, OUT.CCY, OUT.COMP, OUT.ACCT, OUT.REGION, OUT.TXN, RETURN.CODE, ABBR)
*       R.OFS.DATA := 'CREDIT.ACCT.NO=':OUT.ACCT:','
*   END

* NEXT FIELD

*   R.OFS.DATA := 'field name=':field data:','   ; * add field routine here

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
*       FIELD.TO.FIND = 'fileld name'
*       GOSUB PROCESS.SEARCH.FIELD
*
* The field name specified in FIELD.TO.FIND will be searched in DE.I.ALL.FIELD.DATA and
* the contents will be returned in FIELD.TO.SEARCH.DATA variable
*
*
    RETURN

**************************************************************************
DEFAULT.FIELDS:
* Defaulting of fields are done here. DE.I.ALL.FIELD.DATA will have the
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

    FIELD.TO.FIND = QUOTE( FIELD( FIELD.FIND.DEFAULT,'*',1))
    FIELD.TO.DEFAULT = FIELD(FIELD.FIND.DEFAULT,'*',2)
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        IN.DEFAULT.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN IN.DEFAULT.DATA
        NO.REP = 1
        LOOP
            REMOVE DATA.TO.DEF FROM IN.DEFAULT.DATA SETTING DEF.POS
        WHILE DATA.TO.DEF:DEF.POS

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
*   BEGIN CASE
*
*        CASE ???
*           FT.TXN.OPTION.NO = 1
*
*        CASE ???
*           FT.TXN.OPTION.NO = 2
*
*        CASE ???
*           FT.TXN.OPTION.NO = 3
*
*   CASE 1
*       FT.TXN.OPTION.NO = 1
*
*   END CASE

*   TRANS.TYPE = ''
*   ER = ''
*   R.REC = FT.Delivery.DeiFtTxnTypes.Read(MESSAGE.TYPE, ER)
*   TRANS.TYPE = R.REC<FT.Delivery.DeiFtTxnTypes.DeiTxnFtTxnType>
*   FT.TXN.TYPE = TRANS.TYPE<1,FT.TXN.OPTION.NO>
*
*    IF FT.TXN.TYPE EQ '' THEN
*         MESSAGE.ERROR<-1> = 'MISSING TRANSACTION TYPE - IN DE.I.FT.TXN.TYPES FILE'
*    END ELSE
*         R.OFS.DATA = 'TRANSACTION.TYPE:1:1=':FT.TXN.TYPE:',':R.OFS.DATA
*    END
*
*    RETURN
*
**************************************************************************
CALL.SUBROUTINE:
**************************************************************************

* Process each tag routine
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.
*
*      IF DE.TAG.ID EQ '' THEN RETURN
*
*      R.DE.I.SUBROUTINE.TABLE = ''
*      DE.I.FIELD.DATA = ''
*      SET.ERROR = ''
*
*      R.DE.I.SUBROUTINE.TABLE = DE.Messaging.ISubroutineTable.Read(DE.TAG.ID, TAG.ERR)
*
*      IF TAG.ERR THEN
*         SET.ERROR = "TAG ROUTINE FOR ":DE.TAG.ID:" - MISSING"
*      END ELSE
*
*         SUBROUTINE.ID = R.DE.I.SUBROUTINE.TABLE<DE.Messaging.ISubroutineTable.SrTbSubroutine>
*         OFS.DATA = ''
*         COMPILED.OR.NOT = ''
*         EB.API.CheckRoutineExist(SUBROUTINE.ID, COMPILED.OR.NOT, R.ERR)
*
*         IF NOT(COMPILED.OR.NOT) THEN
*            SET.ERROR = "SUBROUTINE FOR TAG ":DE.TAG.ID:" NOT COMPILED"
*         END ELSE
*            CALL @SUBROUTINE.ID (SEQUENCED.TAGS<TAG.FIELD.NO>,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','', DE.I.FIELD.DATA, SET.ERROR)
*            IF OFS.DATA NE '' THEN
*               R.OFS.DATA := OFS.DATA:","
*               DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA
*            END
*         END
*      END
*
*      IF SET.ERROR THEN MESSAGE.ERROR<-1> = SET.ERROR
*
*    RETURN
*
*    END
