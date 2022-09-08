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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
* Version 7 29/09/00  GLOBUS Release No. G11.0.00 29/06/00
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.FX.POSITION

* This routine will build R.RECORD to be used by the FX POSITION ENQUIRY

**********************************************************************
* 16/05/96      GB9600642
*                       Make sure the the ID in ID.LIST has the '\MNE'
*                       appended to it so that multi company consolidation
*                       works correctly. Strip it out to read the DPC record
*
* 08/07/96 - GB9600907
*            Show opening position using ALFAL records
*
* 31/07/01 - GLOBUS_EN_10000052
*            Data consolidation by period
*
** 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 19/01/05 - CI_10026445
*            Removed the writing of R.RECORD into VOC to improve performance.
*
* 03/12/07 - CI_10052728
*            fix iconv for next period, just strip out spaces
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
******************************************************************************


    $USING ST.CurrencyConfig
    $USING PM.Config
    $USING EB.Display
    $USING PM.Reports
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF EB.SystemTables.getRunningUnderBatch() THEN
            PRINT EB.SystemTables.getText() : ' PM.FXPOS'
        END ELSE
            EB.Display.Rem()
        END
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
*
    RETURN


CONSOLIDATE.DPC.DATA:
*====================

    LAST.DATE = ""
    LINE.COUNT = 0

    LOOP
        REMOVE TEMP.ID FROM ID.LIST SETTING POINT1
        EB.Reports.setId(TEMP.ID)
        REMOVE MNEMON FROM MNEMON.LIST SETTING POINT2
    WHILE EB.Reports.getId()

        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)
        EB.Reports.setId(tmp.ID)
        tmp.ID = EB.Reports.getId()
        WCCY = FIELD(tmp.ID,'.',5)
        EB.Reports.setId(tmp.ID)
        IF V$DATE GT LAST.DATE THEN
            GOSUB INIT.LINE   ;* Initialise New Elemement
        END

        MAT DPC.REC = ''
        *
        * GB9600737
        *
        tmp.ID = EB.Reports.getId()
        DPC.ID = FIELD(tmp.ID,'*',1)
        EB.Reports.setId(tmp.ID)
        MATREAD DPC.REC FROM DPC.FILES(MNEMON),DPC.ID THEN
        *
        IF WCCY NE PM.Config.getCcy() THEN      ;* Convert to PM$CCY
            GOSUB CONVERT.RECORD
        END
        *
        *
        * GB9600737
        *

        * Sum takings and placings - remember takings (liabs) must be given
        * a negative sign.

        TAKINGS -= DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,2,1>
        L.TAKINGS -= DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,2,3>
        PLACINGS += DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,1,1>
        L.PLACINGS += DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,1,3>

        TXN.ARRAY := EB.Reports.getId():' '
    END

    REPEAT

* FINISH OFF

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)

* Remove leading value marks on multi value daily fields.

    FOR X = 3 TO 12
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<X,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    DEL TEMP.R.RECORD<19,1,0>
    EB.Reports.setRRecord(TEMP.R.RECORD)

    TOT.MOVEMENT = TOT.PLACINGS + TOT.TAKINGS
    L.TOT.MOVEMENT = L.TOT.PLACINGS + L.TOT.TAKINGS

* Add totals to R.RECORD

    tmp=EB.Reports.getRRecord(); tmp<20>=TOT.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21>=TOT.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<22>=TOT.MOVEMENT; EB.Reports.setRRecord(tmp)


    tmp=EB.Reports.getRRecord(); tmp<26>=LAST.DATE; EB.Reports.setRRecord(tmp);* store the final movement date.


    RETURN


INIT.LINE:
*=========

* Initialisation for each element / line

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

    LINE.COUNT += 1
    AMT.STR = ''
    TXN.ARRAY = ''
    TAKINGS = 0
    L.TAKINGS = 0
    PLACINGS = 0
    L.PLACINGS = 0

