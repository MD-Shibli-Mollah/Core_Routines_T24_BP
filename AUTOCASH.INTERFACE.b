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

* Version 6 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>421</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.Foundation
    SUBROUTINE AUTOCASH.INTERFACE (TELLER.ID, OPERATION, AMOUNT, DENOMINATIONS)
*
*-----------------------------------------------------------------------
*
* Subroutine to send & receive messages to an autocash dispenser.
* Currently the interface is hardcoded to support a Nixdorf AKT machine
* only.
*
* TELLER.ID         - Used as a unique reference to the actual AKT
* OPERATION         - OPEN, CLOSE, WITHDRAW
* AMOUNT            - Amount of withdrawal - not formatted
* DENOMINATIONS     - Individual denomination units required
*
* ETEXT             - Error message returned - if any
*
* The operations which are currently supported are:
*
* OPEN              - Allow money to be withdrawn
* CLOSE             - Prevent money being withdrawn
* WITHDRAW          - Withdraw money
* UNLOCK            - Unlock cassettes on deposit (till transfer)
* PAID.OUT          - Return the amount paid out by a teller
*
*-----------------------------------------------------------------------
*
* 21/06/91 - GB9100207
*            Convert messages to EBCDIC.
*
* 18/12/91 - HY9100502
*            Change send command to globakt -i xxx -o xxx
*
* 21/09/02 - EN_10001184
*            Conversion of error messages to error codes.
*-----------------------------------------------------------------------

    $USING EB.Display
    $USING TT.Contract
    $USING EB.Desktop
    $USING EB.SystemTables

*
*-----------------------------------------------------------------------
*
    GOSUB INITIALISATION
    GOSUB PREPARE.MESSAGE
    GOSUB SEND.MESSAGE
    GOSUB CHECK.RESPONSE
*
    GOTO PROGRAM.END
*
*
*-----------------------------------------------------------------------
*
INITIALISATION:
*
* Initialise ETEXT
*
    DEFFUN CHARX()
    EB.SystemTables.setEtext("")
*
* Set up AKT instruction codes.
*
    AKT.FILL = CHARX(0)                ; * Filler byte '00
    AKT.MESSAGE.LENGTH = 164           ; * Standard message length
    AKT.OPEN = CHARX(32)               ; * Open instruction '20
    AKT.CLOSE = CHARX(248)             ; * Close instruction 'F8
    AKT.UNLOCK = CHARX(195)            ; * Unlock instruction 'C3
    AKT.PAID.OUT = CHARX(246)          ; * Paid out instruction 'F6
    AKT.WITHDRAW.DEFAULT = CHARX(244)  ; * Withdraw default denoms 'F4
    AKT.WITHDRAW.SPECIFIC = CHARX(245)           ; * Withdraw specific denoms 'F5
    AKT.PROCESS.FLAG = CHARX(240)
    AKT.ERROR.FLAG = CHARX(240)
*
* Initialise variables & files used in communication
*
*
    AKT.MESSAGE = STR(AKT.FILL,AKT.MESSAGE.LENGTH)         ; * Blank message
    AKT.SEND.ID = "AKT": TELLER.ID: "S"          ; * "file" to send AKT0001S
    AKT.DIRECTORY = "&UFD&"            ; * Where messages will be returned
    AKT.RESPONSE.ID = "AKT":TELLER.ID  ; * 'file' in &UFD&
    AKT.SEND.COMMAND = 'sh -c "globakt -i ':AKT.SEND.ID: ' -o ':AKT.RESPONSE.ID: '"'
    SQ = "'"                           ; * Single quote to surround message
    AKT.WAITING = "AWAITING RESPONSE FROM AKT"   ; * Please be patient
    EB.Display.Txt(AKT.WAITING)              ; * Foreign perhaps
*
    OPEN '',AKT.DIRECTORY TO F.UFD ELSE
        EB.SystemTables.setEtext("TT.RTN.AKT.FATAL.ERROR.UNABLE.OPEN.&UFD&")
        GOTO PROGRAM.ABORT
    END
