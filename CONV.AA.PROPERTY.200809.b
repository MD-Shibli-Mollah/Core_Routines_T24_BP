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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ProductFramework
    SUBROUTINE CONV.AA.PROPERTY.200809(YID, R.RECORD, FN.FILE)

********************************************************************************
*
* 18/06/08 - EN_10003714
* This is the conversion routine to remove the PRODUCT.ONLY value from the field of
* PROPERTY.TYPE for ACTIVITY.MESSAGING Property Class.
*
********************************************************************************-
* !** Simple SUBROUTINE template
* @author sivall@temenos.com
* @stereotype subroutine
* @package infra.eb
*!
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONVERSION.DETAILS
    $INSERT I_F.AA.PROPERTY


*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
PROCESS:



    IF R.RECORD<AA.PROP.PROPERTY.CLASS> EQ "ACTIVITY.MESSAGING" THEN
        R.RECORD<AA.PROP.PROPERTY.TYPE, 1> = ""
    END

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:


    RETURN
*-----------------------------------------------------------------------------
END
