* @ValidationCode : MjotMTM3OTQzNTc4ODpDUDEyNTI6MTU2OTUwNDQzNTkwODptYW5pcnVkaDotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzA1LTAyNDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 26 Sep 2019 18:57:15
* @ValidationInfo : Encoding          : CP1252
* @ValidationInfo : User Name         : manirudh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190705-0247
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Interest
SUBROUTINE CONV.AA.INTEREST.ACCRUALS.201708(YID, R.RECORD, FN.FILE)
 
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** This routine will update last period TOT.POS.ACCR.AMT, TOT.NEG.ACCR.AMT
*
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* @package   AA.Interest
* @stereotype ConversionRoutine
* @author Sivakumark@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MODIFICATION HISTORY>
***
* 26/04/16 - Enhancement :
*            Task :
*            New field TOT.POS.ACCR.AMT, TOT.NEG.ACCR.AMT updated
*
* 25/07/19 - Task : 3286245
*            Defect : 1427142
*            For Accrue by Bills, Conversion routine to update ABB.NEW.METHOD flag when upgrading from R14

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    $USING AA.Interest
    $USING AA.ProductFramework
    $USING EB.API
    $USING AC.Fees
    $USING EB.DataAccess
    GOSUB INITIALISE
    GOSUB DO.CONVERSION.FOR.ABB.NEW.METHOD
RETURN  ;* the main functionality to update last period TOT.POS.ACCR.AMT, TOT.NEG.ACCR.AMT is blocked and will be delivered later
GOSUB DO.CONVERSION.FOR.ACTUAL.FIELDS
GOSUB DO.CONVERSION.FOR.INFO.FIELDS
GOSUB DO.CONVERSION.FOR.PROJ.LIVE.FIELDS
GOSUB DO.CONVERSION.FOR.INFO.PROJ.FIELDS

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:

    ArrangementId = FIELDS(YID,'-',1)
    InterestProperty = FIELDS(YID,'-',2,1)
   
    CALL F.READ('F.AA.ARRANGEMENT.DATED.XREF', ArrangementId, R.DATED.XREF, '', ERROR.MSG)
    LOCATE InterestProperty IN R.DATED.XREF<1,1> SETTING DATED.XREF.POS THEN
        ID.DATE = R.DATED.XREF<2,DATED.XREF.POS,1>
    END
    
    ArrIntId = ArrangementId:'-':InterestProperty:'-':ID.DATE
    CALL F.READ('F.AA.ARR.INTEREST', ArrIntId, RPropertyRecord, '', ERROR.MSG)
    AccrualRule = RPropertyRecord<5>
    RET.ERROR = ""
    InterestPropertyRecord = AA.ProductFramework.Property.CacheRead(InterestProperty, RET.ERROR)
    PropPropertyType = InterestPropertyRecord<AA.ProductFramework.Property.PropPropertyType>
    LOCATE "ACCRUAL.BY.BILLS" IN PropPropertyType<1,1> SETTING SUSP.POS THEN
        AccrualByBills = "BILLS"
    END
    REbAccrualParam = AC.Fees.EbAccrualParam.CacheRead(AccrualRule, EB.ACCRUAL.PARAM.ERR)
    StartDayInclusive = REbAccrualParam<3>
    EndDayInclusive = REbAccrualParam<4>

* Actual Field Positions
     
    PeriodStartFieldPos = 13
    PeriodEndFieldPos = 14
    TotAccrAmtFieldPos = 15
    ToDateFieldPos = 2
    FromDateFieldPos = 1
    AccrualAmtFieldPos = 8

* Info Field Positions
     
    InfoPeriodStartFieldPos = 46
    InfoPeriodEndFieldPos = 47
    InfoTotAccrAmtFieldPos = 48
    InfoToDateFieldPos = 36
    InfoFromDateFieldPos = 35
    InfoAccrualAmtFieldPos = 42

* Proj Field Positions
     
    ProjPeriodStartFieldPos = 68
    ProjPeriodEndFieldPos = 69
    ProjTotAccrAmtFieldPos = 70
    ProjToDateFieldPos = 58
    ProjFromDateFieldPos = 57
    ProjAccrualAmtFieldPos = 64

