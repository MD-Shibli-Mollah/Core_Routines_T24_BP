* @ValidationCode : MjotNTk5ODIxMDY0OmNwMTI1MjoxNjExMzA0MTg3Nzc1OmJjYXBvb3J2YToxMjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjYzOTo0NzI=
* @ValidationInfo : Timestamp         : 22 Jan 2021 13:59:47
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : bcapoorva
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 472/639 (73.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>288</Rating>
*-----------------------------------------------------------------------------
* Version 1 25/06/02  GLOBUS Release No. G13.2.00 25/06/02
$PACKAGE FT.Delivery
SUBROUTINE DE.I.MT103
*************************************************************************
*                                                                       *
* Inward delivery template                                              *
*                                                                       *
*************************************************************************
*
*   MODIFICATIONS
*
* 10/07/02 - EN_10000786
*            New Program
*
* 01/10/02 - BG_100002189
*            Bug fix in Inward Delivery
*
* 07/10/02 - EN_10001322
*            Account Fields for SWIFT 2002 Usage
*
* 28/10/02 - BG_100002532
*            - FT.TXN.TYPE changed to FT.TXN.TYPE[1,2]
*            - Error in reading Credit ccy correctly from R.OFS.DATA.
*
* 08/11/02 - BG_100002640
*            - Setting error message as Awaiting cover payment is moved
*            to FUNDS.TRANSFER program.
*            - Intermediary tag details (tag 56) are now stored in field
*            IN.INTERMED.BK and not INTERMED.BANK
*            - Populate TELEX.FROM.CUST field in R.OFS.DATA
*            - Populate ACCT.WITH.BK to ACCT.WITH.BANK for OT Transactions
*              if Intermediary details are present
*
* 29/11/02 - CI_10005070
*            Credit currency should be defaulted from Debit currency
*            only if the credit account is not obtained.
*
* 03/11/02 - CI_10005170
*            1. Only when tag 71G(Receiver's Charges) is present, default
*            the CHARGE.TYPE from IN.CHG.CODE of FT.TXN.TYPE.CONDITION
*
*            2. Previously, for all types of charges in 71A, BEN.OUR.CHARGES
*            will be defaulted to 'BEN' and CHARGE.CODE will be defaulted
*            to 'C' (Credit Less Charges).
*            But now the exception is that when tag 71A is 'OUR' and
*            71G is absent (ie., NO receiver charges), then BEN.OUR.CHARGES
*            should be 'OUR' and CHARGE.CODE should be 'D' (Debit Plus Charges)
*
* 18/12/02 - CI_10005633
*            If ORDERING.BANK is not found in the incoming transactions, then
*            set the ordering bank as the Sender of the message.
*
* 26/12/02 - CI_10005670
*            Special characters enclosed in double quotes before
*            passing to R.OFS.DATA in the PROCESS.DEFAULT.FILEDS para
*
* 29/01/03 - EN_10001611
*            Third reimbursement Institution has to be supported in FT &
*            STO based on the COVER.METHOD.
*            Handle tag 55 in the message type 103
*
* 01/02/03 - EN_10001616
*            Supporting 103+ and 103 extended remittance in FT.
*            Handle tag 77T in the message type 103
*
* 21/02/03 - BG_100003547
*            Error in IN.P.IN.SWIFT.MSG as WRONG ALPHANUMERIC CHAR.
*
* 03/03/03 - EN_10001649
*            Map the sender of Incoming message to INW.SEND.BIC field of FT.
*            The sender is indentified from the FROM.ADDRESS of DE.I.HEADER.
*            Incoming charges processing are handled in FT.DEF.COMM.CHG and
*            hence remove all the charges related processing from this
*            subroutine.
*            The debit amount will be the 32A tag amount - 71G( Receiver chg)
*
* 20/03/03 - EN_10001661
*            If the Senders BIC Code is of 12 characters, then the ordering
*            bank should be only of 11 characters. Exclude the 9th character.
*
* 22/09/03 - CI_10012844
*            Changes made to populate Debit Acct no with the
*            acct of Sender Correspondent.
*
* 31/03/05 - CI_10028812
*            Check for the presence of charges is made on IN.REC.CHG
*            instead of CHARGE.AMT.
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 19/04/08 - CI_10054834/Ref: HD0808225
*            Inward swift message (IN.SWIFT.MSG) is not getting updated
*
* 21/07/09 - CI_10064691
*            The company code present in the DE.I.HEADER is also passed in OFS
*            message while calling routine OFS.GLOBUS.MANAGER
*
* 03/05/10 - Task: 27861, Enhancement: 27278
*            Tag 50F support in incoming 103
*
* 11/06/10 - Task 51844
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
* 11/05/11 - Task 206623
*            Enhancement 187149
*            ORD.CUST.ACCT should be defaulted from IN.ORD.CUST.ACCT for inward
*            message.
*
* 17/05/11 - Task 204050
*            Fix is done to check NOSTRO account once it complete the validation
*            of the vostro account for populating debit account for the cases like
*            sender correspond bank & receiver corr bank.
*
* 09/01/13 - Task 556879
*            In OFS Message comma(,) is considered as a delimiter between the field value , So if CUS.NAME contains comma
*       it converted in to "?". Reverting the fix done in Task 51844.
*
* 28/07/14 - Task 617275
*           Replacing OFS.GLOBUS.MANAGER with OFS.BULK.MANAGER using CALL.OFS.BULK.MANAGER routine
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
* 31/03/16 - Defect 2033659/ Task 2072672
*          - Pass the GTS.CONTROL as 4 when transaction fails
* 31/05/17 - Defect 2077855
*          - Task 2142790
*            The mapping of TELEX.FROM.CUST will be done only for the first multivalue set with VM separators.
*
* 07/02/18 - Enhancement 2449690 / Task 2449712
*            When TPS is defined in DE parameter, processing will be routed via TPH.
*
* 25/05/18 - Enhancement 2583024 / Task 2593417
*            1. Populate UETR reference to the field IN.HDR.3.UETR of FT
*            2. update concat file DE.UETR.REF.FILE.
*
* 14/03/19 - Defect 3011224 / Task 3031487
*            Storing the first 180 characters so as to prevent truncation of the
*            error message.
*
* 13/04/19 - Defect 3082516 / Task 3084235
*            The truncated characters- r, e, q, u, s, t in 'IN.PROCESS.ERR' field
*            in FUNDS.TRANSFER has been fixed.
*
* 14/05/19 - Enhancement 3112589 / Task 3112595
*            Pass the Delivery Reference value, update the reference in DE.UETR.CATALOG
*            for the respective transaction.
*
* 11/07/19 - Defect 3223792 / Task 3223797
*          - Replacing F.READ with CACHE.READ
*
*05/02/2020 - Enhancement 3570664 / Task 3570652
*           - Changes done to create FT.CONFIRMATION.TRACKER record through OFS as a part UniversalConfirmation mandatory for Swift2020
*
* 03/02/20 - Enhancement 3265496  / Task 3568259
*            Removing reference that have been moved from ST to CG
*
* 06/01/21 - Defect 4024971 / Task 4155771
*            Replaced the value "NULL" to "\NULL" in the ofs data of the incoming MT103
*            message to avoid "NULL LINES NOT ALLOWED" error during formatting.
*
* 21/01/21 - Defect 4113246 / Task 4190028
*            In SWIFT 2020 installed environment, SFCONF.CONFIRMATION.TRACKER table does not updated for inward processed MT103 which generated FT (for AA account) in INAO status.
*            Check has been done such that if the RETURN.INFO has the RECORD.STATUS as INAO and if TRAC.OFS.RECORD is not NULL then call bulk manager again to create confirmation tracker record
*
*************************************************************************
    $USING DE.Config
    $USING FT.Delivery
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
    $USING EB.Delivery
    $USING EB.Foundation
    $USING EB.TransactionControl
    $USING SFCONF.Contract

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
        DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'OFS FORMATTED');* BG_100013037 - S
        REC.ID = DE.Inward.getRKey()
        R.HEAD.REC = DE.Inward.getDynArrayFromRHead()
        DE.Config.IHeaderWrite(REC.ID,R.HEAD.REC,'')
        EB.SystemTables.setApplication(TEMP.APPLICATION)
        RETURN      ;* BG_100013037 - E
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

            GOSUB CHECK.SEQUENCE.MSG    ;* BG_100013037 - S / E

        END

    NEXT TAG.FIELD.NO
*
    SwiftRelease = '2020'
    Installed = ''
    RtnMsg = ''
            
    DE.API.SwiftRuleBookCheck(SwiftRelease, Installed, RtnMsg)
            
    IF Installed EQ 'YES' AND  DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference) THEN ;* Only if 2020-UC swift release is configured  update Confirmation Tracker
        GOSUB ADD.TO.CONFIRMATION.TRACKER ; *
    END
    GOSUB ADD.NON.TAG.FIELDS  ;* Specific Application Record Processing

    IF MESSAGE.ERROR THEN
        GOSUB STORE.TAG.ERRORS
        R.OFS.DATA := TAG.ERROR.DATA
    END

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
    IF MESSAGE.TYPE NE '103' THEN       ;* Input the type for this template
        MESSAGE.ERROR = 'Trying to process message ':MESSAGE.TYPE:' in message template MT103'
        GOSUB HOLD.ON.ERROR
    END

    R.DE.FORMAT.SWIFT = DE.Config.FormatSwift.CacheRead('103.1.1', READ.ERROR)

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
    DeParmRec = DE.Config.Parm.CacheRead("SYSTEM.STATUS", ParmErr)
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
*  SENDERS.BIC.CODE = SUBSTRINGS(R.HEAD(DE.HDR.FROM.ADDRESS),1,11)
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
        
