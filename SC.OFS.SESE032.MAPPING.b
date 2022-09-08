* @ValidationCode : MjotMTg5OTY2NDgxNDpDcDEyNTI6MTU0ODg0ODk4OTQ1MDpkcG9vcm5pbWE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjoxNDE6MTIz
* @ValidationInfo : Timestamp         : 30 Jan 2019 17:19:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dpoornima
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/141 (87.2%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-61</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.STP
    SUBROUTINE SC.OFS.SESE032.MAPPING
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
*-----------------------------------------------------------------------------
*
* 11/11/2016 - ENHANCEMENT 1913082 TASK 1913130
*             MT548 - Field Additions - Coding
*
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
    $USING DE.ModelBank
    $USING SC.STP
    $USING SC.ScoSecurityMasterMaintenance
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
    R.DE.MESSAGE = DE.Config.Message.Read(DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType), tmp.E)
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

    EB.TRANSFORM.ID = 'SC-SESE032'

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc>Process the xml message to convert it into ofsml</desc>

    GOSUB PRE.PROCESS.XSLT    ;*Pre process for XSLT. convert the required tag before XSLT conversion
    RESULT.XML = ''
    GOSUB READ.EB.TRANSFORM   ;*Read the EB.TRANSFORM record
    EB.Browser.CleanXmlText(R.XML.IN,"REPLACE.CODES","")        ;* convert into chars
* transform the xml to ofsxml message
    EB.API.TransformXml(R.XML.IN,'',R.EB.TRANSFORM<EB.SystemTables.Transform.XmlTransMappingXsl>,RESULT.XML)

* Fetching transaction id
    MT548.MATCH.ID = FIELD(FIELD(R.XML.IN,'<transactionId>',2),'</transactionId>',1)
    IF MT548.MATCH.ID NE '' THEN          ;* to avoid empty OFSML
        DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef, MT548.MATCH.ID)
        DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, FIELD(FIELD(R.XML.IN,'<companyCode>',2),'</companyCode>',1))
    END ELSE
        RESULT.XML = 'OFSML IS NOT GENERATED FOR THE REQUEST ':DE.Inward.getRKey()
    END

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
        * if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.MT548.MATCH.QUEUE","SC.OFS.SS32.MAPPING","SECURITIES",'',RESULT.XML,'SC.MT548.REPAIR.QUEUE',tmp.R.KEY,'1',RESULT.XML,'')
    END ELSE
        GOSUB POST.PROCESS.XSLT         ;*Convert the amount the fields to curreny decimal points as XSLT 1.0 converts strings to float-point precision numbers before sum
        IF MT548.MATCH.ID THEN
            GOSUB UPDATE.OFSML.IN.DIR   ;*Update the OFSML by looping according to the servicerequest tag\
        END
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

*** <region name= POST.PROCESS.XSLT>
POST.PROCESS.XSLT:
*** <desc>Convert the amount the fields to curreny decimal points as XSLT 1.0 converts strings to float-point precision numbers before sum </desc>

    MATCH.CNT = ''
    REASON.CNT = ''

    GOSUB CHECK.MATCH.QUEUE ; *Check the MATCH.QUEUE record

    FLD.POS = ''
    TEMP.R.XML.IN = CHANGE(R.XML.IN,'<messageDataApps>',@FM:'<messageDataApps>')

    FLD.CNT = ''
    NEW.R.XML.IN = TEMP.R.XML.IN
    LOOP
        REMOVE CURR.FIELD FROM TEMP.R.XML.IN SETTING FLD.POS
    WHILE CURR.FIELD:FLD.POS

        FLD.NAME = FIELD(FIELD(CURR.FIELD,'<fieldName>',2),'</fieldName>',1)
        FLD.CNT +=1
        FIELD.VAL = ''

        BEGIN CASE

            CASE FLD.NAME = 'MATCH.CODE'

                MATCH.CNT +=1
                REASON.CNT = ''
                FIELD.VAL =  FIELD(CURR.FIELD,'<value>',1):'<multiValueNumber>':MATCH.CNT:'</multiValueNumber><value>':FIELD(CURR.FIELD,'<value>',2)
                NEW.R.XML.IN<FLD.CNT> = FIELD.VAL

            CASE FLD.NAME = 'REASON.CODE'

                REASON.CNT += 1
                FIELD.VAL =  FIELD(CURR.FIELD,'<value>',1):'<multiValueNumber>':MATCH.CNT:'</multiValueNumber><subValueNumber>':REASON.CNT:'</subValueNumber><value>':FIELD(CURR.FIELD,'<value>',2)
                NEW.R.XML.IN<FLD.CNT> = FIELD.VAL

            CASE FLD.NAME = 'REASON.NARRATIVE'
                FIELD.VAL =  FIELD(CURR.FIELD,'<value>',1):'<multiValueNumber>':MATCH.CNT:'</multiValueNumber><subValueNumber>':REASON.CNT:'</subValueNumber><value>':FIELD(CURR.FIELD,'<value>',2)
                NEW.R.XML.IN<FLD.CNT> = FIELD.VAL


            CASE FLD.NAME = 'AMOUNT'

                *  check whether OFSML has the field AMOUNT
                FIELD.VAL = FIELD(FIELD(CURR.FIELD,'<value>',2),'</value>',1)       ;*remove the tag and get the value
                TRD.CCY = FIELD.VAL[1,3]    ;* In XSLT we transformed the amount as CCYAMT - USD2501.00000006
                AMOUNT = FIELD.VAL[4,LEN(FIELD.VAL)]
                EB.Foundation.ScFormatCcyAmt(TRD.CCY,AMOUNT)
                NEW.R.XML.IN = CHANGE(NEW.R.XML.IN,FIELD.VAL,AMOUNT)


            CASE FLD.NAME = 'DELIVERY.REF'
                *Update the delivery reference
                NEW.R.XML.IN<FLD.CNT> = CHANGE(CURR.FIELD,'$$DELIVERY.REF$$',tmp.R.KEY)


        END CASE
    REPEAT

