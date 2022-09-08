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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>671</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.BUILD.PL.REPORT.WORK(ENQUIRY.DATA)
*
*
************************************************************************
*
* 05/04/99 - GB9900216
*            Builds RE.PL.REPORT.WORK file to be used in the
*            enquiry RE.PL.REPORT
*
* 12/03/07 - EN_10003255
*            Modified to call DAS to select data.
*
* 19/10/08 - BG_100020360
*            Removed dasIsAnOptionalField assignment for the THE.ARG variable and
*            Used separate id's when two dates and single dates are given
********************************************************************************
*
    $INSERT I_DAS.RE.STAT.LINE.BAL
    $INSERT I_DAS.RE.PL.REPORT.WORK
    $USING EB.DataAccess
    $USING EB.Utility
    $USING EB.Reports
    $USING RE.ReportGeneration
    $USING RE.YearEnd
    $USING RE.Config
    $USING EB.SystemTables
    
    GOSUB INITIALISATION
*
* Check calling ENQUIRY
*
*
    ENQ.NAME = ENQUIRY.DATA<1,1>

    GOSUB DELETE.RECORDS

    LINE.NOS = ""
    LOCATE "SEL.REP.LINES" IN ENQUIRY.DATA<2,1> SETTING LINE.POS THEN
    LINE.NOS = ENQUIRY.DATA<4,LINE.POS>
    CONVERT " " TO @FM IN LINE.NOS
    END
*
    LINE.NO.1 = LINE.NOS<1>
    LINE.NO.2 = LINE.NOS<2>
    LINE.NO.3 = LINE.NOS<3>
*
    LOCATE "SEL.DATE" IN ENQUIRY.DATA<2,1> SETTING SYSD.POS THEN
    SYSDTE = ENQUIRY.DATA<4,SYSD.POS>
    CONVERT " " TO @VM IN SYSDTE
    NO.OF.DATES=DCOUNT(SYSDTE,@VM)
    FOR I=1 TO NO.OF.DATES
        IF SYSDTE<1,I> = '!TODAY' THEN SYSDTE<1,I> = EB.SystemTables.getToday()
        IF SYSDTE<1,I> = '!PERIOD' THEN SYSDTE<1,I> = PERIOD.END
    NEXT I
    IF NO.OF.DATES GT 2 OR SYSDTE = "ALL" THEN
        EB.Reports.setEnqError("ONLY TWO DATES REQUIRED FOR RANGE")
        RETURN
    END ELSE
        SYSDTE.FROM=SYSDTE<1,1>
        SYSDTE.TO=SYSDTE<1,2>
    END
    END ELSE SYSDTE = ""

    GOSUB SELECT.BAL.FILE
*
    IF EB.Reports.getEnqError()<> "" THEN GOTO PROGRAM.ABORT
*
    GOSUB PROCESS.RECORDS
*
    RETURN
*
*=========================================================================
* SUBROUTINES
*=========================================================================
*
INITIALISATION:
*-------------
*
** Set local variables
*
    EB.Reports.setEnqError("")
*
** Open files
*
    F.RE.STAT.LINE.BAL = ""
    F.RE.STAT.LINE.BAL.NAME = "F.RE.STAT.LINE.BAL"
    EB.DataAccess.Opf(F.RE.STAT.LINE.BAL.NAME,F.RE.STAT.LINE.BAL)
*
    F.RE.PL.REPORT.WORK = ""
    F.RE.PL.REPORT.WORK.NAME = "F.RE.PL.REPORT.WORK"
    EB.DataAccess.Opf(F.RE.PL.REPORT.WORK.NAME,F.RE.PL.REPORT.WORK)
*
    PERIOD.END = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)
*
    RETURN
*
*------------------------------------------------------------------------
*
DELETE.RECORDS:
*-------------

    PL.REP.LIST   = dasRePlReportWorkIdLike
    THE.ARGS      = EB.SystemTables.getOperator() : '-' : ENQ.NAME : '...'
    TABLE.SUFFIX  = ''
    EB.DataAccess.Das ('RE.PL.REPORT.WORK', PL.REP.LIST, THE.ARGS, TABLE.SUFFIX)


    LOOP

        REMOVE PL.REP.ID FROM PL.REP.LIST SETTING PL.REP.POS

    WHILE PL.REP.ID:PL.REP.POS

        DELETE F.RE.PL.REPORT.WORK,PL.REP.ID

    REPEAT

    RETURN
