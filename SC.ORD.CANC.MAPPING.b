* @ValidationCode : MjoxMzY4ODUzMjAwOkNwMTI1MjoxNTk1NTkwODQ3MjYzOmFtb2hhbW1lZHdhc2ltOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3Oi0xOi0x
* @ValidationInfo : Timestamp         : 24 Jul 2020 17:10:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amohammedwasim
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SC.SctOrderCapture
SUBROUTINE SC.ORD.CANC.MAPPING
*Program Description
*====================
*This Subroutine performs the processing of incoming SETR005(SubscriptionOrderCancellationRequest) message and
* SETR011(RedemptionOrderCancellationRequest)
*This is a service driven program and called from DE.I.PROCESS.OFS routine while invoking the service ISOMX.IN
*Attached as InwardOfsRtn in DE.MESSAGE of SETR005 record and SETR011 record.
*This routine handles the MX cancellation request sent by the Client
*-----------------------------------------------------------------------------
    $USING DE.Inward
    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING DE.Config
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING EB.Interface
    $USING SC.Config
    $USING SC.ScoPortfolioMaintenance
    $USING PY.Config
    $USING EB.ErrorProcessing
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 21/07/2020 - 3806599
*              Cancellation Status Report-Cancellation - Inward MX Processing
*-----------------------------------------------------------------------------
    GOSUB INITIALISATION ; *
    GOSUB GET.XML.RECORD ; *
    GOSUB CONVERT.MX ;* Convert the MX message from XML into Dynamic array for processing.
    GOSUB ORDER.CANCELLATION ;*
*-----------------------------------------------------------------------------
RETURN
*** <region name= INITIALISATION>
INITIALISATION:
*** <desc> </desc>
    
*Equating few constants for easy identification of the transformed Array
*These are the Fields that are expected out of transformation

    EQU MessageRef TO 1 ;* Incoming Message Reference
    EQU CreationDateTime TO 2
    EQU OrderReference TO 3 ;* This is multiValue field since a single Cancellation request may contain MutipleOrderReferences
    
    MSG.REF = ''
    CR.DATE.TIME = ''
    ORDER.REFS = ''
    ERR.MSG = '' ;*Variable for storing Error messages.
    VAR1 = ''
    NARRATIVE = ''
    ERR.FLAG = ''
    DEFFUN CHARX(VAR1)
    
    LOCATE 'ISOMX' IN DE.Inward.getRHead(DE.Config.IHeader.HdrCarrierAddressNo) SETTING POS THEN
        FROM.ADDR = DE.Inward.getRHead(DE.Config.IHeader.HdrFromAddress)<1,POS>
    END

    ID.MESSAGE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    E.MESSAGE = ''
    R.MESSAGE = DE.Config.Message.Read(ID.MESSAGE, E.MESSAGE)
    
    ST.CompanyCreation.EbReadParameter('F.SC.STD.SEC.TRADE','N','',R.SC.STD.SEC.TRADE,'','',ER)
    STD.OFS.SOURCE = ''
    STD.OFS.VERSION = ''
    SC.STD.APPL = ''
    SC.STD.VERSION =  R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstOfsVersion>   ;*Take the versions specified in SC.STD.SEC.TRADE
    FOR VER = 1 TO DCOUNT(SC.STD.VERSION,@VM)     ;*Loop through the versions
        SC.STD.APPL<-1> = FIELD(SC.STD.VERSION<1,VER>,',',1)
    NEXT VER
    LOCATE 'SEC.OPEN.ORDER' IN SC.STD.APPL<1> SETTING STD.APPL THEN          ;*Pick the Version specified with prefix SEC.OPEN.ORDER.
        STD.OFS.SOURCE = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstOfsSource,STD.APPL>  ;*OFS.SOURCE is taken from SC.STD.SEC.TRADE
        STD.OFS.VERSION = R.SC.STD.SEC.TRADE<SC.Config.StdSecTrade.SstOfsVersion,STD.APPL>          ;*OFS.VERSION is taken from SC.STD.SEC.TRADE
    END
    
    IF R.MESSAGE<DE.Config.Message.MsgOfsSource> THEN
        STD.OFS.SOURCE = R.MESSAGE<DE.Config.Message.MsgOfsSource>
    END
    IF R.MESSAGE<DE.Config.Message.MsgInOfsVersion> THEN
        STD.OFS.VERSION = R.MESSAGE<DE.Config.Message.MsgInOfsVersion>
    END
    
    R.OFS.SOURCE = ''
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(STD.OFS.SOURCE, E.OFS.SOURCE)
;* Used in OPM
    EB.Interface.setOfsSourceId(STD.OFS.SOURCE)
    EB.Interface.setOfsSourceRec(R.OFS.SOURCE)
    DE.Inward.setRHead(DE.Config.IHeader.HdrCompanyCode, EB.SystemTables.getIdCompany())
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.XML.RECORD>
GET.XML.RECORD:
*** <desc> </desc>

    ID.INWARD = DE.Inward.getRKey()
    E.INWARD = ''
    XML.RECORD = DE.ModelBank.IMsg.Read(ID.INWARD, E.INWARD)
    IF E.INWARD THEN
        EB.SystemTables.setE(E.INWARD)
        ERR.MSG<-1> = 'DE.I.MSG record not found'
    END

