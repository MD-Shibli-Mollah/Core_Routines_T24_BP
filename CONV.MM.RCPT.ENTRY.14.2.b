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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-166</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MM.PaymentAndReceipt
    SUBROUTINE CONV.MM.RCPT.ENTRY.14.2
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*************************************************************************
*
* MODIFICATIONS
*
*------------------------------------------------------------------------
*
* 22/09/08 - BG_100020073
*            Rating Reduction for MM routines
*
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.PGM.FILE
    $INSERT I_F.USER
*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
*************************************************************************
INITIALISE:
*
    EQU TRUE TO 1, FALSE TO ''
    CLS = ''        ;* Clear Screen
    FOR X = 4 TO 16
        CLS := @(0,X):@(-4)
    NEXT X
    CLS := @(0,4)
    YFILE = "F.MM.RECEIPT.ENTRY"        ;* File to be converted
    COMPANY.CODE.POS = 32     ;* Position of new XX.CO.CODE in the file
    F.PGM.FILE = ''
    CALL OPF('F.PGM.FILE',F.PGM.FILE)

    READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
        ID = APPLICATION
        YFILE = 'F.PGM.FILE'
        GOSUB FATAL.ERROR
    END
    DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

    ID = FIELD(YFILE,'.',2,99)
    READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
        YFILE = 'F.FILE.CONTROL'
        GOSUB FATAL.ERROR
    END
    MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)
*
** If any fields are to be removed from the file add these here
** If several sets of fields are to be removed these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be deleted starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
    CANCEL.FIELD = ""
**      CANCEL.FIELD<1,1> = ""            ;* Position to cancel from.
**      CANCEL.FIELD<2,1> = ""            ;* Number of fields to cancel.
*
** Add the position where new fields start, plus the number of fields
** required.
** If several sets of fields are to be added these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be added starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
    ADD.FIELD = ''
    ADD.FIELD<1,1> = 17       ;* Position to add from. (New field number)
    ADD.FIELD<2,1> = 6        ;* Number of fields to add.
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
        SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()      ;* Summary of files & number of records converted.
        GOSUB CHECK.COMPANY.FOR.FILENAME
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
    END   ;* OK to run Conversion.

    RETURN          ;* Exit Program.
*
**************************
CHECK.COMPANY.FOR.FILENAME:
**************************
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
                GOSUB MODIFY.FILE
            END
        REPEAT
    END ELSE        ;* Internal File.
        FILE.NAME=YFILE ; GOSUB MODIFY.FILE
    END

    RETURN
*************************************************************************
*
MODIFY.FILE:
*
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

    RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
    CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
    V$COUNT = 0     ;* Initialise.
    SELECT F.FILE
    END.OF.FILE = FALSE
    ABORT.FLAG = FALSE
    LOOP
        IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE
                END.OF.FILE = TRUE
            END
        END
    UNTIL END.OF.FILE
*
        READ YREC FROM F.FILE, YID ELSE
            GOSUB FATAL.ERROR
        END
        CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
        GOSUB PROCESS.CONVERSION
*
    REPEAT
    SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
    RETURN
*
*********************
PROCESS.CONVERSION:
*********************
    IF YREC<COMPANY.CODE.POS> MATCHES "2A7N" THEN
        TEXT = "CONVERSION ALREADY DONE... ABORT ?"
        CALL OVE
        IF TEXT EQ "Y" THEN
            END.OF.FILE = TRUE
            ABORT.FLAG = TRUE
        END
    END ELSE
        V$COUNT += 1          ;* Count sucessful conversions.
*
** Delete the fields specified here
*
        GOSUB DELETE.FIELDS
*
** Add the fields specified here
*
        GOSUB ADD.FIELDS
*
        YREC<17> = YREC<1>
*
        WRITE YREC TO F.FILE, YID
*
    END   ;* Valid Record.


    RETURN
*****************
DELETE.FIELDS:
*****************
    X = 0
    LOOP X += 1 UNTIL CANCEL.FIELD<1,X> = ""
        POS = CANCEL.FIELD<1,X>
        NOF = CANCEL.FIELD<2,X>
        FOR Y = 1 TO NOF
            DEL YREC<POS>
        NEXT Y
    REPEAT

    RETURN

***************
ADD.FIELDS:
***************
    X = 0
    LOOP X += 1 UNTIL ADD.FIELD<1,X> = ''
        POS = ADD.FIELD<1,X>
        NOF = ADD.FIELD<2,X>
        FOR Y = 1 TO NOF
            INS "" BEFORE YREC<POS>
        NEXT Y
    REPEAT

    RETURN
*************************************************************************
*
PRINT.SUMMARY:
    LINE.NO = 0
    PRINT CLS:      ;* Clear Screen
    LOOP
        REMOVE LINE FROM SUMMARY.REPORT SETTING MORE
        PRINT LINE
        LINE.NO += 1
        IF NOT(MOD(LINE.NO,16)) THEN    ;* One Screen EQ 16 lines.
            TEXT = 'CONTINUE'
            CALL OVE
            IF TEXT NE 'Y' THEN
                MORE = FALSE
            END ELSE
                PRINT CLS:    ;* Clear Screen
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
