* @ValidationCode : MjoxNTUyODE3MjY4OkNwMTI1MjoxNjAzMTcwODk4NDM0OmdyYWplc3dhcmk6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3OjIyMDoyMTU=
* @ValidationInfo : Timestamp         : 20 Oct 2020 10:44:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : grajeswari
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 215/220 (97.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctOrderCapture
SUBROUTINE SC.OFS.SETR.010.MAPPING
*-----------------------------------------------------------------------------
* This routine performs mapping of SETR.010 Inward message.
*-----------------------------------------------------------------------------
* Modification History :
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
*              Order Flow - Outward MX Processing - Review Rework
*
* 30/06/20   - Task 3830171
*              Checking for History and INAU records inorder to avoid order creation with duplicate ID.
*
* 10/07/2020 - SI 2867405/ENH 3830353/TASK 3830356
*              Client BIL -Subscription Order Confirmation Cancellation Instruction-Incoming & Outgoing
*
* 21/07/2020 - 3806599
*              Cancellation Status Report-Cancellation - Inward MX Processing
*
* 28/07/2020 - Task 3881421
*              For Order cancellation-Unable to amend Sec.Trade from the Enquiry as SOO goes to history.
*
* 16/10/2020 - Task-4033695
*              For a  Subscription Order, Sending Outward 016 for IneligibleCustomer scenario 
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING DE.Inward
    $USING ST.CompanyCreation
    $USING DE.Config
    $USING DE.ModelBank
    $USING SC.SctOrderCapture
    $USING EB.Interface
    $USING EB.Browser
    $USING EB.API
    $USING SC.Config
    $USING SC.ScoPortfolioMaintenance
    $USING EB.Foundation
    $USING DE.Outward
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING EB.TransactionControl
    $USING EB.Utility
*-----------------------------------------------------------------------------
    GOSUB INITIALISATION
    GOSUB MAIN.PROCESSING
    GOSUB GENERATE.OFS
    GOSUB UPD.SC.ORD.INSTR.LOG ; *Update the SC.ORD.INSTR.LOG file with the incoming message details.

RETURN
*-----------------------------------------------------------------------------
*** <region name = initialisation>
INITIALISATION:

    R.SC.PRE.DIARY = ''
    EB.SystemTables.setEtext("")
    ID.INWARD = DE.Inward.getRKey() ;*Inward Delivery ID
    R.INWARD = ''
    R.SWIFT = '' ;*Not used
    MESSAGE.TYPE = 'SETR010' ;*MESSAGE.TYPE
    R.DE.MESSAGE = ''
    OFS.MESSAGE = ''
    OFS.KEY = ''
    YERR=''

    GOSUB MX.PROCESS          ;*Convert the SETR010 MX message to map to SOO
    
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
    SWIFT.SRC.VER = STD.OFS.SOURCE AND STD.OFS.VERSION
    INELIG.CUS = ''
    IF NOT(SWIFT.SRC.VER) THEN
        GOSUB INELIG.CUS ; *Raise this error in case of ineligible customer
    END
    
RETURN
*** </region>
*------------------------------------------------------------------------
*** <region name = MainProcessing>
MAIN.PROCESSING:
    

    GOSUB CREATE.ORDER.ID ; *Creating Order Id for the inward message.
    
    SOO.ERR = '' ; RETRY = ''
    R.SEC.OPEN.ORDER = SC.SctOrderCapture.SecOpenOrder.ReadU(ORDER.ID, SOO.ERR, RETRY)
    IF NOT(R.SEC.OPEN.ORDER) THEN
        
        ORD.DET<1> = 'BUY'      ;* TransactionCode
        ORD.DET<2> = RECORD<2>  ;* Order DateTime
        ORD.DET<3> = RECORD<6>  ;* ISIN
        ORD.DET<4> = RECORD<3>  ;* Portfolio/CustodyPort
        ORD.DET<5> = RECORD<4>  ;* BIC
        ORD.DET<6> = RECORD<7>  ;* Nominals
        ORD.DET<7> = RECORD<12> ;* SettlementCcy
        ORD.DET<8> = RECORD<10> ;* CuDepository
        ORD.DET<9> = RECORD<8>  ;* BrokDelivInstr
        ORD.DET<10> = RECORD<14> ;* Mapping ExpiryDate from Message
        
        SC.SctOrderCapture.ScMapSooFields(ORD.DET,R.SEC.OPEN.ORDER,INELIG.CUS,ERR.MSG) ;* Mapping the Message details to SEC.OPEN.ORDER.
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = GENERATE.OFS>
GENERATE.OFS:

    DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, EB.SystemTables.getIdCompany())
 
* Donot generate SEC.OPEN.ORDER incase of Ineligible customer
    IF INELIG.CUS THEN
        RETURN
    END

