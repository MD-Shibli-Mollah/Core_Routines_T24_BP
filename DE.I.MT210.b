* @ValidationCode : Mjo0MDE1ODkwOTI6Q3AxMjUyOjE1OTM0OTQ0NDM2MjA6YnNhdXJhdmt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1Oi0xOi0x
* @ValidationInfo : Timestamp         : 30 Jun 2020 10:50:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE FT.Delivery
SUBROUTINE DE.I.MT210
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*                                                                       *
*   MODIFICATIONS                                                       *
*                                                                       *
* 10/07/02 -  EN_10000786                                               *
*            New Program                                                *
*                                                                       *
* 08/10/02 - BG_100002295
*            Call SUBROUTINE only if the tag routine is specified in
*            DE.I.SUBROUTINE.TABLE.

*
* 16/07/03 - CI_10010874
*            The dimension array R.MESSAGE was increased to
*            last field in the record, namely AUDIT.DATE.TIME
*            to aviod the system being fatalling out with
*            "Array subscript out of range" message.
*
* 05/01/04 - CI_10016284
*            Messages goes to repair if incoming 210 contains multiple sequence
*
* 27/02/07 - BG_100013037
*            CODE.REVIEW changes.
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
*
* 08/08/18 - Enhancement-2702846
*            Task-2703534
*            Movement from AC to ER.
*
* 03/09/18 - Enhancement 2719154 / Task 2722527
*            Map values from incoming 210 to new fields of AC.EXPECTED.RECS
*
* 08/11/18 - Defect 2846446 / Task 2846524
*            Map value from ORG.CORRESP.BIC to CORRESP.BIC
*
* 23/01/19 - Task 2957554
*            Changes in updating the SENDER.BIC code
*
* 25/06/20 - Defect 3800081 / Task 3821227
*            Check added such that if ER.PARMETER record is not present then the message is put to "REPAIR" status.
*
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
    $USING DE.Inward
    $USING EB.Interface
    $USING EB.DataAccess
    $USING DE.API
    $USING DE.Outward
    $USING EB.API
    $USING DE.ModelBank
    $USING DE.Messaging
    $USING EB.SystemTables
    $USING ER.Config
    $USING AC.AccountOpening
    $USING AC.Config

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE
    
    IF YERR NE '' THEN ;*If ER.PARAMETER record not present then return.
        RETURN
    END

* Message Header Processing

    GOSUB VALIDATE.MESSAGE.TYPE

    GOSUB IDENTIFY.THE.SENDER

* Generic Body Processing

    DE.Inward.GetMsgStructure(MESSAGE.TYPE,R.DE.I.MSG,FIELD.TAGS,MULTIPLE.TAG,SEQUENCED.TAGS,SEQUENCED.MESSAGE,MAXIMUM.REPEATS)


* Method 2 - To generate multiple application records with the same core data and changing sequence data (use this OR method 1)

    TAG.FIELD.COUNT = DCOUNT(SEQUENCED.MESSAGE,@FM)
    TAG.VAL.COUNT = MAXIMUM.REPEATS<1>

    FOR TAG.VAL.NO = 1 TO TAG.VAL.COUNT

        TAG.SUB.COUNT = 0

        FOR TAG.FIELD.NO = 1 TO TAG.FIELD.COUNT
            FIELD.SUB.VALS = DCOUNT(SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.NO>,@SM)
            IF FIELD.SUB.VALS > TAG.SUB.COUNT THEN
                TAG.SUB.COUNT = FIELD.SUB.VALS
            END
        NEXT TAG.FIELD.NO

        FOR TAG.SUB.NO = 1 TO TAG.SUB.COUNT

            GOSUB PROCESS.EACH.TAG      ;* BG_100013037 - S / E

            GOSUB ADD.NON.TAG.FIELDS    ;* Specific Application Record Processing
            
            IF EXIT.FLAG THEN
                TAG.SUB.NO = TAG.SUB.COUNT
                TAG.VAL.NO = TAG.VAL.COUNT
                CONTINUE
            END

            EB.Interface.OfsGlobusManager(K.OFS.SOURCE,R.OFS.DATA)
            GOSUB GET.INFO    ;*Get the trans ref, ofs req details id to update DE.I.HEADER

        NEXT TAG.SUB.NO

        R.OFS.DATA = ''
        R.OFS.DATA = K.VERSION:"/I,,,"

    NEXT TAG.VAL.NO

    IF NOT(EXIT.FLAG) THEN
