* @ValidationCode : MjoyMDEyNDIxMzM0OkNwMTI1MjoxNTcwNzcxNTY3MjQ1OmthamFheXNoZXJlZW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOS4yMDE5MDgyMy0wMzA1Oi0xOi0x
* @ValidationInfo : Timestamp         : 11 Oct 2019 10:56:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>566</Rating>
*-----------------------------------------------------------------------------
* Version 9 15/11/00  GLOBUS Release No. G11.1.01 11/12/00

$PACKAGE ST.RateParameters
SUBROUTINE SETTLEMENT.RATES

******************************************************************

* 29/05/02 - EN_10000410
*            For MG.FX Settlement Rate file will open only in See Mode.
*
* 09/09/02 - EN_10001077
*            Conversion of error messages to error codes.
*
* 05/06/08 - CI_10055883
*            From now on, SETTLEMENT.RATES records will be created in INAU
*            stage whenever an LD is input. This record gets authorised when
*            the respective LD is authorised. Hence, we must not allow the
*            user to tamper such INAU data, so we restrict all functions
*            but for SEE when the INPUTTER of the INAU record is <TNO>_LD.AUTO.
*
* 11/10/19 - Enhancement 2822520 / Task 3380726
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*************************************************************************
    $USING ST.RateParameters
    $INSERT I_COMMON
    $INSERT I_EQUATE
*************************************************************************

    GOSUB DEFINE.PARAMETERS

    IF LEN(V$FUNCTION) GT 1 THEN
        GOTO V$EXIT
    END

    CALL MATRIX.UPDATE

    GOSUB INITIALISE          ;* Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        CALL RECORDID.INPUT

    UNTIL (MESSAGE EQ 'RET')

        V$ERROR = ''

        IF MESSAGE EQ 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION        ;* Special Editing of Function

            IF V$FUNCTION EQ 'E' OR V$FUNCTION EQ 'L' THEN
                CALL FUNCTION.DISPLAY
                V$FUNCTION = ''
            END
            IF V$FUNCTION EQ 'R' THEN
                E ='LD.SER.FUNT.NOT.ALLOWED'
                CALL ERR
                V$ERROR = 1
            END

        END ELSE

            GOSUB CHECK.ID    ;* Special Editing of ID
            IF ID.NEW[1,2] EQ 'MG' AND V$FUNCTION # 'S' THEN          ;* EN_10000410 S
                E ="LD.SER.ONLY.SEE.FUNT.ALLOWD"
                CALL ERR
                V$ERROR = 1
            END     ;* EN_10000410 E
            IF V$ERROR THEN GOTO MAIN.REPEAT

            CALL RECORD.READ

            IF MESSAGE EQ 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            CALL MATRIX.ALTER

            GOSUB CHECK.RECORD
            IF V$ERROR THEN GOTO MAIN.REPEAT

            LOOP
                GOSUB PROCESS.FIELDS
                GOSUB PROCESS.MESSAGE
            WHILE (MESSAGE EQ 'ERROR') REPEAT

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
RETURN

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

PROCESS.FIELDS:

* Input or display the record fields.

    LOOP
        IF SCREEN.MODE EQ 'MULTI' THEN
            IF FILE.TYPE EQ 'I' THEN
                CALL FIELD.MULTI.INPUT
            END ELSE
                CALL FIELD.MULTI.DISPLAY
            END
        END ELSE
            IF FILE.TYPE EQ 'I' THEN
                CALL FIELD.INPUT
            END ELSE
                CALL FIELD.DISPLAY
            END
        END

    WHILE NOT(MESSAGE)

        GOSUB CHECK.FIELDS

        IF T.SEQU NE '' THEN T.SEQU<-1> = A + 1

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF MESSAGE = 'DEFAULT' THEN
        MESSAGE = 'ERROR'
        IF V$FUNCTION <> 'D' AND V$FUNCTION <> 'R' THEN
            GOSUB CROSS.VALIDATION
        END
    END

    IF MESSAGE = 'PREVIEW' THEN
        MESSAGE = 'ERROR'
        IF V$FUNCTION <> 'D' AND V$FUNCTION <> 'R' THEN
            GOSUB CROSS.VALIDATION
            IF NOT(V$ERROR) THEN
