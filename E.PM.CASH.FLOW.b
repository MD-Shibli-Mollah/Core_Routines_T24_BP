* @ValidationCode : Mjo5NjA1MTM1NTpDcDEyNTI6MTUyNDczNTQ1MjEwMDpib3ZpeWE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODAzLjIwMTgwMjIwLTAxNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 26 Apr 2018 15:07:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : boviya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.20180220-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
* Version 7 29/09/00  GLOBUS Release No. G11.0.00 29/06/00
$PACKAGE PM.Reports
SUBROUTINE E.PM.CASH.FLOW

* This routine will build R.RECORD to be used by the CASH FLOW ENQUIRY

**********************************************************************
* 16/05/96      GB9600737
*                       Make sure the the ID in ID.LIST has the '\MNE'
*                       appended to it so that multi company consolidation
*                       works correctly. Strip it out to read the DPC record
*
* 08/07/96 - GB9600907
*            Treat a date of zero as the OPEning poisiton
*
* 31/07/01 - GLOBUS_EN_10000052
*            Allow PM Consolidation by period
*
* 27/01/03 - GLOBUS_CI_10006467
*            Enquiry PM.CAS not showing 'OPENING' record. This
*            is because while allowing consolidation by period, if the
*            field PM.ENQ.CONSOL.PERIOD is  set to 'D' (Daily) then
*            NEXT.PERIOD is directly assigned a value; without checking
*            if it the OPEning record.
* 07/08/03 - CI_10011572
*            Code which assigns NEXT.PERIOD if CONSOL.PERIOD
*            is set as 'D' needs to be uncommented.Code has been
*            done to fix the problem of not showing 'OPENING' also
*            as the fix done under CI_10006467 causes the problem of
*            displaying the same date for transactions where schedule
*            is defined on running the enquiry.
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
* 03/12/07 - CI_10052728
*            fix iconv for next period, just strip out spaces
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*
* 19/03/18 - Enhancement 2501455 / Task 2501458
*            Development #1 - Selection modifications
*
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
    
    GOSUB CHECK.FOR.CALENDAR ; *Check whether any invalid PM calendar given as selection criteria.
   
    IF ID.LIST = '' OR INVALID.CALENDAR THEN                                 ;*when calendar is incorrect,return without any data
        
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF EB.SystemTables.getRunningUnderBatch() THEN
            PRINT EB.SystemTables.getText() : " PM.CAS "
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
    WHILE EB.Reports.getId():POINT1

        tmp.ID = EB.Reports.getId()
        V$DATE = FIELD(tmp.ID,'.',6)+ 0
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
            WCCY = EB.Reports.getId()['.',5,1]
            MKT = EB.Reports.getId()['.',2,1]
            IF WCCY NE PM.Config.getCcy() THEN
                GOSUB CONVERT.RECORD
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

*        LAST.DATE = DATE

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
    PLACINGS = 0
*
    PRD.CNT = DCOUNT(PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate),@SM)
       
    IF PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod)  THEN                   ;*when calendar is present - either inputted or pm.enq.param
            
        LOOP
            NEXT.DATE.COUNT += 1
            LAST.DATE = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
            IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqDatePeriod) EQ 'PERIOD' THEN
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod)<1,NEXT.DATE.COUNT>
            END ELSE
                NEXT.PERIOD = PM.Config.getRPmCalendar(PM.Config.Calendar.CEndDate)<1,NEXT.DATE.COUNT>
                IF NEXT.PERIOD MATCHES "8N" THEN
                    NEXT.PERIOD = OCONV(ICONV(NEXT.PERIOD,'D') ,'D2E-')
                END ELSE
                    NEXT.PERIOD = "OPENING" ; EB.Display.Txt(NEXT.PERIOD)
                END
            END
            CONVERT ' ' TO '' IN NEXT.PERIOD
        UNTIL (LAST.DATE GE V$DATE)
        REPEAT
    
    
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
        IF LAST.DATE NE 1 ELSE
            NEXT.PERIOD = "OPENING"
            EB.Display.Txt(NEXT.PERIOD)
        END
        IF NEXT.PERIOD EQ '' THEN
            IF LAST.DATE NE 1 THEN
                NEXT.PERIOD = OCONV(ICONV(LAST.DATE,'D') ,'D2E-')
            END ELSE          ;* Must be OPE
                NEXT.PERIOD = "OPENING" ; EB.Display.Txt(NEXT.PERIOD)
            END
        END
        
    END
     
