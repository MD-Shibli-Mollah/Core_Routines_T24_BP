* @ValidationCode : MToxMzgwODQ2MTQyOklTTy04ODU5LTE6MTQ3MjgyOTc5MjE2ODpoYXJpcHJhc2F0aDoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTYwOC4w
* @ValidationInfo : Timestamp         : 02 Sep 2016 20:53:12
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : hariprasath
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE AA.Facility
    SUBROUTINE AC.CASH.POOL.EXTRACT.API(InFieldName,InOldRecord,InNewRecord,InApplicationId,OutAccountNumber,OutSystemId,OutAdditionalInfo,OutErrorFlag)
*-----------------------------------------------------------------------------
*
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Its a extract API for the Inline TEC event type AC.CASH.POOL-SERVICE.
*** This API will be called from TEC inline handoff routine for eatch account values
*** This API will do the following things
*** 1 . If the account number added with prefix/suffix then this needs to be removed and return back to handoff routine
*** 2 . To Pass the application spefific information like SystemId/ServiceLine/ServiceProduct etc to the handoff routine
*** </region>
*-----------------------------------------------------------------------------
* @uses  		: AA.Facility.GetServiceAccountDetails
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
* @param OutSystemId			- System id for this application (ACCPR)
* @param OutAdditionalInfo<1>  	- Service line for this account  (N/A)
* @param OutAdditionalInfo<2>  	- Service group for this account (AC.CASH.POOL>AC.SWEEP.TYPE>SWEEP.STYLE)
* @param OutAdditionalInfo<3>  	- Service product for this account (AC.CASH.POOL>RULE)
* @param OutErrorFlag			- Error flag to stop the current account processing

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
*
*
* 21/08/16 - Enhancement : 1791962
*			 Task : 1791958
*            API which is called from TEC Inline processing for the event type AC.CASH.POOL-SERVICE
*
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
        CASE InFieldName EQ "0" OR InFieldName EQ "@ID"   			;* Account number in @id
        CASE InFieldName EQ "LINK.ACCT"								;* Application fields
        CASE 1														;* Local fields!
    END CASE

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetSystemId>
*** <desc>System Id for AC.ACCOUNT.LINK</desc>
SetSystemId:

    OutSystemId = "ACCPR"    ;* Should have an entry in EB.SYSTEM.ID
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetAdditionalInfo>
*** <desc>Additional info. Current SERVICE.LINE,SERVICE.GROUP & SERVICE.PRODUCT </desc>
SetAdditionalInfo:
    
    ApplicationName  = "AC.CASH.POOL"
    AccountFieldName = InFieldName			;* Current field name to be processed
    CurrentRecord    = RAISE(InNewRecord)	;* Current R.NEW record
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


