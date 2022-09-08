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
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
    SUBROUTINE CONV.CUSTOMER.SECURITY.200706(ID,YREC,FILENAME)
*-----------------------------------------------------------------------------
* Correction/conversion routine for CUSTOMER.SECURITY
* Here the drilldown value 520-523 in DEPO.INSTR.TYPE field is removed
* as part of the IS015022 standards.
*-----------------------------------------------------------------------------
* Modification History :
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

* If the field value of DEPO.INSTR.TYPE field value in CUSTOMER.SECURITY is
* 520-523 then it is cleared off as part of the IS015022 standardard.

    IF YREC<39> = '520-523' THEN
        YREC<39> = ''
    END

    RETURN

END
