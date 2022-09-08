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

* Version 3 13/04/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>199</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.SECURITY.SUPP.0892
* Version 2 20/04/94  GLOBUS Release No. 14.1.1 29/04/94
      EQU TRUE TO 1 , FALSE TO ''
      MAXFIELDS = 50
      INSERT.POS = MAXFIELDS - 9
      FOR X = 1 TO 3
         BEGIN CASE
            CASE X = 1
               FILE = 'F.SECURITY.SUPP$NAU'
            CASE X = 2
               FILE = 'F.SECURITY.SUPP'
            CASE X = 3
               FILE = 'F.SECURITY.SUPP$HIS'
         END CASE

         OPEN '',FILE TO FILE.FV ELSE
            STOP 'UNABLE TO OPEN ':FILE
         END

         LINE = 'SELECT ':FILE
         PRINT LINE
         EXECUTE LINE
         EOF = FALSE

         LOOP
            READNEXT ID ELSE EOF = TRUE
         UNTIL EOF
            READ RECORD FROM FILE.FV, ID THEN
               IF DCOUNT(RECORD,@FM) LT MAXFIELDS THEN
                  NO.OF.ITEMS = MAXFIELDS - DCOUNT(RECORD,@FM)
                  FOR XX = 1 TO NO.OF.ITEMS
                     INS '' BEFORE RECORD<INSERT.POS>
                  NEXT XX
               END
               WRITE RECORD TO FILE.FV, ID
            END
         REPEAT
      NEXT X

      RETURN                             ; * Exit Program.
   END
