* @ValidationCode : MjotMjA0MjA3NTU2MTpDcDEyNTI6MTU2NDU3ODAzMTM0NTpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>352</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05

$PACKAGE CQ.ChqSubmit
SUBROUTINE CHEQUE.TXN.IDS

***************************************************************************
* 06/09/02 - GLOBUS_EN_10001063
*          Conversion Of all Error Messages to Error Codes
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
*18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
***************************************************************************
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.SystemTables

*************************************************************************

    GOSUB DEFINE.PARAMETERS

    V$FUNCTION.VAL= EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

REM > GOSUB INITIALISE                ;* Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL EB.SystemTables.getMessage() = 'RET' DO

        V$ERROR = ''

        IF EB.SystemTables.getMessage() = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

REM >       GOSUB CHECK.ID                  ;* Special Editing of ID
REM >       IF ERROR THEN GOTO MAIN.REPEAT

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() = 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            GOSUB PROCESS.DISPLAY        ; * For Display applications

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
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


RETURN


*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    V$FUNCTION.VAL= EB.SystemTables.getVFunction()
    IF INDEX('V',V$FUNCTION.VAL,1) THEN
        EB.SystemTables.setE('AC.RTN.FUNT.NOT.ALLOWED.APP.5')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************

INITIALISE:


RETURN

*************************************************************************

DEFINE.PARAMETERS:* SEE 'I_RULES' FOR DESCRIPTIONS *


EB.SystemTables.clearF() ; EB.SystemTables.clearN() ; EB.SystemTables.clearT()
EB.SystemTables.clearCheckfile() ; EB.SystemTables.clearConcatfile()
EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")

EB.SystemTables.setIdF("CHEQUE.TXN.IDS"); EB.SystemTables.setIdN("35.1"); EB.SystemTables.setIdT("A")
*
Z = 0
Z+=1 ; EB.SystemTables.setF(Z, "XX<CHEQUE.NO"); EB.SystemTables.setN(1, "35.3"); EB.SystemTables.setT(1, "A")
Z+=1 ; EB.SystemTables.setF(Z, "XX>XX.TXN.ID"); EB.SystemTables.setN(1, "35.3"); EB.SystemTables.setT(1, "A")
Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.4"); EB.SystemTables.setN(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.3"); EB.SystemTables.setN(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.2"); EB.SystemTables.setN(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.1"); EB.SystemTables.setN(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)

EB.SystemTables.setV(Z)

RETURN

*************************************************************************

END
