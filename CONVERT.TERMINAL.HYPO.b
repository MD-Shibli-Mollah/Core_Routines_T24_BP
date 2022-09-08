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

* Version 2 13/04/00  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>188</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.DatInterface
      SUBROUTINE CONVERT.TERMINAL.HYPO
*
* Add 8 new fields to the terminal record
*
$INSERT I_F.TERMINAL
$INSERT I_SCREEN.VARIABLES
*
      FILE = "F.TERMINAL"
      FILE<2> = "F.TERMINAL$NAU"
      V$FIELDS = STR(@FM,7)              ; * Number of fields - 1
*
      LOOP FNAME = REMOVE(FILE,D) UNTIL FNAME = ''
         F.FNAME = ""
         CALL OPF(FNAME,F.FNAME)
         PRINT @(30,4): "File ": FNAME
         PRINT @(30,5): S.CLEAR.EOL:
         SELECT F.FNAME
         LOOP READNEXT ID ELSE ID = "" UNTIL ID = ""
            READU R.REC FROM F.FNAME, ID THEN
               IF R.REC<RT.CURR.NO> = "" THEN      ; * New current no. outside record
                  INS V$FIELDS BEFORE R.REC<31>
                  WRITE R.REC TO F.FNAME, ID
                  PRINT @(30,5): "Converted : ":ID
               END ELSE
                  RELEASE F.FNAME
               END
            END
         REPEAT
      REPEAT
*
      RETURN
   END
