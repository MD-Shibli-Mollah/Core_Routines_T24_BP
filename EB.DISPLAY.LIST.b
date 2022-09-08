* @ValidationCode : Mjo5MDIzOTI2MzA6Q3AxMjUyOjE1NDI3Nzk4NTY5Nzc6cmF2aW5hc2g6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 21 Nov 2018 11:27:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 7 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>556</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Display
SUBROUTINE EB.DISPLAY.LIST(DISPLAY.LIST,INPUT.PROMPT,CURRENT.PAGE,ALLOWED.INPUT,LINE.NUMBERING,VALID.RESPONSE,PROCESS.INVALID,FUNCTION.KEYS,RESPONSE)
*
******************************************************************************
* Modification History
*
* 24/10/18 - Enhancement 2822523 / Task 2826387
*          - Incorporation of EB_Display component
*
*------------------------------------------------------------------------------
* Routine to display the contents of the array DISPLAY.LIST on the screen
* allowing scrolling forward and backward with the function keys.
*
*
* DISPLAY.LIST      - Dynamic array containing the lines to be displayed
*                     held as fields.
*
* INPUT.PROMPT      - Single line of text containing the prompt to be
*                     displayed on line 23.
*
* CURRENT.PAGE      - The page of the list to begin display on. Each page
*                     holds 16 lines.
*
* ALLOWED.INPUT     - Dynamic array holding valid responses to the prompt
*                     Does not need to contain the function key responses
*                     When anything other than a function key is input it
*                     is checked with a locate on the fields of this
*                     array.
*
* LINE.NUMBERING    - Set TRUE to produce 3 digit numbering of lines.
*
* VALID.RESPONSE    - Returns TRUE to the calling routine if the response
*                     given was located in the ALLOWED.INPUT array.
*
* PROCESS.INVALID   - Determines the action taken on an invalid response
*                     If TRUE an invalid response message is shown and
*                     the user re-prompted.
*                     If FALSE the program sets VALID.RESPONSE to FALSE
*                     and returns to the calling routine.
*
* FUNCTION.KEYS    - Determines if EB.DISPLAY.LIST allows page scrolling
*                    with the normal EBS function keys. If false then
*                    function key strikes are returned in RESPONSE.
* RESPONSE          - The user input response.
*
************************************************************************
*
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_COLOURS
*
    EQUATE TRUE TO 1
    EQUATE FALSE TO 0
*
    SAVE.T.CONTROLWORD = T.CONTROLWORD           ; * save calling Program's control word
    IF FUNCTION.KEYS THEN
        T.CONTROLWORD = C.U : @FM : C.B : @FM : C.F : @FM : C.E : @FM : C.V
    END ELSE
        T.CONTROLWORD = ''
    END
*
************************************************************************
*
    NO.LINES = COUNT(DISPLAY.LIST,@FM) + (DISPLAY.LIST NE '')
    NO.PAGES = INT(NO.LINES/16) + 1
    IF NO.PAGES = INT(NO.LINES/16) THEN NO.PAGES -= 1
    GOSUB SCROLL.PAGE

    RETURN.CODE = FALSE
    LOOP
    UNTIL RETURN.CODE = TRUE DO
        EB.Display.Inp(INPUT.PROMPT,8,22,'70','A')
        RESPONSE = COMI
        BEGIN CASE
*
* F1 - Return
*
            CASE RESPONSE = T.CONTROLWORD<1>       ; *  F1
                RETURN.CODE = 1
*
* F2 - Last page if not on first
*
            CASE RESPONSE = T.CONTROLWORD<2>       ; * F2
                IF CURRENT.PAGE > 1 THEN
                    CURRENT.PAGE -= 1
                    GOSUB SCROLL.PAGE
                END ELSE
                    ERR.MSG = 'ALREADY ON FIRST PAGE'
                    E = ERR.MSG
                    CALL ERR
                END
*
* F3 - next page if not on last
*
            CASE RESPONSE = T.CONTROLWORD<3>       ; * F3
                IF CURRENT.PAGE < NO.PAGES THEN
                    CURRENT.PAGE += 1
                    GOSUB SCROLL.PAGE
                END ELSE
                    ERR.MSG = 'ALREADY ON LAST PAGE'
                    E = ERR.MSG
                    CALL ERR
                END
*
* Last page if not on last otherwise no action
*
            CASE RESPONSE = T.CONTROLWORD<4>       ; * F4
                IF CURRENT.PAGE < NO.PAGES THEN
                    CURRENT.PAGE = NO.PAGES
                    GOSUB SCROLL.PAGE
                END
*
* No action with F5
*
            CASE RESPONSE = T.CONTROLWORD<5>       ; * F5
                RETURN.CODE = TRUE
*
* May be an answer - check against allowed list of answers
*
            CASE OTHERWISE
                LOCATE RESPONSE IN ALLOWED.INPUT<1> SETTING POS ELSE POS = 0
                IF POS THEN
                    VALID.RESPONSE = TRUE
                    RETURN.CODE = TRUE
                END ELSE
                    IF PROCESS.INVALID THEN
                        E ='EB.RTN.INVALID.INP.1'
                        CALL ERR
                    END ELSE
                        VALID.RESPONSE = FALSE
                        RETURN.CODE = TRUE
                    END
                END

        END CASE

    REPEAT
*
    T.CONTROLWORD = SAVE.T.CONTROLWORD           ; * restore
*
RETURN                             ; * to calling Program
*
************************************************************************
*
SCROLL.PAGE:
*
* Routine to display contents of DISPLAY.LIST on screen
*
    FOR LINE = CURRENT.PAGE * 16 - 15 TO CURRENT.PAGE * 16
        SCREEN.LINE = LINE - (INT(LINE/16)*16) + 3
        IF LINE/16 = INT(LINE/16) THEN SCREEN.LINE = 19
        IF DISPLAY.LIST<LINE> THEN
            PRINT @(0,SCREEN.LINE):S.CLEAR.EOL:
            IF LINE.NUMBERING THEN
                PRINT @(3-LEN(LINE),SCREEN.LINE):LINE:'. ':DISPLAY.LIST<LINE>:S.CLEAR.EOL:
            END ELSE
                PRINT @(1,SCREEN.LINE):DISPLAY.LIST<LINE>:S.CLEAR.EOL:
            END
        END ELSE
            PRINT @(0,SCREEN.LINE):S.CLEAR.EOL:
        END
    NEXT LINE
    IF CURRENT.PAGE < NO.PAGES THEN PRINT @(63,21):'PAGE ':CURRENT.PAGE:' <<<':NO.PAGES:'>>>':S.CLEAR.EOL:
    ELSE PRINT @(63,21):'PAGE ':CURRENT.PAGE:S.CLEAR.EOL:
RETURN
END
