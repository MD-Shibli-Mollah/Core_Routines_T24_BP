* @ValidationCode : MjoxNjkyMzM5NTI0OkNwMTI1MjoxNTc4NTY0NDE5NDczOm1oaW5kdW1hdGh5OjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNToxMDA6MTAw
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 100/100 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.ACTIVITY.DURATION(YrDetails)
*-----------------------------------------------------------------------------
*
* This subroutine is attached as nofile to the enquiries PW.VIEW.ACTIVITY.DURATION.CHART
* and PW.VIEW.ACTIVITY.DURATION.CHART. The routines calculates the absolute time in
* minutes and returns the data to the enquiry along with activity trasaction details
* from the PW.ACTIVITY.TXN record for the current process.
*
* Out Argument: YrDetails, returns that activity transaction details and duration
*               of each activity in a process.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 17/12/2019 - Enhancement 3396943 / Task 3483737
*              Integration of BSG created screen to L1 PW
*
*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING PW.Foundation
    $USING EB.Browser
    $USING EB.Reports
    $USING EB.API

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------

INITIALISE:

    FN.PW.PROCESS = 'F.PW.PROCESS'
    FV.PW.PROCESS = ''
    EB.DataAccess.Opf(FN.PW.PROCESS,FV.PW.PROCESS)

    FN.PW.ACTIVITY.CATALOGUE = 'F.PW.ACTIVITY.CATALOGUE'
    FV.PW.ACTIVITY.CATALOGUE = ''
    EB.DataAccess.Opf(FN.PW.ACTIVITY.CATALOGUE,FV.PW.ACTIVITY.CATALOGUE)

    FN.PW.ACTIVITY.TXN = 'F.PW.ACTIVITY.TXN'
    FV.PW.ACTIVITY.TXN = ''
    EB.DataAccess.Opf(FN.PW.ACTIVITY.TXN,FV.PW.ACTIVITY.TXN)

    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)

    LOCATE 'CURRENT.PROCESS' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
        YR.PW.PROCESS.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END
*

RETURN
*-----------------------------------------------------------------------------

PROCESS:
    YR.PW.PROCESS.REC = PW.Foundation.Process.CacheRead(YR.PW.PROCESS.ID, YR.ERR.1) ;* read the process record

    IF NOT(YR.ERR.1) THEN
        YR.PW.PROCESS.ACTIVITY.TXN = YR.PW.PROCESS.REC<PW.Foundation.Process.ProcActivityTxn> ;* get the activity transaction Ids
        LOOP
            REMOVE YR.PW.ACTIVITY.TXN.ID FROM YR.PW.PROCESS.ACTIVITY.TXN SETTING YR.POS.2
        WHILE YR.PW.ACTIVITY.TXN.ID:YR.POS.2
            GOSUB READ.PW.ACTIVITY.TXN
        REPEAT
    END

RETURN
*-----------------------------------------------------------------------------

READ.PW.ACTIVITY.TXN:
    
    YR.PW.ACTIVITY.TXN.REC = PW.Foundation.ActivityTxn.CacheRead(YR.PW.ACTIVITY.TXN.ID, YR.ERR.3) ;* read the activity transaction records
    IF NOT(YR.ERR.3) THEN
        YR.PW.ACTIVITY.ID = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnActivity> ;* get the activity name
        YR.PW.ACTIVITY.TXN.COMPLETION.DATE = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnCompletionDate> ;* get the completion date
        IF YR.PW.ACTIVITY.TXN.COMPLETION.DATE THEN
            GOSUB COLLECT.ACTIVITY.TXN.DETAILS ;* collection the details of the transaction created for the PW Activity
            GOSUB ACTIVITY.DURATION ;* calculate the activity duration
            GOSUB RETURN.DATA ;* set the output of the enquiry routine
        END
    END


RETURN
*-----------------------------------------------------------------------------

COLLECT.ACTIVITY.TXN.DETAILS:

    YR.PW.ACTIVITY.CATALOGUE.REC = PW.Foundation.ActivityCatalogue.CacheRead(YR.PW.ACTIVITY.ID, YR.ERR.4) ;* read the activity catalogue record
    IF NOT(YR.ERR.4) THEN
        YR.PW.ACTIVITY.DESCRIPTION = YR.PW.ACTIVITY.CATALOGUE.REC<PW.Foundation.ActivityCatalogue.ActCatalogueDescription> ;* get the description of the activity
    END
    YR.PW.ACTIVITY.TXN.OWNER = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnOwner>
    YR.PW.ACTIVITY.TXN.USER = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnUser>
    YR.PW.ACTIVITY.TXN.START.DATE = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnStartDate>
    YR.PW.ACTIVITY.TXN.START.TIME = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnStartTime>
    YR.PW.ACTIVITY.TXN.DUE.DATE = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnDueDate>
    YR.PW.ACTIVITY.TXN.PW.ACTIVITY.STATUS = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnPwActivityStatus>
    YR.PW.ACTIVITY.TXN.STATUS = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnStatus>
    YR.PW.ACTIVITY.TXN.END.DATE = FIELD(YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnEndDate>,@VM,1)
    YR.PW.ACTIVITY.TXN.END.TIME = FIELD(YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnEndTime>,@VM,1)
    YR.PW.ACTIVITY.TXN.MONITOR.INIT.DATE = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnMonitorInitDate>
    YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnMonitorInitTime>

RETURN
*-----------------------------------------------------------------------------

