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
* <Rating>-104</Rating>
*-----------------------------------------------------------------------------
* Version 10 22/05/01  GLOBUS Release No. G15.0.04 29/11/04
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.SEL.POSN.CLASS(ID.LIST, MNEMON.LIST, MAT DPC.FILES)


    $INSERT I_DAS.PM.DLY.POSN.CLASS

    $USING ST.CompanyCreation
    $USING PM.Config
    $USING EB.DataAccess
    $USING EB.Display
    $USING PM.Reports
    $USING EB.SystemTables
    $USING EB.Reports

*
**********************************************************************
*
* 16/05/96 - GB9600642
*            Make sure the the ID in ID.LIST has the '\MNE'
*            appended to it so that multi company consolidation
*            works correctly
*
* 09/07/96 - GB9600924
*            Allow market and dealer desk to be specified in the selection
*            screen
*
* 17/09/98 - GB980XXXX
*            Convert currrencies fixed to the EURO to the EURO
*            if requested in PM.ENQ.PARAM
*
* 22/05/01 - GB0101446
*            The variable DPC.FILES is passed as dimensioned array. But
*            in this program it is not mentioned as dimensioned array,
*            hence causes problems in jBASE. So change DPC FILES to
*            MAT DPC.FILES in the argments
*
* 20/03/02 - CI_10001083
*            Dealer desk 00 is not picked up
*
* 29/09/03 - GB_100005265
*            Set up the correct file for multi book
*
* 20/12/03 - EN_10002104
*            Company level parameters in a MB environment.
*            Used EB.READ.PARAMETER routine to read the PM.POSN.REFERENCE file
*
* 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 23/05/08 - CI_10055593
*            Mnemonic read from FInancial Mnemonic.
*
* 15/12/09 - CI_10068214
*            Changes done to show the final positions of PM.DLY.POSN.CLASS records
*            with ID as ALFAL in cal bucket properly.
*
* 16/12/09 - CI_10068236
*            When COMPANY.CONSOL  is set in PM.ENQ.PARAM, PM.FXPOS enquiry displays
*            POSN.CLASS  contracts across all company properly
*
* 31/03/10 - Defect-34262/Task-35753
*            Cash flow Enquiry Timeout Error
*
* 06/04/10 - Defect-32893/Task-36706
*            Modified to call DAS to select data.
*
* 29/10/10 - DEFECT 99285 / Task 103143
*            Error in enquiry PM.FXREVAL
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
**********************************************************************
    F.COMPANY = ''
    EB.DataAccess.Opf("F.COMPANY",F.COMPANY)
*
    F.COMPANY.CONSOL = ''
    EB.DataAccess.Opf("F.COMPANY.CONSOL",F.COMPANY.CONSOL)

* Thew required PM.ENQ.PARAM record should already have been loaded into
* the common variable R$PM.ENQ.PARAM by the routine E.PM.INIT.COMMON.

    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqOniteDlyFile) = '' THEN
        EB.SystemTables.setText('PM.ENQ.PARAM RECORD NOT IN COMMON')
        IF EB.SystemTables.getRunningUnderBatch() THEN
            PRINT EB.SystemTables.getText()
        END ELSE
            EB.Display.Rem()
        END
        EB.Reports.setRRecord('')
        RETURN
    END
*
* Find request start date.
*
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqStartBreak) THEN
        TEMP.R$PM.CALENDAR = PM.Config.getRPmCalendar(PM.Config.Calendar.CPeriod)
        TEMP.R$PM.ENQ.PARAM = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqStartBreak)
        LOCATE TEMP.R$PM.ENQ.PARAM IN TEMP.R$PM.CALENDAR<1,1> SETTING POSN THEN
        START.DATE = PM.Config.getRPmCalendar(PM.Config.Calendar.CStartDate)<1,POSN>
        IF EB.SystemTables.getToday()[1,4] - START.DATE[1,4] = 100 THEN
            START.DATE = 1
        END
    END ELSE
        START.DATE = 0
    END
    END ELSE
    START.DATE = 0
    END
*
    GOSUB GET.COMPANIES.REQD

    GOSUB OPEN.POSN.CLASS.FILES

    GOSUB GET.VALID.CLASSES.AND.DESKS