*Linearize XML to avoid any Newline/Linefeed characters
    EQU LF TO CHARX(010)
    EQU CRLF TO CHARX(013):CHARX(010)

    CONVERT @FM TO '' IN XML.RECORD   ;*convert the FM to null
    CONVERT CRLF TO '' IN XML.RECORD  ;*convert the CRLF to null
    CONVERT LF TO '' IN XML.RECORD  ;*convert the LF to null
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CONVERT.MX>
CONVERT.MX:
*** <desc> </desc>
    
    
    GOSUB PRE.PROCESS.XSLT ; *           ;*Pre process for XSLT. convert the required tag before XSLT conversion
    RESULT.XML = ''

    E.XML = ''
;* Formatting based on the MessageType either 005 or 011
    IF ID.MESSAGE EQ 'SETR005' THEN
        ID.TRANSFORM = "SC-SETR005" ;*To transform incoming message to dynamic array.
    END ELSE
        ID.TRANSFORM = 'SC-SETR011'
    END
    R.XSL = ''
    EB.API.TransformXml(XML.RECORD, ID.TRANSFORM, R.XSL, E.XML)

    IF E.XML THEN
        EB.SystemTables.setE(E.XML)
        ERR.MSG<-1> = 'Error in XML Tranformation'
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, E.XML)
* if there is an error while transforming then log it in exception
        IF ID.MESSAGE EQ 'SETR005' THEN
            EB.ErrorProcessing.ExceptionLog("S","SEC.OPEN.ORDER","SC.OFS.SETR.005.MAPPING","SECURITIES",'',E.XML,'SEC.OPEN.ORDER',ID.INWARD,'1',E.XML,'')
        END ELSE
            EB.ErrorProcessing.ExceptionLog("S","SEC.OPEN.ORDER","SC.OFS.SETR.011.MAPPING","SECURITIES",'',E.XML,'SEC.OPEN.ORDER',ID.INWARD,'1',E.XML,'')
        END
    END ELSE
        R.XML.IN = CHANGE(XML.RECORD,'@FM',@FM)
        R.XML.IN = CHANGE(R.XML.IN,'@VM',@VM)
    END
    
    MSG.REF = R.XML.IN<MessageRef> ;* MessageReference
    CR.DATE.TIME = R.XML.IN<CreationDateTime> ;*Creation Date and TIme
    ORDER.REFS = R.XML.IN<OrderReference> ;* OrderReferences
    
RETURN
*** </region
*-----------------------------------------------------------------------------
*** <region name= PRE.PROCESS.XSLT>
PRE.PROCESS.XSLT:
*** <desc> </desc>
*DE.I.MSG stores the entire XML message which includes all headers following SWIFT requirements
*we can exclude the Header as the XSL is done assuming "Document" as root
*Remove header part from InXmlRecord
    XML.RECORD = FIELD(XML.RECORD,'<Document',2)
    XML.RECORD = FIELD(XML.RECORD,'</Document',1)
    XML.RECORD = '<?xml version="1.0" encoding="UTF-8"?><Document':XML.RECORD:'</Document>'

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ORDER.CANCELLATION>
ORDER.CANCELLATION:
*** <desc> </desc>
    IF ERR.MSG THEN
        GOSUB WRITE.REPAIR ; *
        RETURN
    END
    SAVE.ORDER.REF = ORDER.REFS
    ORDER.REF = ''
    INELIG.NARR = ''
    
    LOOP
        REMOVE ORDER.REF FROM ORDER.REFS SETTING POS ;* Loop for each Order reference
    WHILE ORDER.REF
        GOSUB PERFORM.CANCELLATION ; *
    REPEAT
    IF INELIG.NARR THEN
        ORDER.REF = MSG.REF
        NARRATIVE = INELIG.NARR
        ERR.FLAG = '1'
        GOSUB UPDATE.SC.ORD.INSTR.LOG ; *
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PERFORM.CANCELLATION>
PERFORM.CANCELLATION:
*** <desc> </desc>
;* Check Whether the Order is grouped One or not
;* Read SOO live file, When the deal status is GROUPED, then the order is a grouped one
;* and it can be Cancelled. If Order is not in the live file then it may be moved to $HIS while transmitting
;* or the OrderReference might be wrong.When the Order is in $HIS file then we can't cancel the order, Send back
;* the client a rejection message.

    GOSUB GET.SOO.ID ; * Get the SOO ID from the OrderReference