* Storing first 180 characters of the error as the field length of IN.PROCESS.ERR is increased to 180 from 65.
        OFS.ERR = ERR.REASON<CNT>[1,180]
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

    T24.TRANS.REF = FIELD(RETURN.INFO,'/',1)      ;* Get the inward trans ref
    OFS.REQ.DET.ID = FIELD(RETURN.INFO,'/',2)     ;* Get the ofs request detail id


    R.OFS.DATA = ''

    IF FIELD(RETURN.INFO,'/',3) < 0 THEN

        TXN.REF.GEN=FIELD(RETURN.INFO,'/',1)
        FAIL.CODE=FIELD(RETURN.INFO,'/',3)

        R.OFS.DATA = K.VERSION:"/I//4,//":TXN.COMPANY:","
        R.OFS.DATA := TXN.REF.GEN:','

        GOSUB STORE.OFS.ERRORS

        EB.Interface.OfsCallBulkManager(K.OFS.SOURCE, R.OFS.DATA,'','')
        
*If FT goes to hold call bulk manager again to create confirmation tracker record
        IF TracOfsrecord THEN
            TracOfsresponse = ''
            TracTxncommitted = ''
        
            EB.Interface.OfsCallBulkManager(TracOfsSource, TracOfsrecord , TracOfsresponse, TracTxncommitted)
        END
 
    END ELSE
    
