* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>94</Rating>
*-----------------------------------------------------------------------------
 $PACKAGE EB.ModelBank

 SUBROUTINE E.BATCH.DATES 
*

* Version 7 02/06/00  GLOBUS Release No. 200508 30/06/05
* 18/12/98 - GB9801587
*            The Enquiry E.BATCH.DATES,does not check for
*            the NEXT.RUN.DATE less than TODAY and reports
*             it as incorrectly setup job.
*  
* 30/05/03 - EN_10001913
*            DATE.CHANGE now runs at FIN level
*
* 28/07/02 - BG_10004887
*            Don't check daily jobs as they always run now
*
* 29/07/03 - EN_10001891
*            Only flag jobs which are not daily and have next date
*            between today and nwd
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated

*-----------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Utility
    $USING EB.Service
 
*-----------------------------------------------------------------------

    VCOUNT = DCOUNT(EB.Reports.getRRecord()<EB.Service.Batch.BatJobName>, @VM)
    R.RECORD.SAVE = EB.Reports.getRRecord()
    EB.Reports.setRRecord('')
    EB.Reports.setVmCount(0)
    NEXT.WORKING.DAY = EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)
*
    FOR I = 1 TO VCOUNT
        ADD.JOB = ''
        *
        IF R.RECORD.SAVE<EB.Service.Batch.BatBatchStage>[1,1] MATCHES 'D':@VM:'O' THEN
            CHECK.DATE = NEXT.WORKING.DAY
            LAST.DATE = EB.SystemTables.getToday()
        END ELSE
            CHECK.DATE = EB.SystemTables.getToday()
            LAST.DATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)
        END
        *
        BEGIN CASE
            CASE R.RECORD.SAVE<EB.Service.Batch.BatFrequency,I> = "D"
                *
            CASE R.RECORD.SAVE<EB.Service.Batch.BatNextRunDate,I> GT CHECK.DATE
                *
            CASE R.RECORD.SAVE<EB.Service.Batch.BatFrequency,I> = "A" AND R.RECORD.SAVE<EB.Service.Batch.BatNextRunDate, I> = ''
                *
            CASE R.RECORD.SAVE<EB.Service.Batch.BatFrequency,I> = "A" AND R.RECORD.SAVE<EB.Service.Batch.BatNextRunDate,I> LE LAST.DATE
                *
            CASE R.RECORD.SAVE<EB.Service.Batch.BatNextRunDate, I> LT CHECK.DATE
                ADD.JOB = 1
                *
            CASE 1
                *
        END CASE
        *
        IF ADD.JOB THEN
            EB.Reports.setVmCount(EB.Reports.getVmCount() + 1)
            FOR J = EB.Service.Batch.BatJobName TO EB.Service.Batch.BatUser
                VM.CNT.VAL = EB.Reports.getVmCount()
                tmp=EB.Reports.getRRecord(); tmp<J,VM.CNT.VAL>=R.RECORD.SAVE<J,I>; EB.Reports.setRRecord(tmp)
            NEXT J
        END
    NEXT I
    IF EB.Reports.getRRecord() = '' THEN EB.Reports.setOData('OK')

*-----------------------------------------------------------------------
    RETURN
    END
