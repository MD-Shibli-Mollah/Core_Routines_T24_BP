* @ValidationCode : MjotMTczOTU1MjkxODpDcDEyNTI6MTYxNzYyNTM0ODc0MzpuZ293dGhhbWt1bWFyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDQuMjAyMTAzMzAtMDUwMToyNDg6ODI=
* @ValidationInfo : Timestamp         : 05 Apr 2021 17:52:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ngowthamkumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/248 (33.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.20210330-0501
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>2898</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.API
SUBROUTINE INITIALISE.MAIN.COMMON
*======================================================================
* Subroutine to initialise the main globus common (now a labelled common)
* This is mainly used in the release procedure when upgrading to the
* new labelled common version - you have initiated EX with an unlabelled
* common and your now calling code which relies on the data being in a
* labelled common.
*
* 16/06/03 - EN_10001845
*            Use EB.READ.SPF to read the SPF record
*
* 21/06/07 - BG_100014340
*            Changes done to populate the fields FINANCIAL.MNE, FINIANCIAL.COM
*            in R.COMPANY common variable, when it is null. This will solve
*            the crash while doing GLOBUS.RELEASE in upgrading from lower release
*            to higher release, before running the actual converison to
*            populate FINANCIAL.MNE/COM in COMPANY record.
*
* 19/05/17 - Task - 2143062 / Enhancement - 2117822
*            AC & LI product availability check has been done on the Company and just skips corresponding file read and OPF if product not installed.
*
* 20/11/18 - Enhancement 2822523 / Task 2843458
*            Incorporation of EB_API component
*
* 21/10/20 - Enhancement 3916484 / Task 4036976
*            Change EB module to use MarketData MDAL API
*======================================================================
    $INSERT I_COMMON
    $INSERT I_AGC.COMMON
    $INSERT I_ACCT.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT.CLASS
    $INSERT I_F.DATES
    $INSERT I_F.LANGUAGE
    $INSERT I_F.ACCOUNT.PARAMETER
    $USING MDLMKT.MarketData
    $USING EB.MdalFramework
*======================================================================
REM "MATRICES:
*     C A U T I O N:  because of a bug in info-basic it's not possible
*     to separate the following line (except using an additional line
*     without COM - but this does not work with IBM-basic)
    COM CHECKFILE.UNAMED(500), R.COMPANY.UNAMED(500), CONCATFILE.UNAMED(500), R.DATES.UNAMED(500), F.UNAMED(500), N.UNAMED(500), R.NEW.UNAMED(500), R.NEW.LAST.UNAMED(500), R.OLD.UNAMED(500), R.OPF.UNAMED(500), R.UNAMED(500), T.UNAMED(500), T.REMTEXT.UNAMED(500), C$SPARE.UNAMED(500), R.VERSION.UNAMED(500)
*     C A U T I O N:  Definition 200
*     must be changed when one (!) pgm needs more fields  !!!!!!!!!
*     ... and ... R.NEW(500) must be changed when one table file has
*     more fields ..................................................
*************************************************************************
REM "SIMPLE VARIABLES:
    COM A.UNAMED, AF.UNAMED, AUTH.NO.UNAMED, ANY.INPUT.UNAMED, APPLICATION.UNAMED, AS.UNAMED, F.JOURNAL.UNAMED
    COM AUTH.QUALITY.UNAMED, AV.UNAMED
    COM C.UNAMED, COMI.UNAMED, COMI.ENRI.UNAMED
    COM CONTROLWORD.OK.UNAMED, PRT.PARAMS.UNAMED
    COM DISPLAY.UNAMED
    COM E.UNAMED, ECOMI.UNAMED, END.ERROR.UNAMED, ETEXT.UNAMED
    COM FILE.TYPE.UNAMED, FULL.FNAME.UNAMED, FUNCTION.UNAMED
    COM HIST.NO.UNAMED
    COM ID.ALL.UNAMED, ID.AUT.UNAMED, ID.CHECKFILE.UNAMED, R.INTERCO.PARAMETER.UNAMED, ID.COMPANY.UNAMED
    COM ID.CONCATFILE.UNAMED, ID.ENRI.UNAMED, ID.ETEXT.UNAMED, ID.F.UNAMED, ID.N.UNAMED, ID.NEW.UNAMED
    COM ID.NEW.LAST.UNAMED, ID.OLD.UNAMED, ID.POINTER.UNAMED, ID.R.UNAMED, ID.T.UNAMED, JOURNAL.BYPASS.UNAMED
    COM INPUT.BUFFER.UNAMED
    COM L.UNAMED, L.MULTI.UNAMED, L1ST.UNAMED, LASTA.UNAMED, LASTL.MULTI.UNAMED, OVERRIDE.FLAG.UNAMED, LASTP.UNAMED
    COM LCCY.UNAMED, LEVEL.NO.UNAMED, LEVEL.STATUS.UNAMED, LNGG.UNAMED, LOCAL.REF.FIELD.UNAMED
    COM MESSAGE.UNAMED, MULTI.POSSIBLE.UNAMED, MTHPOS.UNAMED
    COM OPERATOR.UNAMED, OPF.NO.UNAMED
    COM P.UNAMED, PGM.TYPE.UNAMED, PGM.TYPE.NEXT.UNAMED, PGM.VERSION.UNAMED, PHNO.UNAMED, PREFIX.UNAMED
    COM PRINTER.STATUS.UNAMED
    COM RETURN.COMI.UNAMED
    COM SCREEN.MODE.UNAMED, SCREEN.TITLE.UNAMED, T.OV.CLASS.UNAMED
    COM TEXT.UNAMED, TIME.STAMP.UNAMED, TNO.UNAMED, TODAY.UNAMED, R.ACCOUNT.PARAMETER.UNAMED, TTYPE.UNAMED
    COM V.UNAMED, VAL.TEXT.UNAMED
*************************************************************************
REM "DYNAMIC ARRAYS:
    COM T.AUTH.PAGE.UNAMED
    COM R.SPF.SYSTEM.UNAMED
    COM T.CAT.UNAMED, T.CCY.UNAMED, CLEAR.SCREEN.UNAMED, T.CONTROLWORD.UNAMED
    COM T.ENRI.UNAMED, T.ETEXT.UNAMED
    COM T.FIELDNO.UNAMED, T.FUNCTION.UNAMED
    COM T.LANGUAGE.UNAMED, FILE.CLASS.UNAMED, CACHE.OFF.UNAMED, T.LOCREF.UNAMED
    COM T.MTH.UNAMED, T.MTH.DAY.UNAMED
    COM T.MULTI.PAGE.UNAMED, F.SPF.UNAMED, CONTROL.MODULO.UNAMED
    COM LEVELS.NOT.ALLOWED.UNAMED, T.MULTI.TEXT.UNAMED, LIMIT.NETTING.IND.UNAMED
    COM T.OPF.UNAMED
    COM T.PWD.UNAMED, T.PWP.UNAMED
    COM T.RAT.UNAMED, T.RETURN.DATA.UNAMED
    COM T.SEQU.UNAMED, T.SUB.ASSOC.UNAMED
    COM BATCH.DETAILS.UNAMED, T.TRS.UNAMED
    COM CACHE.TEXT.TABLE.UNAMED
*************************************************************************
REM "FILENAMES:
    COM F.ACTIVITY.UNAMED
    COM F.FILE.UNAMED, F.FILE$HIS.UNAMED, F.FILE$NAU.UNAMED
    COM F.LOCKING.UNAMED
    COM F.PROTOCOL.UNAMED
    COM F.CURRENCY.UNAMED
    COM LIVE.RECORD.MANDATORY.UNAMED, LANG.NO.UNAMED
    COM F.DYNAMIC.TEXT.UNAMED, F.STATIC.TEXT.UNAMED, F.FILE.CONTROL.UNAMED
    COM T.VAL.ASSOC.UNAMED
*************************************************************************
REM "LOCALLY USED IN APPLICATIONS (BY EQUATE):
    COM LOCAL1.UNAMED, LOCAL2.UNAMED, LOCAL3.UNAMED, LOCAL4.UNAMED
    COM LOCAL5.UNAMED, LOCAL6.UNAMED, LOCAL7.UNAMED, LOCAL8.UNAMED
*************************************************************************
REM "MISCELLANEOUS USE (E.G. PRELIMINARY DURING TEST PERIOD):
    COM F.IDS.LATEST.UNAMED, RUNNING.UNDER.BATCH.UNAMED, T.DEF.BASE.UNAMED, T.DEF.BASE.TARGET.UNAMED
    COM COMI.DEFAULT.UNAMED, CMD$STACK.UNAMED, T.SELECT.UNAMED, LINK.DATA.UNAMED
*************************************************************************
*======================================================================

    IF LCCY THEN
        RETURN      ;* Already setup so don't continue
    END
    
    EB.API.ProductIsInCompany("AC",AC.isInstalled)   ;* check AC product availability in the company
    EB.API.ProductIsInCompany("LI",LI.isInstalled)   ;* check LI product availability in the company

    GOSUB OPEN.FILES          ;* Some fundamental files
    GOSUB INITIALISE.VARIABLES          ;* Like R.SPF.SYSTEM
    GOSUB INITIALISE.USER     ;* User variables like OPERATOR
    GOSUB INITIALISE.COMPANY  ;* The company environment

RETURN
*=====================================================================
OPEN.FILES:

    OPEN 'F.FILE.CONTROL' TO F.FILE.CONTROL ELSE
        TEXT = "Cannot open F.FILE.CONTROL"
        GOTO FATAL.ERROR
    END

    OPEN 'F.LOCKING' TO F.LOCKING ELSE
        TEXT = "Cannot open F.LOCKING"
        GOTO FATAL.ERROR
    END

    OPEN 'F.PROTOCOL' TO F.PROTOCOL ELSE
        TEXT = "Cannot open F.PROTOCOL"
        GOTO FATAL.ERROR
    END

    OPEN 'F.STATIC.TEXT' TO F.STATIC.TEXT ELSE
        TEXT = "Cannot open F.STATIC.TEXT"
        GOTO FATAL.ERROR
    END

    OPEN 'F.DYNAMIC.TEXT' TO F.DYNAMIC.TEXT ELSE
        TEXT = "Cannot open F.DYNAMIC.TEXT"
        GOTO FATAL.ERROR
    END

    OPEN 'F.JOURNAL' TO F.JOURNAL ELSE
        TEXT = "Cannot open F.JOURNAL"
        GOTO FATAL.ERROR
    END

    OPEN 'F.ACTIVITY' TO F.ACTIVITY ELSE
        TEXT = "Cannot open F.ACTIVITY"
        GOTO FATAL.ERROR
    END

    OPEN 'F.SPF' TO F.SPF ELSE
        TEXT = "Cannot open F.SPF"
        GOTO FATAL.ERROR
    END

    OPEN 'F.DATES' TO F.DATES ELSE
        TEXT = "Cannot open F.DATES"
        GOTO FATAL.ERROR
    END

    OPEN 'F.USER' TO F.USER ELSE
        TEXT = "Cannot open F.USER"
        GOTO FATAL.ERROR
    END

    OPEN 'F.USER.SIGN.ON.NAME' TO F.USER.SIGN.ON.NAME ELSE
        TEXT = "Cannot open F.USER.SIGN.ON.NAME"
        GOTO FATAL.ERROR
    END

    OPEN 'F.COMPANY' TO F.COMPANY ELSE
        TEXT = "Cannot open F.COMPANY"
        GOTO FATAL.ERROR
    END

    OPEN 'F.DATES' TO F.DATES ELSE
        TEXT = "Cannot open F.DATES"
        GOTO FATAL.ERROR
    END

    IF AC.isInstalled THEN  ;* check AC product availability in the company
        OPEN 'F.ACCOUNT.PARAMETER' TO F.ACCOUNT.PARAMETER ELSE
            TEXT = "Cannot open F.ACCOUNT.PARAMETER"
            GOTO FATAL.ERROR
        END
    END
RETURN
*============================================================================
INITIALISE.VARIABLES:

    E = ""          ;* In case these are set to 0
    ETEXT = ""
    OPF.NO = ""
    MAT R.OPF = ""
    T.OPF = ""
    TNO = @USERNO   ;* Terminal number
    INPUT.BUFFER.UNAMED = ""
    INPUT.BUFFER = ""         ;* GB0001750

    EB.API.ReadSpf()
 
    IF AC.isInstalled THEN  ;* check AC product availability in the company
        READ R.ACCOUNT.PARAMETER FROM F.ACCOUNT.PARAMETER, "SYSTEM" ELSE
            R.ACCOUNT.PARAMETER = ""        ;* Don't crash cause of this
        END
    END
RETURN
*==========================================================================================
INITIALISE.USER:

    IF NOT(R.USER) THEN
        SELECT F.USER
        LOOP READNEXT USER.ID ELSE USER.ID = "INPUTTER"
        UNTIL USER.ID         ;* Get the first one
        REPEAT
        CLEARSELECT ;* Get rid of current list
        READ R.USER FROM F.USER, USER.ID ELSE
            TEXT = "Cannot read ":USER.ID:" from F.USER"
            GOTO FATAL.ERROR
        END
    END

    READ R.USER.SIGN.ON.NAME FROM F.USER.SIGN.ON.NAME, R.USER<EB.USE.SIGN.ON.NAME> ELSE
        TEXT = "Cannot read ": R.USER<EB.USE.SIGN.ON.NAME>: " from F.USER.SIGN.ON.NAME"
        GOTO FATAL.ERROR
    END

    OPERATOR = R.USER.SIGN.ON.NAME<1>   ;* Key to the user file

RETURN
*===========================================================================================
INITIALISE.COMPANY:

**      YCOMPANY.CODE = R.USER<EB.USE.COMPANY.CODE>
    YCOMPANY.CODE = ID.COMPANY.UNAMED


************************************************************************
*
    DIM YR.COMPANY(EB.COM.AUDIT.DATE.TIME),YR.ACCOUNT.CLASS(AC.CLS.AUTHORISER)
*
************************************************************************
*
    ER = ""
    CALL F.MATREAD("F.COMPANY",YCOMPANY.CODE,MAT YR.COMPANY,EB.COM.AUDIT.DATE.TIME,F.COMPANY,ER)
    IF ER THEN      ;* Company not present
        TEXT = "COMPANY RECORD ":YCOMPANY.CODE:" MISSING"
        GOTO FATAL.ERROR
    END
*
    MAT R.COMPANY = MAT YR.COMPANY
    YR.COMPANY.ID=YCOMPANY.CODE

*-- Just populate here to avoid crash while opening the fin level file.
    IF R.COMPANY(EB.COM.FINANCIAL.MNE) = "" THEN
        R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC)
        R.COMPANY(EB.COM.FINANCIAL.COM) = YCOMPANY.CODE
    END