*   Defect 4113246 / Task 4190028
*   In SWIFT 2020 installed environment, SFCONF.CONFIRMATION.TRACKER table does not updated for inward processed MT103 which generated FT (for AA account) in INAO status.
*   Check has been done such that if the RETURN.INFO has the RECORD.STATUS as INAO and if TRAC.OFS.RECORD is not NULL then call bulk manager again to create confirmation tracker record

        RecStatus = "RECORD.STATUS:1:1=INAO"
        FINDSTR RecStatus IN RETURN.INFO SETTING F1,V1,S1 THEN    ;* check if the response have the Accunt Blocked err for creating DD DDI
            IF TracOfsrecord THEN
                TracOfsresponse = ''
                TracTxncommitted = ''
        
                EB.Interface.OfsCallBulkManager(TracOfsSource, TracOfsrecord , TracOfsresponse, TracTxncommitted)
            END
        END
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

    CRT "Starting DE.I.MT103 template program"

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
    REC.CHG.FOUND = ''
    ACCT.WITH.DATA = ''
    DEF.CHARGE.TYPE = ''
    ACCOUNT = ''
    RETURN.INFO = ''
    TXN.COMMITTED = ''
    DEL.REF = ''
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

    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    K.OFS.SOURCE = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>

    TEMP.APPLICATION = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    TXN.COMPANY = DE.Inward.getRHead(DE.Config.IHeader.HdrCompanyCode)
    OFS.PREFIX = K.VERSION:"/I,//":TXN.COMPANY:",,"

    IN.STORE.MSG = R.DE.I.MSG