* Form a list of the PM.?.POSN.CLASS keys to be used together with an
* indicator to which Company they come from.

    ID.LIST = ''
    MNEMON.LIST = ''
    SAVED.ID.COMPANY = EB.SystemTables.getIdCompany()       ;*Reset back to this company after DAS.
    ST.CompanyCreation.LoadCompany(MNEMONIC<1>)      ;*Used to enable DAS to work with this



    GOSUB SELECT.POSN.CLASS.FILE

    LOOP
        REMOVE TEMP.ID FROM POS.ID.LIST SETTING YDELIM
        EB.Reports.setId(TEMP.ID)
    UNTIL EB.Reports.getId() = ''
        DUM.ID = EB.Reports.getId()
        DUM.ID = DUM.ID["*",3,1]
        EB.Reports.setId(DUM.ID)
        GOSUB CHECK.CLASS.AND.DESK
        IF OK THEN
            ID.LIST := @FM:EB.Reports.getId():'*':MNEMONIC<1>
            MNEMON.LIST := @FM:1
        END
    REPEAT
    DEL ID.LIST<1,0,0>
    DEL MNEMON.LIST<1,0,0>
    END.MARKER = '....ZZZZ.999999999'
    ID.LIST := @FM:END.MARKER
    PM.Config.setCcy(PM.Config.getCcy());* reset

* Select PM.?.POSN.CLASS keys from the other companies to be included

    FOR X = 2 TO (MNEMON.COUNT)

        ST.CompanyCreation.LoadCompany(MNEMONIC<X>)  ;*Used to enable DAS to work with this routine.
        GOSUB SELECT.POSN.CLASS.FILE

        Y = 0
        LOOP
            REMOVE TEMP.ID FROM POS.ID.LIST SETTING YDELIM
            EB.Reports.setId(TEMP.ID)
        UNTIL EB.Reports.getId() = ''
            DUM.ID = EB.Reports.getId()
            DUM.ID = DUM.ID["*",3,1]
            EB.Reports.setId(DUM.ID)
            GOSUB CHECK.CLASS.AND.DESK
            IF OK THEN
                GOSUB BUILD.LIST
            END
        REPEAT
    NEXT

* Reset company after DAS.
    ST.CompanyCreation.LoadCompany(SAVED.ID.COMPANY)

* Remove end marker
    LOCATE END.MARKER IN ID.LIST<1> SETTING POSN THEN
    DEL ID.LIST<POSN>
    END
*
    FULL.CCY.LIST = PM.Config.getCcy()
    PM.Config.setCcy(PM.Config.getCcy()<1,1>);* Set to first CCY for all routines

    RETURN

*************************************************************************
*                         INTERNAL ROUTINES
*************************************************************************

GET.COMPANIES.REQD:
*==================

* If multi company consolidation is required read the required companies

    COMP.ARRAY = ""
    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCompConsol) NE '' THEN

        COMP.CON.ERR = ''
        tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqCompConsol = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCompConsol)
        COMP.CON.REC = ST.CompanyCreation.CompanyConsol.Read(tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqCompConsol, COMP.CON.ERR)
        * Before incorporation : CALL F.READ('F.COMPANY.CONSOL',tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqCompConsol,COMP.CON.REC,F.COMPANY.CONSOL,COMP.CON.ERR)
        PM.Config.setRPmEnqParam(PM.Reports.EnqParam.EnqCompConsol, tmp.R$PM.ENQ.PARAM.PM.Reports.EnqParam.EnqCompConsol)
        IF NOT(COMP.CON.ERR) THEN
            COMP.ARRAY = COMP.CON.REC<ST.CompanyCreation.CompanyConsol.EbCcoComConsolFrom>
        END
    END
    IF COMP.ARRAY = '' THEN
        COMP.ARRAY = EB.SystemTables.getIdCompany()
    END

    RETURN


OPEN.POSN.CLASS.FILES:
*=====================

    END.SELECTFILE = '.PM.DLY.POSN.CLASS'

    COMP.COUNT = 0
    MNEMON.COUNT = 0
    MNEMONIC = ''
    DIM DPC.FILES(50)
    MAT DPC.FILES = ''

