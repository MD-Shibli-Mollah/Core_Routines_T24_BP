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
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.EB.CONTRACT.BALANCES.200708(ID,ECB.REC,FILE)

    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.EB.CONTRACT.BALANCES

*------clear existing categ.ids

    IF ECB.REC<31> THEN
        ECB.REC<31> = ''
    END

    RETURN
*
END
