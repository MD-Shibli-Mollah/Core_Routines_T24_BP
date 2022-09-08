* @ValidationCode : MjotMTU4MTM4Mjk1MjpDcDEyNTI6MTYwNjI4MjI1Mjc4NTpnaWJyYW5qYWJiYXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkxOS0wNDU5OjgzOjc2
* @ValidationInfo : Timestamp         : 25 Nov 2020 11:00:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gibranjabbar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 76/83 (91.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.GET.CURRENT.ACCR.DETS
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to return interest accrual details for the current period
*
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author divyasaravanan@temenos.com
*
**

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*
* 05/11/20 - Task : 4062192
*            Enhancement : 3164925
*            Conversion routine to get accrual details for the current period for the given accrual id
*
* 20/11/20 - Task : 4092097
*            Defect : 4089338
*            Fix for multiple dated entries listed under skim
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Interest
    $USING AF.Framework
    $USING EB.SystemTables
    $USING EB.API
    
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB Initialise
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*----------

    AccrualId = EB.Reports.getOData()
    
    RAccrualDetails = ''
    ReturnError = ''
    RAccrualDetails= AA.Interest.InterestAccrualsWork.Read(AccrualId, ReturnError) ;* Read InterestAccrualsWork record

* If Accrualdetails not fetched from InterestAccrualsWork record, read from InterestAccruals record
    IF NOT(RAccrualDetails) THEN
        RAccrualDetails =  AA.Interest.InterestAccruals.Read(AccrualId, ReturnError)
    END

    FromDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccFromDate> ;* Get all from date from record
    ToDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccToDate> ;* Get To date
    PeriodStartDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccPeriodStart> ;* Get period start dates
    PeriodEndDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccPeriodEnd> ;* Get period end dates

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

    PeriodCount = DCOUNT(PeriodStartDate,@VM)
    
    INT.PROP.REC = ""
    EFFECTIVE.DATE = EB.SystemTables.getToday()
    ARR.ID = FIELD(AccrualId,'-',1) ;* Fetch Arrangement id
    TEMP = PeriodStartDate<1,PeriodCount>
    
    AA.Framework.GetArrangementConditions(ARR.ID, "INTEREST", "", EFFECTIVE.DATE, "", INT.PROP.REC, Returnerror)            
    INT.PROP.REC = RAISE(INT.PROP.REC)
    ACCRUAL.RULE = INT.PROP.REC<AA.Interest.Interest.IntAccrualRule>    ;* get accrual rule
    IF ACCRUAL.RULE NE 'FIRST' THEN
        END.DAY.INCLUSIVE = ''
        AA.Interest.GetInterestAccrualParamDetails(ACCRUAL.RULE, "", END.DAY.INCLUSIVE, "")
        IF END.DAY.INCLUSIVE EQ "YES" THEN
            EB.API.Cdt("", TEMP, "+1C")   ;* If last day inclusive, then alone do +1C
        END
    END
    
            
* Locate last period start date in From date to get current period accrual details
    LOCATE PeriodStartDate<1,PeriodCount> IN FromDate<1,1> BY 'DR' SETTING PeriodPos THEN
        GOSUB GetAccrualDetails ; *To get accrual details for the current period
    END ELSE
        PeriodPos  = PeriodPos-1 ;* If Period start date is located, check for the next date
        GOSUB GetAccrualDetails ; *To get accrual details for the current period
    END

* Store all necessary data into return array
    ReturnArray = RetPeriodStartDate:"*":RetPeriodEndDate:"*":RetTotAccrAmt:"*":RetTotAdjAmt:"*":RetFromDate:"*":RetToDate:"*":RetDays:"*":RetBalance:"*":RetBasis:"*":RetRate:"*":RetAccrualAmt

    EB.Reports.setOData(ReturnArray) ;* Set ODATA value

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetAccrualDetails>
*** <desc>To get accrual details for the current period </desc>
GetAccrualDetails:

    FOR LoopCnt = 1 TO PeriodPos
            
* Check if the period start date or period end date should always be greater than or equal to From date and Todate
        IF FromDate<1,LoopCnt> GE TEMP AND ToDate<1,LoopCnt> LT PeriodEndDate<1,PeriodCount>THEN
        
            IF RetFromDate THEN
                RetFromDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccFromDate,LoopCnt>:"~":RetFromDate
            END ELSE
                RetFromDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccFromDate,LoopCnt>
            END

            IF RetToDate THEN
                RetToDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccToDate,LoopCnt>:"~":RetToDate
            END ELSE
                RetToDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccToDate,LoopCnt>
            END
        
            IF RetDays THEN
                RetDays = RAccrualDetails<AA.Interest.InterestAccruals.IntAccDays,LoopCnt>:"~":RetDays
            END ELSE
                RetDays = RAccrualDetails<AA.Interest.InterestAccruals.IntAccDays,LoopCnt>
            END
        
            IF RetBalance NE '' THEN
                RetBalance = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBalance,LoopCnt>:"~":RetBalance
            END ELSE
                RetBalance = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBalance,LoopCnt>
            END
        
            IF RetBasis THEN
                RetBasis = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBasis,LoopCnt>:"~":RetBasis
            END ELSE
                RetBasis = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBasis,LoopCnt>
            END
        
            IF RetRate THEN
                RetRate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccRate,LoopCnt>:"~":RetRate
            END ELSE
                RetRate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccRate,LoopCnt>
            END
        
            IF RetAccrualAmt NE '' THEN
                RetAccrualAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAccrualAmt,LoopCnt>:"~":RetAccrualAmt
            END ELSE
                RetAccrualAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAccrualAmt,LoopCnt>
            END
        
        END

    NEXT LoopCnt
     
    RetPeriodStartDate = PeriodStartDate<1,PeriodCount> ;* Current period start date
    RetPeriodEndDate = PeriodEndDate<1,PeriodCount> ;* Current period end date
    RetTotAccrAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccTotAccrAmt,PeriodCount> ;* Total accrual amount for the current period
    RetTotAdjAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAdjustIntAmt,PeriodCount> ;* Total adjusted amount for the current period if any

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