* EN_10001616 - S
    ENV.POS = INDEX(IN.STORE.MSG,':77T:',1)
    IF ENV.POS THEN
        TRAIL = @FM:'-}'
        TRAIL.POS = INDEX(IN.STORE.MSG,TRAIL,1)
        MSG.CONTENT = IN.STORE.MSG[1,ENV.POS-1]
        ENV.CONTENT = IN.STORE.MSG[ENV.POS,TRAIL.POS - ENV.POS]       ;* BG_100003547 S/E
        NO.CHAR = 65
        LOOP
            REMOVE ENV.MSG FROM ENV.CONTENT SETTING REM.ENV.POS
        WHILE ENV.MSG:REM.ENV.POS
10:
            LEN.ENV.MSG = LEN(ENV.MSG)
            IF LEN.ENV.MSG <= NO.CHAR THEN
                MSG.CONTENT := @FM:ENV.MSG
            END ELSE
                MSG.CONTENT := @FM: ENV.MSG[1,NO.CHAR]
                ENV.MSG = ENV.MSG[NO.CHAR+1,LEN.ENV.MSG]
                GOTO 10
            END
        REPEAT
        IN.STORE.MSG = MSG.CONTENT: TRAIL
    END
* EN_10001616 - E
    CRLF = CHARX(013):CHARX(010)
    CONVERT CRLF TO @FM IN IN.STORE.MSG
    MSG.FIELD.COUNT = DCOUNT(IN.STORE.MSG,@FM)

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

ADD.NON.TAG.FIELDS:
******************

* Complete any fields not directly populated from input Tags
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.

******************

    OFS.DATA = ''   ;* Re-initialise

******************
* Set Transaction type
******************

    GOSUB DETERMINE.TXN.TYPE

******************
* Set Standard fields
******************

    GOSUB STORE.THE.MESSAGE

******************
* Populate TELEX.FROM.CUST
******************

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
* The customerKey value is mapped to a field TELEX.FROM.CUST in FT whose length is only 35 and it single value field.
* So the mapping has to done only for the first multivalue set with VM separators.
* If it has VM separators the Swift message gets truncated when calling request manager.
            R.OFS.DATA := 'TELEX.FROM.CUST=': customerKey<1,1>:','
        END
    END
** BG_100002640 -E

* EN_10001649 S

*******************
* Populate the Net debit amount
* Net debit amount = 32A - 71G.

* Get the Initial debit amount from tag 32A
    FIELD.TO.FIND = 'DEBIT.AMOUNT'
    GOSUB PROCESS.SEARCH.FIELD
    DEBIT.AMOUNT = FIELD.TO.SEARCH.DATA

* Get the receiver charges amountfrom tag 71G

    FIELD.TO.FIND = 'IN.REC.CHG'
    GOSUB PROCESS.SEARCH.FIELD
    IN.REC.CHGS = FIELD.TO.SEARCH.DATA

* Get the effective debit amount.

    IF IN.REC.CHGS AND DEBIT.AMOUNT THEN
        TOT.DR.AMOUNT = DEBIT.AMOUNT - IN.REC.CHGS
        R.OFS.DATA :='DEBIT.AMOUNT:1:1=':TOT.DR.AMOUNT:','
    END

* EN_10001649 E
******************
* Set the credit currency to the debit currency
******************

    DEBIT.CURRENCY.FOUND = INDEX( R.OFS.DATA, "DEBIT.CURRENCY", 1)
    IF DEBIT.CURRENCY.FOUND GT 0 THEN

