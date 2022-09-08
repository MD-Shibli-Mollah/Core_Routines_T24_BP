* @ValidationCode : MjoxOTQ2NDUxMjI5OkNwMTI1MjoxNjEwMTExNjQxMjY5OmFtb2hhbW1lZHdhc2ltOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDozODA6MjU5
* @ValidationInfo : Timestamp         : 08 Jan 2021 18:44:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amohammedwasim
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 259/380 (68.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-102</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SP.Foundation
SUBROUTINE SP.OFS.ST16.MAPPING
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
* 10/11/17 - Defect-2336343/Task-2338587
*            509 doesnot update ORDER.STATUS when message comes with STATUS.CODE other than PACK
*
* 20/06/2020 - SI 3362433 Enhancement 3765466 Task 3765469
*              Order Flow - Inward MX processing
*
* 15/06/2020 - SI-3362433/ENH-3765493/TASK-3765496
*              Order Flow - Outward MX Processing
*
* 24/06/20   - Task 3765473
*              Adding Inward Delivery Reference
*
* 22/06/2020 - SI-3362433/ENH-3765493/TASK-3765500
*              Order Flow - Outward processing
*
* 13/07/2020 - Task - 3806595
*              ENC2 Client BIL -Order Cancellation Status Report-Cancellation - Inward MX Processing
*
* 14/07/2020 - SI 2867405/ENH 3830353/TASK 3830356
*              Client BIL -Subscription Order Confirmation Cancellation Instruction-Incoming & Outgoing
*
* 21/07/2020 - 3855998
*              Rework in SETR016 incoming message
*
* 27/07/2020 - SI 2867416/ENH 3855485/TASK 3855488
*              Client BIL Redemption Order Confirmation-Incoming & Outgoing
*
* 08/01/21 - Task - 4162873
*            On processing incoming SETR016 with status PACK, Order status is not getting updated as 'Cancellation Received'
*-----------------------------------------------------------------------------
*** </region>

*** <region name= INSERTS>
*** <desc>Inserts</desc>
* $INSERT I_COMMON - Not Used anymore;
* $INSERT I_EQUATE - Not Used anymore;
* $INSERT I_F.DE.MESSAGE - Not Used anymore;
* $INSERT I_DEICOM - Not Used anymore;
* $INSERT I_F.DE.HEADER - Not Used anymore;
* $INSERT I_F.EB.TRANSFORM - Not Used anymore;
* $INSERT I_F.SP.ORDER.STP.ACTIVITY - Not Used anymore;
* $INSERT I_F.SP.STP.PARAM - Not Used anymore;
* $INSERT I_GTS.COMMON - Not Used anymore;

    $USING DE.Config
    $USING EB.SystemTables
    $USING EB.Interface
    $USING DE.Inward
    $USING EB.Foundation
    $USING EB.Browser
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING DE.ModelBank
    $USING SP.Foundation
    $USING ST.CompanyCreation
    $USING SC.SctOrderCapture
    $USING SC.SctOrderExecution
    $USING SC.Config
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
    MSG.FUNC = ''
    NARRATIVE = ''
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

    OFS.VERSION.LIST = RAISE(R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>)
    OFS.APP.LIST = FIELDS(OFS.VERSION.LIST,',',1) ;*Get the list of version
    
    SESO.VERSION = '' ;*Get SC.EXE.SEC.ORDERS vesion fron IN.OFS.VERSION list
    SOO.VERSION = ''
    LOCATE 'SC.EXE.SEC.ORDERS' IN OFS.APP.LIST SETTING APP.FOUND.POS THEN
        SESO.VERSION = OFS.VERSION.LIST<APP.FOUND.POS>
    END
    SOO.POS = ''
    LOCATE 'SEC.OPEN.ORDER' IN OFS.APP.LIST SETTING SOO.POS THEN
        SOO.VERSION = OFS.VERSION.LIST<SOO.POS>
    END
    
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

    EB.TRANSFORM.ID = 'SC-ST16'

    R.SP.STP.PARAM = ''
    SP.Foundation.GetSpStpParam(R.SP.STP.PARAM)

    SOO.ID = ''
    SAVE.COMPANY.CODE = '' ;*Initialise SAVE.COMPANY.CODE
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc>Process the xml message to convert it into ofsml</desc>

    GOSUB PRE.PROCESS.XSLT    ;*Pre process for XSLT. convert the required tag before XSLT conversion
    RESULT.XML = ''
* transform the xml to ofsxml message
;*Pass EbTransformId - EB.TRANSFORM.XML transforms the xml using the xsl by using XMLTOXML function
    EB.API.TransformXml(R.XML.IN, EB.TRANSFORM.ID,'',RESULT.XML)
* Fetching transaction id
    SOO.ID = FIELD(FIELD(R.XML.IN,'<transactionId>',2),'</transactionId>',1)
    MSG.ID = FIELD(FIELD(R.XML.IN,'<MsgId>',2),'</MsgId>',1)
    IF SOO.ID NE 'OPODSC' THEN          ;* to avoid empty OFSML
        DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef, SOO.ID)
        DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, FIELD(FIELD(R.XML.IN,'<companyCode>',2),'</companyCode>',1))
    END ELSE
        RESULT.XML = 'OFS IS NOT GENERATED FOR THE REQUEST ':DE.Inward.getRKey()
    END
    
    GOSUB SAVE.AND.LOAD.COMPANY ;*Save & Load Company when COMPANY.CODE is different in the message.

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
* if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.EXE.SEC.ORDERS","SP.OFS.ST16.MAPPING","SECURITIES",'',RESULT.XML,'SC.EXE.SEC.ORDERS',XML.IN.ID,'1',RESULT.XML,'')
    END ELSE
        GOSUB POST.PROCESS.XSLT         ;*Main Section to build OFS & transaction updates.
    END
    
    IF SAVE.COMPANY.CODE THEN
        ST.CompanyCreation.LoadCompany(SAVE.COMPANY.CODE)
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
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= POST.PROCESS.XSLT>
POST.PROCESS.XSLT:
*** <desc>Main Section to build OFS & transaction updates.</desc>

    GOSUB FORMAT.TRANSFORMED.XML ;*Format Transformed XML & fetch values from the transformed XML

