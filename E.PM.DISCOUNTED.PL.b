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
* <Rating>-92</Rating>
*-----------------------------------------------------------------------------
* Version 7 29/09/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.DISCOUNTED.PL

* This routine will build R.RECORD for the PM discounted P&L enquiries.
* The layout of R.RECORD is defined in the standard selection record
* NOFILE.PM.DPAL.

**********************************************************************
* 16/05/96 GB9600737
*   Make sure the the ID in ID.LIST has the '\MNE'
*   appended to it so that multi company consolidation
*   works correctly. Strip it out to read the DPC record
*
*
* 28/09/98 - GB9801153
*            Allow NCU to be reported under EUR
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
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*****************************************************************************



    $USING ST.CurrencyConfig
    $USING PM.Config
    $USING PM.Reports
    $USING EB.Display
    $USING ST.ExchangeRate
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE

* Call E.PM.AC.RATES to get a list of all BASIC.INTEREST keys which
* will be held in a labelled common so that repetetive selects are
* not required.

    PM.Reports.EPmAcRates("SETUP", "", "", "", "")

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF (EB.SystemTables.getRunningUnderBatch()) THEN
            PRINT EB.SystemTables.getText() : ' PM.DPAL'
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

* Loop through all the position class records selected and consolidate
* them by date, asset or liability and insterest code.

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
        IF V$DATE NE LAST.DATE THEN
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
        GOSUB PROCESS.DPC.REC
    END

    LAST.DATE = V$DATE

    REPEAT

* FINISH OFF
    GOSUB FINISH.OFF

    RETURN

*************************************************************************
PROCESS.DPC.REC:
****************

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

********************************************************************
FINISH.OFF:
***********

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

* Final updates to R.RECORD.

    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<2>=DAYS.BASIS; EB.Reports.setRRecord(tmp)

* Remove leading value marks

    FOR X = 3 TO 16
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<X,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT
    TEMP.R.RECORD = EB.Reports.getRRecord()
    DEL TEMP.R.RECORD<30,1,0>
    EB.Reports.setRRecord(TEMP.R.RECORD)
* Add totals to R.RECORD

    tmp=EB.Reports.getRRecord(); tmp<20>=TOT.PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21>=TOT.TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<22>=TOT.PLACINGS.INT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<23>=TOT.TAKINGS.INT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<24>=TOT.CLOSE.OUT.PL; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<25>=TOT.PV.PAL; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<26>=LAST.DATE; EB.Reports.setRRecord(tmp);* Record the final date


    RETURN


**************************************************************************
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
    TAKINGS = 0
    PLACINGS = 0
    AMT.X.RATE = ''

    RETURN


FIN.LINE:
*=========

* Get the actual interest rates and therefore the interest amounts for
* each of the consolidated amount and interest codes.

    FOR ASST.LIAB = 1 TO 2
        XX = 1
        AMT.X.RATE<ASST.LIAB> = 0
        LOOP
            INT.CODE = INT.STR<ASST.LIAB,XX>
        WHILE INT.CODE
            AMT = AMT.STR<ASST.LIAB,XX>
            GOSUB GET.RATE
            AMT.X.RATE<ASST.LIAB> += AMT * RATE
            XX += 1
        REPEAT
    NEXT

* Calculate the number of days from today to maturity - use LAST.DATE as
* by this stage DATE has been cycled forward.

    tmp.TODAY = EB.SystemTables.getToday()
    DAYS = (ICONV(LAST.DATE,'D') - ICONV(tmp.TODAY,'D'))
    EB.SystemTables.setToday(tmp.TODAY)
    IF DAYS < 0 THEN
        DAYS = 0
    END

    IF PLACINGS THEN
        PLAC.AVG.RATE = AMT.X.RATE<1> / PLACINGS
    END ELSE
        PLAC.AVG.RATE = 0
    END
    IF TAKINGS THEN
        TAK.AVG.RATE = AMT.X.RATE<2> / TAKINGS
    END ELSE
        TAK.AVG.RATE = 0
    END

