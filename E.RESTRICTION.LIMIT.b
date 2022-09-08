* @ValidationCode : MjoxMTM4OTY5NTAzOkNwMTI1MjoxNTc1NDM5MTU4OTc5OmphYmluZXNoOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTEuMjAxOTEwMjQtMDMzNTo0OTo0OQ==
* @ValidationInfo : Timestamp         : 04 Dec 2019 11:29:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 49/49 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191024-0335
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.RESTRICTION.LIMIT
*-----------------------------------------------------------------------------
* E.RESTRICTION.LIMIT is an enquiry routine which is used to get restriction limit details.
*
* This api is used in the enquiry RESTRICTION.LIMIT, it is used to get the restriction limit details.
* Restriction limit key will be the input for this api.
* Following details are required for restriction limit enquiry,
*
* Restriction Id    -   Id of Restriction limit
*
* Currency          -   Restriction Limit currency
*
* Expiry Date       -   Restriction limit expiry date
*
* Limit Amount      -   Restriction limit internal amount
*
* Available Amount  -   Restriction available amount
*
* Outsanding Amount -   Restriction total outstanding amount
*
* Context Name      -   Context condition associated with the restriction limit
*
* Context Value     -   Context values associated with the restriction limit
*-----------------------------------------------------------------------------
* @uses LI.RestrictionLimit
* @uses EB.SystemTables
* @uses EB.Reports
* @package LI.ModelBank
* @class E.RESTRICTION.LIM.SELECTION
* @stereotype enquiry
* @author jabinesh@temenos.com
*** </region>
*-----------------------------------------------------------------------------------------------------------
* Modification History :
*
* 27/11/19 - Enhancement  33464117 / Task 3464066
*            New enquiry api introduced to get restriction limit details.
*
*-----------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
    $USING LI.RestrictionLimit
    $USING EB.Reports
    $USING LI.Config
    $USING EB.SystemTables
*** </region>
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>initialise local variables </desc>

    RestrictionId = EB.Reports.getId()  ;* Get Restriction limit key from @ID
    EB.Reports.setRRecord('')
    RestrictionEr = ''
    LimRec = ''
    LiRestrictionEr = ''
    LiRestrictionLimRec = ''
    ContextName = ''
    ContextValue = ''
    rRecord = ''
    FinContextName = ''
    FinContextValue = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>

    GOSUB GetLimitDetails ; * Get details from LIMIT record

    GOSUB GetContextDetails ; * Get details from LI.RESTRICTION.LIMITS record

    GOSUB FormEnquiryDeatil ; * Form enquiry details

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetLimitDetails>
GetLimitDetails:
*** <desc> </desc>
*** Read the limit with restriction key and Get restriction details from limit record

    LimRec = LI.Config.Limit.Read(RestrictionId, RestrictionEr) ;* Get Restriction limit record
    Ccy = LimRec<LI.Config.Limit.LimitCurrency>
    Expiry = LimRec<LI.Config.Limit.ExpiryDate>
    LimAmount = LimRec<LI.Config.Limit.InternalAmount>
    AvailAmt = LimRec<LI.Config.Limit.AvailAmt>
    TotOs = LimRec<LI.Config.Limit.TotalOs>
    UtilKey = LimRec<LI.Config.Limit.UtilParentKey>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetContextDetails>
GetContextDetails:
*** <desc> </desc>
*** Context details for the restriction limit are taken from LI.RETRICTION.LIMITS record of parent utilisation limit.

    LiRestrictionLimRec = LI.RestrictionLimit.LiRestrictionLimits.Read(UtilKey, LiRestrictionEr)
    ContextName = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstContextName>
    LOCATE RestrictionId IN LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstRestrictionLimitId,1> SETTING RstPos THEN
        ContextValue = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstContextValue, RstPos>
        ContextValue = RAISE(ContextValue)
    END
   
*** When the context value is not available for a condition, that condition should be removed from the restriction detail
    TotContextName = DCOUNT(ContextName, @VM)
    FOR ContextCnt = 1 TO TotContextName
        IF ContextValue<1, ContextCnt> THEN
            FinContextName<1,-1> = ContextName<1,ContextCnt>
            FinContextValue<1,-1> = ContextValue<1,ContextCnt>
        END
    NEXT ContextCnt

*** In LI.RESTRICTION.LIMITS multiple values for a conditions are stored in an array with '*' seperated,
*** these values should be stored in sub value positions.
    FinContextValue = CHANGE(FinContextValue,'|',@SM)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FormEnquiryDeatil>
FormEnquiryDeatil:
*** <desc> </desc>
*** Limit record details are store in a single array with '~' seperator, context name and
*** contex value are multi-value fields, therefore these details are store in seperate
*** muti-value positions in R.RECORD.
*
*** R.RECORD updated with below format,
*** R.RECORD<1> = RESTRICTION.LIM.KEY ~ LIMIT.CURRENCY ~ EXPIRY.DATE ~ INTERNAL.AMT ~ AVAIL.AMT ~ TOTAL.OS
*** R.RECORD<2> = CONTEXT.NAME
*** R.RECORD<3> = CONTEXT.VALUE
*
*** EXAMPLE,
*** R.RECORD<1> = LI999093576JZR1 ~ USD ~ 20191203 ~ 10000 ~ 8000 ~ -2000
*** R.RECORD<2> = CONTEXT.NAME.1 @VM CONTEXT.NAME.2 @VM CONTEXT.NAME.3
*** R.RECORD<3> = CONTEXT.VALUE.1 @VM CONTEXT.VALUE.2.1 @SM CONTEXT.VALUE.2.2 @VM CONTEXT.VALUE.3

    rRecord<1> = RestrictionId:'~':Ccy:'~':Expiry:'~':LimAmount:'~':AvailAmt:'~':TotOs
    rRecord<2> = FinContextName
    rRecord<3> = FinContextValue
    EB.Reports.setVmCount(DCOUNT(FinContextName, @VM))
    EB.Reports.setSmCount(DCOUNT(FinContextValue,@SM))
    EB.Reports.setRRecord(rRecord)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END