*Process SEC.OPEN.ORDER/SC.EXE.SEC.ORDERS based on instrcutions based on tag values to frame OFS messages from the data received.
    GOSUB CHECK.CANCEL.REQ ;* Gosub to Check whether this message is received as a response for cancellation request.
    IN.RECORD = ''
    STP.STATUS = ''
    IF ORDER.STATUS EQ "REJECTED" THEN
        MSG.FUNC = 'REJT'
        IF CANC.REQ THEN
;* If the CancellationRequest is Rejected then Update the SOO with OrderStatus as CancellationRejected
;* DealStatus remains Transmitted
;* Update Sp.Order.Stp.Activity even for CancellationRequest Rejection
            MSG.FUNC = 'RJCTD'
            STP.STATUS = 'REJECTED'
            GOSUB UPDATE.STP.ACTIVITY ; *
            IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Rejected'
            GOSUB BUILD.OFS.RECORD
        END ELSE
            GOSUB POST.REJECTED.MESSAGE ;*Post Rejected Message on SC.EXE.SEC.ORDERS
            GOSUB UPDATE.LOG ; *Updating SC.ORD.INSTR.LOG
            IF R.SC.ORD.INSTR.LOG THEN
                GOSUB UPDATE.ORDER.STATUS.IN.ORDER ;*Update ORDER.STATUS in ORDER
            END
        END
        
    END ELSE
        IF STATUS.CODE EQ "PACK" THEN
;* Broker Can also send SETR016 for acceptance of Cancellation Request
            IF CANC.REQ THEN
;* When the status received from the client is PACK, then write the SOO instead of using OFS
;* Because we can't amend the SOO record until we get confirmation from the Client
;* either Cancellation Accepted or Cancellation Rejected
;* It is tracked using SP.ORDER.STP.ACTIVITY in Check record of SOO.
                MSG.FUNC = 'PACK'
                R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Received'
                SC.SctOrderCapture.SecOpenOrderWrite(SOO.ID, R.SEC.OPEN.ORDER, '')
                GOSUB UPDATE.LOG ; *
            END ELSE
                GOSUB CREATE.EXE.FOR.UPFRONT.PAYMENT ;*Create EXE record to create a Trade
                STP.STATUS = 'ACCEPTED'
                GOSUB UPDATE.STP.ACTIVITY ; *
            END
        END
        IF STATUS.CODE EQ 'CANP' THEN
