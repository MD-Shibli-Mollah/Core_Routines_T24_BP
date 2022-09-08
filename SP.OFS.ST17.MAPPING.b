* @ValidationCode : Mjo0NDc1NzYzNDpDcDEyNTI6MTU5NTU5MTAzMzExMzphbW9oYW1tZWR3YXNpbTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA3MDEtMDY1NzotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Jul 2020 17:13:53
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

$PACKAGE SP.Foundation
SUBROUTINE SP.OFS.ST17.MAPPING
*-----------------------------------------------------------------------------
*Program Description
*====================
*This Subroutine performs the processing of incoming SETR017(OrderCancellationStatusReport) message.
*This is a service driven program and called from DE.I.PROCESS.OFS routine while invoking the service ISOMX.IN
*Attached as InwardOfsRtn in DE.MESSAGE of SETR017 record
* This routine handles the incoming SETR017 message sent by Broker/CounterParty after the
* Cancellation request by the Client.The incoming SETR017 can come with different statuses such as
* RECE, CAND, REJCT.  The 3 statuses should be handled
*-----------------------------------------------------------------------------
    $USING DE.Inward
    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING DE.Config
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.Foundation
    $USING EB.Interface
    $USING SP.Foundation
    $USING SC.SctOrderCapture
    $USING ST.CompanyCreation
    $USING SC.Config
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 13/07/2020 - Task - 3806595
*              ENC2 Client BIL -Order Cancellation Status Report-Cancellation - Inward MX Processing
*
* 15/07/2020 - SI 2867405/ENH 3830353/TASK 3830356
*              Client BIL -Subscription Order Confirmation Cancellation Instruction-Incoming & Outgoing
*-----------------------------------------------------------------------------
    GOSUB INITIALISATION ; *
    GOSUB GET.XML.RECORD ; *
    GOSUB CONVERT.MX ;* Convert the MX message from XML into Dynamic array for processing.
    GOSUB PROCESS.MESSAGE ;*
*-----------------------------------------------------------------------------
RETURN
*** <region name= INITIALISATION>
INITIALISATION:
*** <desc> </desc>
    
*Equating few constants for easy identification of the transformed Array
*These are the Fields that are expected out of transformation

    EQU MessageRef TO 1 ;* Incoming Message Reference
    EQU CreationDateTime TO 2
    EQU IndOrderDet TO 3 ;* This field Contains the OrderReference and the Status sent by the Counterparty
    
;* For easy identification of Sub Values
    EQU OrderRef TO 1
    EQU OrderStatus TO 2
    EQU RejectionRsn TO 3
    
    MSG.REF = ''
    CR.DATE.TIME = ''
    IND.ORDER.DET = ''
   
    ERR.MSG = '' ;*Variable for storing Error messages.
    VAR1 = ''
    NARRATIVE = ''
    ERR.FLAG = ''
    DEFFUN CHARX(VAR1)
    
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
        ERR.MSG<-1> = E.INWARD
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
    ID.TRANSFORM = "SC-SETR017" ;*To transform incoming message to dynamic array.
    R.XSL = ''
    EB.API.TransformXml(XML.RECORD, ID.TRANSFORM, R.XSL, E.XML)

    IF E.XML THEN
        EB.SystemTables.setE(E.XML)
        ERR.MSG<-1> = E.XML
    END ELSE
        R.XML.IN = CHANGE(XML.RECORD,'@FM',@FM)
        R.XML.IN = CHANGE(R.XML.IN,'@VM',@VM)
        R.XML.IN = CHANGE(R.XML.IN,'@SM',@SM)
    END
    
    
;* The format of messageId and OrderRef is
;*GB0010001_1910730004_54321(CompanyCode_SequenceNumberPartinSooId_BrokerNo)
    
    MSG.REF = R.XML.IN<MessageRef> ;* MessageReference
    CR.DATE.TIME = R.XML.IN<CreationDateTime> ;*Creation Date and TIme
    IND.ORDER.DET = R.XML.IN<IndOrderDet> ;* Conatins individual Order details such as OrderReference and Status of the Order.
    
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
*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc> </desc>
    IF ERR.MSG THEN
        GOSUB WRITE.REPAIR ; *
        RETURN
    END
    SAVE.ORDER.DET = IND.ORDER.DET
    ORDER.REF = ''
    ORDER.STATUS = ''
    REJT.RSN = ''
    NO.OF.ORDERS = DCOUNT(IND.ORDER.DET,@VM);* Multiple Order statuses can be sent in a single message, so process each order.
    FOR I = 1 TO NO.OF.ORDERS
        GOSUB GET.SOO.ID ;* Get SooId from OrderReference
        ORDER.STATUS = IND.ORDER.DET<1,I,OrderStatus>
        IF ORDER.STATUS EQ 'REJECTED' THEN
            REJT.RSN = IND.ORDER.DET<1,I,RejectionRsn>
        END
        GOSUB PROCESS.ORDER.STATUS ; *
    NEXT I
    
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
*** <region name= PROCESS.ORDER.STATUS>
PROCESS.ORDER.STATUS:
*** <desc> </desc>
;* The Counterparty Can send the message with status such as
;* RECE - Cancellation Received
;* CAND - Cancellation Accepted
;* REJT - Cancellation Rejected
    IN.RECORD = ''
    NARRATIVE = ''
    GOSUB READ.SOO
    BROKER.NO = R.SOO<SC.SctOrderCapture.SecOpenOrder.ScSooBroker,1>
    BEGIN CASE
        CASE ORDER.STATUS EQ 'RECE'