*------------------------------------------------------------------------
    IF YR.COMPANY.ID <> YR.COMPANY(EB.COM.CUSTOMER.COMPANY) THEN
        YR.COMPANY.ID = YR.COMPANY(EB.COM.CUSTOMER.COMPANY)
        GOSUB READ.CO.RECORD
        FOR I = EB.COM.DEFAULT.CUST.COM TO EB.COM.SPCL.CUST.MNE
            R.COMPANY(I) = YR.COMPANY(I)
        NEXT I
    END
* CHECK CUSTOMER LEVEL CODE, UPDATE IF NECESSARY
*------------------------------------------------------------------------
    YR.COMPANY.ID = YCOMPANY.CODE
    MAT YR.COMPANY = MAT R.COMPANY
    LOOP UNTIL TRIM(YR.COMPANY(EB.COM.DEFAULT.CUST.COM)) = ""
        IF YR.COMPANY(EB.COM.DEFAULT.CUST.COM) <> YR.COMPANY.ID THEN
            YR.COMPANY.ID = YR.COMPANY(EB.COM.DEFAULT.CUST.COM)
            GOSUB READ.CO.RECORD
            R.COMPANY(EB.COM.DEFAULT.CUST.COM) = YR.COMPANY(EB.COM.DEFAULT.CUST.COM)
            R.COMPANY(EB.COM.DEFAULT.CUST.MNE) = YR.COMPANY(EB.COM.DEFAULT.CUST.MNE)
            IF TRIM(YR.COMPANY(EB.COM.SPCL.CUST.FILE)) <> "" THEN
                YCOUNT = COUNT(YR.COMPANY(EB.COM.SPCL.CUST.FILE),@VM) + 1
                FOR J = 1 TO YCOUNT
                    LOCATE YR.COMPANY(EB.COM.SPCL.CUST.FILE)<1,J> IN R.COMPANY(EB.COM.SPCL.CUST.FILE)<1,1> SETTING YX ELSE
                        FOR I = EB.COM.SPCL.CUST.FILE TO EB.COM.SPCL.CUST.MNE
                            R.COMPANY(I)<1,-1> = YR.COMPANY(I)<1,J>
                        NEXT I
                    END
                NEXT J
            END ELSE YR.COMPANY(EB.COM.DEFAULT.CUST.COM) = ""
        END ELSE YR.COMPANY(EB.COM.DEFAULT.CUST.COM) = ""
    REPEAT
