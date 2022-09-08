* @ValidationCode : MjotMTUyNzMxNTEyMjpDcDEyNTI6MTYxNTIyMTc0MDQ4MzpzdWRoYW5rOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1Njo0MzI6MTM0
* @ValidationInfo : Timestamp         : 08 Mar 2021 22:12:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudhank
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 134/432 (31.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>8544</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.Config

SUBROUTINE HOLIDAY
REM "HOLIDAY",840528-001,"MAINPGM"
*-----------------------------------------------------------------------------
* Modifications History :
*
* 17/2/2020 - Task 3592441
*            Data Quality Changes in AFW - ST.Config
*
* 22/02/2021 - Enhancement 4218381 / Task 4227104
*              Changes to update MDAL Common variables
*
* ------------------------------------------------------------------------------
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING ST.Config
    $USING EB.Utility
    $USING EB.DataAccess
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.Template
    $USING EB.Service
    $USING EB.MdalFramework

    EQU NOTNUMERIC TO 0

*
* 18/10/96 - GB9601432
*            Allow holidays greater than 2050
*
* 02/07/97 - GB9700785
*            Define the N parameter to allow the records to
*            be displayed in GUI correctly.
*-----------------------------------------------------------------------------
* 16/01/01 - GB0100016
*            Stop users from changing a date to a holiday when DX trades
*            mature on that date.
*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
*11/10/02 - GLOBUS_BG_100002352
*         Syntax Error in ETEXT
*
* 29/10/02 - GLOBUS_BG_100002581
*            Compilation Error - Warning
*
* 09/06/03 - BG_100004419
*            CHeck for local holiday against the batch holiday field
*            PS the old code had a bug checking against region the fmt
*            statement added a text mark.
*
* 16/01/04 - BG_100006027
*            Check for leap year calculation, specifically for years that are divisible by 100.
*
* 17/06/05 - EN_10002570
*            Addition of 12 more fields, WRK.WKND.JANUARY - WRK.WKND.DECEMBER at the
*            end, to override certain weekend dates of any particular months of the
*            year as working days.
*            Ref: SAR-2004-09-01-0005
*
* 02/09/05 - BG_100009354
*            Specify the length of the field WRK.WKND.APRIL correctly.
*
* 17/02/06 - CI_10039066
*            Changed CLEARFILE to EB.CLEAR.FILE so as to enable to clear
*            the record from the disk only at the end of program.
*
* 09/07/08 - CI_10056568
*            Validation added while authorisation to check for date change not less
*            than the next working date. Previously this validation was only present
*            during input stage but now also added to auth stage.
*
* 20/12/09 - CI_10068319
*            When a new HOLIDAY record is inputted for BATCH bypass the check
*            for changed date which compares R.NEW and R.OLD since R.OLD wont be present.
*
* 09/02/12 - Task 353018
*            Stop checking whether the date which is make as a holiday is the maturity date of
*			 DX.TRADE or not
*
* 08/06/12 - Defect - 419483 / Task - 419799
*            System defaults weekends as SATURDAY and SUNDAY only when there is no value in that field.
*
* 30/11/16 - Defect - 1802042; Task - 1915028
*            Whenever Holidays are added in between to the HOLIDAY table, the FORW.VALUE.MAXIMUM field in DATES table
*            is handled to get updated respectivly.
*
* 06/05/19 - Defect 3103703 / Task 3115203
*            When amending holiday record, instead of clearing the entire MUTUAL.WORKING.DAY file,
*            delete only the records that are related to the amended holiday record. Thus avoiding the
*            rebuilding of entire MUTUAL.WORKING.DAY in the cob.
*
*14/01/2020 - Enhancement 3536345/ Task 3536546
*             Length Of JANUARY increased from 35 to 75
*             Length Of FEBRUARY increased from 35 to 75
*             Length Of MARCH increased from 35 to 75
*             Length Of APRIL increased from 35 to 75
*             Length Of MAY increased from 35 to 75
*             Length Of JUNE increased from 35 to 75
*             Length Of JULY increased from 35 to 75
*             Length Of AUGUST increased from 35 to 75
*             Length Of SEPTEMBER increased from 35 to 75
*             Length Of OCTOBER increased from 35 to 75
*             Length Of NOVEMBER increased from 35 to 75
*             Length Of DECEMBER increased from 35 to 75
*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/HOLIDAY/.../G9999')
*========================================================================
    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)
    DIM CONCATFILE(EB.SystemTables.SysDim)

    MAT F = "" ; MAT N = "" ; MAT T = "" ; ID.T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""
