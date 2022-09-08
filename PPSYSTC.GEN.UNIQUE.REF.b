* @ValidationCode : MjoxNTQ0NzEwMTk5OkNwMTI1MjoxNjAyNzUzODA1MTY1OnNrYXlhbHZpemhpOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo1Mjo0OA==
* @ValidationInfo : Timestamp         : 15 Oct 2020 14:53:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 48/52 (92.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.GEN.UNIQUE.REF(iCompanyDetails,iClearingDetails,oFileRef)
*-----------------------------------------------------------------------------
* This routine generates the sequenceNumber to be mapped in outgoing file.
*-----------------------------------------------------------------------------
* Modification History :
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
* 3/8/2020 - Enhancement 3614846/Task 3854892 -Afriland - SYSTAC (CEMAC) - Resubmission of Direct Debits - Clearing
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process ; *Generate a unique reference number

RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
    LockingId = ''
    SeqNo = ''
    fileRefIndicator = ''
    clearingTxnType = ''
    clearingNatureCode  = ''
    fileRefIndicator = FIELD(iClearingDetails,'*',14)
    clearingTxnType = FIELD(iClearingDetails,'*',1)
    outgoingMsgType = FIELD(iClearingDetails,'*',2 )
    clearingNatureCode  = FIELD(iClearingDetails,'*',8)
RETURN
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
    IF fileRefIndicator NE '' THEN
        oFileRef = fileRefIndicator ;* returns the fileReference which is already generated.
        RETURN
    END
    
    IF clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'SYSTACDD' AND clearingNatureCode EQ '' THEN
        LockingId = 'SYSTAC.DD.FILEREF'  ;* The locking id for generating file reference
    END ELSE IF outgoingMsgType EQ 'SYSTACDDRJ' THEN
        LockingId = 'SYSTAC.RJ.FILEREF'
    END ELSE IF clearingTxnType EQ 'CC' THEN
        LockingId = 'SYSTAC.CC.FILEREF'
    END ELSE IF clearingTxnType EQ 'RF' THEN
        LockingId = 'SYSTAC.RF.FILEREF'
    END ELSE IF outgoingMsgType EQ 'SYSTACDD' AND clearingNatureCode EQ 'REP' THEN
        LockingId = 'SYSTAC.REP.DD.FILEREF'
    END ELSE IF outgoingMsgType EQ 'SYTCRDDR' THEN
        LockingId = 'SYSTAC.REP.RJ.FILEREF'
    END ELSE
        RETURN ;* if clearing Txn type is not DD or RJ, the skip the sequence generation value
    END
    FnLocking = 'F.LOCKING'
    FLocking = ''
    
    rLocking = ''
    RecEr = ''
    Suffix=''
    Retry = ''
    
    EB.DataAccess.FReadu(FnLocking, LockingId,rLocking, FLocking, RecEr,Retry)  ;* read the Locking table with the id formed
    IF rLocking EQ '' OR rLocking EQ '9999' THEN ;* if value if null or 9999, then start the value fron sequence 0001
        SeqNo = '0001'
    END ELSE
        SeqNo = rLocking<1> + 1
    END
    length = 4-LEN(SeqNo)
    FOR cnt =1 TO length
        SeqNo = '0':SeqNo ;* form the value as 4 digit value
    NEXT cnt
    rLocking<1> = SeqNo
   
    EB.SystemTables.LockingWrite(LockingId, rLocking, Suffix)
    
    oFileRef = rLocking<1>  ;* file reference
RETURN
*-----------------------------------------------------------------------------
END