*
RETURN


FIN.LINE:
*========

* Use LAST.DATE as by this stage date has been cycled forward to the next
* date.

    DAYS = (ICONV(LAST.DATE,'D')) - I.TODAY
    IF DAYS < 0 THEN
        DAYS = 0
    END


    NET.MOVEMENT = PLACINGS + TAKINGS

* Update totals

    TOT.PLACINGS += PLACINGS
    TOT.TAKINGS += TAKINGS


    CONVERT @SM TO ' ' IN TXN.ARRAY

*      IF R$PM.ENQ.PARAM(PM.ENQ.DATE.PERIOD) EQ 'PERIOD' THEN
    tmp=EB.Reports.getRRecord(); tmp<3>=EB.Reports.getRRecord()<3> : @VM : NEXT.PERIOD; EB.Reports.setRRecord(tmp)
*      END ELSE
*      R.RECORD<3>  := VM : LAST.DATE
*      END
    tmp=EB.Reports.getRRecord(); tmp<4>=EB.Reports.getRRecord()<4> : @VM : DAYS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<7>=EB.Reports.getRRecord()<7> : @VM : PLACINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=EB.Reports.getRRecord()<8> : @VM : TAKINGS; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<9>=EB.Reports.getRRecord()<9> : @VM : NET.MOVEMENT; EB.Reports.setRRecord(tmp)
    AMT.CF += NET.MOVEMENT
    tmp=EB.Reports.getRRecord(); tmp<10>=EB.Reports.getRRecord()<10> : @VM : AMT.CF; EB.Reports.setRRecord(tmp)

    tmp=EB.Reports.getRRecord(); tmp<19>=EB.Reports.getRRecord()<19> : @VM : TXN.ARRAY; EB.Reports.setRRecord(tmp)

RETURN


INITIALISE:
*==========

* Initialise all variables and open files.

    EB.SystemTables.setFCurrency('')
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    EB.DataAccess.Opf('F.CURRENCY',tmp.F.CURRENCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
*
    NEXT.DATE.COUNT = 0

    ER1 = ''
    REC.CURRENCY = ''
    tmp.F.CURRENCY = EB.SystemTables.getFCurrency()
    tmp.PM$CCY = PM.Config.getCcy()
    REC.CURRENCY = ST.CurrencyConfig.Currency.Read(tmp.PM$CCY, ER1)
* Before incorporation : CALL F.READ('F.CURRENCY',tmp.PM$CCY,REC.CURRENCY,tmp.F.CURRENCY,ER1)
    PM.Config.setCcy(tmp.PM$CCY)
    EB.SystemTables.setFCurrency(tmp.F.CURRENCY)
    CUR.BASIS = REC.CURRENCY<ST.CurrencyConfig.Currency.EbCurInterestDayBasis>
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

    AMT.CF = 0
    TOT.PLACINGS = 0
    TOT.TAKINGS = 0
    
    

RETURN
*
*----------------------------------------------------------------
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
*-----------------------------------------------------------------------------

*** <region name= CHECK.FOR.CALENDAR>
CHECK.FOR.CALENDAR:
*** <desc>Check whether any invalid PM calendar given as selection criteria. </desc>

    SelectionFields=''                                                    ;*initialise the variables
    POS=''
    CalendarId=''
    INVALID.CALENDAR=''


    SelectionFields = EB.Reports.getDFields()                      ;*whether calendar is a valid selection criteria
    LOCATE 'CALENDAR' IN SelectionFields<1> SETTING POS THEN
        CalendarId =EB.Reports.getDRangeAndValue()<POS>
    END

*when an invalid calendar or junk value is given,no output should be shown
    IF CalendarId NE '' AND  PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod) EQ '' THEN
        INVALID.CALENDAR ='1'
    END
    
RETURN
*** </region>

END

