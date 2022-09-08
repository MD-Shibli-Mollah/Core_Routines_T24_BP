* @ValidationCode : Mjo1NjMwMDg0NDc6Q3AxMjUyOjE1OTcwNTgxNDg1NzQ6YnNhdXJhdmt1bWFyOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1Mjo1Mg==
* @ValidationInfo : Timestamp         : 10 Aug 2020 16:45:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/52 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE TZ.API
SUBROUTINE TransactionStop.FtProcess
*-----------------------------------------------------------------------------
* Input Routine to be attached to the FT Processing to decide and arrive at the
* Transaction Stop Process decision and raise respective overrides
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 19/06/18 - Enhancement 2582246 / Task 2582514
*            API for Transaction Stop check in FT process
*            And raise overrides based on the decision arrived after checking the Stop instructions
*
* 10/08/20 - Defect 3875404 / Task 3903013
*            DCOUNT removed from loop counter
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.LocalReferences
    $USING FT.Contract
    $USING EB.OverrideProcessing
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB MainProcess
    
RETURN
*-----------------------------------------------------------------------------
Initialise:
*Variable initialisation
    Record=''
    SaveRnew=''
    TransactionId=''
    Application=''
    SourceInfo=''
    ProcessReturnInfo=''
    Decision=''
    InstructionId=''
    InstructionDecision=''
    InstrCnt=''
    TransInstrution=''
    CurrNo=''
    TransInstrPos=''
    
RETURN
*-----------------------------------------------------------------------------
MainProcess:
    
    Record = EB.SystemTables.getDynArrayFromRNew()  ;*get Record details from R.NEW
    SaveRnew = Record
    TransactionId = EB.SystemTables.getIdNew()  ;*get Id from ID.NEW
    Application = EB.SystemTables.getApplication()  ;*get the Current application from APPLICATION

*assign the transaction details to the SourceInfo
    SourceInfo<TZ.API.ApplicationSource> = Application
    SourceInfo<TZ.API.SourceId> = Record<FT.Contract.FundsTransfer.TransactionType>
    SourceInfo<TZ.API.ApplicationId> = TransactionId
    
    TZ.API.TransactionStopProcessingApi(Record,SourceInfo,ProcessReturnInfo,"","");*call Processing Api to get the transaction stop decision
    
    Decision = ProcessReturnInfo<TZ.API.OverallDecision>    ;*get the decision value
    InstructionId = ProcessReturnInfo<TZ.API.InstrId>   ;*get the Instruction Id
    InstructionDecision = ProcessReturnInfo<TZ.API.InstrDecision>   ;*get the Instruction decision
    TotalInstructionId = DCOUNT(InstructionId,@VM)
    
    FOR InstrCnt = 1 TO TotalInstructionId   ;*loop through Instruction Id
        TransInstrution<1,1,InstrCnt> = InstructionId<1,InstrCnt>:'-':InstructionDecision<1,InstrCnt>   ;*form an array InstructionId-InstructionDecision
    NEXT InstrCnt
    
    EB.LocalReferences.GetLocRef(Application, "TRANS.INSTR", TransInstrPos)         ;*get the local ref position of TRANS.INSTR
    
    BEGIN CASE
        CASE Decision EQ '' AND TransInstrPos                                  ;*if decision is null & local ref field available
            SaveRnew<FT.Contract.FundsTransfer.LocalRef,TransInstrPos> = ""    ;*blank out the local ref field
            EB.SystemTables.setDynArrayToRNew(SaveRnew)                        ;*set it back to R.NEW
            RETURN  ;*return from further processing
        CASE Decision NE '' AND TransInstrPos                                               ;*if decision is not null & local ref field available
            SaveRnew<FT.Contract.FundsTransfer.LocalRef,TransInstrPos> = TransInstrution    ;*assign the formed array to the local ref field
            EB.SystemTables.setDynArrayToRNew(SaveRnew)                                     ;*set it back to R.NEW
        CASE Decision EQ ''     ;*if decision is null, retrun from further processing
            RETURN
    END CASE
    
    IF Decision EQ 'PAY' THEN   ;*if the Stop decision is PAY
        EB.SystemTables.setText("TZ-TRANSACTION.STOP.PAY")  ;*raise override - Transaction Stopped due to Stop Instruction with decision Pay
    END ELSE
        EB.SystemTables.setText("TZ-TRANSACTION.STOP.RETURN") ;*raise override - Transaction Stopped due to Stop Instruction with decision Return
    END
    
    CurrNo = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.Override)    ;*get the Curr No
    EB.OverrideProcessing.StoreOverride(CurrNo) ;*call store override to update the override
    
RETURN
*-----------------------------------------------------------------------------
END