;* When the Broker send CANC message for the Cancellation request thru SETR016 then update the SOO
;* with OrderStatus as Cancellation Accepted
;* Change the DealStatus as Cancelled
;* Update Sp.Order.Stp.Activity for CancellationRequest Acceptance
            IF CANC.REQ THEN
                STP.STATUS = 'ACCEPTED'
                GOSUB UPDATE.STP.ACTIVITY ; *
                MSG.FUNC = 'CANP'
                IN.RECORD = ''
                IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooDealStatus> = 'CANCELLED'
                IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Accepted'
                GOSUB BUILD.OFS.RECORD
            END
        END
    
    END
    
    IF NOT(CANC.REQ) THEN
        GOSUB UPDATE.SOO.RECORD ;*Update ORDER.STATUS to order from STATUS.CODE
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

        FLD.NAME = FIELD(FIELD(CURR.FIELD,'<fieldName>',2),'</fieldName>',1) ;*This is used to identify the field name

        BEGIN CASE

            CASE FLD.NAME = 'BROKER.NO'
                BROKER.NO = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)
                DE.Inward.setRHead(DE.Config.IHeader.HdrCustomerNo, BROKER.NO)
            
            CASE FLD.NAME = 'ORDER.STATUS'
                ORDER.STATUS = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)

            CASE FLD.NAME = 'ORDER.STATUS.CODE'
                STATUS.CODE = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)
                
            CASE FLD.NAME = 'SETT.NARRATIVE' ;*This comes as Multi value field, so append it every time
                GOSUB GET.MV.VALUE.FROM.TAG
                SETT.NARRATIVE<1,MV> = TAG.VALUE
                
            CASE FLD.NAME = 'BR.BROKER.COMM'
*  check whether OFSML has the field BR.BROKER.COMM
                FIELD.VAL = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)       ;*remove the tag and get the value
                TRD.CCY = FIELD.VAL[1,3]    ;* In XSLT we transformed the amount as CCYAMT - USD2501.00000006
                BR.BROKER.COMM = FIELD.VAL[4,LEN(FIELD.VAL)]
                EB.Foundation.ScFormatCcyAmt(TRD.CCY,BR.BROKER.COMM)
                
        END CASE
    REPEAT

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

*** <region name= POST.REJECTED.MESSAGE>
POST.REJECTED.MESSAGE:
*** <desc>Post Rejected Message on SC.EXE.SEC.ORDERS . </desc>
    
    GOSUB READ.SP.ORDER.STP.ACTIVITY    ;*Read the SP.ORDER.STP.ACTIVITY
    
    LOCATE BROKER.NO IN R.SP.ORDER.ACTIVITY <SP.Foundation.OrderStpActivity.OrdActBrokerNo,1> SETTING ORD.ACT.POS THEN
*Find the broker position to update status accordingly.
*Find the broker position to update status accordingly.
        R.SP.ORDER.ACTIVITY<SP.Foundation.OrderStpActivity.OrdActBrMsgStatus,ORD.ACT.POS> = 'ACCEPTED'
        GOSUB WRITE.SP.ORDER.STP.ACTIVITY  ;*Update the SP.ORDER.ACTIVITY with LIVE in ACT.BR.MSG.STATUS
    END
        
    OFS.R.SC.EXE.SEC.ORDERS = ''
    OFS.R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoOrderStatus> = "REJECTED" ;*Order is rejected.
    OFS.R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoBrBrokerComm> = BR.BROKER.COMM

    OFS.FUNCT = 'I'
    PROCESS = 'PROCESS'
    GTS.MODE = 0
    NO.OF.AUTH = 0
    TRANSACTION.ID = SOO.ID
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord('SC.EXE.SEC.ORDERS', OFS.FUNCT, PROCESS, SESO.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, OFS.R.SC.EXE.SEC.ORDERS, OFS.RECORD)
    OFS.MESSAGE = OFS.RECORD
    IF OFS.MESSAGE THEN
        GOSUB CALL.OFS.BULK.MANAGER  ;*Call OFS.BULK.MANAGER to update EXE as REJECTED
    END
        
RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= READ.SP.ORDER.STP.ACTIVITY>
READ.SP.ORDER.STP.ACTIVITY:
*** <desc>Read the SP.ORDER.STP.ACTIVITY </desc>

    FERR = ''
    R.SP.ORDER.ACTIVITY = ''
    R.SP.ORDER.ACTIVITY = SP.Foundation.OrderStpActivity.Read(SOO.ID, FERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= WRITE.SP.ORDER.STP.ACTIVITY>
WRITE.SP.ORDER.STP.ACTIVITY:
*** <desc>Write to SP.ORDER.STP.ACTIVITY </desc>

    SP.Foundation.OrderStpActivity.Write(SOO.ID, R.SP.ORDER.ACTIVITY)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.SOO.RECORD>
UPDATE.SOO.RECORD:
*** <desc>Update ORDER.STATUS to order from STATUS.CODE</desc>

* Prepare SEC.OPEN.ORDER record with order status depending on STATUS.CODE
* And trigger the generation of OFS message for SEC.OPEN.ORDER by setting POST.SOO.OFS
    
*Currrently MX to T24 mapped status is PACK only.
    ORDER.STATUS = ''
    BEGIN CASE
        CASE STATUS.CODE EQ 'PACK'
            ORDER.STATUS = "ACKNOWLEDGED"
        CASE STATUS.CODE EQ 'SUSP'
            ORDER.STATUS = "SUSPENDED"
    END CASE

    IF ORDER.STATUS THEN ;*When ORDER.STATUS is applicable, the SEC.OPEN.ORDER should be written.
        ID.SEC.OPEN.ORDER = SOO.ID
        GOSUB UPDATE.ORDER.STATUS.IN.ORDER ;*Update ORDER.STATUS in ORDER
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.ORDER.STATUS.IN.ORDER>
UPDATE.ORDER.STATUS.IN.ORDER:
*** <desc>Update ORDER.STATUS in ORDER. </desc>
    GOSUB READ.SOO
    IF NOT(E.SEC.OPEN.ORDER) THEN ;*When there isnt any error in above read, then Lock & Write status.
        R.SEC.OPEN.ORDER = ''
        E.SEC.OPEN.ORDER = ''
        RETRY = ''
        SC.SctOrderCapture.SecOpenOrderLock(ID.SEC.OPEN.ORDER, R.SEC.OPEN.ORDER, E.SEC.OPEN.ORDER, RETRY, '') ;*Read & Lock SEC.OPEN.ORDER in LIVE to update order status.
                
        R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = ORDER.STATUS
        SC.SctOrderCapture.SecOpenOrderWrite(ID.SEC.OPEN.ORDER, R.SEC.OPEN.ORDER, '')
        
        
        IF ORDER.STATUS EQ 'ACKNOWLEDGED' THEN
*Outward When incoming PACK is processed, outward will be sent with Acknowledged status
            OUT.DETS = ''
            OUT.DETS<1> = ID.SEC.OPEN.ORDER ;*Log id
            OUT.DETS<2> = 'ACKNOWLEDGED' ;*status
            OUT.DETS<3> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityAccnt> ;*SAM
            OUT.DETS<4> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo> ;*SM
            OUT.DETS<5> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooStockExchange> ;*Stock Exchange
            OUT.DETS<6> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooOrderType> ;*OrderType
            OUT.DETS<7> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooOrderNominal> ;*No.Nominal
            OUT.DETS<8> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooCurrPrice> ;*Price
            OUT.DETS<9> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo> ;*SM
            OUT.DETS<10> = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooTradeCcy> ;*TradeCcy
            SC.SctOrderCapture.OrdStatusMxDelivery(OUT.DETS) ;*outward delivery
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CREATE.EXE.FOR.UPFRONT.PAYMENT>
CREATE.EXE.FOR.UPFRONT.PAYMENT:
*** <desc>Create EXE record to create a Trade </desc>

    R.SC.EXE.SEC.ORDERS = SC.SctOrderExecution.ExeSecOrders.ReadNau(SOO.ID, EXE.ERR)
    TRANS.CODE = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoTransactionCode>
    CRED.DEB = ''
    ERR = ''
    SC.Config.GetTransType(TRANS.CODE, CRED.DEB, ERR)
                    
    ORDER.TYPE = R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoOrderType>
    E.ORDER.TYPE = ''
    R.ORDER.TYPE = SC.SctOrderCapture.OrderType.Read(ORDER.TYPE, E.ORDER.TYPE)
    CASH.ORDER = R.ORDER.TYPE<SC.SctOrderCapture.OrderType.ScOrtCashOrder>
                    
    IF NOT(R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoUpfrontSec> AND CRED.DEB EQ 'CREDIT' AND CASH.ORDER EQ "YES") THEN
        RETURN
    END
    
*In case of 'Upfront Payment For Funds' , when 509 is received as PACK
*SESO should be executed with NOMINAL.RECD as TOTAL.CASH.AMOUNT from Customer side & PRICE as 1
    TOTAL.CASH.AMOUNT = SUM(R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoCuCashAmount>)
    
    OFS.R.SC.EXE.SEC.ORDERS = ''
    OFS.R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoBrokerNo> = BROKER.NO
    OFS.R.SC.EXE.SEC.ORDERS<SC.SctOrderExecution.ExeSecOrders.ScEsoPrice> = 1 ;*Always 1 NAV
        
    OFS.FUNCT = 'I'
    PROCESS = 'PROCESS'
    GTS.MODE = 0
    NO.OF.AUTH = 0
    TRANSACTION.ID = SOO.ID
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord('SC.EXE.SEC.ORDERS', OFS.FUNCT, PROCESS, SESO.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, OFS.R.SC.EXE.SEC.ORDERS, OFS.RECORD)
    OFS.MESSAGE = OFS.RECORD
    IF OFS.MESSAGE THEN
        GOSUB CALL.OFS.BULK.MANAGER
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.OFML.IN.DIR>
CALL.OFS.BULK.MANAGER:
*** <desc>Update the OFSML by looping according to the servicerequest tag </desc>

* drop the ofs to the bulk manager
    OFS.RESULT = ''
    RETURN.FLAG = ''
    EB.Interface.OfsBulkManager(OFS.MESSAGE,OFS.RESULT,RETURN.FLAG)

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
    SC.SctOrderCapture.OrdInstrLogLock(ID.SEC.OPEN.ORDER, R.SC.ORD.INSTR.LOG, READ.ERR, READ.RETRY, '') ;*Read & Lock SC.ORD.INSTR.LOG.
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPD.SC.INSTR.LOG>
UPD.SC.ORD.INSTR.LOG:
*** <desc>Update the SC.ORD.INSTR.LOG </desc>
    IF CANC.REQ THEN
        ORD.DETS = ''
        ORD.DETS<4> = 'SETR016'
        ORD.DETS<11> = 'INWARD'
        ORD.DETS<10> = MSG.FUNC
        ORD.DETS<12> = tmp.R.KEY
        BEGIN CASE
            CASE NARRATIVE
                ORD.DETS<13> = NARRATIVE
            CASE ORDER.STATUS EQ 'REJECTED'
                ORD.DETS<13> = ERR.MSG ;* If Rejected
            CASE STATUS.CODE EQ 'PACK'
                ORD.DETS<13> = 'Cancellation Received'
            CASE STATUS.CODE EQ 'CANP'
                ORD.DETS<13> = 'Cancellation Accepted'
        END CASE
;*Call this routine to update the message details to the log.
        SC.SctOrderCapture.ScOrdLogFileUpd(ID.SEC.OPEN.ORDER, '', '', '', R.SC.ORD.INSTR.LOG, ORD.DETS,'','','','')
    END ELSE
        MSG.DETAILS<1> = '' ;* Inward Reference
        MSG.DETAILS<2> = 'SETR016' ;* MessageType
        MSG.DETAILS<3> = 'INWARD' ;*MessageInOut
        MSG.DETAILS<4> = MSG.FUNC ;* MessageFunction
        MSG.DETAILS<8> = tmp.R.KEY ;* DeliveryReference
* Call this routine to update the message details to the log.
        SC.SctOrderCapture.ScOrdLogFileUpd(ID.SEC.OPEN.ORDER, '',  MSG.DETAILS, ERR.MSG, R.SC.ORD.INSTR.LOG,'','','','','')
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CANCEL.REQ>
*** <desc> </desc>
CHECK.CANCEL.REQ:
;* Gosub to Check whether this message is received as a response for cancellation request.
;* Check SP.ORDER.DELIVERY.CONTROL for this order, if the message function sent was CANC
;* and if the OrderStatus is Cancellation Requested in SOO
;* then this message will be a response for Cancellation request.
;* We are Updating Sp.Order.Delivery.Control while sending Cancellation request to broker
    CANC.REQ = '' ;* Variable to identify Whether this message is a response of Cancellation Request
    ID.SEC.OPEN.ORDER = SOO.ID
    GOSUB READ.SOO
    DEL.CTRL.ID = SOO.ID:".":BROKER.NO
    R.DEL.CTRL = SP.Foundation.OrderDeliveryControl.Read(DEL.CTRL.ID, ERR)
    ORD.STAT = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus>
    POS.ORD.STATUS = 'Cancellation Requested':@VM:'Cancellation Received'
    IF R.DEL.CTRL<SP.Foundation.OrderDeliveryControl.OdcMessageFunction> EQ 'CANC' AND (ORD.STAT MATCHES POS.ORD.STATUS) THEN
        CANC.REQ = '1'
    END
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.OFS.RECORD>
BUILD.OFS.RECORD:
*** <desc> </desc>
    APP.NAME = "SEC.OPEN.ORDER"
    OFS.FUNCT = "I"
    PROCESS = "PROCESS"
    OFS.VERSION = SOO.VERSION
    GTS.MODE = '1'
    NO.OF.AUTH = '0'
    TRANSACTION.ID = SOO.ID
    OFS.IN.RECORD = IN.RECORD
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord(APP.NAME, OFS.FUNCT, PROCESS, OFS.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, OFS.IN.RECORD, OFS.RECORD)
    GOSUB UPDATE.LOG
    IF OFS.RECORD THEN ;*Trigger BulkManager when there are requests to process.
        RESPONSE = ''
        REQCOMMITTED = ''
        EB.Interface.OfsBulkManager(OFS.RECORD, RESPONSE, REQCOMMITTED)
        SUCCESS = FIELD(RESPONSE,'/',3)
        IF SUCCESS EQ '-1' THEN
            NARRATIVE = 'Error While Commiting SOO'
            GOSUB UPDATE.LOG
        END
    END
    DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef,ORDER.REF)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.STP.ACTIVITY>
