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

* Version 3 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>494</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
      SUBROUTINE CONV.DE.MAPPING.FIELDS
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
$INSERT I_F.DE.MAPPING


*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
** 05/023/96 - GB9600145
**             Do not give an override if already converted simply continue
*
* 24/09/02 - GLOBUS_EN_10001221
*          Conversion Of all Error Messages to Error Codes
*************************************************************************
INITIALISE:
*
      EQU TRUE TO 1, FALSE TO ''
      TEXT = ''
      ETEXT = ''
      CLS = ''                           ; * Clear Screen
      ALREADY.CONV = 0
      MAPPING.KEY = ''
      ABORT.FLAG = ""
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      YFILE = "F.DE.MAPPING"             ; * File to be converted
      COMPANY.CODE.POS = "16"            ; * Position of new XX.CO.CODE in the file
      INPUTTER.POS = "13"                ; * Position of INPUTTER to store conversion id
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

      ID = FIELD(YFILE,'.',2,99)
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
         YFILE = 'F.FILE.CONTROL'
         GOTO FATAL.ERROR
      END
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)

      FILE.NAME = YFILE
      GOSUB MODIFY.FILE

      RETURN

*
*************************************************************************
*
MODIFY.FILE:
*

      CALL SF.CLEAR.STANDARD
      TEXT = ""
      YFILE = FILE.NAME
      F.FILE = ""
      OPEN '', YFILE TO F.FILE THEN
         GOSUB MODIFY.FILE.START
      END

      RETURN


*
*************************************************************************
*
MODIFY.FILE.START:
*
      CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
      V$COUNT = 0                        ; * Initialise.
      ALREADY.CONV = 0                   ; * Already converted counter
      SELECT F.FILE
      END.OF.FILE = FALSE
      ABORT.FLAG = FALSE

      LOOP

         YTEXT = "Enter the name of the record : "
         CALL TXTINP(YTEXT, 8, 22, "35", "A")

         YID = COMI

      UNTIL YID EQ "" DO
*
         READ YREC FROM F.FILE, YID ELSE
            E ="DE.RTN.REC.NOT.ON.MAPPING.FILE"
            CALL ERR
            GOTO LOOP.BACK
         END

         CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)

         TOT.POS = ''
         TOT.POS = DCOUNT(YREC<DE.MAP.INPUT.POSITION>, VM)

         FOR AV = 1 TO TOT.POS

            IF YREC<DE.MAP.INPUT.POSITION, AV> NE "" THEN
               R.STAND.SEL = ''
               POS = ''
               POSITION = INDEX(YREC<DE.MAP.INPUT.POSITION, AV> , "." , 1)

               LOCATE YREC<DE.MAP.INPUT.POSITION, AV>[1 , POSITION - 1] IN YREC<DE.MAP.INPUT.REC.NO, 1> SETTING POS THEN

                  CALL GET.STANDARD.SELECTION.DETS(YREC<DE.MAP.INPUT.FILE, POS> , R.STAND.SEL)

                  IF R.STAND.SEL NE "" THEN

                     REC.POSN = FIELD(YREC<DE.MAP.INPUT.POSITION, AV>, ".", 2 , 99)
                     FIELD.NUMBER = REC.POSN
                     FIELD.NAME = '' ; DATA.TYPE = '' ; ERR.MSG = ''

                     CALL FIELD.NUMBERS.TO.NAMES(FIELD.NUMBER , R.STAND.SEL , FIELD.NAME , DATA.TYPE , ERR.MSG)

                     IF NOT(ERR.MSG) THEN
                        YREC<DE.MAP.INPUT.NAME, AV> = FIELD.NAME
                        YREC<DE.MAP.INPUT.POSITION, AV> = YREC<DE.MAP.INPUT.POSITION, AV>[1 , POSITION - 1]
                     END

                  END
               END
            END
         NEXT AV

         IF INPUTTER.POS THEN YREC<INPUTTER.POS,-1> = TNO:"_":APPLICATION
         WRITE YREC TO F.FILE, YID

*
LOOP.BACK:

      REPEAT

      RETURN

*
*
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      ETEXT ="DE.RTN.WHY.PROGRAM.ABORTED"          ; * Used to update F.CONVERSION.PGMS
      CALL PGM.BREAK
*
*************************************************************************
   END