* Further methods may be added here if a specific message-transaction scenarios require them
        DE.Inward.setRHead(DE.Config.IHeader.HdrOfsReqDetKey, OFS.REQ.DET.ID);* Store the ofs request details id
        DE.Inward.setRHead(DE.Config.IHeader.HdrT24InwTransRef, T24.TRANS.REF);* Inward T24 trans ref
    END

* End of Method 2

    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED')
    REC.ID = DE.Inward.getRKey()
    R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
    DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')

    EB.SystemTables.setApplication(TEMP.APPLICATION)

RETURN          ;* From main program

************************************************************************
GET.INFO:
* Get the transaction ref and ofs.req detail id

    T24.TRANS.REF<1,-1> = FIELD(R.OFS.DATA,'/',1) ;* Get the inward trans ref
    OFS.REQ.DET.ID<1,-1> = FIELD(R.OFS.DATA,'/',2)          ;* Get the ofs request detail id

RETURN

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

VALIDATE.MESSAGE.TYPE:

* Check if the message is valid type and retrieve message format information

    MESSAGE.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    IF MESSAGE.TYPE NE '210' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT210'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.Read('210.1.1', READ.ERROR)

    IF READ.ERROR THEN
        MESSAGE.ERROR = 'Message not found in DE.FORMAT.SWIFT FILE'
        GOSUB HOLD.ON.ERROR
    END

RETURN

*************************************************************************

IDENTIFY.THE.SENDER:

* Check if the sender is a customer
    
    SENDERS.BIC.CODE = SUBSTRINGS(DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress),1,12)
    COMP.ID = EB.SystemTables.getIdCompany()
    DE.API.SwiftBic(SENDERS.BIC.CODE,COMP.ID,SENDING.CUSTOMER)
 
* Exclude the 9th char if the senders bic code is of 12 chars.
    IF LEN(SENDERS.BIC.CODE) = 12 THEN
        SENDERS.BIC.CODE = SENDERS.BIC.CODE[1,8]:SENDERS.BIC.CODE[10,3]
    END
    
RETURN

*************************************************************************

HOLD.ON.ERROR:

* Processing when an error is found in the message

*   R.OFS.DATA := 'INBOUND.ERROR,':ERROR.COUNT:'=':MESSAGE.ERROR:','

*   ERROR.COUNT = ERROR.COUNT + 1

* MESSAGE.ERROR = ''

RETURN

*************************************************************************

INITIALISE:

* Initialise variables

    FIELD.TO.FIND = ''
    FIELD.TO.DEFAULT = ''
    SWIFT.TAG.NO = ''
    SWIFT.TAG.DATA = ''
    MESSAGE.ERROR = ''
    ERROR.COUNT = 1
    DIM R.MESSAGE(DE.Config.Message.MsgAuditDateTime)         ;*      CI_10010874 -  S/E
* CI_10016284 S
    DE.I.ALL.FIELD.DATA = ''
    TXN.REFERENCE = ''
    VAL.DATE = ''
    ACCT.ID = ''
    OFS.REQ.DET.ID = ''
    T24.TRANS.REF = ''
* CI_10016284 E
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
    R.DE.I.MSG = DE.ModelBank.IMsg.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    R.DE.MESSAGE = ''
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(MSG.ID, ER)
    EB.SystemTables.setE(ER)

    R.ER.PARAMETER = ""
    YERR = ''
    ER.PARAMETER.ID = 'SYSTEM'
    R.ER.PARAMETER = ER.Config.ErParameter.Read(ER.PARAMETER.ID, YERR)
    IF YERR NE '' THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "ER.PARAMETER ":YERR) ;*If ER.PARAMETER record not present then write repair and return.
        GOSUB WRITE.REPAIR
        RETURN
    END
    
* Read ER.FUNDS.TYPE.PARAM record for ER FUNDS.TYPE
    R.ER.FUNDS.TYPE.PARAM = ""
    FUNDS.TYPE.PARAM.READ.ERR = ""
    R.ER.FUNDS.TYPE.PARAM = ER.Config.ErfundsTypeParam.Read("ER", FUNDS.TYPE.PARAM.READ.ERR)
    
    EXCLUDE.CURRENCIES = R.ER.FUNDS.TYPE.PARAM<ER.Config.ErfundsTypeParam.ErFPExcludeCurrencies>
    STORE.BIC8 = R.ER.FUNDS.TYPE.PARAM<ER.Config.ErfundsTypeParam.ErFPStoreBic8>

