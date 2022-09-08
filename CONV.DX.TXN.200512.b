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

* Version 3 02/06/00  GLOBUS RELEASE No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TXN.200512(DX.TXN.ID,R.DX.TXN.REC,F.DX.TRANSACTION)
*-----------------------------------------------------------------------------
* Program Description
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORD
      
      RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*
     EQU DX.TX.IM.EXC.RATE TO 39,
         DX.TX.VM.EXC.RATE TO 44,
         DX.TX.PREV.VM.EXC TO 109,
         DX.TX.PREV.IM.EXC TO 117
      
      RETURN
*-----------------------------------------------------------------------------
*
PROCESS.RECORD:
*
     R.DX.TXN.REC<DX.TX.IM.EXC.RATE> =  R.DX.TXN.REC<195>  ;* Copy IM.EXC.RATE Initial margin exchange rate
     R.DX.TXN.REC<DX.TX.VM.EXC.RATE> =  R.DX.TXN.REC<193>  ;* Copy VM.EXC.RATE Variation margin exchange rate
     R.DX.TXN.REC<DX.TX.PREV.VM.EXC> =  R.DX.TXN.REC<194> ;* Copy PREV.VM.EXC Variation margin exchange rate
     R.DX.TXN.REC<DX.TX.PREV.IM.EXC> =  R.DX.TXN.REC<196> ;* Copy PREV.IM.EXC Variation margin exchange rate
*   
     R.DX.TXN.REC<193> = ""
     R.DX.TXN.REC<194> = ""
     R.DX.TXN.REC<195> = ""
     R.DX.TXN.REC<196> = ""
*   
      RETURN
*-----------------------------------------------------------------------------   
   END
