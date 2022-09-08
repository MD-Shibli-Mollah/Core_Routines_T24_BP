* @ValidationCode : MjotMTYxNzM2NDc1ODpDcDEyNTI6MTYwMDk1OTkyMDExMDpyZXZhdGh5cmFtZXNoOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyNzk6MjIy
* @ValidationInfo : Timestamp         : 24 Sep 2020 20:35:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : revathyramesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 222/279 (79.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-61</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SP.Foundation
SUBROUTINE SP.OFS.ST12.MAPPING
*-----------------------------------------------------------------------------
* @author rajbhuvanesh@temenos.com
* @stereotype subroutine
*
* Determine MX message by locating the tag that contains the message identification information.
* Transform the XML message into OFSML schema by referring to the corresponding record in EB.TRANSFORM.
* Transformed XML message will be updated into Batch file listener path that is also maintained in securities parameter file
* BFL process the OFSML and updates the transaction to T24
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification history</desc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 09/04/15 - Enhancement_1310009 Task_1310011
*            MT - MX message types ( SECOMS 055)
*
* 25/10/17 - SI:2000232/Enhancement-2294562/Task-2294570
*            Mutual Funds PVB - Upfront Payment for Funds.
*
* 10/07/2020 - SI 2867405/ENH 3830353/TASK 3830356
*              Client BIL -Subscription Order Confirmation Cancellation Instruction-Incoming & Outgoing
*
* 21/07/2020  - Task 3830360
*               Subscription Order Confirmation Cancellation - SwiftOrdSender changes
*
* 27/07/2020 - SI 2867416/ENH 3855485/TASK 3855488
*              Client BIL Redemption Order Confirmation-Incoming & Outgoing
*
* 25/08/20 - SI 3632794 / ENH 3897365 / Task 3897368
*            Client BIL -Marketing Fees-Mapping Charges from SETR execution message to EXE.
*
* 17/09/20 - Task-3975086
*            Regression Errors - Existing setr06 message failures
*
* 21/09/20 - Task 3981427
*            TAFC Warning - Assigning Document.Tag variable.
*
* 24/09/20 - Task 3985955
*            SETR012/SETR006 Mapping Changes.
*-----------------------------------------------------------------------------
*** </region>

*** <region name= INSERTS>
*** <desc>Inserts</desc>
    $USING DE.Config
    $USING EB.SystemTables
    $USING EB.Interface
    $USING DE.Inward
    $USING EB.Foundation
    $USING EB.Browser
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING DE.ModelBank
    $USING SP.Foundation
    $USING SC.SctOrderExecution
    $USING SC.SctOffMarketTrades
    $USING ST.CompanyCreation
    $USING SC.SctOrderCapture
    $USING SC.Config
    $USING SC.SctFees
    
    $INSERT I_DAS.SEC.TRADE
*-----------------------------------------------------------------------------

    GOSUB INITIALISE          ;*Initialise the variables
    IF NOT(EB.SystemTables.getE()) THEN
        GOSUB PROCESS.MESSAGE ;*Process the xml message to convert it into ofsml
    END
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise the variables </desc>
    
    VAR1 = ''
    DEFFUN CHARX(VAR1)
  
    R.XML.IN = ''
    tmp.E = EB.SystemTables.getE()
    tmp.F.DE.I.MSG = DE.Inward.getFDeIMsg()
    tmp.R.KEY = DE.Inward.getRKey()
    R.XML.IN = DE.ModelBank.IMsg.Read(tmp.R.KEY, tmp.E)
    EB.SystemTables.setE(tmp.E)

    R.DE.MESSAGE = ''
    tmp.E = EB.SystemTables.getE()
    tmp.F.DE.MESSAGE = DE.Inward.getFDeMessage()
    tmp.R.HEAD.DE.Config.IHeader.HdrMessageType = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.DE.MESSAGE = DE.Config.Message.Read(tmp.R.HEAD.DE.Config.IHeader.HdrMessageType, tmp.E)
    DE.Inward.setRHead(DE.Config.IHeader.HdrMessageType, tmp.R.HEAD.DE.Config.IHeader.HdrMessageType)
    EB.SystemTables.setE(tmp.E)

    R.OFS.SOURCE = ''
    tmp.E = EB.SystemTables.getE()
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>, tmp.E)
    EB.SystemTables.setE(tmp.E)

    EB.Interface.setOfsSourceId(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>)
    EB.Interface.setOfsSourceRec(R.OFS.SOURCE)

    EQU CR TO CHARX(013)      ;* carriage return
    EQU LF TO CHARX(010)      ;* line feed
    CRLF = CR:LF

    CONVERT @FM TO '' IN R.XML.IN        ;*convert the FM to null
    CONVERT CRLF TO '' IN R.XML.IN      ;*convert the CRLF to null
    CONVERT LF TO '' IN R.XML.IN        ;*convert the LF to null

    EB.TRANSFORM.ID = 'SC-ST12'

    R.SP.STP.PARAM = ''
    SP.Foundation.GetSpStpParam(R.SP.STP.PARAM)

    SOO.ID = ''

    OFS.VERSION.LIST = RAISE(R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>)
    OFS.APP.LIST = FIELDS(OFS.VERSION.LIST,',',1) ;*Get the list of version
    
    SC.EXE.SEC.ORDERS.VERSION = '' ;*Get SEC.OPEN.ORDER vesion fron IN.OFS.VERSION list
    LOCATE 'SC.EXE.SEC.ORDERS' IN OFS.APP.LIST SETTING APP.FOUND.POS THEN
        SC.EXE.SEC.ORDERS.VERSION = OFS.VERSION.LIST<APP.FOUND.POS>
    END
    
    SC.BUILD.UPFRONT.POS.VERSION = '' ;*Get SC.EXE.SEC.ORDERS vesion fron IN.OFS.VERSION list
    LOCATE 'SC.BUILD.UPFRONT.POSITION' IN OFS.APP.LIST SETTING APP.FOUND.POS THEN
        SC.BUILD.UPFRONT.POS.VERSION = OFS.VERSION.LIST<APP.FOUND.POS>
    END
    
    SC.SctOrderExecution.setScMsgExec('')
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc>Process the xml message to convert it into ofsml</desc>

    GOSUB PRE.PROCESS.XSLT    ;*Pre process for XSLT. convert the required tag before XSLT conversion
    
