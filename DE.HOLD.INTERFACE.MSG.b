* @ValidationCode : MTotODc1NzI0NjkxOkNwMTI1MjoxNDY3MzAwNDUxMjY1OmhlbWFwcml5YW46LTE6LTE6MDowOmZhbHNlOk4vQQ==
* @ValidationInfo : Timestamp         : 30 Jun 2016 20:57:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : hemapriyan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 4 16/03/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>2319</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
    SUBROUTINE DE.HOLD.INTERFACE.MSG
*
* DE.HOLD.INTERFACE.MSG - Contains the hold instructions by application,
* message type, apllication format, and version format
*
REM "DE.HOLD.INTERFACE.MSG",850107-001,"MAINPGM"
*
*************************************************************************
*
* Modifications
* -------------
*
* GB9400575 - 04-05-94
*             STACHEM delivery enhancements
*             5 characters instead of 4 for DEPT.
*
* 01/06/01  - GLOBUS_EN_10000101
*             Add CQ as a valid application
*
* 20/02/02  - GLOBUS_EN_10000352
*             Add BL as a valid application
*
* 20/04/02  - GLOBUS_EN_10000646
*             Add SL as a valid application
*
* 22/09/15 - Enhancement 1265068/Task 1448651 
*          - Routine incorporated
*
*************************************************************************
*
    $USING DE.Config
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/DE.HOLD.INTERFACE.MSG/.../G9999')
*========================================================================
    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.clearConcatfile()
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
*========================================================================
REM "DEFINE PARAMETERS - SEE 'I_RULES'-DESCRIPTION:
*
    EB.SystemTables.setIdF('ID')
    EB.SystemTables.setIdN('20.2')
    EB.SystemTables.setIdT('A')
    EB.SystemTables.setIdCheckfile('')
    EB.SystemTables.setIdConcatfile('AL')
*
    EB.SystemTables.setF(1, 'INTERFACE DEPT'); EB.SystemTables.setN(1, '5')
*
    EB.SystemTables.setV(10); * number of fields
*
    EB.SystemTables.setT(1, "A")
*
*
*========================================================================
    V$FUNCTION.VAL= EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN RETURN
*     RETURN when pgm used to get parameters only
*------------------------------------------------------------------------
    EB.Display.MatrixUpdate()

    DIM R.PARM(DE.Config.Parm.ParDim + 9)
*------------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN RETURN
*     return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
        *========================================================================
        REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" THEN
            EB.SystemTables.setE("INVALID FUNCTION FOR THIS PGM")
ID.ERROR:
            EB.ErrorProcessing.Err() ; GOTO ID.INPUT
        END
        *========================================================================
        IF EB.SystemTables.getVFunction() = "E" OR EB.SystemTables.getVFunction() = "L" THEN
            EB.Display.FunctionDisplay() ; EB.SystemTables.setVFunction("")
        END
        GOTO ID.INPUT
    END
*========================================================================
REM "CHECK ID OR CHANGE STANDARD ID:
*========================================================================
*
* VALIDATE KEY
*
* Must be application.message-type.application-format.format
*
* Separate key into components
*
    AF0 = EB.SystemTables.getComi()
    APPL = FIELD(AF0, '.' , 1)
    MSG.TYPE = FIELD(AF0, '.' , 2)
    APPL.FORMAT = FIELD(AF0, '.' , 3)
    VERS.FORMAT = FIELD(AF0, '.' , 4)
    AF0 = APPL:'.':MSG.TYPE:'.':APPL.FORMAT:'.':VERS.FORMAT
*
*
* Access the parameter file to see whether EBS files are resident
*
    R.PARM.REC = DE.Config.Parm.CacheRead('SYSTEM.STATUS', ER)
    MATPARSE R.PARM FROM R.PARM.REC
    IF ER THEN
        MAT R.PARM = ''
        EB.SystemTables.setE('SYSTEM STATUS RECORD MISSING')
        GOTO ID.ERROR
    END
*
* Application must not be blank
* and if a component is present, all the upper levels must be there
*
    IF APPL = "" THEN
        EB.SystemTables.setE("ENTER APPLICATION OR 'ALL'")
        GOTO ID.ERROR
    END
    IF VERS.FORMAT <> "" THEN
        IF APPL.FORMAT = "" OR MSG.TYPE = "" THEN
            EB.SystemTables.setE("ENTER EVERYTHING BEFORE VERSION FORMAT")
            GOTO ID.ERROR
        END
    END
    IF APPL.FORMAT <> "" THEN
        IF MSG.TYPE = "" THEN
            EB.SystemTables.setE("ENTER EVERYTHING BEFORE APPLICATION FORMAT")
            GOTO ID.ERROR
        END
    END