* CHECK CUSTOMER TABLE LEVEL DEFAULT CODE, UPDATE IF NECESSARY
*------------------------------------------------------------------------
    YR.COMPANY.ID = YCOMPANY.CODE
    MAT YR.COMPANY = MAT R.COMPANY
    LOOP UNTIL TRIM(YR.COMPANY(EB.COM.DEFAULT.FINAN.COM)) = ""
        IF YR.COMPANY(EB.COM.DEFAULT.FINAN.COM) <> YR.COMPANY.ID THEN
            YR.COMPANY.ID = YR.COMPANY(EB.COM.DEFAULT.FINAN.COM)
            GOSUB READ.CO.RECORD
            R.COMPANY(EB.COM.DEFAULT.FINAN.COM) = YR.COMPANY(EB.COM.DEFAULT.FINAN.COM)
            R.COMPANY(EB.COM.DEFAULT.FINAN.MNE) = YR.COMPANY(EB.COM.DEFAULT.FINAN.MNE)
            IF TRIM(YR.COMPANY(EB.COM.SPCL.FIN.FILE)) <> "" THEN
                YCOUNT = COUNT(YR.COMPANY(EB.COM.SPCL.FIN.FILE),@VM) + 1
                FOR J = 1 TO YCOUNT
                    LOCATE YR.COMPANY(EB.COM.SPCL.FIN.FILE)<1,J> IN R.COMPANY(EB.COM.SPCL.FIN.FILE)<1,1> SETTING YX ELSE
                        FOR I = EB.COM.SPCL.FIN.FILE TO EB.COM.SPCL.FIN.MNE
                            R.COMPANY(I)<1,-1> = YR.COMPANY(I)<1,J>
                        NEXT I
                    END
                NEXT J
            END ELSE YR.COMPANY(EB.COM.DEFAULT.FINAN.COM) = ""
        END ELSE YR.COMPANY(EB.COM.DEFAULT.FINAN.COM) = ""
    REPEAT
