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

*
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TRADE.R7.200610(DX.TRADE.ID,R.DX.TRADE,FN.DX.TRADE)
*-----------------------------------------------------------------------------
* This routine clears the fields DX.TRA.BARRIER, DX.TRA.GEARING and
* DX.TRA.REBATE from DX.TRADE and DX.ORD.BARRIER, DX.ORD.GEARING and
* DX.ORD.REBATE from DX.ORDER.
* Fields Barrier, Gearing and Rebate made obsolete in DX.OPTION.TYPE.
* Therefore also, these fields being made obsolete in DX.TRADE & DX.ORDER.
*
* Field numbers are (as of 200610):
*
*     DX.BARRIER  185
*     DX.GEARING  186
*     DX.REBATE   187
*-----------------------------------------------------------------------------
* Modification History:
*
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB EQUATE.FIELDS
      GOSUB CLEAR.FIELDS

      RETURN

*-----------------------------------------------------------------------------
EQUATE.FIELDS:

      EQUATE BARRIER TO 185
      EQUATE GEARING TO 186
      EQUATE REBATE TO 187

      RETURN

*-----------------------------------------------------------------------------
CLEAR.FIELDS:

      R.DX.TRADE<BARRIER> = ''
      R.DX.TRADE<GEARING> = ''
      R.DX.TRADE<REBATE> = ''

      RETURN

*-----------------------------------------------------------------------------
   END