* Proj Info Field Positions
     
    ProjInfoPeriodStartFieldPos = 95
    ProjInfoPeriodEndFieldPos = 96
    ProjInfoTotAccrAmtFieldPos = 97
    ProjInfoToDateFieldPos = 85
    ProjInfoFromDateFieldPos = 84
    ProjInfoAccrualAmtFieldPos = 91
    
* AbbNewMethod field for accrue by bills
    AbbNewMethod = 103
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION.FOR.ACTUAL.FIELDS:

    AccrualAmt = 0
    TotAccAmt = 0
    TotPosAccAmt = 0
    TotNegAccAmt = 0

    LastPeriod = DCOUNT(R.RECORD<PeriodStartFieldPos>,@VM)   ;* Find the last positon
    
    LastPeriodStartDate = R.RECORD<PeriodStartFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    LastPeriodEndDate = R.RECORD<PeriodEndFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    TotalAccrualAmount = R.RECORD<TotAccrAmtFieldPos,LastPeriod>
    IF TotalAccrualAmount THEN
        GOSUB GetStartDate
        FromPos = ''
    
        LOCATE LastPeriodStartDate IN R.RECORD<FromDateFieldPos,1> BY 'DN' SETTING FromPos ELSE
            IF FromPos EQ '1' THEN
                FromPos = 0
            END
        END

        FOR Cnt = 1 TO FromPos ;* ToDate Position always the 1st position
    
            AccrualAmt = R.RECORD<AccrualAmtFieldPos,Cnt> ;* Get the accrual amount for the FROM-TO Bucket
        
            TotAccAmt+=AccrualAmt ;* Add the accrual amount with TotAccAmt
            IF AccrualAmt GT 0 THEN
                TotPosAccAmt+=AccrualAmt ;* Add the accrual amount with TotPosAccAmt if it's positive accrual
            END ELSE
                TotNegAccAmt+=AccrualAmt ;* Add the accrual amount with TotNegAccAmt if it's negative accrual
            END
     
        NEXT Cnt
    
        SumOfPosNegAccrAmt = TotPosAccAmt+TotNegAccAmt ;* Sum of positive and negative accrual split
    
        IF SumOfPosNegAccrAmt NE TotalAccrualAmount THEN ;* When Sum of positive and negative accrual split is not equal to TotAccAmt then there was adjustment done
* so need to adjust the positive or negative split based on the difference
        
            DiffAmount = TotalAccrualAmount-SumOfPosNegAccrAmt
            IF DiffAmount LT 0 THEN
                TotPosAccAmt+=DiffAmount
            END ELSE
                TotNegAccAmt+=DiffAmount
            END
        END
        IF R.RECORD<TotAccrAmtFieldPos> THEN
            R.RECORD<21,LastPeriod> = TotPosAccAmt
            R.RECORD<22,LastPeriod> = TotNegAccAmt
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION.FOR.INFO.FIELDS:
    
    AccrualAmt = 0
    TotAccAmt = 0
    TotPosAccAmt = 0
    TotNegAccAmt = 0

    LastPeriod = DCOUNT(R.RECORD<InfoPeriodStartFieldPos>,@VM)   ;* Find the last positon
    
    LastPeriodStartDate = R.RECORD<InfoPeriodStartFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    LastPeriodEndDate = R.RECORD<InfoPeriodEndFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    TotalAccrualAmount = R.RECORD<InfoTotAccrAmtFieldPos,LastPeriod>
    
    IF TotalAccrualAmount THEN
        GOSUB GetStartDate
        FromPos = ''
    
        LOCATE LastPeriodStartDate IN R.RECORD<InfoFromDateFieldPos,1> BY 'DN' SETTING FromPos ELSE
            IF FromPos EQ '1' THEN
                FromPos = 0
            END
        END
    
        FOR Cnt = 1 TO FromPos ;* ToDate Position always the 1st position
    
            AccrualAmt = R.RECORD<InfoAccrualAmtFieldPos,Cnt> ;* Get the accrual amount for the FROM-TO Bucket
        
            TotAccAmt+=AccrualAmt ;* Add the accrual amount with TotAccAmt
            IF AccrualAmt GT 0 THEN
                TotPosAccAmt+=AccrualAmt ;* Add the accrual amount with TotPosAccAmt if it's positive accrual
            END ELSE
                TotNegAccAmt+=AccrualAmt ;* Add the accrual amount with TotNegAccAmt if it's negative accrual
            END
     
        NEXT Cnt
    
        SumOfPosNegAccrAmt = TotPosAccAmt+TotNegAccAmt ;* Sum of positive and negative accrual split
    
        IF SumOfPosNegAccrAmt NE TotalAccrualAmount THEN ;* When Sum of positive and negative accrual split is not equal to TotAccAmt then there was adjustment done
