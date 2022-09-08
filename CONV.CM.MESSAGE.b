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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CM.Contract
    SUBROUTINE CONV.CM.MESSAGE(CM.MESSAGE.ID, R.CM.MESSAGE, FN.CM.MESSAGE)
*----------------------------------------------------------------------------
*                      D E S C R I P T I O N
*----------------------------------------------------------------------------
*         Conversion routine for CM.MESSAGE. The field POSSIBLE.MATCH is
* changed as RESERVED field. No more updation will happen in this field.
* Hence the values in the existing records are cleaned using this routine.
*
*----------------------------------------------------------------------------
*                    M O D I F I C A T I O N S
*----------------------------------------------------------------------------
*
* 14/12/09 - EN_10004452
*            SAR Ref:2009-09-22-0002
*            Initial Version.
*
******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    R.CM.MESSAGE<8> = ''      ;* POSSIBLE.MATCH field is changed as RESERVED field.

    RETURN

END