ACTIVITY.DURATION:

    YR.NO.OF.DAYS = 'W'

    IF YR.PW.ACTIVITY.TXN.END.DATE NE '' AND YR.PW.ACTIVITY.TXN.END.TIME NE '' THEN
        IF YR.PW.ACTIVITY.TXN.MONITOR.INIT.DATE EQ '' AND YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME EQ '' THEN
            YR.PW.ACTIVITY.TXN.MONITOR.INIT.DATE = YR.PW.ACTIVITY.TXN.START.DATE
            YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME = YR.PW.ACTIVITY.TXN.START.TIME
        END
        EB.API.Cdd('',YR.PW.ACTIVITY.TXN.MONITOR.INIT.DATE,YR.PW.ACTIVITY.TXN.END.DATE,YR.NO.OF.DAYS) ;* calculate the no of days
        IF YR.NO.OF.DAYS EQ '0' THEN
            GOSUB CALCULATE.DURATION
        END ELSE
            GOSUB CALC.DURATION ;* calculate duration when number of days is greater than or equal to 1
        END
        YR.PW.ACTIVITY.TXN.MONITOR.DURATION = YR.MONITOR.DURA ;* set the final duration
    END

RETURN
*-----------------------------------------------------------------------------

CALCULATE.DURATION:

    YR.TIME.IN.HOURS.1 =  FIELD(YR.PW.ACTIVITY.TXN.END.TIME,':', 1) - FIELD(YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME, ':', 1)
    YR.TIME.IN.MINS.1 = FIELD(YR.PW.ACTIVITY.TXN.END.TIME,':', 2) - FIELD(YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME, ':', 2)
    YR.TIME.IN.HOURS.2 = FIELD((YR.TIME.IN.HOURS.1 * 60 + YR.TIME.IN.MINS.1)/60,'.',1)
    YR.TIME.IN.MINS.2 = MOD((YR.TIME.IN.HOURS.1 * 60 + YR.TIME.IN.MINS.1),60)
    IF YR.TIME.IN.HOURS.2 EQ 0 AND YR.TIME.IN.MINS.2 EQ 0 THEN
        YR.MONITOR.DURA = 1
    END ELSE
        YR.MONITOR.DURA = ABS(YR.TIME.IN.HOURS.2 * 60) + ABS(YR.TIME.IN.MINS.2) ;* set the absolute duration in minutes
    END

RETURN
*-----------------------------------------------------------------------------

CALC.DURATION:

    YR.TIME.IN.HOURS.1 = FIELD(YR.PW.ACTIVITY.TXN.END.TIME,':', 1) + 24 -  FIELD(YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME, ':', 1)
    YR.TIME.IN.MINS.1 = FIELD(YR.PW.ACTIVITY.TXN.END.TIME,':', 2) + 60 -  FIELD(YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME, ':', 2)
    YR.TIME.IN.HOURS.2 = YR.TIME.IN.HOURS.1 + FIELD(YR.TIME.IN.MINS.1/60,'.',1)
    YR.TIME.IN.MINS.2 = MOD(YR.TIME.IN.MINS.1,60)
    YR.TIME.IN.HOURS.2 = YR.TIME.IN.HOURS.2 - 1
    IF YR.TIME.IN.HOURS.2 GE 24 THEN
        YR.TIME.IN.HOURS.2 = MOD(YR.TIME.IN.HOURS.2,24)
        YR.NO.OF.DAYS += 1
    END
    IF YR.NO.OF.DAYS EQ 1 THEN
        YR.MONITOR.DURA = ABS(YR.TIME.IN.HOURS.2 * 60) + ABS(YR.TIME.IN.MINS.2) ;* set the absolute duration in minutes
    END ELSE
        YR.MONITOR.DURA =  ABS((YR.NO.OF.DAYS - 1) * 24 * 60) + ABS(YR.TIME.IN.HOURS.2 * 60) + ABS(YR.TIME.IN.MINS.2) ;* set the absolute duration in minutes
    END

RETURN
*-----------------------------------------------------------------------------

RETURN.DATA:

    YR.DETAIL = YR.PW.PROCESS.ID:'|':YR.PW.ACTIVITY.TXN.ID:'|':YR.PW.ACTIVITY.DESCRIPTION:'|':YR.PW.ACTIVITY.TXN.OWNER:'|':
    YR.DETAIL := YR.PW.ACTIVITY.TXN.USER:'|':YR.PW.ACTIVITY.TXN.START.DATE:'|':YR.PW.ACTIVITY.TXN.START.TIME:'|':YR.PW.ACTIVITY.TXN.DUE.DATE:'|':
    YR.DETAIL := YR.PW.ACTIVITY.TXN.COMPLETION.DATE:'|':YR.PW.ACTIVITY.TXN.PW.ACTIVITY.STATUS:'|':YR.PW.ACTIVITY.TXN.STATUS:'|':YR.PW.ACTIVITY.TXN.END.DATE:'|':
    YR.DETAIL := YR.PW.ACTIVITY.TXN.END.TIME:'|':YR.PW.ACTIVITY.TXN.MONITOR.INIT.DATE:'|':YR.PW.ACTIVITY.TXN.MONITOR.INIT.TIME:'|':YR.PW.ACTIVITY.TXN.MONITOR.DURATION

    YrDetails<-1> = YR.DETAIL

RETURN
*-----------------------------------------------------------------------------

END
