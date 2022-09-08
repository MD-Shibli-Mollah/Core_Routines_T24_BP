* @ValidationCode : Mjo3Mjg3MDEyNzc6Q3AxMjUyOjE1MjY2NjM4MjAwNzk6cG11bmVlc3dhcmk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwMy4yMDE4MDIyMC0wMTUxOi0xOi0x
* @ValidationInfo : Timestamp         : 18 May 2018 22:47:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmuneeswari
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.20180220-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SccEventNotification
SUBROUTINE SC.OFS.SEEV039.MAPPING
*-----------------------------------------------------------------------------
*
* This routine is defined in DE.MESSAGE for message type SEEV039 as
* the default routine to cancel an existing event.
* This routine will update record in SC.CA.ERROR.LOG with CANC status.
* Record ID in SC.CA.ERROR.LOG is decided based on the below hierarchy
* 1. DIARY id
* 2. SC.PRE.DIARY id
* 3. Depository-LinkReference-LoanIndicator-SecurityNo
*
*-----------------------------------------------------------------------------
* Modification History :
*
*  15/12/16 - Enhancement-1545934/Task-1957541
*             ISO20022 MX - Event Inward Messages(MT564,MT566 and MT568)[Post Process XML]
*
* 15/05/2018 - Task - 2589571
*             changes related to SC.CA.ERROR.LOG id based on field CA.LOG.ID of SC.CA.PARAMETER - DIARY
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Browser
    $USING EB.Interface
    $USING EB.Security
    $USING EB.ErrorProcessing
    $USING DE.Inward
    $USING DE.ModelBank
    $USING DE.Outward
    $USING DE.Config
    $USING ST.CompanyCreation
    $USING SC.Config
    $USING SC.SccConfig
    $USING SC.SccEventNotification
*-----------------------------------------------------------------------------
    VAR1 = ''
    DEFFUN CHARX(VAR1) ;*Defining Function

    GOSUB INITIALISATION
    GOSUB MAIN.PROCESSING
    DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef,SC.PRE.KEY<1>) ;*For now update first transaction
    DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, EB.SystemTables.getIdCompany())

RETURN
*-----------------------------------------------------------------------------
*** <region name = initialisation>
INITIALISATION:

    R.SC.PRE.DIARY = ''
    EB.SystemTables.setEtext("")
    ID.INWARD = DE.Inward.getRKey() ;*Inward Delivery ID

    R.SWIFT = '' ;*Not used
    MESSAGE.TYPE = 'SEEV039' ;*Randomly assigned , MESSAGE.TYPE field in SC.PRE.DIARY accepts 4 numeric chars
    R.DE.MESSAGE = ''
    OFS.MESSAGE = ''
    OFS.KEY = ''
    YERR=''

    GOSUB MX.PROCESS          ;*Convert the SEEV039 MX message to MT 564 message

    R.CA.PARAMETER = ''
    R.CA.PARAMETER = SC.SccConfig.CaParameter.CacheRead('DIARY', '')

* Read SC.STD.CLEARING and determine depository pertaining to the safe account otherwise, fetch depo in message
    R.STD.CLEARING = ''
    ST.CompanyCreation.EbReadParameter('F.SC.STD.CLEARING','N','',R.STD.CLEARING,'','',ER)
            