* CHECK FINANCIAL TABLE LEVEL DEFAULT CODE, UPDATE IF NECESSARY
*------------------------------------------------------------------------
    MAT YR.COMPANY = MAT R.COMPANY
    IF YR.COMPANY(EB.COM.NOSTRO.COMPANY) <> YCOMPANY.CODE THEN
        YR.COMPANY.ID = YR.COMPANY(EB.COM.NOSTRO.COMPANY)
        GOSUB READ.CO.RECORD
        R.COMPANY(EB.COM.NOSTRO.SUB.DIV) = YR.COMPANY(EB.COM.SUB.DIVISION.CODE)
        IF AC.isInstalled THEN      ;* check AC product availability in the company
            F.ACCOUNT.CLASS = "" ; CALL OPF("F.ACCOUNT.CLASS",F.ACCOUNT.CLASS)
            MATREAD YR.ACCOUNT.CLASS FROM F.ACCOUNT.CLASS,"INTERCO" ELSE
                TEXT = "'INTERCO' RECORD MISSING"
                GOTO FATAL.ERROR
            END
    
            R.COMPANY(EB.COM.INTER.COM.CATEGORY) = YR.ACCOUNT.CLASS(AC.CLS.CATEGORY)
        END
    END
*
*
* Initiate common
*------------------------------------------------------------------------
    LCCY = R.COMPANY(EB.COM.LOCAL.CURRENCY)       ;* Local currency
    ID.COMPANY = YCOMPANY.CODE          ;* Company Id
