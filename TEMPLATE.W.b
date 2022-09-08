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

* Version 8 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>799</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Template
      SUBROUTINE TEMPLATE.W
*-----------------------------------------------------------------------------
* MODIFICATIONS
*
*18/05/00 - GB0001261
*           The keyword ERROR in all the commented statements has been
*           changed to V$ERROR.
*
* 02/09/02 - GLOBUS_EN_10001055
*          Conversion Of all Error Messages to Error Codes
*
* 21/09/05 - GLOBUS_BG_100009430
*            Correct comments.
*
* 15/03/06 - EN_10002859 - New Template Programming
*            TEMPLATE, TEMPLAT.W,XX.CHECK.FIELDS are no more in use, kindly use
*            XX.TABLE & THE.TEMPLATE for new template programming.
*            Ref:SAR-2006-03-07-0001
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_SCREEN.VARIABLES

* Call $RUN Routine and Exit if running as Phantom *

      IF PHNO THEN
REM > CALL TEMPLATE.W$RUN
         GOTO V$EXIT
      END

*************************************************************************

      GOSUB DEFINE.PARAMETERS

      IF LEN(V$FUNCTION) GT 1 THEN
         GOTO V$EXIT
      END

      CALL MATRIX.UPDATE

REM > GOSUB INITIALISE                  ;* Special Initialising

*************************************************************************
* Main Program Loop

      LOOP

         CALL RECORDID.INPUT

      UNTIL MESSAGE = 'RET' DO

         V$ERROR = ''

         IF MESSAGE = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF V$FUNCTION EQ 'L' THEN
               CALL FUNCTION.DISPLAY
               V$FUNCTION = ''
            END
            IF V$FUNCTION EQ 'V' THEN
               FILE.TYPE = "I"
            END

         END ELSE

            GOSUB CHECK.ID               ; * Special Editing of ID
            IF V$ERROR THEN GOTO MAIN.REPEAT

            CALL RECORD.READ

            IF MESSAGE = 'REPEAT' THEN
               GOTO MAIN.REPEAT
            END

            CALL MATRIX.ALTER

REM > GOSUB CHECK.RECORD                ;* Special Editing of Record
REM > IF V$ERROR THEN GOTO MAIN.REPEAT

REM > GOSUB PROCESS.DISPLAY             ;* For Display applications

            LOOP
               GOSUB PROCESS.FIELDS      ; * ) For Input
               GOSUB PROCESS.MESSAGE     ; * ) Applications
            WHILE MESSAGE = 'ERROR' DO REPEAT

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

      UNTIL MESSAGE <> "" DO

REM > GOSUB CHECK.FIELDS                ;* Special Field Editing

         IF T.SEQU NE '' THEN T.SEQU<-1> = A + 1

      REPEAT

      RETURN

*************************************************************************
PROCESS.MESSAGE:
* Processing after exiting from field input (PF5)

      IF MESSAGE = 'VAL' OR MESSAGE EQ 'VER' THEN
         MESSAGE = ''
         BEGIN CASE
            CASE V$FUNCTION EQ 'R'
               END.ERROR = ""
REM > GOSUB CHECK.REVERSAL              ;* Special Reversal checks
            CASE V$FUNCTION EQ 'V'
REM > GOSUB CHECK.VERIFY                ;* Special Verify checks
               GOSUB CHECK.CHANGES       ; * look for changed field
               IF YWRITE EQ 0 AND NOT(END.ERROR) THEN
                  GOSUB CALL.$RUN        ; * update using $RUN
                  GOTO PROCESS.MESSAGE.EXIT        ; * and return to Id input
               END
            CASE OTHERWISE
REM > GOSUB AUTH.CROSS.VALIDATION       ;* Special Cross Validation
         END CASE

         IF END.ERROR THEN
            GOSUB POINT.TO.ERROR         ; * position on error field
            GOTO PROCESS.MESSAGE.EXIT    ; * return to field input
         END

REM > IF NOT(V$ERROR) THEN
REM > GOSUB BEFORE.AUTH.WRITE           ;* Special Processing before write
REM > END

         IF NOT(V$ERROR) THEN
            CALL AUTH.RECORD.WRITE

            IF MESSAGE <> "ERROR" THEN
