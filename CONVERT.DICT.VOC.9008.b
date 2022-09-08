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
* <Rating>698</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.DatInterface
      SUBROUTINE CONVERT.DICT.VOC.9008
* Version 2 05/01/00  GLOBUS Release No. G10.2.01 25/02/00
* Modifications
* 27/03/00  GB0000576  - Jbase changes.
*           - LABEL NAME should be immediately followed by colon, and
      *        this error could be rectified by just FORMATTING the program.
*
*
* CONVERT.DICT.VOC.9008
*
*------------------------------------------------------------------------
*
* Utility to check that an F.xxxxxxxxx entry exists for all non-install-
* -ation level files which points to the dictionary. Hence when files
* are created for multi-companies they can still share the dictionaries.
*
*------------------------------------------------------------------------
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
*
*------------------------------------------------------------------------
*
*
      GOSUB INITIALISATION
      GOSUB SELECT.FILE.CONTROL
      GOSUB CHECK.AND.UPDATE.VOC
*
      GOTO PROGRAM.END
*
*------------------------------------------------------------------------
*
INITIALISATION:
*
      V$PROMPT = "Check and convert dictionary pointers. Continue <Y/N>"
      CALL INP(V$PROMPT,8,22,"1",@FM:"Y_N")
*
      IF COMI = "N" THEN
         GOTO PROGRAM.ABORT
      END
*
      OPEN "","VOC" TO F.VOC ELSE
         TEXT = "Unable to open VOC file"
         GOTO PROGRAM.ERROR
      END
*
* Select company file to extract all mnemonics
*
      PRINT @(1,4):
      EXECUTE "SSELECT F.COMPANY SAVING MNEMONIC"
*
      MNEMONIC.LIST = ""
*
      LOOP READNEXT MNE ELSE MNE = "" UNTIL MNE = ""
         MNEMONIC.LIST<-1> = MNE
      REPEAT
*
      RETURN
*
*------------------------------------------------------------------------
*
SELECT.FILE.CONTROL:
*
      PRINT @(1,2):"Selecting FILE.CONTROL....."
      PRINT @(1,4)                       ; * Reposition cursor
*
      EXECUTE "SSELECT F.FILE.CONTROL WITH CLASSIFICATION NE 'INT'"
*
      TOT.FILE = @SYSTEM.RETURN.CODE
*
      IF NOT(TOT.FILE) THEN
         TEXT = "Selection of FILE.CONTROL failed"
         GOTO PROGRAM.ERROR
      END
*
      RETURN
*
*------------------------------------------------------------------------
*
CHECK.AND.UPDATE.VOC:
*
      PRINT @(1,2): FMT("Processing ","40L"):
      V$COUNT = 0
*
      LOOP READNEXT FILE.ID ELSE FILE.ID = "" UNTIL FILE.ID = ""
*
         V$COUNT +=1
         PRINT @(14,2):FMT(V$COUNT,"4R"):" ":FMT(TOT.FILE,"4R"):" ":FMT(FILE.ID,"32L"):
*
         I = 0 ; VOC.ID = ""
         LOOP I+=1 ; MNE = MNEMONIC.LIST<I> UNTIL MNE = "" OR VOC.ID
            VOC.ID = "F":MNE:".":FILE.ID
            READ R.VOC FROM F.VOC, VOC.ID ELSE VOC.ID = ""
         REPEAT
*
         IF VOC.ID AND R.VOC<3> THEN
            DICT.POINTER = R.VOC<3>
            READ R.VOC FROM F.VOC, "F.":FILE.ID ELSE
               R.VOC = "F"
            END
            R.VOC<3> = DICT.POINTER
            WRITE R.VOC TO F.VOC, "F.":FILE.ID
         END
*
      REPEAT
*
      CALL INP("Update Complete. Press <CR>",8,22,1,"A")
*
      RETURN
*
*------------------------------------------------------------------------
*
PROGRAM.ERROR:
*
      CALL REM
      GOTO PROGRAM.ABORT
*
*------------------------------------------------------------------------
*
PROGRAM.ABORT:
*
      RETURN TO PROGRAM.ABORT
*
*------------------------------------------------------------------------
*
PROGRAM.END:
*
      RETURN
*
*------------------------------------------------------------------------
   END
