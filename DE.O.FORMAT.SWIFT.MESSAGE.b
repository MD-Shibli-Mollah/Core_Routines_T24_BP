* @ValidationCode : MjotMTg3MTUxNDgzOTpjcDEyNTI6MTQ5Mjc3MzkyNDU3MjpraGFyaW5pOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAzLjIwMTcwMzMxLTA4MDk6MTA4Ojc1
* @ValidationInfo : Timestamp         : 21 Apr 2017 16:55:24
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 75/108 (69.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170331-0809
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 79 27/02/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>-127</Rating>
$PACKAGE DE.Outward
SUBROUTINE DE.O.FORMAT.SWIFT.MESSAGE
*
* This program was restructured in order that the common part will be
* shared between 'PREVIEW' and 'MAIN DELIVERY' programs.
*
* 07/06/00 - GB0001408
*            Restructuring the formatting part to make the code sharable
*            both 'PREVIEW' and 'DELIVERY PHANTOM'. Therefore, all the
*            formatting part will be put in DE.FORMAT.SWIFT.MSG instead.
*
* 11/08/05 - EN_10002614
*            FORMATTING SERVICE - PART 2 - FORMAT MSG VIA SERVICE AND SEND TO INTERFACE
*
* 1/02/2010 - Defect -17032 / Task - 17346
*             Read on DE.O.HANDOFF file is removed from here, as the same is duplicated in DE.FORMAT.SWIFT.MSG
*             REF: HD1004025
*
* 25/06/10 - Task 61746
*            Ref : 61042
*            Swift takes long time resulting in timeout during formatting of a message with
*            multiple carriers
*
* 04/11/11 - Task 304504.
*            When two messages with different carriers using the same format module and each carrier contains
*            different interfaces which contains two different OUT.IF.ROUTINES, but while formatting the message
*            it is not picking up the correct OUT.IF.ROUTINE.
*
* 11/02/14   SI : 908842 / Task : 908881
*	         Data Anonymisation enabled for Delivery module
* 06/03/14 - Task 806838
*            Changed MATREAD to F.MATREAD
*
* 08/04/15 - Enhancement 1265068 / Task 1265070
*          - Including $PACKAGE
*
* 02/06/15 - Enhancement 1132400 / Task 1351981
*            Swift 2015 maintenance  - Delivery changes
*            New validations included to move the messages to repair queue if
*            restricted currency is used by checking the SWIFT.PARAMETER for the
*            rule book and the restricted currency check for the specified message type.
*
* 07/10/15 - Defect 1492129 / Task 1492802
*			 Currency and message type is a single multi value field and it is
*			 passed correctly to SWIFT.PARAM.RULE.CHECK routine.
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 18/02/16 - Defect 1610996 / Task 1612905
*            Based on the new field setup in DE.PARM, decision is made whether
*            Statement consolidation is done or not.
*
* 13/04/17 - Defect 2079725 / Task 2089298
*            ERROR.MSG is initialized to prevent the error raised while running
*            SWIFT.OUT service.
*
****************************************************************************************************************
    $USING DE.Config
    $USING EB.DataAccess
    $USING DE.Outward
    $USING EB.SystemTables
    $USING DE.ModelBank
    $USING EB.Security
    $USING DE.API
    DIM R.DETAIL(2000)        ;* Limit to 100 TAGs/Message
    MAT R.DETAIL = ''
    ERROR.MSG = ''
* DE.PARM is read to fetch the STMT.CARR.CONS Field Value to decide on the delivery carrier and interface.
    R.DE.PARM = DE.Config.Parm.CacheRead('SYSTEM.STATUS', PARM.ERR)

    AV1 = EB.SystemTables.getAv()
    CARRIER.ID = FIELD(DE.Outward.getRHead(DE.Config.OHeader.HdrCarrierAddressNo)<1,AV1>,'.',1)
    DE.Outward.setCarrier(CARRIER.ID)
    R.DE.CARRIER = DE.Config.Carrier.CacheRead(CARRIER.ID, READ.ERR)         ;*Identify the format module
    IF READ.ERR = '' THEN
        FORMAT.MODULE = R.DE.CARRIER<DE.Config.Carrier.CarrFormatModule>
    END

    IF CARRIER.ID = "SWIFT" THEN
        GOSUB CHECK.SWIFT.RULE.BOOK ;*This is to check whether the SWIFT Rule book is installed.
    END

*  If the carrier is SWIFT, and there is an error message generated, then the message is written to the repair queue.
    IF CARRIER.ID  = "SWIFT" AND ERROR.MSG AND R.DE.PARM<DE.Config.Parm.ParStmtCarrCons> NE 'N' THEN
        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>=ERROR.MSG; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
        GOSUB WRITE.REPAIR
        RETURN
    END

    IF R.DE.PARM<DE.Config.Parm.ParStmtCarrCons> NE 'N' THEN
        GOSUB IDENTIFY.CARRIER.AND.INTERFACE
        GOSUB OPEN.CARRIER.RELATED.FILES
        IF DE.Outward.getGenericService() = '1' THEN
            GOSUB OPEN.INTERFACE.RELATED.FILES
        END
    END
*
* Open the formatted message file, dependent on the carrier (e.g. carrier
* could be ALLIANCE
*
    CARRIER.FILE = ''
    CARRIER.FILE = DE.Outward.getFDeOMsgCarrier()
*
* Get field from detail file by finding position of field from
* message file
*
    REC.ID = DE.Outward.getRKey()
    R.DETAIL.REC = ''
    R.DETAIL.REC = DE.ModelBank.OMsg.Read(REC.ID, ER)
    MATPARSE R.DETAIL FROM R.DETAIL.REC
    IF ER THEN
        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>='ERROR - Detail record does not exist'; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
        GOSUB WRITE.REPAIR
        RETURN
    END

    IF EB.Security.getEncREbEncParam() AND EB.Security.getEncDeDecryptRtn() THEN     ; *   If Anonymisation is enabled for Delivery messages
        GOSUB DECRYPT.MSG
    END

* LOAD.ERI para is removed (where as the OPF and read on DE.O.HANDOFF is removed), this will handled in DE.FORMAT.SWIFT.MSG

    OUTPUT = ""
    DE.Outward.FormatSwiftMsg(MAT R.DETAIL, OUTPUT, ERI.REC, YERR.MSG)
    IF YERR.MSG THEN
        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>=YERR.MSG; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
        GOSUB WRITE.REPAIR
    END
RETURN
*
*************************************************************************

DECRYPT.MSG:
* Decrypting already encrypted message stored in DE.O.MSG
    DE.DECRYPT.RTN.NAME = EB.Security.getEncDeDecryptRtn()
    MATBUILD R.RECORD FROM R.DETAIL
    ARGUMENTS = DE.Outward.getRKey():@FM:LOWER(R.RECORD)  ; * Building hook routine arguments <Delivery Reference>@FM<Delivery Message>
    EB.SystemTables.CallApi(DE.DECRYPT.RTN.NAME, ARGUMENTS)
    R.RECORD =  RAISE(ARGUMENTS<2>) ; * Outcoming argument<2> will have decrypted message and is assigned to R.DETAIL
    MATPARSE R.DETAIL FROM R.RECORD
RETURN

*
WRITE.REPAIR:
*
* Add key to repair file
*
    tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgDisp); tmp<1,AV1>='REPAIR'; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgDisp, tmp)
    R.REPAIR = DE.Outward.getRKey():'.':AV1
    DE.Outward.UpdateORepair(R.REPAIR,'')