* Checks for Integrity
    MSG.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.MESSAGE.REC = DE.Config.Message.Read(MSG.ID, ER)
    MATPARSE R.MESSAGE FROM R.MESSAGE.REC

    IF ER THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "Message type does not exist")
        GOSUB WRITE.REPAIR
        RETURN
    END

    OFS.ID = R.MESSAGE(DE.Config.Message.MsgOfsSource)         ;*Ofs Source File ID...
    R.OFS.SOURCE=""


    IF OFS.ID = '' THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "OFS.SOURCE field on DE.MESSAGE blank")
        GOSUB WRITE.REPAIR
        RETURN
    END

    OFS$SOURCE.REC=R.OFS.SOURCE         ;*Set up Common OFS.SOURCE Record...
    OFS$SOURCE.ID=OFS.ID      ;*Set up Common OFS.ID...

    R.OFS.SOURCE = EB.Interface.OfsSource.Read(OFS.ID, ER)

    IF ER THEN
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "OFS ID ":OFS.ID:" DOES NOT EXIST IN OFS.SOURCE")
        GOSUB WRITE.REPAIR
        RETURN
    END

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    R.OFS.DATA = K.VERSION:"/I,,,"
    
* Flag to indicate the Block/Unblock of mapping TAG56 values to ORG.CORRESP.BIC and CORRESP.ACCOUNT in AC.EXPECTED.RECS
    MAP.ADDITIONAL.VALUES.TO.ACER = 1

RETURN


*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:

* Complete any fields not directly populated from input Tags
* CI_10016284 S

    IF TAG.VAL.NO = 1 THEN
        
        GOSUB STORE.MAIN.SEQ.INFO
      
        EXIT.FLAG = ""
        IF ACC.CURRENCY THEN
            GOSUB CHECK.CURRENCY.EXCLUSION ;* Check if the currency is defined for exclusion in ER.FUNDS.TYPE.PARAM
        END
    
        IF EXIT.FLAG THEN
            RETURN
        END
    
    END ELSE
    
        IF TXN.REFERENCE THEN
            R.OFS.DATA := 'REFERENCE:1:1':'=':QUOTE(TXN.REFERENCE):','
        END
       
        IF ACCT.ID THEN
            R.OFS.DATA := 'ACCOUNT.ID':'=':ACCT.ID:','
        END
        
        IF VAL.DATE THEN
            R.OFS.DATA := 'VALUE.DATE':'=':VAL.DATE:','
        END
    
    END

    IF ACCT.ID EQ "" THEN
        GOSUB GET.ACCOUNT.ID ;* Get the VOSTRO account defined for the customer
    END
    
    IF MAP.ADDITIONAL.VALUES.TO.ACER THEN

        IF NOT(TAG.56.PRESENT) AND ORG.CORRESP.BIC EQ "" THEN
            ORG.CORRESP.BIC = SENDERS.BIC.CODE
        END
    
        IF ORG.CORRESP.BIC NE "" THEN
            R.OFS.DATA := 'ORG.CORRESP.BIC':'=':ORG.CORRESP.BIC:','
        END
    
        STORE.CORRESP.BIC = ORG.CORRESP.BIC
        IF STORE.BIC8 EQ "YES" THEN
            STORE.CORRESP.BIC = ORG.CORRESP.BIC[1,8]
        END
    
        IF STORE.CORRESP.BIC NE "" THEN
            R.OFS.DATA := 'CORRESP.BIC':'=':STORE.CORRESP.BIC:','
        END
    
        IF CORRESP.ACC EQ "" THEN
            GOSUB GET.CORRESP.ACC ;* Get the NOSTRO account defined for the customer
        END
    
        R.OFS.DATA := 'MESSAGE.TYPE=':MSG.ID:','
        R.OFS.DATA := 'SENDER.BIC=':SENDERS.BIC.CODE:','
    
    END
* CI_10016284 E

    R.OFS.DATA := 'DATE.ENTERED':'=':EB.SystemTables.getToday():','
    R.OFS.DATA := 'DESCRIPTION':'=':'AUTO':','
    R.OFS.DATA := 'FUNDS.TYPE':'=':'ER':','
    R.OFS.DATA := 'DELIVERY.IN.REF=':DE.Inward.getRKey():','

RETURN

**************************************************************************

WRITE.REPAIR:


    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, "REPAIR")
*

    R.REPAIR=DE.Inward.getRKey()
    DE.Outward.UpdateIRepair(R.REPAIR,'')