*========================================================================
REM "DEFINE PARAMETERS - SEE 'I_RULES'-DESCRIPTION:
    ID.F = "HOLIDAY.CODE" ; ID.N = "10.6" ; ID.T = "SS"
* ID.CHECKFILE programmed separately (for only a part of ID)
    ID.CONCATFILE = "AL" ; ID.T<4> = "R## ## ####" ; ID.T<2> = "ND"

    EB.SystemTables.SetIdProperties(ID.F,ID.N,ID.T,ID.CONCATFILE,ID.CHECKFILE)

    F(1) = "JANUARY" ; N(1) = "150..C" ; T(1) = "A"
    F(2) = "FEBRUARY" ; N(2) = "150..C" ; T(2) = "A"
    F(3) = "MARCH" ; N(3) = "150..C" ; T(3) = "A"
    F(4) = "APRIL" ; N(4) = "150..C" ; T(4) = "A"
    F(5) = "MAY" ; N(5) = "150..C" ; T(5) = "A"
    F(6) = "JUNE" ; N(6) = "150..C" ; T(6) = "A"
    F(7) = "JULY" ; N(7) = "150..C" ; T(7) = "A"
    F(8) = "AUGUST" ; N(8) = "150..C" ; T(8) = "A"
    F(9) = "SEPTEMBER" ; N(9) = "150..C" ; T(9) = "A"
    F(10) = "OCTOBER" ; N(10) = "150..C" ; T(10) = "A"
    F(11) = "NOVEMBER" ; N(11) = "150..C" ; T(11) = "A"
    F(12) = "DECEMBER" ; N(12) = "150..C" ; T(12) = "A"
    F(13) = "XX.WEEKEND.DAYS" ; N(13) = "2"
    T(13) = @FM:"MO_TU_WE_TH_FR_SA_SU"
    F(14) = "MTH.01.TABLE" ; N(14) = "31" ; T(14) = "A":@FM:@FM:"NOINPUT"
    F(15) = "MTH.02.TABLE" ; N(15) = "31" ; T(15) = "A":@FM:@FM:"NOINPUT"
    F(16) = "MTH.03.TABLE" ; N(16) = "31" ; T(16) = "A":@FM:@FM:"NOINPUT"
    F(17) = "MTH.04.TABLE" ; N(17) = "31" ; T(17) = "A":@FM:@FM:"NOINPUT"
    F(18) = "MTH.05.TABLE" ; N(18) = "31" ; T(18) = "A":@FM:@FM:"NOINPUT"
    F(19) = "MTH.06.TABLE" ; N(19) = "31" ; T(19) = "A":@FM:@FM:"NOINPUT"
    F(20) = "MTH.07.TABLE" ; N(20) = "31" ; T(20) = "A":@FM:@FM:"NOINPUT"
    F(21) = "MTH.08.TABLE" ; N(21) = "31" ; T(21) = "A":@FM:@FM:"NOINPUT"
    F(22) = "MTH.09.TABLE" ; N(22) = "31" ; T(22) = "A":@FM:@FM:"NOINPUT"
    F(23) = "MTH.10.TABLE" ; N(23) = "31" ; T(23) = "A":@FM:@FM:"NOINPUT"
    F(24) = "MTH.11.TABLE" ; N(24) = "31" ; T(24) = "A":@FM:@FM:"NOINPUT"
    F(25) = "MTH.12.TABLE" ; N(25) = "31" ; T(25) = "A":@FM:@FM:"NOINPUT"
    F(26)= "WRK.WKND.JANUARY"  ; N(26) = "35..C" ; T(26) = "A"
    F(27)= "WRK.WKND.FEBRUARY" ; N(27) = "35..C" ; T(27) = "A"
    F(28)= "WRK.WKND.MARCH" ; N(28) = "35..C" ; T(28) = "A"
    F(29)= "WRK.WKND.APRIL" ; N(29) = "35..C" ; T(29) = "A"
    F(30)= "WRK.WKND.MAY"  ; N(30) = "35..C" ; T(30) = "A"
    F(31)= "WRK.WKND.JUNE" ; N(31) = "35..C" ; T(31) = "A"
    F(32)= "WRK.WKND.JULY" ; N(32) = "35..C" ; T(32) = "A"
    F(33)= "WRK.WKND.AUGUST"   ; N(33) = "35..C" ; T(33) = "A"
    F(34)= "WRK.WKND.SEPTEMBER"  ; N(34) = "35..C" ; T(34) = "A"
    F(35)= "WRK.WKND.OCTOBER" ; N(35) = "35..C" ; T(35) = "A"
    F(36)= "WRK.WKND.NOVEMBER" ; N(36) = "35..C" ; T(36) = "A"
    F(37)= "WRK.WKND.DECEMBER" ; N(37) = "35..C" ; T(37) = "A"
    V = 46


    EB.SystemTables.SetFieldProperties(MAT F, MAT N, MAT T,MAT CONCATFILE,MAT CHECKFILE, V)

    EB.SystemTables.setPrefix("EB.HOL")


    T.CHECKFILE = 1:@FM:2:@FM:3:@FM:4:@FM:5:@FM:6:@FM:7:@FM:8:@FM:9:@FM:10:@FM:11:@FM:12
