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

*-----------------------------------------------------------------------------
* <Rating>69</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
      SUBROUTINE CONV.AC.VIOLATION.G150(AC.VIOL.ID,AC.VIOL.REC,FILE)
*
*************************************************************************
* This routine is to populate the PROCESSING.DATE field in the AC.VIOLATION record.
* It will get the PROCESSING DATE from the STMT.ENTRY VALUE.DATE field.
*************************************************************************
*
* 20/12/04 - BG_100007803
*            LOAD.COMPANY is not done when running conversions, so
*            the Mnemonic must be passed in the OPF.
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.STMT.ENTRY
*************************************************************************
*
      GOSUB INITIALISE

      GOSUB PROCESS.AC.VIOL

      RETURN
*
*************************************************************************
INITIALISE:
*      Open files

      FN.STMT.ENTRY= FILE[".",1,1]:'.STMT.ENTRY'   ;* BG_100007803
      F.STMT.ENTRY = ''
      CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)

      RETURN

*************************************************************************
*
PROCESS.AC.VIOL:
*
      NO.STMTS = DCOUNT(AC.VIOL.REC<1>,VM)
      I = 0
      LOOP
         I += 1
      UNTIL I > NO.STMTS

         STMT.ID = AC.VIOL.REC<1,I>
         IF AC.VIOL.REC<1,I> THEN
            READ STMT.REC FROM F.STMT.ENTRY,STMT.ID ELSE CONTINUE
            AC.VIOL.REC<2,I> = STMT.REC<AC.STE.BOOKING.DATE>
            IF STMT.REC<AC.STE.REVERSAL.MARKER> THEN
               AC.VIOL.REC<4,I> = 'R'
            END ELSE
               AC.VIOL.REC<4,I> = 'V'
            END
            AC.VIOL.REC<5,I> = STMT.REC<AC.STE.TRANSACTION.CODE>
         END
      REPEAT


      RETURN

   END