RETURN
*
*************************************************************************

IDENTIFY.CARRIER.AND.INTERFACE:
******************************

    DE.Outward.setAddressModule(R.DE.CARRIER<DE.Config.Carrier.CarrAddress>)
    CARRIER.MODULE = R.DE.CARRIER<DE.Config.Carrier.CarrCarrierModule>

* Check for interface
    IF CARRIER.MODULE = 'GENERIC' THEN
        DE.Outward.setGenericService('1')
        DE.Outward.setInterface(R.DE.CARRIER<DE.Config.Carrier.CarrInterface>)
    END

RETURN


OPEN.CARRIER.RELATED.FILES:
***************************


    FN.DE.O.MSG.CARRIER.LOC = 'F.DE.O.MSG.':DE.Outward.getCarrier() ; F.DE.O.MSG.CARRIER.LOC =''        ;* carrier could be ALLIANCE
    EB.DataAccess.Opf(FN.DE.O.MSG.CARRIER.LOC, F.DE.O.MSG.CARRIER.LOC)
    DE.Outward.setFnDeOMsgCarrier(FN.DE.O.MSG.CARRIER.LOC)
    DE.Outward.setFDeOMsgCarrier(F.DE.O.MSG.CARRIER.LOC)



    FN.DE.FORMAT.CARRIER.FILE.LOC = 'F.DE.FORMAT.':FORMAT.MODULE ; F.DE.FORMAT.CARRIER.FILE.LOC = ''        ;* DE.FORMAT.SWIFT, DE.FORMAT.PRINT etc
    EB.DataAccess.Opf(FN.DE.FORMAT.CARRIER.FILE.LOC, F.DE.FORMAT.CARRIER.FILE.LOC)
    DE.Outward.setFnDeFormatCarrierFile(FN.DE.FORMAT.CARRIER.FILE.LOC)
    DE.Outward.setFDeFormatCarrierFile(F.DE.FORMAT.CARRIER.FILE.LOC)

