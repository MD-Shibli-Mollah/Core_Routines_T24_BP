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
* <Rating>1280</Rating>
*-----------------------------------------------------------------------------
* Version 6 26/04/01  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE TT.Foundation
    SUBROUTINE TT.DEAL.SLIP.PRINT
*
*************************************************************************
* This routine is called by FIELD.MULTI.INPUT or FIELD.INPUT when the
* terminal in use includes a hotkey sequence for deal slip production.
*
* The field input routine has recognised the deal slip hotkey and also
* checked that the common variable PRT.ROUTINE has been set by the actual
* application running. The version id and function enrichments are set
* and the DEAL.SLIP.PRINT routine itself is called to produce the slip.
*
* Some terminals may be capable of printing to a locally connected printer
* This can be determined from the teller id record which will contain the
* passbook print device if supported on this terminal.
*
*************************************************************************

* Modification history

*
* 14/11/90 - HY9000023
*            Use local printer sequences from I_SCREEN.VARIABLES instead
*            of the print echo fields. Add more validation.
*
* 22/01/91 - HY9100075
*            Advice can either be a Version or a DEAL.SLIP.FORMAT id.
*            Allow multiple advices.

*
* 16/05/91 - GB9100126
*            DEAL.SLIP.FORMAT interface enabled in the main release
*            at 10.5.0
*
* 10/09/91 - GB9100300
*            Set terminal type to dumb prior to printing VERSION deal
*            slips. Get <eject> sequence from S.LOCAL.PRINT.OFF variable
*            - use <FF> as default.
*
*************************************************************************

    $USING TT.Contract
    $USING TT.Config
    $USING EB.Display
    $USING EB.Dealslip
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Desktop
*
*-----------------------------------------------------------------------

    GOSUB INITIALISATION
    LOOP ADVICE = REMOVE(ADVICE.LIST,D) UNTIL ADVICE = ""
        GOSUB PRINT.DEAL.SLIP
    REPEAT
    GOTO PROGRAM.END
*
*-----------------------------------------------------------------------
*
INITIALISATION:
*
* Open necessary files
*	
	DEFFUN CHARX()
    F.TELLER.TRANSACTION = ""
*
    IF EB.SystemTables.getRNew(TT.Contract.Teller.TeNetAmount) = "" OR EB.SystemTables.getRNew(TT.Contract.Teller.TeTransactionCode) = "" THEN
        EB.SystemTables.setText("TRANSACTION DATA HAS NOT BEEN ENTERED")
        EB.Display.Rem()
        GOTO PROGRAM.ABORT
    END
*
    READ.FAILED = ""
    R.TELLER.TRANSACTION = ""
    tmp.R.NEW.TT.Contract.Teller.TeTransactionCode = EB.SystemTables.getRNew(TT.Contract.Teller.TeTransactionCode)
    R.TELLER.TRANSACTION = TT.Config.TellerTransaction.Read(tmp.R.NEW.TT.Contract.Teller.TeTransactionCode, READ.FAILED)
    EB.SystemTables.setRNew(TT.Contract.Teller.TeTransactionCode, tmp.R.NEW.TT.Contract.Teller.TeTransactionCode)
    IF READ.FAILED THEN
        EB.SystemTables.setText(READ.FAILED)
        EB.Display.Rem()
        GOTO PROGRAM.ABORT
    END
*
    ADVICE.LIST = R.TELLER.TRANSACTION<TT.Config.TellerTransaction.TrAdviceVersion>
*
    IF ADVICE.LIST = "" THEN
        EB.SystemTables.setText("DEAL SLIP NOT DEFINED")
        EB.Display.Rem()
        GOTO PROGRAM.ABORT
    END
*
    REPORT.ID = "TT.DEAL.SLIP"         ; * Default for 'version' prints
*
    PRINT.OFF = EB.Desktop.getSLocalPrintOff()[" ",1,1]       ; * Back to screen
    FF = EB.Desktop.getSLocalPrintOff()[" ",2,1]    ; * Eject sequence
*
    IF NOT(FF) THEN                    ; * Default to form feed
        FF = CHARX(12)                  ; * Form Feed for local printer
    END

*
    DUMB.TERMINAL = "HUSH": @FM: "SET.TERMINAL dumb": @FM: "HUSH"
    RESET.TERMINAL= "HUSH": @FM: "SET.TERMINAL ": @TERM.TYPE: @FM: "HUSH"
*
*
* Set up the function enrichment for the deal slip print
*
    tmp.V = EB.SystemTables.getV()
    tmp.V = EB.SystemTables.getV()
    RECORD.NO=EB.SystemTables.getRNew(tmp.V-7) ; RECORD.STATUS=EB.SystemTables.getRNewLast(tmp.V-8)
    EB.SystemTables.setV(tmp.V)
    EB.SystemTables.setV(tmp.V)
