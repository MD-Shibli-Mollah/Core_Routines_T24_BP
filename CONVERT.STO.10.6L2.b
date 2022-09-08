* @ValidationCode : MjoxMjIwODc0OTI6Y3AxMjUyOjE1NDA5NjgzMTkxMjg6dnZpZ25lc2g6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODA5LjIwMTgwODIxLTAyMjQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Oct 2018 12:15:19
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : vvignesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201809.20180821-0224
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-59</Rating>
    $PACKAGE AC.StandingOrders

    SUBROUTINE CONVERT.STO.10.6L2
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*************************************************************************
*
*
* 26/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
* 30/10/18 - Enhancement 2822520 / Task 2833705
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*************************************************************************
*
    YFILE = "F.STANDING.ORDER" ; YNEWFIELDNO = 14
    Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
*
    ADD.FIELD = ''
*
    ADD.FIELD<1,1> = 28       ;* POSITION TO ADD
    ADD.FIELD<2,1> = 6        ;* NUMBER OF FIELDS TO ADD
*
*
    GOSUB MODIFY.FILE
    IF TEXT = "NO" THEN
        RETURN      ;* BG_100013036 - S
    END   ;* BG_100013036 - E
*
    RETURN
*
*************************************************************************
*
MODIFY.FILE:
*
    CALL SF.CLEAR.STANDARD
    TEXT = "" ; YFILE.SAVE = YFILE ; YFILE.ADD = "" ; YLOOP = "Y"
    LOOP UNTIL YLOOP = "NO" OR TEXT = "NO" DO
        GOSUB MODIFY.FILE.START
        BEGIN CASE
            CASE YFILE.ADD = "" ; YFILE.ADD = "$NAU"
            CASE YFILE.ADD = "$NAU" ; YFILE.ADD = "$HIS"
            CASE YFILE.ADD = "$HIS" ; YLOOP = "NO"
        END CASE
    REPEAT
    RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
    YFILE = YFILE.SAVE:YFILE.ADD
    F.FILE = "" ; CALL OPF (YFILE:@FM:"NO.FATAL.ERROR", F.FILE)
    IF ETEXT THEN
        RETURN      ;* BG_100013036 - S
    END   ;* BG_100013036 - E
    CALL SF.CLEAR(1,5,"FILE RUNNING:  ":YFILE)
*
    SELECT F.FILE
    LOOP
        READNEXT YID ELSE
            YID = ""          ;* BG_100013036 - S
        END         ;* BG_100013036 - E
    UNTIL YID = "" DO
        *
        READ YREC FROM F.FILE, YID ELSE
            GOSUB FATAL.ERROR ;* BG_100013036 - S / E
        END
        PROCESS.FURTHER = 1   ;* BG_100013036 - S / E
        CALL SF.CLEAR(1,7,"RECORD RUNNING:  ":YID)
        IF YREC<AC.StandingOrders.StandingOrder.StoCoCode> = ID.COMPANY THEN
            TEXT = "CONVERSION ALREADY DONE"
            CALL OVE
            IF TEXT = "Y" THEN
                PROCESS.FURTHER = 0     ;* BG_100013036 - S / E
            END ELSE
                RETURN
            END
        END
        *
        *
        IF PROCESS.FURTHER THEN         ;* BG_100013036 - S
            GOSUB BUILD.YREC
        END         ;* BG_100013036 - E
        *

        *
    REPEAT
    RETURN
*
*************************************************************************
* BG_100013036 - S
*=========
BUILD.YREC:
*=========
    X = 0
    LOOP X +=1 UNTIL ADD.FIELD<1,X> = ''
        POS = ADD.FIELD<1,X>
        NOF = ADD.FIELD<2,X>
        FOR Y = 1 TO NOF
            YREC = INSERT(YREC,POS,0,0,"")
        NEXT Y
    REPEAT
    WRITE YREC TO F.FILE, YID
        RETURN          ;* BG_100013036 - E
*************************************************************************
        *
FATAL.ERROR:
        *
        CALL SF.CLEAR(8,22,"MISSING FILE=":YFILE:" ID=":YID)
        CALL PGM.BREAK
        *
*************************************************************************
    END