* Fetch EB.TRANSFORM's ID based on version in the message type. By default , fetch SC-ST12 - follows setr.012.001.03 version
    SEARCH.STR = "urn:iso:std:iso:20022:tech:xsd:"
    FIRST.OCCURRENCE = INDEX(DOCUMENT.TAG,SEARCH.STR,1)
    MESSAGE.TYPE = DOCUMENT.TAG[FIRST.OCCURRENCE+LEN(SEARCH.STR),15]
    IF MESSAGE.TYPE EQ "setr.012.001.04" THEN
        EB.TRANSFORM.ID = "SC-setr.012.001.04"
    END

    RESULT.XML = ''
    EB.Browser.CleanXmlText(R.XML.IN,"REPLACE.CODES","")        ;* convert into chars
* transform the xml to ofsxml message
    EB.API.TransformXml(R.XML.IN,EB.TRANSFORM.ID,'',RESULT.XML)
    
    GOSUB SAVE.AND.LOAD.COMPANY ;*Save & Load Company when COMPANY.CODE is different in the message.

* Fetching transaction id
    SOO.ID = FIELD(FIELD(R.XML.IN,'<transactionId>',2),'</transactionId>',1)
    IF SOO.ID NE 'OPODSC' THEN          ;* to avoid empty OFSML
        DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef, SOO.ID)
        DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, FIELD(FIELD(R.XML.IN,'<companyCode>',2),'</companyCode>',1))
    END ELSE
        RESULT.XML = 'OFSML IS NOT GENERATED FOR THE REQUEST ':DE.Inward.getRKey()
    END

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
* if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.EXE.SEC.ORDERS","SP.OFS.ST16.MAPPING","SECURITIES",'',RESULT.XML,'SC.EXE.SEC.ORDERS',XML.IN.ID,'1',RESULT.XML,'')
    END ELSE
        GOSUB POST.PROCESS.XSLT         ;*Convert the amount the fields to curreny decimal points as XSLT 1.0 converts strings to float-point precision numbers before sum
    END

    GOSUB LOAD.SAVED.COMPANY ;*Load Company saved in SAVE.COMPANY.CODE.
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PRE.PROCESS.XSLT>
PRE.PROCESS.XSLT:
*** <desc>Pre process for XSLT. convert the required tag before XSLT conversion </desc>

