* @ValidationCode : MjoxNzE5MzUzMDMxOkNwMTI1MjoxNjA2Mjc5Njc2OTYxOmRpdnlhc2FyYXZhbmFuOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToxMjE6MTIw
* @ValidationInfo : Timestamp         : 25 Nov 2020 10:17:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 120/121 (99.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.GET.ACCRUAL.DETAILS
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
*            Conversion routine to get accrual details for the given accrual id
*
* 06/11/20 - Task : 4065402
*            Enhancement : 3164925
*            Fix for returning Period start and end dates properly
*
* 24/11/20 - Task : 4096316
*            Enhancement : 3164925
*            Conversion routine to get accrual details for the given period start and end date
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Interest
    
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

    AccrualDets = EB.Reports.getOData()
  
    AccrualId = FIELD(AccrualDets, '#',1)
    ReqStartDate = FIELD(AccrualDets, '#',2)
    ReqEndDate = FIELD(AccrualDets, '#',3)
    
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
    TotAccrueAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccTotAccrAmt> ;* Get Total accrual amounts
    TotAdjAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAdjustIntAmt> ;* Get Total adjustment amount

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

    IF ReqStartDate THEN
        LOCATE ReqStartDate IN PeriodStartDate<1,1> BY 'AR' SETTING StartPos ELSE
            IF StartPos GT 1 THEN
                StartPos = StartPos - 1
            END
        END
    END ELSE
        StartPos = 1
    END
    
    IF ReqEndDate AND PeriodEndDate THEN
        LOCATE ReqEndDate IN PeriodEndDate<1,1> BY 'AR' SETTING EndPos ELSE
            IF EndPos GT 1 THEN
                EndPos  = EndPos - 1
            END
        END
    END ELSE
        EndPos = DCOUNT(PeriodStartDate, @VM)
    END
              

    FOR PeriodCnt = StartPos TO EndPos
        
        CurrPeriodStart = PeriodStartDate<1,PeriodCnt>
        CurrPeriodEnd = PeriodEndDate<1,PeriodCnt>
        CurrTotAccrAmt = TotAccrueAmt<1,PeriodCnt>
        CurrTotAdjAmt = TotAdjAmt<1,PeriodCnt>
        
        LOCATE CurrPeriodStart IN FromDate<1,1> BY 'DR' SETTING CurPeriodPos THEN
            GOSUB GetAccrualDetails ; *To get accrual details for the current period
        END ELSE
            CurPeriodPos  = CurPeriodPos-1
* To get accrual details for the current period only if accrual happened for the particular period
            IF CurPeriodPos THEN
                GOSUB GetAccrualDetails
            END
* If peroid start is present and accrual is not happened, then return the period date details alone
            IF CurrPeriodStart AND NOT(CurPeriodPos) THEN
                GOSUB GetPeriodDetails
            END
        END
    NEXT PeriodCnt
     
    CHANGE @VM TO "~" IN RetPeriodStartDate
    CHANGE @VM TO "~" IN RetPeriodEndDate
    CHANGE @VM TO "~" IN RetTotAccrAmt
    CHANGE @VM TO "~" IN RetTotAdjAmt
    
    ReturnArray = RetPeriodStartDate:"*":RetPeriodEndDate:"*":RetTotAccrAmt:"*":RetTotAdjAmt:"*":RetFromDate:"*":RetToDate:"*":RetDays:"*":RetBalance:"*":RetBasis:"*":RetRate:"*":RetAccrualAmt
   
    EB.Reports.setOData(ReturnArray) ;* Set ODATA value

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetAccrualDetails>
*** <desc>To get accrual details for the current period </desc>
GetAccrualDetails:

* Initialise to null for each period start date and Period end date set.
    TempRetFromDate = ''
    TempRetToDate = ''
    TempRetDays = ''
    TempRetBalance = ''
    TempRetBasis = ''
    TempRetRate = ''
    TempRetAccrualAmt = ''
 
    FOR LoopCnt = 1 TO CurPeriodPos
        
* Check if the period start date or period end date should always be greater than or equal to From date and Todate
        IF FromDate<1,LoopCnt> GE CurrPeriodStart AND ToDate<1,LoopCnt> LE CurrPeriodEnd THEN

* When Fromdate is not present, get from accrual record. Else insert in the first place.
* Similarly, do for all data
     
            IF TempRetFromDate THEN
                TempRetFromDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccFromDate,LoopCnt>:"~":TempRetFromDate
                TempRetToDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccToDate,LoopCnt>:"~":TempRetToDate
                TempRetDays = RAccrualDetails<AA.Interest.InterestAccruals.IntAccDays,LoopCnt>:"~":TempRetDays
                TempRetBalance = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBalance,LoopCnt>:"~":TempRetBalance
                TempRetBasis = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBasis,LoopCnt>:"~":TempRetBasis
                TempRetRate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccRate,LoopCnt>:"~":TempRetRate
                TempRetAccrualAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAccrualAmt,LoopCnt>:"~":TempRetAccrualAmt
            END ELSE
                TempRetFromDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccFromDate,LoopCnt>
                TempRetToDate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccToDate,LoopCnt>
                TempRetDays = RAccrualDetails<AA.Interest.InterestAccruals.IntAccDays,LoopCnt>
                TempRetBalance = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBalance,LoopCnt>
                TempRetBasis = RAccrualDetails<AA.Interest.InterestAccruals.IntAccBasis,LoopCnt>
                TempRetRate = RAccrualDetails<AA.Interest.InterestAccruals.IntAccRate,LoopCnt>
                TempRetAccrualAmt = RAccrualDetails<AA.Interest.InterestAccruals.IntAccAccrualAmt,LoopCnt>
            END

            GOSUB GetPeriodDetails ; *To get data for each period
       
        END
    
    NEXT LoopCnt

* When one period data is retrieved, Store in the return data. If already return data has value, Append after that.
* Each period should have its respective data set
    IF RetFromDate THEN
        RetFromDate = RetFromDate:"~":TempRetFromDate
        RetToDate = RetToDate:"~":TempRetToDate
        RetDays = RetDays:"~":TempRetDays
        RetBalance = RetBalance:"~":TempRetBalance
        RetBasis = RetBasis:"~":TempRetBasis
        RetRate = RetRate:"~":TempRetRate
        RetAccrualAmt = RetAccrualAmt:"~":TempRetAccrualAmt
    END ELSE
        RetFromDate = TempRetFromDate
        RetToDate = TempRetToDate
        RetDays = TempRetDays
        RetBalance = TempRetBalance
        RetBasis = TempRetBasis
        RetRate = TempRetRate
        RetAccrualAmt = TempRetAccrualAmt
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetPeriodDetails>
*** <desc>To get data for each period </desc>
GetPeriodDetails:

* When Period start date is present in the return data, Append marker. Else, Store the current Period start date to return data.
* Similarly do for all required data

    LOCATE CurrPeriodStart IN RetPeriodStartDate<1,1> SETTING RetPos THEN
        RetPeriodStartDate = RetPeriodStartDate:@VM
        RetPeriodEndDate = RetPeriodEndDate:@VM
        RetTotAccrAmt = RetTotAccrAmt:@VM
        RetTotAdjAmt = RetTotAdjAmt:@VM
    END ELSE
        RetPeriodStartDate<1,-1> = CurrPeriodStart
        RetPeriodEndDate<1,-1> = CurrPeriodEnd
        RetTotAccrAmt<1,-1> = CurrTotAccrAmt
        RetTotAdjAmt<1,-1> = CurrTotAdjAmt
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

