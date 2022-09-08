* @ValidationCode : MjotMTc5OTkyOTI2MzpDcDEyNTI6MTU1MzY4NjQyMTMyMzpzbWl0aGFiaGF0Ojc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDEuMjAxODEyMjMtMDM1MzoxMjM6MTIx
* @ValidationInfo : Timestamp         : 27 Mar 2019 17:03:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 121/123 (98.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-207</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Services
SUBROUTINE AA.GET.ACCOUNT.RESTRICTION(ArrangementId,TransactionCode,TransactionAmount,EffectiveDate,RestrictionType,RestrictionDesc,RestrictionErrOvg,RetError)
*------------------------------------------------------------------------------
** This method is used to find the Activity restriction present in the arrangement account
*
* In/out parameters:
* ArrangementId - String. Contains, arrangement number,
* TransactionCode - debit and credit txn code.
* TransactionAmount - String, IN, Contains the current transaction amount
* EffectiveDate - IN, Transaction date
* RestrictionType -INOUT, DEBIT/CREDIT
* RestrictionDesc - Activity Restriction description, INOUT , If RestrictionDesc is set, Error or Override ids corresponding to Error and Override Messages are returned
* RestrcitionOverrideError - Error /Warning, OUT
* RetError - Main error message if any
*
* Modification History
*
* 26/02/19 - Task  :3009925
*            Enhancement : 3009919
*            Changes made to return the error or override ids corresponding to Error and Override Messages if RestrictionDesc is set.
*
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.Services
    $USING AA.ActivityRestriction
    $USING EB.Display
    $USING EB.ErrorProcessing
    $USING EB.Interface
    $USING EB.OverrideProcessing
    $USING EB.SystemTables

*------------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
    
RETURN
*------------------------------------------------------------------------------
process:
 
    GOSUB checkMandatory      ;*Check all mandatory inputs are available
    
    IF NOT(RetError) THEN  ;* Need not execute further If there is any mandaory input missing
    
        GOSUB GetActivityId     ;* Get the Activityid
        
        GOSUB loadCommonInitialise  ;* load Activity common

        GOSUB checkRestriction    ;*Check the restriction present in Arrangement Account
        
        GOSUB RestoreCommonInitialise ;* Initialise the loaded common
    END
    
*
RETURN
 
*-----------------------------------------------------------------------------
*** <region name= checkMandatroy>
checkMandatory:
*** <desc>Check all mandatory inputs are available </desc>

    IF ArrangementId EQ '' OR TransactionCode EQ '' THEN
        RetError = 'AA.RTN.MANDATORY.INPUT.MISSING'
        RestrictionType = ''
        RestrictionDesc = ''
        RestrictionErrOvg = ''
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Activity Id>
GetActivityId:

    AA.Framework.GetTransactionActivity("",ArrangementId, EffectiveDate, TransactionCode,RestrictionType, ActivityId,"")  ;* It returns the Activity id based on the transaction code passed
    
RETURN

*-----------------------------------------------------------------------------
*** <region name= checkRestriction>
checkRestriction:
*** <desc>Check the restriction present in Account restriction condition </desc>

    AA.ActivityRestriction.EvaluateActivityRestriction(ArrangementId,"",EvaluationIndicator,EffectiveDate,FailDescription,FailLevel,FailMsg) ;*  Check the Account has restrictions
    
    SaveText = EB.SystemTables.getText()          ;* Save the TEXT common variable
    GOSUB getRestrictDetails        ;*Get the restriction details
    EB.SystemTables.setText(SaveText)             ;* Restore the TEXT common variable
    
    GOSUB SetRestrictDetails        ;* Assign the restrict details to send out.

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= getRestrictDetails>
getRestrictDetails:
*** <desc>Get the restriction details </desc>
*  IF restrictions is found in account then get details of the restriction  by calling this subflow

    TotalCount = DCOUNT(FailLevel,@FM)  ;*

    FOR ErrorCount = 1 TO TotalCount

        BEGIN CASE

            CASE FailLevel<ErrorCount> EQ "OVERRIDE"
                OverrideMessage = RAISE(FailMsg<ErrorCount>)
                OverrideId = OverrideMessage<1>      ;* Contains Override Id
                EB.SystemTables.setText(OverrideMessage)         ;* Load the message into TEXT common variable
                EB.OverrideProcessing.BuildOverrideText()     ;* Call to get the override message
                ThisOverrideMsg = EB.SystemTables.getText()      ;* Store the override message from override record
* Exception Handling to verify whether override message is set as an Error
                EB.Display.Txt(ThisOverrideMsg) ;* override formed with required parameter
                GOSUB getOverrideDetails
            CASE FailLevel<ErrorCount> EQ "ERROR"
                ErrorMessage = RAISE(FailMsg<ErrorCount>)
                ErrorIds<-1> = ErrorMessage ;* Get the Error Id
                EB.ErrorProcessing.GetErrorMessage(ErrorMessage) ;* Get the error message form eb.error
                EB.Display.Txt(ErrorMessage)
                ErrorDescription<-1> = ErrorMessage
                Errorlevel<-1> = "Error"
                
        END CASE

    NEXT ErrorCount

RETURN


*** </region>
*-----------------------------------------------------------------------------
 
SetRestrictDetails:

;* Return the restriction details
 
    RestrictionDesc = ErrorDescription
    
    IF OverrideDescription THEN
        RestrictionDesc<-1> = OverrideDescription
    END
    
    GOSUB GetErrorOverrideIds ;* Return the Error and Override Ids for corresponding Error and Override Messages if ErrorOverrideIdIndicator is set
    
    RestrictionErrOvg = Errorlevel
    IF Overridelevel THEN
        RestrictionErrOvg<-1> = Overridelevel
    END
    
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetErrorOverrideIds>
*** <desc> Return the Error and Override Ids for corresponding Error and Override Messages if ErrorOverrideIdIndicator is set </desc>
GetErrorOverrideIds:
    
    IF ErrorOverrideIdIndicator THEN ;* If ErrorOverrideIdIndicator is set return the Error and Override Ids
        
        IF ErrorIds THEN
            ErrorOverrideIds = ErrorIds ;* Get Error Ids to map with respective Error Ids to return in RestrictionDesc
        END
        IF OverrideIds THEN
            ErrorOverrideIds<-1> = OverrideIds ;* Get Override Ids to map with respective Override Messages to return in RestrictionDesc
        END
        
        ErrorOverrideCount = DCOUNT(RestrictionDesc,@FM) ;* Get the count of Error and Override Messages
        FOR ErrorOverrideCnt = 1 TO ErrorOverrideCount
            RestrictionDesc<ErrorOverrideCnt,-1> = ErrorOverrideIds<ErrorOverrideCnt> ;* Return the Error and Override Ids
        NEXT ErrorOverrideCnt
    END
    
RETURN

*----------------------------------------------------------------------------
RestoreCommonInitialise:

*Initialise the common variables

    RequestType = "Initialise"
    AA.Framework.SetActivityWrapperCommon("","",RequestType,"","")

RETURN

*-----------------------------------------------------------------------------
loadCommonInitialise:

*Load the Arrangement related common variables
 
    RequestType = "Load"
    AA.Framework.SetActivityWrapperCommon(ArrangementId,EffectiveDate,RequestType,ActivityId,TransactionAmount)

RETURN
*------------------------------------------------------------------------------
initialise:
*
    ActivityId = ""        ;* Activity name corresponding to the transaction code
    RequestType = ""      ;* Determine to initialise/Load the common variables
    EvaluationIndicator = 1    ;* This is set to indicate there is a trigger from Wrapper rotuine.
    Overridelevel = ""  ;*  To indicate override is warning
    Errorlevel = ""     ;*  To indicate it is Error
    ErrorOverrideIdIndicator = "" ;* To Indicate Error and Override Ids to be returned in RestrictionDesc
    ErrorIds = "" ;* Holds the Error Ids
    OverrideIds = "" ;* Holds the Override Ids
    ErrorOverrideIds = "" ;* Holds both Error and Override Ids to map with respective Error and Override Messages to return in RestrictionDesc
    
    IF RestrictionDesc THEN;* If RestrictionDesc is set , ErrorOverrideIdIndicator is set
        ErrorOverrideIdIndicator = 1 ;* This is set to indicate routine will return the equivalent error and Override Id
        RestrictionDesc = "" ;* Initialise RestrictionDesc
    END
    
RETURN

*------------------------------------------------------------------------------
getOverrideDetails:
*** <desc>Gets the override record. </desc>

    Roverride = ''   ;* Holds Override record
    OverrideEr = ''  ;* Holds Error msg if the record does not exist
    Roverride = EB.OverrideProcessing.Override.CacheRead(OverrideId, OverrideEr)
    ThisOverrideType = ''

    IF NOT(OverrideEr) THEN

        ThisTypes = RAISE(Roverride<EB.OverrideProcessing.Override.OrType>)          ;* Get all of 'this' override's types.
        ThisChannels = RAISE(Roverride<EB.OverrideProcessing.Override.OrChannel>)    ;* Get all of 'this' override's channels.
        
        OfsSourceRec = EB.Interface.getFOfsSource()
        IF OfsSourceRec THEN
            OvrPos = ""
            CurrentChannel = OfsSourceRec<EB.Interface.OfsSource.OfsSrcChannel>   ;* Get the current channel being used. If there is one.
            LOCATE CurrentChannel IN ThisChannels SETTING OvrPos THEN
                ThisOverrideType = ThisTypes<OvrPos>
            END ELSE
                ThisOverrideType = ThisTypes<1>          ;* Use the first multivalue as this is the default override.
            END
        END ELSE
            ThisOverrideType = ThisTypes<1>         ;* Use the first multivalue as this is the default override.
        END

    END ELSE ;* if there wasnt a read error
        ThisOverrideMsg = OverrideId
    END

    BEGIN CASE
        CASE ThisOverrideType = "Error"
            ErrorDescription<-1> = ThisOverrideMsg
            Errorlevel<-1> = "Error"
            ErrorIds<-1> = OverrideId ;* Get the Override Id
        CASE ThisOverrideType MATCHES "Warning":@VM:"Message":@VM:""
            Overridelevel<-1> = "Warning"
            OverrideDescription<-1> = ThisOverrideMsg
            OverrideIds<-1> = OverrideId ;* Get the Override Id
    END CASE

RETURN
*----------------------------------------------------------------------------------------
END
