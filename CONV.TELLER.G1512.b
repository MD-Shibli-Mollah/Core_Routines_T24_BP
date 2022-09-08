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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.Contract
    SUBROUTINE CONV.TELLER.G1512(ID,Y.REC,FILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE

    IF FILE[4] EQ '$HIS' OR FILE[4] EQ '$NAU' THEN RETURN
    IF Y.REC<66> EQ '' THEN
        Y.REC<66> = TODAY
    END
    RETURN
END
