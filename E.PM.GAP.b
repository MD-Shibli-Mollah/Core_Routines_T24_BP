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
* <Rating>-144</Rating>
*-----------------------------------------------------------------------------
* Version 6 29/09/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.GAP

* This routine will build R.RECORD for the PMGAP analysis enquiry
* The layout of the R.RECORD is defined by the
* standard selection record NOFILE.PM.AVG.RATES.

**********************************************************************
* 16/05/96      GB9600737
*                       Make sure the the ID in ID.LIST has the '\MNE'
*                       appended to it so that multi company consolidation
*                       works correctly. Strip it out to read the DPC record
*
* 31/07/01 - GLOBUS_EN_10000052
*            Data consolidation by period
*
* 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 19/01/05 - CI_10026445
*            Removed the writing of R.RECORD into VOC to improve performance.
*
* 24/01/07 - CI_10046838
*            cater for multi valued banded interest rates related to amount
*
*
* 03/12/07 - CI_10052728
*            fix iconv for next period, just strip out spaces
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
******************************************************************************



    $USING  ST.CurrencyConfig
    $USING  PM.Config
    $USING  PM.Reports
    $USING  ST.CompanyCreation
    $USING  EB.DataAccess
    $USING  EB.SystemTables
    $USING  EB.Reports


    GOSUB INITIALISE
    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        RETURN
    END

    GOSUB CONSOLIDATE.DPC.DATA

    RETURN



**************************************************************************
*                       INTERNAL ROUTINES
**************************************************************************

SELECT.DLY.POSN.CLASS:
*=====================

* Call E.PM.SEL.POSN.CLASS to get a list of PM.DLY.POSN.CLASS IDs and
* associated file mnemonics required. This routine requires an ID to the
* PM.ENQ.PARAM file which defines the records required for the enquiry.
* In addition information regarding the signing conventions required for
* the enquiry are returned. The PM.ENQ.PARAM will have already been
* loaded in the labelled common area (I_PM.ENQ.PARAM) by the routine
*  E.PM.INT.COMMON.

    ENQ.PARAM.ID = EB.Reports.getOData()
    ID.LIST = ''
    MNEMON.LIST = ""

    PM.Reports.EPmSelPosnClass(ID.LIST, MNEMON.LIST, MAT DPC.FILES)

    RETURN

****************************************************************************
CONSOLIDATE.DPC.DATA:
*====================

* Loop through all the position class records selected and consolidate
* them by date, asset or liability and insterest code.

    LAST.DATE = ""
    LINE.COUNT = 0

    LOOP
        TEMP.ID = EB.Reports.getId()
        REMOVE TEMP.ID FROM ID.LIST SETTING POINT1
        EB.Reports.setId(TEMP.ID)
        REMOVE MNEMON FROM MNEMON.LIST SETTING POINT2
    WHILE EB.Reports.getId()

        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)
        EB.Reports.setId(tmp.ID)
        IF V$DATE GT LAST.DATE THEN
            GOSUB INIT.LINE   ;* Initialise New Elemement
        END

        MAT DPC.REC = ''
        *
        tmp.ID = EB.Reports.getId()
        DPC.ID = FIELD(tmp.ID,'*',1)
        EB.Reports.setId(tmp.ID)
        MATREAD DPC.REC FROM DPC.FILES(MNEMON),DPC.ID THEN
        GOSUB PROCESS.DPC
    END

SKIP.REC:

    REPEAT

* FINISH OFF

    GOSUB FINISH.OFF

    RETURN

*******************************************************************************************
INIT.LINE:
*=========

* Initialisation for each date.

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

    LINE.COUNT += 1
    AMT.STR = ''
    INT.STR = ''
    TXN.ARRAY = ''
    PRIN.AMT = 0
    PRIN.AMT<2> = 0
    AVG.RATE = ''
    ANNUAL.INT = ''
    ACTUAL.INT = ''
    WEIGHTED.PRIN = ''

