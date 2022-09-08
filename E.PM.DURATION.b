* @ValidationCode : MjotMTQwODEyODkxODpDcDEyNTI6MTUwNzgxMzk4MDY1OTpkc3JhbXlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwOC4yMDE3MDcxNy0yMjM4Oi0xOi0x
* @ValidationInfo : Timestamp         : 12 Oct 2017 18:43:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dsramya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.20170717-2238
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>67</Rating>
*-----------------------------------------------------------------------------
* Version 7 29/09/00  GLOBUS Release No. 200508 30/06/05
$PACKAGE PM.Reports
SUBROUTINE E.PM.DURATION


* This routine will build R.RECORD to be used by the what if P&L enquiry.
* Interest is calculated on each balance on the system based on the 01
* yeild curve and also on a second yeild curve input by the user.

**********************************************************************
* 16/05/96  GB9600737
*           Make sure the the ID in ID.LIST has the '\MNE'
*           appended to it so that multi company consolidation
*           works correctly. Strip it out to read the DPC record
*
* 28/09/98 - GB9801153
*            Convert NCU to EUR if required
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
* 01/11/15 - EN_1226121/Task 1499688
*            Incorporation of routine
*
* 10/10/17 - Defect 2288697 / Task 2301207
*            In Enquiry PM.DURATION the total showing for Net Movement, Asset Duration,
*            Liability Duration and Net Duration is not sync with manual calculation.
*
******************************************************************************



    $USING ST.CurrencyConfig
    $USING PM.Config
    $USING EB.Display
    $USING PM.Reports
    $USING ST.ExchangeRate
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF (EB.SystemTables.getRunningUnderBatch()) THEN
            PRINT EB.SystemTables.getText() : ' PM.DURATION'
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

*        IF @LOGNAME = 'd05008' THEN PRINT 'ID = ':ID
        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)
        EB.Reports.setId(tmp.ID)
*
* Cater for OPE calendar, which splits Opening position from
* Positions booked today ie. CAL
*
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
                tmp.PM$CCY = PM.Config.getCcy()
                PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, tmp.PM$CCY)
                PM.Config.setCcy(tmp.PM$CCY)
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

* Calaculate the proportion of the discounted movement on each day for
* assets and liabilities. This is then used to calculate the duration
* for each day and the total duration for the asset and liability books.

    GOSUB CALC.PROPORTIONS.AND.DURATION

* Add totals to R.RECORD

    tmp=EB.Reports.getRRecord(); tmp<20>=TOT.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21>=TOT.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<22>=TOT.MOVEMENT; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<23>=TOT.PV.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<24>=TOT.PV.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<25>=TOT.PV.MOVEMENT; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<30>=TOT.ASSET.DURA; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<31>=TOT.LIAB.DURA; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<32>=TOT.NET.DURA; EB.Reports.setRRecord(tmp)


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
    
*  Round Values
    Value = PV.PLACINGS
    GOSUB ROUND.VALUES
    PV.PLACINGS = Value

    Value = PV.TAKINGS
    GOSUB ROUND.VALUES
    PV.TAKINGS = Value
    

* Update totals

    TOT.PLACINGS += PLACINGS
    TOT.TAKINGS += TAKINGS

    TOT.PV.PLACINGS += PV.PLACINGS
    TOT.PV.TAKINGS += PV.TAKINGS

    CONVERT @SM TO ' ' IN TXN.ARRAY

    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : LAST.DATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<4>=EB.Reports.getRRecord()<4> : @VM : DAYS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : FACTOR; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : NET.MOVEMENT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<9>=EB.Reports.getRRecord()<9> : @VM : PV.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : PV.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=EB.Reports.getRRecord()<11> : @VM : PV.MOVEMENT; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<19>=EB.Reports.getRRecord()<19> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

RETURN

ROUND.VALUES:
*=============================

* Round the value to the no of decimals
* No od decimals considered from the CURRENCY table for the respective currency

    Mask = 'MD':CUR.DECIMAL ;* Set conversion

    Value = OCONV(ICONV(Value,Mask),Mask)  ;* Round rate