*
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCalendar) THEN
        LOOP
            NEXT.DATE.COUNT += 1
            LAST.DATE = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
            IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqDatePeriod) EQ 'PERIOD' THEN
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod)<1,NEXT.DATE.COUNT>
            END ELSE
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
                IF NEXT.PERIOD NE 1 THEN
                    NEXT.PERIOD = OCONV(ICONV(NEXT.PERIOD,'D') ,'D2E-')
                    CONVERT ' ' TO '' IN NEXT.PERIOD
                END ELSE
                    NEXT.PERIOD = "OPENING"
                END
            END
            IF LAST.DATE = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT+1> THEN
                LAST.DATE = 0
            END
        UNTIL (LAST.DATE GE V$DATE OR LAST.DATE EQ '*')
        REPEAT
        *
    END ELSE
        LAST.DATE = V$DATE
        * 10000052 ST
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
        IF NEXT.PERIOD EQ '' THEN
            IF LAST.DATE MATCHES "8N" THEN
                NEXT.PERIOD = OCONV(ICONV(LAST.DATE,'D') ,'D2E-')
            END ELSE
                NEXT.PERIOD = "OPENING" ; EB.Display.Txt(NEXT.PERIOD)
            END
        END
        CONVERT ' ' TO '' IN NEXT.PERIOD
    END
*
    RETURN


FIN.LINE:
*========

* Use LAST.DATE as by this stage date has been cycled forward to the next
* date.


    NET.MOVEMENT = PLACINGS + TAKINGS
    L.NET.MOVEMENT = L.PLACINGS + L.TAKINGS

* Update totals

    TOT.PLACINGS += PLACINGS
    L.TOT.PLACINGS += L.PLACINGS
    TOT.TAKINGS += TAKINGS
    L.TOT.TAKINGS += L.TAKINGS


    CONVERT @SM TO ' ' IN TXN.ARRAY

    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : NEXT.PERIOD; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : TAKINGS; EB.Reports.setRRecord(tmp)

    EB.Reports.setOData(L.PLACINGS:'*':PLACINGS:'*':PM.Config.getCcy())
    PM.Reports.CalcNetRate()
    tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : EB.Reports.getOData(); EB.Reports.setRRecord(tmp)

    EB.Reports.setOData(L.TAKINGS:'*':TAKINGS:'*':PM.Config.getCcy())
    PM.Reports.CalcNetRate()
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : EB.Reports.getOData(); EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<9>=EB.Reports.getRRecord()<9> : @VM : NET.MOVEMENT; EB.Reports.setRRecord(tmp)

    EB.Reports.setOData(L.NET.MOVEMENT:'*':NET.MOVEMENT:'*':PM.Config.getCcy())
    PM.Reports.CalcNetRate()
    tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : EB.Reports.getOData(); EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<19>=EB.Reports.getRRecord()<19> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

    RETURN


INITIALISE:
*==========

* Initialise all variables and open files.

    EB.SystemTables.setFCurrency('')
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    EB.DataAccess.Opf('F.CURRENCY',tmp.F.CURRENCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)

    ER1 = ''
    REC.CURRENCY = ''
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    tmp.PM$CCY = PM.Config.getCcy()
    CUR.REC = ST.CurrencyConfig.Currency.Read(tmp.PM$CCY, ER1)
* Before incorporation : CALL F.READ('F.CURRENCY',tmp.PM$CCY,CUR.REC,tmp.F.CURRENCY,ER1)
    PM.Config.setCcy(tmp.PM$CCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    IF NOT(ER1) THEN
        CUR.BASIS = CUR.REC<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
        CUR.QUOTE = CUR.REC<ST.CurrencyConfig.Currency.EbCurQuotationCode>
        CUR.BASIS = CUR.BASIS[1,1]
        IF CUR.BASIS EQ 'A' OR CUR.BASIS EQ 'B' THEN
            DAYS.BASIS = 36000
            DAYS.IN.YEAR = 360
        END ELSE
            DAYS.BASIS = 36500
            DAYS.IN.YEAR = 365
        END
    END

    tmp.TODAY = EB.SystemTables.getToday()
    I.TODAY = ICONV(tmp.TODAY, 'D')
    EB.SystemTables.setToday(tmp.TODAY)
    NEXT.DATE.COUNT = 0

    DIM DPC.REC(50)
    DIM DPC.FILES(50)
    AMT.STR = ''

    TOT.PLACINGS = 0
    L.TOT.PLACINGS = 0
    TOT.TAKINGS = 0
    L.TOT.TAKINGS = 0


    RETURN
*
*------------------------------------------------------------------
CONVERT.RECORD:
*==============
** Perform conversion to EUR or other fixed ccy using exchange rate
*
    tmp.PM$CCY = PM.Config.getCcy()
    PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, tmp.PM$CCY)
    PM.Config.setCcy(tmp.PM$CCY)
*
    RETURN


******
    END
