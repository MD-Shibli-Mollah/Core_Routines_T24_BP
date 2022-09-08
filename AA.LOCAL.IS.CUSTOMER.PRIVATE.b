* @ValidationCode : MjotMTQyMTQwMzcxODpDcDEyNTI6MTU0NzAzMzQ5NjM1NDpsc3VtYW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5Oi0xOi0x
* @ValidationInfo : Timestamp         : 09 Jan 2019 17:01:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lsuman
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Dormancy
SUBROUTINE AA.LOCAL.IS.CUSTOMER.PRIVATE(ArrangementId,EffectiveDate,ActivityId,ActivityRecord,CurrentDormancyStatus,CurrentDormancyDate,ResultsType,ResultsValue)
*-----------------------------------------------------------------------------
*** <region name= Synopsis of the method>
***
* Program Description
*
* This subroutine is a sample API to check whether the arrangement customer is private or not. If CUSTOMER.SECURITY>CUSTOMER.TYPE is set
* then the customer is private.
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
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
***

    $USING AA.Framework
    $USING AA.Dormancy
    $USING SC.Config
    $USING EB.API

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
***

    GOSUB Initialise
    GOSUB ValidateInputs            ;* Validate incomming values

    IF SC.INSTALLED AND NOT(ReturnError) THEN
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
    SC.INSTALLED = ""
    EB.API.ProductIsInCompany("SC", SC.INSTALLED)
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

    ErrorMessage = ""
    RCustomerSecurity = SC.Config.CustomerSecurity.Read(custId, ErrorMessage)     ;* Get the customer security record
    CustomerType = RCustomerSecurity<SC.Config.CustomerSecurity.CscCustomerType>  ;* Get the customer type

    IF CustomerType THEN
        ResultsType		= "ERROR"
        ResultsValue	= "AA-CUSTOMER.IS.PRIVATE"
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
