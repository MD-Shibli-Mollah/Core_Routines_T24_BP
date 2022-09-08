* @ValidationCode : MjotODY0NDg0NTA2OkNwMTI1MjoxNTE4NjAxMzkxOTg4OmhhcnJzaGVldHRncjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2018 15:13:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SW.Schedules
SUBROUTINE CONV.SWAP.SCHEDULES.SAVE.201803(SwapId)
*-----------------------------------------------------------------------------
*
* Author: harrsheettgr@temenos.com
*-----------------------------------------------------------------------------
*
* Description: A new conversion is introduced to change the existing design of swap schedule save record
* As part of the change a multithreaded conversion job is introduced to carry out the conversion
* The record routine performs the select of swap schedules save record of a particular swap contract, loops & lowers each save record and finally writes all
* the lowered records into one swap schedule save record
*
* Existing Design: Multiple swap schedule save record for a single swap contract
*
* New Design : Single swap schedule save record for a single swap contact where each field value is seperate swap schedule record
* First multivalue value of a field will be the schedule record Id followed by its contents
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 10/01/18 - Enh 2388600  / Task 2388603
*            Swap schedule save structure change (Swap / SWUS) and Conversion
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
    
    $USING EB.DataAccess
    $USING EB.Service
    $USING SW.Schedules
    $USING SW.Contract
    
    $INSERT I_DAS.SWAP.SCHEDULES.SAVE
    
*** </region>
*-----------------------------------------------------------------------------
    
    GOSUB LockRecord ; *Lock the swap record so as to not allow any amendments to the contracts during the conversion processing
    GOSUB SelectSchedulesSave ; *Selects the SWAP.SCHEDULES.SAVE records of a particular swap contract
    GOSUB ReleaseRecord ;* Release the locked swap contract
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= SelectSchedulesSave>
SelectSchedulesSave:
*** <desc>Selects the SWAP.SCHEDULES.SAVE records of a particular swap contract </desc>
    
    SchedSaveIdList = dasSwapSchedulesSaveWithIdSortedCondition ;* Schedule Save Id List
    TheArgs = SwapId
    TableSuffix = ""
    EB.DataAccess.Das("SWAP.SCHEDULES.SAVE", SchedSaveIdList, TheArgs, TableSuffix)
    
    IF SchedSaveIdList NE "" THEN ;* If save record exists perform conversion
        GOSUB PerformConversion ; *Lowers the each schedule save record and stores it in a multivalue of final swap schedule save record
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= PerformConversion>
PerformConversion:
*** <desc>Lowers the each schedule save record and stores it in a multivalue of final swap schedule save record </desc>
    
    SchedSaveIdCount = DCOUNT(SchedSaveIdList, @FM)
    
    FOR SaveId = 1 TO SchedSaveIdCount
        OldScheduleSaveId = SchedSaveIdList<SaveId> ;* Get the schedule save id from the schedule save id list
        OldSchedSaveRec = SW.Schedules.SwapSchedulesSave.Read(OldScheduleSaveId, SchedErr) ;* Read the schedule save record
        
        NewScheduleSaveId = FIELD(OldScheduleSaveId,'.',1):"-BACKUP" ;* As per new design, the scheudule save id will be the <Contract_Id>-BACKUP, inside which all schedule records are stored
        SchedSaveRec = SW.Schedules.SwapSchedulesSave.Read(NewScheduleSaveId, SaveErr) ;* Read with new id to check if the record already exists
        
        IF SaveErr THEN ;* If no record exists, place the schedule save record in very first field value
            SchedSaveRec<1,1> = OldScheduleSaveId
            SchedSaveRec<1,2> = LOWER(OldSchedSaveRec)
        END ELSE ;* If record exists, append the schedule save record to the last available field value
            NewFieldvalue = DCOUNT(SchedSaveRec, @FM) + 1 ;* position of field value to place the schedule save record
            SchedSaveRec<NewFieldvalue> = OldScheduleSaveId:@VM:LOWER(OldSchedSaveRec)
        END
       
        SW.Schedules.SwapSchedulesSave.Write(NewScheduleSaveId, SchedSaveRec) ;* Write the new record
        SW.Schedules.SwapSchedulesSave.Delete(OldScheduleSaveId) ;* Delete the old record
        
    NEXT SaveId
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= LockRecord>
LockRecord:
*** <desc>Lock the swap record so as to not allow any amendments to the contracts during the conversion processing </desc>
    
    Suffix = "NAU"
    Retry = ""
    ReadError = ""
    Record = ""
    SW.Contract.SwapLock(SwapId, Record, ReadError, Retry, Suffix) ;* Performs ReadU to the swap contract
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ReleaseRecord>
ReleaseRecord:
*** <desc>Release the locked swap contract </desc>
    
    FFileid = ""
    EB.DataAccess.FRelease("F.SWAP", SwapId, FFileid) ;* Release the obtained lock
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END



