* @ValidationCode : Mjo1NDgzMTg4MjY6Q3AxMjUyOjE1NjMzNjYxODAzOTc6YnNhdXJhdmt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Jul 2019 17:53:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IN.IbanAPI

SUBROUTINE CONV.ALPHA.TO.NUMERIC(REARRANGED.IBAN , MOD.VALUE)
*-----------------------------------------------------------------------------
* Routine to convert the alphabets into numeric values as per the IBAN
* algorithm( A=10, B=11....) for the generation and validation of IBAN.
*
* Incoming:
* *********
* REARRANGED.IBAN : Append the first 4 characters to the end before
*                   passing to this routine.
*
* Outgoing
* ********
* CHECK.DIGIT     :  check digit value after modulo - 97.
*
***********************************************************************
* Modification:
***************
* 16/07/12 - Enahancement - 381897 / Task - 439575
*            New routine to convert the alphabets into numeric values
*            for IBAN.
*
***********************************************************************

    IBAN.BEFORE.MOD = ''
    IBAN.LENGTH = LEN(REARRANGED.IBAN)
    FOR CHAR.POS = 1 TO IBAN.LENGTH

        VALUE = REARRANGED.IBAN[CHAR.POS,1] ; * Take each value
        IF NOT(NUM(VALUE)) THEN      ; * Convert only for aplphabets
            VALUE = OCONV(VALUE,"MCU")   ; * Convert to UPPER CASE
            ASCII.VAL = SEQ(VALUE)   ; * Find ASCII
            VALUE = ASCII.VAL - 55   ; * Get IBAN algorithm value
        END

        IBAN.BEFORE.MOD :=  VALUE    ; * Append the array for applying MOD
    NEXT CHAR.POS

    MOD.VALUE =  MOD(IBAN.BEFORE.MOD, 97) ; * Do modulo - 97
*-----------------------------------------------------------------------------

END