*========================================================================
    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN
        ID.R.VAL = ''
        ID.R.VAL = "a) 2 SWIFT ('A-Z' only) char. COUNTRY.CODE - must "
        ID.R.VAL = ID.R.VAL:"be an ID of a COUNTRY-record":@FM
        ID.R.VAL = ID.R.VAL:"ba) no char. = no REGION or":@FM
        ID.R.VAL = ID.R.VAL:"bb) REGION.CODE 1...99"
        ID.R.VAL = ID.R.VAL:@FM:"c) Year 1950...2049":@FM
        ID.R.VAL = ID.R.VAL:"a)+b) must be an ID of a REGION-record"
        EB.SystemTables.setIdR(ID.R.VAL)
        EB.SystemTables.setR(1, "a) day 01...31 (leading zero mandatory)":@FM)
        EB.SystemTables.setR(1, EB.SystemTables.getR(1):"b) blank before input next day":@FM)
        EB.SystemTables.setR(1, EB.SystemTables.getR(1):"Date must be valid":@FM)
        EB.SystemTables.setR(1, EB.SystemTables.getR(1):"No input of WEEKEND.DAYS or duplicates")
        EB.SystemTables.setR(1, EB.SystemTables.getR(1):@FM:"Same checks for the next 11 fields!")
        EB.SystemTables.setR(13, "No duplicates":@FM)
        EB.SystemTables.setR(13, EB.SystemTables.getR(13):"'SA' and 'SU' automatically placed when ")
        EB.SystemTables.setR(13, EB.SystemTables.getR(13):"starting a new record")
        RETURN
* RETURN when pgm used to get parameters only
    END
*------------------------------------------------------------------------
*
* Initialise variables used for validation purposes
*
    DIM YR.OLD(EB.SystemTables.getV())
    MAT YR.OLD = ""
    FN.MUTUAL.WORKING.DAY= "F.MUTUAL.WORKING.DAY"
    F.MUTUAL.WORKING.DAY = ""
    EB.DataAccess.Opf(FN.MUTUAL.WORKING.DAY,F.MUTUAL.WORKING.DAY)
*
    EB.Display.MatrixUpdate()
*------------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN RETURN
* return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
*========================================================================
REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" OR EB.SystemTables.getVFunction() = "R" THEN
            EB.SystemTables.setE("ST.RTN.NO.FUNT.APP.7"); EB.SystemTables.setVFunction("")
ID.ERROR:
            EB.ErrorProcessing.Err() ; GOTO ID.INPUT
        END
*========================================================================
        IF EB.SystemTables.getVFunction() = "E" OR EB.SystemTables.getVFunction() = "L" THEN
            EB.Display.FunctionDisplay() ; EB.SystemTables.setVFunction("")
        END
        GOTO ID.INPUT
    END
