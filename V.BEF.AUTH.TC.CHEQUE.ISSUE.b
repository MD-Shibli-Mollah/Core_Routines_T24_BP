* @ValidationCode : MjoxMDM3MzU0NjE6Q3AxMjUyOjE2MTc2MjA4MDQwODY6bGFsaXRoYWxha3NobWk6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjU3OjUz
* @ValidationInfo : Timestamp         : 05 Apr 2021 16:36:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lalithalakshmi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/57 (92.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.













$PACKAGE CQ.Channels
SUBROUTINE V.BEF.AUTH.TC.CHEQUE.ISSUE
*-----------------------------------------------------------------------------
* This routine used to trigger the cheque issue flow, to be attached to the
* CHEQUE.ISSUE,TC version as Check routine
*-----------------------------------------------------------------------------
* Modification History :
* 13/11/2018  - Enhancement 2293366 / Task 2868666
*               2293366: User Journey - Phase 3 - Cheques
*
* 01/10/19 - Defect - 3367195 / Task - 3367524
*          - CQ product installation check.
*-----------------------------------------------------------------------------
    $USING CQ.ChqIssue
    $USING PW.Foundation
    $USING EB.Versions
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING EB.Interface
    $USING AC.AccountOpening
    $USING EB.ARC
    $USING EB.API
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------------------------
    PROCESS.DEF = 'CHEQUE.BOOK.ISSUE'
    APP.NAME = 'PW.PROCESS'         ;* the application is PW.PROCES
    OFS.FUNCT = 'I'       ;* function is 'I'
    PROCESS = 'PROCESS'
    VERSION.NAME = ''     ;* OFS.build.record does not add ap
    R.VER = ''
    ER = ''
    SERIES.ID=''
    CHQ.ID = EB.SystemTables.getIdNew()                             ;*Extract Cheque Issue ID from ID.NEW variable
    ACCOUNT.ID = FIELDS(CHQ.ID,'.',2)                               ;*Get account number
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.ID, YERR)    ;*Read account record
    CUSTOMER.ID = R.ACCOUNT<AC.AccountOpening.Account.Customer>     ;*Extract customer number form account record
    
    CQInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)   ;* Checks if CQ product is installed
RETURN
*-----------------------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------------------
*Read channels paramater record to retrive version name
    GOSUB READ.CHANNELS.PARAMETER
    IF CQInstalled THEN
        SERIES.ID = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsSeriesId) ;*Extract seried ID if defaulted in the routine V.VAL.TC.CHEQUE.ISSUE
    END
    IF SERIES.ID MATCHES '' OR SERIES.ID MATCHES '0' THEN
* Creation of PW.PROCESS for the cheque issue process
        R.VER = EB.Versions.Version.CacheRead(VERSION.NAME, ER)         ;* get the version details.
        GTS.MODE =  1                                                   ;* hardcode the gts mode
        NO.OF.AUTH = R.VER<EB.Versions.Version.VerNoOfAuth>             ;* get no of auth details
        TRANS.ID = ''                                                   ;* say new id need to be generated
        OFS.RECORD<PW.Foundation.Process.ProcProcessDefinition>=PROCESS.DEF     ;* the pw process def name
        OFS.RECORD<PW.Foundation.Process.ProcCustomer>= CUSTOMER.ID     ;* customer
        OFS.RECORD<PW.Foundation.Process.ProcParentCtxId>=CHQ.ID        ;* parent ctx id
        EB.Foundation.OfsBuildRecord(APP.NAME,OFS.FUNCT,PROCESS,VERSION.NAME,GTS.MODE,NO.OF.AUTH,TRANS.ID,OFS.RECORD,OFS.STRING)         ;* build the ofs string
        OFS.SOURCE.ID = "PW.OFS"
        IF OFS.RECORD THEN
            EB.Interface.OfsPostMessage(OFS.STRING,'',OFS.SOURCE.ID,'')     ;* write into the OFS queue
        END
    END
RETURN
*------------------------------------------------------------------------------------------------
READ.CHANNELS.PARAMETER:
    R.CHANNEL.PARAMETER = EB.ARC.ChannelParameter.CacheRead('SYSTEM', Error)        ;*Read Channel Parameter record and extarct application and version name
    APPL.ID.LIST = R.CHANNEL.PARAMETER <EB.ARC.ChannelParameter.CprAppName>
    VERSION.LIST = R.CHANNEL.PARAMETER <EB.ARC.ChannelParameter.CprVersionName>
    CONVERT @VM TO @FM IN APPL.ID.LIST
    CONVERT @VM TO @FM IN VERSION.LIST
    LOOP
        REMOVE APPL FROM APPL.ID.LIST SETTING APPL.POS
    WHILE APPL:APPL.POS
        APPL.CNT+=1
        IF APPL MATCHES APP.NAME THEN
            VERSION.NAME = VERSION.LIST<APPL.CNT,1>
            EXIT
        END
    REPEAT
    IF VERSION.NAME NE '' THEN
        VERSION.NAME=APP.NAME:VERSION.NAME
    END ELSE
        VERSION.NAME= 'PW.PROCESS,AUTO'             ;* If PW.PROCESS version is not found in Channel Parameter record then default the version.
    END
RETURN
END
