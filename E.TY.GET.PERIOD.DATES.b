* @ValidationCode : Mjo1NzUxMTA1NTc6Q3AxMjUyOjE1MDk0NDgyNjkxODg6Ym92aXlhOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDguMDo4NDo4NA==
* @ValidationInfo : Timestamp         : 31 Oct 2017 16:41:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : boviya
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 84/84 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE TY.Reports
SUBROUTINE E.TY.GET.PERIOD.DATES(OUT.DATES)
*----------------------------------------------------------------------------------
* Enquiry routine used in TY.GET.PERIOD.DATES enquiry to fetch the dates for
* pre-defined period by considering the holiday settings in T24
* Parameters Definition:
* OUT.DATES - Outgoing parameter, will contain the period and the corresponding dates for the given currencies which are given at the selection.
*----------------------------------------------------------------------------------
*   Modification History :
*
* 04/09/17 - Enh 2243600 / Task 2243603
*            A nofile enquiry for Calendar functionality - Block
*
* 11/10/17 - Def 2303171 / Task 2303268
*            Displacement to be passed as 1D to retrieve the TN date so as to get in sync with IN2FOREXD
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Config
    $USING FX.Config
    $USING TY.Reports
*** </region>
*-----------------------------------------------------------------------------
    
    GOSUB Initialise ; *Initialise the required varaibles
    GOSUB Process ; *Main process to build return array
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
*** <desc>Initialise the required varaibles </desc>
    
    YIdList = ''
    Sel_Period = ''
    Sel_StartDate = ''
    Sel_CcyPair = ''
    SpotList = 'T':@FM:'1D':@FM:'S':@FM:'SN' ;* Pre-defined list of spot periods
    SpotListCount = DCOUNT(SpotList,@FM) ;* Count of spot list
    FwdList = '7D':@FM:'14D':@FM:'21D':@FM:'28D':@FM:'1M':@FM:'3M':@FM:'6M':@FM:'9M':@FM:'1Y':@FM:'2Y':@FM:'5Y':@FM:'10Y' ;* Pre-defined list of forward periods
    PeriodList = SpotList :@FM: FwdList ;* Pre-defined period list
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc>Main process to build return array </desc>
    
    GOSUB GetSelectionCriteria ;* Gets the user defined selection criteria
    IF Sel_Period NE '' THEN
        GOSUB CheckPeriod ;* Checks whether the given period is a valid selection value
        IF ValidSelection EQ '' THEN
            RETURN
        END
    END ELSE
        PeriodLen = DCOUNT(PeriodList,@FM) ;* Total length of period list is considered when there is user-specified selection for PERIOD
    END
    
    GOSUB TriggerWorkingDay ; *Triggers Working Day
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetSelectionCriteria>
GetSelectionCriteria:
*** <desc>Gets the user defined selection criteria </desc>
    
    CcyPairPos = ''
    LOCATE "CCY.PAIR.OR.CCY" IN EB.Reports.getDFields()<1> SETTING CcyPairPos THEN ;* Gets the selection values for CCY.PAIR.OR.CCY
        Sel_CcyPair = EB.Reports.getDRangeAndValue()<CcyPairPos>
    END
    
    PeriodPos = ''
    LOCATE "PERIOD" IN EB.Reports.getDFields()<1> SETTING PeriodPos THEN ;* Gets the selection values for PERIOD
        Sel_Period = EB.Reports.getDRangeAndValue()<PeriodPos>
    END
    
    StartDatePos = ''
    LOCATE "START.DATE" IN EB.Reports.getDFields()<1> SETTING StartDatePos THEN ;* Gets the selection values for START.DATE
        Sel_StartDate = EB.Reports.getDRangeAndValue()<StartDatePos>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckPeriod>
CheckPeriod:
*** <desc>Checks whether the given period is a valid selection value </desc>
    
    ValidSelection = '' ;* flag to check whether the given period value is a valid value
    ListPos = ''
    
    LOCATE Sel_Period IN PeriodList<1> SETTING ListPos THEN
        ValidSelection = 1
        PeriodLen = ListPos ;* Threshold position of period list until which working day should be triggered to calculate the working day
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= TriggerWorkingDay>
TriggerWorkingDay:
*** <desc>Triggers Working Day </desc>
    
    SpotDate = ''
    Displacement = ''
    restDate = ''
    daysSinceSpot = ''
    CalType = 'S'
    Sign = ''
    ForBackInd = ''
    RegionCd = ''
    ReturnList = ''
    
    GOSUB CallExtractCountryCode ; *Triggers the TY.EXTRACT.CURRENCY.CODE api
    
    FOR PeriodNo = 1 TO PeriodLen
        ReturnDate = ''
        ReturnDisplacement = ''
        ReturnCode = ''
        Displacement = PeriodList<PeriodNo>
        BEGIN CASE
            CASE PeriodNo GT SpotListCount AND Sel_StartDate NE '' ;* Logically for MM, the start date given will be the value date
                StartDate = Sel_StartDate ;* value date which is passed from the enquiry to consider this as a start date
            CASE PeriodNo GT SpotListCount AND Sel_StartDate EQ '' AND CcyPairFlag ;* For forward periods of FX
                SpotDate = ReturnList<SpotListCount-1> ;* To retrieve the spot date
                StartDate = FIELD(SpotDate,'*',2)
            CASE 1 ;* for all the spot periods irrespective of any application
                StartDate = EB.SystemTables.getToday()
        END CASE
        ST.Config.WorkingDay(CalType, StartDate, Sign, Displacement, ForBackInd, CountryCode, RegionCd, ReturnDate, ReturnCode, ReturnDisplacement)
        GOSUB DoSoftMapping ;* Soft Map the displacement for enquiry display 
        
        ReturnList<-1> = Displacement: '*' :ReturnDate
    NEXT PeriodNo
    
    OUT.DATES = ReturnList ;* Return list array containing the displacement and the dates
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetCountryCodes>
CallExtractCountryCode:
*** <desc>Triggers the TY.EXTRACT.CURRENCY.CODE api </desc>
    
    CpairOrCcy = Sel_CcyPair ;* User selection
    CountryCode = ''
    CcyPairFlag = ''
    Reserved1 = ''
    Reserved2 = ''
    TY.Reports.ExtractCountryCode(CpairOrCcy, CountryCode, CcyPairFlag, Reserved1, Reserved2)
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoSoftMapping>
DoSoftMapping:
*** <desc>Soft Map the displacement for enquiry display </desc>
    
    IF Displacement EQ "1D" THEN
        Displacement = "TN" ;* Soft map 1D to TN and this is not initially mapped in spotlist so as to get in line with IN2FOREXD soft mapping
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END