*
*-------------------------------------------------------------------------
*
SELECT.BAL.FILE:
*--------------
*
    THE.ARGS     = ''
    TABLE.SUFFIX = ''

    THE.ARGS<1>=LINE.NO.1
    THE.ARGS<2>=LINE.NO.2
    THE.ARGS<3>=LINE.NO.3
    THE.ARGS<4>=SYSDTE.FROM
    THE.ARGS<5>=SYSDTE.TO

    IF SYSDTE.TO THEN
        BAL.ID.LIST  = dasReStatLineBalForEBuildPlReportWork
    END ELSE
        BAL.ID.LIST  = dasReStatLineBalForeEqPeriodEndPlReportWork
    END

    MVMT.ID.LIST = ""
    EB.DataAccess.Das('RE.STAT.LINE.BAL',BAL.ID.LIST,THE.ARGS,TABLE.SUFFIX)
*
    RETURN
*
*-----------------------------------------------------------------------
*
PROCESS.RECORDS:
*--------------

    R.RE.PL.REPORT.WORK = ""
    LAST.PERIOD.DATE = ""
    LAST.CURRENCY = ""
    STARTS.RECORD = 1

    LOOP

        REMOVE BAL.ID FROM BAL.ID.LIST SETTING BAL.ID.POS

    WHILE BAL.ID:BAL.ID.POS

        LINE.NAME = FIELD(BAL.ID,"-",1,2)
        PERIOD.DATE = FIELD(BAL.ID,"-",4)
        CURRENCY = FIELD(BAL.ID,"-",3)

        GOSUB READ.BAL.REC

        BEGIN CASE

            CASE PERIOD.DATE NE LAST.PERIOD.DATE
                CURRENCY.POS = 1
                IF R.RE.PL.REPORT.WORK THEN
                    PL.REPORT.ID = EB.SystemTables.getOperator():'-':ENQ.NAME:"-":LAST.PERIOD.DATE
                    GOSUB WRITE.RE.PL.REPORT.WORK
                    R.RE.PL.REPORT.WORK = ""
                END
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkCurrency,CURRENCY.POS> = CURRENCY

            CASE CURRENCY NE LAST.CURRENCY
                CURRENCY.POS += 1
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkCurrency,CURRENCY.POS> = CURRENCY

        END CASE

        LAST.PERIOD.DATE = PERIOD.DATE
        LAST.CURRENCY = CURRENCY

        *
        ** Now process the record
        *
        BEGIN CASE

            CASE LINE.NAME EQ LINE.NO.1
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountFcyOne,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBal>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountLcyOne,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBalLcl>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkMvmtLineOne,CURRENCY.POS> = LINE.NO.1:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                IF STARTS.RECORD THEN
                    MVMT.LINE = LINE.NO.1:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END ELSE
                    MVMT.LINE := " ":LINE.NO.1:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END

            CASE LINE.NAME EQ LINE.NO.2
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountFcyTwo,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBal>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountLcyTwo,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBalLcl>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkMvmtLineTwo,CURRENCY.POS> = LINE.NO.2:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                IF STARTS.RECORD THEN
                    MVMT.LINE = LINE.NO.2:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END ELSE
                    MVMT.LINE := " ":LINE.NO.2:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END

            CASE LINE.NAME EQ LINE.NO.3
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountFcyThr,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBal>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkAmountLcyThr,CURRENCY.POS> = R.RE.STAT.LINE.BAL<RE.ReportGeneration.StatLineBal.SlbClosingBalLcl>
                R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkMvmtLineThr,CURRENCY.POS> = LINE.NO.3:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                IF STARTS.RECORD THEN
                    MVMT.LINE = LINE.NO.3:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END ELSE
                    MVMT.LINE := " ":LINE.NO.3:"-":CURRENCY:"-":PERIOD.DATE:"-P"
                END

        END CASE

        STARTS.RECORD = 0
    REPEAT


    IF R.RE.PL.REPORT.WORK THEN
        PL.REPORT.ID = EB.SystemTables.getOperator():'-':ENQ.NAME:"-":LAST.PERIOD.DATE
        GOSUB WRITE.RE.PL.REPORT.WORK
    END

    RETURN
*-------------------------------------------------------------------------
*
READ.BAL.REC:
*------------
*
    R.RE.STAT.LINE.BAL = "" ; ER = ""
    R.RE.STAT.LINE.BAL = RE.ReportGeneration.StatLineBal.Read(BAL.ID, ER)
*
    RETURN
*
*---------------------------------------------------------------------
*
WRITE.RE.PL.REPORT.WORK:
*----------------------

    R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkReLineOne> = LINE.NO.1
    R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkReLineTwo> = LINE.NO.2
    R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkReLineThr> = LINE.NO.3
    R.RE.PL.REPORT.WORK<RE.YearEnd.PlReportWork.PlrepWorkMvmtLine> = MVMT.LINE
    WRITE R.RE.PL.REPORT.WORK TO F.RE.PL.REPORT.WORK,PL.REPORT.ID
    STARTS.RECORD = 1

    RETURN
*
*----------------------------------------------------------------------
*
PROGRAM.ABORT:
*------------
*
    RETURN
*
*
    END
