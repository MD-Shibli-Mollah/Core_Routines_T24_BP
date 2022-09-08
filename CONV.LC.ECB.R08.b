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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
* Version n 07/07/07  GLOBUS Release No. R08 28/08/07
*
   $PACKAGE RE.ConBalanceUpdates
   SUBROUTINE CONV.LC.ECB.R08(ID,R.COMP,FILE)
*----------------------------------------------------------------------------------------------
* This Conversion routine will just update the Trigger record "ECB.CONTRACT" in AC.CONV.ENTRY with "LC".
* In the batch job EOD.CONV.ECB, this record will get processed and inturn the routine RE.UPDATE.LC.ECB
* gets triggered which does the actual conversion(RE.CONTRACT.DETAIL -> EB.CONTRACT.BALANCES).
*----------------------------------------------------------------------------------------------
* Modification History:
*
* 16/09/07 - EN_10003508 /REF: SAR-2007-02-08-0002
*            New Conversion routine for writing a trigger record in AC.CONV.ENTRY.
*
*<<----------------------------------------------------------------------------->>
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY

***   Main processing   ***
*     ---------------     *
* Take the mnemonic from the current comp
*
   YCOMP.MNE = R.COMP<EB.COM.FINANCIAL.MNE>

   R.AC.CONV.ENTRY = ''

   FN.AC.CONV.ENTRY = 'F':YCOMP.MNE:'.AC.CONV.ENTRY'
   F.AC.CONV.ENTRY = ''

   OPEN FN.AC.CONV.ENTRY TO F.AC.CONV.ENTRY THEN
      AC.CONV.ENTRY.ID = "ECB.CONTRACT"
      READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN
         LOCATE 'LC' IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
            INS 'LC' BEFORE R.AC.CONV.ENTRY<POSN>
         END
         WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
      END ELSE
         WRITE 'LC' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
      END
   END
*
   RETURN
*
*<<----------------------------------------------------------------------------->>
   END
