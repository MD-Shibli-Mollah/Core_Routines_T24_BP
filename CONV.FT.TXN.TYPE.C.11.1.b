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
* <Rating>163</Rating>
*-----------------------------------------------------------------------------
* Version 5 02/06/00  GLOBUS Release No. 200508 30/06/05
*
* Modifications -
* -------------
* 28/03/00 - GB0000612
*            FILE.REC is a DYNAMIC array , it is changed to DYNAMIC array
*            where ever it is used as dimensioned array.
    $PACKAGE FT.Config
    SUBROUTINE CONV.FT.TXN.TYPE.C.11.1
*
* 20/07/93 - GB9301210
*            SUFFIXES incorrectly defined.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES

    EQU BELL TO CHARX(7)

*************************************************************************
* PROGRAM MAINLINE *
* ~~~~~~~~~~~~~~~~ *

    APPLIC.NAME = 'F.FT.TXN.TYPE.CONDITION'

    ADD.FIELD.POS = 17
    SUFFIXES = " $NAU $HIS"
    CONVERT " " TO @VM IN SUFFIXES
    LINE.NO = 8     ;* SCREEN LINE TO START DISPLAY

    FOR LP1 = 1 TO 3
        FILE.SUFFIX = SUFFIXES<1,LP1>
        GOSUB MODIFY.FILE
        RELEASE
        LINE.NO += 3
    NEXT LP1

    RETURN          ;* FROM CONVERT.FT.TXN.TYPE.CONDITION.11.1

*************************************************************************

MODIFY.FILE:
*~~~~~~~~~~~

    TEXT = ''
    UPDTOT = 0

    FILE.NAME = APPLIC.NAME:FILE.SUFFIX
    F.FILE = ''
    CALL OPF (FILE.NAME:FM:'NO.FATAL.ERROR', F.FILE)
    IF ETEXT THEN RETURN
    CALL SF.CLEAR(1,LINE.NO,"FILE RUNNING:  ":FILE.NAME)

    CLEARSELECT
    SELECT F.FILE
    LOOP WHILE READNEXT V$KEY DO

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

        IF FILE.REC EQ '' THEN
            RELEASE F.FILE,V$KEY
        END ELSE
            IF FILE.REC<26> MATCHES '2A7N' THEN   ;*GB0000612
                TEXT = "PROCESS ALREADY RUN"
                CALL REM
                RETURN
            END ELSE
                IF FILE.SUFFIX = "$HIS" THEN
                    INS.FLDS = "_":FM:"_":FM:"_":FM:"_":FM
                END ELSE
                    INS.FLDS = "Y":FM:"Y":FM:FM
                END
                INS INS.FLDS BEFORE FILE.REC<ADD.FIELD.POS>
                WRITE FILE.REC TO F.FILE, V$KEY
                UPDTOT += 1
            END
        END
    REPEAT
    CALL SF.CLEAR(1,LINE.NO+1,'RECORDS UPDATED:  ':UPDTOT)

    RETURN          ;* FROM MODIFY.FILE

END
