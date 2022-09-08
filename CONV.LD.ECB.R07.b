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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LD.Contract
      SUBROUTINE CONV.LD.ECB.R07
*______________________________________________________________________________________
*
* This routine will write AC.CONV.ENTRY file to trigger to update EB.CONTRACT.BALANCES
* from the LD and PD balance files.
*
* Modification log:
* -----------------
* 14/09/06 - EN_10003056
*            New conversion routine to update AC.CONV.ENTRY file to trigger
*            LD/PD conversion for EB.CONTRACT.BALANCES update.
*______________________________________________________________________________________
*
$INSERT I_COMMON
$INSERT I_EQUATE

      SAVE.ID.COMPANY = ID.COMPANY

*--   Loop through each company
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
      WHILE K.COMPANY:COMP.MARK

         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

*--      Check whether product is installed
         GOSUB INITIALISE
         GOSUB WRITE.AC.CONV.ENTRY

      REPEAT

*--   Restore back ID.COMPANY if it has changed.
      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN

*______________________________________________________________________________________
*
INITIALISE:
*---------

      FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
      F.AC.CONV.ENTRY = ''
      CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

      RETURN
*______________________________________________________________________________________
*
WRITE.AC.CONV.ENTRY:
*-------------------

      AC.CONV.ENTRY.ID = "ECB.CONTRACT"
      READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID ELSE
         R.AC.CONV.ENTRY = ''
      END

      LOCATE 'LD' IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
         INS 'LD' BEFORE R.AC.CONV.ENTRY<POSN>
      END

      WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID

      RETURN
*______________________________________________________________________________________
*
   END
