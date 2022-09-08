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

* Version 6 22/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>308</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Template
      SUBROUTINE TEMPLATE.L
*********************************************************************

**********************************************************************
* 02/09/02 - GLOBUS_EN_10001055
*          Conversion Of all Error Messages to Error Codes
*
* 21/09/05 - GLOBUS_BG_100009430
*            Correct misleading comments
*********************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB INITIALISE                   ; * Special Initialising

      GOSUB DEFINE.PARAMETERS

      IF LEN(V$FUNCTION) GT 1 THEN
         GOTO V$EXIT
      END

      CALL MATRIX.UPDATE


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

            GOSUB CHECK.ID               ; * Special Editing of ID
            IF V$ERROR THEN GOTO MAIN.REPEAT

            CALL RECORD.READ

            IF MESSAGE = 'REPEAT' THEN
               GOTO MAIN.REPEAT
            END

            CALL MATRIX.ALTER

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

      IF SCREEN.MODE EQ 'MULTI' THEN
         CALL FIELD.MULTI.DISPLAY
      END ELSE
         CALL FIELD.DISPLAY
      END

      RETURN

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
*
* Define often used checkfile variables
*
REM      CHK.ACCOUNT = "ACCOUNT":FM:AC.SHORT.TITLE:FM:"L"
REM      CHK.CUSTOMER = "CUSTOMER":FM:EB.CUS.SHORT.NAME:FM:'.A'
REM      CHK.CUSTOMER.SECURITY = "CUSTOMER.SECURITY":FM:0:FM:'':FM:"CUSTOMER":FM:EB.CUS.SHORT.NAME:FM:'..S'
REM      CHK.SAM = "SEC.ACC.MASTER":FM:SC.SAM.ACCOUNT.NAME:FM:'..S'

      RETURN

*************************************************************************
DEFINE.PARAMETERS:
* SEE 'I_RULES' FOR DESCRIPTIONS *
* Still use XX.FIELD.DEFINITIONS, but set V = Z, not Z+9

      MAT F = "" ; MAT N = "" ; MAT T = ""
      MAT CHECKFILE = "" ; MAT CONCATFILE = ""
      ID.CHECKFILE = "" ; ID.CONCATFILE = ""

      ID.F = "KEY" ; ID.N = "___" ; ID.T = "_"
*
      Z=0
*
REM > Z+=1 ; F(Z) = "XX.XX.FIELD.NAME" ; N(Z) = "35.2" ; T(Z) = "A"
REM > CHECKFILE(Z) = CHK.ACCOUNT
*
*
* Live files DO NOT require V = Z + 9 as there are not audit fields.
* But it does require V to be set to the number of fields
*
      V = Z

      RETURN

*************************************************************************

   END
