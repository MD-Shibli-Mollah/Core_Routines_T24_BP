* @ValidationCode : MTotMTc2MDU2Mzk3NTpJU08tODg1OS0xOjE0NzQ1MzQ3NDQ5MjY6aGFyaXByYXNhdGg6MTowOi01MzotMTpmYWxzZTpOL0E6REVWXzIwMTYwOS4x
* @ValidationInfo : Timestamp         : 22 Sep 2016 14:29:04
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : hariprasath
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -53
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201609.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE AA.Facility
    SUBROUTINE STANDING.ORDER.EXTRACT.API(InFieldName,InOldRecord,InNewRecord,InApplicationId,OutAccountNumber,OutSystemId,OutAdditionalInfo,OutErrorFlag)
*-----------------------------------------------------------------------------
*
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Its a extract API for the Inline TEC event type STANDING.ORDER-SERVICE.
*** This API will be called from TEC inline handoff routine for eatch account values
*** This API will do the following things
*** 1 . If the account number added with prefix/suffix then this needs to be removed and return back to handoff routine
*** 2 . To Pass the application spefific information like SystemId/ServiceLine/ServiceProduct etc to the handoff routine
*** </region>
*-----------------------------------------------------------------------------
* @uses  		: AA.Facility.TrimServiceAccount
* @access		: public
* @stereotype 	: subroutine
* @author 		: hariprasath@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param InFieldName			- Current processing field name (ACCOUNT.FROM/ACCOUNT.TO)
* @param InOldRecord			- Current old record after resolving mutli-values
* @param InNewRecord			- Current new record after resolving mutli-values
* @param InApplicationId		- Current application id

* Output
*
* @param OutAccountNumber		- Account number after removing prefix/suffix (N/A because no preffix/suffix)
* @param OutSystemId			- System id for this application (STO)
* @param OutAdditionalInfo<1>  	- Service line for this account  (N/A)
* @param OutAdditionalInfo<2>  	- Service group for this account (N/A)
* @param OutAdditionalInfo<3>  	- Service product for this account (N/A)
* @param OutErrorFlag			- Error flag to stop the current account processing

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 21/08/16 - Enhancement : 1791962
*			 Task : 1791958
*            API which is called from TEC Inline processing for the event type STANDING.ORDER-SERVICE
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.Facility


*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB SetAccountNumber				;* Remove prefix/suffix
    GOSUB SetSystemId					;* Application system id
    GOSUB SetAdditionalInfo				;* Service product,Service Line etc
    GOSUB SetErrorFlag					;* Skip flag
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetAccountNumber>
*** <desc>Removing prefix/suffix from account number</desc>
SetAccountNumber:

*** Its not required for this application! Clear account field.No prefix/suffix are added!

    BEGIN CASE
        CASE InFieldName EQ "0" OR InFieldName EQ "@ID"   				;* Account number in @id
             OutAccountNumber = ""
        	 AA.Facility.TrimAccount("STANDING.ORDER","@ID", InApplicationId, OutAccountNumber)
        CASE InFieldName EQ "CPTY.ACCT.NO"   ;* Application fields
        CASE 1														    ;* Local fields!
    END CASE

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetSystemId>
*** <desc>System Id for AC.ACCOUNT.LINK</desc>
SetSystemId:

    OutSystemId = "STO"    ;* Should have an entry in EB.SYSTEM.ID
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetAdditionalInfo>
*** <desc>Additional info. Current SERVICE.LINE,SERVICE.GROUP & SERVICE.PRODUCT </desc>
SetAdditionalInfo:
    
    ApplicationName  = "STANDING.ORDER"
    AccountFieldName = InFieldName			;* Current field name to be processed
    CurrentRecord    = RAISE(InNewRecord)			;* Current R.NEW record
    CurrentRecordId  = InApplicationId		;* Current ID.NEW
    ServiceDetails   = ""					;* Service details
    ReturnError      = ""
    AA.Facility.GetAccountKeywords(ApplicationName,AccountFieldName,CurrentRecord,CurrentRecordId,ServiceDetails,ReturnError)
    OutAdditionalInfo = ServiceDetails  ;* The values are seprated by @VM
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetErrorFlag>
*** <desc>If the current account process needs to be skiped then we need to set here</desc>
SetErrorFlag:

    OutErrorFlag = ""    ;* No need to Skip! Process all the request
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END