RETURN

OPEN.INTERFACE.RELATED.FILES:
****************************

* Open the files used in Generic routine

    FN.DE.O.MSG.INTERFACE.LOC = 'F.DE.O.MSG.':DE.Outward.getInterface() ; F.DE.O.MSG.INTERFACE.LOC = ''
    EB.DataAccess.Opf(FN.DE.O.MSG.INTERFACE.LOC,F.DE.O.MSG.INTERFACE.LOC)
    DE.Outward.setFnDeOMsgInterface(FN.DE.O.MSG.INTERFACE.LOC)
    DE.Outward.setFDeOMsgInterface(F.DE.O.MSG.INTERFACE.LOC)

    FN.DE.SENT.CARRIER.LOC = 'F.DE.SENT.':DE.Outward.getCarrier() ; F.DE.SENT.CARRIER.LOC = ''
    EB.DataAccess.Opf(FN.DE.SENT.CARRIER.LOC, F.DE.SENT.CARRIER.LOC)
    DE.Outward.setFnDeSentCarrier(FN.DE.SENT.CARRIER.LOC)
    DE.Outward.setFDeSentCarrier(F.DE.SENT.CARRIER.LOC)

* Read interface
    INT.ERR = ''
    INTERFACE.ID = DE.Outward.getInterface()
    R.DE.INTERFACE = DE.Config.Interface.CacheRead(INTERFACE.ID, INT.ERR)

    DE.Outward.setOutRoutine(R.DE.INTERFACE<DE.Config.Interface.ItfOutIfRoutine>)
    DE.Outward.setShutdownRoutine(R.DE.INTERFACE<DE.Config.Interface.ItfShutdownRoutine>)
    DE.Outward.setAckRequired(R.DE.INTERFACE<DE.Config.Interface.ItfAckRequired>)


RETURN


*-----------------------------------------------------------------------------

*** <region name= CHECK.SWIFT.RULE.BOOK>
CHECK.SWIFT.RULE.BOOK:
*** <desc>This is to check whether the SWIFT Rule book is installed. </desc>

    SWIFT.RELEASE = "2015"
    INSTALLED = ''
    RTN.MSG = ''

    DE.API.SwiftRuleBookCheck(SWIFT.RELEASE, INSTALLED, RTN.MSG)

    IF NOT(RTN.MSG) AND INSTALLED = "YES" THEN
        GOSUB CHECK.SWIFT.PARM.RULE ;*To Check the SWIFT Parameter for the Rule we specify for the specified RULE Value and Message Type
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.SWIFT.PARM.RULE>
CHECK.SWIFT.PARM.RULE:
*** <desc>To Check the SWIFT Parameter for the Rule we specify for the specified RULE Value and Message Type </desc>
    ERROR.MSG = ''
    RESTRICTED = ''
    RTN.MSG = ''
    RULE.PARAM = "CURRENCY"
* Currency and message type are single value field. So it is passed correctly.

    RULE.VALUE = DE.Outward.getRHead(DE.Config.OHeader.HdrCurrency)
    MSG.TYPE = DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType)

    DE.API.SwiftParamRuleCheck(RULE.PARAM, RULE.VALUE, MSG.TYPE, RESTRICTED, RTN.MSG)

    IF RESTRICTED = 'YES' THEN
        ERROR.MSG = 'ERROR - Restricted Currency Used'
    END

RETURN
*** </region>

END