* so need to adjust the positive or negative split based on the difference
        
            DiffAmount = TotalAccrualAmount-SumOfPosNegAccrAmt
            IF DiffAmount LT 0 THEN
                TotPosAccAmt+=DiffAmount
            END ELSE
                TotNegAccAmt+=DiffAmount
            END
        END
        IF R.RECORD<InfoTotAccrAmtFieldPos> THEN
            R.RECORD<49,LastPeriod> = TotPosAccAmt
            R.RECORD<50,LastPeriod> = TotNegAccAmt
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION.FOR.PROJ.LIVE.FIELDS:
    
    AccrualAmt = 0
    TotAccAmt = 0
    TotPosAccAmt = 0
    TotNegAccAmt = 0

    LastPeriod = DCOUNT(R.RECORD<ProjPeriodStartFieldPos>,@VM)   ;* Find the last positon
    
    LastPeriodStartDate = R.RECORD<ProjPeriodStartFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    LastPeriodEndDate = R.RECORD<ProjPeriodEndFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    TotalAccrualAmount = R.RECORD<ProjTotAccrAmtFieldPos,LastPeriod>
    IF TotalAccrualAmount THEN
        GOSUB GetStartDate
    
        FromPos = ''
        LOCATE LastPeriodStartDate IN R.RECORD<ProjFromDateFieldPos,1> BY 'DN' SETTING FromPos ELSE
            IF FromPos EQ '1' THEN
                FromPos = 0
            END
        END

        FOR Cnt = 1 TO FromPos ;* ToDate Position always the 1st position
    
            AccrualAmt = R.RECORD<ProjAccrualAmtFieldPos,Cnt> ;* Get the accrual amount for the FROM-TO Bucket
        
            TotAccAmt+=AccrualAmt ;* Add the accrual amount with TotAccAmt
            IF AccrualAmt GT 0 THEN
                TotPosAccAmt+=AccrualAmt ;* Add the accrual amount with TotPosAccAmt if it's positive accrual
            END ELSE
                TotNegAccAmt+=AccrualAmt ;* Add the accrual amount with TotNegAccAmt if it's negative accrual
            END
     
        NEXT Cnt
    
        SumOfPosNegAccrAmt = TotPosAccAmt+TotNegAccAmt ;* Sum of positive and negative accrual split
    
        IF SumOfPosNegAccrAmt NE TotalAccrualAmount THEN ;* When Sum of positive and negative accrual split is not equal to TotAccAmt then there was adjustment done
