* @ValidationCode : MjoyNTIwNjUwOTA6Q3AxMjUyOjE0Nzc5NzkyMDQ1Mzk6YmFsYW5nOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTEuMDo2NTo1MQ==
* @ValidationInfo : Timestamp         : 01 Nov 2016 11:16:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : balang
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/65 (78.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201611.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 09/11/00  GLOBUS Release No. G11.1.01 11/12/00
*-----------------------------------------------------------------------------
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
	  $PACKAGE EB.Desktop
      SUBROUTINE S.INP(PROMPT.MESSAGE,N1,T1)
*=========================================================================
* Routine to prompt the user, validate his reply and return the same to
* the calling application.
*
*=========================================================================
*
* 26/06/95 - GB9500784
*            The input buffer was not being analysed for preset
*            input. Hence user was being requested for overrides and
*            inputs by the GUI at times incompatible with the operation
*            of the Classic Globus system
*
* 21/03/02 - BG_100000759
*            To supress the extra cancel button in the messages in
*            Desktop, when an error occurs in a Teller transaction.
*
* 28/06/03 - CI_10010321
*  LIMIT.REFERENCE could'nt be keyed -in when given as RE-KEY field.
* REF:NO   - HD0307636
*
* 20/07/07 - CI_10050442
*            Rekey fld for amount does not allow Authorisation in LC & DR
*            Ref: HD0705681
*
* 15/10/07 - CI_10051917
*            Cannot exit TELLER application if TELLER.ID does not exist.
*            Ref: HD0716587
*
* 20/01/11 - TASK 132293(DEFECT 126430)
*            DC - Issue with rekey on DATA CAPTURE
*            REKEY function should work properly in DESKTOP
*
* 14/07/15 - Enhancement - 1326996 / Task 1399935
*			 Incorporation of EB_Desktop component
*
* 01/11/16 - Defect 1901050 / Task 1903696
*            Fatal Error occurs after QUERY call in Desktop
*
*=========================================================================
	$USING EB.API
	$USING EB.Desktop
	$USING EB.ErrorProcessing
	$USING EB.SystemTables
*
*=========================================================================
*
* The PROMPT.MESSAGE contains both the prompt & the message - split them
* before sending to the GUI.
*
      POS = INDEX(PROMPT.MESSAGE,"     ",1)        ; * Two sentences
*
      IF POS THEN                        ; * Prompt & Message
         S.PROMPT = TRIM(PROMPT.MESSAGE[1,POS])
         S.MESSAGE = TRIM(PROMPT.MESSAGE[POS,999])
      END ELSE
         S.MESSAGE = PROMPT.MESSAGE      ; * Just a message
         S.PROMPT = ""
      END
*
* Determine if theres is a pre-set table for input eg Y_NO etc
*
      IF T1<1> = "" AND T1<2,1> THEN     ; * <2> = table ; * CI_10010321 S/E
         S.TABLE = T1<2>
      END ELSE
         S.TABLE = ""                    ; * Nope
      END
*
      PROMPT.DETAILS = S.MESSAGE
      PROMPT.DETAILS<2> = S.PROMPT
      PROMPT.DETAILS<3> = S.TABLE
      LOCATE "NV" IN EB.SystemTables.getTControlword()<1> SETTING POS THEN
         PROMPT.DETAILS<4> = "N"         ; * Flag as password input
      END
      LOCATE EB.API.getCU() IN EB.SystemTables.getTControlword()<1> SETTING POS THEN
         PROMPT.DETAILS<5> = "Y"         ; * Allow cancel button
      END
      PROMPT.DETAILS<6> = N1[".",1,1]    ; * Size of input
*
      LOOP                               ; * Until the input is ok
         EB.SystemTables.setEtext("")
         OPERATION = EB.Desktop.CPrompt
         DETAILS = PROMPT.DETAILS        ; * Message etc
		  tmp.C$REKEY = EB.Desktop.getCRekey()
         IF NOT(tmp.C$REKEY) AND EB.SystemTables.getInputBuffer()<> "" THEN
			tmp.INPUT.BUFFER = EB.SystemTables.getInputBuffer()
            EB.SystemTables.setComi(FIELD(tmp.INPUT.BUFFER," ",1))
            EB.SystemTables.setInputBuffer(FIELD(tmp.INPUT.BUFFER," ",2,99))
         END ELSE
            EB.Desktop.SGuiHost(OPERATION,DETAILS)     ; * Display & input
*
            EB.SystemTables.setComi(DETAILS); * Returned by GUI
         END
         IF EB.SystemTables.getComi() = "CANCEL" THEN         ; * F1
			tmp.C.U = EB.API.getCU()
            EB.SystemTables.setComi(tmp.C.U)
			EB.API.setCU(tmp.C.U)
         END ELSE                        ; * If COMI is not 'CANCEL'
			tmp.C$REKEY = EB.Desktop.getCRekey()
            IF NOT(tmp.C$REKEY) THEN         ; * Check for Rekey
               ROUTINE = "IN2": T1<1>    ; * IN2 routine
               EB.SystemTables.setEtext(""); * Errors returned here
               CALL @ROUTINE(N1,T1)      ; * Validate it
            END
         END
            IF EB.SystemTables.getEtext() THEN                ; * Error detected
               EB.SystemTables.setE(EB.SystemTables.getEtext())
               EB.ErrorProcessing.Err()
            END
      WHILE EB.SystemTables.getEtext()
      REPEAT
*
      LOCATE EB.SystemTables.getComi() IN EB.SystemTables.getTControlword()<1> SETTING POS THEN
         EB.SystemTables.setControlwordOk("Y"); * Function key hit
      END ELSE
         EB.SystemTables.setControlwordOk("")
      END

* BG_100000759 - S
*
      LOCATE EB.API.getCU() IN EB.SystemTables.getTControlword()<1> SETTING POS THEN
         tmpControlWord = EB.SystemTables.getTControlword()
         DEL tmpControlWord<POS>
         EB.SystemTables.setTControlword(tmpControlWord)
      END
* BG_100000759 - E
      RETURN
*
*=========================================================================
   END
*