*
* Application must be FX, FT, MM, BD, LD, MG, LC, SC, AC, EF, LC, SC, FR,CQ,
* or ALL, or xxyy
* where xx is the application code and yy is the FT product code
*
    BEGIN CASE
        CASE APPL = 'ALL'
            NULL
        CASE LEN(APPL) <> 2 AND LEN(APPL) <> 4
            EB.SystemTables.setE('INVALID APPLICATION')
            GOTO ID.ERROR
        CASE 1
            IF APPL[1, 2] MATCHES "FX" : @VM : "FT" : @VM : "MM" : @VM : "BD" : @VM : "LD" : @VM : "MG" : @VM : "AC" : @VM : "EF" : @VM : 'LC' : @VM : 'SC' : @VM : 'FR' : @VM: 'FD' : @VM : 'CQ' : @VM : 'BL' : @VM : 'SL' THEN NULL ELSE        ; * EN_10000101, EN_10000352, EN_10000646 S/E
            EB.SystemTables.setE("INVALID APPLICATION")
            GOTO ID.ERROR
        END
    END CASE
*
* If message type is not 'ALL', it must be numeric
*
    ENRIX = ''
    IF MSG.TYPE <> "ALL" THEN
        IF NOT(NUM(MSG.TYPE)) THEN
            EB.SystemTables.setE("TYPE MUST BE NUMERIC")
            GOTO ID.ERROR
        END
        *
        * Trim leading zeros from message type
        *
        LOOP
        WHILE MSG.TYPE[1, 1] = 0
            MSG.TYPE = MSG.TYPE[2, 99]
        REPEAT
        *
        * If message type is not 'ALL', check that it exists on the message file
        *
        R.REC = DE.Config.Message.Read(MSG.TYPE, ER)
        EB.SystemTables.setEtext(ER)
        LNGG.POS = EB.SystemTables.getLngg()
        ENRIX = R.REC<DE.Config.Message.MsgDescription,LNGG.POS>
        IF NOT(ENRIX) THEN
            ENRIX = R.REC<DE.Config.Message.MsgDescription,1>
        END
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE(EB.SystemTables.getEtext())
            GOTO ID.ERROR
        END
    END
*
    EB.SystemTables.setIdEnri(ENRIX)
    EB.SystemTables.setIdNew(AF0)
    EB.SystemTables.setComi(AF0)
    EB.TransactionControl.RecordRead()
    IF EB.SystemTables.getMessage() = "REPEAT" THEN GOTO ID.INPUT
    EB.Display.MatrixAlter()
*========================================================================
REM "SPECIAL CHECKS OR CHANGE FIELDS AFTER READING RECORD(S):
*========================================================================
FIELD.DISPLAY.OR.INPUT:
    BEGIN CASE
        CASE EB.SystemTables.getScreenMode() = "MULTI"
            IF EB.SystemTables.getFileType() = "I" THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        CASE EB.SystemTables.getFileType() = "I"
            EB.Display.FieldInput()
        CASE 1
            EB.Display.FieldDisplay()
    END CASE
*------------------------------------------------------------------------
HANDLE.MESSAGE:
    BEGIN CASE
        CASE EB.SystemTables.getMessage() = "REPEAT" ; NULL
        CASE EB.SystemTables.getMessage() = "VAL"
            EB.SystemTables.setMessage("")
            IF EB.SystemTables.getVFunction() = "D" OR EB.SystemTables.getVFunction() = "R" THEN
                *========================================================================
                REM "HANDLING REVERSAL:
                *========================================================================
                NULL
            END ELSE
                *========================================================================
                REM "HANDLING 'VAL'-CHECKS:
                *========================================================================
                *
                * Validate origin department
                *
                INTERFACE.DEPT = EB.SystemTables.getRNew(DE.Config.HoldInterfaceMsg.HoldMsgDept)
                *              IF NOT(NUM(INTERFACE.DEPT)) THEN
                *                 ETEXT = "INTERFACE DEPARTMENT MUST BE NUMERIC"
                *                 CALL STORE.END.ERROR
                *              END
                *
                REM "HANDLE AUTOM. CALCULATED FIELDS (BEGINNING WITH OVERRIDE):
                *========================================================================
                REM "HANDLING UPDATE SPECIAL FILES:
                *========================================================================
            END
            EB.TransactionControl.UnauthRecordWrite()
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
            IF EB.SystemTables.getMessage() = "AUT" THEN GOTO HANDLE.MESSAGE
        CASE EB.SystemTables.getMessage() = "AUT"
            *========================================================================
            REM "DEFINE FINAL CHECKS BEFORE STORING AUTHORISED LIFE FILE RECORD:
            *========================================================================
            V.VAL = EB.SystemTables.getV()
            IF EB.SystemTables.getRNew(V.VAL - 8)[2, 3] = 'NAU' AND EB.SystemTables.getAuthNo() = 2 THEN GOTO SKIP.AUTH.CALL
SKIP.AUTH.CALL:
            EB.TransactionControl.AuthRecordWrite()
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
        CASE 1
            *========================================================================
            REM "DEFINE SPECIAL FIELD CHECKS:
            *========================================================================
            *
*************************************************************************
    END CASE
    GOTO ID.INPUT
    RETURN
    END