* Get the company MNEMONICS for the companies to be consolidated.
* and open the associated PM.DLY.POSN.CLASS file

    LOOP
        COMP.COUNT += 1
    UNTIL COMP.ARRAY<1,COMP.COUNT> = ''
        COMP.ERR = ''
        Y.COMPANY.REC = ST.CompanyCreation.Company.Read(COMP.ARRAY<1,COMP.COUNT>, COMP.ERR)
* Before incorporation : CALL F.READ('F.COMPANY',COMP.ARRAY<1,COMP.COUNT>,Y.COMPANY.REC,F.COMPANY,COMP.ERR)
        IF NOT(COMP.ERR) THEN
            MNEMON.COUNT += 1
            MNEMONIC<MNEMON.COUNT> = Y.COMPANY.REC<ST.CompanyCreation.Company.EbComFinancialMne>
            READFILE = 'F':MNEMONIC<MNEMON.COUNT>:END.SELECTFILE
            READFILE.VAR = ''
            EB.DataAccess.Opf(READFILE,READFILE.VAR)
            DPC.FILES(MNEMON.COUNT) = READFILE.VAR
        END
    REPEAT

    RETURN


GET.VALID.CLASSES.AND.DESKS:
*===========================
*
* Look for DEALER.DESK and CCY.MARKET in ENQ.SELECTION and  use the specified
* selections if present, otherwise use the PM.ENQ.PARAM setting.
*
    VALID.DESK = ""
    LOCATE "DEALER.DESK" IN EB.Reports.getEnqSelection()<2,1> SETTING DESK.POS THEN
    VALID.DESK = RAISE(EB.Reports.getEnqSelection()<4,DESK.POS>)
    CONVERT " " TO @VM IN VALID.DESK
    END
*
    VALID.MARKET = ""
    LOCATE "CCY.MARKET" IN EB.Reports.getEnqSelection()<2,1> SETTING MKT.POS THEN
    VALID.MARKET = RAISE(EB.Reports.getEnqSelection()<4,MKT.POS>)
    CONVERT " " TO @VM IN VALID.MARKET
    END

    IF NOT(VALID.MARKET) THEN
        VALID.MARKET = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCurrencyMarket)
    END
*
* Read the Position Classes and Dealer desks to be included from the
* ENQ parameter file OR the PM.POSN.REFERENCE file.

    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqPosnRef) NE '' THEN
        F.PM.POSN.REFERENCE = ''
        EB.DataAccess.Opf("F.PM.POSN.REFERENCE",F.PM.POSN.REFERENCE)
        Y.POSN.REF.ID = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqPosnRef)
        ST.CompanyCreation.EbReadParameter("F.PM.POSN.REFERENCE",'N','',POSN.REF.REC,Y.POSN.REF.ID,F.PM.POSN.REFERENCE,RETURN.CODE)
        VALID.CLASS = POSN.REF.REC<PM.Config.PosnReference.PrPosnClass>
        IF VALID.DESK EQ '' THEN
            VALID.DESK = POSN.REF.REC<PM.Config.PosnReference.PrDlrDskGrp>
        END
    END ELSE
        VALID.CLASS = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqPosnClass)
        IF VALID.DESK EQ '' THEN
            VALID.DESK = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqDealDesk)
        END
    END

* Get secondary Posn classes for seperating Nosto's of the same CCY

    SEC.VALID.CLASS = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCheckfileId)

* Get the actual desks where PM.GRPs have been specified

    F.PM.GRP = ''
    TEMP.VALID.DESK = ''
    EB.DataAccess.Opf('F.PM.GRP',F.PM.GRP)
    X = 1
    LOOP UNTIL VALID.DESK<X> EQ ''

        PM.GRP.ERR = ''
        GRP.REC = PM.Config.Grp.Read(VALID.DESK<X>, PM.GRP.ERR)
        * Before incorporation : CALL F.READ('F.PM.GRP',VALID.DESK<X>,GRP.REC,F.PM.GRP,PM.GRP.ERR)
        IF NOT(PM.GRP.ERR) THEN
            Y = 1
            LOOP UNTIL GRP.REC<PM.Config.Grp.GRecordId,Y> EQ ''
                TEMP.VALID.DESK<1,-1> = GRP.REC<PM.Config.Grp.GRecordId,Y>
                Y += 1
            REPEAT
        END ELSE
            TEMP.VALID.DESK<1,-1> = VALID.DESK<X>
        END
        X += 1
    REPEAT
    VALID.DESK = TEMP.VALID.DESK

    RETURN