*========================================================================
REM "CHECK ID OR CHANGE STANDARD ID:
    COMI2 = EB.SystemTables.getComi()[3,99] ; EB.SystemTables.setComi(EB.SystemTables.getComi()[1,2])
    EB.Template.In2sss("2.2","SSS")
    IF EB.SystemTables.getEtext()<> "" THEN EB.SystemTables.setE("COUNTRY: ":EB.SystemTables.getEtext()); GOTO ID.ERROR
    EB.SystemTables.setIdNew(EB.SystemTables.getComi())
    IF LEN(COMI2) = 4 THEN
        EB.SystemTables.setComi("")
    END ELSE
        IF LEN(COMI2) = 5 THEN
            EB.SystemTables.setComi(COMI2[1,1]); COMI2 = COMI2[2,99]
        END ELSE
            EB.SystemTables.setComi(COMI2[1,2]); COMI2 = COMI2[3,99]
        END
        EB.Template.InTwo("2","")
        IF EB.SystemTables.getEtext()<> "" THEN EB.SystemTables.setE("REGION: ":EB.SystemTables.getEtext()); GOTO ID.ERROR
    END
    IF COMI2 < "1950" THEN
        EB.SystemTables.setE("ST.RTN.YEAR.CANT.BEFORE.1950"); GOTO ID.ERROR
    END
    COMI.VAL = EB.SystemTables.getComi()
    EB.SystemTables.setIdNew(EB.SystemTables.getIdNew():FMT(COMI.VAL,'2"0"R'):COMI2)
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    EB.SystemTables.setVDisplay(FMT(ID.NEW.VAL,EB.SystemTables.getIdT()<4>))
    ID.ENRI.VAL = ''
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    EB.DataAccess.Dbr("COUNTRY":@FM:ST.Config.Country.EbCouCountryName:@FM:"L",ID.NEW.VAL[1,2],ID.ENRI.VAL)
    EB.SystemTables.setIdEnri(ID.ENRI.VAL)
    ETEXT.VAL = EB.SystemTables.getEtext()
    IF ETEXT.VAL <> "" THEN EB.SystemTables.setE(ETEXT.VAL); GOTO ID.ERROR
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    IF ID.NEW.VAL[3,2] <> "00" THEN
        CHECKFILE2 = "REGION":@FM:ST.Config.Region.EbRegRegionName:@FM:"L" ; Y = ""
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        EB.DataAccess.Dbr(CHECKFILE2,ID.NEW.VAL[1,4],Y)
        ETEXT.VAL = EB.SystemTables.getEtext()
        IF ETEXT.VAL <> "" THEN EB.SystemTables.setE(ETEXT.VAL); GOTO ID.ERROR
        EB.SystemTables.setIdEnri(EB.SystemTables.getIdEnri():" ":Y)
    END
*========================================================================
    EB.TransactionControl.RecordRead()
    IF EB.SystemTables.getMessage() = "REPEAT" THEN GOTO ID.INPUT
* special place for CALL MATRIX.ALTER (after following change)
*========================================================================
REM "SPECIAL CHECKS OR CHANGE FIELDS AFTER READING RECORD(S):
* Default week ends as SATURDAY and SUNDAY, when there is no value in WEEKEND.DAYS field.
    V.VAL = EB.SystemTables.getV()
    IF EB.SystemTables.getRNew(V.VAL-7) = "" AND EB.SystemTables.getRNew(ST.Config.Holiday.EbHolWeekendDays) EQ "" THEN
        tmp=EB.SystemTables.getRNew(13); tmp<1,1>="SA"; EB.SystemTables.setRNew(13, tmp); tmp=EB.SystemTables.getRNew(13); tmp<1,2>="SU"; EB.SystemTables.setRNew(13, tmp)
    END
* = standard weekend days
    EB.Display.MatrixAlter()
    EB.SystemTables.setAf(1); EB.SystemTables.setAv(1); EB.SystemTables.setAs(1)
*========================================================================
FIELD.DISPLAY.OR.INPUT:
    BEGIN CASE
        CASE EB.SystemTables.getScreenMode() = "MULTI"
            IF EB.SystemTables.getFileType() = "I" THEN
                EB.Display.FieldMultiInput()
            END ELSE EB.Display.FieldMultiDisplay()
        CASE EB.SystemTables.getFileType() = "I" ; EB.Display.FieldInput()
        CASE 1 ; EB.Display.FieldDisplay()
    END CASE
*------------------------------------------------------------------------
HANDLE.MESSAGE:
    BEGIN CASE
        CASE EB.SystemTables.getMessage() = "REPEAT" ; NULL
        CASE EB.SystemTables.getMessage() = "VAL"
            EB.SystemTables.setMessage("")
            IF EB.SystemTables.getVFunction() = "D" OR EB.SystemTables.getVFunction() = "R" THEN
*========================================================================
REM "HANDLING REVERSAL:
*========================================================================
                NULL
            END ELSE
*========================================================================
REM "HANDLING 'VAL'-CHECKS:
                EB.SystemTables.setAf(13); EB.Template.Dup()