*
* Check that the 'reponse' record is NOT present. Remove it if
* necessary - it may have been left there after an error.
*
    READ R.RESPONSE FROM F.UFD, AKT.RESPONSE.ID THEN
        DELETE F.UFD, AKT.RESPONSE.ID   ; * Shouldn't be here
            R.RESPONSE = ""
        END
        *
        * Determine the language of the AKT
        *
        AKT.LANGUAGE = CHARX(242)          ; * Default language = German
        *
        BEGIN CASE
            CASE EB.SystemTables.getLngg() = 2                   ; * French
                AKT.LANGUAGE = CHARX(241)
            CASE EB.SystemTables.getLngg() = 4                   ; * Italian
                AKT.LANGUAGE = CHARX(240)
        END CASE
        *
        * Modify amount passed to the lowest denomination that the akt can
        * dispense and convert to cents (thats the way the akt wants it).
        *
        AKT.LOWEST.DENOMINATION = 10       ; * Lowest value that can be dispensed
        AKT.AMOUNT.FACTOR = 100            ; * Amounts expressed as cents
        *
        IF AMOUNT THEN                     ; * Any cash to be withdrawn
            AMOUNT = INT(AMOUNT/AKT.LOWEST.DENOMINATION)*AKT.LOWEST.DENOMINATION    ; * Rounded down
        END
        *
        *
        * Extract units passed, format them and place in a string ready for the
        * message. Ie 5 hundreds 2 twenties & 1 ten would end up as :
        * AKT.UNITS = 000000005000002001 (3 digits per denomination value)
        *
        DENOM.VALUES = "500.000 1000.000 100.000 50.000 20.000 10.000"   ; * Denominations held by AKT
        CONVERT " " TO @FM IN DENOM.VALUES           ; * Turn into a dynamic array
        AKT.UNITS = STR("0",18)            ; * Units to be sent to AKT- Default
        *
        IF SUM(DENOMINATIONS<2>) THEN      ; * Denoms specified
            AMOUNT = 0                      ; * Recalculate based on denoms
        END
        *
        I = 0
        LOOP I+=1 ; VALUE = DENOMINATIONS<1,I> UNTIL VALUE = ""          ; * For each value sent
            LOCATE VALUE IN DENOM.VALUES<1> SETTING POS THEN    ; * Determine position
            POS = (POS*3)-2              ; * Position of value in output string
            AKT.UNITS[POS,3] = FMT(DENOMINATIONS<2,I>,'3"0"R')         ; * Pop it in
            AMOUNT += VALUE* DENOMINATIONS<2,I>
        END
    REPEAT
*
* If trying to withdraw money but the amount is 0 (after rounding down
* to the lowest denomination supported by the autocash device) then
* abort the process but do NOT report an error).
*
    IF OPERATION = "WITHDRAW" AND NOT(AMOUNT) THEN
        EB.SystemTables.setEtext(""); * No error
        GOTO PROGRAM.ABORT              ; * Nothing to do
    END
* Load akt message with defaults
*
    AMOUNT = AMOUNT * AKT.AMOUNT.FACTOR          ; * Expressed as cents
    AKT.AMOUNT = FMT(AMOUNT,'7"0"R'):"C"         ; * nnnnnnnC format for AKT
*###      PRINT @(8,22):OPERATION:" ":AKT.AMOUNT :;INPUT XXX
    AKT.MESSAGE[1,4] = TELLER.ID       ; * Teller = AKT device number
    AKT.MESSAGE[14,1] = AKT.LANGUAGE   ; * User's language
    AKT.MESSAGE[5,1] = AKT.PROCESS.FLAG
    AKT.MESSAGE[7,1] = AKT.ERROR.FLAG
*
    RETURN
