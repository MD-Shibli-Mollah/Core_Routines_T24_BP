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
* <Rating>114</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05


    $PACKAGE PC.Contract
    SUBROUTINE PC.STMT.ADJUSTMENT

* 21/09/02 - EN_10001196
*            Conversion of error messages to error codes.

    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING PC.Contract


*************************************************************************

    GOSUB DEFINE.PARAMETERS


    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE                   ; * Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL (EB.SystemTables.getMessage() EQ 'RET')

        V$ERROR = ''

        IF EB.SystemTables.getMessage() EQ 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

            REM >       GOSUB CHECK.ID                  ;* Special Editing of ID
            REM >       IF ERROR THEN GOTO MAIN.REPEAT

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            REM >       GOSUB CHECK.RECORD              ;* Special Editing of Record
            REM >       IF ERROR THEN GOTO MAIN.REPEAT

            REM >       GOSUB PROCESS.DISPLAY           ;* For Display applications

            LOOP
                GOSUB PROCESS.FIELDS      ; * ) For Input
                GOSUB PROCESS.MESSAGE     ; * ) Applications
            WHILE (EB.SystemTables.getMessage() EQ 'ERROR') REPEAT

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
    RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

PROCESS.FIELDS:

* Input or display the record fields.

    LOOP
        IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        END ELSE
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldInput()
            END ELSE
                EB.Display.FieldDisplay()
            END
        END


    WHILE NOT(EB.SystemTables.getMessage())

        REM >    GOSUB CHECK.FIELDS              ;* Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)

    REPEAT

    RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() = 'DEFAULT' THEN
        EB.SystemTables.setMessage('ERROR'); * Force the processing back
        IF EB.SystemTables.getVFunction() <> 'D' AND EB.SystemTables.getVFunction() <> 'R' THEN
            REM >       GOSUB CROSS.VALIDATION
        END
    END

    IF EB.SystemTables.getMessage() = 'PREVIEW' THEN
        EB.SystemTables.setMessage('ERROR'); * Force the processing back
        IF EB.SystemTables.getVFunction() <> 'D' AND EB.SystemTables.getVFunction() <> 'R' THEN
            REM >       GOSUB CROSS.VALIDATION
            REM >       IF NOT(ERROR) THEN
            REM >          GOSUB DELIVERY.PREVIEW
            REM >       END
        END
    END

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
                REM >          GOSUB CHECK.DELETE              ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
                REM >          GOSUB CHECK.REVERSAL            ;* Special Reversal checks
            CASE 1
                REM >          GOSUB CROSS.VALIDATION          ;* Special Cross Validation
                REM >          IF NOT(ERROR) THEN
                REM >             GOSUB OVERRIDES
                REM >          END
        END CASE
        REM >    IF NOT(ERROR) THEN
        REM >       GOSUB BEFORE.UNAU.WRITE         ;* Special Processing before write
        REM >    END
        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
            REM >       IF MESSAGE NE "ERROR" THEN
            REM >          GOSUB AFTER.UNAU.WRITE          ;* Special Processing after write
            REM >       END
        END

    END

    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
        REM >    GOSUB AUTH.CROSS.VALIDATION          ;* Special Cross Validation
        REM >    IF NOT(ERROR) THEN
        REM >       GOSUB BEFORE.AUTH.WRITE         ;* Special Processing before write
        REM >    END

        IF NOT(V$ERROR) THEN

            EB.TransactionControl.AuthRecordWrite()

            REM >       IF MESSAGE NE "ERROR" THEN
            REM >          GOSUB AFTER.AUTH.WRITE          ;* Special Processing after write
            REM >       END
        END

    END

    RETURN

*************************************************************************

PROCESS.DISPLAY:

* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

    RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.

    IF EB.SystemTables.getE() THEN V$ERROR = 1

    RETURN

*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.


    RETURN

*************************************************************************