*========================================================================
REM "HANDLE AUTOM. CALCULATED FIELDS (BEGINNING WITH OVERRIDE):
                WEEKEND.NO = COUNT(EB.SystemTables.getRNew(13),@VM)+1 ; DAYNO = 7 ; X = 1950
                LOOP
                UNTIL X = EB.SystemTables.getIdNew()[5,4] DO
                    IF MOD(X,4) = 0 THEN DAYNO = DAYNO+1
                    DAYNO = DAYNO+365 ; X = X+1
                REPEAT
                DAYNO = MOD(DAYNO,7) ; IF DAYNO = 0 THEN DAYNO = 7
* calculate day number for Jan, 1 (1950-01-01 = 7)
                FOR A.POS = 1 TO 12
                    EB.SystemTables.setA(A.POS)
                    BEGIN CASE
                        CASE A.POS = 2
                            ID.NEW.VAL = EB.SystemTables.getIdNew()
                            IF MOD(ID.NEW.VAL[5,4],4) = 0 THEN          ;*A year divisible by 4 as well as 100 should also be divisible by 400 ;* BG_100006027 S
                                IF MOD(ID.NEW.VAL[5,4],100) <> 0 THEN MONTH.LENGTH = 29
                                ELSE
                                    IF MOD(ID.NEW.VAL[5,4],400) = 0 THEN MONTH.LENGTH = 29
                                    ELSE MONTH.LENGTH = 28
                                END
                            END       ;* BG_100006027 E
                            ELSE MONTH.LENGTH = 28
                        CASE A.POS = 4 OR A.POS = 6 OR A.POS = 9 OR A.POS = 11
                            MONTH.LENGTH = 30
                        CASE 1 ; MONTH.LENGTH = 31
                    END CASE

                    EB.SystemTables.setTMth(STR("W",MONTH.LENGTH))
                    EB.SystemTables.setTMth(EB.SystemTables.getTMth():STR("X",31-MONTH.LENGTH))
                    FOR AV.POS = 1 TO WEEKEND.NO
                        EB.SystemTables.setAv(AV.POS)
                        X = EB.SystemTables.getRNew(13)<1,AV.POS>
                        IF X <> "" THEN
                            BEGIN CASE
                                CASE X = "MO" ; Y = 1
                                CASE X = "TU" ; Y = 2
                                CASE X = "WE" ; Y = 3
                                CASE X = "TH" ; Y = 4
                                CASE X = "FR" ; Y = 5
                                CASE X = "SA" ; Y = 6
                                CASE X = "SU" ; Y = 7
                            END CASE
                            X = Y-DAYNO+1
                            IF X < 1 THEN X = X+7
                            LOOP
                            UNTIL X > MONTH.LENGTH DO
                                EB.SystemTables.setTMth(EB.SystemTables.getTMth()[1,X-1]:"H":EB.SystemTables.getTMth()[X+1,99])
                                X = X+7
                            REPEAT
                        END
                    NEXT AV.POS
                    I.MTH = EB.SystemTables.getRNew(A.POS)
                    Y.DATES = ""
                    LOOP
                    UNTIL I.MTH = "" DO
                        EB.SystemTables.setEtext("")
                        BEGIN CASE
                            CASE TRIM(I.MTH[3,1]) <> ""
                                EB.SystemTables.setEtext("ST.RTN.INP.NN.NN.NN")
                            CASE NUM(I.MTH[1,2]) = NOTNUMERIC
                                EB.SystemTables.setEtext("ST.RTN.INP.NOT.NUMERIC")
                            CASE I.MTH[1,2] < 1 OR I.MTH[1,2] > MONTH.LENGTH
                                EB.SystemTables.setEtext("ST.RTN.INVALID.DATE")
                            CASE EB.SystemTables.getTMth()[I.MTH[1,2],1] = "W"
                                X = I.MTH[1,2]
                                Y.DATES = INSERT(Y.DATES,1,-1,0,X)
                                EB.SystemTables.setTMth(EB.SystemTables.getTMth()[1,X-1]:"H":EB.SystemTables.getTMth()[X+1,99])
                            CASE 1
                                LOCATE I.MTH[1,2] IN Y.DATES<1,1> SETTING YX ELSE YX = 0
                                IF YX <> 0 THEN
                                    EB.SystemTables.setEtext("ST.RTN.DUPLICATE":@FM:I.MTH[1,2])
                                END ELSE
                                    EB.SystemTables.setEtext("ST.RTN.WEEKEND":@FM:I.MTH[1,2]);* GLOBUS_BG_100002352 S/E    GLOBUS_BG_100002581 S/E
                                END
                        END CASE

                        IF EB.SystemTables.getEtext()<> "" THEN
                            A2 = A.POS ; EB.SystemTables.setAf(A.POS); EB.ErrorProcessing.StoreEndError()
                            EB.SystemTables.setA(A2)
                            A.POS = EB.SystemTables.getA()
                        END
                        IF LEN(I.MTH) > 2 THEN I.MTH = I.MTH[4,99]
                        ELSE I.MTH = ""
                    REPEAT
                    EB.SystemTables.setRNew(A.POS+13, EB.SystemTables.getTMth()); DAYNO = DAYNO+MONTH.LENGTH
                    DAYNO = MOD(DAYNO,7) ; IF DAYNO = 0 THEN DAYNO = 7

                NEXT A.POS
