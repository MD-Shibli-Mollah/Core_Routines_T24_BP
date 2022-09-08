* @ValidationCode : MjoxNzExNDI3MDkwOkNwMTI1MjoxNTQwODA3MDIxMzc4OnJhdmluYXNoOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMTMtMDI0ODotMTotMQ==
* @ValidationInfo : Timestamp         : 29 Oct 2018 15:27:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181013-0248
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>461</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Reports
SUBROUTINE CONVERT.ENQUIRY.14.2
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
    $INSERT I_COMMON
    $INSERT I_F.PGM.FILE
    $INSERT I_F.USER
    $INSERT I_DAS.ENQUIRY     ;* EN_10003192 S/E
*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
********************************************************************
* 23/08/02 - GLOBUS_EN_10001028
*          Conversion Of all Error Messages to Error Codes
*
* 21/02/07 - EN_10003192
*            DAS Implementation
*
* 29/10/18 - Enhancement 2822523 / Task 2832287
*          - Incorporation of EB_Reports component
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

    CALL OPF('F.ENQUIRY',F.ENQUIRY)
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
        GOSUB REMOVE.PERCENT.ENQUIRIES
        SUMMARY.REPORT<-1> = DELETED:" Deleted"
        GOSUB PRINT.SUMMARY
        TEXT = 'CONVERSION COMPLETE'
        CALL REM
    END   ;* OK to run Conversion.

RETURN          ;* Exit Program.
*
*************************************************************************
*
REMOVE.PERCENT.ENQUIRIES:
*
* Remove % enquiries with no inputter field - ie created automatically
*
    PERC = "'%'..." ;* LIKE "'%'..."
    DQ = '"'
    PERC = DQ:PERC:DQ
    THE.LIST= dasEnquiry$ID1  ;*EN_10003192 S
    THE.ARGS=PERC
    TABLE.SUFFIX=""
    CALL DAS("ENQUIRY",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST        ;*EN_10003192 E
    DELETED = 0
*
    LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
        READ R.ENQUIRY FROM F.ENQUIRY, ID THEN
            TITLE = R.ENQUIRY<EB.Reports.Enquiry.EnqHeader,1,1>["-",2,1]
*GB9601107*            IF TITLE[" ",2,1] = "DEFAULT" AND R.ENQUIRY<43> LE 1 THEN  ; * Auto built  43=CURR,NO
            IF TITLE[" ",2,1] = "DEFAULT" THEN
                DELETE.RECORD = 0
                IF R.SPF.SYSTEM<30> < 'G5.0.00' THEN
                    IF R.ENQUIRY<43> LT 1 THEN DELETE.RECORD = 1
                END ELSE
                    IF R.ENQUIRY<43> LE 1 THEN DELETE.RECORD = 1
                END
*
                IF DELETE.RECORD THEN
                    DELETE F.ENQUIRY, ID          ;* Zap it
                    DELETED +=1
                    CALL DISPLAY.MESSAGE(DELETED:" Deleted",3)
                END
            END
        END
    REPEAT
*
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
    ETEXT ="EB.RTN.WHY.PROGRAM.ABORTED.22"        ;* Used to update F.CONVERSION.PGMS
    CALL PGM.BREAK
*
*************************************************************************
END
