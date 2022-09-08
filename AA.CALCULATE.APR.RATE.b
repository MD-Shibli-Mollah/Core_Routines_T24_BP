* @ValidationCode : MjotMjEwMjE4OTUwNjpDcDEyNTI6MTYwNTYwMjk2NjE0NTpubWFydW46OTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0Ojg5Ojg5
* @ValidationInfo : Timestamp         : 17 Nov 2020 14:19:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/89 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Reporting
SUBROUTINE AA.CALCULATE.APR.RATE(T.Cashflows, T.Cf.Dates, Int.Basis, Eir, RetErr)
*-----------------------------------------------------------------------------
* This local API will be attached in a AA.APR.TYPE record
* It will calculate the APR rate for the particular APR type
*
*-----------------------------------------------------------------------------
* @author vkprathiba@temenos.com
*-----------------------------------------------------------------------------
*** </region>
************************************************************************************
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* T.Cashflows       - Cash flow amounts
* T.Cf.Dates        - Cash flow dates
* Int.Basis         - Interest Basis to calculate days in year
* Eir               - Input-Sample rate; Output-Calculated effective interest rate for given cashflows
*
* Output
*
* RetErr            - Errors, if any, during processing
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 24/01/19 - Task  : 2897305
*            Enhan : 2897301
*            Local Api to calculate the Apr rate for the Apr type defined, this Api will be attached in AA.APR.TYPE table
*
* 13/03/19 - Task  : 3020742
*            Enhan : 2947685
*            Removed reserved argument Apr Type
*
* 22/04/19 - Task  : 3097509
*            Defect : 3095040
*            If Eir is given, convert it to decimal from percentage
*
* 09/10/20 - Task        - 3930713
*            Enhancement - 3930710
*            Get interest basis record using MDAL Reference data API
*
* 17/11/20 - Task        - 4084560
*            Enhancement - 3930710
*            Selenium Fix -  Call MDAL Reference data API only when InterestBasis Id is available
*
*-----------------------------------------------------------------------------

    $USING AC.Fees
    $USING ST.RateParameters
    $USING IA.Valuation
    $USING CW.CashFlow
    $USING MDLREF.ReferenceData
    $USING EB.SystemTables
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB Initialise
    GOSUB ProcessRate
    
    InitFlag = ''
    LOOP
    UNTIL ABS(Cf.Bal) LT Tolerance OR IterateCnt GT Threshold
        GOSUB GetNextRate
        GOSUB ProcessRate
        IterateCnt += 1
    REPEAT
    
    IterateCnt -= 1          ;*Nullify the last increment as we have not processed.
    Eir = NextRate*100       ;* return the rate as percentage

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise Variables</desc>
Initialise:
    
    IF Eir = '' THEN
        Eir = '0.05'   ;* If Eir is null, Calculate default rate 0.5
    END ELSE
        Eir = Eir/100   ;* If Eir is given, convert it to decimal from percentage
    END
    NextRate = Eir
    RIntBasis = ''
    AprType = ''
    RetErr = ''
    Tolerance = '0.00001'
    DaysInYear = ''
    
    IF Int.Basis THEN  ;* Call MDAL Reference Data API only when Interest Basis Id is available
        SaveEText = ''
        SaveEText = EB.SystemTables.getEtext()  ;* Save the Etext to restore it later
        EB.SystemTables.setEtext('')  ;* Reset the  Etext before calling MDAL API
        RIntBasis = MDLREF.ReferenceData.getInterestDayBasisDetails(Int.Basis)   ;* Get the Interest Basis Record
        RetErr = EB.SystemTables.getEtext() ;* Set the Error text to RetErr Argument if there is any error
        EB.SystemTables.setEtext(SaveEText)  ;* Restore the Etext after calling MDAL API
        DaysInYear = RIntBasis<MDLREF.ReferenceData.InterestDayBasisDetails.interestBasis>['/',2,1]
    END
    TotCf = DCOUNT(T.Cashflows, @FM)
    IterateCnt = 0
    InitFlag = 1
    Threshold = 100
    PowerFactor = ''         ;*This array will store once the number of days from the initial cash flow

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessRate>
*** <desc> Calculate the Rate</desc>
ProcessRate:

    Cf.Bal = 0
    Cf.Der.Bal = 0
    FOR LoopCnt = 1 TO TotCf
        IF InitFlag THEN
            GOSUB FormCompoundingFactor         ;*Form this array once and reuse for the iterations
        END
        Cf.Bal += T.Cashflows<LoopCnt>/( (1 + NextRate)^PowerFactor<LoopCnt> )  ;* Cash Flow balance available on the particular date
        Cf.Der.Bal -= PowerFactor<LoopCnt> * T.Cashflows<LoopCnt> / ((1 + NextRate)^(PowerFactor<LoopCnt>+1))
    NEXT LoopCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FormCompoundingFactor>
*** <desc> Form the Compounding Factor</desc>
FormCompoundingFactor:

    NoOfDays = ''
    IF LoopCnt GT 1 THEN
        GOSUB GetDaysInYear ;* Count the total number of days between start and end date from the cashflow dates
    END ELSE
        PowerFactor<1> = 0
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetDaysInYear>
*** <desc> Get the total number of days in a year</desc>
GetDaysInYear:

    IF Int.Basis EQ 'C' THEN    ;* Get Days for Int.Basis 'C'
        BEGIN CASE

            CASE T.Cf.Dates<1>[1,4] NE T.Cf.Dates<LoopCnt>[1,4]
*Split the Days till the end of year and then calculate
                StartDate = T.Cf.Dates<1>
                EndDate = T.Cf.Dates<1>[1,4] + 1:'0101'
                GOSUB GetDays
                PowerFactor<LoopCnt> += NoOfDays

                StartDate = T.Cf.Dates<LoopCnt>[1,4]:'0101'
                EndDate = T.Cf.Dates<LoopCnt>
                GOSUB GetDays
                PowerFactor<LoopCnt> += NoOfDays

                PowerFactor<LoopCnt> += T.Cf.Dates<LoopCnt>[1,4] - T.Cf.Dates<1>[1,4] - 1

            CASE 1
                StartDate = T.Cf.Dates<1>
                EndDate = T.Cf.Dates<LoopCnt>
                GOSUB GetDays
                PowerFactor<LoopCnt> = NoOfDays

        END CASE
    END ELSE
* Get Days for Int.Basis 'E'
        AC.Fees.BdCalcDays(T.Cf.Dates<1>, T.Cf.Dates<LoopCnt>, Int.Basis, NoOfDays)
        PowerFactor<LoopCnt> = NoOfDays/DaysInYear
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetDays>
*** <desc> Get the days for Rate Calculation</desc>
GetDays:

    NoOfDays = ''
    AC.Fees.BdCalcDays(StartDate, EndDate, Int.Basis, NoOfDays)
    IF MOD(StartDate[1,4],4) THEN   ;* Check for leap year
        DaysInYear = 365    ;* Normal year
    END ELSE
        DaysInYear = 366    ;* Leap year
    END
    NoOfDays = NoOfDays/DaysInYear

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetNextRate>
*** <desc> Get the Next Rate</desc>
GetNextRate:

    NextRate += Cf.Bal/Cf.Der.Bal*(Cf.Bal/T.Cashflows<1> -1)    ;* Calculate rate for the next cash flow date using Cash flow balance available on the date

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