*
***!      SEARCH.KEYS = ""
***!      SEARCH.KEYS.LOADED = ""
    MATREAD R.DATES FROM F.DATES, ID.COMPANY ELSE
        TEXT = "DATES RECORD MISSING ":ID.COMPANY
        GOTO FATAL.ERROR
    END
*
    TODAY = R.DATES(EB.DAT.TODAY)       ;* Todays date
*
    T.OPF = ""      ;* Clear opf tables
    OPF.NO = 0
*
    T.CAT = ""      ;* Clear UPDxxx tables
    T.CCY = ""
    T.MTH = ""
    T.MTH.DAY = ""
    T.RAT = ""
    T.TRS = ""
*
    T.LANGUAGE = '' ;* Update language abbreviations
    Y.ID = 0
    ETEXT = ""
    T.LANGUAGE<1> = "GB"
*
    CCY.TABLE = ""  ;* Used by F.READ etc
*
    IF EB.MdalFramework.isEmbeddedObject('MDLMKT') THEN
        CALL OPF("F.CURRENCY",F.CURRENCY)   ;* Files opened in SIGN ON
    END
*
    C$R.LCCY = ''
    C$R.LCCY = MDLMKT.MarketData.getCurrencyInfo(LCCY)
    ETEXT = ''
*
* Check for interest/taxes records to be stored
*
    IF AC.isInstalled THEN      ;* check AC product availability in the company
        IF R.ACCOUNT.PARAMETER<AC.PAR.INT.MVMT.UPDATE> EQ 'Y' THEN
            F.INT.MOVEMENT.PARAM = ''
            CALL OPF ('F.INT.MOVEMENT.PARAM', F.INT.MOVEMENT.PARAM )
            READ C$INT.MOVEMENT.PARAM FROM F.INT.MOVEMENT.PARAM, 'SYSTEM' ELSE C$INT.MOVEMENT.PARAM = ''
        END
    END