* CI_10005070 S

*     Save debit currency in CREDIT.CURRENCY .

        DEBIT.CURRENCY = SUBSTRINGS( R.OFS.DATA, DEBIT.CURRENCY.FOUND+15, 3)
        CREDIT.CURRENCY = DEBIT.CURRENCY
*        R.OFS.DATA := 'CREDIT.CURRENCY=':CREDIT.CCY:','
*         CCY = CREDIT.CCY
    END

* CI_10005070 E


******************
* Specific to Transaction Types
******************


    IF FT.TXN.TYPE[1,1] = 'I' THEN
* Specific for Inward Type messages

        FIELD.TO.FIND.ALL = ''
        FIELD.TO.FIND.ALL = "IN.BEN.ACCT.NO":'*':'CREDIT.ACCT.NO'
        FIELD.TO.FIND.ALL<-1> = "IN.ORD.CUST.ACCT":'*':'ORD.CUST.ACCT'

        GOSUB DEFAULT.FIELDS

    END ELSE
* Specific for Outward Type messages

        FIELD.TO.FIND.ALL = ''
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.ACCT.NO":'*':'BEN.ACCT.NO'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.CUSTOMER":'*':'BEN.CUSTOMER'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.BANK":'*':'BEN.BANK'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.NAME":'*':'BEN.NAME'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.ADDRESS":'*':'BEN.ADDRESS'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.COUNTRY":'*':'BEN.COUNTRY'
        FIELD.TO.FIND.ALL<-1> = "IN.BEN.TOWN":'*':'BEN.TOWN'

*-------------------*
* If intermediary details are present, then we have to default the
* Acct with bank details to outward also.
*-------------------*

        IN.INTERMED.ACC = INDEX(R.OFS.DATA,"IN.INTERMED.ACC",1)
        INTERMED.BANK = INDEX(R.OFS.DATA,"IN.INTERMED.BK",1)
        IF IN.INTERMED.ACC OR INTERMED.BANK THEN
            FIELD.TO.FIND.ALL<-1> = 'IN.ACCT.BANK.ACC':'*':'ACCT.WITH.BANK.ACC'
            FIELD.TO.FIND.ALL<-1> = 'ACCT.WITH.BK':'*':'ACCT.WITH.BANK'
        END

        GOSUB DEFAULT.FIELDS


*-------------------*
* Set Credit account no.
*-------------------*
*
* EN_10001322 - S
*
        IF NOT(INDEX(R.OFS.DATA,"CREDIT.ACCT.NO",1)) AND FT.TXN.TYPE[1,2] = "OT" THEN     ;* BG_100002532 s/e

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

* BG_100002640 - s
* Locate for IN.INTERMED.BK and not INTERMED.BANK

*                  FIELD.TO.FIND = 'INTERMED.BANK'
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
    END


******************
* Set Ordering customer and Ordering bank
******************

    FIELD.TO.FIND.ALL = ''
    FIELD.TO.FIND.ALL<-1> = "IN.ORDERING.CUS":'*':'ORDERING.CUST'
    FIELD.TO.FIND.ALL<-1> = "IN.ORDERING.BK":'*':'ORDERING.BANK'
    GOSUB DEFAULT.FIELDS

* CI_10005633 S
    IF NOT(INDEX(R.OFS.DATA,"IN.ORDERING.BK",1)) THEN

        IF SAVE.SENDING.CUSTOMER = '' THEN
            SAVE.SENDING.CUSTOMER = 'SW-':SENDERS.BIC.CODE  ;* BG_100013037 - S
        END         ;* BG_100013037 - E
        R.OFS.DATA := 'IN.ORDERING.BK:1:1=':SAVE.SENDING.CUSTOMER:','
        R.OFS.DATA := 'ORDERING.BANK:1:1=':SAVE.SENDING.CUSTOMER:','
    END
* CI_10005633 E


******************
*  Set Default Debit Account
******************

*
* EN_10001322 - S
*
    IF NOT(INDEX(R.OFS.DATA,"DEBIT.ACCT.NO",1)) THEN

        CCY = ''
        CHECK.ACCOUNT.CLASS = ''