CHECK.FIELDS:
REM > CALL XX.CHECK.FIELDS
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

    RETURN

*************************************************************************

CROSS.VALIDATION:

*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
*
REM > CALL XX.CROSSVAL
*
* If END.ERROR has been set then a cross validation error has occurred
*
    IF EB.SystemTables.getEndError() THEN
        EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getTEtext()<EB.SystemTables.getA()> <> "" DO EB.SystemTables.setA(EB.SystemTables.getA()+1); REPEAT
        EB.SystemTables.setTSequ('D')
        tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA(); EB.SystemTables.setTSequ(tmp)
        V$ERROR = 1
        EB.SystemTables.setMessage('ERROR')
    END
    RETURN                             ; * Back to field input via UNAUTH.RECORD.WRITE

*************************************************************************

OVERRIDES:
*
*  Overrides should reside here.
*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
REM > CALL XX.OVERRIDE
*

*
    IF EB.SystemTables.getText() = "NO" THEN                ; * Said NO to override
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR"); * Back to field input

    END
    RETURN

*************************************************************************

AUTH.CROSS.VALIDATION:


    RETURN

*************************************************************************

CHECK.DELETE:


    RETURN

*************************************************************************

CHECK.REVERSAL:


    RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
*
*  Contract processing code should reside here.
*
REM > CALL XX.         ;* Accounting, Schedule processing etc etc

    IF EB.SystemTables.getText() = "NO" THEN                ; * Said No to override
        EB.TransactionControl.TransactionAbort()          ; * Cancel current transaction
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR"); * Back to field input
        RETURN
    END

*
* Additional updates should be performed here
*
REM > CALL XX...



    RETURN

*************************************************************************

AFTER.UNAU.WRITE:


    RETURN

*************************************************************************

AFTER.AUTH.WRITE:


    RETURN

*************************************************************************

BEFORE.AUTH.WRITE:

    BEGIN CASE
        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "INA"    ; * Record status
            REM > CALL XX.AUTHORISATION
        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "RNA"    ; * Record status
            REM > CALL XX.REVERSAL

    END CASE
*
* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
* IF R.NEW(V-9) THEN
*    EXCEP.CODE = "110" ; EXCEP.MESSAGE = "OVERRIDE CONDITION"
*    GOSUB EXCEPTION.MESSAGE
* END
*

    RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    IF INDEX('V',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('PC.RTN.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

    RETURN

*************************************************************************
*
EXCEPTION.MESSAGE:
*

    APPLN = EB.SystemTables.getApplication()
    EXCEP.MESSAGE = ''
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,APPLN,APPLN,EXCEP.CODE,"",EB.SystemTables.getFullFname(),EB.SystemTables.getIdNew(), EB.SystemTables.getRNew(EB.SystemTables.getV()-7),EXCEP.MESSAGE,ACCT.OFFICER)

*
    RETURN

*************************************************************************

INITIALISE:

    APP.CODE = ""                      ; * Set to product code ; e.g FT, FX
    ACCT.OFFICER = ""                  ; * Used in call to EXCEPTION. Should be relevant A/O
    EXCEP.CODE = ""

    RETURN

*************************************************************************

    DEFINE.PARAMETERS:* SEE 'I_RULES' FOR DESCRIPTIONS *

    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.setIdT("")
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
    Z = 0

    EB.SystemTables.setIdF('PC.STMT.ID'); EB.SystemTables.setIdN('60'); tmp=EB.SystemTables.getIdT(); tmp<1>='A'; EB.SystemTables.setIdT(tmp)

    Z += 1 ; EB.SystemTables.setF(Z, 'STMT.ENTRY.ID'); EB.SystemTables.setN(Z, '35'); tmp=EB.SystemTables.getT(Z); tmp<1>='A'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.1'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

    EB.SystemTables.setV(Z + 9); EB.SystemTables.setPrefix('PCS')

    RETURN

*************************************************************************

    END