* Initialise necessary variables here related to changes in SC.CA.ERROR.LOG id.
    CA.LOG.ID = ''
    TXN.ID = ''
    CORPREF = ''
    DEPO.ID = ''
    SM.ID = ''
    SUB.ACCOUNT = ''
    LOG.ID.FORMAT = ''
    CALOG.WITH.SUBACC = ''
    CALOG.WITHOUT.SUBACC = ''
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MX.PROCESS>
MX.PROCESS:
*** <desc>Convert the SEEV039 MX message to MT 564 message </desc>

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

    R.OFS.SOURCE = ''
    tmp.E = EB.SystemTables.getE()
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>, tmp.E)
    EB.SystemTables.setE(tmp.E)

    EB.Interface.setOfsSourceId(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>)
    EB.Interface.setOfsSourceRec(R.OFS.SOURCE)

    EQU CR TO CHARX(013)  ;* carriage return
    EQU LF TO CHARX(010)  ;* line feed
    CRLF = CR:LF

    CONVERT @FM TO '' IN R.XML.IN   ;*convert the FM to null
    CONVERT CRLF TO '' IN R.XML.IN  ;*convert the CRLF to null
    CONVERT LF TO '' IN R.XML.IN    ;*convert the LF to null

    EB.TRANSFORM.ID = 'SC-SEEV039'

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
* transform the xml message to form R.XML.IN array
    EB.API.TransformXml(R.XML.IN,'',R.EB.TRANSFORM<EB.SystemTables.Transform.XmlTransMappingXsl>,RESULT.XML)

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
* if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.MT564.QUEUE","SC.OFS.SEEV039.MAPPING","SECURITIES",'',RESULT.XML,'SC.MT564.QUEUE','','1',RESULT.XML,'')
    END ELSE
        R.XML.IN = CHANGE(R.XML.IN,'@FM',@FM)
        R.XML.IN = CHANGE(R.XML.IN,'@VM',@VM)
        R.XML.IN = CHANGE(R.XML.IN,'@SM',@SM)
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
*** <region name = MAIN.PROCESSING>
MAIN.PROCESSING:
*** <desc>Extract SC.CA.ERROR.LOG id to update status </desc>
*R.XML.IN has three values.
*1 - SAFEKEEP Account
*2 - CORP.REF
*3 - SEME.REF
*
    GOSUB FORM.CONC.ID.LIST ;*CONC.ID.LIST will store all depositories for the message
    
    FOR CTR = 1 TO DEPO.COUNT ;*Depo count will have count from CONC.ID.LIST
        CONCAT.ID = CONC.ID.LIST<1,CTR>:'-':R.XML.IN<2>
        R.CONCAT.REC = SC.SccEventNotification.MtFivSixFouReference.Read(CONCAT.ID, YERR3)
        SC.PRE.KEY<-1> = R.CONCAT.REC ;*References from each concat record will be copied to SC.PRE.KEY delmited by Field Marker
    NEXT CTR
        
    NO.OF.REC = DCOUNT(SC.PRE.KEY,@FM)
    SC.PRE.KEY<-1> = R.CONCAT.REC
    FOR CTR = 1 TO NO.OF.REC ;*For all the references, update cancellation status
        PRE.DIARY.ID = SC.PRE.KEY<CTR>
        GOSUB GET.CA.LOG.ID ;*Extract SC.CA.ERROR.LOG id to update cancelled status
        IF R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaStp> THEN
            GOSUB UPDATE.CA.LOG
        END
    NEXT CTR

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FORM.CONC.ID.LIST>
FORM.CONC.ID.LIST:
*** <desc>CONC.ID.LIST will store all depositories for the message </desc>
    NO.OF.SFKP.ACCTS = DCOUNT(R.XML.IN<1>,@VM)
    FOR CTR = 1 TO NO.OF.SFKP.ACCTS
        CONC.ID = R.XML.IN<1,CTR>
        GOSUB GET.DEPO.ID.FROM.SC.STD.CLEARING
    NEXT CTR

    DEPO.COUNT = DCOUNT(CONC.ID.LIST<1>,@VM)
    IF DEPO.COUNT = 0 THEN
        R.DE.I.HEADER = DE.Config.IHeader.Read(ID.INWARD,'')
        CONC.ID = R.DE.I.HEADER<DE.Config.IHeader.HdrCustomerNo>  ;* fetch the depository from customer number
        DEPO.COUNT = 1
        CONC.ID.LIST = CONC.ID
        IF NOT(NUM(CONC.ID)) THEN ;*Just copying from SC.OFS.564.MAPPING
            CONC.ID.LIST = 'ALL'
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.DEPO.ID.FROM.SC.STD.CLEARING>
GET.DEPO.ID.FROM.SC.STD.CLEARING:
*** <desc>Get equivalent Depository IDs from SC.STD.CLEARING</desc>

    LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,1> SETTING CONC.POS THEN         ;* Locate for safekeep account
        CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>         ;* Fetch Depo
        CONC.POS += 1
        LOOP
        WHILE CONC.POS    ;* Check whether same safekeep is linked to many depositories and get the list of depos
            LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,CONC.POS> SETTING CONC.POS THEN
                CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>
                CONC.POS += 1
            END ELSE
                CONC.POS = ''
            END
        REPEAT
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CA.LOG.ID>
GET.CA.LOG.ID:
*** <desc>Extract SC.CA.ERROR.LOG id to update status </desc>
*Determine LIVE/NAU availability
    
    R.LIVE.PRE.DIARY = '' ;R.SC.PRE.DIARY = ''
    NAU.ERR = ''
    R.SC.PRE.DIARY = SC.SccEventNotification.PreDiary.ReadNau(PRE.DIARY.ID, NAU.ERR)
    IF NAU.ERR THEN
        LIV.ERR = ''
        R.SC.PRE.DIARY = SC.SccEventNotification.PreDiary.Read(PRE.DIARY.ID, LIV.ERR)
        R.LIVE.PRE.DIARY = R.SC.PRE.DIARY
    END

