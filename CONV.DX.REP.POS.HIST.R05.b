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

* Version 3 02/06/00  GLOBUS Release No. 200502 02/02/05
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Position
      SUBROUTINE CONV.DX.REP.POS.HIST.R05(ID.DX.RPH,R.DX.RPH,FN.DX.RPH)
*-----------------------------------------------------------------------------
* Program Description :
*
* This routine rearranges the records to add DELIVERY.CURRENCY after CURRENCY
* and populate it from DX.CONTRACT.MASTER. BG_100008242
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

   GOSUB INITIALISE
   
   R.DX.RPH<66> = R.DX.RPH<65>
   R.DX.RPH<65> = R.DX.RPH<64>

   R.DX.CONTRACT.MASTER = ''
   DX.CONTRACT.MASTER.ID = R.DX.RPH<3>
   YERR = ''
   CALL F.READ(FN.DX.CONTRACT.MASTER,DX.CONTRACT.MASTER.ID,R.DX.CONTRACT.MASTER,F.DX.CONTRACT.MASTER,YERR)

   IF NOT(YERR) THEN
      R.DX.RPH<64> = R.DX.CONTRACT.MASTER<12>
   END
   
   RETURN
*-----------------------------------------------------------------------------
INITIALISE:

   FN.DX.CONTRACT.MASTER = 'F.DX.CONTRACT.MASTER'
   F.DX.CONTRACT.MASTER = ''
   CALL OPF(FN.DX.CONTRACT.MASTER,F.DX.CONTRACT.MASTER)


   RETURN

*-----------------------------------------------------------------------------
*
END