;*Read SOO
    R.SOO = ''
    ERR.LIVE = ''
    PORT.ID = ''
    NARRATIVE = ''
    INELIG.CUST = ''
    DEAL.STATUS = ''
    R.SOO = SC.SctOrderCapture.SecOpenOrder.Read(ORDER.REF,ERR.LIVE)
    IF R.SOO THEN
;* when the Order is in Live file
;* There will be only one Customer and Only one broker when SEND.ORD.STATUS.ADV field is set in SOO.
        PORT.ID = R.SOO<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityAccnt,1>
        GOSUB CHECK.CUSTOMER.ELIGIBILTY ;* Check Customer eligibilty for each order
        DEAL.STATUS = R.SOO<SC.SctOrderCapture.SecOpenOrder.ScSooDealStatus>
        BEGIN CASE
;*If the Customer is Ineligible to send Swift message
            CASE INELIG.CUST
                INELIG.NARR := ' Customer is InEligible to Send OrderCancellation for Order ':ORDER.REF
                
            CASE DEAL.STATUS EQ 'GROUPED' OR  DEAL.STATUS EQ ''
;* DealStatus is GROUPED and not yet transmitted, So the Order can be Cancelled
;* Change DEAL.STATUS -> CANCELLED, ORDER.STATUS -> CancellationAccepted
;* When the deal status is NULL, then this order is not yet transmitted  so
;* this order can be cancelled without intimating the Broker/CounterParty
                R.IN.OFS = ''
                R.IN.OFS<SC.SctOrderCapture.SecOpenOrder.ScSooDealStatus> = 'CANCELLED'
                R.IN.OFS<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Int Cancellation Accepted'
;* If we change the deal status as cancelled then this order will not be considered for transmitting while running the
;* service SC.GRP.ORD.SERVICE. The Id of this SOO order in SC.AUTO.GROUP.ORDERS will be deleted in the routine SC.GROUP.ORDERS
;* while running the service. whereas the Id of this SOO order in SC.GROUP.ORDERS table will be deleted in the routine
;* SC.MANUAL.GRP.ORD while running the service.
                GOSUB UPDATE.LOG ; *
                GOSUB BUILD.OFS.RECORD
 
            CASE DEAL.STATUS EQ 'TRANSMITTED'
;*When the Order is transmitted in case of Single Order we need to send the Broker/Counterparty SETR017 request
;* for cancellation confirmation.
;*============================
;* But in case of GroupedOrder - When the 'ParentChild' option is set in SC.GROUP.ORDERS or SC.AUTO.GROUP.ORDERS then the individual orders
;* will not be reversed and they will stay in the live file with order status as Transmitted. In that case the Order will have value in
;* parent reference.
;*============================
;* Incase of ParentChildOrder
;* In parent Child Orderthe Order will have value in ParentReference field
;*===========================
;* When there is value in ParentReference field we can reject the Cancellation request without asking confirmation from the Broker/counterparty.
                GROUPED = '' ;* Variable to check whether this a grouped order or not.
                GOSUB CHECK.GROUPED.ORDER ; * Check whether this order was transmitted as part of a group OR whether it is parent child Order.
                IF NOT(GROUPED) THEN
                    GOSUB CHECK.SINGLE.ORDER ; *
                END
                
        END CASE
    END ELSE
        GOSUB GET.LATEST.SOO.HIST ;*
;* when the Order in history file contains GroupOrder and the RecordStatus is reversed then the order was transmitted.
;* Here the individual orders were reversed since 'ParentChild' in SC.GROUP.ORDERS or SC.AUTO.GROUP.ORDERS is 'not' set.So there will be no
;* record in live file.
        BEGIN CASE
;*If there is no record in $HIS file then that means the OrderReference is wrong
            CASE E.SEC.OPEN.ORDER
                INELIG.NARR := 'Invalid Order Reference':ORDER.REF