*
* The below code is for the validation of the fields WRK.WKND.JANUARY - WRK.WKND.DECEMBER
* Validations:
* 1. Should be a valid weekend date.
* 2. Should not try to change a declared holiday.
*
                FOR FIELD.NO = 26 TO 37     ;* WRK.WKND.JANUARY - WRK.WKND.DECEMBER
                    ERR.WKNDS = ''          ;* err.var , initialising
                    HOL.FOR.THIS.MONTH = '' ;* will be storing the holiday map for this month
                    IF EB.SystemTables.getRNew(FIELD.NO) THEN ;* anything input
                        WRK.WKNDS = EB.SystemTables.getRNew(FIELD.NO)   ;* working weekends defined
                        CONVERT " "  TO @FM IN WRK.WKNDS         ;* converting SPACE to FM for ease of operation
                        NO.OF.WRK.WKNDS = COUNT(WRK.WKNDS,@FM) + (WRK.WKNDS <> '')   ;* count of wrk.weekdns
                        HOL.FOR.THIS.MONTH = EB.SystemTables.getRNew(FIELD.NO-12) ;* HOLIDAY map for this month
                        LOOP
                            REMOVE WRK.WKND FROM WRK.WKNDS SETTING POSWKD
                        WHILE WRK.WKND:POSWKD
                            HOL.OR.NOT = HOL.FOR.THIS.MONTH[WRK.WKND,1]   ;* extracting this particular day
                            IF HOL.OR.NOT = 'H' THEN  ;* if it is a HOLIDAY
                                DECLARED.HOLIDAYS = EB.SystemTables.getRNew(FIELD.NO-25)    ;* get the DECLARED.HOLIDAYS for that month
                                CONVERT '' TO @FM IN DECLARED.HOLIDAYS     ;* converting SPACE to FM for ease of operation
                                LOCATE WRK.WKND IN DECLARED.HOLIDAYS<1> SETTING DEC.POS THEN  ;* if it delcared holiday
                                    IF ERR.WKNDS THEN
                                        ERR.WKNDS :=',':WRK.WKND          ;* say this is not a weekend holiday but a declared holiday
                                    END ELSE
                                        ERR.WKNDS = WRK.WKND
                                    END
                                END
                            END ELSE
                                IF ERR.WKNDS THEN
                                    ERR.WKNDS :=',':WRK.WKND    ;* this is already a working day
                                END ELSE
                                    ERR.WKNDS = WRK.WKND
                                END
                            END
                            IF ERR.WKNDS = '' THEN    ;* no error so far
                                HOL.FOR.THIS.MONTH[WRK.WKND,1] = 'W'      ;* then change the holiday to working.day
                            END
                        REPEAT
                        IF ERR.WKNDS THEN
                            EB.SystemTables.setEtext('ST.RTN.NOT.WKN.END.HOL':@FM:ERR.WKNDS)
                            EB.SystemTables.setAf(FIELD.NO); EB.SystemTables.setAv(1); EB.SystemTables.setAs(1); EB.ErrorProcessing.StoreEndError()
                        END ELSE
                            EB.SystemTables.setRNew(FIELD.NO-12, HOL.FOR.THIS.MONTH);* put the changed HOLIDAY map
                        END
                    END
                NEXT FIELD.NO
*

* CHECK to ensure that NEXT.WORKING.DAY cannot be declared as a holiday and weekend before the
* next.working.day cannot be declared as a working.day.
*

* result: mth.table = 31 char.
* W = working day; H = holiday (or weekend); X = not existing day
*
                GOSUB CHECK.CHANGED.DATE
*========================================================================
REM "HANDLING UPDATE SPECIAL FILES:
*========================================================================
            END
            EB.TransactionControl.UnauthRecordWrite()
    
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
            IF EB.SystemTables.getMessage() = "AUT" THEN GOTO HANDLE.MESSAGE
        CASE EB.SystemTables.getMessage() = "AUT"

            GOSUB CHECK.CHANGED.DATE
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setE(EB.SystemTables.getEtext())
                EB.ErrorProcessing.Err()
                GOTO ID.INPUT
            END