* EN_10001611 - S
        IN.3RD.REIMB.BK = INDEX(R.OFS.DATA,"IN.3RD.REIMB.BK",1)
        IN.3RD.REIMB.ACC = INDEX(R.OFS.DATA,"IN.3RD.REIMB.ACC",1)
* EN_10001611 - E
        IN.REC.CORR.ACC = INDEX(R.OFS.DATA,"IN.REC.CORR.ACC",1)
        IN.REC.CORR.BK = INDEX(R.OFS.DATA,"IN.REC.CORR.BK",1)
        COMP.ID = EB.SystemTables.getIdCompany()
        R.REC = FT.Config.ApplDefault.Read(COMP.ID, ER)
        AWAITING.COVER = R.REC<FT.Config.ApplDefault.FtOneAwaitCover>

* CI_10012844 -s
* Get  Sender Corres account specified in tag 53, if any.
        FIELD.TO.FIND = 'IN.SEND.CORR.ACC'
        GOSUB PROCESS.SEARCH.FIELD
        IN.SEND.CORR.ACC = FIELD.TO.SEARCH.DATA

        IN.SEND.CORR.BK = INDEX(R.OFS.DATA,"IN.SEND.CORR.BK",1)
* CI_10012844 -e

        BEGIN CASE
* EN_10001611  - S
            CASE IN.3RD.REIMB.ACC
                FIELD.TO.FIND.ALL = 'IN.3RD.REIMB.ACC':'*':'DEBIT.ACCT.NO'
                GOSUB DEFAULT.FIELDS
            CASE IN.3RD.REIMB.BK
                GOSUB CHECK.ON.IN.3RD.REIMB.BK        ;* BG_100013037 - S / E
* EN_10001611 - E
            CASE IN.REC.CORR.ACC

                FIELD.TO.FIND.ALL = 'IN.REC.CORR.ACC':'*':'DEBIT.ACCT.NO'
                GOSUB DEFAULT.FIELDS

* BG_100002640 S
*            CASE IN.REC.CORR.BK AND AWAITING.COVER = "YES"
*               MESSAGE.ERROR<-1> = 'Awaiting Cover Payment'

* BG_100002640 E
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


**************************
* Default Credit Currency
**************************

* CI_10005070 S
* If the credit account is not found, default credit currency from debit currency
    IF NOT(INDEX(R.OFS.DATA,'CREDIT.ACCT.NO',1)) AND CREDIT.CURRENCY THEN
        R.OFS.DATA := 'CREDIT.CURRENCY:1:1=':CREDIT.CURRENCY:','
    END
* CI_10005070 E


****************************************
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
            DATA.TO.DEF = QUOTE(DATA.TO.DEF)      ;* CI_10005670 S/E
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
    ACCT.WITH.FOUND = INDEX( R.OFS.DATA, "ACCT.WITH.BK", 1) ;* BG_100002189 - s/e - Changed ACCT.WITH.BANK to ACCT.WITH.BK

* Identify if the Payment is from a third Party & not our correspondent
* EN_10001611 - S
    THIRD.PARTY.FOUND = INDEX( R.OFS.DATA, "IN.3RD.REIMB.ACC", 1)
    IF NOT(THIRD.PARTY.FOUND) THEN
        THIRD.PARTY.FOUND = INDEX( R.OFS.DATA, "IN.3RD.REIMB.BK", 1)
        IF NOT(THIRD.PARTY.FOUND) THEN
* EN_10001611 - E
            THIRD.PARTY.FOUND = INDEX( R.OFS.DATA, "IN.REC.CORR.BK", 1)
        END         ;* EN_10001611 S/E
    END   ;* EN_10001611 S/E

* Check for the presence of Charges
    REC.CHG.FOUND = INDEX(R.OFS.DATA,"IN.REC.CHG",1)        ;* CI_10028812 S/E

