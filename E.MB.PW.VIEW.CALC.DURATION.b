* @ValidationCode : MjotNjE0NTA2NjM5OkNwMTI1MjoxNTc4NTY0NDE5MzAxOm1oaW5kdW1hdGh5OjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTo1NTo1NQ==
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 55/55 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.CALC.DURATION
*-----------------------------------------------------------------------------
*
* This is a build routine attached to the enquiry PW.VIEW.ACTIVITY.DURATION.
* Returns the time taken to complete each activity in days, hours and minutes.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 17/12/2019 - Enhancement 3396943 / Task 3483737
*              Integration of BSG created screen to L1 PW
*
*-----------------------------------------------------------------------------

    $USING EB.API
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING PW.Foundation
    
    

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------


INITIALISE:

    fnPwActivityTxn = 'F.PW.ACTIVITY.TXN'
    fvPwActivityTxn = ''
    EB.DataAccess.Opf(fnPwActivityTxn,fvPwActivityTxn)

    fnPwProcess = 'F.PW.PROCESS'
    fvPwProcess = ''
    EB.DataAccess.Opf(fnPwProcess,fvPwProcess)
    
    yrPwActivityTxnId = EB.Reports.getOData()

RETURN
*-----------------------------------------------------------------------------


PROCESS:
    yrPwActivityTxnRec = PW.Foundation.ActivityTxn.CacheRead(yrPwActivityTxnId, actTxnErr)
    IF NOT(actTxnErr) THEN
        yrPwActivityTxnStartDate = yrPwActivityTxnRec<PW.Foundation.ActivityTxn.ActTxnStartDate>
        yrPwActivityTxnStartTime = yrPwActivityTxnRec<PW.Foundation.ActivityTxn.ActTxnStartTime>
        yrPwActivityTxnEndDate = yrPwActivityTxnRec<PW.Foundation.ActivityTxn.ActTxnEndDate>
        yrPwActivityTxnEndTime = yrPwActivityTxnRec<PW.Foundation.ActivityTxn.ActTxnEndTime>
        yrPwActivityTxnEndDateCount = DCOUNT(yrPwActivityTxnEndDate,@VM)
        endDate = FIELD(yrPwActivityTxnEndDate,@VM,yrPwActivityTxnEndDateCount)
        endTime = FIELD(yrPwActivityTxnEndTime,@VM,yrPwActivityTxnEndDateCount)
        GOSUB CALCULATE.DURATION
    END

RETURN
*-----------------------------------------------------------------------------

CALCULATE.DURATION:

    noOfDays = 'W'
    daysHrMin = ''
    IF endDate THEN
        EB.API.Cdd('',yrPwActivityTxnStartDate,endDate,noOfDays)
        IF noOfDays EQ '0' THEN
            diffInHr =  FIELD(endTime,':', 1) - FIELD(yrPwActivityTxnStartTime, ':', 1)
            diffInMins = FIELD(endTime,':', 2) - FIELD(yrPwActivityTxnStartTime, ':', 2)
            actDiffInHr = FIELD((diffInHr * 60 + diffInMins)/60,'.',1)
            actDiffInMins = MOD((diffInHr * 60 + diffInMins),60)
            hrMin = (actDiffInHr * 60 + actDiffInMins)/60
            hrVal = FIELDS(hrMin,'.',1)
            minVal = actDiffInMins
            daysHrMin = hrVal:' Hr ':minVal:' Min'
        END ELSE
            diffInHr= FIELD(endTime,':', 1) + 24 -  FIELD(yrPwActivityTxnStartTime, ':', 1)
            diffInMins = FIELD(endTime,':', 2) + 60 -  FIELD(yrPwActivityTxnStartTime, ':', 2)
            diffInHr += FIELD(diffInMins/60,'.',1)
            diffInMins = MOD(diffInMins,60)
            diffInHr = diffInHr - 1
            IF diffInHr GE 24 THEN
                diffInHr = MOD(diffInHr,24)
                noOfDays += 1
            END
            IF noOfDays EQ 1 THEN
                daysHrMin = diffInHr : ' Hr ' : diffInMins : ' Min'
            END ELSE
                daysHrMin =  (noOfDays - 1) : ' Day ' : diffInHr : ' Hr ' : diffInMins : ' Min'
            END
        END
    END
    EB.Reports.setOData(daysHrMin)
    
RETURN
*-----------------------------------------------------------------------------

END
