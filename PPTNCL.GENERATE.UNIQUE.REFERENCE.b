* @ValidationCode : MjotODg5NzE4MTk2OkNwMTI1MjoxNTk0MjA1Nzk0MTE1OnNrYXlhbHZpemhpOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNTo2Njo2Ng==
* @ValidationInfo : Timestamp         : 08 Jul 2020 16:26:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 66/66 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.GENERATE.UNIQUE.REFERENCE(iLockingId,iAgentDigits,iRandomDigitsLen,iReserved,oUniqueReference,oReserved)
*-------------------------------------------------------------------------------------------------------------------------------------
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
*---------------------------------------------------------------------------------------------------------------------------------------
*
* 13/05/2019 - Enhancement 2959657 / Task 2959618
*            - API to generate an unique reference number
* 02/08/2019 - Defect 3269782 / Task 3269802
*            - Changes to do Readu of F.LOCKING to lock Unique Id
* 27/01/2020 - Defect 3408269/Task 3556339
*             - Coding Added for removing EB.DataAccess.FWrite by replacing update routines of the respective component.

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
    Suffix=''
    CurrentDate = EB.SystemTables.getToday() ;* get TODAY date

*If more than one payment processed at same time, both can get same record, if it is not locked
*So, Changing Read to Readu to lock the record
    EB.DataAccess.FReadu(FnLocking, LockingId,rLocking, FLocking, RecEr, Retry)  ;* read the Locking table with the id formed
    
    IF rLocking EQ '' THEN  ;* if there is no record, write a new one with the sequence number and today date
        SeqNo = '1' ;* sequence number
        rLocking<2> = CurrentDate ;* today date
    END ELSE
        IF rLocking<2> LT CurrentDate THEN  ;* if there is a locking record present, but it is not created today, clear the record and create a new record.
            EB.DataAccess.FDelete(FnLocking,LockingId) ;* delete the exisitng old record
            SeqNo = '1' ;* sequence number
            rLocking<2> = CurrentDate ;* today date
        END ELSE
            SeqNo = rLocking<1> + 1 ;* if the record is present and is created today, then update the existing record
        END
    END
    
    IF LEN(SeqNo) GT iRandomDigitsLen THEN  ;* after incrementing, if the seq number exceeds the number of digits mentioned in the incoming parameter, then reinitialise the seq number
        SeqNo = '1'
    END
    
    MaskCode = iRandomDigitsLen:"'0'R" ;* mask the output with the required no of 0s.
    rLocking<1> = FMT(SeqNo,MaskCode) ;* formatting to the required no of digits
    LockingSeqNo = rLocking<1> ;* the unique number after formatting to the required no of digits
        
    EB.SystemTables.LockingWrite(LockingId, rLocking, Suffix)
        
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
END