*
RETURN

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
CALL.SUBROUTINE:
**************************************************************************
*
* Process each tag routine
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.

    IF DE.TAG.ID EQ '' THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E

    R.DE.I.SUBROUTINE.TABLE = ''
    SET.ERROR = ''

    R.DE.I.SUBROUTINE.TABLE = DE.Messaging.ISubroutineTable.Read(DE.TAG.ID, TAG.ERR)

    IF TAG.ERR THEN
        SET.ERROR = "TAG ROUTINE FOR ":DE.TAG.ID:" - MISSING"
    END ELSE

        SUBROUTINE.ID = R.DE.I.SUBROUTINE.TABLE<DE.Messaging.ISubroutineTable.SrTbSubroutine>
        OFS.DATA = ''
        COMPILED.OR.NOT = ''
        DE.I.FIELD.DATA = ''  ;* CI_10016284 S/E
        EB.API.CheckRoutineExist(SUBROUTINE.ID, COMPILED.OR.NOT, R.ERR)

        IF NOT(COMPILED.OR.NOT) THEN
            SET.ERROR = "SUBROUTINE FOR TAG ":DE.TAG.ID:" NOT COMPILED"
        END ELSE
            CALL @SUBROUTINE.ID (SEQ.TAG.ID,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','', DE.I.FIELD.DATA, SET.ERROR)       ;* CI_10016284 S/E
            IF OFS.DATA NE '' THEN
                R.OFS.DATA := OFS.DATA:","
                DE.I.ALL.FIELD.DATA<-1> = DE.I.FIELD.DATA   ;* CI_10016284 S/E
            END
        END
    END

    IF SET.ERROR THEN
        MESSAGE.ERROR<-1> = SET.ERROR   ;* BG_100013037 - S
    END   ;* BG_100013037 - E

RETURN
**************************************************************************
* CI_10016284 S
STORE.MAIN.SEQ.INFO:
    
    FIELD.TO.FIND = 'REFERENCE'
    GOSUB PROCESS.SEARCH.FIELD
    TXN.REFERENCE = FIELD.TO.SEARCH.DATA

    FIELD.TO.FIND = 'ACCOUNT.ID'
    GOSUB PROCESS.SEARCH.FIELD
    ACCT.ID = FIELD.TO.SEARCH.DATA

    FIELD.TO.FIND = 'VALUE.DATE'
    GOSUB PROCESS.SEARCH.FIELD
    VAL.DATE = FIELD.TO.SEARCH.DATA
    
    FIELD.TO.FIND = 'CURRENCY'
    GOSUB PROCESS.SEARCH.FIELD
    ACC.CURRENCY = FIELD.TO.SEARCH.DATA
    
    FIELD.TO.FIND = 'ORG.CORRESP.BIC'
    GOSUB PROCESS.SEARCH.FIELD
    ORG.CORRESP.BIC = FIELD.TO.SEARCH.DATA

    FIELD.TO.FIND = 'CORRESP.ACCOUNT'
    GOSUB PROCESS.SEARCH.FIELD
    CORRESP.ACC = FIELD.TO.SEARCH.DATA
    
RETURN
**************************************************************************
PROCESS.SEARCH.FIELD:
    
    FIELD.TO.SEARCH.DATA = ''
    FINDSTR FIELD.TO.FIND IN DE.I.ALL.FIELD.DATA SETTING FMS,VMS THEN
        FIELD.TO.SEARCH.DATA = FIELD( DE.I.ALL.FIELD.DATA<FMS>,CHARX(251),2)
        CONVERT @VM TO @FM IN FIELD.TO.SEARCH.DATA
    END
    
RETURN
* CI_10016284 E
*************************************************************************************************************
* BG_100013037 - S
*================
PROCESS.EACH.TAG:
*================

    TAG.56.PRESENT = ""

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
* CI_10016284 S
        BLANK.REPEAT.FIELD = 0
        IF MULTIPLE.TAG<TAG.FIELD.NO>[1,2] GT 0 THEN
            IF FIELD.VALS<TAG.VAL.NO OR FIELD.SUBS<TAG.SUB.NO THEN
                BLANK.REPEAT.FIELD = 1
            END
        END
* The values of single repetitive sequcene field should be handled within
* the tag routine and it should be separated by VM s.

        MULTIPLE.FIELD.NO = MULTIPLE.TAG<TAG.FIELD.NO>
        IF MULTIPLE.FIELD.NO[1,1] = 'R' THEN
            DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
            SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>
            DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX>
            CONVERT @SM TO @VM IN DE.TAG.SEQ.MSG

            GOSUB CALL.SUBROUTINE
        END ELSE

*                IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' THEN
            IF SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX> NE '' AND BLANK.REPEAT.FIELD = 0 THEN
*                   DE.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO>[1,2]
                SEQ.TAG.ID = SEQUENCED.TAGS<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
                DE.TAG.ID = SEQ.TAG.ID[1,2]
                
                IF DE.TAG.ID EQ "56" THEN
                    TAG.56.PRESENT = 1
                END
* CI_10016284 E
                DE.TAG.SEQ.MSG = SEQUENCED.MESSAGE<TAG.FIELD.NO,TAG.VAL.IDX,TAG.SUB.IDX>
                GOSUB CALL.SUBROUTINE   ;* BG_100002295 S/E
            END     ;* CI_10016284 S/E
        END

    NEXT TAG.FIELD.NO
RETURN          ;*BG_100013037 - E
*************************************************************************************************************
*** <region name= GET.ACCOUNT.ID>
GET.ACCOUNT.ID:
*** <desc> Get the VOSTRO account defined for the customer </desc>

    CUSTOMER.ID = SENDING.CUSTOMER
    ACCOUNT.CLASS = "VOSTRO"

    GOSUB GET.CUSTOMER.ACCOUNT ;* Get the customer account based on ACCOUNT.CLASS and currency

    IF REQUIRED.ACCOUNT THEN
        ACCT.ID = REQUIRED.ACCOUNT
        R.OFS.DATA := 'ACCOUNT.ID':'=':ACCT.ID:','
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CORRESP.ACC>
GET.CORRESP.ACC:
*** <desc> Get the NOSTRO account defined for the customer </desc>

    IF ORG.CORRESP.BIC EQ "" THEN
        RETURN
    END
    
    CORRESP.CUSTOMER = ""
    DE.API.SwiftBic(ORG.CORRESP.BIC, COMP.ID, CORRESP.CUSTOMER)
    
    CUSTOMER.ID = CORRESP.CUSTOMER
    ACCOUNT.CLASS = "NOSTRO"

    GOSUB GET.CUSTOMER.ACCOUNT ;* Get the customer account based on ACCOUNT.CLASS and currency

    IF REQUIRED.ACCOUNT THEN
        CORRESP.ACC = REQUIRED.ACCOUNT
        R.OFS.DATA := 'CORRESP.ACCOUNT':'=':CORRESP.ACC:','
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUSTOMER.ACCOUNT>
GET.CUSTOMER.ACCOUNT:
*** <desc> Get the customer account based on ACCOUNT.CLASS and currency </desc>

    REQUIRED.ACCOUNT = ""

    CUST.ACCTS.READ.ERR = ""
    R.CUSTOMER.ACCOUNTS = ""
    R.CUSTOMER.ACCOUNTS = AC.AccountOpening.CustomerAccount.Read(CUSTOMER.ID, CUST.ACCTS.READ.ERR)
    CUST.ACCT.COUNT = DCOUNT(R.CUSTOMER.ACCOUNTS, @FM)
        
    FOR ACC.POS = 1 TO CUST.ACCT.COUNT
        
        CURRENT.CUST.ACCT = R.CUSTOMER.ACCOUNTS<ACC.POS>
        ACC.READ.ERR = ""
        R.ACCOUNT = ""
        R.ACCOUNT = AC.AccountOpening.Account.Read(CURRENT.CUST.ACCT, ACC.READ.ERR)
        CURRENT.ACCT.CCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>
       
        IF ACC.CURRENCY NE CURRENT.ACCT.CCY THEN
            CONTINUE
        END
            
        CURRENT.ACCT.CATEG = R.ACCOUNT<AC.AccountOpening.Account.Category>
        ACCT.CLASS.RETURN.VALUE = ""
        AC.Config.CheckAccountClass(ACCOUNT.CLASS, CURRENT.ACCT.CATEG, CUSTOMER.ID, "", ACCT.CLASS.RETURN.VALUE)
            
        IF ACCT.CLASS.RETURN.VALUE NE "YES" THEN
            CONTINUE
        END
    
        REQUIRED.ACCOUNT = CURRENT.CUST.ACCT
        ACC.POS = CUST.ACCT.COUNT
    
    NEXT ACC.POS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CURRENCY.EXCLUSION>
CHECK.CURRENCY.EXCLUSION:
*** <desc> Check if the currency is defined for exclusion in ER.FUNDS.TYPE.PARAM </desc>

* Do not form create AC.EXPECTED.RECS if the currency is defined for exclusion
* in ER.FUNDS.TYPE.PARAM
    ECLUDED.CCY.POS = ""
    LOCATE ACC.CURRENCY IN EXCLUDE.CURRENCIES<1,1> SETTING ECLUDED.CCY.POS THEN
        EXIT.FLAG = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

