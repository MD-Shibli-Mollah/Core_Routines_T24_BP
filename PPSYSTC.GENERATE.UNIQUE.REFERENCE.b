* @ValidationCode : MjotNTI0ODkyMDM5OkNwMTI1MjoxNjE4NDgxMjcwNTcyOnN0dXRpLnNpbmdoOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1Njo2NDo2MQ==
* @ValidationInfo : Timestamp         : 15 Apr 2021 15:37:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stuti.singh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 61/64 (95.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.GENERATE.UNIQUE.REFERENCE(iLockingId,iAgentDigits,iRandomDigitsLen,iReserved,oUniqueReference,oReserved)
*-----------------------------------------------------------------------------
*   @author : stuti.singh@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
*   12/04/2021 - Defect - 4333141 / Task - 4339104 - Regression Fix
*-----------------------------------------------------------------------------
* This API returns a unique reference number when called from any service. The length of this reference, is determined
* by the iAgentDigits (no of digits to be obtained from Relative position of the agent) and the iRandomDigitsLen (no of digits
* to be retrieved from the Locking record created with the iLockingId).
*
* Parameters :
*
* IN - iLockingId  - Record Id on which the F.LOCKING record will be created
* IN - iAgentsDigits - no of digits to be obtained from Relative position of the agent
* IN - ireserved - input parameter reserved for future use
* IN - iRandomDigitsLen - no of digits to be retrieved from the Locking record created with the iLockingId
* OUT - oUniqueReference - Generated Unique reference
* OUT - oreserved - output parameter reserved for future use
*-----------------------------------------------------------------------------------------------------------------------------------
* Modification History :
*
*----------------------------------------------------------------------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.DataAccess
    
    $INSERT I_TSA.COMMON
    $INSERT I_F.TSA.STATUS
    
        
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process ; *Generate a unique reference number based on the incoming parameters

RETURN
*------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables used </desc>

    AgentPostionSeqNo = ''
    LockingSeqNo = ''
    oUniqueReference = ''
    ServerDets = ''
    ServiceName = ''
    AgentNumber = ''
    AgentPostionSeqNo = ''
    LockingId = ''
    SeqNo = ''
    oReserved = ''
RETURN
*** </region>

*-------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Generate 7 digit unique reference number </desc>

    GOSUB FromAgentPostion ; *Get the required digits by retrieving Agent position
    GOSUB FromLocking ; *Get the required digits from FLocking record
    
    oUniqueReference = AgentPostionSeqNo:LockingSeqNo  ;* unique reference formed from relative position and Locking record

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= FromAgentPostion>
FromAgentPostion:
*** <desc>Get the required digits by retrieving Agent position </desc>
*
*    ServerDets = EB.Service.getRTsaStatus()<EB.Service.TsaStatus.TsTssServer>
*    IF ServerDets = '' THEN
*        ServerDets = EB.Service.getServerName()
*    END
*
*    ServiceName = EB.Service.getRTsaStatus()<EB.Service.TsaStatus.TsTssCurrentService>
    
    ServerDets = R.TSA.STATUS<TS.TSS.SERVER>  ;* Server Details from the TSA record
    
    IF ServerDets EQ '' THEN
        ServerDets = SERVER.NAME
    END
    
    ServiceName = R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> ;* Current Service whose agent's relative position is to be determined
    
;* This routine gives the relative position of the agent which executes the current service with respect to the other active agents. If the none of the service is running, the agent number
;* will be returned as 'OLTP####'. Trim the numeric part when the agent number is returned as alpha numeric.

    CALL EB.GET.RELATIVE.POSITION(ServerDets,ServiceName,AgentNumber)

    IF NUM(AgentNumber) ELSE
        len = LEN(AgentNumber) ;* Agent number can be of varying length
        AgentNumber = AgentNumber[5,len] ;* get the numeric part of the agent number
    END
    
    IF iAgentDigits GT LEN(AgentNumber) THEN ;* when the incoming no of agent digits is greater than the agent number returned, mask the output
        MaskCode = iAgentDigits:"'0'R"  ;* mask the output with the required no of 0s.
        AgentPostionSeqNo = FMT(AgentNumber,MaskCode) ;* relative position of the agent (unique) after formatting to required no of digits
    END ELSE
        AgentPostionSeqNo = AgentNumber[1,iAgentDigits]  ;* If the number of agent digits is less than or equal to the number of digits in Agent number, trim
    END

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= FromLocking>
FromLocking:
*** <desc>Get the required digits from FLocking record </desc>
    
    FnLocking = 'F.LOCKING'
    FLocking = ''
    
    LockingId = iLockingId:'.':AgentPostionSeqNo  ;* The locking id is formed by concatenating the incoming locing id name (eg Unique, Trace..) with the unique agent position seq
    rLocking = ''
    RecEr = ''
    Retry = ''
    
    CurrentDate = EB.SystemTables.getToday() ;* get TODAY date

*If more than one payment processed at same time, both can get same record, if it is not locked
*So, Changing Read to Readu to lock the record
    EB.DataAccess.FReadu(FnLocking, LockingId,rLocking, FLocking, RecEr, Retry)  ;* read the Locking table with the id formed
    
    IF rLocking EQ '' THEN  ;* if there is no record, write a new one with the sequence number and today date
        SeqNo = '1' ;* sequence number
        rLocking<2> = SeqNo
    END ELSE
        IF rLocking<2> EQ '99999' THEN  ;* If value reaches 9999999 then start the sequence again
            RSuffix = ''
            SeqNo = '1' ;* sequence number
            rLocking<2> = SeqNo
        END ELSE
            SeqNo = rLocking<1> + 1 ;* if the record is present , then update the existing record
            rLocking<2> = SeqNo
        END
    END
    
    MaskCode = iRandomDigitsLen:"'0'R" ;* mask the output with the required no of 0s.
    rLocking<1> = FMT(SeqNo,MaskCode) ;* formatting to the required no of digits
    LockingSeqNo = rLocking<1> ;* the unique number after formatting to the required no of digits

    RSuffix = ''
    EB.SystemTables.LockingWrite(LockingId, rLocking, RSuffix) ;* Update the Locking record
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
END

