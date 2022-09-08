* @ValidationCode : MjoxMDMwODM0MDYxOkNwMTI1MjoxNTMxOTE5ODI1MzY1OnJhamFrOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDYuMjAxODA1MTktMDA1ODoyMDoxNg==
* @ValidationInfo : Timestamp         : 18 Jul 2018 18:47:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rajak
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/20 (80.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.20180519-0058
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE TZ.Contract
SUBROUTINE TRANS.INSTR.EXTRACT.API(InFieldName,InOldRecord,InNewRecord,InApplicationId,OutAccountNumber,OutSystemId,OutAdditionalInfo,OutErrorFlag)
*-----------------------------------------------------------------------------
*
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Its a extract API for the Inline TEC event type TZ.TRANSACTION.STOP.INSTRUCTION-SERVICE.
*** This API will be called from TEC inline handoff routine for eatch account values
*** This API will do the following things
*** 1 . If the account number added with prefix/suffix then this needs to be removed and return back to handoff routine
*** 2 . To Pass the application spefific information like SystemId/ServiceLine/ServiceProduct etc to the handoff routine
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param InFieldName            - Current processing field name (ACCOUNT.FROM/ACCOUNT.TO)
* @param InOldRecord            - Current old record after resolving mutli-values
* @param InNewRecord            - Current new record after resolving mutli-values
* @param InApplicationId        - Current application id

* Output
*
* @param OutAccountNumber       - Account number after removing prefix/suffix (N/A because no preffix/suffix)
* @param OutSystemId            - System id for this application (CI)
* @param OutAdditionalInfo<1>   - Service line for this account  (N/A)
* @param OutAdditionalInfo<2>   - Service group for this account (N/A)
* @param OutAdditionalInfo<3>   - Service product for this account
* @param OutErrorFlag           - Error flag to stop the current account processing

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 07/16/18 - Task : 2679254
*            API which is called from TEC Inline processing for the event type TZ.TRANSACTION.STOP.INSTRUCTION-SERVICE
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING TZ.Contract
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB SetAccountNumber              ;* Remove prefix/suffix
    GOSUB SetSystemId                   ;* Application system id
    GOSUB SetAdditionalInfo             ;* Service product,Service Line etc
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetAccountNumber>
*** <desc>Removing prefix/suffix from account number</desc>
SetAccountNumber:

*** Its not required for this application! Clear account field.No prefix/suffix are added!

    BEGIN CASE
        CASE InFieldName EQ "ACCOUNT"                                ;* Application fields
            OutAccountNumber = InNewRecord<1,TZ.Contract.TransactionStopInstruction.TsiAccount>
        CASE 1
            NULL ;* Local fields!
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetSystemId>
*** <desc>System Id for AC.ACCOUNT.LINK</desc>
SetSystemId:

    OutSystemId = "TZ"    ;* Should have an entry in EB.SYSTEM.ID
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetAdditionalInfo>
*** <desc>Additional info. Current SERVICE.LINE,SERVICE.GROUP & SERVICE.PRODUCT </desc>
SetAdditionalInfo:
    
    OutAdditionalInfo = ''  ;* The values are seprated by @VM
    IF EB.SystemTables.getDynArrayFromROld() THEN
        OutAdditionalInfo<1,3> = 'AMEND'
    END ELSE
        OutAdditionalInfo<1,3> = 'NEW'
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END



