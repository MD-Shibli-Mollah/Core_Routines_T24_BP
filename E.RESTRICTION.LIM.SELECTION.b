* @ValidationCode : MjotMzkyNzE0ODEyOkNwMTI1MjoxNTc5MDAzMDQxMDc2Om1hbmlzZWthcmFua2FyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMTMtMDU0MDozOTozOQ==
* @ValidationInfo : Timestamp         : 14 Jan 2020 17:27:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 39/39 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.RESTRICTION.LIM.SELECTION(RestrictionLimId)
*-----------------------------------------------------------------------------
* E.RESTRICTION.LIM.SELECTION is an enquiry selection routine which is used to
* select restriction limits associated with an utilisation limit.
*
* This api is used in NOFILE.RESTRICTION.LIMIT ss record, utilisation limit will be the input for the api.
* It will check the live file LI.RESTRICTION.LIMITS to get the list of restriction limits associated with the utilisation limit.
* Expired and future effective dated limits are skipped, only valid and effective limit ids are selected.
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
*            New enquiry api introduced to select restriction limits.
*
*-----------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
    $USING LI.RestrictionLimit
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.Limit
*** </region>
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>initialise local variables </desc>

    RestrictionLimId = ''
    DField = EB.Reports.getDFields()
    DLogicalOperands = EB.Reports.getDLogicalOperands()
    SelectionId = EB.Reports.getDRangeAndValue()
    LiRestrictionEr = ''
    LiRestrictionLimRec = ''
    TodayDate = EB.SystemTables.getToday()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>

    BEGIN CASE
        
        CASE SelectionId[1,2] EQ 'AA'   ;* If arrangement Id is passed
            EffectiveDate = TodayDate
            ArrangementId = SelectionId
            PropertyClass = "LIMIT"
            RArrLimit = ''
            RetError = ''
            AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, "", EffectiveDate, "", RArrLimit, RetError) ;* Get the Arrangement Limit condition setup
            RArrLimit = RAISE(RArrLimit)
            UtilLimKey = RArrLimit<AA.Limit.Limit.LimLimit> ;* Get the utilisation limit from AA.ARR.LIMIT record
            GOSUB SelectRestrictionLimit
        
        CASE SelectionId[1,2] EQ 'LI'   ;* If limit id is passed
            UtilLimKey = SelectionId
            GOSUB SelectRestrictionLimit
            
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SelectRestrictionLimit>
SelectRestrictionLimit:
*** <desc> </desc>

    LiRestrictionLimRec = LI.RestrictionLimit.LiRestrictionLimits.Read(UtilLimKey, LiRestrictionEr)
    RestrictionLimits = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstRestrictionLimitId>
    
    TotRstLim = DCOUNT(RestrictionLimits, @VM)
    FOR RstCnt = 1 TO TotRstLim
        RestrictionLim = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstRestrictionLimitId, RstCnt>
        RestrictionChkLim = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstCheckLimit, RstCnt>
        Expiry = LiRestrictionLimRec<LI.RestrictionLimit.LiRestrictionLimits.LiRstExpiryDate, RstCnt>
        IF RestrictionChkLim EQ 'Y' AND Expiry GE TodayDate THEN
            RestrictionLimId<-1> = RestrictionLim
        END
    NEXT RstCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------

END


