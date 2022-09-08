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
    $PACKAGE SL.Loans
    SUBROUTINE CONV.SL.LOANS.200604(LN.ID, LN.REC, SLL.FILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU SL.LN.ACCRUAL.ID TO 14

    LN.REC<SL.LN.ACCRUAL.ID> = ""

    RETURN
END