* so need to adjust the positive or negative split based on the difference
        
            DiffAmount = TotalAccrualAmount-SumOfPosNegAccrAmt
            IF DiffAmount LT 0 THEN
                TotPosAccAmt+=DiffAmount
            END ELSE
                TotNegAccAmt+=DiffAmount
            END
    
        END

        IF R.RECORD<ProjTotAccrAmtFieldPos> THEN
            R.RECORD<76,LastPeriod> = TotPosAccAmt
            R.RECORD<77,LastPeriod> = TotNegAccAmt
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION.FOR.INFO.PROJ.FIELDS:
    
    AccrualAmt = 0
    TotAccAmt = 0
    TotPosAccAmt = 0
    TotNegAccAmt = 0

    LastPeriod = DCOUNT(R.RECORD<ProjInfoPeriodStartFieldPos>,@VM)   ;* Find the last positon
    
    LastPeriodStartDate = R.RECORD<ProjInfoPeriodStartFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    LastPeriodEndDate = R.RECORD<ProjInfoPeriodEndFieldPos,LastPeriod> ;* Get the Last set of PeriodStart, PeriodEnd
    TotalAccrualAmount = R.RECORD<ProjInfoTotAccrAmtFieldPos,LastPeriod>
    IF TotalAccrualAmount THEN
        GOSUB GetStartDate
    
        FromPos = ''
        LOCATE LastPeriodStartDate IN R.RECORD<ProjInfoFromDateFieldPos,1> BY 'DN' SETTING FromPos ELSE
            IF FromPos EQ '1' THEN
                FromPos = 0
            END
        END
    
        FOR Cnt = 1 TO FromPos ;* ToDate Position always the 1st position
    
            AccrualAmt = R.RECORD<ProjInfoAccrualAmtFieldPos,Cnt> ;* Get the accrual amount for the FROM-TO Bucket
        
            TotAccAmt+=AccrualAmt ;* Add the accrual amount with TotAccAmt
            IF AccrualAmt GT 0 THEN
                TotPosAccAmt+=AccrualAmt ;* Add the accrual amount with TotPosAccAmt if it's positive accrual
            END ELSE
                TotNegAccAmt+=AccrualAmt ;* Add the accrual amount with TotNegAccAmt if it's negative accrual
            END
     
        NEXT Cnt
    
        SumOfPosNegAccrAmt = TotPosAccAmt+TotNegAccAmt ;* Sum of positive and negative accrual split
    
        IF SumOfPosNegAccrAmt NE TotalAccrualAmount THEN ;* When Sum of positive and negative accrual split is not equal to TotAccAmt then there was adjustment done
* so need to adjust the positive or negative split based on the difference
        
            DiffAmount = TotalAccrualAmount-SumOfPosNegAccrAmt
            IF DiffAmount LT 0 THEN
                TotPosAccAmt+=DiffAmount
            END ELSE
                TotNegAccAmt+=DiffAmount
            END
    
        END
        IF R.RECORD<ProjInfoTotAccrAmtFieldPos> THEN
            R.RECORD<98,LastPeriod> = TotPosAccAmt
            R.RECORD<99,LastPeriod> = TotNegAccAmt
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetStartDate>
*** <desc>GetStartDate</desc>
GetStartDate:
    
    BEGIN CASE
        
        CASE StartDayInclusive EQ "YES" AND EndDayInclusive EQ "YES" ;* Accural rule as BOTH
            IF LastPeriod GT 1 THEN
                IF LastPeriodStartDate MATCHES "8N" THEN ;*Valid date format
                    EB.API.Cdt('',LastPeriodStartDate,"+1C") ;* And from the second and subsequent periods
                END
            END ELSE
                LastPeriodStartDate = LastPeriodStartDate ;* Assuming its a first period
            END

        CASE EndDayInclusive EQ "YES" ;* Accrual rule as LAST
            IF LastPeriodStartDate MATCHES "8N" THEN ;*Valid date format
                EB.API.Cdt('',LastPeriodStartDate,"+1C")
            END

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION.FOR.ABB.NEW.METHOD:
    IF AccrualByBills AND InterestProperty EQ YID["-",2,2] THEN ;* Update only for main accrual file
        FrameworkFlag = '';* Record variable to hold the error record
        ChargeFlag = ''
        PaymentFlag = ''
        ErrText = ''
        EB.DataAccess.CacheRead('F.EB.ERROR', "AA-AA.ACCRUE.BILLS.FRAMEWORK",FrameworkFlag, ErrText)    ;* Perform a Cache read on the error record to see if its available.
        EB.DataAccess.CacheRead('F.EB.ERROR', "AA-AA.ACCRUE.BILLS.CHARGE", ChargeFlag, ErrText)    ;* Perform a Cache read on the error record to see if its available.
        EB.DataAccess.CacheRead('F.EB.ERROR', "AA-AA.ACCRUE.BILLS.PAYMENT", PaymentFlag, ErrText)    ;* Perform a Cache read on the error record to see if its available.

        IF FrameworkFlag AND ChargeFlag AND PaymentFlag THEN   ;* If all three flags are available, then the client has upgraded from R14. So update the flag !!!
        	R.RECORD<AbbNewMethod> = "YES"
       END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
