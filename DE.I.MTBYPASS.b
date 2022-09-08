* @ValidationCode : MjoxNjUzMTA3NzAzOkNwMTI1MjoxNTc5MjU4OTk2NDQwOnZhbmthd2FsYWhlZXI6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMS4yMDE5MTAyNC0wMzM1OjEyODoxMTQ=
* @ValidationInfo : Timestamp         : 17 Jan 2020 16:33:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vankawalaheer
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 114/128 (89.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191024-0335
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-94</Rating>
*-----------------------------------------------------------------------------
* Version 1 25/06/02  GLOBUS Release No. 200508 30/06/05
$PACKAGE DE.Messaging
SUBROUTINE DE.I.MTBYPASS
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*                                                                       *
*   MODIFICATIONS                                                       *
*                                                                       *
* 10/7/02 - GLOBUS_EN_10000786                                          *
*           New Program                                                *
*                                                                       *
* 01/09/03 - CI_10012201
*            The Sending Bank should populate 11 characters
*            (ie: leaving out the 9th character) of the address
*            from the header file
*
* 17/05/10 - Task 27812 / Defect 25860
*            Added additional fields to DE.I.HEADER to store the header, trailer, inward transaction ref
*            and ofs request deatils id information.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 13/10/15 - Defect 1485285 / Task  1499708
*            The service BNK/SWIFT.IN crashes and incoming message could not be formatted while processing
*            MT299 SWIFTmessage due to tag 21 starting with a space
*
* 11/10/18 - Defect 2799043 / Task 2804593
*            When inward 199 message is processed, system properly updates OFS.REQ.DET.KEY,
*            T24.INW.TRANS.REF and DISPOSITION fields in DE.I.HEADER record.
*
* 15/07/29 - Enhancement 3210414 / Task 3210418
*            Mapping of newly added fields 'SenderAddr/UetrRef/ServiceTypeId' in EB.FREE.MESSAGE
*            as part of the enhancement 'Process Gpi Confirmations".
*
* 30/12/2019 - Enahancement 3517938 / Task 3517944
*              Mapping of AnswerCode and IsoReasonCode for inward 199.
*
* 10/01/2020 - Enhancement 3517938 / Task 3529902
*              Added condition for ServiceTypeIdentifier,If ServiceTypeId is 002 then only map the IsoReasonCode and AnswerCode
*
* 17/01/2020 - Defect 3531695 / Task 3540809
*              When service type identifier is 002 then also map to TEXT field of EBFM
*************************************************************************

    $USING DE.Config
    $USING DE.Inward
    $USING EB.Interface
    $USING DE.API
    $USING DE.Messaging
    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING ER.Api

    GOSUB INITIALISE

* Message Header Processing

    GOSUB VALIDATE.MESSAGE.TYPE

    GOSUB IDENTIFY.THE.SENDER

* Generic Body Processing
    R.DE.I.MSG.REC = R.DE.I.MSG

    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)

    GOSUB ADD.NON.TAG.FIELDS  ;* Specific Application Record Processing

    GOSUB ADD.MSG.TAG.FIELDS

    EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)

* Further methods may be added here if a specific message-transaction scenarios require them
    DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, FIELD(R.OFS.DATA,'/',2));* Store the ofs request details id
    DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, FIELD(R.OFS.DATA,'/',1));* Inward T24 trans ref
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
RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer
* CI_10012201 - S
* The Sending Bank should populate full address
    SENDERS.BIC.CODE = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)
* CI_10012201 - E
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)

RETURN

*************************************************************************

INITIALISE:

* Initialise variables
    DEFFUN CHARX()
    FIELD.TO.FIND = ''
    FIELD.TO.DEFAULT = ''
    SWIFT.TAG.NO = ''
    SWIFT.TAG.DATA = ''
    MESSAGE.ERROR = ''
    ERROR.COUNT = 1


* Open Files

    R.DE.I.MSG = ''
    MSG.ID = DE.Inward.getRKey()
    ER = ''
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    R.DE.MESSAGE = ''
    ER = ''
    MESSAGE.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(MESSAGE.TYPE, ER)
    EB.SystemTables.setE(ER)
    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    R.OFS.DATA = K.VERSION:"/I,,,"

* Call to ErGpiEnableProcess to block/unblock gpi confirmation
    EnableProcess = "GPI.CONFIRMATION"
    ER.Api.ErGpiEnableProcess(EnableProcess)
    UETR.REFERENCE = ''
    IN.HEAD.TRAIL = ''
    SVC.TYPE.ID.TAG = ''
    SVC.TYPE.ID = ''

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:


* Required fields for EB.FREE.MESSAGE application

    IF SENDING.CUSTOMER = '' THEN
*
* CI_10012201 - S
* Check for various length of the BIC.CODE & accordingly choose the
* appropriate character code.
        GOSUB EXTRACT.BIC.CODE ; *Extract BIC code
* CI_10012201 - E
*
        SENDING.CUSTOMER = 'SW-':SENDERS.BIC.CODE
        SEND.FIELD = 'RECV.ADDR='
    END ELSE
        SEND.FIELD = 'CUSTOMER.NO='
    END

    R.OFS.DATA := SEND.FIELD:SENDING.CUSTOMER:','