* Generating SEC.OPEN.ORDER
    IF SWIFT.SRC.VER THEN
        IF ERR.MSG NE '' THEN
            GTS.MODE = '4' ;* Generating SOO in IHLD incase of missing details.
            NO.OF.AUTH = '1'
        END ELSE
            GTS.MODE = '3' ;* Generating SOO in LIVE incase of correct details and generating in IHLD in case of Errors or Overrides.
            NO.OF.AUTH = '0'
        END
* Calling OFS.BUILD.RECORD to form the SEC.OPEN.ORDER ofs message.
        EB.Foundation.OfsBuildRecord('SEC.OPEN.ORDER', 'I', 'PROCESS', STD.OFS.VERSION, GTS.MODE, NO.OF.AUTH, ORDER.ID, R.SEC.OPEN.ORDER,OFS.RECORD)
        OPTIONS = STD.OFS.SOURCE
        THE.REQUEST = OFS.RECORD
        THE.RESPONSE = ''
*  Calling OBM to generate SEC.OPEN.ORDER
        EB.Interface.OfsCallBulkManager(OPTIONS, THE.REQUEST, THE.RESPONSE,'')
        DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef,ORDER.ID)
    END
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MX.PROCESS>
MX.PROCESS:
*** <desc>Convert the SETR010 message to map to SOO </desc>
    
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

    EB.TRANSFORM.ID = 'SC-SETR010'

    IF NOT(EB.SystemTables.getE()) THEN
        GOSUB PROCESS.MESSAGE       ;*Process the xml message to convert it into ofsml
    END
    
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
        EB.ErrorProcessing.ExceptionLog("S","SEC.OPEN.ORDER","SC.OFS.SETR.010.MAPPING","SECURITIES",'',RESULT.XML,'SEC.OPEN.ORDER',tmp.R.KEY,'1',RESULT.XML,'')
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
*** <region name= UPD.SC.ORD.INSTR.LOG>
UPD.SC.ORD.INSTR.LOG:
*** <desc>Update the SC.ORD.INSTR.LOG file with the incoming message details. </desc>
    
    ORD.CREATED.SUCCESS = ''
    
    IF INELIG.CUS THEN
        INSTR.ID = RECORD<1>
    END ELSE
        INSTR.ID = ORDER.ID
        R.SOO.REC = '' ; SOO.ERR = ''
        R.SOO.REC = SC.SctOrderCapture.SecOpenOrder.ReadNau(INSTR.ID, SOO.ERR) ;* Check if the record is in HLD
        IF SOO.ERR THEN
            R.SOO.REC = SC.SctOrderCapture.SecOpenOrder.Read(INSTR.ID, SOO.ERR) ;*Else check in LIVE
            ORD.CREATED.SUCCESS = '1'
        END
        OVERR.CNT = DCOUNT(R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooOverride>,@VM)
        FOR OVERR.POS = 1 TO OVERR.CNT
            ERR.MSG<1,1,-1> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooOverride,OVERR.POS> ;* Mapping Override to the Log
        NEXT OVERR.POS
;* Write the SOO ID to SC.ORD.CUST.REF.WRK file with ID as ORDER.REF. Which will be used to find the SOO id when the customer sends further messages with ORDER.REF
        SC.SctOrderCapture.OrdCustRefWrK.Write(RECORD<5>, INSTR.ID)
        
    END

* Reading the SC.ORD.INSTR.LOG file.
    R.SC.ORD.INSTR.LOG = '' ; INSTR.ERR = '' ; INSTR.RETRY = ''
    R.SC.ORD.INSTR.LOG = SC.SctOrderCapture.OrdInstrLog.ReadU(INSTR.ID,INSTR.ERR,INSTR.RETRY)
    IF INSTR.ERR THEN
        READ.ERR = 1
    END
    
* Updating the Message details to the log file.
    MSG.DET = '' 
    MSG.DET<1> = RECORD<5> ;* Inward Reference
    MSG.DET<2> = 'SETR010' ;* MessageType
    MSG.DET<3> = 'INWARD' ;*MessageInOut
    MSG.DET<4> = 'NEWM' ;* MessageFunction
    MSG.DET<5> = RECORD<3>      ;* CustodyPort/SAM
    MSG.DET<6> = RECORD<4>      ;* BIC
    MSG.DET<7> = RECORD<13>     ;* IBAN
    MSG.DET<8> = ID.INWARD      ;* DeliveryReference

    SC.SctOrderCapture.ScOrdLogFileUpd(INSTR.ID, R.SOO.REC, MSG.DET, ERR.MSG, R.SC.ORD.INSTR.LOG,'','','','','')
    
    GOSUB PROCESS.OUTWARD ; *To process outward message
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CREATE.ORDER.ID>
CREATE.ORDER.ID:
*** <desc>Creating Order Id for the inward message. </desc>
    FN.SEC.OPEN.ORDER = 'F.SEC.OPEN.ORDER'
    F.SEC.OPEN.ORDER = ''
    EB.DataAccess.Opf(FN.SEC.OPEN.ORDER,F.SEC.OPEN.ORDER)
