* @ValidationCode : MjotNDUzNzY2NDE4OkNwMTI1MjoxNTI0NzM1NDAwMjM5OmJvdml5YTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDMuMjAxODAyMjAtMDE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Apr 2018 15:06:40
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

* Version 7 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>181</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PM.ModelBank
SUBROUTINE E.PM.INIT.COMMON

* This routine will initilise all variables in the PM.ENQ.COMM labelled
* common area. If anything is passed in O.DATA (ENQUIRY.COMMON) then this
* routine will attempt to read a record with this ID from the PM.ENQ.PARAM
* file.



    $USING  PM.Config
    $USING  EU.Config
    $USING  ST.CompanyCreation
    $USING  EB.DataAccess
    $USING  EB.Display
    $USING  PM.Reports
    $USING  EB.SystemTables
    $USING  EB.Reports


    GOSUB INIT.VARIABLES
    GOSUB LOAD.VARIABLES
    GOSUB READ.PM.ENQ.PARAM

* Prior to returning reset the contents of the ENQUIRY.COMMON variable

* otherwise the enquiryu processor will think it has a second record
* to process and will overwrite the screen with null data.
*
* GB0000352 - place sign behind of amount (NNN- instead of -NNN)
*
* GB0002037 - RPK, 09/08/2000: Addition of PM.ENQ.FX.BUY.SIGN and PM.ENQ.FX.SELL.SIGN into
*             PM.ENQ.PARAM to cater for alternative signing for forex positions.
*
* 03/07/13 - Defect 712113/Task 719720
* 			 Currency mnemonic is not displayed in the enquiry header when no records are
*			 available in PM enquiries
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*
* 19/03/18 - Enhancement 2501455 / Task 2501458
*            Development #1 - Selection modifications
*

    EB.Reports.setEnqKeys("")

RETURN


**************************************************************************
*                             INTERNAL ROUTINES
**************************************************************************

INIT.VARIABLES:
*==============

* Simple variables.

    PM.Config.setCcy('')
    PM.Config.setAmt('')
    PM.Config.setCcyDate('')
    PM.Config.setDesks('')
    PM.Config.setRate('')
    PM.Config.setYeild('')
    PM.Config.setBasicList('')
    PARAM.ID = ''

* File variables

    PM.Config.setFPmEnqParam('')
    PM.Config.setFPmDlyPosnClass('')

* Dimensioned arrays

    PM.Config.clearRPmEnqParam()
    PM.Config.clearRPmDlyPosnClass()
    PM.Config.clearRPmCalendar()
    
    PmCalendarRec=''                                                                            ;*initialise record variable
    CalendarErr=''                                                                              ;*initialise error variable

RETURN


READ.PM.ENQ.PARAM:
*=================

* Open the F.PM.ENQ.PARAM file.

    PM.Config.setFPmEnqParam('')
    PM.ENQ.PARAM.FILE = "F.PM.ENQ.PARAM"
    tmp.F$PM.ENQ.PARAM = PM.Config.getFPmEnqParam()
    EB.DataAccess.Opf(PM.ENQ.PARAM.FILE, tmp.F$PM.ENQ.PARAM)
    PM.Config.setFPmEnqParam(tmp.F$PM.ENQ.PARAM)

* Attempt to read the PM.ENQ.PARAM file using O.DATA.

    IF NOT(PARAM.ID) THEN RETURN


    PM.ENQ.PARAM.ERR = ''
    TEMP.R$PM.ENQ.PARAM = ''
    tmp.FPARAM = PM.Config.getFPmEnqParam()
    READ TEMP.R$PM.ENQ.PARAM FROM tmp.FPARAM, PARAM.ID ELSE
* Before incorporation : CALL F.READ("F.PM.ENQ.PARAM",PARAM.ID,TEMP.R$PM.ENQ.PARAM,F.PM.ENQ.PARAM,PM.ENQ.PARAM.ERR)

        EB.SystemTables.setText("MISSING PM.ENQ.PARAM RECORD &")
        tmp=EB.SystemTables.getText(); tmp<2>=PARAM.ID; EB.SystemTables.setText(tmp)
        IF EB.SystemTables.getRunningUnderBatch() THEN
            PRINT 'MISSING PM.ENQ.PARAM RECORD ':PARAM.ID
        END ELSE
            EB.Display.Rem()
        END
        EB.Reports.setEnqKeys('')
        RETURN
    END 
    PM.Config.setDynArrayToRPmEnqParam(TEMP.R$PM.ENQ.PARAM)
*
* Load associated PM.CALENDAR
*
    IF PmCalendarRec EQ '' AND CalendarId EQ '' THEN                                                              ;*if calendar is not defined in selection
    
        CalendarId=PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCalendar)                         ;*read calendar from pm.enq.param
        GOSUB LOAD.CALENDAR                                                                          ; *Load the Calendar

    END


