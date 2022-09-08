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

* Version 12 27/02/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>912</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Reports
    SUBROUTINE E.DE.PRINT.MSG
*
* E.DE.PRINT.MSG - Calls the appropiate print message program
* according to the id passed from the enquiry program
*
*  18/05/93 - GB9300875
*           Add PRINTER.CLOSE to spool printed messages.
*
* 10/04/00  - GB0000648
*             Complex IF THEN statements.
*             In IF-THEN-ELSE statement there is a READ-ELSE or MATREAD-
*             ELSE in the same line as THEN or ELSE ( of the IF). This
*             is not accepted in jBASE. The READ-ELSE statements is moved
*             to the line after THEN or ELSE.
*
* 15/06/07 - BG_100014234
*            Incorrect no. of arguments and routine missing
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*************************************************************************
    $USING DE.Config
    $USING DE.Reports
    $USING DE.Clearing
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Desktop

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    DIM R.HEAD(50)
    PROMPT ""

* Spool all reports regardles of carrier to the same REPORT.ID.

    REPORT.ID = 'ENQ.FORMATTED.MSG'
    PRINT.REQUESTED = ''

    ERROR.TEXT = CHARX(7):@(19,23):(-4):@(19,23)
    REMOVE.ERROR.TEXT = @(19,23):EB.Desktop.getSClearEol()
    tmp.S.CURSOR.BACK = EB.Desktop.getSCursorBack()
    PRINT @(24 - tmp.S.CURSOR.BACK,0):EB.Desktop.getSClearEol():@(40,0):EB.Desktop.getSReverseVideoOff():
    PRINT @(24,0):EB.Desktop.getSReverseVideoOn():'DISPLAY MESSAGES':EB.Desktop.getSReverseVideoOff():EB.Desktop.getSClearEol():
    PRINT @(0,1):EB.Desktop.getSClearEol():
    PRINT @(0,23):EB.Desktop.getSClearEol():
    PRINT @(8,22):EB.Desktop.getSClearEol():
    FOR I = 4 TO 19
        PRINT @(0,I):EB.Desktop.getSClearEol()
    NEXT I
*
* Process each id passed from the enquiry program in T.FUNCTION in turn
*
    tmp.T.FUNCTION = EB.SystemTables.getTFunction()
    MAX.MESSAGES = COUNT(tmp.T.FUNCTION,@FM) + 1
    FOR MESSAGE.NO = 1 TO MAX.MESSAGES
        MESSAGE.KEY = EB.SystemTables.getTFunction()<MESSAGE.NO,1>

        * Use the function entered to set DISPLAY.CODE which controls if the
        * message is to be printed or dispalyed on the screen. If "P"rint is
        * not specifically requested then assume "D"isplay.

        DISPLAY.CODE = EB.SystemTables.getTFunction()<MESSAGE.NO,2>
        ERR.MSG = ""
        IF DISPLAY.CODE EQ "P" THEN
            IF PRINT.REQUESTED = '' THEN
                ER = ''
                R.REPORT = EB.Reports.ReportControl.Read(REPORT.ID, ER)
                IF ER THEN
                    ERR.MSG = "Report control record ":REPORT.ID:" missing"
                    GOTO RESET.SCREEN
                END
                PRINT.REQUESTED = 1
            END
        END ELSE
            DISPLAY.CODE = "D"
        END
        *
        * Get header record
        *
        RECORD.EXISTS = 1
        ARCHIVE = 1
***** START ** GB0000648
        R.HEAD.REC = ''
        IF MESSAGE.KEY[1,1] = 'D' THEN
            R.HEAD.REC = DE.Config.OHeaderArch.Read(MESSAGE.KEY, ER)
        END ELSE
            R.HEAD.REC = DE.Config.IHeaderArch.Read(MESSAGE.KEY, ER)
        END
        IF NOT(R.HEAD.REC) THEN
            RECORD.EXISTS = ''
        END
***** END ** GB0000648

        IF RECORD.EXISTS THEN
            MATPARSE R.HEAD FROM R.HEAD.REC
            *
            * Call appropiate print program for each message in turn
            *
            NO.RECORDS = 1
            IF R.HEAD(DE.Config.OHeader.HdrCarrierAddressNo) THEN
                MAX.VALUES = COUNT(R.HEAD(DE.Config.OHeader.HdrCarrierAddressNo),@VM) + 1
                FOR COPY.NO = 1 TO MAX.VALUES
                    MESSAGE.EXISTS = 1
                    IF MESSAGE.KEY[1,1] = 'D' THEN
                        IF R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,COPY.NO> <> 'FORMATTED' THEN
                            IF R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,COPY.NO>[1,3] <> 'ACK' THEN
                                IF R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,COPY.NO>[1,4] <> 'WACK' THEN
                                    MESSAGE.EXISTS = 0
                                END
                            END
                        END
                    END
                    IF MESSAGE.EXISTS THEN
                        CARRIER = FIELD(R.HEAD(DE.Config.OHeader.HdrCarrierAddressNo)<1,COPY.NO>,'.',1)
                        ERR.MSG = ''
                        BEGIN CASE
                            CASE CARRIER = 'SWIFT' OR CARRIER = 'TELEXF'
                                DE.Reports.MmPrintSwift(DISPLAY.CODE,MESSAGE.KEY,COPY.NO,ARCHIVE,ERR.MSG)

                                * DE.MM.PRINT.TELEX made Obsolete, so Case removed. ;*BG_100014234 S/E

                            CASE CARRIER = 'PRINT'
                                DE.Reports.MmPrintPrint(DISPLAY.CODE,MESSAGE.KEY,COPY.NO,ARCHIVE,ERR.MSG)

                                * DE.MM.PRINT.EUCLID made Obsolete, so Case removed. ;*BG_100014234 S/E

                            CASE CARRIER = 'SIC'
                                DE.Clearing.MmPrintSic(DISPLAY.CODE,MESSAGE.KEY,COPY.NO,ARCHIVE,ERR.MSG)
                            CASE 1
                                * Print program not yet written
                        END CASE
                        NO.RECORDS = 0
                    END
                NEXT COPY.NO
            END
            IF ERR.MSG THEN ERR.MSG = 'No formatted messages for this reference'
            IF NO.RECORDS THEN ERR.MSG = 'No formatted messages for this reference'
        END ELSE
            ERR.MSG = 'Record does not exist'
        END

RESET.SCREEN:
        *
        * Reset screen
        *
        PRINT @(24,0):'DISPLAY MESSAGES':EB.Desktop.getSClearEol():
        PRINT @(0,2):EB.Desktop.getSClearEol():
        FOR I = 4 TO 19
            PRINT @(0,I):EB.Desktop.getSClearEol()
        NEXT I
        *
        * If an error occurred, display on screen
        *
        PRINT REMOVE.ERROR.TEXT:
        IF ERR.MSG THEN
            PRINT ERROR.TEXT:FMT(ERR.MSG,'60R'):
            INPUT XX:
        END
    NEXT MESSAGE.NO

* Spool any printed messages

    IF PRINT.REQUESTED THEN
        EB.Reports.PrinterClose(REPORT.ID, 0, '')
    END

    RETURN
    END
