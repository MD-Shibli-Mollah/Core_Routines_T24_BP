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

* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>498</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CONV.ENQUIRY.11.2.1
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ENQUIRY
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_DAS.COMMON      ;*EN_10003192 S
    $INSERT I_DAS.ENQUIRY     ;*EN_10003192 E

    EQU BELL TO CHARX(7)

*************************************************************************
* MODIFICATIONS:
* 14/03/07 - EN_10003192
*            DAS Implementation
*************************************************************************
* PROGRAM MAINLINE *
* ~~~~~~~~~~~~~~~~ *

    APPLIC.NAME = 'F.ENQUIRY'

    ADD.FIELD = ''
    ADD.FIELD.POS = 29
    ADD.FIELD.TOT= 5          ;*2
    OLD.FIELD.TOT = 37        ;*37
    CO.CODE.POS = 39
    INPUTTER.POS = 36
    SUFFIXES = '':VM:'$NAU'
    LINE.NO = 8     ;* SCREEN LINE TO START DISPLAY

    FOR LP1 = 1 TO 2
        FILE.SUFFIX = SUFFIXES<1,LP1>
        GOSUB MODIFY.FILE
        RELEASE
        LINE.NO += 3
    NEXT LP1

    RETURN          ;* FROM CONVERT.ENQUIRY.11.2.1

*************************************************************************

MODIFY.FILE:
*~~~~~~~~~~~

    TEXT = ''
    UPDTOT = 0

    FILE.NAME = APPLIC.NAME:FILE.SUFFIX
    F.FILE = ''
    CALL OPF (FILE.NAME:FM:'NO.FATAL.ERROR', F.FILE)

    IF ETEXT THEN
        CALL SF.CLEAR(8,22,"MISSING FILE=":FILE.NAME:" ID=":V$KEY)
        CALL PGM.BREAK
    END
    CALL SF.CLEAR(1,LINE.NO,"FILE RUNNING:  ":FILE.NAME)

    CLEARSELECT

    THE.LIST = dasAllIds      ;*EN_10003192 S
    THE.ARGS = ""
    TABLE.SUFFIX = FILE.SUFFIX
    CALL DAS("ENQUIRY",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST

    FILE.ERROR = 0  ;* FLAG FOR ALREADY CONVERTED
    LOOP
        REMOVE V$KEY FROM ID.LIST SETTING POS     ;*EN_10003192 E
    WHILE V$KEY:POS
        LOOP
            LOKMSG = ''
            READU FILE.REC FROM F.FILE, V$KEY LOCKED
                LOKMSG = '"':V$KEY:'" in ':FILE.NAME:' is locked'
            END ELSE
                FILE.REC = ''
            END
        WHILE LOKMSG NE '' DO
            CRT @(1,23):BELL:LOKMSG:
            SLEEP 2
            CRT @(1,23):S.CLEAR.EOL:
        REPEAT

        CALL SF.CLEAR(1,LINE.NO+1,'RECORD RUNNING:  ':V$KEY)
        FIELD.TOT = DCOUNT(FILE.REC,@FM)

        IF FILE.REC EQ '' THEN
            RELEASE F.FILE,V$KEY
        END ELSE
*
            IF NOT(FILE.REC<CO.CODE.POS> MATCHES "2A7N") AND FIELD.TOT < 42 THEN
                IF NOT(FILE.REC<INPUTTER.POS> MATCHES "1N0N'_'0X") THEN         ;* No inputter
*
                    IF NOT(FILE.REC<INPUTTER.POS> = '' AND V$KEY[1,1] = "%") THEN         ;* Don;t bother with AutO
                        FOR LP2 = 1 TO ADD.FIELD.TOT
                            INS '' BEFORE FILE.REC<ADD.FIELD.POS>
                        NEXT LP2
                    END ELSE
                        RELEASE F.FILE,V$KEY
                    END
*
                END ELSE
                    RELEASE F.FILE,V$KEY
                END
*
            END ELSE
                IF NOT(FILE.ERROR) THEN ;* NO ERRORS PREVIOUSLY
                    TEXT = ' "':V$KEY:'" ALREADY CONVERTED. CONTINUE THIS FILE? (Y/N) : '
                    CALL OVE
                    IF TEXT NE 'Y' THEN
                        RELEASE F.FILE,V$KEY
                        CLEARSELECT
                        RETURN          ;* FROM MODIFY.FILE
                    END
                    FILE.ERROR = 1
                END
            END
            WRITEU FILE.REC TO F.FILE, V$KEY
            RELEASE F.FILE,V$KEY
            UPDTOT += 1
        END
    REPEAT
    CALL SF.CLEAR(1,LINE.NO+1,'RECORDS UPDATED:  ':UPDTOT)

    RETURN          ;* FROM MODIFY.FILE

END
