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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.PositionAndReval
    SUBROUTINE CONV.REVAL.PARAM.R07(REC.ID,R.REC,F.REVAL.FILE)
**********************************************
*
* 14/09/06 - BG_100012036
*            Conversion routine to change the value of field
*            MAINTAIN.POS.TABLE in REVALUATION.PARAMETER from
*            YES to NULL. This field also changed as RESERVED.6 field as it has
*            no significance now.
*
* 03/03/09 - BG_100022434
*            Conversion routine to change the value of field
*            RESERVED.6 in REVALUATION.PARAMETER from
*            YES/NO to NULL.
*
*********************************************


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REVALUATION.PARAMETER

* Any future changes to the insert REVALUATION.PARAMETER, when the RESERVED.6 field
* is modified to a new field, then this conversion would become absolete.

    R.REC<REVAL.P.REVAL.RATE> = ''

    RETURN
END
