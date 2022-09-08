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

* Version 8 29/09/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-17</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.INTEREST.RATE.EXP.II

* This routine will build R.RECORD to be used by the what if P&L enquiry.
* Interest is calculated on each balance on the system based on the 01
* yeild curve and also on a second yeild curve input by the user.

**********************************************************************
* 16/05/96      GB9600737
*                       Make sure the the ID in ID.LIST has the '\MNE'
*                       appended to it so that multi company consolidation
*                       works correctly. Strip it out to read the DPC record
*
* 04/12/96        GB9601687
*                 Sort out unassigned variables
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
* 05/06/13 - Defect 518866 / 695216
*             Enquiry PM.IRE- When drilled down against Today, does not display any data.
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*****************************************************************************


    $USING  ST.CurrencyConfig
    $USING  PM.Config
    $USING  EB.Display
    $USING  PM.Reports
    $USING  EB.DataAccess
    $USING  EB.SystemTables
    $USING  EB.Reports


    GOSUB INITIALISE

    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF (EB.SystemTables.getRunningUnderBatch()) THEN
            PRINT EB.SystemTables.getText() : ' PM.IRE'
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

    LAST.DATE = EB.SystemTables.getToday()
    tmp.TODAY = EB.SystemTables.getToday()
    LAST.I.DATE = ICONV(tmp.TODAY, 'D')
    EB.SystemTables.setToday(tmp.TODAY)
    LINE.COUNT = 0
    GOSUB INIT.LINE

    LOOP

        REMOVE TEMP.ID FROM ID.LIST SETTING POINT1
        EB.Reports.setId(TEMP.ID)
        REMOVE MNEMON FROM MNEMON.LIST SETTING POINT2
    WHILE EB.Reports.getId()

        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)
        EB.Reports.setId(tmp.ID)
        IF V$DATE LT EB.SystemTables.getToday() THEN
            *        IF DATE LT (TODAY) THEN
            GOTO SKIP.REC
        END
        IF V$DATE NE LAST.DATE THEN
            *        IF DATE GT LAST.DATE THEN
            I.DATE = ICONV(V$DATE, 'D')
            NO.OF.DAYS = I.DATE - LAST.I.DATE
            GOSUB INIT.LINE
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
        DPC.CCY = DPC.ID['.',5,1]
        IF DPC.CCY NE PM.Config.getCcy() THEN
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
    LAST.I.DATE = ICONV(LAST.DATE, 'D')
SKIP.REC:
    REPEAT

* FINISH OFF

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)

* Remove leading value marks

    FOR X = 3 TO 10
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<X,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT

* Add in the final cumulative balance at todays date so that the final
* cumulative amount falls to zero. In this case the todays movement should
* ignored. This is a fiddle factor specified by KBIM.

    BF.BAL = CUM.MOVEMENT * -1
    CUM.MOVEMENT = 0
    IF EB.Reports.getRRecord()<3,1> GT EB.SystemTables.getToday() THEN
        tmp=EB.Reports.getRRecord(); tmp<3>=EB.SystemTables.getToday():@VM:EB.Reports.getRRecord()<3>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<4>=BF.BAL:@VM:EB.Reports.getRRecord()<4>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<8>=0:@VM:EB.Reports.getRRecord()<8>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<8>="":@VM:EB.Reports.getRRecord()<8>; EB.Reports.setRRecord(tmp)
    END ELSE
        BF.BAL += EB.Reports.getRRecord()<4,1>
        tmp=EB.Reports.getRRecord(); tmp<4,1>=BF.BAL; EB.Reports.setRRecord(tmp)
    END

