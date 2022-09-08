* @ValidationCode : MjoxODM5NDUyODUzOkNwMTI1MjoxNTQyOTc3MzIxMzA5OnBtYWhhOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 23 Nov 2018 18:18:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.API
SUBROUTINE CONVERT.ASCII.EBCDIC

    $INSERT I_COMMON

*
* Determine if we are running in ASCII or EBCDIC and populate the
* tables accordingly. CHARX() function is used in place of the CHAR, hence
* C$SEQX<65> will always be "A".
* in ASCII order hence SEQX(65) will always give you "A".
*
****************************************************************************
*
* CHANGE CONTROL
* --------------
*
* 19/04/00 - GB0001083
*            Initialise array C$CHARX to nulls
*
* 10/05/00 - GB0001209
*           Redo the changes done in GB0001083, as the changes was lost before releasing
*
* 18/12/2002 - GLOBUS_EN_10001548
*              Do nothing if running in UTF8
*
* 20/11/18 - Enhancement 2822523 / Task 2843458
*            Incorporation of EB_API component
****************************************************************************
*
    IF NOT(RUNNING.IN.UTF8) THEN

        MAT C$CHARX = ""                ; * GB0001083 & GB0001209
        IF SEQ("A") = 193 THEN          ; * I'm on an IBM
            USING.EBCDIC = 1             ; * Common variable
        END ELSE
            USING.EBCDIC = 0
        END

        C$SEQX = SPACES(255)            ; * In preparation for ascii table

        BEGIN CASE
            CASE USING.EBCDIC
                EBCDIC.TABLE = ""         ; * Hold list of EBCDIC characters
                FOR IDX = 1 TO 255
                    EBCDIC.TABLE := CHAR(IDX)
                NEXT IDX
                ASCII.TABLE = ASCII(EBCDIC.TABLE)   ; * Now make it the ascii equivalents
                FOR IDX = 1 TO 255
                    AVALUE = SEQ(ASCII.TABLE[IDX,1])           ; * Ascii equivalent number ie position 193 will give you an seq of 65
                    C$CHARX(AVALUE) = CHAR(IDX)      ; * Put EBCDIC chars in their ascii position
                    C$SEQX[AVALUE,1] = CHAR(IDX)     ; * And build up table for SEQX to index in
                NEXT IDX
            CASE 1
                FOR IDX = 1 TO 255
                    C$CHARX(IDX) = CHAR(IDX)         ; * Put ascii character
                    C$SEQX[IDX,1] = CHAR(IDX)        ; * And build up table for SEQX to index in
                NEXT IDX
        END CASE
    END


RETURN
END