* Determine Transaction types
    BEGIN CASE
        CASE THIRD.PARTY.FOUND AND NOT(ACCT.WITH.FOUND) AND REC.CHG.FOUND
            FT.TXN.OPTION.NO = 8

        CASE THIRD.PARTY.FOUND AND NOT(ACCT.WITH.FOUND)
            FT.TXN.OPTION.NO = 7

        CASE REC.CHG.FOUND AND NOT(ACCT.WITH.FOUND)
            FT.TXN.OPTION.NO = 6

        CASE NOT(ACCT.WITH.FOUND)
            FT.TXN.OPTION.NO = 5

        CASE THIRD.PARTY.FOUND AND ACCT.WITH.FOUND AND REC.CHG.FOUND
            FT.TXN.OPTION.NO = 4

        CASE THIRD.PARTY.FOUND AND ACCT.WITH.FOUND
            FT.TXN.OPTION.NO = 3

        CASE REC.CHG.FOUND AND ACCT.WITH.FOUND
            FT.TXN.OPTION.NO = 2

        CASE 1
            FT.TXN.OPTION.NO = 1

    END CASE

    TRANS.TYPE = ''
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
        R.OFS.DATA := OFS.DATA:","      ;* BG_100013037 - S
    END   ;* BG_100013037 - E

RETURN
*
* EN_10001322 - E
**********************************************************************************
CHECK.ACCT:
***********************************************************************************
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
* Process each tag routine
*
* NOTE:  Store all the erros in the variable 'MESSAGE.ERROR' separated by FM
* so that all errors will be written in R.OFS.DATA at one shot before calling
* OFS.GLOBUS.MANAGER.

    IF DE.TAG.ID EQ '' THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E

    R.DE.I.SUBROUTINE.TABLE = ''
    DE.I.FIELD.DATA = ''
    SET.ERROR = ''
    SEQ.TAG = ''
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
            SEQ.TAG<1> = SEQUENCED.TAGS<TAG.FIELD.NO>
            IF SEQ.TAG<1> EQ '50F' THEN
                SEQ.TAG<3> = '103'
            END
            CALL @SUBROUTINE.ID (SEQ.TAG,DE.TAG.SEQ.MSG, OFS.DATA,SENDING.CUSTOMER,'','','', DE.I.FIELD.DATA, SET.ERROR)

