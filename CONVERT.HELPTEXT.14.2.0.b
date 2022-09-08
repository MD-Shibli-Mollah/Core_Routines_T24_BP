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

* Version 6 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>452</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
    SUBROUTINE CONVERT.HELPTEXT.14.2.0
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.PGM.FILE
    $INSERT I_F.USER
    $INSERT I_DAS.COMMON      ;*EN_10003192 S
    $INSERT I_DAS.NEW.HELPTEXT.FILE     ;*EN_10003192 E

*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
*********************************************************************
* 23/08/02 - GLOBUS_EN_10001028
*          Conversion Of all Error Messages to Error Codes
*
* 21/02/07 - EN_10003192
*            DAS Implementation
*************************************************************************
INITIALISE:
*
    EQU TRUE TO 1, FALSE TO ''
    TEXT = ''
    ETEXT = ''
    CLS = ''        ;* Clear Screen
    FOR X = 4 TO 16
        CLS := @(0,X):@(-4)
    NEXT X
    CLS := @(0,4)
*      YFILE = "F.CONV.FILE"             ;* File to be converted
    COMPANY.CODE.POS = ""     ;* Position of new XX.CO.CODE in the file
    F.PGM.FILE = ''
    CALL OPF('F.PGM.FILE',F.PGM.FILE)

    READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
        ID = APPLICATION
        YFILE = 'F.PGM.FILE'
        GOTO FATAL.ERROR
    END
    DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

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
        GOSUB CONVERT.HELPTEXT          ;* Perform conversion
        SUMMARY.REPORT<-1> = "Completed ":TIMEDATE()
        GOSUB PRINT.SUMMARY
        PRINT
        TEXT = 'CONVERSION COMPLETE'
        CALL REM
    END   ;* OK to run Conversion.

    RETURN          ;* Exit Program.
*
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
*========================================================================
CONVERT.HELPTEXT:
* Copy all helptext records from the 'new' file.
*
    OPEN "VOC" TO F.VOC ELSE
        ETEXT ="EB.RTN.UNABLE.OPEN.VOC"
        GOTO FATAL.ERROR
    END
*
    R.VOC = "Q"
    R.VOC<2> = "TEMP.RELEASE"
    R.VOC<3> = "F.HELPTEXT"
    WRITE R.VOC TO F.VOC, "NEW.HELPTEXT.FILE"
*
    R.VOC = "Q"
    R.VOC<2> = "TEMP.RELEASE"
    R.VOC<3> = "F.HELPTEXT.TITLE"
    WRITE R.VOC TO F.VOC, "NEW.HELPTEXT.TITLE.FILE"
*
    CALL OPF("F.HELPTEXT",F.HELPTEXT)
    CALL OPF("F.HELPTEXT.TITLE",F.HELPTEXT.TITLE)
*
    OPEN "NEW.HELPTEXT.FILE" TO F.NEW.HELPTEXT ELSE
        ETEXT ="EB.RTN.UNABLE.OPEN.F.HELPTEXT.TEMP.RELEASE"
        GOTO FATAL.ERROR
    END
*
    OPEN "NEW.HELPTEXT.TITLE.FILE" TO F.NEW.HELPTEXT.TITLE.FILE ELSE
        ETEXT ="EB.RTN.UNABLE.OPEN.F.HELPTEXT.TITLE.TEMP.RELEASE"
        GOTO FATAL.ERROR
    END
*
    THE.LIST = dasAllIds      ;*EN_10003192 S
    THE.ARGS = ""
    TABLE.SUFFIX = ""
    CALL DAS("NEW.HELPTEXT.FILE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
    TOTAL.SELECTED = DCOUNT(ID.LIST,FM) ;*EN_10003192 E
*
    CNT = 0
    LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
        CNT+=1
        MSG = "Processed ":CNT:" of ":TOTAL.SELECTED
        CALL DISPLAY.MESSAGE(MSG,3)     ;* On action line
        READ R.HELPTEXT FROM F.HELPTEXT,ID ELSE   ;* Not already present
            READ R.NEW.HELPTEXT FROM F.NEW.HELPTEXT, ID THEN
                WRITE R.NEW.HELPTEXT TO F.HELPTEXT, ID
                READ R.NEW.HELPTEXT.TITLE FROM F.NEW.HELPTEXT.TITLE.FILE, ID THEN
                    WRITE R.NEW.HELPTEXT.TITLE TO F.HELPTEXT.TITLE, ID
                END
            END
        END
    REPEAT
*
    CALL BUILD.HELP.INDEX
*
    RETURN
*
*=============================================================================
FATAL.ERROR:
*
    TEXT = ETEXT
    CALL REM
    GOTO PROGRAM.ABORT
*
*==================================================================================
PROGRAM.ABORT:
    RETURN TO PROGRAM.ABORT

*==================================================================================
END
