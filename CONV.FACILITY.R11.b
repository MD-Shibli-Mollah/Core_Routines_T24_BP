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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SL.Facility
    SUBROUTINE CONV.FACILITY.R11(FAC.ID, FAC.REC, SLL.FILE)
*-----------------------------------------------------------------------------
*** <region name= Modifications>
*** <desc> </desc>
*
* 13/04/13 - TASK : 649841
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
* Modifications
*** </region>
***********************************************************************************
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU FAC.MULTI.PROD.FAC TO 105

*** </region>
*** <region name= Main Program>
*** <desc>Main Program </desc>
    IF FAC.REC<FAC.MULTI.PROD.FAC> EQ '' THEN
        FAC.REC<FAC.MULTI.PROD.FAC> = 'NO'
    END
*** </region>
    RETURN
    END