*If "NULL" has been replaced by "\NULL\" by the tag routine returned above, the same must be replaced to "\NULL" in OFS.DATA, DE.I.FIELD.DATA and DE.I.MSG
            FINDSTR "\NULL\" IN OFS.DATA SETTING POS THEN
                OFS.DATA = CHANGE(OFS.DATA,"\NULL\","\NULL")
                DE.I.FIELD.DATA = CHANGE(DE.I.FIELD.DATA,"\NULL\","\NULL")
                    
                STORE.MSG1 = FIELD(IN.STORE.MSG,":50K:", 2)
                STORE.MSG2 = FIELD(STORE.MSG1,":71A:",1) ;* Holds the data present in DE.I.MSG from 50K to 71A tag
                    
                MSG1.POS = INDEX(IN.STORE.MSG,":50K:",1) + 5  ;* position of the tag 50K in DE.I.MSG
                MSG2.POS = INDEX(IN.STORE.MSG,":71A",1)  - MSG1.POS   ;* position of 71A tag from 50k tag in DE.I.MSG
                
                COUNT.MSG = DCOUNT(STORE.MSG2,@FM)
                FOR I = 1 TO COUNT.MSG      ;* loop through each tag value and replace NULL to \NULL
                    MSG.VALUE = FIELD(STORE.MSG2,@FM,I)
                    IF MSG.VALUE EQ "NULL" THEN
                        STORE.MSG2<I,1> = "\NULL"    ;*replace NULL to \NULL in the DE.I.MSG
                    END
                NEXT I
                
                IN.STORE.MSG[MSG1.POS,MSG2.POS] = STORE.MSG2
            END
                           
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
**************************************************************************
* BG_100013037 - S
*==================
CHECK.SEQUENCE.MSG:
*==================
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
RETURN
********************************************************************************
*========================
CHECK.ON.IN.3RD.REIMB.BK:
*========================
    FIELD.TO.FIND = 'IN.3RD.REIMB.BK'
    GOSUB PROCESS.SEARCH.FIELD
    CCY = DEBIT.CURRENCY
    CHECK.ACCOUNT.CLASS = "VOSTRO"
    GOSUB CHECK.GLOBUS.CUSTOMER
RETURN          ;* BG_100013037 - E
********************************************************************************

*-----------------------------------------------------------------------------

*** <region name= ADD.TO.CONFIRMATION.TRACKER>
ADD.TO.CONFIRMATION.TRACKER:
*** <desc>Create a intial Confirmation Tracker Record even before FT with origin details to track FundsTransfer </desc>
    GOSUB InitialiseTrackerVariables ; *
    
    LOCATE '20' IN SEQUENCED.TAGS SETTING TAG.NO THEN ;* Tag 20 contains Transaction reference details
        RConfiramtionTracker<SFCONF.Contract.ConfirmationTracker.SfconfCntrInwardMsgRef> = SEQUENCED.MESSAGE<TAG.NO> ;*Map Transaction reference to Inward message Reference of Confirmation Tracker
    END
    
    LOCATE '32A' IN SEQUENCED.TAGS SETTING TAG.NO THEN ;*Tag 32A contains Value Date Currency Interbank Settled amount
        Tag32A = SEQUENCED.MESSAGE<TAG.NO>
        
        Date = Tag32A[1,6] ;* Date will be in format YYMMDD
        Date = Date[5,2]:Date[3,2]:Date[1,2] ;*Date changed to format DDYYMM
        RConfiramtionTracker<SFCONF.Contract.ConfirmationTracker.SfconfCntrOrigValDate> = Date ;*Map Date to Original value date of Confirmation Tracker
        
        RConfiramtionTracker<SFCONF.Contract.ConfirmationTracker.SfconfCntrOrigCcy> = Tag32A[7,3] ;* Map currency to Original currency of Confirmation Tracker
        
        Amount = Tag32A[10,99]
        CHANGE ',' TO '.' IN Amount
        RConfiramtionTracker<SFCONF.Contract.ConfirmationTracker.SfconfCntrOrgAmt> = Amount ;*Map Amount to Original Amount of Confirmation Tracker
            
    END
    RConfiramtionTracker<SFCONF.Contract.ConfirmationTracker.SfconfCntrInwardDeliveryRef> = DE.Inward.getRKey() ;*Map DE.I.HEADER id to InwardDeliveryRef of Confirmation Tracker
              
    AppName = "SFCONF.CONFIRMATION.TRACKER" ;*Application Name
    Ofsfunct = 'I'
    Process = 'PROCESS'
    Ofsversion = 'SFCONF.CONFIRMATION.TRACKER,'
    Gtsmode = '3'
    NoOfAuth = '0'
    TransactionId = DE.Inward.getRHead(DE.Config.IHeader.HdrUetrReference) ;*UetrReference is Id of Confirmation Tracker
        
    
*EB.DataAccess.FWrite(AppName,TransactionId,RConfiramtionTracker)
    TracOfsSource = 'CONFTRAC'
        
    EB.Foundation.OfsBuildRecord(AppName, Ofsfunct, Process, Ofsversion, Gtsmode, NoOfAuth, TransactionId, RConfiramtionTracker, TracOfsrecord);*  to build ofs message to create Confirmation Tracker record
    EB.Interface.OfsCallBulkManager(TracOfsSource, TracOfsrecord , TracOfsresponse, TracTxncommitted) ;*Create Confirmation Tracker Record
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= InitialiseTrcakerVariables>
InitialiseTrackerVariables:
*** <desc> </desc>
    Tag32A = ''
    Date = ''
    Amount = ''
    
    RConfiramtionTracker = ''
    AppName = ''
    Ofsfunct = ''
    Process = ''
    Ofsversion = ''
    Gtsmode = ''
    NoOfAuth = ''
    TransactionId = ''
    
    TracOfsrecord = ''
    TracOfsSource = ''
    TracOfsresponse = ''
    TracTxncommitted = ''
    
    
RETURN
*** </region>

END