*
    IN.DEL.KEY = DE.Inward.getRKey()
    R.OFS.DATA := 'IN.DEL.REF=':IN.DEL.KEY:','
    IN.MSG.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.OFS.DATA := 'EB.ADVICE.NO=EB-0':IN.MSG.TYPE:','
    R.OFS.DATA := 'DIRECTION=INWARD,'
    
    IF NOT(EnableProcess) THEN
        GOSUB EXTRACT.BIC.CODE ; *Extract BIC code
        R.OFS.DATA := 'SENDER.ADDR=':SENDERS.BIC.CODE:','   ;* Mapping of SenderAddr
        
        UETR.REFERENCE = DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference) ;* Get UetrRef
        R.OFS.DATA := 'UETR.REF=':UETR.REFERENCE:','    ;* Mapping of UetrRef
        
        IN.HEAD.TRAIL = DE.Inward.getRHead(DE.Config.IHeader.HdrInwHeadTrail)   ;* Get Inward HeadTrail value
        SVC.TYPE.ID.TAG = FIELD(IN.HEAD.TRAIL, '111:', 2)
        SVC.TYPE.ID = FIELD(SVC.TYPE.ID.TAG, '}', 1)    ;* Extract the value in tag 111
        R.OFS.DATA := 'SERVICE.TYPE.ID=':SVC.TYPE.ID:','    ;* Mapping of ServiceTypeId
    END

RETURN

**************************************************************************

ADD.MSG.TAG.FIELDS:
    DE.Inward.StripMsg(R.DE.I.MSG.REC,SWIFT.TAG.NO,SWIFT.DATA)
    NO.TAGS=DCOUNT(SWIFT.TAG.NO,@VM)     ;*Number of tags for message...

    FOR POS.TAG = 1 TO 3
        TAG.NO=SWIFT.TAG.NO<1,POS.TAG>  ;*Tag Number...
        FLD.DATA=SWIFT.DATA<1,POS.TAG>  ;*Data for field...

        BEGIN CASE
            CASE TAG.NO = "20"    ;* Senders Reference
                TAG.20 = FLD.DATA
                R.OFS.DATA := 'THEIR.REFERENCE=':TAG.20

            CASE TAG.NO = "21"    ;* Related Reference
                TAG.21 = FLD.DATA
                TAG.21.TRIM = TRIM(TAG.21, "", "F")             ;* if TAG21 contain any spaces removing that spaces
                R.OFS.DATA := ',OUR.REFERENCE=':TAG.21.TRIM

            CASE TAG.NO = "79"    ;* Narrative
                IF SVC.TYPE.ID EQ '002' AND MESSAGE.TYPE EQ '199' THEN ;*If ServiceTypeId and MessageType is 199
                    CRLF=CHARX(013):CHARX(010)
                    TAG.79 = FLD.DATA
                    TAG.79 = CONVERT(CRLF,@FM,TAG.79)
                    SwiftCodeWordDetails<DE.API.SwiftIsoCodeWord> = TAG.79<1> ;*Get the Value of TAG.79<1> in SwiftIsoCodeWord
                    DE.API.DeGetSwiftIsoCode(SwiftCodeWordDetails, SwiftCodeWord, Reserved1, Reserved2)
                    IF SwiftCodeWord<DE.API.AnswerCode> THEN ;*If AnswerCode is there then map to ACCEPT.REJECT field of EBFM
                        R.OFS.DATA := ',ACCEPT.REJECT=':SwiftCodeWord<DE.API.AnswerCode>
                    END
                    IF SwiftCodeWord<DE.API.IsoReasonCode> THEN ;*iF iSOrEASONcODE is there then map to ISO.REASON.CODE field of EBFM
                        R.OFS.DATA := ',ISO.REASON.CODE=':SwiftCodeWord<DE.API.IsoReasonCode>
                    END
                    AGENT.BIC = FIELD(TAG.79<2>,'/',2) ;*Get the AGENT.BIC value from TAG.79
                    IF AGENT.BIC THEN
                        R.OFS.DATA := ',FORWARDED.TO.AGENT.BIC=':AGENT.BIC
                    END
                END
                CRLF=CHARX(013):CHARX(010)
                TAG.79 = FLD.DATA

                NO.OF.DATA = ''
                NO.OF.DATA = DCOUNT(TAG.79,CRLF)
                TAG.79 = CONVERT(CRLF,@VM,TAG.79)
                TAG.79 = CHANGE(TAG.79,'//','/ /')
                FOR I = 1 TO NO.OF.DATA
                    R.OFS.DATA := ',TEXT:':I:':='
                    R.OFS.DATA := '"':TAG.79<1,I>:'"'
                NEXT I
                
*            R.OFS.DATA := 'TEXT=':TAG.79:','
        END CASE

    NEXT POS.TAG

RETURN
**************************************************************************
*** <region name= EXTRACT.BIC.CODE>
EXTRACT.BIC.CODE:
*** <desc>Extract BIC code </desc>

    BEGIN CASE
        CASE LEN(SENDERS.BIC.CODE) = 12
            SENDERS.BIC.CODE = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
        CASE LEN(SENDERS.BIC.CODE) = 11 OR LEN(SENDERS.BIC.CODE) = 8
            SENDERS.BIC.CODE = SENDERS.BIC.CODE
        CASE LEN(SENDERS.BIC.CODE) = 9
            SENDERS.BIC.CODE = SENDERS.BIC.CODE[1,8]
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

END