* Remove header part
    R.XML.IN = FIELD(R.XML.IN,'<Document',2)
    DOCUMENT.TAG = FIELD(R.XML.IN,'>',1)
    R.XML.IN = FIELD(R.XML.IN,'</Document',1)
    R.XML.IN = '<?xml version="1.0" encoding="UTF-8"?><Document':R.XML.IN:'</Document>'

* AddtlInf might exceed T24 filed length so cut short and make it multi value
    FINDSTR '<AddtlInf>' IN R.XML.IN<1> SETTING FPOS,VPOS THEN
        R.XML.IN = CHANGE(R.XML.IN,'><','>':@FM:'<')
        LINE.CNT = 1
        SPLIT.R.XML.IN = R.XML.IN
        LOOP
            REMOVE CURRENT.LINE FROM R.XML.IN SETTING LPOS
        WHILE CURRENT.LINE:LPOS
            IF INDEX(CURRENT.LINE,'<AddtlInf>',1) THEN
                FIELD.VAL = FIELD(R.XML.IN<LINE.CNT>,'>',2)
                FIELD.VAL = FIELD(FIELD.VAL ,'<',1)         ;*remove the tag and get the value
                LEN.FIELD.VAL = LEN(FIELD.VAL)
                MAX.LEN = 35
                IF LEN.FIELD.VAL GT MAX.LEN THEN
                    GOSUB SPLIT.ADDITIONAL.INFO   ;*Split the additional information string by 35 characters as T24 allows max of 35
                    SPLIT.R.XML.IN<LINE.CNT> = FIELD.VAL
                END
            END
            LINE.CNT +=1
        REPEAT
        R.XML.IN = CHANGE(SPLIT.R.XML.IN,'>':@FM:'<','><')
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SPLIT.ADDITIONAL.INFO>
SPLIT.ADDITIONAL.INFO:
*** <desc>Split the additional information string by 35 characters as T24 allows max of 35 </desc>

    TEMP.FIELD.VAL = ''
    DIV.SPLIT = LEN.FIELD.VAL/MAX.LEN
    IF INDEX(DIV.SPLIT,'.',1) THEN
        DIV.SPLIT = FIELD(DIV.SPLIT,'.',1) + 1
    END
    START.POS = 1
    END.POS = MAX.LEN
    FOR I = 1 TO  DIV.SPLIT
        END.POS =  MAX.LEN * I
        TEMP.FIELD.VAL<1,I> = FIELD.VAL[START.POS,MAX.LEN]
        START.POS = END.POS + 1
    NEXT I
    FIELD.VAL = '<AddtlInf>':CHANGE(TEMP.FIELD.VAL,@VM,'</AddtlInf><AddtlInf>'):'</AddtlInf>'

RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= POST.PROCESS.XSLT>
POST.PROCESS.XSLT:
*** <desc>Main Section to build OFS & transaction updates. </desc>

    GOSUB FORMAT.TRANSFORMED.XML ;*Format Transformed XML & fetch values from the transformed XML
        
    SC.EXE.ID = SOO.ID
    R.SC.EXE.SEC.ORDERS = ''
    ER = ''
    R.SC.EXE.SEC.ORDERS = SC.SctOrderExecution.ExeSecOrders.ReadNau(SC.EXE.ID, ER)          ;*Read SC.EXE.SEC.ORDERS
    IF NOT(ER) THEN ;*if found
        CUS.SEC.ID = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoCustomerNo,1>
        GOSUB READ.CUSTOMER.SECURITY ;* Reading the Customer Security record.
        EXE.HLT = R.CUS.SEC<SC.Config.CustomerSecurity.CscExeHlt> EQ 'YES' AND R.CUS.SEC<SC.Config.CustomerSecurity.CscSwiftOrdInstr> EQ 'YES'
        IF SOO.ID THEN
            IF NOT(EXE.HLT) THEN
                GOSUB SC.EXE.OFS.BUILD.PROCESS ; *Calling OFS.BUILD.RECORD for SC.EXE.SEC.ORDERS.
                R.XML.IN = OFS.RECORD
                GOSUB UPDATE.OFSML.IN.DIR   ;*Update the OFSML by looping according to the servicerequest tag\
            END
            GOSUB READ.ORD.INSTR.LOG ; *Reading SC.ORD.INSTR.LOG ID
            GOSUB DETERMINE.EXE.STATUS ; *To determine the status of the execution.
            GOSUB UPD.SC.ORD.INSTR.LOG ; *Update the SC.ORD.INSTR.LOG
        END
    END ELSE
