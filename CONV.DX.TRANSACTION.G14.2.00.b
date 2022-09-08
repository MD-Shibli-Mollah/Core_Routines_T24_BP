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
    $PACKAGE DX.Trade
    SUBROUTINE CONV.DX.TRANSACTION.G14.2.00(YID,YREC,YFILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRANSACTION

    IF YREC<DX.TX.SOURCE.REF> = 'DXTRA' THEN
        CALL DX.GEN.POS.KEY(YREC,GEN.POS.KEY)
        YREC<DX.TX.LAST.REP.POS> = GEN.POS.KEY
    END

    RETURN
END