*
*-----------------------------------------------------------------------
*
PREPARE.MESSAGE:
*
    BEGIN CASE
        CASE OPERATION = "OPEN"
            AKT.MESSAGE[8,1] = AKT.OPEN  ; * Open instruction
        CASE OPERATION = "CLOSE"
            AKT.MESSAGE[8,1] = AKT.CLOSE           ; * Close instruction
        CASE OPERATION = "WITHDRAW" AND NOT(AKT.UNITS)
            AKT.MESSAGE[8,1] = AKT.WITHDRAW.DEFAULT          ; * Withdraw default denoms
            AKT.MESSAGE[25,8] = AKT.AMOUNT
        CASE OPERATION = "WITHDRAW" AND AKT.UNITS           ; * Specified denoms
            AKT.MESSAGE[8,1] = AKT.WITHDRAW.SPECIFIC
            AKT.MESSAGE[25,8] = AKT.AMOUNT
            AKT.MESSAGE[49,18] = AKT.UNITS
        CASE OPERATION = "UNLOCK"
            AKT.MESSAGE[8,1] = AKT.UNLOCK
            AKT.MESSAGE[25,8] = "0000000C"         ; * Zero amounts
            AKT.MESSAGE[33,8] = "0000000C"
            AKT.MESSAGE[41,8] = "0000000C"
            AKT.MESSAGE[49,8] = "0000000C"
            AKT.MESSAGE[57,8] = "0000000C"
            AKT.MESSAGE[65,8] = "0000000C"
        CASE OPERATION = "PAID.OUT"
            AKT.MESSAGE[8,1] = AKT.PAID.OUT
        CASE 1
            EB.SystemTables.setEtext("TT.RTN.INVALID.AUTOCASH.OPERATION":@FM: OPERATION)
            GOTO PROGRAM.ABORT
    END CASE
*
    RETURN
*-----------------------------------------------------------------------
*
SEND.MESSAGE:
*
* Convert ASCII portion of message to EBCDIC
*
    AKT.MESSAGE[1,4] = EBCDIC(AKT.MESSAGE[1,4])
    AKT.MESSAGE[16,149] = EBCDIC(AKT.MESSAGE[16,149])
*
    PRINT @(50,22): AKT.WAITING:
    WRITE AKT.MESSAGE TO F.UFD, AKT.SEND.ID      ; * Write out message
        HUSH ON                            ; * Suppress screen
        EXECUTE AKT.SEND.COMMAND
        HUSH OFF                           ; * Turn screen back on
        *
        RETURN
        *
        *-----------------------------------------------------------------------
        *
CHECK.RESPONSE:
        *
        PRINT @(50,22): EB.Desktop.getSClearEol():       ; * Clear awaiting message
        *
        * Read the response record.
        *
        SECOND = 0
        R.RESPONSE = ""
        EB.SystemTables.setEtext(""); * Loaded with fatal errors
        *
        READ R.RESPONSE FROM F.UFD, AKT.RESPONSE.ID ELSE
            R.RESPONSE = ""
        END
        *
        IF NOT(R.RESPONSE) THEN            ; * Nothing
            EB.SystemTables.setEtext("TT.RTN.AKT.ERROR.NO.REPSPONSE"); * Tell them
            GOTO PROGRAM.ABORT
        END
        *
        * Convert EBCDIC portion of message to ASCII
        *
        R.RESPONSE[1,4] = ASCII(R.RESPONSE[1,4])
        R.RESPONSE[16,149] = ASCII(R.RESPONSE[16,149])         ; * 16-164
        *
        IF R.RESPONSE[7,1] = CHARX(242) THEN         ; * Error
            AKT.ERROR = R.RESPONSE[125,3]   ; * Error number
            EB.SystemTables.setEtext("TT.RTN.AKT.ERROR":@FM: AKT.ERROR:@VM:TRIMB(R.RESPONSE[128,37]))
            GOTO PROGRAM.ABORT
        END
        *
        IF R.RESPONSE[7,1] = CHARX(241) THEN         ; * Warning
            AKT.ERROR = R.RESPONSE[125,3]   ; * Error number
            EB.SystemTables.setText("AKT WARNING: &": @FM: AKT.ERROR:" ":TRIMB(R.RESPONSE[128,37]))
            EB.Display.Rem()                        ; * Tell them
        END
        *
        IF OPERATION = "PAID.OUT" THEN     ; * Return the paid out amount
            AMOUNT = R.RESPONSE[30,7]
            IF NUM(AMOUNT) THEN
                AMOUNT = AMOUNT * 1          ; * Drop leading zeroes
            END
        END
        *
        RETURN
        *
        *-----------------------------------------------------------------------
        *
PROGRAM.ABORT:
        RETURN TO PROGRAM.ABORT
        *
        *-----------------------------------------------------------------------
        *
PROGRAM.END:
        *
        RETURN
        *
        *----------------------------------------------------------------------
    END
