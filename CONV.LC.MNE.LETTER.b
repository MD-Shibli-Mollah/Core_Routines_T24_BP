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

*===============================================================
*-----------------------------------------------------------------------------
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Foundation
      SUBROUTINE CONV.LC.MNE.LETTER
*===============================================================
*Modifications
* 15/05/02 - EN_10000718
*            This conversion routine will clear out existing mnemonic
*            letter file and re-populate mnemonic.letter for each
*            company.
*
* 30/06/03 - CI_10010473
*            Call JOURNAL.UPDATE for each Company and not each record.
*
*
* 09/07/03 - CI_10010655
*            Remove call to JOURNAL.UPDATE and replace TABLE.FILE.UPDATE
*            with WRITE statement
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_CONV.COMMON
$INSERT I_F.COMPANY
*===============================================================
*
      EQU TF.LC.OLD.LC.NUMBER TO 133
      EQU TF.LC.AUDIT.DATE.TIME TO 230
*
      SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
      WHILE K.COMPANY:COMP.MARK

         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END
*
* Check whether product is installed
*
         LOCATE 'LC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN

            GOSUB INITIALISE

            GOSUB SELECT.LETTER.OF.CREDIT

            GOSUB PROCESS.LETTER.OF.CREDIT


         END

      REPEAT

*Restore back ID.COMPANY if it has changed.
      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN
*===============================================================
*==========
INITIALISE:
*==========
*
      MNEMONIC.LETTER.FILE = 'F.MNEMONIC.LETTER'
      F.MNEMONIC.LETTER = ''
      CALL OPF(MNEMONIC.LETTER.FILE, F.MNEMONIC.LETTER)

*Clear out MNEMONIC.LETTER file before further process.

      IF ETEXT = "" THEN
         CLEARFILE F.MNEMONIC.LETTER
      END ELSE
         ETEXT = ""
      END

      F.LETTER.OF.CREDIT = ''
      FN.LETTER.OF.CREDIT = 'F.LETTER.OF.CREDIT'
      CALL OPF(FN.LETTER.OF.CREDIT,F.LETTER.OF.CREDIT)

      RETURN
*===============================================================
*========================
SELECT.LETTER.OF.CREDIT:
*========================
*
*Select all LETTER.OF.CREDIT with OLD.LC.NUMBER for each company.
      KEY.LIST = ""
      SELECTED = ""
      RET.CODE = ""
      SELECT.COMMAND = 'SELECT ':FN.LETTER.OF.CREDIT: ' WITH OLD.LC.NUMBER NE ""'
*
      CALL EB.READLIST(SELECT.COMMAND, KEY.LIST, '', SELECTED, RET.CODE)
*
      RETURN
*===============================================================
*=========================
PROCESS.LETTER.OF.CREDIT:
*=========================
*
      LOOP
         REMOVE CONTRACT.ID FROM KEY.LIST SETTING POS
      WHILE CONTRACT.ID:POS

         GOSUB READ.LETTER.OF.CREDIT
         IF LC.REC NE '' THEN
            OLD.LC.NO = LC.REC<TF.LC.OLD.LC.NUMBER>

*            SAVE.ID.NEW = ID.NEW
*            SAVE.V = V
*            ID.NEW = CONTRACT.ID
*            V = TF.LC.AUDIT.DATE.TIME
*            MATPARSE R.NEW FROM LC.REC
*            CALL TABLE.FILE.UPDATE('AR':FM:'MNEMONIC.LETTER', CONTRACT.ID, OLD.LC.NO)
*            ID.NEW = SAVE.ID.NEW
*            V = SAVE.V
            IF OLD.LC.NO THEN            ; * CI_10655 +
               WRITE CONTRACT.ID ON F.MNEMONIC.LETTER, OLD.LC.NO
            END                          ; * CI_10655 -
         END
      REPEAT
      RETURN
*===============================================================
*======================
READ.LETTER.OF.CREDIT:
*======================
      LC.REC = ''
      CALL F.READ('F.LETTER.OF.CREDIT',CONTRACT.ID , LC.REC, F.LETTER.OF.CREDIT, '')

      RETURN
*===============================================================

   END