*Check if the SESO record in history involves upfront security,
*to confirm if a order involved UPFRONT.SECURITY & SEC.TRADE was created.
        FN.SC.EXE.SEC.ORDERS = 'F.SC.EXE.SEC.ORDERS$HIS'
        F.SC.EXE.SEC.ORDERS = ''
        EB.DataAccess.Opf(FN.SC.EXE.SEC.ORDERS, F.SC.EXE.SEC.ORDERS)
        
        R.SC.EXE.SEC.ORDERS = ''
        E.SC.EXE.SEC.ORDERS = ''
        EB.DataAccess.ReadHistoryRec(F.SC.EXE.SEC.ORDERS, SC.EXE.ID, R.SC.EXE.SEC.ORDERS, E.SC.EXE.SEC.ORDERS)
        
        ERR.MSG = 'ORDER ALREADY EXECUTED'
        GOSUB READ.ORD.INSTR.LOG ; *Reading SC.ORD.INSTR.LOG ID
        GOSUB UPD.SC.ORD.INSTR.LOG ; *Update the SC.ORD.INSTR.LOG
        
        SEC.TRADE.ID = RAISE(R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoSecTradeId>) ;*SEC.TRADE id in SC.EXE.SEC.ORDERS is a subvalue field.
        UPFRONT.SEC = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoUpfrontSec>
        IF UPFRONT.SEC AND SEC.TRADE.ID THEN
            GOSUB CREATE.SC.BUILD.UPFRONT.POSITION ;*Create SC.BUILD.UPFRONT.POSITION for an UPFRONT.SEC involved order, when 515 is received with NAV
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= FORMAT.TRANSFORMED.XML>
FORMAT.TRANSFORMED.XML:
*** <desc>Format Transformed XML & fetch values from the transformed XML </desc>

*Message will have the below repeating blocks in the transformed XML which stores values on mapped fields
*    <messageDataApps>
*        <field>
*            <fieldName></fieldName>
*            <value></value>
*        </field>
*    </messageDataApps>

    TEMP.R.XML.IN = CHANGE(R.XML.IN,'<messageDataApps>',@FM:'<messageDataApps>')

    LOOP
        REMOVE CURR.FIELD FROM TEMP.R.XML.IN SETTING FLD.POS
    WHILE CURR.FIELD:FLD.POS

        FLD.NAME = FIELD(FIELD(CURR.FIELD,'<fieldName>',2),'</fieldName>',1)

        BEGIN CASE

            CASE FLD.NAME = 'BROKER.NO'
                DE.Inward.setRHead(DE.Config.IHeader.HdrCustomerNo, FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1))
                BROKER.NO = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)
                
            CASE FLD.NAME = 'BR.BROKER.COMM' ;* Will be mapped from setr.012.001.03 version alone
*  check whether OFSML has the field BR.BROKER.COMM
                FIELD.VAL = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)       ;*remove the tag and get the value
                TRD.CCY = FIELD.VAL[1,3]    ;* In XSLT we transformed the amount as CCYAMT - USD2501.00000006
                BR.BROKER.COMM = FIELD.VAL[4,LEN(FIELD.VAL)]
                EB.Foundation.ScFormatCcyAmt(TRD.CCY,BR.BROKER.COMM)
                
            CASE FLD.NAME = 'PRICE'
                PRICE = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1) ;*copy price from the message.
                
            CASE FLD.NAME = 'NOMINAL.RECD'
                NOMINAL.RECD = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1) ;*copy nominal from the message.
                
            CASE FLD.NAME = 'INT.CTR'
                INT.CTR = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1) ;*copy IntCtr from the message.
                
            CASE FLD.NAME = 'TRADE.DATE'
                TRADE.DATE = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1) ;*copy TradeDate from the message.
                
            CASE FLD.NAME = 'VALUE.DATE'
                VALUE.DATE = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1) ;*copy ValueDate from the message.
                
            CASE FLD.NAME = 'CHARGE.TYPE'
                GOSUB GET.MV.VALUE.FROM.TAG
                CHARGE.TYPE<1,MV> = TAG.VALUE ;*copy ChargeType from the message.

            CASE FLD.NAME = 'CHARGE.AMT'
                GOSUB GET.MV.VALUE.FROM.TAG
                CHARGE.AMT<1,MV> = TAG.VALUE ;*copy ChargeType from the message.
                               
        END CASE
    REPEAT
