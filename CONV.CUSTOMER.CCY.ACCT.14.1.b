* @ValidationCode : MjoxMjU1NTE0NTc6Q3AxMjUyOjE1OTk2NDc1NzU2NjM6c2Fpa3VtYXIubWFra2VuYToyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwNC4wOjE1NToyNw==
* @ValidationInfo : Timestamp         : 09 Sep 2020 16:02:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/155 (17.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>440</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.Config
SUBROUTINE CONV.CUSTOMER.CCY.ACCT.14.1
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
* ----------------------------------------------------------------------------
*   Modification History
*
* 26/04/17 - Enhancement 1765879 / Task 2101165
*            Routine is not processed if AC product is not installed in the current company
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.PGM.FILE
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT
    $USING EB.API
*
*************************************************************************
INITIALISE:
*

    acInstalled = ''
    EB.API.ProductIsInCompany('AC', acInstalled)

    IF NOT(acInstalled) THEN
        RETURN
    END

    EQU TRUE TO 1, FALSE TO ''
    CLS = ''                           ; * Clear Screen
    FOR X = 4 TO 16
        CLS := @(0,X):@(-4)
    NEXT X
    CLS := @(0,4)
    YFILE = "F.CUSTOMER.CCY.ACCT"      ; * File to be converted
    COMPANY.CODE.POS = ""              ; * Position of new XX.CO.CODE in the file
    F.PGM.FILE = ''
    CALL OPF('F.PGM.FILE',F.PGM.FILE)

    READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
        ID = APPLICATION
        YFILE = 'F.PGM.FILE'
        GOTO FATAL.ERROR
    END
    DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

    ID = FIELD(YFILE,'.',2,99)
    READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
        YFILE = 'F.FILE.CONTROL'
        GOTO FATAL.ERROR
    END
    MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)
    YACC.CAT = 3000
*
*************************************************************************
*
** Take description of what the program will do from the PGM.FILE file
** and give the user the opportunity to quit.
*
    PRINT @(5,4):"Reason:"
    LOOP
        REMOVE LINE FROM DESCRIPTION SETTING MORE
        PRINT SPACE(5):LINE
    WHILE MORE
    REPEAT
    PRINT
    TEXT = "DO YOU WANT TO RUN THIS CONVERSION"
    CALL OVE
    IF TEXT EQ "Y" THEN
        SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()      ; * Summary of files & number of records converted.
        IF MULTI.COMPANY.FILE THEN
            SEL.CMD = 'SSELECT F.COMPANY'
            COM.LIST = ''
            YSEL = 0
            CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
            LOOP
                REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
            WHILE K.COMPANY:END.OF.COMPANIES
                READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
                    FILE.NAME = 'F':MNEMONIC:'.':FIELD(YFILE,'.',2,99)
                    YACC.FILE.NAME = 'F':MNEMONIC:'.ACCOUNT'
                    GOSUB MODIFY.FILE
                END
            REPEAT
        END ELSE                        ; * Internal File.
            YACC.FILE.NAME = 'F.ACCOUNT'
            FILE.NAME=YFILE ; GOSUB MODIFY.FILE
        END
*
        IF NOT(ABORT.FLAG) THEN
* This subroutine will maintain the correct field numbers in any
* ENQUIRYs, REPGENs, STATIC.TEXT, and VERSIONs
*            CALL MODIFY.DATA(YFILE,ADD.FIELD,CANCEL.FIELD,SUMMARY.REPORT)
        END
*
        GOSUB PRINT.SUMMARY
        PRINT
        TEXT = 'CONVERSION COMPLETE'
        CALL REM
    END                                ; * OK to run Conversion.

RETURN                             ; * Exit Program.
*
*************************************************************************
*
MODIFY.FILE:
*
    YACC.FILE = YACC.FILE.NAME
    OPEN '',YACC.FILE TO YACC.F.FILE THEN
        CALL SF.CLEAR.STANDARD
        TEXT = ""
        FOR FILE.TYPE = 1 TO 3
            BEGIN CASE
                CASE FILE.TYPE EQ 1
                    SUFFIX = ""
                CASE FILE.TYPE EQ 2
                    SUFFIX = "$NAU"
                CASE FILE.TYPE EQ 3
                    SUFFIX = "$HIS"
            END CASE
            YFILE = FILE.NAME:SUFFIX
            F.FILE = ""
            OPEN '',YFILE TO F.FILE THEN
                GOSUB MODIFY.FILE.START
            END
        NEXT FILE.TYPE
        YFILE = FIELD(YFILE,'$',1)
    END

RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
    CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
    V$COUNT = 0                        ; * Initialise.
    SELECT F.FILE
    END.OF.FILE = FALSE
    ABORT.FLAG = FALSE
    YREC.NEW = ''
    LOOP
        IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE END.OF.FILE = TRUE
        END
    UNTIL END.OF.FILE
*
        READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
        CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
        V$COUNT += 1                    ; * Count sucessful conversions.
*
** Delete the fields specified here
*
        X = 0
        Y = 0
        LOOP X += 1 UNTIL YREC<X> = ""
            YACC.KEY = YREC<X>
            READ YACC.REC FROM YACC.F.FILE,YACC.KEY ELSE
                YACC.REC<AC.CATEGORY> = 9999
            END
            IF YACC.REC<AC.CATEGORY> LT YACC.CAT THEN
                Y += 1
                YREC.NEW<Y> = YREC<X>
            END
        REPEAT
        YREC = YREC.NEW
*
        IF YREC THEN
            WRITE YREC TO F.FILE, YID
        END ELSE
            DELETE F.FILE,YID
        END
        YREC.NEW = ''
*
    REPEAT
    SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
RETURN
*
*************************************************************************
*
PRINT.SUMMARY:
    LINE.NO = 0
    PRINT CLS:                         ; * Clear Screen
    LOOP
        REMOVE LINE FROM SUMMARY.REPORT SETTING MORE
        PRINT LINE
        LINE.NO += 1
        IF NOT(MOD(LINE.NO,16)) THEN    ; * One Screen EQ 16 lines.
            TEXT = 'CONTINUE'
            CALL OVE
            IF TEXT NE 'Y' THEN
                MORE = FALSE
            END ELSE
                PRINT CLS:                ; * Clear Screen
            END
        END
    WHILE MORE
    REPEAT

    R.PGM.FILE<EB.PGM.DESCRIPTION,-1> = TRIM(LOWER(SUMMARY.REPORT))
    WRITE R.PGM.FILE TO F.PGM.FILE,APPLICATION

RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
    CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
    CALL PGM.BREAK
*
*************************************************************************
END