*
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCalendar) THEN
        LOOP
            NEXT.DATE.COUNT += 1
            LAST.DATE = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
            IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqDatePeriod) EQ 'PERIOD' THEN
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod)<1,NEXT.DATE.COUNT>
            END ELSE
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
                NEXT.PERIOD = OCONV(ICONV(NEXT.PERIOD,'D') ,'D2E-')
            END
            CONVERT ' ' TO '' IN NEXT.PERIOD
        UNTIL (LAST.DATE GE V$DATE)
        REPEAT
        *
    END ELSE
        LAST.DATE = V$DATE
        IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqConsolPeriod) NE 'D' THEN
            IF LEN(LAST.DATE) LT 8 THEN
                LAST.DATE = EB.SystemTables.getToday()
            END
            tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqConsolPeriod = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqConsolPeriod)
            ST.CompanyCreation.PeriodEndDate(tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqConsolPeriod,LAST.DATE,NEXT.PERIOD)
            PM.Config.setRPmEnqParam(PM.Reports.EnqParam.EnqConsolPeriod, tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqConsolPeriod)
            LAST.DATE = NEXT.PERIOD
            NEXT.PERIOD = OCONV(ICONV(NEXT.PERIOD,'D'),'D2E-')
        END ELSE
            NEXT.PERIOD = OCONV(ICONV(LAST.DATE,'D') ,'D2E-')
        END
        CONVERT ' ' TO '' IN NEXT.PERIOD
    END
*
    RETURN


*****************************************************************************************
PROCESS.DPC:
************

    DPC.CCY = DPC.ID['.',5,1]
    IF DPC.CCY NE PM.Config.getCcy() THEN
        TEMP.PM$CCY = PM.Config.getCcy()
        PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, TEMP.PM$CCY)
        PM.Config.setCcy(TEMP.PM$CCY)
    END

* Sum takings and placings - remember takings (liabs) must be given
* a negative sign.

    TXN.ARRAY := EB.Reports.getId():@SM

* Loop through all interest codes and amounts and consolidate the asset
* and liability amounts by interest code in the arrays INT.STR and
* INT.STR.

    FOR ASST.LIAB = 1 TO 2
        XX = 10
        LOOP
            INT.CODE = DPC.REC(PM.Config.DlyPosnClass.DpcAmtCode)<1,ASST.LIAB,XX>
        WHILE INT.CODE
            AMT = DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,ASST.LIAB,XX>
            IF ASST.LIAB = 2 THEN
                AMT = AMT * -1          ;* Liabs are -ve
            END
            PRIN.AMT<ASST.LIAB> += AMT
            IF INT.CODE[1,1] EQ 'F' THEN
                INT.CODE = INT.CODE:'*':DPC.REC(PM.Config.DlyPosnClass.DpcAvgRate)<1,ASST.LIAB,XX>
            END
            LOCATE INT.CODE IN INT.STR<ASST.LIAB, 1> SETTING I.POS THEN
            AMT.STR<ASST.LIAB, I.POS> += AMT
        END ELSE
            INS INT.CODE BEFORE INT.STR<ASST.LIAB, I.POS>
            INS AMT BEFORE AMT.STR<ASST.LIAB, I.POS>
        END
        XX += 1
    REPEAT
    NEXT ASST.LIAB

    RETURN

****************************************************************************************************
FINISH.OFF:
***********

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

* Final updates to R.RECORD.

    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<2>=BASIS; EB.Reports.setRRecord(tmp)

* Remove leading value marks

    FOR X = 3 TO 14
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<X,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    DEL TEMP.R.RECORD<30,1,0>
    EB.Reports.setRRecord(TEMP.R.RECORD)

* Finally calculate the average and weighted average interest rates for
* both assets and liabilities.

    FOR AL = 1 TO 2
        IF TOT.PRIN.AMT<AL> THEN
            AVG.INT.RATE<AL> = TOT.ANNUAL.INT<AL> / TOT.PRIN.AMT<AL>
        END ELSE
            AVG.INT.RATE = 0
        END
    NEXT AL

    tmp=EB.Reports.getRRecord(); tmp<20>=AVG.INT.RATE<1>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21>=AVG.INT.RATE<2>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<26>=LAST.DATE; EB.Reports.setRRecord(tmp);* Record the final date