UPDATE.STP.ACTIVITY:
*** <desc> </desc>
    GOSUB READ.SP.ORDER.STP.ACTIVITY    ;*Read the SP.ORDER.STP.ACTIVITY
    LOCATE BROKER.NO IN R.SP.ORDER.ACTIVITY <SP.Foundation.OrderStpActivity.OrdActBrokerNo,1> SETTING ORD.ACT.POS THEN
*Find the broker position to update status accordingly.
        R.SP.ORDER.ACTIVITY<SP.Foundation.OrderStpActivity.OrdActBrMsgStatus,ORD.ACT.POS> = STP.STATUS
        GOSUB WRITE.SP.ORDER.STP.ACTIVITY  ;*Update the SP.ORDER.ACTIVITY with LIVE in ACT.BR.MSG.STATUS
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.SOO>
READ.SOO:
*** <desc> </desc>
    R.SEC.OPEN.ORDER = ''
    E.SEC.OPEN.ORDER = ''
    R.SEC.OPEN.ORDER = SC.SctOrderCapture.SecOpenOrder.Read(ID.SEC.OPEN.ORDER, E.SEC.OPEN.ORDER)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.LOG>
UPDATE.LOG:
*** <desc> </desc>
    ID.SEC.OPEN.ORDER = SOO.ID
    GOSUB READ.ORD.INSTR.LOG ; *Reading SC.ORD.INSTR.LOG ID
    
    IF R.SC.ORD.INSTR.LOG THEN
        MSG.DETAILS = '' ; ERR.MSG = ''
        REAS.CNT = DCOUNT(SETT.NARRATIVE,@VM)
        FOR REAS = 1 TO REAS.CNT
            ERR.MSG<1,1,-1> =  SETT.NARRATIVE<1,REAS>
        NEXT REAS
        GOSUB UPD.SC.ORD.INSTR.LOG ; *Update the SC.ORD.INSTR.LOG
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