RETURN

CALC.PROPORTIONS.AND.DURATION:
*=============================

* Calculate the sasset and liablitiy durations for each date on which
* movements occur as well as the total for the book. Note that liab
* durations are recorded as negative figures.

    TOT.ASSET.DURA = 0
    TOT.LIAB.DURA = 0
    TOT.NET.DURA = 0

    DAYS.STR = EB.Reports.getRRecord()<4>
    PV.ASSET.STR = EB.Reports.getRRecord()<6>
    PV.LIAB.STR = EB.Reports.getRRecord()<7>
    PV.NET.STR = EB.Reports.getRRecord()<8>

    LOOP
        REMOVE NO.OF.DAYS FROM DAYS.STR SETTING D.DELIM
        REMOVE ASSET.AMT FROM PV.ASSET.STR SETTING A.DELIM
        REMOVE LIAB.AMT FROM PV.LIAB.STR SETTING L.DELIM
        REMOVE NET.AMT FROM PV.NET.STR SETTING N.DELIM

        ASSET.PROP = ASSET.AMT / TOT.PV.PLACINGS
        ASSET.DURA = ASSET.PROP * NO.OF.DAYS
        
        Value = ASSET.DURA
        GOSUB ROUND.VALUES
        ASSET.DURA = Value

        tmp=EB.Reports.getRRecord(); tmp<12>=EB.Reports.getRRecord()<12> : @VM : ASSET.PROP; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<15>=EB.Reports.getRRecord()<15> : @VM : ASSET.DURA; EB.Reports.setRRecord(tmp)
        TOT.ASSET.DURA += ASSET.DURA

        LIAB.PROP = LIAB.AMT / TOT.PV.TAKINGS
        LIAB.DURA = LIAB.PROP * NO.OF.DAYS * -1
        
        Value = LIAB.DURA
        GOSUB ROUND.VALUES
        LIAB.DURA = Value

        tmp=EB.Reports.getRRecord(); tmp<13>=EB.Reports.getRRecord()<13> : @VM : LIAB.PROP; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<16>=EB.Reports.getRRecord()<16> : @VM : LIAB.DURA; EB.Reports.setRRecord(tmp)
        TOT.LIAB.DURA += LIAB.DURA

        NET.DURA = ASSET.DURA + LIAB.DURA
        tmp=EB.Reports.getRRecord(); tmp<17>=EB.Reports.getRRecord()<17> : @VM : NET.DURA; EB.Reports.setRRecord(tmp)
        TOT.NET.DURA += NET.DURA

*        IF @LOGNAME = 'd05008' THEN PRINT 'DELIM = ':D.DELIM
    WHILE D.DELIM
    REPEAT

* Remove leading value marks.

    FOR XX = 12 TO 17
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<XX,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT XX



GET.YEILD.CURVE.RATE:
*====================

    RETURN.CODE = ''
    PLAC.RATE = ''
*     IF @LOGNAME = 'd05008' THEN PRINT 'LAST.DATE = ':LAST.DATE
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



    ER1 = ''
    REC.CURRENCY = ''
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    tmp.PM$CCY = PM.Config.getCcy()
    REC.CURRENCY = ST.CurrencyConfig.Currency.Read(tmp.PM$CCY, ER1)
* Before incorporation : CALL F.READ('F.CURRENCY',tmp.PM$CCY,REC.CURRENCY,tmp.F.CURRENCY,ER1)
    PM.Config.setCcy(tmp.PM$CCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    CUR.BASIS = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
    CUR.DECIMAL = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurNoOfDecimals>
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

*
* GB9601685
*
    TOT.PV.TAKINGS = 0
    TOT.PV.PLACINGS = 0
*
* GB9601685
*
    TOT.PLACINGS = 0
    TOT.TAKINGS = 0
    TOT.NET.INTEREST = 0
    TOT.PV.PAL = 0


RETURN


******
END