* hardcoded version is changed to DE.MESSAGE defined version
    R.XML.IN = CHANGE(R.XML.IN,'<version>$$VERSION$$</version>','<version>':FIELD(SC.EXE.SEC.ORDERS.VERSION,',',2):'</version>')

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.OFML.IN.DIR>
UPDATE.OFSML.IN.DIR:
*** <desc>Update the OFSML by looping according to the servicerequest tag </desc>


    IF R.XML.IN THEN
* drop the ofs to the bulk manager
        RETURN.FLAG = ''
        R.XML.RES = ''
        EB.Interface.OfsBulkManager(R.XML.IN,R.XML.RES,RETURN.FLAG)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CREATE.SC.BUILD.UPFRONT.POSITION>
CREATE.SC.BUILD.UPFRONT.POSITION:
*** <desc>Create SC.BUILD.UPFRONT.POSITION for an UPFRONT.SEC involved order, when 515 is received with NAV </desc>

*Create SC.BUILD.UPFRONT.POSITION to trigger Transfer Out from UPFRONT.SEC  & Transfer In for the original security.

    FUND.ID = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoSecurityNo> ;* Original security in the order
        
    R.SC.BUILD.UPFRONT.POSITION = ''
    R.SC.BUILD.UPFRONT.POSITION<SC.SctOffMarketTrades.ScBuildUpfrontPosition.ScBuiFundId> = FUND.ID ;* fund ID to perform Transfer IN & for which NAV is receieved.
    R.SC.BUILD.UPFRONT.POSITION<SC.SctOffMarketTrades.ScBuildUpfrontPosition.ScBuiNav> = PRICE ;*Price from the Message
    GOSUB GET.TRADE.IDS ;*Get Trade IDs for the order , for which Transfers should be generated
    R.SC.BUILD.UPFRONT.POSITION<SC.SctOffMarketTrades.ScBuildUpfrontPosition.ScBuiSecTradeId> = SEC.TRADE.ID.LIST ;*SEC.TRADE references from the order
    
    OFS.FUNCT = 'I'
    PROCESS = 'PROCESS'
    OFS.VERSION = SC.BUILD.UPFRONT.POS.VERSION
    GTS.MODE = 0
    NO.OF.AUTH = '' ;*Leave it in INAU .
    TRANSACTION.ID = ''
    RECORD = R.SC.BUILD.UPFRONT.POSITION
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord('SC.BUILD.UPFRONT.POSITION', OFS.FUNCT, PROCESS, OFS.VERSION , GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, RECORD, OFS.RECORD)
    
    R.XML.IN = OFS.RECORD
    GOSUB UPDATE.OFSML.IN.DIR ;*Trigger OFS.BULK.MANAGER.
        
RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= GET.TRADE.IDS>
GET.TRADE.IDS:
*** <desc> </desc>

    SEC.TRADE.ID.LIST = ''
    PARENT.REFERENCE = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoParentReference> ;*Parent Reference
    IF PARENT.REFERENCE THEN
        DAS.LIST = dasChildTradeAuth
        THE.ARGS = PARENT.REFERENCE
        TABLE.SUFFIX = ''
        EB.DataAccess.Das('SEC.TRADE',DAS.LIST,THE.ARGS,TABLE.SUFFIX)
        SEC.TRADE.ID.LIST = LOWER(DAS.LIST) ;*DAS.LIST comes with FM separated.
    END ELSE
        SEC.TRADE.ID.LIST = RAISE(R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoSecTradeId>) ;*SEC.TRADE id in SC.EXE.SEC.ORDERS is a subvalue field.
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SAVE.AND.LOAD.COMPANY>
SAVE.AND.LOAD.COMPANY:
*** <desc>Save & Load Company when COMPANY.CODE is different in the message. </desc>

    COMPANY.CODE = FIELD(FIELD(R.XML.IN,'<companyCode>',2),'</companyCode>',1)
    SAVE.COMPANY.CODE = ''
    IF COMPANY.CODE AND COMPANY.CODE NE EB.SystemTables.getIdCompany() THEN
        SAVE.COMPANY.CODE = EB.SystemTables.getIdCompany()
        ST.CompanyCreation.LoadCompany(COMPANY.CODE)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= LOAD.SAVED.COMPANY>
LOAD.SAVED.COMPANY:
*** <desc>Load Company saved in SAVE.COMPANY.CODE. </desc>
        
    IF SAVE.COMPANY.CODE THEN
        ST.CompanyCreation.LoadCompany(SAVE.COMPANY.CODE)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.ORD.INSTR.LOG>
