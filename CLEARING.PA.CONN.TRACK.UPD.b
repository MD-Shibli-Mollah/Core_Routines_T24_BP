* @ValidationCode : MjotMTk4NTM1MDk0NzpDcDEyNTI6MTU2NDQwMDcyNDE3NTp5Z3JhamFzaHJlZToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzIzLTAyNTE6ODI6ODI=
* @ValidationInfo : Timestamp         : 29 Jul 2019 17:15:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygrajashree
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/82 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE FT.Clearing
SUBROUTINE CLEARING.PA.CONN.TRACK.UPD(EntryDetails,ClearingRecord,PostProcessResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :

* 05/03/19 - Enhancement 2984417 / Task 2984419
*            New Routine to update the PA.CONNECTION.TRACKER record, based on the values from AC.INWARD.ENTRY.
*
* 22/03/19 - Defect 3047759 / Task 3046951
*            Upadte the ALL.TXN.RECEIVED in PA.CONNECTION.TRACKER, only if all the batches are processed under the ARRG.ID
*
* 15/05/19 - Defect 3097199 / Task 3130619
*            Call to OFS.BULK.MANAGER is changed to OFS.POST.MESSAGE
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.Interface
    $USING PA.Contract
    $USING EB.LocalReferences
    $USING EB.API
    $USING EB.Security
    
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*** </region>
*-----------------------------------------------------------------------------
PROCESS:
    IF ConnTracRec NE '' THEN           ;*Check if the record exists in PA.CONNECTION.TRACKER for the ID passed in EntryDetails
        UniqueBatchRef = ClearingRecord<FT.Clearing.AcInwardEntry.AcieUniqueBatchRef>
        FIND UniqueBatchRef IN BatchId SETTING FM.POS,VM.POS,SM.POS THEN  ;* For the account num passed, find EXT.BATCH.REF matches and update values accordingly
            ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerProcessedFlag,VM.POS,SM.POS>=1
            ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerRcvdCnt,VM.POS,SM.POS>=ClearingRecord<FT.Clearing.AcInwardEntry.AcieNoTxnBatch>
            ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerSuccessCnt,VM.POS,SM.POS>=ClearingRecord<FT.Clearing.AcInwardEntry.AcieNoSuccessTxn>
            ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerFailedCnt,VM.POS,SM.POS>=ClearingRecord<FT.Clearing.AcInwardEntry.AcieNoRejectTxn>
        END
        
        LOCATE AcctNo IN ConnTracAcctNum<1,1> SETTING VM.POS1 THEN
            NextPageID = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerTxnNextPageId,VM.POS1>
            ProcessedFlagCount=SUM(ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerProcessedFlag,VM.POS1>) ;* To finnd how many batches are processed.
        END
        
        IF ProcessedFlagCount EQ NextPageID THEN          ;* Update all tansactions received to 1 only if all the Batches are processed
            ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerAllTxnsReceived,VM.POS1>= 1
            securemsg<1> = RecId
            securemsg<2> = AcctNo
            PA.Contract.ConnectionSecuremsg(securemsg,'INITIALLOAD', "POSTINGREADY",ConnTracRec)       ;*raise secure message indicating transactions loaded
* Check all txns received in all batch- then move status to active
            BUILD.OFS = 0 ;* default is to write directly without using OFS to avoid history for every update
            GOSUB CHECK.STATUS.UPDATE
            IF NOT(BUILD.OFS) THEN
                GOSUB WRITE.TO.TRACKER.RECORD ;* Direct write
            END ELSE
                EB.Foundation.OfsBuildRecord("PA.CONNECTION.TRACKER", "I", "PROCESS", "PA.CONNECTION.TRACKER,TRANSACTION", '', "0", RecId , ConnTracRec, Ofsrecord)    ;* Building Ofs Source Record
                OFS.SOURCE.ID = 'PA.CONN.UPD'   ;* set ofs source id
                EB.Interface.OfsPostMessage(Ofsrecord, "",OFS.SOURCE.ID, "")
            END
        END
    END
RETURN
*** </region>
******************************************************************************************************
*** </region>
*-----------------------------------------------------------------------------
INITIALISE:

    Error=''
    Ofsrecord=''
    ConnTracRec = ''
    ofsInfo = ''                          ;* information needed for OFS.CALL.BULK.MANAGER
    isTxnCommited = ''
    isInstalled = ''
    ofsMsgResponse = ''
    RecId = ClearingRecord<FT.Clearing.AcInwardEntry.AcieExternalBatchRef>     ;* Get the @id to read the record from PA.CONNECTION.TRACKER
    EB.API.ProductIsInSystem("PA", isInstalled)     ;* Is product code installed
    IF isInstalled THEN
        PA.Contract.ConnectionTrackerLock(RecId, ConnTracRec, Error, '', '')
    END
    BatchId = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerBatchId> ;*List of all Batch Ids in the record
    ConnTracAcctNum = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerArrId>    ;*List of all account numbers in the record
    LocalFields = ClearingRecord<FT.Clearing.AcInwardEntry.AcieLocalRef>
    EB.LocalReferences.GetLocRef('AC.INWARD.ENTRY', 'OBCB.ACCTID', Pos1)        ;*get the position of local field in the AC.INWARD.ENTRY
    AcctNo = LocalFields<1,Pos1>
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region>
*-----------------------------------------------------------------------------
WRITE.TO.TRACKER.RECORD:
    TIME.DATE = TIMEDATE()
    X = OCONV(DATE(),"D-")
    DT = X[9,2]:X[1,2]:X[4,2]:TIME.DATE[1,2]:TIME.DATE[4,2]
    ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerDateTime> =  DT
    ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerInputter> = EB.SystemTables.getTno() :"_":EB.SystemTables.getOperator()
    ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerCompCode> = EB.SystemTables.getIdCompany()
    ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerAuthorise> =  EB.SystemTables.getTno() :"_":EB.SystemTables.getOperator()
    PA.Contract.ConnectionTrackerWrite(RecId, ConnTracRec, '')
RETURN
*** <region>

*-----------------------------------------------------------------------------
*** <region>
*-----------------------------------------------------------------------------
CHECK.STATUS.UPDATE:

    subStatus = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerSubStatus>
    IF subStatus NE 'POSTINGREADY' THEN
        RETURN
    END
    totalArrangements = DCOUNT(ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerObcpAcctId,@VM)
    allActiveTxnsReceived = 0 ;* all Active transactions
    allActiveArrangements = 0 ;* all Active Arrangements
        
    FOR arrangementNo = 1 TO totalArrangements
        obcpStatus = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerObcpStatus>
        arrstatus = UPCASE(obcpStatus<1,arrangementNo>)
        IF  arrstatus MATCHES 'ACTIVE':@VM:'INACTIVE' THEN ;* only if active/inactive- exclude disabled
            txnReceived = ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerAllTxnsReceived>
            allActiveTxnsReceived += txnReceived<1,arrangementNo> ;* add active transactions
            allActiveArrangements +=1 ;* add to active arrangements
            
        END ;* end all done
    NEXT arrangementNo
        
    IF (allActiveTxnsReceived EQ allActiveArrangements ) AND allActiveTxnsReceived THEN ;* All are done
        ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerConnectionStatus> = "ACTIVE" ;* all done
        ConnTracRec<PA.Contract.PAConnectionTracker.ConnTrackerSubStatus> = "";* reset
        BUILD.OFS = 1
    END  ;* end arr status check
RETURN
END
