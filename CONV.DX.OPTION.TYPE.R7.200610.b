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
    $PACKAGE DX.Configuration
      SUBROUTINE CONV.DX.OPTION.TYPE.R7.200610(DX.OPTION.TYPE.ID,R.DX.OPTION.TYPE,FN.DX.OPTION.TYPE)
*-----------------------------------------------------------------------------
* This routine clears the fields DX.OT.BARRIER, DX.OT.GEARING and DX.OT.REBATE.
* Fields Barrier, Gearing and Rebate made obsolete in DX.OPTION.TYPE.
*
* Field numbers are (as of 200610):
*
*     DX.OT.BARRIER  3
*     DX.OT.GEARING  4
*     DX.OT.REBATE   5
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

      EQUATE BARRIER TO 3
      EQUATE GEARING TO 4
      EQUATE REBATE TO 5

      RETURN

*-----------------------------------------------------------------------------
CLEAR.FIELDS:

      R.DX.OPTION.TYPE<BARRIER> = ''
      R.DX.OPTION.TYPE<GEARING> = ''
      R.DX.OPTION.TYPE<REBATE> = ''

      RETURN

*-----------------------------------------------------------------------------
   END