;* If the Order was transmitted then reject the message,here we can't update the deal status or Order status since the order was reversed.
;* When the Group Order is tranmitted, it'll contain the GroupOrder field whereas when the single order is tranmitted then it'll contain Deal status as Transmitted
            CASE (R.SOO.HIS<SC.SctOrderCapture.SecOpenOrder.ScSooGroupOrder>) OR (R.SOO.HIS<SC.SctOrderCapture.SecOpenOrder.ScSooDealStatus> EQ 'TRANSMITTED')
;* Send the response to the Client Only when the Client is Eligible to recieve swift
                PORT.ID = R.SOO.HIS<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityAccnt,1>
                GOSUB CHECK.CUSTOMER.ELIGIBILTY ;* Check Customer eligibilty for each order
                IF INELIG.CUST THEN
                    INELIG.NARR := 'Customer is InEligible to Send OrderCancellation for Order ':ORDER.REF
                END ELSE
*to send 017 to client as request rejected since the Order is TRANSMITTED and moved to history
                    GOSUB UPDATE.LOG
                    ORDER.EXEC = '1' ;* Order is executed
                    SETR.MSG<1> = 'RJCTD' ;* RejectionMessage to client
                    SETR.MSG<2> = 'CUTO' ;* Request is received after Cut-off time.
                    SOO.ID = ORDER.REF
                    SC.SctOrderCapture.OrdCancMxDelivery(ORDER.EXEC, SETR.MSG, SOO.ID)
                END

        END CASE
    END

    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CUSTOMER.ELIGIBILTY>
CHECK.CUSTOMER.ELIGIBILTY:
*** <desc> </desc>
;* Check whether the SWIFT.ORD.INSTR field is set in CustomerSecurity then only the customer can send and receive order instructions via SWIFT
;* After that Check whether the SWIFT.ORD.SENDER field of SAM matches with the sender of the message. If these two matches the only
;* the Customer is eligible or else don't process the Cancellation of this order.

    INELIG.CUST = ''
    R.SAM = SC.ScoPortfolioMaintenance.SecAccMaster.Read(PORT.ID,SAM.ERR)
    IF NOT(SAM.ERR) THEN
        CUS.SEC.ID = FIELD(PORT.ID,'-',1)
        GOSUB READ.CUSTOMER.SECURITY ;* Reading the Customer Security record.
        IF R.CUS.SEC<SC.Config.CustomerSecurity.CscSwiftOrdInstr> EQ 'YES' THEN
            SWIFT.ORD.SENDER = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamSwiftOrdSender>
            SW.LEN = LEN(SWIFT.ORD.SENDER)
            BEGIN CASE
                CASE SWIFT.ORD.SENDER[1,2] EQ 'B-'
                    IF FROM.ADDR NE SWIFT.ORD.SENDER[3,SW.LEN-2] THEN
                        INELIG.CUST = '1'
                    END
                
                CASE NUM(SWIFT.ORD.SENDER)
                    CUS.SWIFT.ADDR = PY.Config.SwiftAddress.Read(FROM.ADDR, ERR)       ;* read the DE.SWIFT.ADDRESS for the actual bic code
                    NO.OF.ADDR = DCOUNT(CUS.SWIFT.ADDR,@FM)
                    INELIG.CUST = '1' ;* Initially set to 1. If found then make it as NULL
                    FOR I = 1 TO NO.OF.ADDR
                        ADDR = CUS.SWIFT.ADDR<I>
                        CUSTOMER.ID = FIELD(FIELD(ADDR,'.',2),'-',2)
                        IF CUSTOMER.ID EQ SWIFT.ORD.SENDER THEN
                            INELIG.CUST = ''
                            BREAK
                        END
                    NEXT I
            END CASE
        END ELSE
            INELIG.CUST = '1'
        END
    END
    

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= WRITE.REPAIR>
WRITE.REPAIR:
*** <desc> </desc>
;* DE.I.REPAIR will be updated in DE.I.FORMAT.ISOMX.MESSAGE routine
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition,'REPAIR')
    DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, ERR.MSG)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.LATEST.SOO.HIST>
GET.LATEST.SOO.HIST:
*** <desc> </desc>
;* If the Order was reversed due to Group order transmission, then reject the Cancellation
;* message and Update the log with reason - the Order was transmitted Or else update the log with reason
;* invalid order reference
    E.SEC.OPEN.ORDER = ""
    R.SOO.HIS = ""
    ORDER.REF.HIS = ORDER.REF
    FN.SEC.OPEN.ORDER = "F.SEC.OPEN.ORDER$HIS"
    F.SEC.OPEN.ORDER  = ""
    EB.DataAccess.Opf(FN.SEC.OPEN.ORDER,F.SEC.OPEN.ORDER)
    EB.DataAccess.ReadHistoryRec(F.SEC.OPEN.ORDER, ORDER.REF.HIS, R.SOO.HIS, E.SEC.OPEN.ORDER);*Get the latest SOO history record.

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.GROUPED.ORDER>
CHECK.GROUPED.ORDER:
*** <desc> </desc>
;* If the Order Contains Value in ParentReference then reject the Order Cancellation Request.
    IF R.SOO<SC.SctOrderCapture.SecOpenOrder.ScSooParentReference> THEN
        GROUPED = '1'