SELECT.POSN.CLASS.FILE:
*======================

    TABLE.SUFFIX = ''
    THE.ARGS = ''
*

    IF PM.Config.getCcy() THEN
        CCY.LIST = ''
        COUNTER = 1
        CURRENCY.LIST = PM.Config.getCcy()
        LOOP
            REMOVE WORK.CCY FROM CURRENCY.LIST SETTING YD
        WHILE WORK.CCY:YD
            THE.ARGS<COUNTER> = WORK.CCY
            COUNTER = COUNTER+1
        REPEAT
        POS.ID.LIST = dasPmDlyPosnClassIdLike
    END ELSE
        POS.ID.LIST = 'ALL.IDS'
    END
*

    EB.DataAccess.Das('PM.DLY.POSN.CLASS',POS.ID.LIST,THE.ARGS,TABLE.SUFFIX)

*
    NEW.POS.ID.LIST = ""
*
    LOOP
        REMOVE POS.ID FROM POS.ID.LIST SETTING POS1
    WHILE POS1:POS.ID
        IF PM.Config.getCcy() THEN        ;* If currency specified
            NEW.POS.ID.LIST<-1> = FIELD(POS.ID,'.',6):"*":FIELD(POS.ID,'.',5):"*":POS.ID  ;* Sort by DATE
        END ELSE
            NEW.POS.ID.LIST<-1> = FIELD(POS.ID,'.',5):"*":FIELD(POS.ID,'.',6):"*":POS.ID  ;* Else sort by CCY and then by DATE
        END
    REPEAT
    POS.ID.LIST = SORT(NEW.POS.ID.LIST) ;* Sort the list
*
    RETURN


CHECK.CLASS.AND.DESK:
*====================

    OK = 1

    tmp.ID = EB.Reports.getId()
    CCY = FIELD(tmp.ID,'.',5)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    CLASS = FIELD(tmp.ID,'.',1)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    V$DATE = FIELD(tmp.ID,'.',6)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    DESK = FIELD(tmp.ID,'.',3)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    MKT = FIELD(tmp.ID,".",2)
    EB.Reports.setId(tmp.ID)

*
    IF V$DATE LT START.DATE THEN
        OK = ''
        RETURN
    END
    LOCATE CLASS IN VALID.CLASS<1,1> SETTING POSN ELSE
    LOCATE CLASS IN SEC.VALID.CLASS<1,1> SETTING POSN ELSE
    OK = ""
    END
    END

    IF VALID.DESK NE '' THEN
        LOCATE DESK IN VALID.DESK<1,1> SETTING POSN ELSE
        IF VALID.DESK<1,1> NE "ALL" THEN
            OK = ""
        END
    END
    END
*
    IF VALID.MARKET THEN
        LOCATE MKT IN VALID.MARKET<1,1> SETTING POSN ELSE
        IF VALID.MARKET<1,1> NE "ALL" THEN
            OK = ""
        END
    END
    END

    RETURN


BUILD.LIST:
*=========

    LOOP
        Y += 1
        T.ID = ID.LIST<Y,1>
        W.CCY = FIELD(T.ID,'.',5)
        T.DATE = FIELD(T.ID,'.',6)
        KEY.LOC = 0
        IF CCY LE W.CCY AND CCY LT W.CCY OR V$DATE LT T.DATE THEN
            INS EB.Reports.getId():'*':MNEMONIC<X> BEFORE ID.LIST<Y,0,0>
            INS X BEFORE MNEMON.LIST<Y,0,0>
            KEY.LOC = 1
        END
    UNTIL KEY.LOC
    REPEAT

    RETURN


******
    END
