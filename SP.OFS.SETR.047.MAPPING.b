* @ValidationCode : Mjo1Nzk2NDU4Mzc6Q3AxMjUyOjE1OTYwOTAzNjA5MTk6cmV2YXRoeXJhbWVzaDo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6ODQ6ODM=
* @ValidationInfo : Timestamp         : 30 Jul 2020 11:56:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : revathyramesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 83/84 (98.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SP.Foundation
SUBROUTINE SP.OFS.SETR.047.MAPPING
*-----------------------------------------------------------------------------
* This routine performs the mapping of incoming SETR047 and updates it to the SC.ORD.INSTR.LOG
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/07/2020 - SI 2867405/ENH 3830353/TASK 3830356
*              Client BIL -Subscription Order Confirmation Cancellation Instruction-Incoming & Outgoing
*
* 21/07/2020  - Task 3830360
*               Subscription Order Confirmation Cancellation - SecTrade ID changes.
*
* 27/07/2020 - SI 2867416/ENH 3855485/TASK 3855488
*              Client BIL Redemption Order Confirmation-Incoming & Outgoing
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING DE.Inward
    $USING SC.SctOrderCapture
    $USING SC.SctOrderExecution
    $USING SC.SctTrading
    $USING DE.Config
    $USING DE.ModelBank
    $USING EB.Browser
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    GOSUB INITIALISATION
    GOSUB MAIN.PROCESSING
    GOSUB UPD.SC.ORD.INSTR.LOG ; *Update the SC.ORD.INSTR.LOG file with the incoming message details.
    
RETURN
*-----------------------------------------------------------------------------
*** <region name = initialisation>
INITIALISATION:

    EB.SystemTables.setEtext("")
    ID.INWARD = DE.Inward.getRKey() ;*Inward Delivery ID
    R.INWARD = ''
    MESSAGE.TYPE = 'SETR047' ;*MESSAGE.TYPE field
    R.DE.MESSAGE = ''
    OFS.MESSAGE = ''
    OFS.KEY = ''
    YERR=''

    GOSUB MX.PROCESS          ;*Convert the SETR047 MX message
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = MainProcessing>
MAIN.PROCESSING:
    
    ORDER.ID = RECORD<6> ;* Mapping OrderID from the Message.
    R.SC.EXE.SEC.ORDERS = ''
    SP.Foundation.SpDetermineTradeStatus(ORDER.ID, R.SC.EXE.SEC.ORDERS, ORDER.STAGE, '', '', '')
    IF NOT(R.SC.EXE.SEC.ORDERS) THEN
        ORDER.ID = RECORD<9> ;* To update SC.ORD.INSTR.LOG with ORD.REF tag as ID if Order is not found
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MX.PROCESS>
MX.PROCESS:
*** <desc>Convert the SETR004 MX message </desc>
    
    VAR1 = ''
    DEFFUN CHARX(VAR1) ;*Defining Function
    
    R.XML.IN = ''
    tmp.E = EB.SystemTables.getE()
    tmp.F.DE.I.MSG = DE.Inward.getFDeIMsg()
    tmp.R.KEY = DE.Inward.getRKey()
    R.XML.IN = DE.ModelBank.IMsg.Read(tmp.R.KEY, tmp.E)
    EB.SystemTables.setE(tmp.E)

    R.DE.MESSAGE = ''
    tmp.E = EB.SystemTables.getE()
    R.DE.MESSAGE = DE.Config.Message.Read(DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType), tmp.E)
    EB.SystemTables.setE(tmp.E)

    EQU CR TO CHARX(013)  ;* carriage return
    EQU LF TO CHARX(010)  ;* line feed
    CRLF = CR:LF

    CONVERT @FM TO '' IN R.XML.IN   ;*convert the FM to null
    CONVERT CRLF TO '' IN R.XML.IN  ;*convert the CRLF to null
    CONVERT LF TO '' IN R.XML.IN    ;*convert the LF to null

    EB.TRANSFORM.ID = 'SC-SETR047'

    IF NOT(EB.SystemTables.getE()) THEN
        GOSUB PROCESS.MESSAGE       ;*Process the xml message to convert it into ofsml
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPD.SC.ORD.INSTR.LOG>
UPD.SC.ORD.INSTR.LOG:
*** <desc>Update the SC.ORD.INSTR.LOG file with the incoming message details. </desc>
    R.SC.ORD.INSTR.LOG = '' ; READ.ERR = '' ; READ.RETRY = ''
    SC.SctOrderCapture.OrdInstrLogLock(ORDER.ID, R.SC.ORD.INSTR.LOG, READ.ERR, READ.RETRY,'')

* Mapping Amendment Indicator from Message
    IF RECORD<8> EQ 'true' THEN
        AMEND.IND = 'TRUE'
    END ELSE
        AMEND.IND = 'FALSE'
    END
    
* Updating the Message details to the log file.
    CONF.DET = ''
    CONF.DET<1> = 'SETR047' ;* Confirmation Cancellation message
    CONF.DET<2> = 'INWARD'  ;* Inward/Outward
    CONF.DET<3> = RECORD<3> ;* SETR.012 Reference
    CONF.DET<4> = AMEND.IND ;* Amendment Indicator
    CONF.DET<5> = ORDER.STAGE ; * Order Stage
    CONF.DET<6> = 'NEW' ;* Message Status
    CONF.DET<7> = tmp.R.KEY ;* Delivery Reference
    CONF.DET<8> = RECORD<7> ;* Broker
    SC.SctOrderCapture.ScOrdLogFileUpd(ORDER.ID, '','', '', R.SC.ORD.INSTR.LOG,'',CONF.DET,'','','')
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc>Process the xml message to convert it into ofsml</desc>

    GOSUB PRE.PROCESS.XSLT          ;*Pre process for XSLT. convert the required tag before XSLT conversion
    RESULT.XML = ''
    GOSUB READ.EB.TRANSFORM         ;*Read the EB.TRANSFORM record
    EB.Browser.CleanXmlText(R.XML.IN,"REPLACE.CODES","")          ;* convert into chars
* transform the xml message to form R.INWARD array
    MAPPING.XSL = R.EB.TRANSFORM<EB.SystemTables.Transform.XmlTransMappingXsl>
    CONVERT @VM TO '' IN MAPPING.XSL
    EB.API.TransformXml(R.XML.IN,'',MAPPING.XSL,RESULT.XML)

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
* if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.ORD.INSTR.LOG","SC.OFS.SETR.047.MAPPING","SECURITIES",'',RESULT.XML,'SC.ORD.INSTR.LOG',tmp.R.KEY,'1',RESULT.XML,'')
    END ELSE
        R.XML.IN = CHANGE(R.XML.IN,'@FM',@FM)
        RECORD = R.XML.IN
    END

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

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= READ.EB.TRANSFORM>
READ.EB.TRANSFORM:
*** <desc>Read the EB.TRANSFORM record </desc>

    R.EB.TRANSFORM = ''
    YERR = ''
    R.EB.TRANSFORM = EB.SystemTables.Transform.Read(EB.TRANSFORM.ID, YERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