;*Update the SOO record in live file with OrderStatus as CancellationRejected.
        R.IN.OFS = ''
        R.IN.OFS<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Int Cancellation Rejected'
        GOSUB UPDATE.LOG ; *
        GOSUB BUILD.OFS.RECORD
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.SINGLE.ORDER>
CHECK.SINGLE.ORDER:
*** <desc> </desc>
;* Here the Order is transmitted, So when the CLient sends an Cancellation request
;* Update OrderStatus of SOO as CancellationRequested
;* Send the Client SETR017 message with Status as RECE ----------|
;*                                                               |-> These two will be done in SOO after we send OFS message with OrderStatus as CancellationRequested.
;* Send the Broker SETR005/SETR011 message-----------------------|

    R.IN.OFS = ''
    R.IN.OFS<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Requested'
    GOSUB UPDATE.LOG ; *
    GOSUB BUILD.OFS.RECORD ; *

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.OFS.RECORD>
BUILD.OFS.RECORD:
*** <desc> </desc>
    APP.NAME = "SEC.OPEN.ORDER"
    OFS.FUNCT = "I"
    PROCESS = "PROCESS"
    OFS.VERSION = STD.OFS.VERSION
    GTS.MODE = '1'
    NO.OF.AUTH = '0'
    TRANSACTION.ID = ORDER.REF
    IN.RECORD = R.IN.OFS
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord(APP.NAME, OFS.FUNCT, PROCESS, OFS.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, IN.RECORD, OFS.RECORD)
    
    IF OFS.RECORD THEN ;*Trigger BulkManager when there are requests to process.
        RESPONSE = ''
        REQCOMMITTED = ''
        EB.Interface.OfsBulkManager(OFS.RECORD, RESPONSE, REQCOMMITTED)
        SUCCESS = FIELD(RESPONSE,'/',3)
        IF SUCCESS EQ '-1' THEN
            NARRATIVE = 'Error While Commiting SOO'
            ORDER.REF = MSG.REF ;* Update log with message reference since there is error
            ERR.FLAG = '1'
            GOSUB UPDATE.SC.ORD.INSTR.LOG
        END
    END

    DE.Inward.setRHead(DE.Config.IHeader.HdrTransRef,ORDER.REF)
    
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
*** <region name= UPDATE.SC.ORD.INSTR.LOG>
UPDATE.SC.ORD.INSTR.LOG:
*** <desc> </desc>
    LOG.ERR = ''
    R.LOG = ''
    R.LOG = SC.SctOrderCapture.OrdInstrLog.Read(ORDER.REF, LOG.ERR)
;* If the MsgRef is already present then Update the log or create a new one.
    
    ORD.DETS = ''
    IF LOG.ERR THEN
;*If there is no existing fields then update necessary fields
        ORD.DETS<1> = ORDER.REF
    END
    ORD.DETS<4> = ID.MESSAGE
    ORD.DETS<11> = 'INWARD'
    ORD.DETS<10> = 'CANC'
    ORD.DETS<12> = ID.INWARD
    ORD.DETS<13> = NARRATIVE
        
;*Call this routine to update the message details to the log.
    ERR.NARR = ''
    IF ERR.FLAG THEN
        ERR.NARR = NARRATIVE
    END
    SC.SctOrderCapture.ScOrdLogFileUpd(ORDER.REF, '', '', ERR.NARR, R.LOG, ORD.DETS,'','','','')
 
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.LOG>
UPDATE.LOG:
*** <desc> </desc>
    NARRATIVE = 'Requested for Cancellation'
    GOSUB UPDATE.SC.ORD.INSTR.LOG
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SOO.ID>
GET.SOO.ID:
*** <desc> </desc>
;* Read SC.ORD.CUST.REF.WRK file to get the SOO id, which was written in SETR004/011 mapping.
    
    WRK.ERR = ''
    WRK.ID = ORDER.REF
    ORDER.REF = SC.SctOrderCapture.OrdCustRefWrK.Read(WRK.ID, WRK.ERR)

RETURN
*** </region>

END