* hardcoded version is changed to DE.MESSAGE defined version
    R.XML.IN = NEW.R.XML.IN
    R.XML.IN = CHANGE(R.XML.IN,'<version>$$VERSION$$</version>','<version>':FIELD(R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>,',',2):'</version>')

    MATCH.CODES = R.SC.MT548.REPAIR.QUEUE<SC.STP.MtFivFouEigRepairQueue.RqeMatchCode>
    REASON.CODES = R.SC.MT548.REPAIR.QUEUE<SC.STP.MtFivFouEigRepairQueue.RqeReasonCode>
    REASON.NARRATIVES = R.SC.MT548.REPAIR.QUEUE<SC.STP.MtFivFouEigRepairQueue.RqeReasonNarrative>
    DELIVERY.REFS = R.SC.MT548.REPAIR.QUEUE<SC.STP.MtFivFouEigRepairQueue.RqeDeliveryRef>

* existing codes need to moved to down so read and loop the existing record
    MTH.TOT.CNT = DCOUNT(MATCH.CODES,@VM)
    MATCH.CODE.XML = ''
    FOR MTH.CNT = 1 TO MTH.TOT.CNT
        MATCH.CNT+=1
        MATCH.CODE.XML := '<messageDataApps><field><fieldName>MATCH.CODE</fieldName><multiValueNumber>':MATCH.CNT:'</multiValueNumber><value>':MATCH.CODES<1,MTH.CNT>:'</value></field></messageDataApps>'
        REASON.TOT.CNT = DCOUNT(REASON.CODES<1,MTH.CNT>,@SM)
        FOR RSN.CNT = 1 TO REASON.TOT.CNT
            MATCH.CODE.XML := '<messageDataApps><field><fieldName>REASON.CODE</fieldName><multiValueNumber>':MATCH.CNT:'</multiValueNumber><subValueNumber>':RSN.CNT:'</subValueNumber><value>':REASON.CODES<1,MTH.CNT,RSN.CNT>:'</value></field></messageDataApps>'
            IF REASON.NARRATIVES<1,MTH.CNT,RSN.CNT> THEN
                MATCH.CODE.XML :='<messageDataApps><field><fieldName>REASON.NARRATIVE</fieldName><multiValueNumber>':MATCH.CNT:'</multiValueNumber><subValueNumber>':RSN.CNT:'</subValueNumber><value>':REASON.NARRATIVES<1,MTH.CNT,RSN.CNT>:'</value></field></messageDataApps>'
            END
        NEXT RSN.CNT
    NEXT MTH.CNT

* MT548.REPAIR.QUEUE needs TRANS.REF
    MATCH.CODE.XML :='<messageDataApps><field><fieldName>TRANS.REF</fieldName><value>':MT548.MATCH.ID:'</value></field></messageDataApps>'

* add the exisiting match codes to the xml
    R.XML.IN = CHANGE(R.XML.IN,'<MATCHCODE/>',MATCH.CODE.XML)


* existing DELIVERY need to moved to down so read and loop the existing record
    DEL.TOT.CNT = DCOUNT(DELIVERY.REFS,@VM)
    DEL.REF.XML = ''
    DELVERY.CNT = 1
    FOR DEL.CNT = 1 TO DEL.TOT.CNT
        DELVERY.CNT +=1
        DEL.REF.XML := '<messageDataApps><field><fieldName>DELIVERY.REF</fieldName><multiValueNumber>':DELVERY.CNT:'</multiValueNumber><value>':DELIVERY.REFS<1,DEL.CNT>:'</value></field></messageDataApps>'
    NEXT DEL.CNT
* add the exisiting DELIVERY codes to the xml
    R.XML.IN = CHANGE(R.XML.IN,'<DELREF/>',DEL.REF.XML)

    CONVERT @FM TO '' IN R.XML.IN        ;*convert the FM to null

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

*** <region name= CHECK.MATCH.QUEUE>
CHECK.MATCH.QUEUE:
*** <desc>Check the MATCH.QUEUE record </desc>

* check whether record exist in match queue

    R.SC.MT548.REPAIR.QUEUE = ''
    QUE.ERR = ''
    R.SC.MT548.REPAIR.QUEUE = SC.STP.MtFivFouEigRepairQueue.ReadNau(MT548.MATCH.ID, QUE.ERR)
    IF QUE.ERR THEN
        QUE.ERR =''
        R.SC.MT548.REPAIR.QUEUE = SC.STP.MtFivFouEigRepairQueue.Read(MT548.MATCH.ID, QUE.ERR)
    END

    RETURN
*** </region>

    END
