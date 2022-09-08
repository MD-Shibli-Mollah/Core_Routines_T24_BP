* @ValidationCode : MTotMzg0ODkxMDA5OlVURi04OjE0NzA5MjQ1OTk5NDA6bXVuaXlhc2FteTo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjA3LjE=
* @ValidationInfo : Timestamp         : 11 Aug 2016 19:39:59
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : muniyasamy
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.Services 
    SUBROUTINE AA.GET.ACCOUNT.STATUS(ArrangementId,AccountStatus,RetError) 
*------------------------------------------------------------------------------
** This method is used to get type and status of the account.

* In/out parameters:
* ArrangementNumber - String, IN
* ArrangmentID - String, IN
* AccountStatus - AccountStatusType (MV), OUT 
* RetError   - Return Error msg if any, OUT  

    $USING AA.Dormancy
    $USING AA.Services
    $USING AA.Framework 

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB initialise
    GOSUB process
   
    RETURN 
*------------------------------------------------------------------------------
process:

    GOSUB checkMandatory      ;*Check all mandatory inputs are available

    GOSUB checkAccountStatus  ;*Check the Status of the account requested

    RETURN

*-----------------------------------------------------------------------------
*** <region name= checkMandatroy>
checkMandatory:
*** <desc>Check all mandatory inputs are available </desc>
    
    RetError = ""
    
    IF ArrangementId EQ '' THEN
        RetError = "AA.FRM.ARRANGEMENT.ID.MISSING"
        AccountStatus= ''
    END
    
    RETURN 
*** </region>

*-----------------------------------------------------------------------------
*** <region name= checkAccountStatus>
checkAccountStatus:
*** <desc>Check the Status of the account requested </desc>

    AA.Framework.GetArrangement(ArrangementId, RArrangement,ArrangementErr) 
    
    IF NOT(ArrangementErr) THEN
     
       BEGIN CASE
    
            CASE RArrangement<AA.Framework.Arrangement.ArrArrStatus> = 'PENDING.CLOSURE' OR  RArrangement<AA.Framework.Arrangement.ArrArrStatus> = 'CLOSE'
                 AccountStatus<1> = 'Closed'  ;* Arrangment already closed
    
            CASE 1
                 RequestType = "CURRENT"
                 AA.Dormancy.DetermineDormancyStatus(RequestType,ArrangementId,EffectiveDate,DormancyStatus,DormancyDate,DormancyProcess)  ;* Determine dormancy status according to the request as current

                IF DormancyStatus THEN  
                  AccountStatus<1> = 'Inactive'  ;* Arrangment account is inactive
                END
        
      END CASE
      
   END ELSE
   
    RetError = ArrangementErr  ;* Arrangment is missing 
   
   END 
    
   RETURN
*** </region>

initialise:

    AccountStatus= ''  ;* Return argument 
    RArrangement = ""   ;* Arrangment Varaible intialised
    ArrangementErr = ""  ;* Error varaible

   RETURN 

END 