*========================================================================
REM "DEFINE FINAL CHECKS BEFORE STORING AUTHORISED LIFE FILE RECORD:
            EB.SystemTables.setTMth(""); EB.SystemTables.setTMthDay("")
* cancel presently used holiday tables (may be changed with
* following authorising)
*========================================================================
            V.VAL = EB.SystemTables.getV()
            IF EB.SystemTables.getRNew(V.VAL-8)[1,1] = "R" THEN
                NULL
* reversal normally only after special checks
* e.g. you can't reverse CUSTOMER record before ACCOUNT record
            END
* To ensure that the difference between TODAY and FORW.VALUE.MAXiMUM remains constant when HOLIDAY dates are updated in between.
    
            ST.Config.DatesCheck()
            GOSUB CLEAR.MWD ; *On modifying a holiday respective mutual working day records should be deleted
            EB.MdalFramework.setMdalScope("holiday")
            EB.MdalFramework.setMdalKeys("holidayId")
            EB.MdalFramework.setMdalValues(EB.SystemTables.getIdNew())
            EB.TransactionControl.AuthRecordWrite()
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT

        CASE 1
*========================================================================
REM "DEFINE SPECIAL FIELD CHECKS:

            AF.POS = EB.SystemTables.getAf()
            IF AF.POS NE 13 AND EB.SystemTables.getComi()<> "" THEN
                BEGIN CASE
                    CASE AF.POS = 2 OR AF.POS = 27
                        ID.NEW.VAL = EB.SystemTables.getIdNew()
                        IF MOD(ID.NEW.VAL[5,4],4) = 0 THEN    ;* A year divisible by 4 as well as 100 should also be divisible by 400 ;* BG_100006027 S
                            IF MOD(ID.NEW.VAL[5,4],100) <> 0 THEN MONTH.LENGTH = 29
                            ELSE
                                IF MOD(ID.NEW.VAL[5,4],400) = 0 THEN MONTH.LENGTH = 29
                                ELSE MONTH.LENGTH = 28
                            END
                        END ;* BG_100006027 E
                        ELSE MONTH.LENGTH = 28
                    CASE AF.POS = 4 OR AF.POS = 29 OR AF.POS = 6 OR AF.POS = 31 OR AF.POS = 9 OR AF.POS = 34 OR AF.POS = 11 OR AF.POS = 36
                        MONTH.LENGTH = 30
                    CASE 1 ; MONTH.LENGTH = 31
                END CASE
                T.DAY = STR("0",MONTH.LENGTH)
                COMI1 = EB.SystemTables.getComi() ; COMI2 = EB.SystemTables.getComi()

                LOOP
                    IF LEN(COMI2) = 1 THEN
DAY.ERROR:
                        EB.SystemTables.setE("ST.RTN.INVALID.DAY..BLANK.BETWEEN.DAYS")
INPUT.COMMON.ERROR:
                        EB.ErrorProcessing.Err() ; EB.SystemTables.setTSequ("IFLD")
                        GOTO FIELD.DISPLAY.OR.INPUT
                    END ELSE
                        EB.SystemTables.setComi(COMI2[1,2]); COMI2 = COMI2[3,99]
                        COMI.VAL = EB.SystemTables.getComi()
                        BEGIN CASE
                            CASE COMI.VAL[1,1] < "0" OR COMI.VAL[1,1] > "3"
                                GOTO DAY.ERROR
                            CASE COMI.VAL[2,1] < "0" OR COMI.VAL[2,1] > "9"
                                GOTO DAY.ERROR
                            CASE COMI.VAL[1,2] = "00"
                                GOTO DAY.ERROR
                            CASE COMI2 <> "" AND COMI2[1,1] <> " "
                                GOTO DAY.ERROR
                            CASE COMI.VAL > LEN(T.DAY)
                                GOTO DAY.ERROR
                            CASE T.DAY[COMI.VAL,1] = "1"
                                EB.SystemTables.setE("ST.RTN.DAY.DEF.TWICE")
                                GOTO INPUT.COMMON.ERROR
                            CASE EB.SystemTables.getAf() >= 26 AND EB.SystemTables.getAf() <=37
                                IF COMI.VAL AND NOT(EB.SystemTables.getRNew(13)) THEN
                                    EB.SystemTables.setE('ST.RTN.INP.ONLY.IF.WKENDS.DEF')
                                    GOTO INPUT.COMMON.ERROR
                                END
                        END CASE
                        T.DAY = T.DAY[1,COMI.VAL-1]:"1":T.DAY[COMI.VAL+1,99]
                        T.DAY[COMI.VAL,1] = "1"
                    END
                UNTIL COMI2 = "" DO
                    COMI2 = COMI2[2,99]
                REPEAT
                EB.SystemTables.setComi(COMI1)
            END
