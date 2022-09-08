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
    $PACKAGE SC.Config
    SUBROUTINE CONV.CUST.SECURITY.G13.1.00(CUS.SEC.ID,R.CUS.SEC,F.CUS.SEC)
*------------------------------------------------------------------------------
* Record routine for CONVERSION.DETAILS CONV.CUST.SECURITY.G13.1.00
* Wrong update to SUB.DEPOT field in CUSTOMER.SECURITY is corrected.
*------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER.SECURITY

    IF R.CUS.SEC<47> NE '' THEN
        R.CUS.SEC<45> = R.CUS.SEC<47>
        R.CUS.SEC<47> = ''
    END

    RETURN
END
