* @ValidationCode : Mjo5MzkzMzc5Nzc6Q3AxMjUyOjE1MzczNTc2MzQ2MTM6cHN2aWppOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTA2LTAyMzI6NDM6NDA=
* @ValidationInfo : Timestamp         : 19 Sep 2018 17:17:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : psviji
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/43 (93.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE UpdateT24TableRestructureQueue(fileNameList,recIdList)
*-----------------------------------------------------------------------------
*
* This routine takes care of writing T24.TABLE.RESTRUCTURE.QUEUE based on T24.TABLE.RESTRUCTURE values.
* The T24.TABLE.RESTRUCTURE file will have entry for application or files which need restructuring.
* Online transactions can understand the a) system mode using SPF>ONLINE.UPGRADE, b) current table or file need restructuring
* if it has entry in T24.TABLE.RESTRUCTURE.
*
*-----------------------------------------------------------------------------
*** <region name= ModificationHistory>
*** <desc> </desc>
* 18/09/2017 - Task 2262587
*              Online upgrade
*              Update T24.TABLE.RESTRUCTURE.QUEUE for a table write request in FW cache variables if that file opt for restructuring.
*
* 20/11/2017 - Task 2349694
*              TAFC compilation issue, common variable componentised get methods assigned to a variable
*              and then used in READ and WRITE statements.
*
* 09/03/2018 - Task 2493574
*             Avoid looking for restructure table list to update feeder queue when Write request comes from
*             online upgrade services.
*
* 16/09/2018 - Task 2770283
*             Suffix OFS.SOURCE id as part of ID of T24.TABLE.RESTRUCTURE.LIST feeder queue.
*             So that enquiries can fetch channel details of this transaction.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MainProcess>
*** <desc> </desc>
    
    $USING EB.SystemTables
    $USING EB.Upgrade
    $USING EB.DataAccess
    $USING EB.Service
    $USING EB.Interface
    
    rSpfSystem = EB.SystemTables.getRSpfSystem()
    IF NOT(fileNameList) OR (rSpfSystem<EB.SystemTables.Spf.SpfOnlineUpgrade> NE 'YES') THEN       ;* values not loaded, no files to be written to queue , do a double check before proceeding
        RETURN                   ;* just return
    END
    onlineUpgradeServiceList = 'T24.RESTRUCTURE.SERVICE':@VM:'T24.RESTRUCTURE.FEEDER':@VM:'T24.UPGRADE.PRIMARY':@VM:'T24.UPGRADE':@VM:'T24.AUTHORISE'
    currentService = FIELD(EB.Service.getBatchInfo()<1>, '/', 2)
    IF currentService MATCHES onlineUpgradeServiceList THEN                  ;* don't look for restructure table list when W(rite) request from these services
        RETURN                                                               ;* just return, unnecessary I/O avoided
    END
    GOSUB initialise
    GOSUB updateQueue
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise required variables </desc>
  
    IF NOT(EB.Upgrade.getFvT24TableRestrQueue()) THEN                 ;* do file open only once per session
        fnTableRestrQueue = 'F.T24.TABLE.RESTRUCTURE.LIST'
        fvTableRestrQueue = ''
        EB.DataAccess.Opf(fnTableRestrQueue, fvTableRestrQueue)        ;* do file open for T24.TABLE.RESTRUCTURE.QUEUE
        EB.Upgrade.setFnT24TableRestrQueue(fnTableRestrQueue)
        EB.Upgrade.setFvT24TableRestrQueue(fvTableRestrQueue)
    END
    ofsSourceId = EB.Interface.getOfsSourceId()
     
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= updateQueue>
updateQueue:
*** <desc>Update T24.TABLE.RESTRUCTURE.LIST for any write on table which are opt for restructuring. this will be picked up by Restructuring service to do conversion. </desc>
* Restructuring service will also handle T24.TABLE.RESTRUCTURE.LIST having just fileName as id (as it is updated from temp release by T24.INITIATE.UPGRADE), select whole file and restructure across company based on file classification.
* RESTRUCTURE.TABLES field in SPF will be cleared by that service after restructuring over.
    
    fileTotCnt = DCOUNT(fileNameList,@FM)
    FOR fileCnt = 1 TO fileTotCnt
        fileMnemonic = FIELD(fileNameList<fileCnt>,'.',1)
        fileMnemonic = fileMnemonic[2,3]                    ;* get file mnemonic
        companyId = ''
        IF fileMnemonic THEN
            EB.DataAccess.CacheRead("F.MNEMONIC.COMPANY", fileMnemonic, companyId, "")
        END
        recordId = recIdList<fileCnt>
        currentFileName = FIELD(FIELD(fileNameList<fileCnt>,'.',2,99),'$',1)     ;* get only file name without file suffix
        LOCATE currentFileName IN rSpfSystem<EB.SystemTables.Spf.SpfRestructureTables,1> SETTING rstrPos THEN              ;* identify whether current file is enabled for restructuring logic, if yes then write to queue
            queueRecId = currentFileName:'*':companyId:'*':recordId:'*':ofsSourceId            ;* company mnemonic position is depends on currentFile classification
            fvTableRestrQueue = EB.Upgrade.getFvT24TableRestrQueue()
            READ tmpRecord FROM fvTableRestrQueue,queueRecId ELSE              ;* check whether any record exist in this id already
                WRITE queueRecId TO fvTableRestrQueue,queueRecId ON ERROR              ;* update t24 table restructure queue for service to pickup and restructure txn data for that company.
                    TEXT = 'Cannot write ':queueRecId:' to ':currentFileName     ;* Write error
                    CALL FATAL.ERROR('UpdateT24TableRestructureQueue')
                END
            END
        END
    NEXT fileCnt
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