* Replace the words 'BRACKETS, 'MINUS' etc in the signing convention
* fields with the actual characters to be used.
*
* GB0002037 - Addition of PM.ENQ.FX.BUY.SIGN and PM.ENQ.FX.SELL.SIGN
*             Split For/Next loop into two, first loads attrib numbers into TEMP.SIGN
*             the second loops through TEMP.SIGN check position values in R$PM.ENQ.PARAM

    Y = 0
    TEMP.SIGN = ""
    FOR XX = PM.Reports.EnqParam.EnqTakSign TO PM.Reports.EnqParam.EnqDifPlacSign
        Y+=1
        TEMP.SIGN<Y> = XX
    NEXT XX

    Y+=1 ; TEMP.SIGN<Y>=PM.Reports.EnqParam.EnqFxBuySign
    Y+=1 ; TEMP.SIGN<Y>=PM.Reports.EnqParam.EnqFxSellSign

    FOR XX = 1 TO Y
        BEGIN CASE
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'BRACKETS'
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>='('; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>=')'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'MINUS'
* GB0000352 - start
*              R$PM.ENQ.PARAM(XX)<1,1> = '-'
*              R$PM.ENQ.PARAM(XX)<1,2> = SPACE(1)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>='-'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
            CASE PM.Config.getRPmEnqParam(TEMP.SIGN<XX>) = 'PLUS'
*              R$PM.ENQ.PARAM(XX)<1,1> = '+'
*              R$PM.ENQ.PARAM(XX)<1,2> = SPACE(1)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>='+'; PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
* GB0000352 - end
            CASE 1
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,1>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
                tmp=PM.Config.getRPmEnqParam(TEMP.SIGN<XX>); tmp<1,2>=SPACE(1); PM.Config.setRPmEnqParam(TEMP.SIGN<XX>, tmp)
        END CASE
    NEXT XX
*
** If a currency is specified and fixed currencies are to
** be converted add the linked currencies, i.e. if EUR is
** selected add the other 11 currencies
** They are only included if we've passed the start date
*
    PM.Config.setREuFixedCcy('')
    IF PM.Config.getCcy() THEN
        IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqConvertFixedCcy) = 'Y' THEN

            LOCATE 'EU' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING EU.INSTALLED THEN
                F.EU.FIXED.CURRENCY = ''
                EB.DataAccess.Opf('F.EU.FIXED.CURRENCY', F.EU.FIXED.CURRENCY)
*
                tmp.R$EU.FIXED.CCY = PM.Config.getREuFixedCcy()
                tmp.R$EU.FIXED.CCY = EU.Config.FixedCurrency.Read(PM.Config.getCcy()<1,1>, '')
* Before incorporation : CALL F.READ('F.EU.FIXED.CURRENCY', PM.Config.getCcy()<1,1>, tmp.R$EU.FIXED.CCY, F.EU.FIXED.CCY, '')
                PM.Config.setREuFixedCcy(tmp.R$EU.FIXED.CCY)
                NO.CCYS = DCOUNT(PM.Config.getREuFixedCcy()<EU.Config.FixedCurrency.FcCurrencyCode>,@VM)
                FOR YI = 1 TO NO.CCYS
***!                  IF R$EU.FIXED.CCY<EU.FC.FIXED.START.DATE,YI> GE TODAY THEN
                    tmp=PM.Config.getCcy(); tmp<1,-1>=PM.Config.getREuFixedCcy()<EU.Config.FixedCurrency.FcCurrencyCode,YI>; PM.Config.setCcy(tmp)
***!                  END
                NEXT YI
            END
        END
    END

RETURN


LOAD.VARIABLES:
*==============

* Now load common variables based on slection critieria.

    XX = 1
    LOOP
        SEL.FIELD = EB.Reports.getDFields()<XX>
    WHILE SEL.FIELD
        BEGIN CASE
            CASE SEL.FIELD = "CCY"
                PM.Config.setCcy(EB.Reports.getDRangeAndValue()<XX>)
            CASE SEL.FIELD = "RATE"
                PM.Config.setRate(EB.Reports.getDRangeAndValue()<XX>)
            CASE SEL.FIELD = "DESK"
                PM$DESK = EB.Reports.getDRangeAndValue()<XX>
            CASE SEL.FIELD = "YEILD"
                PM.Config.setYeild(EB.Reports.getDRangeAndValue()<XX>)
            CASE SEL.FIELD = "PM.ENQ.PARAM"
                PARAM.ID = EB.Reports.getDRangeAndValue()<XX>
            CASE SEL.FIELD="CALENDAR"                                                            ;*if calendar is present as selection criteria
                CalendarId = EB.Reports.getDRangeAndValue()<XX>                                  ;*fetch the value of calendar
                GOSUB LOAD.CALENDAR
            CASE 1
            
        END CASE
        XX += 1
    REPEAT

    tmp=EB.Reports.getRRecord(); tmp<1>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<2>=PM.Config.getCcy(); EB.Reports.setRRecord(tmp)

    IF PARAM.ID = '' THEN PARAM.ID = 'PM.NOS'

RETURN


******

*-----------------------------------------------------------------------------

*** <region name= LOAD.CALENDAR>
LOAD.CALENDAR:
*** <desc>Load the Calendar </desc>

    IF CalendarId THEN
        PmCalendarRec = PM.Config.Calendar.Read(CalendarId, CalendarErr)
        PM.Config.setDynArrayToRPmCalendar(PmCalendarRec)                                             ;*set common var
    END

RETURN
*** </region>

END