* For initial input of Pre diary, Log Id will be combination of Corp ref, depository and Loan
    CA.LOG.ID = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDepository>:'-':R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef>
    IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLoan> THEN
        CA.LOG.ID := '-LOAN'
    END
    CA.LOG.ID := '-':R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo> ;*Do we have to get from message ?? - Check Point!

    IF PRE.DIARY.ID THEN      ;*If Pre diary ID exists, Log id will be pre diary id
        CA.LOG.ID = PRE.DIARY.ID
    END
    IF R.LIVE.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDiaryId> THEN     ;* if Diary id exists in Pre diary, Log id will be diary id
        CA.LOG.ID = R.LIVE.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDiaryId>
    END
    
    IF CA.LOG.ID[1,6] EQ 'SCPDIA' THEN                                           ;* if the log id formed is SC.PRE.DIARY id, form the log id.
        TXN.ID = CA.LOG.ID                                                       ;* pass SC.PRE.DIARY id to SC.GET.LOG.ID routine
        CORPREF = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef>  ;* Pass Corp Reference
        DEPO.ID = CONC.ID                                                        ;* Pass Depo id.
        SUB.ACCOUNT = ''                                                         ;* Check with SLN
        LOG.ID.FORMAT = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaCaLogId>     ;* this holds either TXN.ID or CORP.REF from SC.CA.PARMAETER record for DIARY - pass it.
        SM.ID = ''                                                               ;* Reserved.
        SC.SccConfig.ScFormCaErrorLogId(TXN.ID, CORPREF, SUB.ACCOUNT, DEPO.ID, LOG.ID.FORMAT,SM.ID,CALOG.WITH.SUBACC, CALOG.WITHOUT.SUBACC) ;* call this routine to form the SC.CA.ERROR.LOG id.
        
* Id will be returned as either <ScPreDiaryid>-<Depo>-<Sub Account> for TXN.ID or <Corp ref>-<Depo>-<Sub account> for CORP.REF in SC.CA.PARAMETER and if segregated account set up is available in SC.PARAMETER with Sub Account available.
* if the segregated account set up is not available, then id will be <sc Pre diary> OR <Diary> for TXN.ID set up and <Corp Ref>-<Depo> for CORP.REF set up

        CA.LOG.ID = CALOG.WITH.SUBACC
    END
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = UPDATE.CA.LOG>
UPDATE.CA.LOG:

    LOG.ERR = ''
    SC.SccConfig.ScCaErrorLogLock(CA.LOG.ID,R.CA.ERROR,LOG.ERR,'','')

    MV.POS = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSecurityNo>,@VM) + 1
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDelivRef,MV.POS> = ID.INWARD       ;* Inward delivery id
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerReceivingDate,MV.POS> = EB.SystemTables.getToday()     ;* Message receiving date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerMessageType,MV.POS> = MESSAGE.TYPE       ;* message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSemeRef,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSourceRef>    ;* Source reference
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCorpRef,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef>      ;* Corp action ref
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSecurityNo,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo>   ;* security number in message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPayDate,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>      ;* Pay date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerExDate,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate>        ;* Ex date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'CANC' ;*This message itself is for Cancellation
    
    SC.SccConfig.ScCaErrorLogWrite(CA.LOG.ID, R.CA.ERROR,'')
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
