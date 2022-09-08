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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200610 02/08/06
*
    $PACKAGE SC.SctDealerBook
      SUBROUTINE CONV.SC.ECB.R7
*----------------------------------------------------------------------------------------------
* This Conversion routine will just update the Trigger record "ECB.CONTRACT" in AC.CONV.ENTRY with "SC". 
* In the batch job EOD.CONV.ECB, this record will get processed and inturn the routine RE.UPDATE.SC.ECB 
* gets triggered which does the actual conversion(SC.TRADING.POSITION -> EB.CONTRACT.BALANCES).
*----------------------------------------------------------------------------------------------
* Modification History:
*
* 02/08/06 - EN_10003043 /REF: SAR-2006-05-30-0001
*            New Conversion routine for writing a trigger record in AC.CONV.ENTRY.
*
*<<----------------------------------------------------------------------------->>
$INSERT I_COMMON
$INSERT I_EQUATE
*<<----------------------------------------------------------------------------->>

*** <region name= Main Para>
***
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

         GOSUB WRITE.AC.CONV.ENTRY ; * Write a record in AC.CONV.ENTRY with Trigger record

      REPEAT

*Restore back ID.COMPANY if it has changed.

      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN

*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= WRITE.AC.CONV.ENTRY>
WRITE.AC.CONV.ENTRY:
*** <desc>Write a record in AC.CONV.ENTRY with Trigger record</desc>

      FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
      F.AC.CONV.ENTRY = ''
      CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

      AC.CONV.ENTRY.ID = "ECB.CONTRACT"
      READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN
         LOCATE 'SC'  IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
            INS 'SC' BEFORE R.AC.CONV.ENTRY<POSN>
         END
         WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
      END ELSE
         WRITE 'SC' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
      END

      RETURN
*** </region>

*<<----------------------------------------------------------------------------->>

   END
