* @ValidationCode : MjotMTc3ODQ0NjU0OTpDcDEyNTI6MTU5OTE0MDQwNjEwMzpqYWJpbmVzaDo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6OTQ6OTQ=
* @ValidationInfo : Timestamp         : 03 Sep 2020 19:10:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 94/94 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.LIM.UTIL.DETAILS(OutValues)
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : manisekarankar@temenos.com
* Program Name   : E.LIM.UTIL.DETAILS
* Module Name    : LI
* Component Name : LI_ModelBank
*-----------------------------------------------------------------------------
* Description    : No file routine, which would return the details of utilistation limits
*                  under validation limit which is linked to a Deal.
*                  Selection parameter can either be a validation limit id / Deal arrangement id.
*
*------------------------------------------------------------------------------
* Modification History :
*
* 03/01/2010 - Enhancement / Task
*              Nofile routine to return the details of utilisation limits
*              for a validation limit linked to a deal.
*
* 03/09/2020 - Defect 3945721 / Task 3948074
*              Get Facility Arr Id from drawings when facility is fully disbursed.
*
*-----------------------------------------------------------------------------
    $USING LI.ModelBank
    $USING LI.LimitTransaction
    $USING AA.Framework
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.Limit
    $USING LI.Config
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB Process
RETURN
*-----------------------------------------------------------------------------
Initialise:
***********
    OutValues = ''
    ValidationLimitId = ''
    UtilisationLimitIds = ''
    ArrangementId = ''
    EffectiveDate = ''
    PropertyClass = ''
    RLimitTxns = ''
    SelectionPos = ''
    SelectionId = ''
    RArrLimit = ""
    RetError = ""
    ErrorId = "LI-NOT.VALID.DEAL"
    MandErrId = "EB-MAND.INP.MISSING"
    
RETURN
*-----------------------------------------------------------------------------
Process:
********

    LOCATE "@ID" IN EB.Reports.getDFields()<1> SETTING SelectionPos THEN
        SelectionId= EB.Reports.getDRangeAndValue()<SelectionPos>
    END
    
* The selection id can either be an Arrangement ID or Limit Id.
    BEGIN CASE
        
        CASE NOT(SelectionId)           ;* Selection id is mandatory
            EB.Reports.setEnqError(MandErrId)
            
        CASE SelectionId[1,2] EQ 'AA'   ;* If arrangement Id is passed
            
            EffectiveDate = EB.SystemTables.getToday()
            ArrangementId = SelectionId
            PropertyClass = "LIMIT"
            AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, "", EffectiveDate, "", RArrLimit, RetError) ;* Get the Arrangement Limit condition setup
            RArrLimit = RAISE(RArrLimit)
            LimitId = RArrLimit<AA.Limit.Limit.LimValidationLimit> ;* Get the validation limit from AA.ARR.LIMIT record
            GOSUB ProcessValLimit
        
        CASE SelectionId[1,2] EQ 'LI'   ;* If limit id is passed
            LimitId = SelectionId
            GOSUB ProcessValLimit
        
        CASE 1                          ;* Neither arrangement nor limit, hence set error stating its not valid deal.
            EB.Reports.setEnqError(ErrorId)
            
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
ProcessValLimit:
****************
    LimitRec = LI.Config.Limit.Read(LimitId, Error)
    IF LimitRec<LI.Config.Limit.LimitType> EQ '2' THEN ;* Process only for validation limits
        GOSUB GetUtilisationLimits
    END ELSE
        EB.Reports.setEnqError(ErrorId)                ;* Only validation limit can be linked to a deal, hence if its not validation set error.
    END
    
RETURN
*-----------------------------------------------------------------------------
GetUtilisationLimits:
*********************
* Call LIMIT.CALC.INFO to fetch the utlisation limit details
    AddlInfo = ''
    TimeCodeCnt = ''
    LI.ModelBank.limitCalcInfo(LimitId, LimitRec, AddlInfo, TimeCodeCnt, ValidationDetails, UtilisationDetails, "", ReturnError) ;* Get the validation and utilization limit balances
    TotalUtilRecs = DCOUNT(UtilisationDetails,@FM)
    FOR Util = 1 TO TotalUtilRecs
        UtilRecord = ''
        UtilId = ''
        InternalAmount = ''
        OsAmount = ''
        AvailOrExcess = ''
        UtilRecord = RAISE(UtilisationDetails<Util>)
        UtilId = UtilRecord<LI.ModelBank.LiCalcUtilLimitId>          ;* Utilisation limit id
        InternalAmount = UtilRecord<LI.ModelBank.LiCalcInternalAmt>  ;* Internal amount
        OsAmount = UtilRecord<LI.ModelBank.LiCalcOs>                 ;* Total outstanding amount
        AvailOrExcess = UtilRecord<LI.ModelBank.LiCalcAvail>         ;* Available / excess amount
* Read the limitTxns of Utilisation limit to find if its facility based
        GOSUB ReadLimitTxns
* Process out array only if required utlisation is found
        IF ProcessOutArray THEN
            GOSUB FormOutArray
        END
    NEXT Util
    
RETURN
*-----------------------------------------------------------------------------
ReadLimitTxns:
**************
    ProcessOutArray = 0 ;* Descision to update the outArray
    FacilityArrId = '' ;* Facility Arrangement's id
    LimitRecord = ''
    CustomerId = ''
    Error = ''
    LimitRecord = LI.Config.Limit.Read(UtilId, Error)
    LimitCurrency = LimitRecord<LI.Config.Limit.LimitCurrency>
*
    limitTxnsId = UtilId
*
    LI.Config.LiGetLimitTxns(limitTxnsId, CustomerId, rLimitTxns, '', LimitTxnId, '', '')
*
    RecCount = ''
    RecCount = DCOUNT(rLimitTxns,@FM)
    TxnsRec = ''

    FOR TxnIndex = 1 TO RecCount
        TxnsRec = rLimitTxns<TxnIndex>
*  Process out array only its Facility contract based limit transaction.
        IF FIELD(TxnsRec,'\',8) EQ "FL" OR FIELD(TxnsRec,'\',8) EQ "AL" THEN
            ProcessOutArray = 1
            FacilityArrId = FIELD(TxnsRec,'\',1)
            IF FIELD(TxnsRec,'\',8) EQ "AL" THEN ;* IF Drawing get facility arrangement from the drawing
                DrawingArrId = FIELD(TxnsRec,'\',1)
                AA.Framework.GetArrangement(DrawingArrId, RArrangement, RetError)
                FacilityArrId = RArrangement<AA.Framework.Arrangement.ArrMasterArrangement>
            END
            RecCount = TxnIndex ;* If FL is found then reset count to the index so that loop breaks
        END
    NEXT TxnIndex
    
RETURN
*-----------------------------------------------------------------------------
FormOutArray:
*************

    OutValues<-1> = UtilId:"#":LimitCurrency:"#":InternalAmount:"#":OsAmount:"#":AvailOrExcess:"#":FacilityArrId
   
RETURN
*-----------------------------------------------------------------------------
END