*
    BEGIN CASE
        CASE RECORD.NO=1 AND EB.SystemTables.getVFunction()='I' AND RECORD.STATUS=''
            FUNCTION.ENRI=''
        CASE EB.SystemTables.getVFunction()='I'
            FUNCTION.ENRI=(IF RECORD.STATUS#'' THEN '(AMEND UNAUTHORISED)' ELSE '(AMEND AUTHORISED)')
    CASE EB.SystemTables.getVFunction()='A'
        FUNCTION.ENRI=(IF RECORD.STATUS[1,1]='R' THEN '(AUTHORISE REVERSAL)' ELSE '(AUTHORISE)')
    CASE EB.SystemTables.getVFunction()='D'
    FUNCTION.ENRI=(IF RECORD.STATUS[1,1]='R' THEN '(DELETE REVERSAL)' ELSE '(DELETE)')
    CASE EB.SystemTables.getVFunction()='R'
    FUNCTION.ENRI='(REVERSE)'
*
    CASE EB.SystemTables.getVFunction()="C"
    FUNCTION.ENRI=(IF RECORD.STATUS#'' THEN '(COPY UNAUTHORISED)' ELSE '(COPY AUTHORISED)')
*
    CASE 1
    FUNCTION.ENRI = ""
    END CASE
*
    Y.TIMEDATE = TIMEDATE()[1,5]:" ":TIMEDATE()[10,11]
    FUNCTION.ENRI = FUNCTION.ENRI:" ":Y.TIMEDATE
*
    FUNCTION.ENRI<2> = "NO"
*
*
* Initialise the blinking & reset 'PRINTED' messages to be displayed.
*
    tmp.S.CURSOR.BACK = EB.Desktop.getSCursorBack()
    MESSAGE.1 = @(63+LEN(EB.SystemTables.getTRemtext(18)),21):EB.Desktop.getSBlinkOff():@(63-tmp.S.CURSOR.BACK,21):EB.Desktop.getSBlinkOn():EB.SystemTables.getTRemtext(18):EB.Desktop.getSBlinkOff():EB.Desktop.getSClearEol()
    EB.Desktop.setSCursorBack(tmp.S.CURSOR.BACK)
*
    MESSAGE.2 = @(63+LEN(EB.SystemTables.getTRemtext(18)),21):EB.Desktop.getSHalfIntensityOff():@(63,21):EB.Desktop.getSHalfIntensityOn():EB.Desktop.getSBlinkOff():EB.SystemTables.getTRemtext(18):EB.Desktop.getSHalfIntensityOff():EB.Desktop.getSClearEol()
*
    RETURN
*
*-----------------------------------------------------------------------
*
PRINT.DEAL.SLIP:
*
* Determine if a local printer is attached. If not send it out via
* report control. If the format is based on the old Version mechanism then
* we have to handle the output destination (local or report control)
* otherwise PRODUCE.DEAL.SLIP call from DEAL.SLIP.PRINT handles it.
*
    PRINT MESSAGE.1:                   ; * Printing
*
    VERSION.TYPE = INDEX(ADVICE,",",1)           ; * Version format
*
    IF VERSION.TYPE THEN               ; * Using old VERSION mechanism
        IF EB.Desktop.getSLocalPrintOn() THEN        ; * Local printing
            EXECUTE DUMB.TERMINAL        ; * Otherwise HEADING screws up printer
            PRINT EB.Desktop.getSLocalPrintOn():
            EB.Dealslip.DealSlipPrint(ADVICE,FUNCTION.ENRI)
            PRINT FF: PRINT.OFF:
            EXECUTE RESET.TERMINAL       ; * Put it back
        END ELSE
            IF EB.SystemTables.getPrinterStatus()='OPEN' THEN EB.Reports.PrinterClose('P.FUNCTION','','') ; EB.SystemTables.setPrinterStatus(''); * Get rid of any earlier P.FUNCTIONS
            EB.Reports.PrinterOn(REPORT.ID,"")
            EB.Dealslip.DealSlipPrint(ADVICE,FUNCTION.ENRI)
            EB.Reports.PrinterClose(REPORT.ID,"","")    ; * Spool it
        END
        *
    END ELSE
        EB.Dealslip.DealSlipPrint(ADVICE,FUNCTION.ENRI)          ; * PRODUCE.DEAL.SLIP handles printing
    END
*
    PRINT MESSAGE.2:                   ; * Printed
*
    RETURN
*
*-----------------------------------------------------------------------

*
*-----------------------------------------------------------------------
*
PROGRAM.ABORT:
*
    RETURN TO PROGRAM.ABORT
*
*-----------------------------------------------------------------------
*
PROGRAM.END:
*
    RETURN
*
*-----------------------------------------------------------------------
    END