* Get the market rates from period interest for 01 yeild curve.

    RETURN.CODE = ''
    MKT.PLAC.RATE = ''
    tmp.PM$CCY = PM.Config.getCcy()
    ST.ExchangeRate.Termrate('','01','',tmp.PM$CCY,'','O','',LAST.DATE,'YES',MKT.PLAC.RATE,'','','','',RETURN.CODE)
    PM.Config.setCcy(tmp.PM$CCY)
    IF RETURN.CODE THEN
        CRT @(1,20):EB.SystemTables.getEtext()
        RETURN.CODE = ''
    END

    MKT.TAK.RATE = ''
    tmp.PM$CCY = PM.Config.getCcy()
    ST.ExchangeRate.Termrate('','01','',tmp.PM$CCY,'','B','',LAST.DATE,'YES',MKT.TAK.RATE,'','','','',RETURN.CODE)
    PM.Config.setCcy(tmp.PM$CCY)
    IF RETURN.CODE THEN
        CRT @(1,20):EB.SystemTables.getEtext()
    END

    MKT.PLAC.RATE = ABS(MKT.PLAC.RATE)
    MKT.TAK.RATE = ABS(MKT.TAK.RATE)
    MKT.MID.RATE = (MKT.PLAC.RATE + MKT.TAK.RATE) / 2

* Calcaute the difference between the interest on the principal amounts
* using the actual deal rates and the prevailing market rates on the
* future maturity dates. This is effectively the cost of closing out
* each of the future daily positions.

    PLACINGS.INT = PLACINGS * (PLAC.AVG.RATE - MKT.MID.RATE) * DAYS
    PLACINGS.INT = PLACINGS.INT / (DAYS.BASIS *100)
    TAKINGS.INT = TAKINGS * (TAK.AVG.RATE - MKT.MID.RATE) * DAYS
    TAKINGS.INT = TAKINGS.INT / (DAYS.BASIS *100)

    CLOSE.OUT.PL = PLACINGS.INT + TAKINGS.INT

* Finally discount the csot of closing the position on eaqch future day
* back to the present value using yeild curve 01.

    FACTOR = 1 / (1 + ((MKT.MID.RATE * DAYS) / (DAYS.BASIS * 100)))
    IF EB.SystemTables.getEtext() THEN
        FACTOR = 0
        EB.SystemTables.setEtext('')
    END
    PV.PAL = CLOSE.OUT.PL * FACTOR

* Update totals

    TOT.PLACINGS += PLACINGS
    TOT.TAKINGS += TAKINGS
    TOT.PLACINGS.INT += PLACINGS.INT
    TOT.TAKINGS.INT += TAKINGS.INT
    TOT.CLOSE.OUT.PL += CLOSE.OUT.PL
    TOT.PV.PAL += PV.PAL

    CONVERT @SM TO ' ' IN TXN.ARRAY

    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : LAST.DATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<4>=EB.Reports.getRRecord()<4> : @VM : DAYS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : PLACINGS.INT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : TAKINGS.INT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<9>=EB.Reports.getRRecord()<9> : @VM : CLOSE.OUT.PL; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : PLAC.AVG.RATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=EB.Reports.getRRecord()<11> : @VM : TAK.AVG.RATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=EB.Reports.getRRecord()<12> : @VM : MKT.PLAC.RATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=EB.Reports.getRRecord()<13> : @VM : MKT.TAK.RATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<14>=EB.Reports.getRRecord()<14> : @VM : MKT.MID.RATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<15>=EB.Reports.getRRecord()<15> : @VM : FACTOR; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<16>=EB.Reports.getRRecord()<16> : @VM : PV.PAL; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<30>=EB.Reports.getRRecord()<30> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

    RETURN


GET.RATE:
*========

    INT.CODE<2> = ABS(AMT)
    tmp.PM$CCY = PM.Config.getCcy()
    PM.Reports.EPmAcRates(INT.CODE, tmp.PM$CCY, BASIS, ASST.LIAB, RATE)
    PM.Config.setCcy(tmp.PM$CCY)
    INT.CODE = INT.CODE<1>
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
    REC.CURRENCY = ST.CurrencyConfig.Currency.Read(PM.Config.getCcy()<1,1>, ER1)
* Before incorporation : CALL F.READ('F.CURRENCY',PM.Config.getCcy()<1,1>,REC.CURRENCY,tmp.F.CURRENCY,ER1)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    CUR.BASIS = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>

    IF CUR.BASIS THEN
        CUR.BASIS = CUR.BASIS[1,1]
        IF CUR.BASIS EQ 'A' OR CUR.BASIS EQ 'B' THEN
            DAYS.BASIS = 360
        END ELSE
            DAYS.BASIS = 365
        END
    END

    DIM DPC.REC(50)
    DIM DPC.FILES(50)
    INT.STR = ''
    AMT.STR = ''

    TOT.PLACINGS = 0
    TOT.TAKINGS = 0
    TOT.PLACINGS.INT = 0
    TOT.TAKINGS.INT = 0
    TOT.CLOSE.OUT.PL = 0
    TOT.PV.PAL = 0

    RETURN


******
    END