;*When the OrderStatus is received then Update the OrderStatus as CancellationReceived in SOO.
;* DealStatus remains as Transmitted
;* When the status received from the client is RECE, then write the SOO instead of using OFS
;* Because we can't amend the SOO record until we get confirmation from the Client
;* either Cancellation Accepted or Cancellation Rejected
;* It is tracked using SP.ORDER.STP.ACTIVITY in Check record of SOO.
            R.SOO<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Received'
            SC.SctOrderCapture.SecOpenOrderWrite(ORDER.REF, R.SOO, '')
            NARRATIVE = 'Cancellation Received'
            GOSUB UPDATE.LOG
        CASE ORDER.STATUS EQ 'CAND'
;* When the DealStatus is Cancelled, then Update the OrderStatus as Cancellation Accepted and
;* DealStatus as Cancelled
            IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Accepted'
            IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooDealStatus> = 'CANCELLED'
            STP.STATUS = 'ACCEPTED'
            GOSUB UPDATE.STP.ACTIVITY ; *
            NARRATIVE = 'Cancellation Accepted'
        CASE ORDER.STATUS EQ 'REJECTED'
;* When the DealStatus is Rejected, then Update the OrderStatus as Cancellation Rejected and
;* DealStatus remains as Transmitted
            IN.RECORD<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> = 'Cancellation Rejected'
            STP.STATUS = 'REJECTED'
            GOSUB UPDATE.STP.ACTIVITY ; *
            NARRATIVE = REJT.RSN
    END CASE
    
    IF IN.RECORD THEN
        GOSUB UPDATE.LOG
        GOSUB BUILD.OFS.RECORD ; *
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
    OFS.VERSION = STD.OFS.VERSION
    GTS.MODE = '1'
    NO.OF.AUTH = '0'
    TRANSACTION.ID = ORDER.REF
    OFS.IN.RECORD = IN.RECORD
    OFS.RECORD = ''
    EB.Foundation.OfsBuildRecord(APP.NAME, OFS.FUNCT, PROCESS, OFS.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, OFS.IN.RECORD, OFS.RECORD)
    
    IF OFS.RECORD THEN ;*Trigger BulkManager when there are requests to process.
        RESPONSE = ''
        REQCOMMITTED = ''
        EB.Interface.OfsBulkManager(OFS.RECORD, RESPONSE, REQCOMMITTED)
        SUCCESS = FIELD(RESPONSE,'/',3)
        IF SUCCESS EQ '-1' THEN
            NARRATIVE = 'Error While Commiting SOO'
            ORDER.REF = MSG.REF ;* Update log with message reference since there is error
            ERR.FLAG = '1'
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
    R.SOO = ''
    E.SOO = ''
    R.SOO = SC.SctOrderCapture.SecOpenOrder.Read(ORDER.REF, E.SOO)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.SP.ORDER.STP.ACTIVITY>
READ.SP.ORDER.STP.ACTIVITY:
*** <desc>Read the SP.ORDER.STP.ACTIVITY </desc>

    FERR = ''
    R.SP.ORDER.ACTIVITY = ''
    R.SP.ORDER.ACTIVITY = SP.Foundation.OrderStpActivity.Read(ORDER.REF, FERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= WRITE.SP.ORDER.STP.ACTIVITY>
WRITE.SP.ORDER.STP.ACTIVITY:
*** <desc>Write to SP.ORDER.STP.ACTIVITY </desc>

    SP.Foundation.OrderStpActivity.Write(ORDER.REF, R.SP.ORDER.ACTIVITY)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.LOG>
UPDATE.LOG:
*** <desc> </desc>
    LOG.ERR = ''
    R.LOG = ''
    R.LOG = SC.SctOrderCapture.OrdInstrLog.Read(ORDER.REF, LOG.ERR)
;* If the MsgRef is already present then Update the log or create a new one.
    
    ORD.DETS = ''
    ORD.DETS<4> = ID.MESSAGE
    ORD.DETS<11> = 'INWARD'
    IF ORDER.STATUS EQ 'REJECTED' THEN
        ORDER.STATUS = 'RJCTD'
    END
    ORD.DETS<10> = ORDER.STATUS
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
*** <region name= GET.SOO.ID>
GET.SOO.ID:
*** <desc> </desc>
    SEQ.NUM = ''
    ORDER.REF = IND.ORDER.DET<1,I,OrderRef>
    SEQ.NUM = FIELD((FIELD(ORDER.REF,'_',2)),'_',1) ;* Get the Sequence number
    ORDER.REF = 'OPODSC':SEQ.NUM
RETURN
*** </region>

END

