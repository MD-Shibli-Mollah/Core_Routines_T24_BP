* @ValidationCode : MjotMTUzNDUwMjY4NDpDcDEyNTI6MTYwNTc5NDY2MTUzMzphbml0dGFwYXVsOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDoyODoyNA==
* @ValidationInfo : Timestamp         : 19 Nov 2020 19:34:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : anittapaul
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/28 (85.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-69</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Dormancy
SUBROUTINE AA.LOCAL.SENSITIVE.CUSTOMER(ArrangementId,EffectiveDate,ActivityId,ActivityRecord,CurrentDormancyStatus,CurrentDormancyDate,ResultsType,ResultsValue)
*-----------------------------------------------------------------------------
*** <region name= Synopsis of the method>
***
* Program Description
*
* This subroutine is a sample API to check whether the arrangement customer is sensitive or not. It will raise
* the error message to stop marking the account as dormant.
*
* Its will check the field CUSTOMER>CUSTOMER.RATING, the field value from 1 to 5 then its will raise the error message
*** </region>
*-----------------------------------------------------------------------------
* @uses			:
* @access		: public
* @stereotype 	: subroutine
* @author 		: hariprasath@temenos.com
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
* Input
*
* ArrangementId			- Arrangement Reference
* EffectiveDate			- Current activity effective date
* ActivityId			- Current activity id
* ActivityRecord		- Current activity record
* CurrentDormancyStatus	- Current dormancy status
* CurrentDormancyDate	- Current dormancy date
*
* OutPut
*
* ResultsType			- Result type (SUCCESS/ERROR)
* ResultsValue			- If result type is error then the error message needs to be raised

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 15/03/16 - Enhancement : 1224672
*			 Task : 1663961
*            Sample user API to attach into the dormancy condition
*
* 17/11/20 - Enhancement : 3930149
*            Task        : 4086531
*            Party related changes for microservices- Get the customer related details from party methods.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
***

    $INSERT I_CustomerService_Profile
    $USING AA.Framework
    $USING AA.Dormancy
    $USING MDLPTY.Party
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
***

    GOSUB Initialise
    GOSUB ValidateInputs            ;* Validate incomming values

    IF NOT(ReturnError) THEN
        GOSUB CheckCustomerRating  ;* Check customer rating
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise the varibles</desc>
Initialise:

    ResultsType		= "SUCCESS"  ;* Assumed default result is SUCCESS
    ResultsValue	= ""
    
    custId = ActivityRecord<AA.Framework.ArrangementActivity.ArrActCustomer> ;* Get the customer id
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= ValidateInputs>
*** <desc>Validate the input arguments</desc>
ValidateInputs:

    IF NOT(custId) THEN
        ReturnError = 1    ;* Handle exception!
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= CheckCustomerRating>
*** <desc>Customer rating with in the accepted range</desc>
CheckCustomerRating:
    
    SaveEtext = ""
    SaveEtext = EB.SystemTables.getEtext()    ;* Before calling MDAL API, Save EText to restore it later
    EB.SystemTables.setEtext("")  ;* set Error text to Null
    custProfile = ""
    custProfile = MDLPTY.Party.getCustomerProfile(custId)
    EB.SystemTables.setEtext(SaveEtext)
    Rating = custProfile<MDLPTY.Party.CustomerProfile.customerRatings.customerRating,1>  ;* Just check the last rating
    
    BEGIN CASE
        CASE Rating GE 1 AND Rating LE 5
            ResultsType      = "ERROR"
            ResultsValue     = "AA-SENSITIVE.CUSTOMER~":custId:"|":Rating  ;* Raise error ~ -> @FM & | -> @VM
        CASE 1
    END CASE
    
END
