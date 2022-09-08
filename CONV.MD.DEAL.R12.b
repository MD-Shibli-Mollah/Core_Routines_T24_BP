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
    $PACKAGE MD.Contract
    SUBROUTINE CONV.MD.DEAL.R12(MD.ID,MD.REC,MD.FILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* 13/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
* Modifications
*** </region>
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.DEA.SL.REF.TRANCHE TO 130
    EQU MD.DEA.VALUE.DATE TO 6
    EQU MdDeal_CsnPaymentType TO 48
    EQU MdDeal_FixedAmount TO 54
    EQU MD.DEA.RETURN.COMM TO 145
    EQU MD.DEA.RATE.CHANGE TO 142
    EQU MD.DEA.SL.LINK.DATE TO 141

    IF MD.REC<MD.DEA.SL.REF.TRANCHE> THEN
        MD.REC<MD.DEA.SL.LINK.DATE> = MD.REC<MD.DEA.VALUE.DATE>
    END
    IF MD.REC<MdDeal_CsnPaymentType> AND MD.REC<MdDeal_FixedAmount> NE 'YES' THEN
        MD.REC<MD.DEA.RETURN.COMM> = "YES"
        MD.REC<MD.DEA.RATE.CHANGE> = "NO"
    END
    RETURN
    END
