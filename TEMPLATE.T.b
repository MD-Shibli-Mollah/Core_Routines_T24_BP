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

* Version 5 02/06/00  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>122</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Template
      SUBROUTINE TEMPLATE.T
*************************************************************************
* MODIFICATIONS
*
*1 8/05/00 - GB0001261
*            Jbase changes.
*            All the commented lines containing the keyword ERROR
*            has been changed to V$ERROR
*
* 02/09/02 - GLOBUS_EN_10001055
*            Conversion Of all Error Messages to Error Codes
*
* 21/09/05 - GLOBUS_BG_100009430
*            Correct comments.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB DEFINE.PARAMETERS

      IF LEN(V$FUNCTION) GT 1 THEN
         GOTO V$EXIT
      END

      CALL MATRIX.UPDATE

REM > GOSUB INITIALISE                ;* Special Initialising

*************************************************************************
* Main Program Loop

      LOOP

         CALL RECORDID.INPUT

      UNTIL MESSAGE = 'RET' DO

         V$ERROR = ''

         IF MESSAGE = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF V$FUNCTION EQ 'E' OR V$FUNCTION EQ 'L' THEN
               CALL FUNCTION.DISPLAY
               V$FUNCTION = ''
            END

         END ELSE

REM >       GOSUB CHECK.ID                     ;* Special Editing of ID
REM >       IF V$ERROR THEN GOTO MAIN.REPEAT

            CALL RECORD.READ

            IF MESSAGE = 'REPEAT' THEN
               GOTO MAIN.REPEAT
            END

            CALL MATRIX.ALTER

            CALL TABLE.DISPLAY           ; * For Table Files

         END

MAIN.REPEAT:
      REPEAT

V$EXIT:
      RETURN                             ; * From main program

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************
CHECK.ID:
* Validation and changes of the ID entered.  Set V$ERROR to 1 if in error.


      RETURN


*************************************************************************
CHECK.FUNCTION:
* Validation of function entered.  Sets V$FUNCTION to null if in error.

      IF INDEX('V',V$FUNCTION,1) THEN
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

REM > ID.F  = "Key.Description"; ID.N  = "____"; ID.T  = "_"
REM > ID.CHECKFILE = "Main.File.Name" : FM : Enrichment.Field

REM > F(1)  = "XX.LL.Index.Description";  N(1)  = "35.3"
REM > CHECKFILE(1) = "Indexed.File.Name" : FM : Enrichment.Field

      RETURN

*************************************************************************

   END
