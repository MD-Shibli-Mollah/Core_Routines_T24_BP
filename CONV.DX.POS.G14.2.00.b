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
    $PACKAGE DX.Position
    SUBROUTINE CONV.DX.POS.G14.2.00(DX.POSITION.ID,R.DX.POSITION,F.DX.POSITION)
* Conversion routine to clear RESERVED.11 field, as this field was replaced
* for AVERAGE.IPRICE
*
    EQUATE DX.POS.RESERVED.11 TO 17
    R.DX.POSITION<DX.POS.RESERVED.11> = ""

    RETURN
END