READ.ORD.INSTR.LOG:
*** <desc>Reading SC.ORD.INSTR.LOG </desc>
    R.SC.ORD.INSTR.LOG = '' ; READ.ERR = '' ; READ.RETRY = ''
    SC.SctOrderCapture.OrdInstrLogLock(SOO.ID, R.SC.ORD.INSTR.LOG, READ.ERR, READ.RETRY, '') ;*Read & Lock SC.ORD.INSTR.LOG.
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPD.SC.INSTR.LOG>
UPD.SC.ORD.INSTR.LOG:
*** <desc>Update the SC.ORD.INSTR.LOG </desc>
    MSG.DETAILS = '' ; MSG.FUNC = 'NEWM'
    MSG.DETAILS<2> = 'SETR012' ;* MessageType
    MSG.DETAILS<3> = 'INWARD' ;*MessageInOut
    MSG.DETAILS<4> = MSG.FUNC ;* MessageFunction
    MSG.DETAILS<8> = tmp.R.KEY ;* DeliveryReference
    MSG.DETAILS<9> = PRICE ;*MessagePrice
    MSG.DETAILS<10> = NOMINAL.RECD ;* NominalReceived
    MSG.DETAILS<11> = BROKER.NO ;*BrokerNo
    
* Call this routine to update the message details to the log.
    IF R.SC.ORD.INSTR.LOG THEN
        SC.SctOrderCapture.ScOrdLogFileUpd(SOO.ID, R.SEC.OPEN.ORDER,  MSG.DETAILS, ERR.MSG, R.SC.ORD.INSTR.LOG,'','','','','')
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.CUSTOMER.SECURITY>
READ.CUSTOMER.SECURITY:
*** <desc>Reading the Customer Security record. </desc>
    R.CUS.SEC = SC.Config.CustomerSecurity.Read(CUS.SEC.ID,CUS.SEC.ERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DETERMINE.EXE.STATUS>
DETERMINE.EXE.STATUS:
*** <desc>To determine the status of the execution. </desc>
        
    IF SC.SctOrderExecution.getScMsgExec() THEN ;* Variable to check if the Order is executed.
        ERR.MSG = ''
    END ELSE
        ERR.MSG = 'ORDER NOT EXECUTED' ;* If the variable is not set, then raise this error.
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SC.EXE.OFS.BUILD.PROCESS>
SC.EXE.OFS.BUILD.PROCESS:
*** <desc>Calling OFS.BUILD.RECORD for SC.EXE.SEC.ORDERS. </desc>

* XML format is changed to OFS format since SC.BUILD.UPFRONT.POSITION is in OFS.
* So commonly making both as OFS message.

    OFS.SC.EXE.SEC.ORDERS = ''
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoTradeDate> = TRADE.DATE
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoValueDate> = VALUE.DATE
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoIntCtr> = INT.CTR
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoNominalRecd> = NOMINAL.RECD
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoPrice> = PRICE
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoBrBrokerComm> = BR.BROKER.COMM ;* Will be mapped from setr.012.001.03 version alone
    OFS.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoBrokerNo> = BROKER.NO
    
* Mapping Broker side charges.
    SP.Foundation.SpMapBrChgFromMsg(R.SC.EXE.SEC.ORDERS, CHARGE.TYPE, CHARGE.AMT, OFS.SC.EXE.SEC.ORDERS, '', '', '')
    
    OFS.FUNCT = 'I'
    PROCESS = 'PROCESS'
    OFS.VERSION = SC.EXE.SEC.ORDERS.VERSION
    GTS.MODE = 0
    NO.OF.AUTH = 0
    TRANSACTION.ID = SOO.ID
    RECORD = OFS.SC.EXE.SEC.ORDERS
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord('SC.EXE.SEC.ORDERS', OFS.FUNCT, PROCESS, OFS.VERSION , GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, RECORD, OFS.RECORD)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.MV.VALUE.FROM.TAG>
GET.MV.VALUE.FROM.TAG:
*** <desc>Get Field Value along with this MV</desc>

*Get the incoming field value in var: FIELD.VALUE
    MV = FIELD(FIELD(CURR.FIELD,'<multiValueNumber>',2),'</multiValueNumber>',1)
    IF NOT(MV) THEN
        MV = 1
    END
    
    TAG.VALUE = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)
                
RETURN
                
*** </region>
*-----------------------------------------------------------------------------
END