**
** PIF GB9500567
**
    IF R.COMPANY(EB.COM.LOCAL.PROCESS.NAME) NE '' THEN
        READ.FAILED = ''
        BRP.ID = R.COMPANY(EB.COM.LOCAL.PROCESS.NAME)
        R.BANK.RETURN.PARAMS = ''
        CALL F.READ('F.BANK.RETURN.PARAMS',BRP.ID,R.BANK.RETURN.PARAMS,F.BANK.RETURN.PARAMS,READ.FAILED)
        IF READ.FAILED THEN
            CALL EXCEPTION.LOG("U", "EB", "LOAD.COMPANY", "LOAD.COMPANY", "900", "", "F.BANK.RETURN.PARAMS", BRP.ID, "", "RECORD MISSING", R.USER<EB.USE.DEPARTMENT.CODE>)
        END
    END
**
** END OF PIF GB9500567
**
*
*
* Call LIMIT.CURR.CONV to set customer company file and lccy for cust
* company
*

    IF LI.isInstalled THEN  ;* check LI product availability in the company
        YPROC.FLAG = 'SETUP'
        CALL LIMIT.CURR.CONV("","","","",YPROC.FLAG)
    END

*
* Initialise account group common - reset init flag - hence first call to
* accounting will force re-open of files.
*
    C$AGC.INIT = ""
*
*
    GOTO END.OF.PROCESS
*
* SETUP EB.COM.NOSTRO ACCOUNT PROCESSING DETAILS
*------------------------------------------------------------------------
READ.CO.RECORD:
* GB9901118 S
    IF YR.COMPANY.ID NE '' THEN
        TEXT=""
        MATREAD YR.COMPANY FROM F.COMPANY,YR.COMPANY.ID ELSE
            TEXT="COMPANY RECORD ":YR.COMPANY.ID:" MISSING"
            GOTO FATAL.ERROR
        END
    END
RETURN
* GB9901118 E

END.OF.PROCESS:
RETURN
*------------------------------------------------------------------------
FATAL.ERROR:

    HUSH OFF        ;* In case it's on
    CRT TEXT        ;* In case FATAL.ERROR doesn't show it
    CALL FATAL.ERROR("INITIALISE.MAIN.COMMON")

RETURN
*========================================================================
END