* SET VM.COUNT prior to returning to the enquiry.

    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<3>, @VM))

    RETURN

***********************************************************************************************
FIN.LINE:
*=========


* Get the actual interest rates and therefore the annual interest amount
* for both the assets and the laibilites. Also calculate the
* remaining interest to be paid.  A weighted principal amount is also
* calculated. These three items are then summed for all dates so that
* the averagfe and weighted avreage rates can be calculated.

    FOR ASST.LIAB = 1 TO 2
        XX = 1
        ANNUAL.INT<ASST.LIAB> = 0
        LOOP
            INT.CODE = INT.STR<ASST.LIAB,XX>
        WHILE INT.CODE
            AMT = AMT.STR<ASST.LIAB,XX>
            GOSUB GET.RATE
            ANNUAL.INT<ASST.LIAB> += AMT * RATE
            XX += 1
        REPEAT

        IF PRIN.AMT<ASST.LIAB> THEN
            AVG.RATE<ASST.LIAB> = ANNUAL.INT<ASST.LIAB> / PRIN.AMT<ASST.LIAB>
        END

        TOT.PRIN.AMT<ASST.LIAB> += PRIN.AMT<ASST.LIAB>
        TOT.ANNUAL.INT<ASST.LIAB> += ANNUAL.INT<ASST.LIAB>
        TOT.ACTUAL.INT<ASST.LIAB> += ACTUAL.INT<ASST.LIAB>
        TOT.WEIGHTED.PRIN<ASST.LIAB> += WEIGHTED.PRIN<ASST.LIAB>

    NEXT ASST.LIAB


* Update totals


    CONVERT @SM TO ' ' IN TXN.ARRAY

* Update R.RECORD

    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : NEXT.PERIOD; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : PRIN.AMT<1>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : PRIN.AMT<2>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : AVG.RATE<1>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : AVG.RATE<2>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=EB.Reports.getRRecord()<13> : @VM : ANNUAL.INT<1>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<14>=EB.Reports.getRRecord()<14> : @VM : ANNUAL.INT<2>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<30>=EB.Reports.getRRecord()<30> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

    RETURN


GET.RATE:
*========

    INT.CODE<2> = AMT
    TEMP.PM$CCY = PM.Config.getCcy()
    PM.Reports.EPmAcRates(INT.CODE, TEMP.PM$CCY, BASIS, ASST.LIAB, RATE)
    PM.Config.setCcy(TEMP.PM$CCY)
    INT.CODE = INT.CODE<1>

    RETURN


INITIALISE:
*==========

* Initialise all variables and open files.

    EB.SystemTables.setFCurrency('')
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    EB.DataAccess.Opf('F.CURRENCY',tmp.F.CURRENCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)

    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    CURR.ERR = ''
    CURR.REC = ST.CurrencyConfig.Currency.Read(PM.Config.getCcy()<1,1>, CURR.ERR)
* Before incorporation : CALL F.READ('F.CURRENCY',PM.Config.getCcy()<1,1>,CURR.REC,tmp.F.CURRENCY,CURR.ERR)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    CUR.BASIS = CURR.REC<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
    IF CUR.BASIS THEN
        CUR.BASIS = CUR.BASIS[1,1]
        IF CUR.BASIS EQ 'A' OR CUR.BASIS EQ 'B' THEN
            BASIS = 360
        END ELSE
            BASIS = 365
        END
    END

    DIM DPC.REC(50)
    DIM DPC.FILES(50)
    INT.STR = ''
    AMT.STR = ''
    NEXT.DATE.COUNT = 0

    TOT.PRIN.AMT = 0
    TOT.PRIN.AMT<2> = 0
    TOT.ANNUAL.INT = 0
    TOT.ACTUAL.INT = 0
    TOT.WEIGHTED.PRIN = 0

    AVG.INT.RATE = ''
    AVG.WEIGHTED.RATE = ''

    RETURN


******
    END