*========================================================================
            IF EB.SystemTables.getTSequ()<> "" THEN tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA()+1; EB.SystemTables.setTSequ(tmp)
            GOTO FIELD.DISPLAY.OR.INPUT
*------------------------------------------------------------------------
    END CASE
    GOTO ID.INPUT
*
*-----LOCAL HOLIDAY------------------------------------------------------
*
LOCAL.HOLIDAY:
    ID.YEAR=EB.SystemTables.getIdNew()[5,4]
    IF ID.YEAR=EB.SystemTables.getToday()[1,4] THEN
        EB.SystemTables.setAf(EB.SystemTables.getToday()[5,2]); I1=EB.SystemTables.getToday()[7,2]
        IF ID.YEAR=EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[1,4] THEN         ;* same year
            IF EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[5,2]#EB.SystemTables.getAf() THEN          ;* different month (next assumed)
                I2=31 ; GOSUB CURRENT.PERIOD
                EB.SystemTables.setAf(EB.SystemTables.getAf() +1); I1=1 ; I2=EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[7,2]
            END ELSE          ;* same month
                I2=EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[7,2]-I1+1
            END
        END ELSE    ;* year-end
            I2=31
        END
        GOSUB CURRENT.PERIOD
    END ELSE
        IF ID.YEAR=EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[1,4] THEN         ;* year-end, january assumed
            EB.SystemTables.setAf(1); I1=1 ; I2=EB.SystemTables.getRDates(EB.Utility.Dates.DatNextWorkingDay)[7,2]
            GOSUB CURRENT.PERIOD
        END
    END
RETURN
*
*-----CURRENT PERIOD-----------------------------------------------------
*
CURRENT.PERIOD:

    A$=EB.SystemTables.getAf()+13
    IF EB.SystemTables.getRNew(A$)[I1,I2]#EB.SystemTables.getROld(A$)[I1,I2] THEN
        EB.SystemTables.setEtext('ST.RTN.DATE.CHANGED.L.NEXT.WKG.DAY')
        EB.ErrorProcessing.StoreEndError()
    END
RETURN

RETURN
*===============================================================================
CHECK.CHANGED.DATE:
    IF EB.SystemTables.getIdOld() EQ '' THEN
        RETURN
    END
    IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComBatchHoliday) THEN
        IF EB.SystemTables.getIdNew()[1,4]=EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComBatchHoliday) THEN ;* should always be this one after G14.00
            GOSUB LOCAL.HOLIDAY
        END
    END ELSE
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry) THEN   ;* this next bit just in case
            IF EB.SystemTables.getIdNew()[1,4]=EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry):"00" THEN
                GOSUB LOCAL.HOLIDAY
            END ELSE
                IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion) THEN
                    IF EB.SystemTables.getIdNew()[1,4]=EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion) THEN
                        GOSUB LOCAL.HOLIDAY
                    END
                END
            END
        END
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= CLEAR.MWD>
CLEAR.MWD:
*** <desc>On modifying a holiday respective mutual working day records should be deleted </desc>
    
    REC.ID = ''
    REC.ID = EB.SystemTables.getIdNew()
    
    SELECT.CMD = ''
    SELECT.CMD = 'SSELECT ':FN.MUTUAL.WORKING.DAY:' @ID LIKE ...':REC.ID:'...'  ;* select ids that is related to the amended holiday record
    
    KEY.LIST = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''

    EB.DataAccess.Readlist(SELECT.CMD, KEY.LIST, '', SELECTED, SYSTEM.RETURN.CODE)
    
    LIST.CNT = DCOUNT(KEY.LIST, @FM)
    FOR VAL = 1 TO LIST.CNT
        EB.DataAccess.FDelete(FN.MUTUAL.WORKING.DAY, KEY.LIST<VAL>) ;* delete all the selected ids
    NEXT VAL
    
RETURN
*** </region>
*=======================================================================================
* <new subroutines>
END