* Save Application details
    SAVE.APP = EB.SystemTables.getApplication()
    SAVE.FULL.FNAME = EB.SystemTables.getFullFname()
    SAVE.FUNC = EB.SystemTables.getVFunction()
    SAVE.PGM = EB.SystemTables.getPgmType()
    SAVE.ID.T = EB.SystemTables.getIdT()
    SAVE.ID.N = EB.SystemTables.getIdN()
    EB.SystemTables.setFullFname(FN.SEC.OPEN.ORDER)
    EB.SystemTables.setApplication('SEC.OPEN.ORDER')
    EB.SystemTables.setVFunction('I')
    EB.SystemTables.setPgmType('H.IDA')  ;* H checks whether the record with same id exist in unauth / history file
    EB.SystemTables.setIdT('S')
    EB.SystemTables.setIdN('16')
    Y.ID = ''
    SAVE.COMI = EB.SystemTables.getComi()
    JUL.PROCESSDATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatJulianDate)[3,5]
    EB.TransactionControl.GetNextId(Y.ID,'F')
    tmp.COMI = EB.SystemTables.getComi()
    IF LEN(tmp.COMI) <= 5 THEN
        tmp.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi("OPODSC":JUL.PROCESSDATE:FMT(tmp.COMI,"5'0'R"))
    END ELSE
        tmp.COMI = EB.SystemTables.getComi()
        IF LEN(tmp.COMI) = 10 THEN
            EB.SystemTables.setComi("OPODSC":EB.SystemTables.getComi())
        END
        IF EB.SystemTables.getComi()[1,2] = "SC" THEN
            EB.SystemTables.setComi("OPOD":EB.SystemTables.getComi())
        END
    END
    ORDER.ID = EB.SystemTables.getComi()
    EB.SystemTables.setApplication(SAVE.APP)
    EB.SystemTables.setVFunction(SAVE.FUNC)
    EB.SystemTables.setPgmType(SAVE.PGM)
    EB.SystemTables.setIdT(SAVE.ID.T)
    EB.SystemTables.setIdN(SAVE.ID.N)
    EB.SystemTables.setComi(SAVE.COMI)
    
RETURN
*** </region>
*----------------------------------------------------------------------------
*** <region name= INELIG.CUS>
INELIG.CUS:
*** <desc>Raise this error in case of ineligible customer </desc>
    IF NOT(INELIG.CUS) THEN
        ERR.MSG<1,1,-1> = 'INELIGIBLE CUSTOMER'
        INELIG.CUS = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= PROCESS.OUTWARD>
PROCESS.OUTWARD:
*** <desc>To process outward message </desc>
    
    OUT.DETS = ''
    IF INELIG.CUS THEN
*For Ineligible customer SETR016 will be sent out with Error reason
        OUT.DETS = ''
        OUT.DETS<1,1> = INSTR.ID ;*log id
        OUT.DETS<1,2> = 'REJECTION'
        OUT.DETS<11> = 'B-':ORD.DET<5> ;*customer's BIC
        OUT.DETS<12> = 'INELIGIBLE CUSTOMER' ;*reason
        SC.SctOrderCapture.OrdStatusMxDelivery(OUT.DETS) ;*outward delivery
    END ELSE
        IF ORD.CREATED.SUCCESS AND NOT(ERR.MSG) THEN
*when the order is created without any err, outward will be generated with the order status
            OUT.DETS = ''
            OUT.DETS<1> = INSTR.ID ;*log id
            OUT.DETS<2> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooOrderStatus> ;*order status
            OUT.DETS<3> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityAccnt> ;*SAM
            OUT.DETS<4> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo> ;*SM
            OUT.DETS<5> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooStockExchange> ;*Stock Exchange
            OUT.DETS<6> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooOrderType> ;*OrderType
            OUT.DETS<7> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooOrderNominal> ;*No.Nominal
            OUT.DETS<8> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooCurrPrice> ;*price
            OUT.DETS<9> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo> ;*SM
            OUT.DETS<10> = R.SOO.REC<SC.SctOrderCapture.SecOpenOrder.ScSooTradeCcy> ;*TradeCcy
            SC.SctOrderCapture.OrdStatusMxDelivery(OUT.DETS) ;*outward delivery
        END
    END
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