* Add total cumulative amount back into day zero and build up the daily
* profit and loss and cumulative profit and loss.

    NET.STR = EB.Reports.getRRecord()<4>
    DAY.STR = EB.Reports.getRRecord()<8>

    CUM.MOVEMENT = 0
    POS = 0
    LOOP
        POS += 1
        REMOVE NET.MVMT FROM NET.STR SETTING DELIM
        REMOVE NO.OF.DAYS FROM DAY.STR SETTING DELIM2
        CUM.MOVEMENT += NET.MVMT
        PROFIT.LOSS = CUM.MOVEMENT * MULTIPLIER * NO.OF.DAYS
        CUM.PROFIT.LOSS += PROFIT.LOSS

        IF CUM.PROFIT.LOSS GT LARGEST.PROFIT THEN
            LARGEST.PROFIT = CUM.PROFIT.LOSS
            LARGE.PROFIT.DAYS = POS
        END

        IF CUM.PROFIT.LOSS LT LARGEST.LOSS THEN
            LARGEST.LOSS = CUM.PROFIT.LOSS
            LARGE.LOSS.DAYS = POS
        END

        tmp=EB.Reports.getRRecord(); tmp<5>=EB.Reports.getRRecord()<5> : @VM : CUM.MOVEMENT; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<6>=EB.Reports.getRRecord()<6> : @VM : PROFIT.LOSS; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : CUM.PROFIT.LOSS; EB.Reports.setRRecord(tmp)

    UNTIL DELIM = 0
    REPEAT

    FOR XX = 5 TO 7
        TEMP.R.RECORD = EB.Reports.getRRecord()
        DEL TEMP.R.RECORD<XX,1,0>
        EB.Reports.setRRecord(TEMP.R.RECORD)
    NEXT XX

* Calc cdate of largest profit or loss.

    IF LARGE.PROFIT.DAYS = 0 THEN
        PRFT.DATE = 'NONE'
    END ELSE
        PRFT.DATE = ICONV(EB.Reports.getRRecord()<3,LARGE.PROFIT.DAYS+1>, 'D') - 1
        PRFT.DATE = OCONV(PRFT.DATE, 'D4/E')
        PRFT.DATE = PRFT.DATE[7,4]:PRFT.DATE[4,2]:PRFT.DATE[1,2]
    END

    IF LARGE.LOSS.DAYS = 0 THEN
        LOSS.DATE = 'NONE'
    END ELSE
        LOSS.DATE = ICONV(EB.Reports.getRRecord()<3,LARGE.LOSS.DAYS+1>, 'D') - 1
        LOSS.DATE = OCONV(LOSS.DATE, 'D4/E')
        LOSS.DATE = LOSS.DATE[7,4]:LOSS.DATE[4,2]:LOSS.DATE[1,2]
    END

    tmp=EB.Reports.getRRecord(); tmp<15>=LARGEST.PROFIT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<16>=LARGEST.LOSS; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<17>=PRFT.DATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<18>=LOSS.DATE; EB.Reports.setRRecord(tmp)
* Set VM.COUNT on exit

    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<3>, @VM))

* Add totals to R.RECORD



    RETURN


INIT.LINE:
*=========

* Initialisation for each element / line

    IF LINE.COUNT THEN
        GOSUB FIN.LINE
    END

    LINE.COUNT += 1
    TXN.ARRAY = ''
    TAKINGS = 0
    PLACINGS = 0

    RETURN

FIN.LINE:
*========

* Use LAST.DATE as by this stage date has been cycled forward to the next
* date.

    NET.MOVEMENT = PLACINGS + TAKINGS
    CUM.MOVEMENT += NET.MOVEMENT

    CONVERT @SM TO ' ' IN TXN.ARRAY

    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : LAST.DATE; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<4>=EB.Reports.getRRecord()<4> : @VM : NET.MOVEMENT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : NO.OF.DAYS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

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
            DAYS.BASIS = 360
        END ELSE
            DAYS.BASIS = 365
        END
    END
*
    LOCATE "RATE.RISE" IN EB.Reports.getDFields()<1> SETTING POSN THEN
    tmp=EB.Reports.getRRecord(); tmp<2>=EB.Reports.getDRangeAndValue()<POSN>; EB.Reports.setRRecord(tmp)
    END ELSE
    tmp=EB.Reports.getRRecord(); tmp<2>=1; EB.Reports.setRRecord(tmp)
    END
*
    MULTIPLIER = EB.Reports.getRRecord()<2> / (DAYS.BASIS * 100)
    tmp.TODAY = EB.SystemTables.getToday()
    I.TODAY = ICONV(tmp.TODAY, 'D')
    EB.SystemTables.setToday(tmp.TODAY)
    DIM DPC.REC(50)
    DIM DPC.FILES(50)
    AMT.STR = ''

    TOT.PLACINGS = 0
    TOT.TAKINGS = 0
    TOT.NET.INTEREST = 0
    TOT.PV.PAL = 0

    LARGEST.PROFIT = 0
    LARGEST.LOSS = 0
    LARGE.PROFIT.DAYS = 0
    LARGE.LOSS.DAYS = 0


    RETURN


******
    END
