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
* <Rating>208</Rating>
*-----------------------------------------------------------------------------
* Version 7 29/09/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.NET.PRESENT.VALUE

* This routine will build R.RECORD to be used by the what if P&L enquiry.
* Interest is calculated on each balance on the system based on the 01
* yeild curve and also on a second yeild curve input by the user.

**********************************************************************
* 16/05/96      GB9600737
*                       Make sure the the ID in ID.LIST has the '\MNE'
*                       appended to it so that multi company consolidation
*                       works correctly. Strip it out to read the DPC record
*
* 05/12/96      GB9601687 
*                 Set the date for OPE balances from 1 to today
*
** 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
**********************************************************************



    $USING  ST.CurrencyConfig
    $USING  PM.Config
    $USING  EB.Display
    $USING  PM.Reports
    $USING  ST.ExchangeRate
    $USING  EB.DataAccess
    $USING  EB.SystemTables
    $USING  EB.Reports


    GOSUB INITIALISE

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF (EB.SystemTables.getRunningUnderBatch()) THEN
            PRINT EB.SystemTables.getText() : ' PM.NPV'
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
        IF V$DATE = 1 THEN V$DATE = EB.SystemTables.getToday()
        IF V$DATE NE LAST.DATE THEN
            GOSUB INIT.LINE              ; * Initialise New Elemement
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
        WCCY = DPC.ID['.',5,1]
        IF WCCY NE PM.Config.getCcy() THEN
            TEMP.PM$CCY = PM.Config.getCcy()
            PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, TEMP.PM$CCY)
            PM.Config.setCcy(TEMP.PM$CCY)
        END
        *
        * GB9600737
        *

        * Sum takings and placings - remember takings (liabs) must be given
        * a negative sign.

        TAKINGS -= DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,2,1>
        PLACINGS += DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,1,1>

        TXN.ARRAY := EB.Reports.getId():@SM
    END

    LAST.DATE = V$DATE

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
    TOT.PV.MOVEMENT = TOT.PV.PLACINGS + TOT.PV.TAKINGS

* Add totals to R.RECORD

    tmp=EB.Reports.getRRecord(); tmp<20>=TOT.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21>=TOT.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<22>=TOT.MOVEMENT; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<23>=TOT.PV.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<24>=TOT.PV.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<25>=TOT.PV.MOVEMENT; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<26>=LAST.DATE; EB.Reports.setRRecord(tmp); * store the final movement date.

    OPEN '','VOC' TO VOC ELSE STOP
        WRITE EB.Reports.getRRecord() TO VOC,'YYY'

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
            PLACINGS = 0

            RETURN


FIN.LINE:
            *========

            * Use LAST.DATE as by this stage date has been cycled forward to the next
            * date.

            DAYS = (ICONV(LAST.DATE,'D')) - I.TODAY
            IF DAYS < 0 THEN DAYS = 0

            * Get the mid rate for the valuation yield curve - ie periodic interest 01
            * and calculate the discount factor.

            YEILD.CURVE = "01"
            VAL.PLAC.RATE = 0 ; VAL.TAK.RATE = 0 ; VAL.MID.RATE = 0
            GOSUB GET.YEILD.CURVE.RATE

            FACTOR = 1 / (1 + ((MID.RATE * DAYS) / (DAYS.BASIS)))
            IF EB.SystemTables.getEtext() THEN
                FACTOR = 0
                EB.SystemTables.setEtext('')
            END

            NET.MOVEMENT = PLACINGS + TAKINGS

            PV.PLACINGS = PLACINGS * FACTOR
            PV.TAKINGS = TAKINGS * FACTOR
            PV.MOVEMENT = NET.MOVEMENT * FACTOR

            * Update totals

            TOT.PLACINGS += PLACINGS
            TOT.TAKINGS += TAKINGS

            TOT.PV.PLACINGS += PV.PLACINGS
            TOT.PV.TAKINGS += PV.TAKINGS

            CONVERT @SM TO ' ' IN TXN.ARRAY

            tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : LAST.DATE; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<4>=EB.Reports.getRRecord()<4> : @VM : DAYS; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : MID.RATE; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : FACTOR; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : PLACINGS; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : TAKINGS; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<9>=EB.Reports.getRRecord()<9> : @VM : NET.MOVEMENT; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : PV.PLACINGS; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<11>=EB.Reports.getRRecord()<11> : @VM : PV.TAKINGS; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<12>=EB.Reports.getRRecord()<12> : @VM : PV.MOVEMENT; EB.Reports.setRRecord(tmp)

            tmp=EB.Reports.getRRecord(); tmp<19>=EB.Reports.getRRecord()<19> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

            RETURN


GET.YEILD.CURVE.RATE:
            *====================

            RETURN.CODE = ''
            PLAC.RATE = ''
            tmp.PM$CCY = PM.Config.getCcy()
            ST.ExchangeRate.Termrate('',YEILD.CURVE,'',tmp.PM$CCY,'','O','',LAST.DATE,'YES',PLAC.RATE,'','','','',RETURN.CODE)
            PM.Config.setCcy(tmp.PM$CCY)
            IF RETURN.CODE THEN
                CRT @(1,20):EB.SystemTables.getEtext()
                RETURN.CODE = ''
            END

            TAK.RATE = ''
            tmp.PM$CCY = PM.Config.getCcy()
            ST.ExchangeRate.Termrate('',YEILD.CURVE,'',tmp.PM$CCY,'','B','',LAST.DATE,'YES',TAK.RATE,'','','','',RETURN.CODE)
            PM.Config.setCcy(tmp.PM$CCY)
            IF RETURN.CODE THEN
                CRT @(1,20):EB.SystemTables.getEtext()
            END

            PLAC.RATE = ABS(PLAC.RATE)
            TAK.RATE = ABS(TAK.RATE)
            MID.RATE = (PLAC.RATE + TAK.RATE) / 2

            RETURN


INITIALISE:
            *==========

            * Initialise all variables and open files.

            EB.SystemTables.setFCurrency('')
            tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
            EB.DataAccess.Opf('F.CURRENCY',tmp.F.CURRENCY)
            EB.SystemTables.setFCurrency(tmp.F.CURRENCY)


            CURR.ERR = ''
            CURR.REC = ''
            tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
            CURR.REC = ST.CurrencyConfig.Currency.Read(PM.Config.getCcy()<1,1>, CURR.ERR)
            * Before incorporation : CALL F.READ('F.CURRENCY',PM.Config.getCcy()<1,1>,CURR.REC,tmp.F.CURRENCY,CURR.ERR)
            EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
            CUR.BASIS = CURR.REC<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
            IF CUR.BASIS THEN
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

            DIM DPC.REC(50)
            DIM DPC.FILES(50)
            AMT.STR = ''

            TOT.PLACINGS = 0
            TOT.TAKINGS = 0
            TOT.PV.PLACINGS = 0
            TOT.PV.TAKINGS = 0


            RETURN


******
        END