REM > GOSUB AFTER.AUTH.WRITE            ;* Special Processing after write

               IF V$FUNCTION EQ 'V' THEN
                  GOSUB CALL.$RUN
               END

            END

         END

      END

PROCESS.MESSAGE.EXIT:

      RETURN

*************************************************************************
PROCESS.DISPLAY:
* Display the record fields.

      IF SCREEN.MODE EQ 'MULTI' THEN
         CALL FIELD.MULTI.DISPLAY
      END ELSE
         CALL FIELD.DISPLAY
      END

      RETURN

*************************************************************************
CHECK.CHANGES:

      YWRITE = 0
      IF END.ERROR EQ '' THEN
         A = 1
         LOOP UNTIL A GT V OR YWRITE DO
            IF R.NEW(A) NE R.OLD(A) THEN YWRITE = 1 ELSE A += 1
         REPEAT
      END

      RETURN

*************************************************************************
POINT.TO.ERROR:

      IF END.ERROR EQ 'Y' THEN
         P = 0 ; A = 1
         LOOP UNTIL T.ETEXT<A> NE '' DO
            A += 1
         REPEAT
         T.SEQU = A
         IF SCREEN.MODE EQ 'SINGLE' THEN
            IF INPUT.BUFFER[1,LEN(C.F)] EQ C.F THEN
               INPUT.BUFFER = INPUT.BUFFER[LEN(C.F) + 2,99]
                                         ; * cancel C.F function after C.W usage
                                         ; * (+2 for space separator)
            END
         END ELSE
            E = T.ETEXT<A>
            CALL ERR
         END
      END ELSE
         T.SEQU = 'ACTION' ; E = END.ERROR ; L = 22
         CALL ERR
      END

      CALL DISPLAY.MESSAGE("", "1")      ; * Clear the VALIDATED message
      VAL.TEXT = ""
      MESSAGE = 'ERROR'

      RETURN

*************************************************************************
CALL.$RUN:
* Process the 'Work' file using the .Run Routine *

      V$FUNCTION = FUNCTION.SAVE

REM > CALL TEMPLATE.W.RUN

      IF V$FUNCTION EQ 'B' THEN
         V$FUNCTION = 'V'
      END

      RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************
CHECK.ID:
* Validation and changes of the ID entered.  Set V$ERROR to 1 if in error.


      RETURN

*************************************************************************
CHECK.RECORD:
* Validation and changes of the Record.  Set V$ERROR to 1 if in error.


      RETURN

*************************************************************************
CHECK.FIELDS:


      RETURN

*************************************************************************
AUTH.CROSS.VALIDATION:


      RETURN

*************************************************************************
CHECK.REVERSAL:


      RETURN

*************************************************************************
CHECK.VERIFY:


      RETURN

*************************************************************************
AFTER.AUTH.WRITE:


      RETURN

*************************************************************************
BEFORE.AUTH.WRITE:


      RETURN

*************************************************************************
CHECK.FUNCTION:
* Validation of function entered.  Sets V$FUNCTION to null if in error.

      FUNCTION.SAVE = V$FUNCTION
      IF V$FUNCTION EQ "B" THEN
         V$FUNCTION = "V"
         ID.ALL = ""
      END
      IF INDEX('ADEFQ',V$FUNCTION,1) THEN
         E ='EB.RTN.FUNT.NOT.ALLOWED.APP.17'
         CALL ERR
         V$FUNCTION = ''
      END

      RETURN

*************************************************************************
INITIALISE:


      RETURN

*************************************************************************
DEFINE.PARAMETERS:
* SEE 'I_RULES' FOR DESCRIPTIONS *
* Still use XX.FIELD.DEFINITIONS

      MAT F = "" ; MAT N = "" ; MAT T = ""
      MAT CHECKFILE = "" ; MAT CONCATFILE = ""
      ID.CHECKFILE = "" ; ID.CONCATFILE = ""

REM > ID.F  = "KEY"; ID.N  = "____"; ID.T  = "_"
REM > F(1)  = "XX.LL.DESCRIPTION";  N(1)  = "35.3"; T(1)  = "A"

REM > V = NumberOfFields + 9

      RETURN

*************************************************************************

   END