REM >               GOSUB DELIVERY.PREVIEW   ; * Activate print preview
            END
        END
    END

    IF MESSAGE EQ 'VAL' THEN
        MESSAGE = ''
        BEGIN CASE
            CASE V$FUNCTION EQ 'D'
                GOSUB CHECK.DELETE          ;* Special Deletion checks
            CASE V$FUNCTION EQ 'R'
                GOSUB CHECK.REVERSAL        ;* Special Reversal checks
            CASE OTHERWISE
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
                IF NOT(V$ERROR) THEN
                    GOSUB OVERRIDES
                END
        END CASE
        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.UNAU.WRITE     ;* Special Processing before write
        END
        IF NOT(V$ERROR) THEN
            CALL UNAUTH.RECORD.WRITE
            IF MESSAGE NE "ERROR" THEN
                GOSUB AFTER.UNAU.WRITE  ;* Special Processing after write
            END
        END

    END

    IF MESSAGE EQ 'AUT' THEN
        GOSUB AUTH.CROSS.VALIDATION     ;* Special Cross Validation
        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.AUTH.WRITE     ;* Special Processing before write
        END

        IF NOT(V$ERROR) THEN

            CALL AUTH.RECORD.WRITE

            IF MESSAGE NE "ERROR" THEN
                GOSUB AFTER.AUTH.WRITE  ;* Special Processing after write
            END
        END

    END

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.

    IF E THEN V$ERROR = 1

RETURN

*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.
* New record cannot be created
    IF NOT(ID.OLD) AND V$FUNCTION EQ 'I' THEN
        E ='LD.SER.CREATION.NEW.REC.NOT.ALLOWED'
        CALL ERR
        V$ERROR = 1
    END
    IF R.NEW(ST.RateParameters.SettlementRates.SrInputter)[7] EQ 'LD.AUTO' AND V$FUNCTION NE 'S' THEN
        E = "LD.SER.ONLY.SEE.FUNT.ALLOWD"         ;* new INAU records are not to be tampered!
        CALL ERR
        V$ERROR = 1
    END
RETURN

*************************************************************************

CHECK.FIELDS:
    ST.RateParameters.SettlementRatesCheckFields()
    IF E THEN
        T.SEQU = "IFLD"
        CALL ERR
    END

RETURN

*************************************************************************

CROSS.VALIDATION:

*
    V$ERROR = ''
    ETEXT = ''
    TEXT = ''
*
*       CALL XX.CROSSVAL
*
* If END.ERROR has been set then a cross validation error has occurred
*
    IF END.ERROR THEN
        A = 1
        LOOP UNTIL T.ETEXT<A> <> "" DO A = A+1 ; REPEAT
        T.SEQU = A
        V$ERROR = 1
        MESSAGE = 'ERROR'
    END
RETURN          ;* Back to field input via UNAUTH.RECORD.WRITE

*************************************************************************

OVERRIDES:
*
*  Overrides should reside here.
*
    V$ERROR = ''
    ETEXT = ''
    TEXT = ''
REM > CALL XX.OVERRIDE
*

*
    IF TEXT = "NO" THEN       ;* Said NO to override
        V$ERROR = 1
        MESSAGE = "ERROR"     ;* Back to field input

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
DELIVERY.PREVIEW:

RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
*
*  Contract processing code should reside here.
*
REM > CALL XX.         ;* Accounting, Schedule processing etc etc

    IF TEXT = "NO" THEN       ;* Said No to override
        CALL TRANSACTION.ABORT          ;* Cancel current transaction
        V$ERROR = 1
        MESSAGE = "ERROR"     ;* Back to field input
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
        CASE R.NEW(V-8)[1,3] = "INA"        ;* Record status
REM > CALL XX.AUTHORISATION
        CASE R.NEW(V-8)[1,3] = "RNA"        ;* Record status
REM > CALL XX.REVERSAL

    END CASE

RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    IF INDEX('V',V$FUNCTION,1) THEN
        E ='LD.SER.FUNT.NOT.ALLOWED.APP'
        CALL ERR
        V$FUNCTION = ''
    END

RETURN

*************************************************************************

INITIALISE:

RETURN

*************************************************************************

DEFINE.PARAMETERS:  * SEE 'I_RULES' FOR DESCRIPTIONS *

    ST.RateParameters.SettlementRatesFieldDefinitions()

RETURN

*************************************************************************

END
